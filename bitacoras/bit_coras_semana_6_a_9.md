# Bitácoras Semana 6 a 9: Guías y Talleres Resueltos

**Autor:** Ronald Rodríguez
**Proyecto:** DataLab

# GUÍA 1: Semana 7 — Evolución del esquema de DataLab con ALTER TABLE, restricciones y DROP

## 1. Propósito

Durante las semanas anteriores construyeron la base de datos DataLab.
Ahora el sistema ya tiene tablas, relaciones, restricciones y datos semilla.
El equipo de DataLab recibe dos nuevas necesidades:

1. conocer el **estado** de cada experimento;

2. registrar **observaciones libres** sobre cada dataset.

## 5. BLOQUE 1 — Formalización sin PC

### Paso 1 — Analizar el escenario

DataLab solicita:

* Cambio 1: Agregar estado a experimento

* Cambio 2: Agregar notas a dataset

**¿Por qué no sería apropiado volver a ejecutar `CREATE TABLE` para resolver estos cambios?**
**Respuesta:** Porque las tablas ya tienen información viva. Si ejecutáramos un `CREATE TABLE` de nuevo, primero nos obligaría a hacer un `DROP TABLE`, lo cual borraría irreversiblemente todos los experimentos, científicos y datasets reales que el equipo ya ha registrado en la base de datos.

### Paso 2 — Diseñar el cambio `estado`

Antes de escribir SQL, define:

* **Nombre:** estado

* **Tipo:** VARCHAR(20)

* **¿Puede ser NULL?** No

* **DEFAULT:** 'planificado'

* **CHECK:** 'planificado', 'en_ejecucion', 'exitoso', 'fallido'

### Paso 3 — Predecir el problema

Antes de ejecutar `ALTER TABLE experimento ADD estado VARCHAR(20) NOT NULL;`

**¿Qué ocurrirá si experimento ya tiene registros?**
**Respuesta:** SQL Server arrojará un error. Al crear una nueva columna que obligatoriamente requiere un dato (`NOT NULL`), el sistema no sabrá qué valor asignarle a los experimentos viejos que ya están creados, dejándolos en estado nulo y violando la regla inmediatamente.

### Paso 4 — Diseñar la solución

Propón una solución utilizando `DEFAULT`.

```
ALTER TABLE experimento
ADD estado VARCHAR(20) NOT NULL CONSTRAINT df_experimento_estado DEFAULT 'planificado' WITH VALUES;

```

**¿Qué valor recibirán los registros existentes?**
**Respuesta:** Gracias al comando `WITH VALUES`, todos los experimentos históricos registrados en la base de datos recibirán automáticamente el valor 'planificado'.

### Paso 5 — Diseñar el CHECK

```
ALTER TABLE experimento
ADD CONSTRAINT chk_experimento_estado
CHECK (estado IN ('planificado', 'en_ejecucion', 'exitoso', 'fallido'));

```

### Paso 6 — Cambio en dataset

* **Nombre:** notas

* **Tipo:** VARCHAR(MAX)

* **¿Puede ser NULL?** Sí

Escribe el `ALTER TABLE`:

```
ALTER TABLE dataset
ADD notas VARCHAR(MAX) NULL;

```

### Paso 7 — Relación con UPDATE

```
UPDATE experimento
SET estado = 'exitoso'
WHERE id_experimento = 1;

```

**¿Por qué se utiliza WHERE?**
**Respuesta:** Para acotar el impacto del cambio. Si no uso el `WHERE`, la base de datos le aplicará el cambio a todo y marcaría absolutamente todos los experimentos del laboratorio como "exitosos", dañando nuestra información.

### Paso 8 — Relación con Git

**¿Por qué este cambio puede considerarse una migración de esquema?**
**Respuesta:** Porque estamos evolucionando la estructura (el "esqueleto") de la base de datos de manera incremental sobre un sistema que ya está en producción, adaptándolo a nuevas necesidades de negocio sin perder la trazabilidad ni los datos históricos.

## 13. BLOQUE 2 — Laboratorio con PC

### Paso 4 — Probar el CHECK

```
UPDATE experimento
SET estado = 'terminado'
WHERE id_experimento = 1;

```

**¿Qué ocurrió?**
**Respuesta:** SQL Server detuvo la actualización y arrojó un error (Msg 547) por conflicto con la restricción.
**¿Por qué SQL Server rechazó o aceptó la operación?**
**Respuesta:** La rechazó porque la palabra 'terminado' no hace parte de la lista exacta de estados permitidos que definimos en el `CHECK` (planificado, en_ejecucion, exitoso, fallido).

### Paso 7 — Agregar una restricción adicional

```
ALTER TABLE proyecto
ADD CONSTRAINT uq_proyecto_nombre
UNIQUE (nombre_proyecto);

```

**Restricción agregada:** UNIQUE en el nombre del proyecto.
**¿Por qué es necesaria?**
**Respuesta:** Para evitar que, por error humano, dos personas registren proyectos diferentes utilizando exactamente el mismo nombre, lo que causaría ambigüedad en los reportes y confusión en los científicos.

### Paso 8 — Practicar modificación de columna

```
ALTER TABLE dataset
ALTER COLUMN nombre VARCHAR(200) NOT NULL;

```

* **¿Qué tamaño tenía?** VARCHAR(100)

* **¿Qué tamaño tendrá?** VARCHAR(200)

* **¿Por qué se amplía?** Porque descubrimos que los nombres extraídos de repositorios externos y archivos crudos suelen ser muy descriptivos y estaban truncándose al llegar al límite de los 100 caracteres.

### Reto — Detectar un problema antes de agregar una restricción

**¿Existen duplicados?** Sí.
**¿Se puede agregar UNIQUE inmediatamente?** No, porque la base detectaría los duplicados actuales y abortaría la restricción.
**¿Qué habría que hacer primero?** Habría que ejecutar consultas `DELETE` o `UPDATE` para unificar, limpiar o borrar los registros repetidos antes de aplicar la regla.

### Reto — CHECK sobre datos existentes

Imagina que existe `estado = 'terminado'` y la regla no lo permite:

1. Detectar datos inválidos.

2. Corregirlos con UPDATE: `UPDATE experimento SET estado = 'exitoso' WHERE estado = 'terminado';`

3. Agregar CHECK.

4. Verificar.

### Reto — Diferenciar DML y DDL

* **DML:** `INSERT`, `UPDATE`, `DELETE`, `SELECT`

* **DDL:** `ALTER TABLE`, `DROP TABLE`, `CREATE TABLE`

**Diferencia:** DML manipula la *información* que vive dentro de las tablas (crear un registro, modificarlo, leerlo). DDL manipula la *estructura o contenedores* de la base de datos (crear la tabla misma, alterarle columnas, destruirla).

### Reto Feynman

* **Reto 1:** Porque `CREATE TABLE` destruye los datos históricos; `ALTER TABLE` muta la estructura manteniendo la información viva.

* **Reto 2:** Porque las filas antiguas quedarán con el campo vacío (nulo), rompiendo la regla de no-nulos inmediatamente.

* **Reto 3:** Para darle un valor "salvavidas" automático a esos registros viejos.

* **Reto 4:** Si un solo dato guardado previamente no cumple la nueva regla del CHECK, SQL Server no permitirá crear la restricción.

* **Reto 5:** `DELETE` borra filas; `DROP COLUMN` borra un atributo de la tabla; `DROP TABLE` borra la tabla completa; `DROP DATABASE` borra todo el contenedor general.

* **Reto 6:** Porque representa un avance secuencial y versionable en la arquitectura del sistema.

* **Reto 7:** Porque `DROP` es destructivo e irreversible. Un error ahí borraría el trabajo real de mis compañeros.

# GUÍA 2: Actividad — Manipulación de Datos con SQL (INSERT, SELECT, UPDATE y DELETE)

## 11. Actividad — Crear registros

### 11.1 Un científico

```
Nombre:
[ Ronald Rodriguez ]
Correo:
[ ronald.rodriguez@datalab.com ]

```

### 11.2 Un proyecto

```
Nombre:
[ Prediccion de demanda (practica DML) ]
Descripción:
[ Proyecto para analizar y predecir la demanda de servicios utilizando regresion lineal. ]

```

### 11.3 Un dataset

```
Nombre:
[ Historial de demanda 2026 ]
Fuente:
[ Sistema de facturacion interno ]
Fecha de carga:
[ 2026-10-22 ]
Tamaño de filas:
[ 25000 ]

```

## 18. Actividad — DELETE controlado

Documenta:

* **qué registro eliminaste:** El proyecto de práctica con nombre "Proyecto Temporal DELETE".

* **por qué lo seleccionaste:** Porque lo creé específicamente para esta prueba y no tiene ningún experimento asociado que bloquee el DELETE por claves foráneas.

* **si existían relaciones:** No, me aseguré de consultar previamente con un JOIN a la tabla `experimento` para verificar que el conteo de dependencias fuera 0.

* **qué resultado obtuviste:** El registro fue borrado exitosamente y el SELECT posterior devolvió un conjunto de resultados vacío.

## 23. Paso 1 — Diseñar antes de ejecutar

Documenta:

```
Nombre del proyecto:
[ Auditoría Predictiva 2026 ]

Descripción:
[ Modelo experimental para detectar anomalías tempranas en registros contables. ]

¿Por qué se crea?
[ Porque el departamento de finanzas solicitó una prueba de concepto usando Machine Learning. ]

¿Quién es responsable?
[ Ronald Rodríguez ]

¿Qué otros datos necesitará posteriormente?
[ Necesitará tener asignados científicos, un dataset financiero inicial y al menos un experimento planificado. ]

```

## 31. Experimento de integridad

Intenta realizar deliberadamente una operación incorrecta:

```
INSERT INTO experimento (id_proyecto, id_cientifico, fecha_ejecucion, configuracion)
VALUES (9999, 1, '2026-09-24', 'Prueba de integridad');

```

Documenta:

```
¿Qué ocurrió?
[ SQL Server arrojó un error (Msg 547) y detuvo la ejecución del INSERT. ]

¿Por qué ocurrió?
[ Porque intenté registrar el experimento asociándolo al proyecto con ID 9999, el cual no existe en la tabla proyecto. ]

¿Qué restricción intervino?
[ Intervino la restricción de Clave Foránea (Foreign Key) fk_experimento_proyecto. ]

¿Qué relación del modelo está protegiendo SQL Server?
[ Está protegiendo la relación jerárquica de 1 a N entre proyecto y experimento, asegurando que ningún experimento quede "huérfano". ]

```

## 40. Reto Feynman

Explica con tus propias palabras:

1. **¿Qué hace SELECT?** Sirve para leer o traer la información guardada. No altera absolutamente nada en la tabla, es como abrir un reporte para visualizarlo.

2. **¿Qué hace INSERT?** Agrega nuevas filas o registros completos al final de una tabla. Es para la creación de nuevos datos.

3. **¿Qué hace UPDATE?** Cambia los valores específicos dentro de filas que ya existen. Es para editar o corregir un dato puntual sin tener que borrar toda la fila y crearla de cero.

4. **¿Qué hace DELETE?** Elimina filas completas permanentemente de la tabla.

5. **¿Por qué UPDATE necesita normalmente WHERE?** Porque si no uso WHERE, SQL no sabe a qué fila específica aplicarle el cambio y, por defecto, se lo aplicará a todas las filas de la tabla al mismo tiempo. Destruiría la base de datos.

6. **¿Por qué DELETE puede verse afectado por las claves foráneas?** Porque si intento borrar un registro padre que tiene registros hijos asociados en otra tabla, SQL me bloquea para mantener la integridad de los datos y evitar dejar "hijos huérfanos".

7. **¿Por qué debemos consultar antes de modificar?** Para previsualizar exactamente cuáles y cuántas filas voy a afectar. Es mi red de seguridad.

8. **¿Cómo se relacionan INSERT, SELECT, UPDATE y DELETE con CRUD?** Son la representación exacta: CREATE = INSERT, READ = SELECT, UPDATE = UPDATE, DELETE = DELETE.

9. **¿Qué ocurriría si intentas crear un experimento utilizando un `id_proyecto` inexistente?** SQL Server arrojaría un error de violación de Clave Foránea y no crearía el experimento.

# GUÍA 3: Semana 8 — Actividades y Ejercicios (Filtros, operadores, orden y agregación)

## BLOQUE 1 — Actividades conceptuales

### Actividad 1 — Los cuatro comandos DML

| Comando | ¿Qué hace? | Tabla DataLab donde lo aplicarías | 
| ----- | ----- | ----- | 
| **INSERT** | Crea nuevas filas. | `dataset` (para agregar el historial de ventas). | 
| **SELECT** | Lee información. | `proyecto` (para ver los proyectos actuales). | 
| **UPDATE** | Modifica filas. | `experimento` (para actualizar los estados). | 
| **DELETE** | Elimina filas. | `modelo` (si un modelo se da de baja). | 

**Pregunta Feynman:** Explica la diferencia entre `UPDATE` y `ALTER TABLE`.
**Respuesta:** `UPDATE` modifica el contenido (los datos) que vive dentro de la fila de una tabla (por ejemplo, corregir el correo de alguien). `ALTER TABLE` modifica el "cascarón" (la estructura de la tabla), como cuando le agregamos una columna nueva que antes no existía.

### Actividad 2 — UPDATE y DELETE sin WHERE

**¿Es una instrucción válida?** Sintácticamente sí.
**¿Qué filas modifica?** Todas las filas de la tabla experimento sin excepción.
**¿Por qué puede ser peligrosa?** Porque corrompería la información marcando como "fallidos" experimentos que estaban planificados o que habían sido exitosos.
**¿Cómo comprobarías primero qué filas serán afectadas?** Corriendo un `SELECT * FROM experimento WHERE...` con el filtro correcto antes de aplicar el `UPDATE`.
**Diferencia de DELETE vs eliminar tabla:** `DELETE FROM experimento;` borra toda la información, pero la tabla queda viva y vacía, lista para recibir más datos. `DROP TABLE experimento;` destruye la tabla completamente, incluyendo su estructura de columnas.

### Actividad 3 — Operadores

| Operador | Ejemplo | ¿Qué busca? | 
| ----- | ----- | ----- | 
| `=` | `fuente = 'interna'` | Coincidencia exacta de valor. | 
| `<>` | `estado <> 'fallido'` | Todo lo que sea diferente a ese valor. | 
| `>` | `tamanio_filas > 10000` | Valores estrictamente mayores a la cifra. | 
| `<` | `valor < 0.5` | Valores estrictamente menores. | 
| `>=` | `fecha_carga >= '2026-01-01'` | Valores mayores o iguales. | 
| `<=` | `valor <= 0.8` | Valores menores o iguales. | 
| `BETWEEN` | `valor BETWEEN 0.7 AND 0.9` | Valores dentro de un rango (inclusivo). | 
| `IN` | `estado IN ('exitoso', 'fallido')` | Que el valor coincida con alguna opción de la lista. | 
| `LIKE` | `nombre_proyecto LIKE '%demanda%'` | Búsqueda de patrones de texto. | 
| `IS NULL` | `notas IS NULL` | Celdas que están completamente vacías (sin valor). | 
| `IS NOT NULL` | `notas IS NOT NULL` | Celdas que sí contienen algún dato. | 

### Actividad 4 — NULL

**¿Por qué `WHERE notas = NULL` es incorrecto?** Porque `NULL` no es un valor, es el estado de "ausencia de valor". SQL no puede validar una igualdad matemática con algo que no existe.
**La consulta correcta:** `SELECT * FROM dataset WHERE notas IS NULL;`

### Actividad 5 — AND, OR y NOT

**a)** `SELECT * FROM experimento WHERE estado = 'exitoso';`
**b)** `SELECT * FROM experimento WHERE estado = 'exitoso' OR estado = 'fallido';`
**c)** `SELECT * FROM metrica WHERE valor >= 0.70 AND valor <= 0.90;`
**d)** `SELECT * FROM experimento WHERE estado <> 'fallido';`
**e)** `SELECT * FROM dataset WHERE fuente = 'interna' AND (tamanio_filas > 1000 OR notas IS NOT NULL);`
**¿Por qué utilizaste los paréntesis?** Para obligar al motor a evaluar el bloque `OR` como un conjunto, asegurándome de que el dataset *siempre* sea interno y cumpla alguna de las dos condiciones extras, y no que me traiga datos externos por accidente.

## BLOQUE 2 — Laboratorio de filtros

### Actividad 7 — Comparación de operadores

* `OR`: Es útil cuando solo hay que comparar un par de condiciones simples.

* `IN`: Es mucho más limpio y legible que el `OR` cuando tenemos listas de 3 o más elementos.

* `NOT IN`: Es excelente para excluir elementos rápidamente sin llenar el código de múltiples `AND <>`.

### Actividad 8 — LIKE

1. `SELECT * FROM dataset WHERE nombre LIKE 'EEG%';`

2. `SELECT * FROM dataset WHERE nombre LIKE '%financiero';`

3. `SELECT * FROM dataset WHERE nombre LIKE '%demanda%';`

4. `SELECT * FROM dataset WHERE nombre LIKE 'Data____';` (Data seguido de 4 letras exactas).

## BLOQUE 3 — Ordenamiento

### Actividad 9 — ORDER BY

**a)** `ORDER BY nombre ASC;`
**b)** `ORDER BY fecha_carga DESC;`
**Pregunta:** Si dos datasets tienen la misma fuente, ¿qué criterio decide cuál aparece primero?
**Respuesta:** Sin un segundo criterio, SQL los mostrará en el orden aleatorio en el que el motor los lee del disco. Para desempatar controladamente, hay que añadir una segunda columna al `ORDER BY`.

## BLOQUE 4 — Funciones de agregación

### Actividad 13 — HAVING

`SELECT nombre_metrica, AVG(valor) FROM metrica GROUP BY nombre_metrica HAVING AVG(valor) > 0.8;`
**¿Por qué no utilizo WHERE AVG(valor) > 0.8?** Porque `WHERE` filtra fila a fila *antes* de armar los grupos, pero el promedio (`AVG`) es un cálculo que requiere que el grupo ya esté armado. El `HAVING` actúa correctamente *después* del `GROUP BY`.

## BLOQUE 6 — DELETE seguro

### Actividad 15 — Registro de prueba

**¿Por qué es importante que el registro de prueba sea claramente identificable?**
**Respuesta:** Para asegurar que en nuestras prácticas no borremos o corrompamos accidentalmente información real de producción. Un nombre identificable minimiza el riesgo al correr el script de DELETE.

## BLOQUE 7 — Preguntas de negocio

### Actividad 16 — Retomar preguntas de Semana 6

**Pregunta:** ¿Qué tipo de métricas están por encima de un rendimiento del 80%?
**Objetivo:** Saber qué métricas superan un promedio de 0.8 de forma general usando agregaciones.
**Consulta SQL:** `SELECT nombre_metrica, AVG(valor) AS Promedio FROM metrica GROUP BY nombre_metrica HAVING AVG(valor) > 0.8;`
**Interpretación:** Nos dice directamente qué algoritmos de validación son los más robustos en los modelos actuales.

### Actividad 18 — Crear una pregunta de negocio propia

**Pregunta de negocio:** ¿Qué fuentes acumulan más de 1 millón de registros de volumen?
**¿Por qué es importante?** Para dimensionar costos de infraestructura, almacenamiento y procesamiento.
**Tablas utilizadas:** `dataset`
**Consulta SQL:**

```
SELECT fuente, COUNT(*) AS datasets, SUM(tamanio_filas) AS total_volumen
FROM dataset 
GROUP BY fuente 
HAVING SUM(tamanio_filas) > 1000000;

```

**Interpretación:** Identifica los orígenes pesados cuyo acumulado supera la barrera del millón de registros procesados.

## BLOQUE 8 — Desafío Feynman

### Actividad 19 — Diferencia entre WHERE y HAVING sin SQL

`WHERE` es el portero de la discoteca: revisa persona por persona (fila por fila) para decidir quién entra. `HAVING` es el mesero adentro del salón: revisa el grupo en la mesa ya conformada, y si el grupo no cumple el consumo mínimo (promedio/suma), lo invita a irse.

### Actividad 20 — Explícalo con un ejemplo

Usar `WHERE notas = NULL` es como preguntarle a un sistema: "¿Tu edad es igual a No Tengo Idea?". La lógica falla, nunca te dirá que sí, porque no se puede igualar matemáticamente algo desconocido. Lo correcto es usar `WHERE notas IS NULL`, que es el equivalente a preguntar "¿El campo está vacío?".

## BLOQUE 9 — Comparación SQL Server / MySQL

### Actividad 21

* **SQL Server:** Usa `TOP 5` justo después de la palabra `SELECT`.

* **MySQL:** Usa `LIMIT 5` al final absoluto de la consulta.

* **Por qué cambia:** Porque son "dialectos" desarrollados por compañías diferentes (Microsoft vs. Oracle). Aunque las bases del lenguaje SQL son el mismo estándar ANSI, cada motor tiene variaciones propietarias para funciones específicas como los topes de registros.