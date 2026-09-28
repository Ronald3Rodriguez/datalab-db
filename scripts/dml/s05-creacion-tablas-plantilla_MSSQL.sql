-- =========================================================
-- DataLab — Script de creación de tablas (DDL) — PLANTILLA DE TRABAJO
-- Semana 5 — Hito 2
-- Motor: SQL Server 2019+ (las FOREIGN KEY se validan con el motor relacional)
--
-- Instrucciones: las primeras 3 tablas ya están resueltas como ejemplo,
-- porque no tienen dependencias (no llevan FOREIGN KEY). Completen las
-- 5 tablas restantes siguiendo el mismo patrón y respetando el orden
-- de dependencias explicado en la guía. Reemplacen cada bloque "-- TODO"
-- por la sentencia CREATE TABLE completa.
--
-- Recuerden que en SQL Server:
--   * El autoincremental se escribe  IDENTITY(1,1)
--   * Los textos usan NVARCHAR (y NVARCHAR(MAX) para textos largos)
--   * Cada lote de sentencias se separa con la palabra GO
-- =========================================================

-- Crear la base de datos si no existe
IF DB_ID('datalab') IS NULL
BEGIN
    CREATE DATABASE datalab;
END;
GO

USE datalab;
GO

-- ---------------------------------------------------------
-- Tablas sin dependencias (resueltas como ejemplo)
-- ---------------------------------------------------------

CREATE TABLE cientifico_datos (
    id_cientifico        INT IDENTITY(1,1) PRIMARY KEY,
    nombre               NVARCHAR(100) NOT NULL,
    correo_institucional NVARCHAR(150) NOT NULL UNIQUE
);
GO

CREATE TABLE proyecto (
    id_proyecto     INT IDENTITY(1,1) PRIMARY KEY,
    nombre_proyecto NVARCHAR(150) NOT NULL,
    descripcion     NVARCHAR(MAX)
);
GO

CREATE TABLE dataset (
    id_dataset    INT IDENTITY(1,1) PRIMARY KEY,
    nombre        NVARCHAR(150) NOT NULL,
    fuente        NVARCHAR(20)  NOT NULL,
    fecha_carga   DATE          NOT NULL,
    tamanio_filas INT,
    CONSTRAINT chk_dataset_fuente
        CHECK (fuente IN ('interna','externa')),
    CONSTRAINT chk_dataset_tamanio
        CHECK (tamanio_filas >= 0)
);
GO

-- ---------------------------------------------------------
-- TODO 1 — Tabla experimento
-- Depende de: proyecto, cientifico_datos
-- Columnas: id_experimento (PK, auto), id_proyecto (FK), id_cientifico (FK),
--           fecha_ejecucion (DATE, NOT NULL, DEFAULT hoy), configuracion (texto largo)
-- Política ON DELETE definida en la Semana 4 para cada FK.
-- Pista: para el valor por defecto de hoy usen  DEFAULT (CAST(GETDATE() AS DATE))
-- ---------------------------------------------------------

-- Escriban aquí su CREATE TABLE experimento ...


-- ---------------------------------------------------------
-- TODO 2 — Tabla modelo
-- Depende de: experimento
-- Recuerden: la FK a experimento debe ser UNIQUE (fuerza la cardinalidad 1:1,
-- ver Semana 3).
-- Columnas: id_modelo (PK, auto), id_experimento (FK, UNIQUE), nombre,
--           version, algoritmo.
-- ---------------------------------------------------------

-- Escriban aquí su CREATE TABLE modelo ...


-- ---------------------------------------------------------
-- TODO 3 — Tabla metrica
-- Depende de: modelo
-- Columnas: id_metrica (PK, auto), id_modelo (FK), nombre_metrica, valor
--           (con su CHECK del rango permitido), fecha_calculo.
-- ---------------------------------------------------------

-- Escriban aquí su CREATE TABLE metrica ...


-- ---------------------------------------------------------
-- TODO 4 — Tabla puente participacion
-- Depende de: cientifico_datos, proyecto
-- Llave primaria compuesta por las dos FK.
-- ---------------------------------------------------------

-- Escriban aquí su CREATE TABLE participacion ...


-- ---------------------------------------------------------
-- TODO 5 — Tabla puente uso_dataset
-- Depende de: dataset, experimento
-- Llave primaria compuesta por las dos FK.
-- ---------------------------------------------------------

-- Escriban aquí su CREATE TABLE uso_dataset ...


-- =========================================================
-- Cuando terminen: ejecuten el script completo contra su base `datalab`
-- y verifiquen con la siguiente consulta que las 8 tablas se crearon:
--
--   SELECT name AS tabla FROM sys.tables ORDER BY name;
--
-- Deben aparecer 8 tablas en total.
-- =========================================================