<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.sql.SQLException,java.util.Arrays,java.util.HashMap,java.util.HashSet,java.util.LinkedHashSet,java.util.Map,java.util.Set" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/usuario.jspf" %>
<%@ include file="/WEB-INF/modelo/perfil.jspf" %>
<%@ include file="/WEB-INF/modelo/usuario_rol.jspf" %>
<%@ include file="/WEB-INF/modelo/auditoria.jspf" %>
<%--
  Administración de cuentas (solo ADMINISTRADOR).
  GET  ?accion=listar[&q=texto&pagina=N] | nuevo | editar&id_usuario=N
  POST ?accion=crear (nombres, apellidos, correo, clave, roles) | actualizar&id_usuario=N (nombres, apellidos, correo, clave opcional)
       | cambiar_estado&id_usuario=N (activo=true|false)
  Los roles ADMINISTRADOR y CLIENTE se gestionan aquí; INMOBILIARIA pertenece a B3.
--%>
<%!
    private static final int USUARIOS_POR_PAGINA = 10;
%>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    boolean esPost = "POST".equals(request.getMethod());
    Integer idObjetivo = aEntero(request.getParameter("id_usuario"));
    Map<String, String> errores = new HashMap<String, String>();
    Map<String, String> valores = new HashMap<String, String>();

    if ("cambiar_estado".equals(accion) && esPost) {
        boolean activar = "true".equals(request.getParameter("activo"));
        if (!tokenValido(request)) {
            session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
        } else if (idObjetivo == null) {
            session.setAttribute("mensajeError", "No se indicó la cuenta.");
        } else if (!activar && idObjetivo.equals(idUsuarioSesion)) {
            session.setAttribute("mensajeError", "No puedes desactivar tu propia cuenta.");
        } else {
            try (Connection conexion = abrirConexion()) {
                if (cambiarEstadoUsuario(conexion, idObjetivo, activar)) {
                    registrarEvento(conexion, idUsuarioSesion,
                            (activar ? "USUARIO_ACTIVADO" : "USUARIO_DESACTIVADO") + " · cuenta " + idObjetivo);
                    session.setAttribute("mensaje", activar ? "Cuenta activada." : "Cuenta desactivada.");
                } else {
                    session.setAttribute("mensajeError", "La cuenta no existe.");
                }
            }
        }
        response.sendRedirect(ctx + "/controlador/usuario.jsp?accion=listar");
        return;
    }

    if (("crear".equals(accion) || "actualizar".equals(accion)) && esPost) {
        boolean creando = "crear".equals(accion);
        String nombres = limpiar(request.getParameter("nombres"));
        String apellidos = limpiar(request.getParameter("apellidos"));
        String correo = limpiar(request.getParameter("correo"));
        String clave = request.getParameter("clave");
        if (correo != null) {
            correo = correo.toLowerCase(Locale.ROOT);
        }
        if (clave != null && clave.isEmpty()) {
            clave = null;
        }
        Set<String> rolesElegidos = new LinkedHashSet<String>();
        String[] rolesRecibidos = request.getParameterValues("roles");
        if (rolesRecibidos != null) {
            for (String rol : rolesRecibidos) {
                if ("ADMINISTRADOR".equals(rol) || "CLIENTE".equals(rol)) {
                    rolesElegidos.add(rol);
                }
            }
        }
        valores.put("nombres", nombres);
        valores.put("apellidos", apellidos);
        valores.put("correo", correo);

        if (!tokenValido(request)) {
            errores.put("general", "El formulario expiró. Vuelve a intentarlo.");
        }
        if (!creando && idObjetivo == null) {
            errores.put("general", "No se indicó la cuenta.");
        }
        if (!longitudValida(nombres, 1, 100)) {
            errores.put("nombres", "Escribe los nombres (máximo 100 caracteres).");
        }
        if (!longitudValida(apellidos, 1, 100)) {
            errores.put("apellidos", "Escribe los apellidos (máximo 100 caracteres).");
        }
        if (!esCorreo(correo)) {
            errores.put("correo", "Escribe un correo válido.");
        }
        if (creando && clave == null) {
            errores.put("clave", "Escribe una contraseña inicial.");
        } else if (clave != null && (clave.length() < 8 || clave.length() > 100)) {
            errores.put("clave", "La contraseña debe tener entre 8 y 100 caracteres.");
        }
        if (creando && rolesElegidos.isEmpty()) {
            errores.put("roles", "Elige al menos un rol.");
        }

        if (errores.isEmpty()) {
            Connection conexion = null;
            try {
                conexion = abrirConexion();
                conexion.setAutoCommit(false);
                int idGuardado;
                if (creando) {
                    idGuardado = crearUsuario(conexion, correo, generarClave(clave));
                    crearPerfil(conexion, idGuardado, nombres, apellidos);
                    for (String rol : rolesElegidos) {
                        asignarRol(conexion, idGuardado, rol);
                    }
                } else {
                    idGuardado = idObjetivo;
                    if (buscarUsuario(conexion, idGuardado) == null) {
                        throw new SQLException("La cuenta no existe.", "P0002");
                    }
                    actualizarCorreo(conexion, idGuardado, correo);
                    Map<String, Object> perfilActual = buscarPerfil(conexion, idGuardado);
                    guardarPerfil(conexion, idGuardado, nombres, apellidos,
                            (String) perfilActual.get("documento"), (String) perfilActual.get("telefono"),
                            (String) perfilActual.get("direccion"));
                    if (clave != null) {
                        actualizarClave(conexion, idGuardado, generarClave(clave));
                    }
                }
                registrarEvento(conexion, idUsuarioSesion, (creando ? "USUARIO_CREADO" : "USUARIO_ACTUALIZADO")
                        + " · cuenta " + idGuardado + " · " + correo + (clave != null && !creando ? " · clave cambiada" : ""));
                conexion.commit();
                if (idGuardado == idUsuarioSesion) {
                    session.setAttribute("nombreUsuario", (nombres + " " + apellidos).trim());
                }
                session.setAttribute("mensaje", creando ? "Cuenta creada." : "Cuenta actualizada.");
                response.sendRedirect(ctx + "/controlador/usuario.jsp?accion=editar&id_usuario=" + idGuardado);
                return;
            } catch (SQLException e) {
                if (conexion != null) {
                    try { conexion.rollback(); } catch (SQLException ignorada) { }
                }
                if ("23505".equals(e.getSQLState())) {
                    errores.put("correo", "El correo ya se encuentra registrado.");
                } else if ("P0002".equals(e.getSQLState())) {
                    errores.put("general", e.getMessage());
                } else {
                    errores.put("general", mensajeError(e));
                }
            } finally {
                if (conexion != null) {
                    try { conexion.close(); } catch (SQLException ignorada) { }
                }
            }
        }
        accion = creando ? "nuevo" : "editar";
        request.setAttribute("rolesElegidos", rolesElegidos);
    }

    if ("nuevo".equals(accion) || "editar".equals(accion)) {
        if ("editar".equals(accion)) {
            if (idObjetivo == null) {
                response.sendRedirect(ctx + "/controlador/usuario.jsp?accion=listar");
                return;
            }
            try (Connection conexion = abrirConexion()) {
                Map<String, Object> usuario = buscarUsuario(conexion, idObjetivo);
                if (usuario == null) {
                    session.setAttribute("mensajeError", "La cuenta no existe.");
                    response.sendRedirect(ctx + "/controlador/usuario.jsp?accion=listar");
                    return;
                }
                request.setAttribute("usuario", usuario);
                request.setAttribute("rolesCuenta", rolesDeUsuario(conexion, idObjetivo));
                if (valores.isEmpty()) {
                    valores.put("nombres", (String) usuario.get("nombres"));
                    valores.put("apellidos", (String) usuario.get("apellidos"));
                    valores.put("correo", (String) usuario.get("correo"));
                }
            }
        }
        request.setAttribute("modo", accion);
        request.setAttribute("errores", errores);
        request.setAttribute("valores", valores);
        request.getRequestDispatcher("/WEB-INF/vista/formulario_usuario.jsp").forward(request, response);
        return;
    }

    String busqueda = limpiar(request.getParameter("q"));
    Integer paginaPedida = aEntero(request.getParameter("pagina"));
    int pagina = paginaPedida == null || paginaPedida < 1 ? 1 : paginaPedida;
    try (Connection conexion = abrirConexion()) {
        int total = contarUsuarios(conexion, busqueda);
        int paginas = Math.max(1, (total + USUARIOS_POR_PAGINA - 1) / USUARIOS_POR_PAGINA);
        pagina = Math.min(pagina, paginas);
        request.setAttribute("usuarios", listarUsuarios(conexion, busqueda, USUARIOS_POR_PAGINA, (pagina - 1) * USUARIOS_POR_PAGINA));
        request.setAttribute("total", total);
        request.setAttribute("pagina", pagina);
        request.setAttribute("paginas", paginas);
    }
    request.setAttribute("busqueda", busqueda);
    request.getRequestDispatcher("/WEB-INF/vista/usuarios.jsp").forward(request, response);
%>
