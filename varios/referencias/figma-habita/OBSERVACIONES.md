# Observaciones de la exportación

## Comparación de versiones

El segundo ZIP mantiene sin cambios todo el código de la primera exportación. Solo añade:

- `public/habita-logo.svg`
- `public/habita-icon.svg`
- `public/habita-palette.svg`

Estos tres archivos se conservaron sin modificaciones en `recursos/`.

## Imágenes

Las fotografías no están empacadas en el ZIP. El código las solicita desde `images.unsplash.com`. Se descargaron trece imágenes únicas en `imagenes/` para conservar una referencia local y evitar depender de que los enlaces sigan disponibles.

## Favicon

La explicación entregada por Figma indica que `index.html` contiene:

```html
<link rel="icon" type="image/svg+xml" href="/habita-icon.svg" />
```

La línea no aparece en el `index.html` exportado. Esto no afecta la aplicación JSP actual porque el ZIP se conserva únicamente como referencia. Cuando se replantee la interfaz, el ícono podrá incorporarse en la cabecera JSPF mediante la ruta pública que se defina.

## Uso futuro

La estructura visual, textos, logo, paleta y distribución de pantallas pueden adaptarse al proyecto. El código React, las cifras comerciales ficticias y las funciones no contempladas por el parcial no deben trasladarse automáticamente.
