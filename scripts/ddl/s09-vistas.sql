/* =====================================================================
   DataLab | Bases de Datos 1 | Semana 9 - Vistas
   Archivo : scripts/ddl/s09-vistas.sql
   Autor   : Ronald Rodriguez
   Motor   : SQL Server (SSMS)  |  Base de datos: datalab

   Una vista es una consulta guardada con nombre. Una vista normal NO
   almacena copia de los datos: consulta las tablas subyacentes cada vez.
   Cada CREATE VIEW va en su propio lote (separado por GO).
   CREATE OR ALTER VIEW requiere SQL Server 2016 SP1 o superior; si tu
   version no lo admite, usa DROP VIEW IF EXISTS + CREATE VIEW.
   ===================================================================== */

USE datalab;
GO

/* ---------------------------------------------------------------------
   Vista 1. Modelos por experimento
   Negocio : ¿que modelos produjo cada experimento?
   Tablas  : experimento + modelo (2)
   --------------------------------------------------------------------- */
CREATE OR ALTER VIEW dbo.vista_modelos_por_experimento AS
SELECT e.id_experimento,
       e.fecha_ejecucion,
       m.nombre AS nombre_modelo,
       m.algoritmo,
       m.version
FROM dbo.experimento AS e
INNER JOIN dbo.modelo AS m
    ON m.id_experimento = e.id_experimento;
GO

/* ---------------------------------------------------------------------
   Vista 2. Resumen de experimentos por proyecto (incluye proyectos en 0)
   Negocio : ¿cuanta actividad experimental tiene cada proyecto?
   Tablas  : proyecto + experimento (2)
   --------------------------------------------------------------------- */
CREATE OR ALTER VIEW dbo.vista_resumen_proyecto AS
SELECT p.id_proyecto,
       p.nombre_proyecto,
       COUNT(e.id_experimento) AS total_experimentos
FROM dbo.proyecto AS p
LEFT JOIN dbo.experimento AS e
    ON e.id_proyecto = p.id_proyecto
GROUP BY p.id_proyecto, p.nombre_proyecto;
GO

/* ---------------------------------------------------------------------
   Vista 3. Datasets sin uso (auditoria)
   Negocio : ¿que datasets nunca se han usado?
   Tablas  : dataset + uso_dataset (2)
   --------------------------------------------------------------------- */
CREATE OR ALTER VIEW dbo.vista_datasets_sin_uso AS
SELECT d.id_dataset,
       d.nombre,
       d.fuente,
       d.tamanio_filas
FROM dbo.dataset AS d
LEFT JOIN dbo.uso_dataset AS u
    ON u.id_dataset = d.id_dataset
WHERE u.id_dataset IS NULL;
GO

/* ---------------------------------------------------------------------
   PRUEBAS: consultar cada vista
   --------------------------------------------------------------------- */
-- Vista 1: solo modelos Random Forest
SELECT v.id_experimento, v.nombre_modelo, v.algoritmo
FROM dbo.vista_modelos_por_experimento AS v
WHERE v.algoritmo = 'Random Forest';

-- Vista 2: proyectos ordenados por actividad
SELECT v.nombre_proyecto, v.total_experimentos
FROM dbo.vista_resumen_proyecto AS v
ORDER BY v.total_experimentos DESC;

-- Vista 3: datasets que nadie ha usado
SELECT v.nombre, v.fuente
FROM dbo.vista_datasets_sin_uso AS v;
GO

/* Consultar la definicion guardada de una vista (documentacion) */
SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.vista_modelos_por_experimento')) AS definicion;
GO
