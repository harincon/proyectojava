# Fotografías del catálogo

Las fotos de `img/habita/` son imágenes gratuitas de [Unsplash](https://unsplash.com/license), usadas como datos de prueba del proyecto académico. La licencia de Unsplash no exige atribución, pero se conserva por buena práctica.

- **01 a 13:** vienen del prototipo de Figma (ver `figma-habita/IMAGENES.md`).
- **14 a 29:** las agregó el estudiante el 16 de septiembre de 2026.

Para que el catálogo cargue rápido, se recortaron al centro en proporción 3:2 y se redujeron a 1200 × 800 px: pasaron de 37 MB a unos 2,7 MB. Los originales quedan en `varios/referencias/fotos-originales/`, excluidos de Git.

| Archivo | Muestra | Autor | Foto original |
| --- | --- | --- | --- |
| 14-casa-moderna-blanca.jpg | Fachada de casa moderna blanca | Bilal Mansuri | https://unsplash.com/photos/R8F3tLZUWRs |
| 15-casa-campestre-bosque.jpg | Casa de campo en el bosque al atardecer | Clay Banks | https://unsplash.com/photos/obnpdOXBaU8 |
| 16-loft-doble-altura.jpg | Sala de loft con doble altura | Davide Colonna | https://unsplash.com/photos/DZrZhVd_wR0 |
| 17-casa-colonial-jardin.jpg | Casa colonial blanca con jardín | Elijah Crouch | https://unsplash.com/photos/kcNB4_0HRLA |
| 18-lote-urbano-aereo.jpg | Vista aérea de un lote urbano | Fotografías Inmobiliarias | https://unsplash.com/photos/Qal7KiJ-ErQ |
| 19-edificio-balcones.jpg | Edificio residencial con balcones | George Barros | https://unsplash.com/photos/t4FMbSdmeR0 |
| 20-casa-porche.jpg | Casa con porche y jardín | Jamie Hagan | https://unsplash.com/photos/sRG-fo7BYt8 |
| 21-sala-apartaestudio.jpg | Sala y cocina de apartaestudio | Michael Oxendine | https://unsplash.com/photos/GHCVUtBECuY |
| 22-fachada-moderna.jpg | Fachada contemporánea iluminada | Naksha Banwao | https://unsplash.com/photos/3ddHcjHmiGw |
| 23-sala-apartamento.jpg | Sala de apartamento | Prydumano Design | https://unsplash.com/photos/vYlmRFIsCIk |
| 24-cocina-vista-ciudad.jpg | Cocina con vista a la ciudad | Rafael Hoyos Weht | https://unsplash.com/photos/8PKGjZ2GzuQ |
| 25-habitacion-principal.jpg | Habitación principal | Salman Saqib | https://unsplash.com/photos/OD3gwob6acU |
| 26-casa-piscina-moderna.jpg | Casa moderna con piscina | Salman Saqib | https://unsplash.com/photos/WaC-JFfF21M |
| 27-cocina-comedor.jpg | Cocina con comedor | Taufiq Triadi | https://unsplash.com/photos/E7yGIdzNE3k |
| 28-oficina-vista-ciudad.jpg | Sala de juntas con vista a la ciudad | Yibei Geng | https://unsplash.com/photos/-UdYbiywGeg |
| 29-local-vidriado.jpg | Local comercial vidriado | Zero Take | https://unsplash.com/photos/WvHrrR1C5Po |

Los autores y enlaces se tomaron del nombre con el que Unsplash entrega cada archivo descargado.

## Reparto en los datos de prueba

La primera foto de cada propiedad es la del catálogo. En las 14 propiedades publicadas y disponibles ninguna se repite; la validación `sql/pruebas/02-validar-datos.sql` lo comprueba. Nueve propiedades tienen una segunda foto, casi siempre un interior, para la galería del detalle. Solo se repite la foto del lote, porque hay dos terrenos y uno de ellos está retirado del catálogo.
