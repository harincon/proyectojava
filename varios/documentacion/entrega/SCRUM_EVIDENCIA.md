# Evidencia Scrum

## Alcance de esta evidencia

El parcial exige tres sprints de siete días, con planning, review y retrospectiva. Los archivos de planificación sí describen esa distribución. El historial disponible registra trabajo entre el 14 y el 16 de septiembre de 2026. No existen actas, grabaciones, capturas de tablero ni notas fechadas que demuestren que las nueve ceremonias ocurrieron. Este documento no las inventa.

## Distribución prevista

| Sprint | Duración exigida | Objetivo previsto | Bloques |
|---|---|---|---|
| Sprint 1 | 7 días | Modelo de datos, conexión, diseño base, registro, ingreso y roles | B0, B1, B2 y base de B8 |
| Sprint 2 | 7 días | Empresas, catálogos, perfil, landing, catálogo y propiedades | B3 y B4 |
| Sprint 3 | 7 días | Favoritos, citas, solicitudes, documentos, reportes, auditoría y cierre | B5, B6, B7, cierre B8 y B9 |

Esta tabla conserva la planificación del proyecto. No demuestra que cada periodo duró siete días en la ejecución real.

## Backlog consolidado

Las estimaciones se documentan ahora como referencia de tamaño. No se presentan como puntos acordados en una reunión pasada.

| ID | Historia | Prioridad | Responsable técnico | Estimación propuesta |
|---|---|---|---|---:|
| HU-01 | Landing y búsqueda rápida | Alta | B4 | 5 |
| HU-02 | Registro con correo único | Alta | B2 | 5 |
| HU-03 | Inicio, cierre y panel por roles | Alta | B2 | 8 |
| HU-04 | Asignación y retiro de roles | Alta | B2/B3 | 5 |
| HU-05 | Perfil y foto | Media | B2 | 5 |
| HU-06 | Propiedades con imágenes y características | Alta | B4 | 8 |
| HU-07 | Filtros de catálogo | Alta | B4 | 5 |
| HU-08 | Favoritos sin duplicados | Media | B5 | 3 |
| HU-09 | Citas sin cruces | Media | B5 | 8 |
| HU-10 | Solicitudes y documentos privados | Media | B6 | 8 |
| HU-11 | Revisión y cierre transaccional | Media | B6 | 8 |
| HU-12 | Reportes SQL | Media | B7 | 5 |
| HU-13 | Auditoría de accesos y cambios | Baja | B7/coordinación | 5 |
| HU-14 | Datos, diccionario y validaciones SQL | Alta | B8 | 8 |
| HU-15 | Integración, pruebas y entrega | Alta | B9/coordinación | 8 |

## Evidencia real disponible

- `varios/planificacion/PLAN_IMPLEMENTACION.md` contiene alcance, dependencias, historias y distribución propuesta.
- `varios/planificacion/PLAN_DELEGACION.md` registra bloques B0 a B9, responsables por archivo y estado de integración.
- `README_IMPLEMENTACION.md` resume lo implementado y las pruebas de cada bloque.
- `.git/logs/HEAD` contiene 28 commits o merges: 2 el 14 de septiembre, 17 el 15 y 9 el 16 de 2026.
- El historial muestra una rama específica para B8 y su merge a `main`.
- `HISTORIAL_GIT.md` presenta los registros que pueden sustentarse con el repositorio local.

## Planning, review y retrospectiva

| Ceremonia | Sprint 1 | Sprint 2 | Sprint 3 |
|---|---|---|---|
| Planning | Alcance propuesto en planificación; no hay acta de reunión | Alcance propuesto; no hay acta | Alcance propuesto; no hay acta |
| Review | No se encontró evidencia fechada | No se encontró evidencia fechada | Las pruebas B9 demuestran el producto final, pero no una review ocurrida |
| Retrospectiva | No se encontró evidencia fechada | No se encontró evidencia fechada | No se encontró evidencia fechada |

Si el equipo realizó alguna ceremonia, debe anexar únicamente evidencia existente: fecha, participantes, objetivo, historias revisadas, decisiones y enlace o captura. Una minuta creada después puede explicar lo ocurrido, pero debe identificarse como reconstrucción y no como acta contemporánea.

## Brecha frente al parcial

La concentración de actividad en tres días no demuestra tres sprints reales de siete días. Para la sustentación conviene mostrar con honestidad la planificación, el historial y el producto; también reconocer que falta evidencia contemporánea del tablero, planning, review y retrospectiva. B9 no puede reparar esa brecha sin inventar hechos.
