-- =========================================================
-- DataLab — Pruebas de integridad referencial y restricciones — SOLUCIÓN DE REFERENCIA
-- Semana 5 — Hito 2
-- Uso: exclusivo del docente. Ejecutar DESPUÉS de s05-creacion-tablas-solucion.sql
-- Motor: SQL Server 2019+
-- =========================================================

USE datalab;
GO

-- ---------------------------------------------------------
-- Prueba 1 — Inserciones válidas (deben funcionar sin error)
-- ---------------------------------------------------------

INSERT INTO cientifico_datos (nombre, correo_institucional)
VALUES ('Ana Torres', 'ana.torres@usta.edu.co');
GO

INSERT INTO proyecto (nombre_proyecto, descripcion)
VALUES ('Detección de fraude en transacciones',
        'Modelo de clasificación binaria sobre transacciones bancarias');
GO

-- Resultado esperado: 2 filas insertadas sin error.
-- Verificar con:
--   SELECT * FROM cientifico_datos;
--   SELECT * FROM proyecto;


-- ---------------------------------------------------------
-- Prueba 2 — Violación de integridad referencial (DEBE FALLAR)
-- ---------------------------------------------------------

-- id_proyecto = 999 no existe en la tabla proyecto.
INSERT INTO experimento (id_proyecto, id_cientifico, configuracion)
VALUES (999, 1, 'lr=0.01;epochs=50;batch=32');
GO

-- Resultado esperado (SQL Server):
-- Msg 547, Level 16, State 0, Line ...
-- The INSERT statement conflicted with the FOREIGN KEY constraint
-- "fk_experimento_proyecto". The conflict occurred in database "datalab",
-- table "dbo.proyecto", column 'id_proyecto'.
-- The statement has been terminated.
--
-- Esto es exactamente lo que los equipos predijeron en la Semana 3.


-- ---------------------------------------------------------
-- Prueba 3 — Inserción válida en experimento, para poder probar CHECK después
-- ---------------------------------------------------------

INSERT INTO experimento (id_proyecto, id_cientifico, configuracion)
VALUES (1, 1, 'lr=0.01;epochs=50;batch=32');
GO

INSERT INTO modelo (id_experimento, nombre, version, algoritmo)
VALUES (1, 'modelo_fraude_v1', '1.0', 'Random Forest');
GO


-- ---------------------------------------------------------
-- Prueba 4 — Violación de restricción CHECK (DEBE FALLAR)
-- ---------------------------------------------------------

-- valor = 1.5 está fuera del rango permitido (0 a 1).
INSERT INTO metrica (id_modelo, nombre_metrica, valor, fecha_calculo)
VALUES (1, 'accuracy', 1.5, CAST(GETDATE() AS DATE));
GO

-- Resultado esperado (SQL Server):
-- Msg 547, Level 16, State 0, Line ...
-- The INSERT statement conflicted with the CHECK constraint "chk_metrica_valor".
-- The conflict occurred in database "datalab", table "dbo.metrica", column 'valor'.
-- The statement has been terminated.


-- ---------------------------------------------------------
-- Prueba 5 — Política RESTRICT / NO ACTION ante DELETE (DEBE FALLAR)
-- ---------------------------------------------------------

-- proyecto con id_proyecto = 1 ya tiene un experimento asociado (Prueba 3).
DELETE FROM proyecto WHERE id_proyecto = 1;
GO

-- Resultado esperado (SQL Server, si la FK está con ON DELETE NO ACTION):
-- Msg 547, Level 16, State 0, Line ...
-- The DELETE statement conflicted with the REFERENCE constraint
-- "fk_experimento_proyecto". The conflict occurred in database "datalab",
-- table "dbo.experimento", column 'id_proyecto'.
-- The statement has been terminated.
--
-- NOTA IMPORTANTE:
-- En SQL Server "RESTRICT" no es una palabra válida para FK; el equivalente
-- es ON DELETE NO ACTION (que es además el comportamiento por defecto).
-- Esto confirma la política que los equipos justificaron en la Semana 4.
--
-- Si en el script de creación se definió ON DELETE CASCADE para esta FK,
-- entonces esta Prueba 5 NO debe fallar y el DELETE eliminará en cascada
-- los experimentos asociados. Ajusten según la decisión de su diseño.


-- ---------------------------------------------------------
-- Prueba 6 — Política CASCADE ante DELETE (referencia, no ejecutar sobre los
-- mismos datos si se quiere conservar la base para la Semana 6)
-- ---------------------------------------------------------

-- INSERT de una métrica válida para luego probar el CASCADE:
-- INSERT INTO metrica (id_modelo, nombre_metrica, valor, fecha_calculo)
-- VALUES (1, 'accuracy', 0.95, CAST(GETDATE() AS DATE));
-- GO
--
-- DELETE FROM modelo WHERE id_modelo = 1;
-- GO
-- Resultado esperado: la fila de modelo se borra Y la fila de metrica asociada
-- se borra automáticamente (CASCADE), sin error.
-- Sugerencia: mostrar esto en un esquema de práctica aparte, no en la base
-- que van a usar como datos semilla para las próximas semanas.


-- ---------------------------------------------------------
-- Consultas de verificación (opcionales, para mostrar en clase)
-- ---------------------------------------------------------

-- Ver el estado final de las tablas usadas en las pruebas:
-- SELECT * FROM cientifico_datos;
-- SELECT * FROM proyecto;
-- SELECT * FROM experimento;
-- SELECT * FROM modelo;
-- SELECT * FROM metrica;
--
-- Revisar las restricciones definidas sobre una tabla:
-- EXEC sp_help 'experimento';
-- EXEC sp_help 'metrica';


-- =========================================================
-- Cierre: pedir a cada equipo que registre en documentacion/decisiones.md
-- si el comportamiento real coincidió con lo que predijeron en las
-- Semanas 3 y 4, y qué ajustaron si no coincidió.
-- =========================================================