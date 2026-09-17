# Guía de ejecución

## 1. Requisitos

- PostgreSQL y pgAdmin.
- JDK compatible con Tomcat 8.5.
- Apache Tomcat 8.5 de XAMPP.
- Driver JDBC de PostgreSQL dentro de `WEB-INF/lib`.
- Proyecto copiado como `C:\xampp\tomcat\webapps\proyectojava`.

## 2. Crear la base

En pgAdmin, conectarse al servidor local, abrir Query Tool sobre la base `postgres` y ejecutar:

```sql
CREATE DATABASE proyectojava WITH ENCODING 'UTF8';
```

Abrir Query Tool sobre `proyectojava` y ejecutar, en este orden:

1. `sql/01-esquema.sql`
2. `sql/02-datos-base.sql`
3. `sql/03-datos-prueba.sql`

`sql/04-consultas.sql` contiene consultas de demostración y reportes. No es un script de carga.

Para comprobar la instalación:

1. Ejecutar `sql/pruebas/01-validar-esquema.sql`.
2. Ejecutar `sql/pruebas/02-validar-datos.sql`.

Con `psql` en PowerShell:

```powershell
$env:PGCLIENTENCODING = "UTF8"
$env:PGPASSWORD = "su_clave_local"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -U postgres -d proyectojava -f "sql\01-esquema.sql"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -U postgres -d proyectojava -f "sql\02-datos-base.sql"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -U postgres -d proyectojava -f "sql\03-datos-prueba.sql"
```

## 3. Configurar JDBC

Copiar:

```text
WEB-INF/jspf/conexion.jspf.ejemplo
```

como:

```text
WEB-INF/jspf/conexion.jspf
```

Completar la URL, usuario y contraseña local. La configuración esperada usa la base `proyectojava` y fija el esquema `inmobiliaria`. No confirmar `conexion.jspf` en un repositorio público porque contiene la contraseña.

Verificar que el JAR de PostgreSQL permanezca en `WEB-INF/lib`. No se usan clases Java propias ni archivos `.properties` para la conexión.

## 4. Desplegar en Tomcat

1. Copiar la carpeta completa a `C:\xampp\tomcat\webapps\proyectojava`.
2. Iniciar Tomcat desde XAMPP.
3. Esperar a que Tomcat compile las JSP.
4. Abrir `http://localhost:8080/proyectojava/`.
5. Si se cambia `web.xml`, reiniciar o recargar la aplicación.

## 5. Cuentas de desarrollo

| Rol | Correo | Contraseña de desarrollo |
|---|---|---|
| Administrador | `admin@habita.com` | `Admin123` |
| Inmobiliaria | `camila.rojas@habita.local` | `Clave123` |
| Cliente | `daniela.moreno@habita.local` | `Clave123` |

Cambiar la contraseña del administrador antes de cualquier publicación o demostración fuera del equipo controlado.

## 6. Recorrido de verificación

1. Abrir inicio, catálogo y detalle sin sesión.
2. Registrar un cliente, iniciar sesión y completar el perfil.
3. Agregar un favorito, agendar una cita futura y radicar una solicitud.
4. Subir un PDF válido desde el detalle de la solicitud.
5. Ingresar como inmobiliaria, confirmar la cita, aprobar documento y solicitud, y finalizar la operación.
6. Ingresar como administrador y revisar usuarios, reportes y auditoría.
7. Probar un ID ajeno y confirmar la respuesta 403.

## 7. Diagnóstico local

Las páginas `controlador/prueba_conexion.jsp`, `controlador/prueba_subida.jsp` y `controlador/prueba_diseno.jsp` solo responden desde loopback. Sirven durante el desarrollo. Antes de publicar, se deben retirar o limitar al administrador.

## 8. Limitaciones de la entrega

La conexión remota, el despliegue público y el Filter exigido literalmente por el parcial no forman parte de la configuración actual. La aplicación protege cada controlador privado mediante `WEB-INF/jspf/seguridad.jspf`. Consultar el documento de pendientes de entrega (compartido con el profesor por separado) antes de sustentar o publicar.
