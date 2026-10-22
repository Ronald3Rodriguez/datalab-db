# Preguntas de Negocio DataLab — Semana 8 y Cierre de Hito 3

**Autor:** Ronald Rodríguez  
**Repositorio:** [github.com/Ronald3Rodriguez/datalab-db](https://github.com/Ronald3Rodriguez/datalab-db)  
**SGBD:** SQL Server  

---

## 1. Actividad 16 — Pregunta de la Semana 6 Retomada

### Pregunta
¿Cuál es el desempeño promedio de cada tipo de métrica y cuáles superan un umbral de calidad de $0.8$?

### Objetivo
Resumir en una sola consulta las mediciones de la tabla `metrica` por tipo (*accuracy*, *f1-score*, etc.) y detectar cuáles tipos tienen un desempeño promedio aceptable mediante `GROUP BY`, `AVG()` y `HAVING`.

```sql
SELECT nombre_metrica, AVG(valor) AS promedio
FROM metrica
GROUP BY nombre_metrica
HAVING AVG(valor) > 0.8
ORDER BY promedio DESC;
```

**Interpretación:**  
Cada fila representa un tipo de métrica cuyo promedio supera el umbral de $0.8$. Los tipos no listados corresponden a métricas con un promedio menor o igual a $0.8$. Se utiliza `HAVING` en lugar de `WHERE` debido a que la condición evalúa una función de agregación calculada sobre el grupo.

---

## 2. Actividad 17 — Preguntas de Negocio

### Pregunta 1 — Datasets por fuente
**Objetivo:** Conocer la cantidad de datasets internos y externos para analizar la dependencia de datos de terceros.  
**Requisito:** `GROUP BY` + `COUNT`

```sql
SELECT fuente, COUNT(*) AS cantidad
FROM dataset
GROUP BY fuente;
```
*Interpretación:* Muestra la distribución de datasets según su origen. La suma de las cantidades coincide con el total de registros de la tabla `dataset`.

---

### Pregunta 2 — Experimentos por estado
**Objetivo:** Visualizar el avance del trabajo en el laboratorio (*planificados*, *en ejecución*, *exitosos* o *fallidos*).  
**Requisito:** `GROUP BY` por `estado` + `COUNT`

```sql
SELECT estado, COUNT(*) AS cantidad
FROM experimento
GROUP BY estado;
```
*Interpretación:* Refleja el estado operativo de los experimentos. Si existen experimentos sin un estado definido, `GROUP BY` agrupa los valores `NULL` en una fila independiente.

---

### Pregunta 3 — Promedio por tipo de métrica
**Objetivo:** Comparar el desempeño medio global de cada tipo de métrica.  
**Requisito:** `GROUP BY` + `AVG`

```sql
SELECT nombre_metrica, AVG(valor) AS promedio
FROM metrica
GROUP BY nombre_metrica;
```
*Interpretación:* Dado que la columna `valor` está acotada al intervalo $[0, 1]$ por la restricción `chk_metrica_valor`, los promedios resultantes permanecen dentro de dicho rango.

---

### Pregunta 4 — Métricas con promedio > 0.8
**Objetivo:** Identificar los tipos de métrica con alto desempeño general.  
**Requisito:** `GROUP BY` + `AVG` + `HAVING`

```sql
SELECT nombre_metrica, AVG(valor) AS promedio
FROM metrica
GROUP BY nombre_metrica
HAVING AVG(valor) > 0.8;
```
*Interpretación:* Filtra únicamente los grupos de la consulta anterior cuyos promedios superan el valor de $0.8$.

---

### Pregunta 5 — Dataset más reciente de cada fuente
**Objetivo:** Identificar el registro de carga más actual según la fuente de origen.  
**Requisito:** Filtro y ordenamiento.

```sql
-- Aproximación A: Fecha máxima registrada por fuente
SELECT fuente, MAX(fecha_carga) AS fecha_mas_reciente
FROM dataset
GROUP BY fuente;

-- Aproximación B: Registro específico filtrado por origen
SELECT TOP 1 nombre, fuente, fecha_carga
FROM dataset
WHERE fuente = 'interna'
ORDER BY fecha_carga DESC;

SELECT TOP 1 nombre, fuente, fecha_carga
FROM dataset
WHERE fuente = 'externa'
ORDER BY fecha_carga DESC;
```
*Interpretación:* La Aproximación A entrega la fecha máxima acumulada por origen, mientras que la Aproximación B obtiene el dataset específico más reciente para cada fuente.

---

### Pregunta 6 — Experimentos exitosos o fallidos
**Objetivo:** Consultar únicamente los experimentos concluidos.  
**Requisito:** `IN`

```sql
SELECT id_experimento, id_proyecto, estado
FROM experimento
WHERE estado IN ('exitoso', 'fallido');
```
*Interpretación:* Filtra los experimentos que han finalizado su ciclo, ignorando los estados `planificado` o `en_ejecucion`.

---

### Pregunta 7 — Datasets con notas
**Objetivo:** Consultar datasets que cuentan con observaciones o documentación adicional.  
**Requisito:** `IS NOT NULL`

```sql
SELECT id_dataset, nombre, notas
FROM dataset
WHERE notas IS NOT NULL;
```
*Interpretación:* Retorna solo aquellos registros de datasets que contienen observaciones documentadas en el campo `notas`.

---

### Pregunta 8 — Métricas entre 0.70 y 0.90
**Objetivo:** Filtrar métricas en un rango de calidad intermedio.  
**Requisito:** `BETWEEN`

```sql
SELECT id_metrica, nombre_metrica, valor
FROM metrica
WHERE valor BETWEEN 0.70 AND 0.90;
```
*Interpretación:* Devuelve las mediciones cuyos valores se encuentran en el intervalo inclusivo $[0.70, 0.90]$.

---

## 3. Actividad 18 — Pregunta de Negocio Propia del Equipo

**Pregunta de negocio:**  
¿Qué fuentes de datos aportan más de un millón de filas en total y cuántos datasets componen cada una?

**Justificación:**  
El volumen acumulado condiciona la capacidad de almacenamiento y los tiempos de procesamiento. Identificar fuentes masivas permite anticipar necesidades de infraestructura y priorizar la supervisión de la calidad del dato.

**Tablas utilizadas:** `dataset`

```sql
SELECT fuente,
       COUNT(*)           AS datasets,
       SUM(tamanio_filas) AS filas_totales
FROM dataset
GROUP BY fuente
HAVING SUM(tamanio_filas) > 1000000
ORDER BY filas_totales DESC;
```
**Interpretación:** Identifica los orígenes cuyo total acumulado de filas supera $1,000,000$. La agregación `SUM` excluye automáticamente los registros con valores `NULL` en la columna `tamanio_filas`.

---

## 4. Estado de Preguntas de Negocio al Cierre del Hito 3 (Semana 9)

| # | Pregunta de negocio | Estado | Consulta / Evidencia | Observación |
|---|---------------------|--------|----------------------|-------------|
| **1** | ¿Qué proyectos tienen experimentos? | ✅ Resuelta | Ej. 1 y Ej. 17 | `INNER JOIN` proyecto–experimento |
| **2** | ¿Qué científicos han ejecutado experimentos recientemente? | ✅ Resuelta | Ej. 2 y consulta H3-B | Filtro `fecha_ejecucion >= '20260101'` |
| **3** | ¿Qué datasets nunca se han usado? | ✅ Resuelta | Ej. 13, Ej. 20 y vista `vista_datasets_sin_uso` | `LEFT JOIN … IS NULL` y `NOT IN` |
| **4** | ¿Cuáles son los modelos con mejor desempeño? | ✅ Resuelta | Ej. 11 y Ej. 16 | Ranking de *accuracy* y métricas sobre el promedio |
| **5** | ¿Qué proyectos no tienen modelos? | ⏳ Pendiente | Ej. 6 y Ej. 18 (parcial) | Requiere proyecto → experimento → modelo (3 tablas) |
| **6** | ¿Qué datasets son más grandes que el promedio? | ✅ Resuelta | Ej. 14 | Subconsulta escalar con `AVG` |
| **7** | ¿Qué científicos tienen más métricas registradas? | ⏳ Pendiente | — | Requiere científico → experimento → modelo → métrica (4 tablas) |

**Balance del Hito 3:** 5 de 7 preguntas resueltas; las 2 pendientes quedan programadas para la fase de consultas complejas multitabla.