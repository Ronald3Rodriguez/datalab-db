/*
    DataLab - Semana 8
    Filtros, ordenamiento y funciones de agregación (SQL Server)
*/
USE datalab;
GO

-- Ejercicio 1
SELECT id_proyecto, nombre_proyecto
FROM dbo.proyecto;
GO

-- Ejercicio 2
SELECT id_dataset, nombre, fuente
FROM dbo.dataset
WHERE fuente = 'externa';
GO

-- Ejercicio 3
SELECT id_metrica, nombre_metrica, valor
FROM dbo.metrica
WHERE valor >= 0.80;
GO

-- Ejercicio 4
SELECT id_metrica, nombre_metrica, valor
FROM dbo.metrica
WHERE valor BETWEEN 0.70 AND 0.90;
GO

-- Ejercicio 5
SELECT id_dataset, nombre, fuente
FROM dbo.dataset
WHERE fuente IN ('interna', 'externa');
GO

-- Ejercicio 6
SELECT id_dataset, nombre
FROM dbo.dataset
WHERE nombre LIKE 'EEG%';
GO

-- Ejercicio 7
-- Datasets con tamaño desconocido
SELECT id_dataset, nombre, tamanio_filas
FROM dbo.dataset
WHERE tamanio_filas IS NULL;

-- Datasets con tamaño informado
SELECT id_dataset, nombre, tamanio_filas
FROM dbo.dataset
WHERE tamanio_filas IS NOT NULL;
GO

-- Ejercicio 8
SELECT id_dataset, nombre, fuente, fecha_carga
FROM dbo.dataset
WHERE fuente = 'externa'
  AND fecha_carga >= '20260101';
GO

-- Ejercicio 9
-- Con NOT
SELECT id_dataset, nombre, fuente
FROM dbo.dataset
WHERE NOT fuente = 'externa';

-- Con <>
SELECT id_dataset, nombre, fuente
FROM dbo.dataset
WHERE fuente <> 'externa';
GO

-- Ejercicio 10
SELECT nombre, fecha_carga
FROM dbo.dataset
ORDER BY fecha_carga DESC;
GO

-- Ejercicio 11
SELECT nombre, fuente, fecha_carga
FROM dbo.dataset
ORDER BY fuente ASC, fecha_carga DESC;
GO

-- Ejercicio 12
SELECT COUNT(*) AS total_datasets
FROM dbo.dataset;
GO

-- Ejercicio 13
SELECT AVG(valor) AS promedio,
       MIN(valor) AS minimo,
       MAX(valor) AS maximo
FROM dbo.metrica;
GO

-- Ejercicio 14
SELECT fuente, COUNT(*) AS cantidad_datasets
FROM dbo.dataset
GROUP BY fuente;
GO

-- Ejercicio 15
SELECT nombre_metrica, AVG(valor) AS promedio
FROM dbo.metrica
GROUP BY nombre_metrica;
GO

-- Ejercicio 16
SELECT nombre_metrica, AVG(valor) AS promedio
FROM dbo.metrica
GROUP BY nombre_metrica
HAVING AVG(valor) > 0.80;
GO

-- Ejercicio 17
INSERT INTO dbo.proyecto (nombre_proyecto, descripcion)
VALUES (N'Proyecto de práctica S08',
        N'Registro temporal para practicar DML.');

SELECT id_proyecto, nombre_proyecto, descripcion
FROM dbo.proyecto
WHERE nombre_proyecto = N'Proyecto de práctica S08';
GO

-- Ejercicio 18
-- Antes
SELECT id_proyecto, nombre_proyecto, descripcion
FROM dbo.proyecto
WHERE nombre_proyecto = N'Proyecto de práctica S08';

UPDATE dbo.proyecto
SET descripcion = N'Descripcion actualizada durante la practica S08.'
WHERE nombre_proyecto = N'Proyecto de práctica S08';

-- Después
SELECT id_proyecto, nombre_proyecto, descripcion
FROM dbo.proyecto
WHERE nombre_proyecto = N'Proyecto de práctica S08';
GO

-- Ejercicio 19
-- Antes
SELECT id_proyecto, nombre_proyecto
FROM dbo.proyecto
WHERE nombre_proyecto = N'Proyecto de práctica S08';

DELETE FROM dbo.proyecto
WHERE nombre_proyecto = N'Proyecto de práctica S08';

-- Después (debe devolver 0 filas)
SELECT id_proyecto, nombre_proyecto
FROM dbo.proyecto
WHERE nombre_proyecto = N'Proyecto de práctica S08';
GO

-- Ejercicio 20
SELECT nombre_metrica, AVG(valor) AS promedio
FROM dbo.metrica
GROUP BY nombre_metrica
HAVING AVG(valor) > 0.80;
GO

-- Pregunta de negocio 1
SELECT fuente, COUNT(*) AS cantidad_datasets
FROM dbo.dataset
GROUP BY fuente;
GO

-- Pregunta de negocio 2
SELECT id_dataset, nombre, tamanio_filas
FROM dbo.dataset
WHERE tamanio_filas IS NULL;
GO

-- Pregunta de negocio 3
SELECT MAX(tamanio_filas) AS tamanio_maximo
FROM dbo.dataset;
GO

-- Pregunta de negocio 4
SELECT nombre_metrica, AVG(valor) AS promedio
FROM dbo.metrica
GROUP BY nombre_metrica;
GO

-- Pregunta de negocio 5
SELECT nombre_metrica, AVG(valor) AS promedio
FROM dbo.metrica
GROUP BY nombre_metrica
HAVING AVG(valor) > 0.80;
GO

-- Pregunta de negocio 6
SELECT algoritmo, COUNT(*) AS cantidad_modelos
FROM dbo.modelo
GROUP BY algoritmo;
GO

-- Pregunta de negocio 7
SELECT id_modelo, nombre, version, algoritmo
FROM dbo.modelo
WHERE version LIKE '1.2%';
GO
