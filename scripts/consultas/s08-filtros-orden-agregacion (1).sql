-- =====================================================
-- SEMANA 8 - DML, FILTROS, ORDEN Y AGREGACIONES
-- DataLab
-- ==============================================

USE datalab;
GO

-- =====================================================
-- 0. PREPARACION (idempotente: no falla si ya existe)
-- =====================================================
IF COL_LENGTH('experimento', 'estado') IS NULL
    ALTER TABLE experimento ADD estado VARCHAR(20) NULL;
GO
IF COL_LENGTH('dataset', 'notas') IS NULL
    ALTER TABLE dataset ADD notas NVARCHAR(MAX) NULL;
GO

-- Vista rapida del contenido actual (para saber con que datos trabajas)
SELECT 'cientifico_datos' AS tabla, COUNT(*) AS filas FROM cientifico_datos
UNION ALL SELECT 'proyecto',     COUNT(*) FROM proyecto
UNION ALL SELECT 'dataset',      COUNT(*) FROM dataset
UNION ALL SELECT 'experimento',  COUNT(*) FROM experimento
UNION ALL SELECT 'modelo',       COUNT(*) FROM modelo
UNION ALL SELECT 'metrica',      COUNT(*) FROM metrica
UNION ALL SELECT 'participacion',COUNT(*) FROM participacion
UNION ALL SELECT 'uso_dataset',  COUNT(*) FROM uso_dataset;
GO

-- =====================================================
-- 1. SELECT BASICO  (Actividad 1 - SELECT)
-- =====================================================
SELECT nombre_proyecto, descripcion
FROM proyecto;

-- Todas las columnas (solo para explorar; en consultas reales, listar columnas)
SELECT * FROM proyecto;
GO

-- =====================================================
-- 2. OPERADORES DE COMPARACION  (Actividades 3 y 6)
-- =====================================================
-- =  : proyecto con un nombre exacto
SELECT * FROM proyecto
WHERE nombre_proyecto = 'Proyecto IA';

-- <> : metricas con valor distinto de cero
SELECT * FROM metrica
WHERE valor <> 0;

-- >  : metricas mayores a 0.80
SELECT * FROM metrica
WHERE valor > 0.80;

-- <  : metricas menores a 0.50
SELECT * FROM metrica
WHERE valor < 0.50;

-- >= : metricas con valor de al menos 0.80
SELECT * FROM metrica
WHERE valor >= 0.80;

-- <= : metricas menores o iguales a 0.50   (Actividad 6.3)
SELECT * FROM metrica
WHERE valor <= 0.50;

-- Fecha: datasets cargados desde el 1 de enero de 2026
SELECT nombre, fecha_carga
FROM dataset
WHERE fecha_carga >= '2026-01-01';
GO

-- =====================================================
-- 3. BETWEEN  (Actividades 3, 5c, 6.4 y Pregunta de negocio 8)
-- =====================================================
-- Incluye ambos limites: 0.70 <= valor <= 0.90
SELECT *
FROM metrica
WHERE valor BETWEEN 0.70 AND 0.90;

-- Equivalente con AND (para comprobar que da el mismo resultado)
SELECT *
FROM metrica
WHERE valor >= 0.70 AND valor <= 0.90;
GO

-- =====================================================
-- 4. IN / NOT IN  (Actividades 3, 6.5, 7 y Pregunta de negocio 6)
-- =====================================================
-- Consulta A -> con OR
SELECT * FROM experimento
WHERE estado = 'planificado'
   OR estado = 'en_ejecucion'
   OR estado = 'exitoso';

-- Consulta B -> con IN (mismo resultado, mas legible)
SELECT * FROM experimento
WHERE estado IN ('planificado', 'en_ejecucion', 'exitoso');

-- Consulta C -> con NOT IN (excluye los estados indicados)
-- OJO: las filas con estado NULL NO aparecen con NOT IN
SELECT * FROM experimento
WHERE estado NOT IN ('fallido', 'exitoso');
GO

-- =====================================================
-- 5. LIKE  (Actividades 3, 6.6 y 8)
-- =====================================================
-- 8.1 Comienza por EEG
SELECT * FROM dataset WHERE nombre LIKE 'EEG%';

-- 8.2 Termina en una palabra elegida (ej. 'Clinicos')
SELECT * FROM dataset WHERE nombre LIKE '%Clinicos';

-- 8.3 Contiene una palabra (ej. 'Ventas')
SELECT * FROM dataset WHERE nombre LIKE '%Ventas%';

-- 8.4 Patron con "_" (exactamente UN caracter cualquiera)
--     a) un caracter + 'EG' + lo que sea
SELECT * FROM dataset WHERE nombre LIKE '_EG%';
--     b) 'EEG' seguido de al menos un caracter mas
SELECT * FROM dataset WHERE nombre LIKE 'EEG_%';
--     c) nombres de EXACTAMENTE 6 caracteres
SELECT nombre, LEN(nombre) AS longitud
FROM dataset
WHERE nombre LIKE '______';
-- Nota: en SQL Server y MySQL la sensibilidad a mayusculas depende de la
-- collation. Con las collation por defecto ambos son case-insensitive.
GO

-- =====================================================
-- 6. IS NULL / IS NOT NULL  (Actividades 3, 4, 6.7, 6.8, 20 y PN 7)
-- =====================================================
-- INCORRECTO (nunca devuelve filas: NULL = NULL no es verdadero)
SELECT * FROM dataset WHERE notas = NULL;

-- CORRECTO: datasets SIN notas
SELECT * FROM dataset WHERE notas IS NULL;

-- CORRECTO: datasets CON notas
SELECT * FROM dataset WHERE notas IS NOT NULL;

-- COUNT(*) vs COUNT(columna): la segunda ignora los NULL
SELECT COUNT(*) AS total_datasets,
       COUNT(notas) AS datasets_con_notas
FROM dataset;
GO

-- =====================================================
-- 7. AND / OR / NOT  (Actividad 5)
-- =====================================================
-- 5a) Experimentos exitosos
SELECT * FROM experimento WHERE estado = 'exitoso';

-- 5b) Experimentos exitosos o fallidos
SELECT * FROM experimento
WHERE estado = 'exitoso' OR estado = 'fallido';

-- 5c) Metricas entre 0.70 y 0.90
SELECT * FROM metrica
WHERE valor >= 0.70 AND valor <= 0.90;

-- 5d) Experimentos cuyo estado NO es fallido
SELECT * FROM experimento WHERE NOT estado = 'fallido';
-- (equivalente) SELECT * FROM experimento WHERE estado <> 'fallido';

-- 5e) AND + OR con parentesis:
--     (exitoso O fallido) Y que pertenezcan a un proyecto con id > 1
SELECT * FROM experimento
WHERE (estado = 'exitoso' OR estado = 'fallido')
  AND id_proyecto > 1;

-- Sin parentesis cambia el significado (AND se evalua antes que OR):
--   estado = 'exitoso'  OR  (estado = 'fallido' AND id_proyecto > 1)
SELECT * FROM experimento
WHERE estado = 'exitoso' OR estado = 'fallido' AND id_proyecto > 1;
GO

-- =====================================================
-- 8. ORDER BY  (Actividad 9)
-- =====================================================
-- 9a) Nombre ascendente
SELECT nombre, fecha_carga, tamanio_filas
FROM dataset
ORDER BY nombre ASC;

-- 9b) Fecha de carga descendente (mas recientes primero)
SELECT nombre, fecha_carga, tamanio_filas
FROM dataset
ORDER BY fecha_carga DESC;

-- 9c) Fuente ascendente y, en empate, fecha de carga descendente
SELECT nombre, fuente, fecha_carga, tamanio_filas
FROM dataset
ORDER BY fuente ASC, fecha_carga DESC;
GO

-- =====================================================
-- 9. FUNCIONES DE AGREGACION  (Actividades 10 y 11)
-- =====================================================
-- Actividad 10: COUNT
SELECT COUNT(*) AS total_datasets     FROM dataset;
SELECT COUNT(*) AS total_experimentos FROM experimento;
SELECT COUNT(*) AS total_modelos      FROM modelo;
SELECT COUNT(*) AS total_metricas     FROM metrica;

-- Los cuatro conteos en un solo resultado
SELECT
    (SELECT COUNT(*) FROM dataset)     AS datasets,
    (SELECT COUNT(*) FROM experimento) AS experimentos,
    (SELECT COUNT(*) FROM modelo)      AS modelos,
    (SELECT COUNT(*) FROM metrica)     AS metricas;

-- SUM (aplicable: total de filas procesadas por todos los datasets)
SELECT SUM(tamanio_filas) AS filas_totales
FROM dataset;

-- Actividad 11: AVG, MIN, MAX sobre toda la tabla metrica
SELECT AVG(valor) AS promedio,
       MIN(valor) AS minimo,
       MAX(valor) AS maximo
FROM metrica;

-- Actividad 11 (segunda parte): agrupado por nombre_metrica
SELECT nombre_metrica,
       AVG(valor) AS promedio,
       MIN(valor) AS minimo,
       MAX(valor) AS maximo
FROM metrica
GROUP BY nombre_metrica;
GO

-- =====================================================
-- 10. GROUP BY  (Actividad 12)
-- =====================================================
-- 12a) Datasets por fuente
SELECT fuente, COUNT(*) AS cantidad
FROM dataset
GROUP BY fuente;

-- 12b) Experimentos por estado
SELECT estado, COUNT(*) AS cantidad
FROM experimento
GROUP BY estado;

-- 12c) Metricas por tipo de metrica
SELECT nombre_metrica, COUNT(*) AS cantidad
FROM metrica
GROUP BY nombre_metrica;
GO

-- =====================================================
-- 11. HAVING  (Actividad 13 y Pregunta de negocio 4)
-- =====================================================
-- Tipos de metrica con promedio > 0.8
SELECT nombre_metrica, AVG(valor) AS promedio
FROM metrica
GROUP BY nombre_metrica
HAVING AVG(valor) > 0.8;

-- ERROR (no ejecutar): las agregaciones no se permiten en WHERE
--   SELECT nombre_metrica, AVG(valor) FROM metrica
--   WHERE AVG(valor) > 0.8 GROUP BY nombre_metrica;
-- SQL Server responde: "An aggregate may not appear in the WHERE clause..."

-- WHERE + GROUP BY + HAVING + ORDER BY juntos
SELECT nombre_metrica, AVG(valor) AS promedio
FROM metrica
WHERE valor IS NOT NULL            -- 1) filtra FILAS
GROUP BY nombre_metrica            -- 2) forma GRUPOS
HAVING AVG(valor) > 0.8            -- 3) filtra GRUPOS
ORDER BY promedio DESC;            -- 4) ordena (aqui SI se puede usar el alias)
GO

-- =====================================================
-- 12. UPDATE SEGURO  (Actividad 14)
-- =====================================================
-- Paso 1: SELECT para identificar el registro (guardar el valor inicial)
SELECT id_dataset, nombre, notas
FROM dataset
WHERE id_dataset = 1;

-- Paso 2: UPDATE con WHERE por clave primaria
UPDATE dataset
SET notas = 'Correccion realizada en Semana 8'
WHERE id_dataset = 1;
-- SSMS informa "(1 row affected)": si dice otro numero, algo esta mal.

-- Paso 3: SELECT de verificacion
SELECT id_dataset, nombre, notas
FROM dataset
WHERE id_dataset = 1;

-- UPDATE de varias columnas (opcional, mismo patron)
-- SELECT * FROM dataset WHERE id_dataset = 2;
-- UPDATE dataset
-- SET nombre = 'Dataset actualizado',
--     notas  = 'Correccion realizada en Semana 8'
-- WHERE id_dataset = 2;
-- SELECT * FROM dataset WHERE id_dataset = 2;

-- UPDATE de estado de un experimento (patron de la guia)
-- SELECT * FROM experimento WHERE id_experimento = 1;
-- UPDATE experimento SET estado = 'exitoso' WHERE id_experimento = 1;
-- SELECT * FROM experimento WHERE id_experimento = 1;
GO

-- =====================================================
-- 13. DELETE SEGURO  (Actividad 15)
-- =====================================================
-- Paso 0: insertar una fila claramente identificable
INSERT INTO proyecto (nombre_proyecto, descripcion)
VALUES ('FILA_DE_PRUEBA_BORRAR', 'Registro creado para practicar DELETE');

-- Paso 1: comprobar que existe (y que es UNA sola fila)
SELECT * FROM proyecto
WHERE nombre_proyecto = 'FILA_DE_PRUEBA_BORRAR';

-- Paso 2: eliminarla (no tiene experimentos hijos, asi que el CASCADE no afecta nada)
DELETE FROM proyecto
WHERE nombre_proyecto = 'FILA_DE_PRUEBA_BORRAR';

-- Paso 3: comprobar que ya no existe (debe devolver 0 filas)
SELECT * FROM proyecto
WHERE nombre_proyecto = 'FILA_DE_PRUEBA_BORRAR';
GO

-- =====================================================
-- 14. PREGUNTAS DE NEGOCIO  (Actividades 16, 17 y 18)
-- =====================================================
-- PN1: Cuantos datasets existen por fuente?
SELECT fuente, COUNT(*) AS cantidad
FROM dataset
GROUP BY fuente;

-- PN2: Cuantos experimentos hay en cada estado?
SELECT estado, COUNT(*) AS cantidad
FROM experimento
GROUP BY estado;

-- PN3: Promedio de cada tipo de metrica
SELECT nombre_metrica, AVG(valor) AS promedio
FROM metrica
GROUP BY nombre_metrica;

-- PN4: Tipos de metrica con promedio superior a 0.8
SELECT nombre_metrica, AVG(valor) AS promedio
FROM metrica
GROUP BY nombre_metrica
HAVING AVG(valor) > 0.8;

-- PN5: Dataset mas reciente de cada fuente
-- LIMITACION: la solucion completa (nombre + fecha de CADA fuente en una
-- sola consulta) requiere subconsultas, JOIN o funciones de ventana
-- (ROW_NUMBER), que aun no se estudian. Aproximaciones con lo visto:
--   (a) Solo la FECHA mas reciente por fuente (agregacion):
SELECT fuente, MAX(fecha_carga) AS fecha_mas_reciente
FROM dataset
GROUP BY fuente;
--   (b) Nombre y fecha, una fuente por consulta (filtro + orden):
SELECT TOP 1 nombre, fuente, fecha_carga
FROM dataset
WHERE fuente = 'interna'
ORDER BY fecha_carga DESC;

SELECT TOP 1 nombre, fuente, fecha_carga
FROM dataset
WHERE fuente = 'externa'
ORDER BY fecha_carga DESC;
-- Limite de (b): hay que repetir la consulta por cada fuente y si aparece
-- una fuente nueva hay que escribir otra. Empates en fecha: TOP 1 devuelve uno solo.

-- PN6: Experimentos con estado exitoso o fallido (IN)
SELECT id_experimento, id_proyecto, estado
FROM experimento
WHERE estado IN ('exitoso', 'fallido');

-- PN7: Datasets con informacion en notas (IS NOT NULL)
SELECT id_dataset, nombre, notas
FROM dataset
WHERE notas IS NOT NULL;

-- PN8: Metricas con valores entre 0.70 y 0.90 (BETWEEN)
SELECT id_metrica, nombre_metrica, valor
FROM metrica
WHERE valor BETWEEN 0.70 AND 0.90;

-- Actividad 18 - Pregunta propia:
-- "Que fuentes de datos aportan mas de 1 millon de filas en total?"
-- (GROUP BY + SUM + HAVING + ORDER BY)
SELECT fuente,
       COUNT(*)           AS datasets,
       SUM(tamanio_filas) AS filas_totales
FROM dataset
GROUP BY fuente
HAVING SUM(tamanio_filas) > 1000000
ORDER BY filas_totales DESC;
GO

-- =====================================================
-- 15. COMPARACION SQL SERVER / MySQL  (Actividad 21)
-- =====================================================
-- SQL Server: TOP va ANTES de las columnas, dentro del SELECT
SELECT TOP 5 *
FROM dataset
ORDER BY fecha_carga DESC;
GO
