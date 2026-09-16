<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.sql.SQLException,java.util.Arrays,java.util.HashMap,java.util.HashSet,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/usuario.jspf" %>
<%@ include file="/WEB-INF/modelo/usuario_rol.jspf" %>
<%@ include file="/WEB-INF/modelo/inmobiliaria.jspf" %>
<%@ include file="/WEB-INF/modelo/auditoria.jspf" %>
<%--
  Empresas inmobiliarias.
  ADMINISTRADOR: GET ?accion=listar[&q&pagina] | vincular[&id_usuario=N] | editar&id_inmobiliaria=N
                 POST ?accion=crear (id_usuario y datos) | actualizar&id_inmobiliaria=N
  INMOBILIARIA:  GET ?accion=empresa | POST ?accion=guardar_empresa (su empresa; la identificación no cambia)
  Datos: nombre, identificacion, telefono, correo_contacto, direccion.
--%>
<%!
    private static final int INMOBILIARIAS_POR_PAGINA = 10;

    // Lee y valida los datos de la empresa; los deja normalizados en "valores".
    private void validarEmpresa(HttpServletRequest peticion, Map<String, String> valores, Map<String, String> errores,
            boolean conIdentificacion) {
        String nombre = limpiar(peticion.getParameter("nombre"));
        String identificacion = limpiar(peticion.getParameter("identificacion"));
        String telefono = limpiar(peticion.getParameter("telefono"));
        String correo = limpiar(peticion.getParameter("correo_contacto"));
        String direccion = limpiar(peticion.getParameter("direccion"));
        if (identificacion != null) {
            identificacion = identificacion.toUpperCase(Locale.ROOT);
        }
        if (correo != null) {
            correo = correo.toLowerCase(Locale.ROOT);
        }
        valores.put("nombre", nombre);
        valores.put("identificacion", identificacion);
        valores.put("telefono", telefono);
        valores.put("correo_contacto", correo);
        valores.put("direccion", direccion);

        if (!longitudValida(nombre, 1, 150)) {
            errores.put("nombre", "Escribe el nombre de la empresa (máximo 150 caracteres).");
        }
        if (conIdentificacion && (identificacion == null || !identificacion.matches("[0-9A-Z.\\-]{5,50}"))) {
            errores.put("identificacion", "La identificación debe tener entre 5 y 50 letras, números, puntos o guiones.");
        }
        if (!esTelefono(telefono)) {
            errores.put("telefono", "Escribe un teléfono válido (7 a 25 dígitos, espacios, + o guiones).");
        }
        if (!esCorreo(correo)) {
            errores.put("correo_contacto", "Escribe un correo de contacto válido.");
        }
        if (!longitudValida(direccion, 1, 200)) {
            errores.put("direccion", "Escribe la dirección (máximo 200 caracteres).");
        }
    }

    // En un 23505, el nombre de la restricción indica qué dato se repitió.
    private boolean identificacionRepetida(SQLException e) {
        return String.valueOf(e.getMessage()).contains("identificacion_empresarial");
    }
%>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR", "INMOBILIARIA")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    boolean esPost = "POST".equals(request.getMethod());
    boolean esAdmin = rolesUsuario.contains("ADMINISTRADOR");
    if (accion == null) {
        accion = esAdmin ? "listar" : "empresa";
    }
    boolean accionPropia = "empresa".equals(accion) || "guardar_empresa".equals(accion);
    if (!accionPropia && !esAdmin) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    Integer idInmobiliaria = aEntero(request.getParameter("id_inmobiliaria"));
    String destinoListado = ctx + "/controlador/inmobiliaria.jsp?accion=listar";
    Map<String, String> errores = new HashMap<String, String>();
    Map<String, String> valores = new HashMap<String, String>();

    // Vincular: asigna el rol y crea la empresa en una sola transacción.
    if ("crear".equals(accion) && esPost) {
        Integer idCuenta = aEntero(request.getParameter("id_usuario"));
        validarEmpresa(request, valores, errores, true);
        valores.put("id_usuario", idCuenta == null ? null : String.valueOf(idCuenta));
        if (!tokenValido(request)) {
            errores.put("general", "El formulario expiró. Vuelve a intentarlo.");
        }
        if (idCuenta == null) {
            errores.put("id_usuario", "Elige la cuenta responsable.");
        }
        if (errores.isEmpty()) {
            Connection conexion = null;
            try {
                conexion = abrirConexion();
                conexion.setAutoCommit(false);
                Map<String, Object> cuenta = buscarUsuario(conexion, idCuenta);
                if (cuenta == null || !(Boolean) cuenta.get("activo")) {
                    throw new SQLException("La cuenta responsable no existe o está desactivada.", "P0002");
                }
                asignarRol(conexion, idCuenta, "INMOBILIARIA");
                int idNueva = crearInmobiliaria(conexion, idCuenta, valores.get("nombre"), valores.get("identificacion"),
                        valores.get("telefono"), valores.get("correo_contacto"), valores.get("direccion"));
                registrarEvento(conexion, idUsuarioSesion, "EMPRESA_VINCULADA · empresa " + idNueva + " · "
                        + valores.get("identificacion") + " · cuenta " + idCuenta);
                conexion.commit();
                session.setAttribute("mensaje", "Empresa vinculada. La cuenta ahora tiene el rol INMOBILIARIA.");
                response.sendRedirect(ctx + "/controlador/inmobiliaria.jsp?accion=editar&id_inmobiliaria=" + idNueva);
                return;
            } catch (SQLException e) {
                if (conexion != null) {
                    try { conexion.rollback(); } catch (SQLException ignorada) { }
                }
                if ("P0002".equals(e.getSQLState())) {
                    errores.put("id_usuario", e.getMessage());
                } else if ("23505".equals(e.getSQLState()) && identificacionRepetida(e)) {
                    errores.put("identificacion", "Ya existe una empresa con esa identificación.");
                } else if ("23505".equals(e.getSQLState())) {
                    errores.put("id_usuario", "La cuenta ya administra una empresa.");
                } else {
                    errores.put("general", mensajeError(e));
                }
            } finally {
                if (conexion != null) {
                    try { conexion.close(); } catch (SQLException ignorada) { }
                }
            }
        }
        accion = "vincular";
    }

    if ("actualizar".equals(accion) && esPost) {
        validarEmpresa(request, valores, errores, true);
        if (!tokenValido(request)) {
            errores.put("general", "El formulario expiró. Vuelve a intentarlo.");
        }
        if (idInmobiliaria == null) {
            response.sendRedirect(destinoListado);
            return;
        }
        if (errores.isEmpty()) {
            try (Connection conexion = abrirConexion()) {
                if (actualizarInmobiliaria(conexion, idInmobiliaria, valores.get("nombre"), valores.get("identificacion"),
                        valores.get("telefono"), valores.get("correo_contacto"), valores.get("direccion"))) {
                    registrarEvento(conexion, idUsuarioSesion, "EMPRESA_ACTUALIZADA · empresa " + idInmobiliaria
                            + " · " + valores.get("identificacion"));
                    session.setAttribute("mensaje", "Empresa actualizada.");
                    response.sendRedirect(ctx + "/controlador/inmobiliaria.jsp?accion=editar&id_inmobiliaria=" + idInmobiliaria);
                } else {
                    session.setAttribute("mensajeError", "La empresa no existe.");
                    response.sendRedirect(destinoListado);
                }
                return;
            } catch (SQLException e) {
                if ("23505".equals(e.getSQLState())) {
                    errores.put("identificacion", "Ya existe una empresa con esa identificación.");
                } else {
                    errores.put("general", mensajeError(e));
                }
            }
        }
        accion = "editar";
    }

    // La empresa se toma de la sesión, nunca de un parámetro.
    if ("guardar_empresa".equals(accion) && esPost) {
        validarEmpresa(request, valores, errores, false);
        if (!tokenValido(request)) {
            errores.put("general", "El formulario expiró. Vuelve a intentarlo.");
        }
        if (errores.isEmpty()) {
            try (Connection conexion = abrirConexion()) {
                Map<String, Object> propia = buscarInmobiliariaPorUsuario(conexion, idUsuarioSesion);
                if (propia == null) {
                    session.setAttribute("mensajeError", "Tu cuenta no tiene una empresa vinculada.");
                } else {
                    actualizarInmobiliaria(conexion, (Integer) propia.get("idInmobiliaria"), valores.get("nombre"),
                            (String) propia.get("identificacion"), valores.get("telefono"),
                            valores.get("correo_contacto"), valores.get("direccion"));
                    registrarEvento(conexion, idUsuarioSesion, "EMPRESA_ACTUALIZADA · empresa " + propia.get("idInmobiliaria")
                            + " · " + propia.get("identificacion"));
                    session.setAttribute("mensaje", "Datos de la empresa actualizados.");
                }
                response.sendRedirect(ctx + "/controlador/inmobiliaria.jsp?accion=empresa");
                return;
            } catch (SQLException e) {
                errores.put("general", mensajeError(e));
            }
        }
        accion = "empresa";
    }

    if ("vincular".equals(accion)) {
        Integer idCuenta = aEntero(request.getParameter("id_usuario"));
        try (Connection conexion = abrirConexion()) {
            // Desde la edición de usuario: si ya tiene empresa se edita; si está inactiva no se vincula.
            if (idCuenta != null && valores.isEmpty()) {
                Map<String, Object> existente = buscarInmobiliariaPorUsuario(conexion, idCuenta);
                Map<String, Object> cuenta = buscarUsuario(conexion, idCuenta);
                if (existente != null) {
                    session.setAttribute("mensaje", "La cuenta ya administra la empresa " + existente.get("nombre") + ".");
                    response.sendRedirect(ctx + "/controlador/inmobiliaria.jsp?accion=editar&id_inmobiliaria=" + existente.get("idInmobiliaria"));
                    return;
                }
                if (cuenta == null) {
                    session.setAttribute("mensajeError", "La cuenta no existe.");
                    response.sendRedirect(ctx + "/controlador/usuario.jsp?accion=listar");
                    return;
                }
                if (!(Boolean) cuenta.get("activo")) {
                    session.setAttribute("mensajeError", "Activa la cuenta antes de vincularle una empresa.");
                    response.sendRedirect(ctx + "/controlador/usuario.jsp?accion=editar&id_usuario=" + idCuenta);
                    return;
                }
                valores.put("id_usuario", String.valueOf(idCuenta));
            }
            request.setAttribute("cuentas", listarCuentasSinEmpresa(conexion));
        }
        request.setAttribute("modo", "vincular");
        request.setAttribute("errores", errores);
        request.setAttribute("valores", valores);
        request.getRequestDispatcher("/WEB-INF/vista/formulario_inmobiliaria.jsp").forward(request, response);
        return;
    }

    if ("editar".equals(accion) || "empresa".equals(accion)) {
        boolean propia = "empresa".equals(accion);
        if (!propia && idInmobiliaria == null) {
            response.sendRedirect(destinoListado);
            return;
        }
        try (Connection conexion = abrirConexion()) {
            Map<String, Object> empresa = propia
                    ? buscarInmobiliariaPorUsuario(conexion, idUsuarioSesion) : buscarInmobiliaria(conexion, idInmobiliaria);
            if (empresa == null && !propia) {
                session.setAttribute("mensajeError", "La empresa no existe.");
                response.sendRedirect(destinoListado);
                return;
            }
            if (empresa != null && valores.isEmpty()) {
                valores.put("nombre", (String) empresa.get("nombre"));
                valores.put("identificacion", (String) empresa.get("identificacion"));
                valores.put("telefono", (String) empresa.get("telefono"));
                valores.put("correo_contacto", (String) empresa.get("correoContacto"));
                valores.put("direccion", (String) empresa.get("direccion"));
            }
            request.setAttribute("empresa", empresa);
        }
        request.setAttribute("modo", accion);
        request.setAttribute("errores", errores);
        request.setAttribute("valores", valores);
        request.getRequestDispatcher("/WEB-INF/vista/formulario_inmobiliaria.jsp").forward(request, response);
        return;
    }

    String busqueda = limpiar(request.getParameter("q"));
    Integer paginaPedida = aEntero(request.getParameter("pagina"));
    int pagina = paginaPedida == null || paginaPedida < 1 ? 1 : paginaPedida;
    try (Connection conexion = abrirConexion()) {
        int total = contarInmobiliarias(conexion, busqueda);
        int paginas = Math.max(1, (total + INMOBILIARIAS_POR_PAGINA - 1) / INMOBILIARIAS_POR_PAGINA);
        pagina = Math.min(pagina, paginas);
        request.setAttribute("empresas", listarInmobiliarias(conexion, busqueda, INMOBILIARIAS_POR_PAGINA, (pagina - 1) * INMOBILIARIAS_POR_PAGINA));
        request.setAttribute("total", total);
        request.setAttribute("pagina", pagina);
        request.setAttribute("paginas", paginas);
    }
    request.setAttribute("busqueda", busqueda);
    request.getRequestDispatcher("/WEB-INF/vista/inmobiliarias.jsp").forward(request, response);
%>
