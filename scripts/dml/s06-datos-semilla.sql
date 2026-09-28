/*
    DataLab — Datos semilla
    Semana 6 — Bases de Datos
    SGBD: SQL Server
    Herramienta: SQL Server Management Studio (SSMS)

    Propósito:
    - Cargar datos de prueba para las 8 tablas de DataLab.
    - Permitir practicar SELECT, DISTINCT, ORDER BY y TOP.
    - Dejar datos suficientes para las consultas multitabla de semanas posteriores.

    Supuesto:
    La estructura de las tablas ya fue creada mediante el DDL de la Semana 5.
    Se utilizan los nombres de tablas y columnas definidos para DataLab.
*/

USE datalab;
GO

SET NOCOUNT ON;
GO

/* ============================================================
   1. LIMPIEZA OPCIONAL
   ============================================================
   Descomentar este bloque SOLO si se desea reiniciar la base
   de datos de práctica.
*/

-- DELETE FROM metrica;
-- DELETE FROM modelo;
-- DELETE FROM uso_dataset;
-- DELETE FROM participacion;
-- DELETE FROM experimento;
-- DELETE FROM dataset;
-- DELETE FROM proyecto;
-- DELETE FROM cientifico_datos;
-- GO

/* ============================================================
   2. CIENTIFICOS DE DATOS
   ============================================================ */

INSERT INTO cientifico_datos (nombre, correo)
VALUES
    ('Ana Torres',      'ana.torres@datalab.edu.co'),
    ('Carlos Mendoza',  'carlos.mendoza@datalab.edu.co'),
    ('Laura Gómez',     'laura.gomez@datalab.edu.co'),
    ('Diego Ramírez',   'diego.ramirez@datalab.edu.co');
GO

/* ============================================================
   3. PROYECTOS
   ============================================================ */

INSERT INTO proyecto (nombre, descripcion)
VALUES
    (
        'Predicción de demanda',
        'Modelo para predecir la demanda de productos utilizando información histórica.'
    ),
    (
        'Clasificación de pacientes',
        'Proyecto de clasificación de pacientes a partir de variables biomédicas.'
    ),
    (
        'Detección de fraude',
        'Identificación de transacciones potencialmente fraudulentas.'
    ),
    (
        'Análisis de abandono',
        'Predicción de clientes con riesgo de abandonar un servicio.'
    );
GO

/* ============================================================
   4. DATASETS
   ============================================================ */

INSERT INTO dataset
    (nombre, fuente, fecha_carga, tamanio_filas)
VALUES
    (
        'ventas_historicas',
        'ERP',
        '2026-08-01',
        125000
    ),
    (
        'clientes_2026',
        'CRM',
        '2026-08-15',
        48000
    ),
    (
        'transacciones_bancarias',
        'Core Bancario',
        '2026-09-01',
        850000
    ),
    (
        'pacientes_historicos',
        'Sistema Hospitalario',
        '2026-09-05',
        76000
    ),
    (
        'consumo_clientes',
        'Data Warehouse',
        '2026-09-10',
        215000
    );
GO

/* ============================================================
   5. EXPERIMENTOS
   ============================================================ */

INSERT INTO experimento
    (id_proyecto, id_cientifico, fecha_ejecucion, configuracion)
VALUES
    (
        (SELECT id_proyecto
         FROM proyecto
         WHERE nombre = 'Predicción de demanda'),
        (SELECT id_cientifico
         FROM cientifico_datos
         WHERE correo = 'ana.torres@datalab.edu.co'),
        '2026-08-10',
        'Modelo base con variables históricas y ventana de 30 días.'
    ),
    (
        (SELECT id_proyecto
         FROM proyecto
         WHERE nombre = 'Predicción de demanda'),
        (SELECT id_cientifico
         FROM cientifico_datos
         WHERE correo = 'carlos.mendoza@datalab.edu.co'),
        '2026-08-18',
        'Prueba con variables de estacionalidad y ventana de 60 días.'
    ),
    (
        (SELECT id_proyecto
         FROM proyecto
         WHERE nombre = 'Clasificación de pacientes'),
        (SELECT id_cientifico
         FROM cientifico_datos
         WHERE correo = 'laura.gomez@datalab.edu.co'),
        '2026-09-06',
        'Clasificación binaria con variables clínicas seleccionadas.'
    ),
    (
        (SELECT id_proyecto
         FROM proyecto
         WHERE nombre = 'Detección de fraude'),
        (SELECT id_cientifico
         FROM cientifico_datos
         WHERE correo = 'diego.ramirez@datalab.edu.co'),
        '2026-09-08',
        'Detección de patrones anómalos en transacciones.'
    ),
    (
        (SELECT id_proyecto
         FROM proyecto
         WHERE nombre = 'Detección de fraude'),
        (SELECT id_cientifico
         FROM cientifico_datos
         WHERE correo = 'ana.torres@datalab.edu.co'),
        '2026-09-12',
        'Comparación de diferentes configuraciones del modelo.'
    ),
    (
        (SELECT id_proyecto
         FROM proyecto
         WHERE nombre = 'Análisis de abandono'),
        (SELECT id_cientifico
         FROM cientifico_datos
         WHERE correo = 'carlos.mendoza@datalab.edu.co'),
        '2026-09-15',
        'Predicción de abandono utilizando comportamiento histórico.'
    );
GO

/* ============================================================
   6. MODELOS
   ============================================================ */

INSERT INTO modelo
    (nombre, version, algoritmo, id_experimento)
VALUES
    (
        'Modelo Demanda Base',
        '1.0',
        'Regresión Lineal',
        (SELECT id_experimento
         FROM experimento
         WHERE fecha_ejecucion = '2026-08-10')
    ),
    (
        'Modelo Demanda Estacional',
        '1.1',
        'Random Forest',
        (SELECT id_experimento
         FROM experimento
         WHERE fecha_ejecucion = '2026-08-18')
    ),
    (
        'Modelo Clasificación Pacientes',
        '1.0',
        'Regresión Logística',
        (SELECT id_experimento
         FROM experimento
         WHERE fecha_ejecucion = '2026-09-06')
    ),
    (
        'Modelo Fraude Base',
        '1.0',
        'Random Forest',
        (SELECT id_experimento
         FROM experimento
         WHERE fecha_ejecucion = '2026-09-08')
    ),
    (
        'Modelo Fraude Optimizado',
        '1.1',
        'Gradient Boosting',
        (SELECT id_experimento
         FROM experimento
         WHERE fecha_ejecucion = '2026-09-12')
    ),
    (
        'Modelo Abandono',
        '1.0',
        'Random Forest',
        (SELECT id_experimento
         FROM experimento
         WHERE fecha_ejecucion = '2026-09-15')
    );
GO

/* ============================================================
   7. METRICAS
   ============================================================ */

INSERT INTO metrica
    (nombre_metrica, valor, fecha_calculo, id_modelo)
VALUES
    (
        'R2',
        0.82,
        '2026-08-10',
        (SELECT id_modelo
         FROM modelo
         WHERE nombre = 'Modelo Demanda Base')
    ),
    (
        'MAE',
        0.14,
        '2026-08-10',
        (SELECT id_modelo
         FROM modelo
         WHERE nombre = 'Modelo Demanda Base')
    ),
    (
        'R2',
        0.91,
        '2026-08-18',
        (SELECT id_modelo
         FROM modelo
         WHERE nombre = 'Modelo Demanda Estacional')
    ),
    (
        'MAE',
        0.09,
        '2026-08-18',
        (SELECT id_modelo
         FROM modelo
         WHERE nombre = 'Modelo Demanda Estacional')
    ),
    (
        'Accuracy',
        0.88,
        '2026-09-06',
        (SELECT id_modelo
         FROM modelo
         WHERE nombre = 'Modelo Clasificación Pacientes')
    ),
    (
        'F1',
        0.84,
        '2026-09-06',
        (SELECT id_modelo
         FROM modelo
         WHERE nombre = 'Modelo Clasificación Pacientes')
    ),
    (
        'Accuracy',
        0.93,
        '2026-09-08',
        (SELECT id_modelo
         FROM modelo
         WHERE nombre = 'Modelo Fraude Base')
    ),
    (
        'F1',
        0.89,
        '2026-09-08',
        (SELECT id_modelo
         FROM modelo
         WHERE nombre = 'Modelo Fraude Base')
    ),
    (
        'Accuracy',
        0.95,
        '2026-09-12',
        (SELECT id_modelo
         FROM modelo
         WHERE nombre = 'Modelo Fraude Optimizado')
    ),
    (
        'F1',
        0.92,
        '2026-09-12',
        (SELECT id_modelo
         FROM modelo
         WHERE nombre = 'Modelo Fraude Optimizado')
    ),
    (
        'Accuracy',
        0.86,
        '2026-09-15',
        (SELECT id_modelo
         FROM modelo
         WHERE nombre = 'Modelo Abandono')
    ),
    (
        'F1',
        0.81,
        '2026-09-15',
        (SELECT id_modelo
         FROM modelo
         WHERE nombre = 'Modelo Abandono')
    );
GO

/* ============================================================
   8. PARTICIPACION
   ============================================================ */

INSERT INTO participacion
    (id_cientifico, id_proyecto)
VALUES
    (
        (SELECT id_cientifico FROM cientifico_datos
         WHERE correo = 'ana.torres@datalab.edu.co'),
        (SELECT id_proyecto FROM proyecto
         WHERE nombre = 'Predicción de demanda')
    ),
    (
        (SELECT id_cientifico FROM cientifico_datos
         WHERE correo = 'carlos.mendoza@datalab.edu.co'),
        (SELECT id_proyecto FROM proyecto
         WHERE nombre = 'Predicción de demanda')
    ),
    (
        (SELECT id_cientifico FROM cientifico_datos
         WHERE correo = 'laura.gomez@datalab.edu.co'),
        (SELECT id_proyecto FROM proyecto
         WHERE nombre = 'Clasificación de pacientes')
    ),
    (
        (SELECT id_cientifico FROM cientifico_datos
         WHERE correo = 'diego.ramirez@datalab.edu.co'),
        (SELECT id_proyecto FROM proyecto
         WHERE nombre = 'Detección de fraude')
    ),
    (
        (SELECT id_cientifico FROM cientifico_datos
         WHERE correo = 'ana.torres@datalab.edu.co'),
        (SELECT id_proyecto FROM proyecto
         WHERE nombre = 'Detección de fraude')
    ),
    (
        (SELECT id_cientifico FROM cientifico_datos
         WHERE correo = 'carlos.mendoza@datalab.edu.co'),
        (SELECT id_proyecto FROM proyecto
         WHERE nombre = 'Análisis de abandono')
    );
GO

/* ============================================================
   9. USO_DATASET
   ============================================================ */

INSERT INTO uso_dataset
    (id_dataset, id_experimento)
VALUES
    (
        (SELECT id_dataset FROM dataset
         WHERE nombre = 'ventas_historicas'),
        (SELECT id_experimento FROM experimento
         WHERE fecha_ejecucion = '2026-08-10')
    ),
    (
        (SELECT id_dataset FROM dataset
         WHERE nombre = 'ventas_historicas'),
        (SELECT id_experimento FROM experimento
         WHERE fecha_ejecucion = '2026-08-18')
    ),
    (
        (SELECT id_dataset FROM dataset
         WHERE nombre = 'pacientes_historicos'),
        (SELECT id_experimento FROM experimento
         WHERE fecha_ejecucion = '2026-09-06')
    ),
    (
        (SELECT id_dataset FROM dataset
         WHERE nombre = 'transacciones_bancarias'),
        (SELECT id_experimento FROM experimento
         WHERE fecha_ejecucion = '2026-09-08')
    ),
    (
        (SELECT id_dataset FROM dataset
         WHERE nombre = 'transacciones_bancarias'),
        (SELECT id_experimento FROM experimento
         WHERE fecha_ejecucion = '2026-09-12')
    ),
    (
        (SELECT id_dataset FROM dataset
         WHERE nombre = 'consumo_clientes'),
        (SELECT id_experimento FROM experimento
         WHERE fecha_ejecucion = '2026-09-15')
    );
GO

/* ============================================================
   10. VERIFICACIÓN GENERAL
   ============================================================ */

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
GO

/* ============================================================
   11. CONSULTAS RÁPIDAS PARA LA SEMANA 6
   ============================================================ */

-- 1. Todos los proyectos
SELECT *
FROM proyecto;
GO

-- 2. Columnas específicas
SELECT nombre, descripcion
FROM proyecto;
GO

-- 3. Fuentes únicas de datasets
SELECT DISTINCT fuente
FROM dataset;
GO

-- 4. Datasets ordenados por fecha de carga
SELECT nombre, fecha_carga
FROM dataset
ORDER BY fecha_carga DESC;
GO

-- 5. Los tres datasets más recientes
SELECT TOP 3
    nombre,
    fecha_carga
FROM dataset
ORDER BY fecha_carga DESC;
GO
