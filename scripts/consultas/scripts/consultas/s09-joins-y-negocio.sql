/* =====================================================================
   DataLab | Bases de Datos 1 | Semana 9 - Cierre del Hito 3
   Archivo : scripts/consultas/s09-joins-y-negocio.sql
   Autor   : Ronald Rodriguez
   Motor   : SQL Server (SSMS)  |  Base de datos: datalab
   Tema    : Consultas multitabla, subconsultas y preguntas de negocio

   REGLA DE LA ACTIVIDAD
   Cada consulta usa como MAXIMO dos tablas, contando las tablas
   que aparecen dentro de subconsultas.

   ESQUEMA REAL (s08-creacion-tablas-solucion_MSSQL.sql)
     proyecto        (id_proyecto, nombre_proyecto, descripcion)
     cientifico_datos(id_cientifico, nombre, correo_institucional)
     experimento     (id_experimento, id_proyecto, id_cientifico, fecha_ejecucion, configuracion)
     modelo          (id_modelo, id_experimento [UNIQUE], nombre, version, algoritmo)
     metrica         (id_metrica, id_modelo, nombre_metrica, valor, fecha_calculo)
     dataset         (id_dataset, nombre, fuente, fecha_carga, tamanio_filas)
     uso_dataset     (id_dataset, id_experimento)  -- PK compuesta
     Datos: semilla de la Semana 8 (s08-datos-semilla.sql).
   ===================================================================== */

USE datalab;
GO

/* ---------------------------------------------------------------------
   0. VERIFICACION DEL ESQUEMA (ejecutar primero, no forma parte de los 20)
   --------------------------------------------------------------------- */
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('proyecto','cientifico_datos','experimento','modelo',
                     'metrica','dataset','uso_dataset')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO

/* =====================================================================
   NIVEL 1 - INNER JOIN
   ===================================================================== */

-- Ejercicio 1. Proyecto y experimento
-- Pregunta: ¿que experimentos tiene cada proyecto?
SELECT p.nombre_proyecto,
       e.id_experimento,
       e.fecha_ejecucion
FROM dbo.proyecto AS p
INNER JOIN dbo.experimento AS e
    ON e.id_proyecto = p.id_proyecto;

-- Ejercicio 2. Cientifico y experimento
-- Pregunta: ¿que cientifico ejecuto cada experimento y cuando?
SELECT c.nombre AS nombre_cientifico,
       e.fecha_ejecucion
FROM dbo.cientifico_datos AS c
INNER JOIN dbo.experimento AS e
    ON e.id_cientifico = c.id_cientifico;

-- Ejercicio 3. Modelo y experimento
-- Pregunta: ¿a que experimento pertenece cada modelo?
SELECT m.nombre AS nombre_modelo,
       m.algoritmo,
       e.id_experimento
FROM dbo.modelo AS m
INNER JOIN dbo.experimento AS e
    ON e.id_experimento = m.id_experimento;

-- Ejercicio 4. Metricas de modelos
-- Pregunta: ¿que metricas y valores tiene cada modelo?
SELECT m.nombre AS nombre_modelo,
       met.nombre_metrica,
       met.valor
FROM dbo.modelo AS m
INNER JOIN dbo.metrica AS met
    ON met.id_modelo = m.id_modelo;

/* =====================================================================
   NIVEL 2 - LEFT JOIN, LEFT JOIN + NULL, RIGHT JOIN
   ===================================================================== */

-- Ejercicio 5. Todos los experimentos (con o sin modelo)
-- Izquierda = experimento (se conserva completa); derecha = modelo
SELECT e.id_experimento,
       m.nombre AS nombre_modelo
FROM dbo.experimento AS e
LEFT JOIN dbo.modelo AS m
    ON m.id_experimento = e.id_experimento;

-- Ejercicio 6. Todos los proyectos, incluso sin experimentos
-- Los proyectos sin experimentos muestran NULL en id_experimento
SELECT p.nombre_proyecto,
       e.id_experimento
FROM dbo.proyecto AS p
LEFT JOIN dbo.experimento AS e
    ON e.id_proyecto = p.id_proyecto;

-- Ejercicio 7. Experimentos sin modelo (anti-join)
-- Pregunta de negocio: ¿que experimentos aun no producen un modelo?
SELECT e.id_experimento,
       e.fecha_ejecucion
FROM dbo.experimento AS e
LEFT JOIN dbo.modelo AS m
    ON m.id_experimento = e.id_experimento
WHERE m.id_modelo IS NULL;

-- Ejercicio 8. RIGHT JOIN - conservar el lado derecho
-- La tabla que se conserva completa es experimento (derecha).
SELECT c.nombre AS nombre_cientifico,
       e.fecha_ejecucion
FROM dbo.cientifico_datos AS c
RIGHT JOIN dbo.experimento AS e
    ON e.id_cientifico = c.id_cientifico;

/* =====================================================================
   NIVEL 3 - Filtros, fechas, ordenamiento y LIKE
   ===================================================================== */

-- Ejercicio 9. Modelos Random Forest (una sola tabla, filtro con WHERE)
SELECT m.nombre,
       m.version,
       m.algoritmo
FROM dbo.modelo AS m
WHERE m.algoritmo = 'Random Forest';

-- Ejercicio 10. Experimentos desde el 1 de enero de 2026
-- Rango directo de fechas (formato ISO yyyymmdd, independiente del idioma)
SELECT p.nombre_proyecto,
       e.fecha_ejecucion
FROM dbo.proyecto AS p
INNER JOIN dbo.experimento AS e
    ON e.id_proyecto = p.id_proyecto
WHERE e.fecha_ejecucion >= '20260101'
ORDER BY e.fecha_ejecucion;

-- Ejercicio 11. Ranking de accuracy (mayor a menor)
-- Pregunta de negocio: ¿cuales son los modelos con mejor desempeño?
SELECT m.nombre AS nombre_modelo,
       met.nombre_metrica,
       met.valor
FROM dbo.modelo AS m
INNER JOIN dbo.metrica AS met
    ON met.id_modelo = m.id_modelo
WHERE met.nombre_metrica = 'accuracy'
ORDER BY met.valor DESC;

-- Ejercicio 12. Modelos cuya version comienza por 1.2
SELECT m.nombre,
       m.algoritmo
FROM dbo.modelo AS m
WHERE m.version LIKE '1.2%'
ORDER BY m.nombre;

/* =====================================================================
   NIVEL 4 - Subconsultas (NOT IN, escalar, IN)
   ===================================================================== */

-- Ejercicio 13. Datasets nunca utilizados (NOT IN)
-- Tablas: dataset + uso_dataset (2). Precaucion: si uso_dataset.id_dataset
-- admitiera NULL, NOT IN no devolveria filas (ver ejercicio 20).
SELECT d.nombre,
       d.fuente
FROM dbo.dataset AS d
WHERE d.id_dataset NOT IN (
    SELECT u.id_dataset
    FROM dbo.uso_dataset AS u
);

-- Ejercicio 14. Datasets mayores al promedio (subconsulta escalar)
-- La subconsulta devuelve UN valor; AVG ignora los NULL de tamanio_filas.
SELECT d.nombre,
       d.tamanio_filas
FROM dbo.dataset AS d
WHERE d.tamanio_filas > (
    SELECT AVG(d2.tamanio_filas)
    FROM dbo.dataset AS d2
);

-- Ejercicio 15. Modelos de los experimentos del proyecto 10 (IN)
SELECT m.nombre,
       m.algoritmo,
       m.version
FROM dbo.modelo AS m
WHERE m.id_experimento IN (
    SELECT e.id_experimento
    FROM dbo.experimento AS e
    WHERE e.id_proyecto = 10
);

-- Ejercicio 16. Metricas por encima del promedio global (escalar)
SELECT met.id_modelo,
       met.nombre_metrica,
       met.valor
FROM dbo.metrica AS met
WHERE met.valor > (
    SELECT AVG(met2.valor)
    FROM dbo.metrica AS met2
);

/* =====================================================================
   NIVEL 5 - JOIN + agregacion
   ===================================================================== */

-- Ejercicio 17. Experimentos por proyecto (solo proyectos con experimentos)
SELECT p.nombre_proyecto,
       COUNT(e.id_experimento) AS total_experimentos
FROM dbo.proyecto AS p
INNER JOIN dbo.experimento AS e
    ON e.id_proyecto = p.id_proyecto
GROUP BY p.id_proyecto, p.nombre_proyecto
ORDER BY total_experimentos DESC;

-- Ejercicio 18. Conteo por proyecto, incluso cero
-- COUNT(e.id_experimento) cuenta solo valores no NULL => proyectos sin
-- experimentos dan 0. (COUNT(*) devolveria 1 por la fila con NULL).
SELECT p.nombre_proyecto,
       COUNT(e.id_experimento) AS total_experimentos
FROM dbo.proyecto AS p
LEFT JOIN dbo.experimento AS e
    ON e.id_proyecto = p.id_proyecto
GROUP BY p.id_proyecto, p.nombre_proyecto
ORDER BY total_experimentos DESC;

-- Ejercicio 19. Modelos con mas de una metrica
SELECT m.id_modelo,
       COUNT(*) AS total_metricas
FROM dbo.modelo AS m
INNER JOIN dbo.metrica AS met
    ON met.id_modelo = m.id_modelo
GROUP BY m.id_modelo
HAVING COUNT(*) > 1
ORDER BY total_metricas DESC;

/* =====================================================================
   NIVEL 6 - Comparacion de estrategias
   Ejercicio 20. Auditoria de datasets no utilizados
   ===================================================================== */

-- 20-A. LEFT JOIN + IS NULL  (dataset + uso_dataset = 2 tablas)
SELECT d.id_dataset,
       d.nombre,
       d.fuente
FROM dbo.dataset AS d
LEFT JOIN dbo.uso_dataset AS u
    ON u.id_dataset = d.id_dataset
WHERE u.id_dataset IS NULL;

-- 20-B. NOT IN  (dataset + uso_dataset = 2 tablas)
-- El filtro IS NOT NULL protege frente a NULL dentro de la subconsulta.
SELECT d.id_dataset,
       d.nombre,
       d.fuente
FROM dbo.dataset AS d
WHERE d.id_dataset NOT IN (
    SELECT u.id_dataset
    FROM dbo.uso_dataset AS u
    WHERE u.id_dataset IS NOT NULL
);

-- Comprobacion de nulabilidad que justifica la precaucion de NOT IN
SELECT COUNT(*) AS filas_con_id_dataset_nulo
FROM dbo.uso_dataset AS u
WHERE u.id_dataset IS NULL;

/* =====================================================================
   CONSULTAS ADICIONALES PARA CERRAR EL HITO 3
   (preguntas de negocio que SI caben en la regla de dos tablas)
   ===================================================================== */

-- H3-B. ¿Que cientificos han ejecutado experimentos recientemente?
SELECT DISTINCT c.nombre AS nombre_cientifico
FROM dbo.cientifico_datos AS c
INNER JOIN dbo.experimento AS e
    ON e.id_cientifico = c.id_cientifico
WHERE e.fecha_ejecucion >= '20260101';

-- Uso de la vista creada en scripts/ddl/s09-vistas.sql
SELECT v.id_experimento, v.nombre_modelo, v.algoritmo
FROM dbo.vista_modelos_por_experimento AS v
WHERE v.algoritmo = 'Random Forest';
GO
