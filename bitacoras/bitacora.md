# Bitácora — DataLab
**Nombre:** Elian Santiago Pacheco Vanegas 

---

## SEMANA 1 — Modelado conceptual y E-R

### Actividad 1 — Lectura y extracción cruda

**a) ¿De qué "cosas" del negocio de DataLab se necesita guardar información?**
Necesitamos guardar información de: los científicos de datos del equipo, los proyectos en los que trabajan, los datasets que usan, los experimentos que ejecutan, los modelos que resultan de esos experimentos, y las métricas con las que se evalúa cada modelo.

**b) ¿Qué preguntas le harían al equipo de ciencia de datos antes de empezar a modelar?**
Con que tipo de metricas evaluan sus proyectos, Cuales experimentos suelen usar, informacion personal importante... Cualquier tipo de informacion que nos permita modelar de forma clara y sencilla y identificar las areas claves y solidas en nuestro modelo

**c) Reto Feynman — explicar "Experimento" sin usar la palabra "entidad"**
Un experimento es cada vez que alguien del equipo prueba algo: toma un conjunto de datos, define con qué configuración lo va a correr (por ejemplo, qué parámetros usar), lo ejecuta un día específico, y esa corrida queda registrada como un hecho puntual — con su propia fecha, su propia configuración y su propio resultado.

### Actividad 2 — Primer boceto

**Herramienta usada:** Draw.io

### Actividad 3 — Puesta en común

**a) ¿En qué se parece su boceto al de otros equipos?**
en las entidades y en las relaciones

**b) ¿En qué se diferencia? ¿Alguna diferencia les genera dudas?**
los atributos

**c) Preguntas abiertas que les quedan:**
que tanto puede cambiar un modelo por los atributos dados a cada entidad y por la forma d enombrar las relaciones

---

## BLOQUE 2 — Formalización (Semana 1)

### Niveles de modelado

| Frase | Nivel |
|---|---|
| "Un experimento puede producir, como máximo, un modelo" | Conceptual |
| "La tabla EXPERIMENTO tiene una llave foránea id_dataset" | Lógico |
| "La columna fecha_ejecucion es de tipo DATE" | Físico |

### Corrección del boceto con notación de Chen

**a) ¿`algoritmo` quedó como atributo o entidad?**
Debe quedar como atributo de MODELO. No tiene existencia propia independiente de un modelo: no se identifica ni se consulta por sí solo, solo describe una característica del modelo (ej. "Random Forest").

**b) ¿DATASET es entidad fuerte o débil?**
Es una entidad fuerte. Tiene su propia llave primaria (`id_dataset`) y existe de forma independiente — un dataset puede existir y reutilizarse aunque no esté vinculado en ese momento a ningún experimento.

**c) ¿EXPERIMENTO quedó como entidad o relación?**
Debe quedar como entidad. Tiene atributos propios (`fecha_ejecucion`, `configuracion`) que solo tienen sentido si existe como entidad con su propia llave — no es solo el punto de encuentro entre dataset y científico, es un objeto con identidad propia (`id_experimento`).

### Cardinalidad y participación

| Relación | Cardinalidad | Participación |
|---|---|---|
| CIENTIFICO_DATOS – participa en – PROYECTO | N:M | Total en ambos lados — un científico existe para participar en proyectos y un proyecto agrupa científicos |
| DATASET – se usa en – EXPERIMENTO | 1:N | Parcial en DATASET (puede existir sin usarse aún), total en EXPERIMENTO (todo experimento necesita un dataset) |
| EXPERIMENTO – produce – MODELO | 1:1 | Parcial en EXPERIMENTO (no todos producen modelo), total en MODELO (todo modelo viene de un experimento) |
| MODELO – se evalúa con – METRICA | 1:N | Parcial en MODELO (puede no tener métricas aún), total en METRICA (toda métrica pertenece a un modelo) |

**Ejercicios rápidos:**

**a) Pipeline de anotación — ANOTADOR e IMAGEN:**
Es 1:N entre ANOTADOR e IMAGEN (un anotador etiqueta muchas imágenes), con participación total en IMAGEN si toda imagen requiere al menos un anotador.

**b) MLOps — MODELO–DESPLIEGUE:**
Es 1:N. Un modelo puede desplegarse en varios ambientes (staging, producción), pero cada despliegue específico (con su fecha y versión de infraestructura) pertenece a un único modelo.

### Llaves primarias y candidatas

**a) Llave candidata más evidente de EXPERIMENTO:** `id_experimento_interno`

**b) ¿Por qué `nombre_experimento` no sirve como llave sola?**
Porque no garantiza unicidad: distintos experimentos, incluso del mismo científico al iterar configuraciones, podrían compartir el mismo nombre.

**c) Llaves de las demás entidades:**

| Entidad | Llave(s) candidata(s) | Llave primaria | Justificación |
|---|---|---|---|
| CIENTIFICO_DATOS | id_cientifico | id_cientifico | No hay identificador natural único mencionado en el enunciado |
| PROYECTO | id_proyecto | id_proyecto | El nombre del problema podría repetirse o reformularse |
| DATASET | id_dataset | id_dataset | El nombre del dataset podría repetirse entre fuentes distintas |
| MODELO | id_modelo | id_modelo | (nombre+version) sería candidata pero complica referencias desde METRICA |
| METRICA | id_metrica | id_metrica | (id_modelo+nombre_metrica) no es única si se recalcula en fechas distintas |

---

## SEMANA 2 — Modelo relacional y conversión

### Retomar el Hito 1

**a) ¿Cómo resolvieron la participación parcial entre EXPERIMENTO y MODELO?**
Dejando `id_experimento` como FK y UNIQUE en la tabla `modelo`, de modo que no todo experimento tiene una fila correspondiente en modelo (participación parcial), pero todo modelo sí referencia exactamente un experimento.

### El modelo relacional — equivalencias

| Término técnico | Equivalente |
|---|---|
| Relación | Tabla |
| Tupla | Fila / registro |
| Atributo | Columna |
| Dominio | Conjunto de valores válidos para una columna |
| Grado | Número de columnas de la tabla |
| Cardinalidad (de la tabla) | Número de filas de la tabla |

**b) "Relación" en el modelo E-R significa:** una asociación entre dos o más entidades.

**c) "Relación" en el modelo relacional significa:** una tabla.

**d) ¿Es lo mismo la cardinalidad de una tabla que la cardinalidad E-R?**
No. La cardinalidad de una tabla es el número de filas que tiene en un momento dado (cambia constantemente). La cardinalidad E-R (1:1, 1:N, N:M) es una restricción de diseño sobre cuántas instancias de una entidad pueden asociarse con cuántas de otra — es fija, no depende de los datos.

### Reglas de conversión E-R → relacional

- **Regla 1 — Entidad → tabla:** cada entidad se convierte en una tabla, y cada atributo en una columna.
- **Regla 2 — Relación 1:N:** la llave primaria del lado "1" se agrega como llave foránea en la tabla del lado "N".
- **Regla 3 — Relación N:M:** se crea una tabla puente con las llaves primarias de ambas entidades como llaves foráneas (y como llave primaria compuesta de la tabla puente).
- **Regla 4 — Atributo multivaluado:** se convierte en una tabla aparte, con FK hacia la entidad dueña del atributo.
- **Regla 5 — Entidad débil:** se convierte en tabla, pero su llave primaria incluye la llave foránea de la entidad fuerte de la que depende.

**e) ¿Por qué DataLab no tiene entidades débiles en su núcleo?**
Porque las 6 entidades tienen un identificador propio que no depende de otra entidad para existir — ninguna necesita la llave de otra entidad como parte de su propia llave primaria.

### Ejercicio guiado en papel

**a) Tabla puente CIENTIFICO_DATOS–PROYECTO:** `participacion (id_cientifico FK, id_proyecto FK)`, llave primaria compuesta por ambas.

**b) Relación 1:N PROYECTO–EXPERIMENTO:** la llave foránea `id_proyecto` queda en la tabla `experimento`, porque es el lado "N" de la relación.

### Tarea de transición — conversión de tablas restantes

- `dataset (id_dataset PK, nombre, fuente, fecha_carga, tamanio_filas)`
- `experimento (id_experimento PK, id_proyecto FK, id_dataset FK, id_cientifico FK, fecha_ejecucion, configuracion)`
- `modelo (id_modelo PK, id_experimento FK UNIQUE, nombre, version, algoritmo)`
- `metrica (id_metrica PK, id_modelo FK, nombre_metrica, valor, fecha_calculo)`

---

## BLOQUE 2 — Laboratorio (Semana 2)

### Revisión cruzada

**Pregunta que le dejamos al otro equipo:**...

### Digitalización

**Herramienta usada:** MY SQL WORKBENCH

### Nombrar tablas puente

| Tabla puente | ¿Qué representa cada fila? | ¿Por qué se llama así? |
|---|---|---|
| participacion | La participación de un científico específico en un proyecto específico | Describe directamente la acción que representa: participar |

**Pregunta de cierre — si borran una fila de `participacion`:**
El científico y el proyecto siguen existiendo sin problema (siguen en sus propias tablas); solo se elimina el vínculo entre ese científico y ese proyecto en particular.

### Verificación de comprensión

**1. Diferencia entre "relación" E-R y relacional:** en E-R es una asociación entre entidades; en el modelo relacional es sinónimo de tabla.

**2. ¿Por qué la FK va del lado "N"?** Porque cada fila del lado "N" solo puede asociarse con una fila del lado "1", así que necesita guardar la referencia a esa única fila mediante la FK; el lado "1" tendría que guardar múltiples referencias si fuera al revés, lo cual rompe la forma tabular.

**3. ¿Qué pasaría si CIENTIFICO_DATOS–PROYECTO fuera 1:N en vez de N:M?**
Un científico solo podría pertenecer a un proyecto a la vez, y ya no se necesitaría tabla puente — bastaría con una FK `id_proyecto` directamente en `cientifico_datos`. Esto no representa correctamente el negocio, porque el enunciado dice que un científico puede participar en varios proyectos.

---

## SEMANA 3 — Tipos de dato, restricciones y llaves

### Dominios y tipos de dato

| Tipo | Uso típico | Ejemplo en DataLab |
|---|---|---|
| `INT` | Identificadores y conteos | `id_experimento`, `tamanio_filas` |
| `VARCHAR(n)` | Texto corto de longitud limitada | `nombre` de dataset, `algoritmo` |
| `TEXT` | Texto largo sin límite fijo | `configuracion` del experimento |
| `DATE` | Fechas sin hora | `fecha_carga`, `fecha_calculo` |
| `DECIMAL(p,e)` | Valores numéricos exactos con decimales | `valor` de la métrica |
| `BOOLEAN` | Verdadero/falso | (no usado directamente en el núcleo de DataLab) |

**a) ¿Diferencia entre tipo de dato y restricción?**
El tipo de dato define qué clase de valores puede almacenar la columna (número, texto, fecha); la restricción impone una regla adicional sobre esos valores (que no falte, que sea único, que esté en un rango).

### Restricciones

| Restricción | Qué garantiza | Ejemplo en DataLab |
|---|---|---|
| `NOT NULL` | Que la columna no quede vacía | `fecha_ejecucion` en experimento |
| `UNIQUE` | Que el valor no se repita en la tabla | `id_experimento` en modelo (fuerza el 1:1) |
| `DEFAULT` | Un valor por defecto si no se especifica | `fecha_carga` = fecha del día en dataset |
| `CHECK` | Que el valor cumpla una condición lógica | `tamanio_filas > 0` en dataset |

**b) ¿Todas las métricas caben en `CHECK (valor BETWEEN 0 AND 1)`?**
No. Métricas como accuracy, precisión o F1-score sí caben en ese rango, pero otras métricas de desempeño (por ejemplo, un error como MAE o RMSE) pueden tomar valores fuera de 0-1, así que ese CHECK no aplicaría de forma genérica a toda la tabla `metrica`.

### Llaves primarias y foráneas formalizadas

**c) ¿Qué significa llave primaria compuesta? Ejemplo en DataLab:**
Es una llave primaria formada por dos o más columnas en conjunto, no por una sola. En DataLab, la tabla puente `participacion` usa como llave primaria la combinación de `id_cientifico` + `id_proyecto`.

**d) ¿Qué error se podría colar si `modelo.id_experimento` es FK pero no UNIQUE?**
Varias filas de `modelo` podrían terminar apuntando al mismo experimento, violando la cardinalidad 1:1 que define el negocio — un experimento produciría "varios" modelos cuando el diseño dice que produce, como máximo, uno.

### Ejercicio en papel — ficha de tablas
(Ver tabla completa en `documentacion/diccionario_datos.md` — 8 columnas: tabla, columna, tipo de dato, restricciones.)

---

## BLOQUE 2 — Laboratorio (Semana 3)

### Retomar

**¿En qué tabla o columna tuvo dudas su equipo?**
En la tabla participacion 

### Ejercicio aplicado

**Si insertan en `experimento` un `id_proyecto = 999` que no existe, ¿qué debería pasar?**
La inserción debería rechazarse. Esto es responsabilidad de la restricción de llave foránea (FK): no debe permitirse una fila en `experimento` que referencie un proyecto inexistente, para mantener la integridad referencial entre las tablas.

### Verificación de comprensión

**1. Diferencia entre tipo de dato y restricción:**
El tipo de dato define la naturaleza del valor (numérico, texto, fecha); la restricción define una regla adicional que ese valor debe cumplir.

**2. ¿Por qué `modelo.id_experimento` necesita `UNIQUE` además de `FK`?**
Porque el `FK` solo garantiza que el experimento referenciado exista; el `UNIQUE` es lo que impide que ese mismo experimento sea referenciado por más de un modelo, forzando la cardinalidad 1:1.

**3. ¿Qué restricción evitaría que `dataset.tamanio_filas` fuera negativo?**
`CHECK (tamanio_filas > 0)`.









## Semana 5 — Resultados de las pruebas de integridad

- **Motor(es) probado(s):** MySQL 8.x / SQL Server 2019+
- **Pruebas ejecutadas:** 6 de 6
- **Predicciones de Semana 3/4 que se cumplieron:** [listar]
- **Predicciones que NO se cumplieron y por qué:** [listar]
- **Diferencias observadas entre MySQL y SQL Server:** [listar]
- **Ajustes realizados al DDL:** [listar]
```
