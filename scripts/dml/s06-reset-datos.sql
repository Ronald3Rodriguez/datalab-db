/*
    DataLab - Reinicio de datos
    SGBD: SQL Server

    Propósito:
    - Eliminar todos los datos de las 8 tablas de DataLab.
    - Respetar las dependencias entre claves foráneas.
    - Reiniciar los contadores IDENTITY para que el siguiente registro
      vuelva a comenzar en 1.

    IMPORTANTE:
    - Este script elimina TODOS los datos de las tablas.
    - No elimina las tablas ni modifica su estructura.
    - Ejecutar después de haber creado las tablas (DDL).
    - Ejecutar antes de s06-datos-semilla.sql cuando se quiera
      reconstruir el conjunto de datos desde cero.
*/

SET NOCOUNT ON;

BEGIN TRY

    BEGIN TRANSACTION;

    PRINT '========================================';
    PRINT 'DataLab - Reinicio de datos';
    PRINT '========================================';

    /* ============================================================
       1. TABLAS HIJAS / TABLAS PUENTE
       ============================================================ */

    PRINT 'Eliminando datos de uso_dataset...';

    DELETE FROM uso_dataset;


    PRINT 'Eliminando datos de participacion...';

    DELETE FROM participacion;


    /* ============================================================
       2. TABLAS DEPENDIENTES
       ============================================================ */

    PRINT 'Eliminando datos de metrica...';

    DELETE FROM metrica;

    DBCC CHECKIDENT ('metrica', RESEED, 0) WITH NO_INFOMSGS;


    PRINT 'Eliminando datos de modelo...';

    DELETE FROM modelo;

    DBCC CHECKIDENT ('modelo', RESEED, 0) WITH NO_INFOMSGS;


    PRINT 'Eliminando datos de experimento...';

    DELETE FROM experimento;

    DBCC CHECKIDENT ('experimento', RESEED, 0) WITH NO_INFOMSGS;


    /* ============================================================
       3. TABLAS PADRE
       ============================================================ */

    PRINT 'Eliminando datos de dataset...';

    DELETE FROM dataset;

    DBCC CHECKIDENT ('dataset', RESEED, 0) WITH NO_INFOMSGS;


    PRINT 'Eliminando datos de proyecto...';

    DELETE FROM proyecto;

    DBCC CHECKIDENT ('proyecto', RESEED, 0) WITH NO_INFOMSGS;


    PRINT 'Eliminando datos de cientifico_datos...';

    DELETE FROM cientifico_datos;

    DBCC CHECKIDENT ('cientifico_datos', RESEED, 0) WITH NO_INFOMSGS;


    /* ============================================================
       4. CONFIRMAR TRANSACCIÓN
       ============================================================ */

    COMMIT TRANSACTION;

    PRINT '========================================';
    PRINT 'Reinicio completado correctamente.';
    PRINT 'Los contadores IDENTITY fueron reiniciados.';
    PRINT '========================================';

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '========================================';
    PRINT 'ERROR: El reinicio fue cancelado.';
    PRINT '========================================';

    THROW;

END CATCH;


/* ================================================================
   5. VERIFICACIÓN
   ================================================================ */

SELECT 'cientifico_datos' AS tabla, COUNT(*) AS registros
FROM cientifico_datos

UNION ALL

SELECT 'proyecto', COUNT(*)
FROM proyecto

UNION ALL

SELECT 'dataset', COUNT(*)
FROM dataset

UNION ALL

SELECT 'experimento', COUNT(*)
FROM experimento

UNION ALL

SELECT 'modelo', COUNT(*)
FROM modelo

UNION ALL

SELECT 'metrica', COUNT(*)
FROM metrica

UNION ALL

SELECT 'participacion', COUNT(*)
FROM participacion

UNION ALL

SELECT 'uso_dataset', COUNT(*)
FROM uso_dataset;
