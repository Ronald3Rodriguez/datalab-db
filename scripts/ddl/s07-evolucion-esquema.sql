/*
    DataLab
    Semana 7
    Evolución del esquema

    ALTER TABLE
    Restricciones
    UPDATE
    DROP de prueba

    SGBD:   SQL Server (SSMS)
    Base:   datalab
    Fecha:  2026-10-07
    Autor:  Ronald Rodriguez

    Notas:
    - Script incremental: NO reconstruye ninguna de las ocho tablas reales.
    - Cada bloque está separado por GO porque SQL Server compila el lote
      completo antes de ejecutarlo; una columna recién creada no puede
      usarse en el mismo lote en el que se crea.
    - Los bloques son re-ejecutables (usan IF para no fallar si el cambio
      ya fue aplicado).
    - DROP se practica ÚNICAMENTE sobre tabla_prueba_drop.
*/

USE datalab;
GO

-- ==========================================
-- 0. ESTADO INICIAL (evidencia "antes")
-- ==========================================
SELECT * FROM experimento;
SELECT * FROM dataset;
GO


-- ==========================================
-- 1. AGREGAR ESTADO
-- ==========================================
-- NOT NULL + DEFAULT + WITH VALUES: las filas existentes reciben
-- 'planificado' en lugar de quedar sin valor.
IF COL_LENGTH('experimento', 'estado') IS NULL
BEGIN
    ALTER TABLE experimento
    ADD estado VARCHAR(20) NOT NULL
        CONSTRAINT df_experimento_estado
        DEFAULT 'planificado'
        WITH VALUES;
END
GO

SELECT id_experimento, estado
FROM experimento;
GO


-- ==========================================
-- 2. AGREGAR CHECK
-- ==========================================
-- Paso previo: detectar valores que violarían la regla (debe devolver 0 filas).
SELECT id_experimento, estado
FROM experimento
WHERE estado NOT IN ('planificado', 'en_ejecucion', 'exitoso', 'fallido');
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'chk_experimento_estado'
)
BEGIN
    ALTER TABLE experimento
    ADD CONSTRAINT chk_experimento_estado
    CHECK (
        estado IN (
            'planificado',
            'en_ejecucion',
            'exitoso',
            'fallido'
        )
    );
END
GO

-- Prueba del CHECK: debe FALLAR (error 547). Se deja comentada para que el
-- script completo se pueda ejecutar de corrido; descomentar para la evidencia.
-- UPDATE experimento
-- SET estado = 'terminado'
-- WHERE id_experimento = 1;
GO


-- ==========================================
-- 3. AGREGAR NOTAS
-- ==========================================
IF COL_LENGTH('dataset', 'notas') IS NULL
BEGIN
    ALTER TABLE dataset
    ADD notas VARCHAR(MAX) NULL;
END
GO

SELECT id_dataset, nombre, notas
FROM dataset;
GO


-- ==========================================
-- 4. ACTUALIZAR ESTADOS
-- ==========================================
-- WHERE es obligatorio: sin él, TODOS los experimentos quedarían 'exitoso'.
UPDATE experimento
SET estado = 'exitoso'
WHERE id_experimento = 1;
GO

SELECT id_experimento, estado
FROM experimento
WHERE id_experimento = 1;
GO


-- ==========================================
-- 5. RESTRICCIÓN ADICIONAL
-- ==========================================
-- UNIQUE (nombre) en proyecto. Primero se buscan duplicados (reto 25).
-- Si en tu tabla la columna se llama nombre_proyecto, cambia el nombre
-- en las tres sentencias de este bloque.
SELECT nombre, COUNT(*) AS cantidad
FROM proyecto
GROUP BY nombre
HAVING COUNT(*) > 1;
GO

IF EXISTS (
    SELECT 1 FROM proyecto GROUP BY nombre HAVING COUNT(*) > 1
)
    PRINT 'Hay nombres duplicados en proyecto: corregirlos con UPDATE antes de agregar UNIQUE.';
ELSE IF NOT EXISTS (
    SELECT 1 FROM sys.key_constraints WHERE name = 'uq_proyecto_nombre'
)
BEGIN
    ALTER TABLE proyecto
    ADD CONSTRAINT uq_proyecto_nombre
    UNIQUE (nombre);
END
GO


-- ==========================================
-- 6. MODIFICACIÓN DE COLUMNA
-- ==========================================
-- Ampliar dataset.nombre a VARCHAR(200). Se asume tamaño actual VARCHAR(100)
-- NOT NULL; se debe repetir NOT NULL, de lo contrario la columna pasaría
-- a aceptar NULL. Antes de ejecutar, confirmar el tamaño real:
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dataset' AND COLUMN_NAME = 'nombre';
GO

IF (SELECT CHARACTER_MAXIMUM_LENGTH
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'dataset' AND COLUMN_NAME = 'nombre') < 200
BEGIN
    ALTER TABLE dataset
    ALTER COLUMN nombre VARCHAR(200) NOT NULL;
END
GO

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dataset' AND COLUMN_NAME = 'nombre';
GO


-- ==========================================
-- 7. PRUEBA DROP
-- ==========================================
-- Todo lo destructivo ocurre solo sobre tabla_prueba_drop.

IF OBJECT_ID('tabla_prueba_drop', 'U') IS NOT NULL
    DROP TABLE tabla_prueba_drop;
GO

CREATE TABLE tabla_prueba_drop (
    id   INT PRIMARY KEY,
    dato VARCHAR(50)
);
GO

INSERT INTO tabla_prueba_drop
VALUES (1, 'prueba');
GO

SELECT * FROM tabla_prueba_drop;
GO

-- 7.1 Renombrar columna (equivalente SQL Server de CHANGE COLUMN de MySQL).
-- Se practica sobre la tabla de prueba, no sobre una tabla real.
EXEC sp_rename
    'tabla_prueba_drop.dato',
    'dato_renombrado',
    'COLUMN';
GO

SELECT * FROM tabla_prueba_drop;
GO

-- 7.2 DROP COLUMN: elimina solo la columna.
ALTER TABLE tabla_prueba_drop
DROP COLUMN dato_renombrado;
GO

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tabla_prueba_drop';
GO

-- 7.3 DROP TABLE: elimina la tabla completa.
DROP TABLE tabla_prueba_drop;
GO

-- Debe FALLAR: "Invalid object name 'tabla_prueba_drop'" (error 208).
-- Descomentar solo para capturar la evidencia.
-- SELECT * FROM tabla_prueba_drop;
GO


-- ==========================================
-- 8. VERIFICACIÓN FINAL
-- ==========================================
-- Las ocho tablas reales siguen existiendo.
SELECT name
FROM sys.tables
WHERE name IN ('cientifico_datos','proyecto','dataset','experimento',
               'modelo','metrica','participacion','uso_dataset')
ORDER BY name;   -- debe devolver 8 filas
GO

-- Restricciones creadas en esta semana.
SELECT name, type_desc
FROM sys.objects
WHERE name IN ('df_experimento_estado','chk_experimento_estado','uq_proyecto_nombre');
GO
