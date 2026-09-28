# Registro de Actividades — DataLab

**Estudiante:** Ronald Andres Rodriguez Becerra

---

## SEMANA 1 — Modelado conceptual y Diagramas E-R

### Actividad 1 — Análisis y extracción inicial

**a) ¿De qué elementos del negocio de DataLab necesitamos almacenar información?**
El sistema debe guardar datos sobre: el personal (los científicos de datos), los distintos proyectos a los que están asignados, los conjuntos de datos (datasets) que manejan, los experimentos que realizan, los modelos generados a partir de esas pruebas, y las métricas con las que evalúan el rendimiento de dichos modelos.

**b) ¿Qué consultas le harían al equipo de ciencia de datos antes de diseñar el modelo?**
Les preguntaría cuáles son las métricas exactas que usan para validar sus proyectos, qué tipo de configuraciones de experimentos corren con más frecuencia y qué datos personales son indispensables para la empresa. En resumen, cualquier detalle que nos ayude a estructurar la base de datos de manera limpia, identificando las áreas más críticas del modelo.

**c) Reto Feynman — explicar qué es un "Experimento" sin utilizar el término "entidad"**
Piensa en un experimento como un ensayo o una prueba puntual. Alguien del equipo toma unos datos específicos, decide qué parámetros o ajustes va a utilizar y ejecuta el proceso un día determinado. Ese "intento" queda guardado en el historial con su fecha exacta, su configuración particular y el resultado que arrojó.

### Actividad 2 — Primer borrador

**Herramienta utilizada:** Draw.io

### Actividad 3 — Socialización de resultados

**a) ¿En qué se asemeja su borrador al de los demás grupos?**
Coincidimos bastante en cuáles son las entidades principales y en cómo se conectan entre sí (las relaciones).

**b) ¿En qué notaron diferencias? ¿Hay algo que les cause dudas?**
La mayor diferencia estuvo en los atributos que cada equipo eligió. Es la parte que más nos hace dudar.

**c) Preguntas que quedaron en el aire:**
Nos preguntamos qué tanto impacto puede tener en el diseño final la manera en que nombramos las relaciones o la decisión de incluir o descartar ciertos atributos en cada elemento.

---

## BLOQUE 2 — Formalización (Semana 1)

### Niveles de abstracción en bases de datos

| Afirmación | Nivel de modelo |
| --- | --- |
| "Un experimento genera, a lo sumo, un único modelo" | Conceptual |
| "La tabla EXPERIMENTO posee una clave foránea id_dataset" | Lógico |
| "El campo fecha_ejecucion se define como tipo DATE" | Físico |

### Ajustes al diagrama con notación de Chen

**a) ¿`algoritmo` se definió como atributo o como entidad?**
Se quedó como un atributo de la entidad MODELO. No tiene sentido que exista por sí solo porque no vamos a consultarlo de manera independiente; únicamente funciona como una característica (ej. "Árbol de Decisión") que describe a un modelo.

**b) ¿DATASET es una entidad fuerte o débil?**
Es una entidad fuerte. Tiene su propio identificador principal (`id_dataset`) y no depende de otra entidad para existir en la base de datos — podemos tener un dataset guardado que todavía no se ha utilizado en ningún experimento.

**c) ¿EXPERIMENTO se dejó como entidad o como relación?**
Se estableció como entidad. Cuenta con atributos exclusivos (`fecha_ejecucion`, `configuracion`) que solo tienen sentido si existe como un objeto independiente con su propia clave (`id_experimento`). No es simplemente la conexión entre los datos y el científico.

### Cardinalidad y reglas de participación

| Vínculo | Cardinalidad | Participación |
| --- | --- | --- |
| CIENTIFICO_DATOS – asignado a – PROYECTO | N:M | Total de ambos lados: los científicos están para trabajar en proyectos, y todo proyecto debe tener científicos. |
| DATASET – utilizado en – EXPERIMENTO | 1:N | Parcial para DATASET (puede estar sin uso), total para EXPERIMENTO (no hay prueba sin datos). |
| EXPERIMENTO – genera – MODELO | 1:1 | Parcial para EXPERIMENTO (algunos fallan y no dan modelo), total para MODELO (todo modelo proviene de una prueba). |
| MODELO – medido con – METRICA | 1:N | Parcial para MODELO (podría no tener métricas calculadas aún), total para METRICA (toda métrica está atada a un modelo). |

**Ejercicios rápidos:**

**a) Flujo de anotación — ANOTADOR e IMAGEN:**
Es una relación 1:N (un anotador etiqueta múltiples imágenes). La participación es total del lado de IMAGEN, asumiendo que todas deben ser procesadas por alguien.

**b) MLOps — MODELO–DESPLIEGUE:**
Es 1:N. Un mismo modelo puede subirse a diferentes entornos (pruebas, producción), pero cada despliegue puntual le pertenece a un solo modelo.

### Claves primarias y alternativas

**a) Clave candidata más obvia para EXPERIMENTO:** `id_experimento_interno`

**b) ¿Por qué no usar `nombre_experimento` como clave principal?**
Porque no asegura que sea único. Dos científicos distintos (o incluso el mismo) podrían nombrar "prueba_final" a experimentos diferentes, generando conflictos.

**c) Identificadores del resto de entidades:**

| Entidad | Posibles claves (Candidatas) | Clave Primaria Definitiva | Razón de la elección |
| --- | --- | --- | --- |
| CIENTIFICO_DATOS | id_cientifico | id_cientifico | El caso de uso no menciona otro identificador natural (como un DNI). |
| PROYECTO | id_proyecto | id_proyecto | El nombre del proyecto podría cambiar o repetirse en el futuro. |
| DATASET | id_dataset | id_dataset | Podría haber nombres duplicados dependiendo de la fuente de los datos. |
| MODELO | id_modelo | id_modelo | Usar (nombre+versión) serviría, pero haría muy complejas las foráneas en METRICA. |
| METRICA | id_metrica | id_metrica | (id_modelo+nombre_metrica) falla si la misma métrica se vuelve a calcular otro día. |

---

## SEMANA 2 — Modelo relacional y reglas de mapeo

### Revisión del Hito 1

**a) ¿Qué estrategia usaron para la participación parcial entre EXPERIMENTO y MODELO?**
Colocamos `id_experimento` como clave foránea (FK) en la tabla `modelo` y le añadimos una restricción UNIQUE. De esta forma, un experimento no está obligado a tener un registro en la tabla modelo, pero cada modelo apunta a un único experimento sin posibilidad de duplicados.

### Conceptos del modelo relacional

| Concepto técnico | Sinónimo práctico |
| --- | --- |
| Relación | Tabla |
| Tupla | Fila / registro |
| Atributo | Columna / campo |
| Dominio | El rango de valores permitidos para una columna |
| Grado | Cantidad de columnas que tiene la tabla |
| Cardinalidad (de tabla) | Cantidad de registros o filas actuales |

**b) ¿Qué es una "Relación" en el contexto E-R?**
Es el vínculo o la asociación lógica que existe entre dos o más entidades.

**c) ¿Qué es una "Relación" en el contexto relacional?**
Es sencillamente una tabla de datos.

**d) ¿La cardinalidad de una tabla es lo mismo que la cardinalidad en E-R?**
Para nada. En una tabla, la cardinalidad es simplemente cuántas filas hay guardadas (un número que sube o baja). En E-R, la cardinalidad (1:1, 1:N) es una regla de diseño estática que define cómo interactúan las entidades.

### Pautas para pasar de E-R a relacional

* **Regla 1 — De Entidad a Tabla:** Toda entidad se vuelve una tabla y sus atributos se convierten en columnas.
* **Regla 2 — Vínculos 1:N:** La PK de la tabla que tiene el "1" se inserta como FK en la tabla que tiene la "N".
* **Regla 3 — Vínculos N:M:** Obliga a crear una tabla intermedia (puente). Sus columnas serán las PK de las dos tablas originales, funcionando juntas como una PK compuesta.
* **Regla 4 — Atributos con varios valores (multivaluados):** Se extraen a una tabla nueva, apuntando con una FK a la entidad original.
* **Regla 5 — Entidades débiles:** Se vuelven tablas, pero su clave principal se forma combinando su propio identificador con la FK de la entidad fuerte que las sustenta.

**e) ¿Por qué no encontramos entidades débiles en el centro del negocio de DataLab?**
Porque las seis entidades principales tienen independencia absoluta. Ninguna requiere heredar la clave primaria de otra para poder identificarse de forma única.

### Práctica en papel

**a) Diseño de la tabla puente CIENTIFICO_DATOS–PROYECTO:** `asignaciones (id_cientifico FK, id_proyecto FK)`, donde la llave primaria es la unión de ambas.

**b) Conexión 1:N entre PROYECTO y EXPERIMENTO:** La clave foránea `id_proyecto` se ubica dentro de la tabla `experimento`, ya que este representa el extremo "N" de la relación.

### Tarea — Traducción de las tablas faltantes

* `dataset (id_dataset PK, nombre, fuente, fecha_carga, tamanio_filas)`
* `experimento (id_experimento PK, id_proyecto FK, id_dataset FK, id_cientifico FK, fecha_ejecucion, configuracion)`
* `modelo (id_modelo PK, id_experimento FK UNIQUE, nombre, version, algoritmo)`
* `metrica (id_metrica PK, id_modelo FK, nombre_metrica, valor, fecha_calculo)`

---

## BLOQUE 2 — Práctica de Laboratorio (Semana 2)

### Evaluación cruzada

**Duda que planteamos al otro equipo:**...

### Herramienta de digitalización

**Software empleado:** MySQL Workbench

### Nomenclatura de tablas intermedias

| Tabla intermedia | ¿Qué información contiene la fila? | ¿Razón del nombre? |
| --- | --- | --- |
| asignaciones | El vínculo exacto entre un científico particular y un proyecto específico. | Refleja la acción concreta del negocio: asignar personal a un proyecto. |

**Pregunta final — ¿Qué sucede si eliminan un registro de `asignaciones`?**
No pasa nada grave con los datos maestros. El científico sigue existiendo en su tabla y el proyecto en la suya. Solamente se destruye el vínculo que indicaba que esa persona trabajaba en ese proyecto.

### Repaso de conceptos

**1. Contraste entre "relación" en E-R vs. modelo relacional:** En el diagrama E-R es cómo se conectan las figuras; en el modelo relacional, la palabra "relación" significa "tabla".

**2. ¿Por qué la FK siempre va en el lado "N"?** Porque un registro del lado "N" solo pertenece a un padre (lado "1"), así que le basta con una columna para guardar ese ID. Si lo hiciéramos al revés, el lado "1" necesitaría múltiples columnas para guardar a todos sus hijos, arruinando la estructura tabular.

**3. ¿Qué ocurriría si CIENTIFICO_DATOS–PROYECTO se definiera como 1:N en lugar de N:M?**
Significaría que un científico solo puede estar en un proyecto a la vez, eliminando la necesidad de la tabla puente (la FK iría directo en el científico). Esto rompería los requerimientos del negocio, ya que nos dijeron explícitamente que pueden estar en varios proyectos en simultáneo.

---

## SEMANA 3 — Tipos de datos, llaves y restricciones

### Selección de dominios

| Tipo de Dato | Aplicación común | Caso en DataLab |
| --- | --- | --- |
| `INT` | Códigos numéricos y cantidades | `id_experimento`, `tamanio_filas` |
| `VARCHAR(n)` | Cadenas de texto con un tope máximo | `nombre` del dataset, `algoritmo` |
| `TEXT` | Bloques de texto extensos | `configuracion` del experimento |
| `DATE` | Fechas calendario (sin hora) | `fecha_carga`, `fecha_calculo` |
| `DECIMAL(p,e)` | Números con precisión decimal exacta | `valor` de la tabla métrica |
| `BOOLEAN` | Lógica de sí/no | (No lo aplicamos directamente en este núcleo) |

**a) ¿Qué distingue a un tipo de dato de una restricción?**
El tipo de dato le dice al motor qué clase de información va en la celda (si es texto, número, etc.). La restricción es una regla de negocio o de validación que esos datos deben obedecer (por ejemplo, que el número no sea negativo, o que el texto no esté en blanco).

### Aplicación de Restricciones

| Regla / Restricción | Propósito | Caso en DataLab |
| --- | --- | --- |
| `NOT NULL` | Impide que el campo quede vacío | `fecha_ejecucion` de un experimento |
| `UNIQUE` | Exige que el valor jamás se repita en la columna | `id_experimento` en la tabla modelo (asegura el 1:1) |
| `DEFAULT` | Asigna un valor automático si el usuario no manda nada | `fecha_carga` = fecha actual del sistema |
| `CHECK` | Valida que el dato pase una prueba lógica | `tamanio_filas > 0` en los datasets |

**b) ¿Sería correcto poner `CHECK (valor BETWEEN 0 AND 1)` para todas las métricas?**
No. Aunque métricas como el *accuracy* o el *recall* se mueven entre 0 y 1, si el equipo decide registrar errores como el MAE o el RMSE, esos valores superarán el 1. Si ponemos ese CHECK genérico, el sistema rechazaría esos datos válidos.

### Formalización de llaves

**c) ¿A qué llamamos una clave primaria compuesta y dónde se ve en DataLab?**
Es una PK que necesita la unión de dos o más columnas para garantizar que el registro sea único. Lo aplicamos en la tabla puente `asignaciones`, donde la clave principal es la suma de `id_cientifico` + `id_proyecto`.

**d) ¿Qué riesgo corremos si a `modelo.id_experimento` le ponemos FK pero olvidamos el UNIQUE?**
El sistema permitiría que múltiples filas en la tabla `modelo` apunten al mismo `id_experimento`. Esto destruiría la regla de cardinalidad 1:1, haciendo que un solo experimento parezca haber generado varios modelos oficiales.

### Fichas técnicas de las tablas

*(El detalle completo está en `documentacion/diccionario_datos.md` — estructurado en 8 columnas detallando tablas, campos, tipos y restricciones).*

---

## BLOQUE 2 — Práctica de Laboratorio (Semana 3)

### Puesta al día

**¿Con qué tabla o columna se enredó el equipo?**
Tuvimos un poco de confusión al estructurar y nombrar la tabla intermedia de asignaciones.

### Caso práctico

**Si alguien intenta insertar en la tabla `experimento` un valor `id_proyecto = 999` (y ese proyecto no existe), ¿cómo responde la base de datos?**
Debería arrojar un error y bloquear la inserción. De esto se encarga la restricción de llave foránea (FK): protege la integridad referencial asegurando que no se puedan asociar registros a "padres" que no existen en las tablas maestras.

### Repaso de conceptos

**1. Contraste entre tipo de dato y restricción:**
El tipo define la estructura física del dato (ej. número entero), mientras que la restricción impone un límite de negocio sobre ese dato (ej. que el número entero sea mayor a cero).

**2. ¿Por qué el campo `modelo.id_experimento` exige `UNIQUE` y no solo ser una `FK`?**
Porque la `FK` solamente vigila que el experimento referenciado sea real. Es el `UNIQUE` el que garantiza que ese experimento real no sea usado por ningún otro registro en la tabla modelos (cumpliendo así el 1:1).

**3. ¿Cómo obligamos a que `dataset.tamanio_filas` no acepte números negativos?**
Añadiendo la restricción `CHECK (tamanio_filas > 0)` en la definición de la columna.

---

## SEMANA 5 — Resultados y Pruebas de Integridad

* **Motor(es) de base de datos evaluado(s):** MySQL 8.x / SQL Server 2019+
* **Pruebas completadas:** 6 de 6
* **Hipótesis de las Semanas 3/4 que resultaron ciertas:** [listar]
* **Hipótesis que fallaron y sus motivos:** [listar]
* **Contrastes notados entre el comportamiento de MySQL y SQL Server:** [listar]
* **Modificaciones finales hechas al script DDL:** [listar]
