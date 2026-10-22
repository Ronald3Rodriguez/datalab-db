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
CREATE TABLE experimento (
    id_experimento  INT IDENTITY(1,1) PRIMARY KEY,
    id_proyecto     INT  NOT NULL,
    id_cientifico   INT  NOT NULL,
    fecha_ejecucion DATE NOT NULL
        CONSTRAINT df_experimento_fecha DEFAULT (CAST(GETDATE() AS DATE)),
    configuracion   NVARCHAR(MAX),
    CONSTRAINT fk_experimento_proyecto
        FOREIGN KEY (id_proyecto) REFERENCES proyecto(id_proyecto)
        ON DELETE NO ACTION,
    CONSTRAINT fk_experimento_cientifico
        FOREIGN KEY (id_cientifico) REFERENCES cientifico_datos(id_cientifico)
        ON DELETE NO ACTION
);
GO


-- ---------------------------------------------------------
-- TODO 2 — Tabla modelo
-- Depende de: experimento
-- Recuerden: la FK a experimento debe ser UNIQUE (fuerza la cardinalidad 1:1,
-- ver Semana 3).
-- Columnas: id_modelo (PK, auto), id_experimento (FK, UNIQUE), nombre,
--           version, algoritmo.
-- ---------------------------------------------------------

-- Escriban aquí su CREATE TABLE modelo ...
CREATE TABLE modelo (
    id_modelo       INT IDENTITY(1,1) PRIMARY KEY,
    id_experimento  INT NOT NULL UNIQUE,
    nombre          NVARCHAR(150) NOT NULL,
    version         NVARCHAR(50)  NOT NULL,
    algoritmo       NVARCHAR(100) NOT NULL,
    CONSTRAINT fk_modelo_experimento
        FOREIGN KEY (id_experimento) REFERENCES experimento(id_experimento)
        ON DELETE CASCADE
);
GO


-- ---------------------------------------------------------
-- TODO 3 — Tabla metrica
-- Depende de: modelo
-- Columnas: id_metrica (PK, auto), id_modelo (FK), nombre_metrica, valor
--           (con su CHECK del rango permitido), fecha_calculo.
-- ---------------------------------------------------------

-- Escriban aquí su CREATE TABLE metrica ...
CREATE TABLE metrica (
    id_metrica      INT IDENTITY(1,1)
        CONSTRAINT pk_metrica PRIMARY KEY,
    id_modelo       INT           NOT NULL,
    nombre_metrica  NVARCHAR(100) NOT NULL,
    valor           DECIMAL(10,4) NOT NULL,
    fecha_calculo   DATE          NOT NULL,
    CONSTRAINT chk_metrica_valor
        CHECK (valor >= 0 AND valor <= 1),
    CONSTRAINT fk_metrica_modelo
        FOREIGN KEY (id_modelo) REFERENCES modelo(id_modelo)
        ON DELETE CASCADE
);
GO



-- ---------------------------------------------------------
-- TODO 4 — Tabla puente participacion
-- Depende de: cientifico_datos, proyecto
-- Llave primaria compuesta por las dos FK.
-- ---------------------------------------------------------

-- Escriban aquí su CREATE TABLE participacion ...
CREATE TABLE participacion (
    id_cientifico INT NOT NULL,
    id_proyecto   INT NOT NULL,
    CONSTRAINT pk_participacion
        PRIMARY KEY (id_cientifico, id_proyecto),
    CONSTRAINT fk_participacion_cientifico
        FOREIGN KEY (id_cientifico) REFERENCES cientifico_datos(id_cientifico)
        ON DELETE CASCADE,
    CONSTRAINT fk_participacion_proyecto
        FOREIGN KEY (id_proyecto) REFERENCES proyecto(id_proyecto)
        ON DELETE CASCADE
);
GO



-- ---------------------------------------------------------
-- TODO 5 — Tabla puente uso_dataset
-- Depende de: dataset, experimento
-- Llave primaria compuesta por las dos FK.
-- ---------------------------------------------------------

-- Escriban aquí su CREATE TABLE uso_dataset ...
CREATE TABLE uso_dataset (
    id_dataset     INT NOT NULL,
    id_experimento INT NOT NULL,
    CONSTRAINT pk_uso_dataset
        PRIMARY KEY (id_dataset, id_experimento),
    CONSTRAINT fk_uso_dataset_dataset
        FOREIGN KEY (id_dataset) REFERENCES dataset(id_dataset)
        ON DELETE CASCADE,
    CONSTRAINT fk_uso_dataset_experimento
        FOREIGN KEY (id_experimento) REFERENCES experimento(id_experimento)
        ON DELETE CASCADE
);
GO


-- =========================================================
-- Cuando terminen: ejecuten el script completo contra su base `datalab`
-- y verifiquen con la siguiente consulta que las 8 tablas se crearon:
--
--   SELECT name AS tabla FROM sys.tables ORDER BY name;
--
-- Deben aparecer 8 tablas en total.

-- =========================================================