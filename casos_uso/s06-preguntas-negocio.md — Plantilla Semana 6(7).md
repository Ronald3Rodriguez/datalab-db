# Preguntas de Negocio — Semana 6

## DataLab — Consultas SQL básicas

**Proyecto:** DataLab  
**Semana:** 6  
**Tema:** SQL como lenguaje relacional y sintaxis básica  
**SGBD:** SQL Server  
**Herramienta:** SQL Server Management Studio (SSMS)

---

## 1. Propósito

Este documento registra las **preguntas de negocio** que el equipo desea responder utilizando la base de datos DataLab.

El objetivo no es comenzar directamente escribiendo SQL.

Primero debemos comprender:

> **¿Qué información necesitamos conocer?**

Después identificaremos:

- qué tabla contiene la información;
- qué columnas necesitamos;
- si la pregunta puede resolverse utilizando una sola tabla;
- si requiere información de varias tablas;
- qué consulta SQL permite responderla.

Este documento evolucionará durante el semestre junto con el proyecto.

---

# 2. Proceso de trabajo

Para cada pregunta seguiremos este proceso:

```text
Pregunta de negocio
        ↓
¿Qué queremos conocer?
        ↓
¿Qué tabla(s) contienen la información?
        ↓
¿Qué columna(s) necesitamos?
        ↓
¿Una tabla o varias?
        ↓
Consulta SQL
        ↓
Resultado
        ↓
Validación
```

---

# 3. Preguntas de negocio — Consultas básicas

En esta sección se documentarán preguntas que puedan resolverse principalmente utilizando una tabla.

---

## Pregunta 01 — Científicos de datos

### Pregunta de negocio

> ¿Cuáles son los científicos de datos registrados en DataLab?

### Objetivo

Obtener el listado de científicos de datos registrados en la plataforma.

### Tabla involucrada

```text
cientifico_datos
```

### Columnas necesarias

```text
id_cientifico
nombre
correo
```

### Tipo de consulta

```text
x Una tabla
☐ Varias tablas
```

### Consulta SQL

```sql
SELECT id_cientifico,
       nombre,
       correo_institucional
FROM cientifico_datos;
```

### Resultado esperado

Describa brevemente qué información debería devolver la consulta.

```text

| id_cientifico | nombre         | correo_institucional          |
|---------------|----------------|-------------------------------|
| 1             | Ana Torres     | ana.torres@datalab.edu.co     |
| 2             | Carlos Mendoza | carlos.mendoza@datalab.edu.co |
| 3             | Laura Gómez    | laura.gomez@datalab.edu.co    |
| 4             | Diego Ramírez  | diego.ramirez@datalab.edu.co  |
```

---

## Pregunta 02 — Proyectos

### Pregunta de negocio

> ¿Cuáles son los proyectos registrados en DataLab?

### Objetivo

Obtener el listado de proyectos disponibles.

### Tabla involucrada

```text
proyecto
```

### Columnas necesarias

```text
id_proyecto
nombre
descripcion
```

### Tipo de consulta

```text
x Una tabla
☐ Varias tablas
```

### Consulta SQL

```sql
SELECT id_proyecto,
       nombre_proyecto,
       descripcion
FROM proyecto;
```

### Resultado esperado

```text
| id_proyecto | nombre_proyecto            | descripcion                                                                 |
|-------------|----------------------------|-----------------------------------------------------------------------------|
| 1           | Predicción de demanda      | Modelo para predecir la demanda de productos utilizando información histórica. |
| 2           | Clasificación de pacientes | Proyecto de clasificación de pacientes a partir de variables biomédicas.    |
| 3           | Detección de fraude        | Identificación de transacciones potencialmente fraudulentas.                |
| 4           | Análisis de abandono       | Predicción de clientes con riesgo de abandonar un servicio.                 |
```

---

## Pregunta 03 — Datasets

### Pregunta de negocio

> ¿Qué datasets están registrados en DataLab y cuál es su fuente?

### Objetivo

Identificar los datasets disponibles y su procedencia.

### Tabla involucrada

```text
dataset
```

### Columnas necesarias

```text
id_dataset
nombre
fuente
```

### Tipo de consulta

```text
x Una tabla
☐ Varias tablas
```

### Consulta SQL

```sql
SELECT id_dataset,
       nombre,
       fuente
FROM dataset;
```

### Resultado esperado

```text
| id_dataset | nombre                  | fuente  |
|------------|-------------------------|---------|
| 2          | ventas_historicas       | interna |
| 3          | clientes_2026           | externa |
| 4          | transacciones_bancarias | externa |
| 5          | pacientes_historicos    | interna |
| 6          | consumo_clientes        | interna |
```

---

## Pregunta 04 — Experimentos

### Pregunta de negocio

> ¿Cuáles son los experimentos registrados en DataLab?

### Objetivo

Obtener información básica sobre los experimentos realizados.

### Tabla involucrada

```text
experimento
```

### Columnas necesarias

```text
id_experimento
id_proyecto
id_cientifico
fecha_ejecucion
```

### Tipo de consulta

```text
x Una tabla
☐ Varias tablas
```

### Consulta SQL

```sql
SELECT id_experimento,
       id_proyecto,
       id_cientifico,
       fecha_ejecucion
FROM experimento;
```

### Resultado esperado

```text
| id_experimento | id_proyecto | id_cientifico | fecha_ejecucion |
|----------------|-------------|---------------|-----------------|
| 1              | 1           | 1             | 2026-08-10      |
| 2              | 1           | 2             | 2026-08-18      |
| 3              | 2           | 3             | 2026-09-06      |
| 4              | 3           | 4             | 2026-09-08      |
| 5              | 3           | 1             | 2026-09-12      |
| 6              | 4           | 2             | 2026-09-15      |
```

---

## Pregunta 05 — Modelos

### Pregunta de negocio

> ¿Qué modelos están registrados y qué algoritmo utiliza cada uno?

### Objetivo

Identificar los modelos disponibles y los algoritmos utilizados.

### Tabla involucrada

```text
modelo
```

### Columnas necesarias

```text
id_modelo
nombre
version
algoritmo
```

### Tipo de consulta

```text
☐ Una tabla
☐ Varias tablas
```

### Consulta SQL

```sql
SELECT id_modelo,
       nombre,
       version,
       algoritmo
FROM modelo;
```

### Resultado esperado

```text
| id_modelo | nombre                         | version | algoritmo           |
|-----------|--------------------------------|---------|---------------------|
| 1         | Modelo Demanda Base            | 1.0     | Regresión Lineal    |
| 2         | Modelo Demanda Estacional      | 1.1     | Random Forest       |
| 3         | Modelo Clasificación Pacientes | 1.0     | Regresión Logística |
| 4         | Modelo Fraude Base             | 1.0     | Random Forest       |
| 5         | Modelo Fraude Optimizado       | 1.1     | Gradient Boosting   |
| 6         | Modelo Abandono                | 1.0     | Random Forest       |
```

---

# 4. Preguntas que requieren información de varias tablas

Algunas preguntas de negocio no pueden responderse adecuadamente utilizando una sola tabla.

En esta sección **no es necesario construir todavía el `JOIN`**.

El objetivo de esta semana es reconocer que la pregunta necesita información distribuida en diferentes tablas.

---

## Pregunta 06 — Científico y experimento

### Pregunta de negocio

> ¿Qué científico de datos ejecutó cada experimento?

### Información necesaria

```text
cientifico_datos
experimento
```

### ¿Por qué necesitamos varias tablas?

Explique qué información se encuentra en cada tabla.

```text
cientifico_datos:
[Escriba aquí]

experimento:
[Escriba aquí]
```

### Tipo de consulta

```text
☐ Una tabla
☒ Varias tablas
```

### ¿Requiere JOIN?

```text
☒ Sí
☐ No
```

### Consulta SQL

```sql
-- No es necesario resolver todavía el JOIN.
-- Describa aquí qué información necesitaría relacionar.
```

### Resultado esperado

```text
[Escriba aquí]
```

---

## Pregunta 07 — Proyecto y experimento

### Pregunta de negocio

> ¿Qué experimentos pertenecen a cada proyecto?

### Información necesaria

```text
proyecto
experimento
```

### Tipo de consulta

```text
☐ Una tabla
☒ Varias tablas
```

### ¿Requiere JOIN?

```text
☒ Sí
☐ No
```

### Consulta SQL

```sql
-- El JOIN se desarrollará posteriormente.
```

### Resultado esperado

```text
[Escriba aquí]
```

---

## Pregunta 08 — Experimento y modelo

### Pregunta de negocio

> ¿Qué modelos fueron generados a partir de cada experimento?

### Información necesaria

```text
experimento
modelo
```

### Tipo de consulta

```text
☐ Una tabla
☒ Varias tablas
```

### ¿Requiere JOIN?

```text
☒ Sí
☐ No
```

### Resultado esperado

```text
[Escriba aquí]
```

---

## Pregunta 09 — Dataset y experimento

### Pregunta de negocio

> ¿Qué datasets fueron utilizados en cada experimento?

### Información necesaria

```text
dataset
uso_dataset
experimento
```

### Tipo de consulta

```text
☐ Una tabla
☒ Varias tablas
```

### ¿Requiere JOIN?

```text
☒ Sí
☐ No
```

### Resultado esperado

```text
[Escriba aquí]
```

---

# 5. Consultas que utilizan `DISTINCT`

Identifique al menos una pregunta que requiera obtener valores únicos.

### Pregunta de negocio

> ¿Qué algoritmos diferentes se han utilizado en los modelos?

### Tabla

```text
modelo
```

### Columna

```text
algoritmo
```

### ¿Puede haber valores repetidos?

```text
☐ Sí
☐ No
```

### ¿Necesitamos `DISTINCT`?

```text
☐ Sí
☐ No
```

### Consulta SQL

```sql
-- Escriba aquí la consulta
```

---

# 6. Consultas que utilizan `ORDER BY`

Identifique una pregunta que requiera ordenar los resultados.

### Pregunta de negocio

> ¿Cómo podemos listar los proyectos en orden alfabético?

### Tabla

```text
proyecto
```

### Columna utilizada para ordenar

```text
nombre
```

### Orden

```text
☐ ASC
☐ DESC
```

### Consulta SQL

```sql
-- Escriba aquí la consulta
```

---

# 7. Consultas que utilizan `TOP`

Identifique una pregunta que requiera limitar la cantidad de resultados.

### Pregunta de negocio

> ¿Cuáles son los tres primeros proyectos según un criterio de orden?

### Tabla

```text
proyecto
```

### Cantidad de registros

```text
3
```

### Criterio de orden

```text
[Escriba aquí]
```

### Consulta SQL

```sql
-- Escriba aquí la consulta
```

---

# 8. Matriz de preguntas

Complete la siguiente tabla con las preguntas desarrolladas.

| # | Pregunta | Tabla(s) | ¿Una o varias tablas? | ¿DISTINCT? | ¿ORDER BY? | ¿TOP? | ¿JOIN futuro? |
|---|---|---|---|---|---|---|---|
| 01 | Científicos registrados | | | | | | |
| 02 | Proyectos registrados | | | | | | |
| 03 | Datasets registrados | | | | | | |
| 04 | Experimentos registrados | | | | | | |
| 05 | Modelos y algoritmos | | | | | | |
| 06 | Científico y experimento | | | | | | |
| 07 | Proyecto y experimento | | | | | | |
| 08 | Experimento y modelo | | | | | | |
| 09 | Dataset y experimento | | | | | | |

---

# 9. Validación de las consultas

Para cada consulta básica debemos verificar:

### Pregunta

¿La consulta responde exactamente la pregunta de negocio?

```text
☐ Sí
☐ No
```

### Columnas

¿La consulta devuelve solamente las columnas necesarias?

```text
☐ Sí
☐ No
```

### Datos

¿Los resultados corresponden con los datos existentes en DataLab?

```text
☐ Sí
☐ No
```

### Duplicados

¿Existen registros repetidos que deberían eliminarse del resultado?

```text
☐ Sí
☐ No
☐ No aplica
```

### Orden

¿Los resultados necesitan un orden específico?

```text
☐ Sí
☐ No
☐ No aplica
```

---

# 10. Preguntas pendientes para próximas semanas

Las siguientes preguntas fueron identificadas pero requieren conocimientos que se desarrollarán posteriormente.

| Pregunta | Tablas involucradas | Concepto futuro |
|---|---|---|
| ¿Qué científico ejecutó cada experimento? | cientifico_datos + experimento | JOIN |
| ¿Qué experimentos pertenecen a cada proyecto? | proyecto + experimento | JOIN |
| ¿Qué modelos fueron generados por cada experimento? | experimento + modelo | JOIN |
| ¿Qué datasets fueron utilizados en cada experimento? | dataset + uso_dataset + experimento | JOIN |

> **Importante:** identificar una pregunta como "pendiente" no significa que esté incompleta. Significa que estamos reconociendo qué conocimiento SQL necesitamos aprender para resolverla.

---

# 11. Reflexión Feynman

Explique con sus propias palabras:

### ¿Qué diferencia existe entre una pregunta de negocio y una consulta SQL?

```text
[Escriba aquí]
```

### ¿Por qué no debemos comenzar escribiendo SQL antes de comprender la pregunta?

```text
[Escriba aquí]
```

### ¿Cómo puedo determinar si una pregunta necesita una o varias tablas?

```text
[Escriba aquí]
```

### ¿Qué significa que una consulta sea declarativa?

```text
[Escriba aquí]
```

---

# 12. Evidencia de trabajo

Cada integrante del equipo debe poder explicar al menos una de las consultas desarrolladas.

Para la sustentación, el estudiante puede ser preguntado:

- ¿Qué pregunta responde esta consulta?
- ¿Por qué seleccionaste esas columnas?
- ¿Por qué utilizaste `DISTINCT`?
- ¿Por qué utilizaste `ORDER BY`?
- ¿Por qué utilizaste `TOP`?
- ¿Qué tabla contiene la información?
- ¿Qué consulta requerirá posteriormente un `JOIN`?
- ¿Cómo sabes que el resultado obtenido es correcto?

---

# 13. Relación con el repositorio

Este documento debe almacenarse en:

```text
casos_uso/s06-preguntas-negocio.md
```

La consulta SQL correspondiente debe almacenarse en:

```text
scripts/consultas/s06-consultas-basicas.sql
```

Los datos utilizados deben prepararse mediante:

```text
scripts/dml/s06-reset-datos.sql
scripts/dml/s06-datos-semilla.sql
```

---

# 14. Commit sugerido

```bash
git add .
git commit -m "consulta: primeras consultas SELECT básicas sobre DataLab"
git push
```

---

# 15. Checklist

Antes de finalizar:

- [ ] Las preguntas de negocio están claramente redactadas.
- [ ] Identifiqué las tablas involucradas.
- [ ] Identifiqué las columnas necesarias.
- [ ] Diferencié preguntas de una tabla y de varias tablas.
- [ ] Implementé las consultas básicas.
- [ ] Utilicé `DISTINCT` cuando corresponde.
- [ ] Utilicé `ORDER BY` cuando corresponde.
- [ ] Utilicé `TOP` cuando corresponde.
- [ ] Identifiqué las preguntas que posteriormente requerirán `JOIN`.
- [ ] Validé los resultados.
- [ ] Documenté mis decisiones.
- [ ] El archivo está almacenado en `casos_uso/`.
- [ ] El trabajo está versionado en Git.

---

## Nota para el equipo

Este documento **evolucionará durante el semestre**.

No es necesario resolver desde ahora todas las preguntas.

La intención es que DataLab pase progresivamente de:

```text
Preguntas
   ↓
Consultas básicas
   ↓
JOIN
   ↓
Agrupaciones
   ↓
Subconsultas
   ↓
Consultas de negocio
```

Cada semana agregaremos nuevas capacidades para responder preguntas más complejas sobre los mismos datos.