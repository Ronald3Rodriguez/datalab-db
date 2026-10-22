
---

## Semana 6/7 — Preguntas de negocio resueltas con DML

> **Cómo usar este archivo:** pega este bloque **al final** de tu `casos_uso/s06-preguntas-negocio.md` existente (no reemplaces lo que ya tienes). Si el archivo aún no existe, créalo con este contenido.

Cada pregunta de negocio se traduce a una operación SQL sobre las tablas reales de DataLab. Todas se verifican con un `SELECT`.

| # | Pregunta de negocio | Operación | Tablas implicadas |
|---|---|---|---|
| N1 | ¿Qué proyectos existen en DataLab? | `SELECT` | `proyecto` |
| N2 | ¿Cómo registramos un nuevo proyecto? | `INSERT` + `SELECT` | `proyecto` |
| N3 | ¿Qué experimentos tiene un proyecto y quién los ejecutó? | `SELECT` con `JOIN` | `experimento`, `proyecto`, `cientifico_datos` |
| N4 | ¿Cómo corregimos la descripción de un proyecto? | `UPDATE` + `SELECT` | `proyecto` |
| N5 | ¿Cómo registramos un experimento nuevo de forma válida? | `INSERT` con FK + `SELECT` | `experimento`, `proyecto`, `cientifico_datos` |
| N6 | ¿Cómo eliminamos un proyecto creado por error? | `SELECT` → `DELETE` → `SELECT` | `proyecto` |
| N7 | ¿Qué pasa si se elimina un proyecto que ya tiene experimentos? | `DELETE` en transacción + `ROLLBACK` | `proyecto`, `experimento` |
| N8 | ¿Qué pasa si se registra un experimento de un proyecto que no existe? | `INSERT` fallido (error 547) | `experimento`, `proyecto` |

### N1. ¿Qué proyectos existen en DataLab?

```sql
SELECT id_proyecto, nombre, descripcion
FROM proyecto
ORDER BY id_proyecto;
```

### N2. ¿Cómo registramos un nuevo proyecto?

```sql
INSERT INTO proyecto (nombre, descripcion)
VALUES ('Prediccion de demanda (practica S06)',
        'Proyecto para analizar y predecir la demanda de servicios.');

SELECT * FROM proyecto
WHERE nombre = 'Prediccion de demanda (practica S06)';
```

### N3. ¿Qué experimentos tiene un proyecto y quién los ejecutó?

```sql
SELECT p.nombre        AS proyecto,
       c.nombre        AS cientifico,
       e.fecha_ejecucion,
       e.configuracion
FROM experimento e
JOIN proyecto p         ON p.id_proyecto   = e.id_proyecto
JOIN cientifico_datos c ON c.id_cientifico = e.id_cientifico
WHERE p.nombre = 'Prediccion de demanda (practica S06)';
```

### N4. ¿Cómo corregimos la descripción de un proyecto?

```sql
-- 1) Confirmar qué fila se afectará
SELECT * FROM proyecto
WHERE nombre = 'Prediccion de demanda (practica S06)';

-- 2) Modificar
UPDATE proyecto
SET descripcion = 'Proyecto para predecir la demanda mensual de servicios con series de tiempo.'
WHERE nombre = 'Prediccion de demanda (practica S06)';

-- 3) Verificar
SELECT * FROM proyecto
WHERE nombre = 'Prediccion de demanda (practica S06)';
```

### N5. ¿Cómo registramos un experimento nuevo de forma válida?

Primero deben existir el científico y el proyecto (orden: `cientifico_datos` → `proyecto` → `experimento`).

```sql
INSERT INTO experimento (id_proyecto, id_cientifico, fecha_ejecucion, configuracion)
SELECT p.id_proyecto, c.id_cientifico, '20261007', 'Configuracion inicial del experimento'
FROM proyecto p
CROSS JOIN cientifico_datos c
WHERE p.nombre = 'Prediccion de demanda (practica S06)'
  AND c.correo = 'elian.pacheco@datalab.com';
```

### N6. ¿Cómo eliminamos un proyecto creado por error?

```sql
SELECT * FROM proyecto WHERE nombre = 'Proyecto Temporal DELETE S06';   -- 1 fila

DELETE FROM proyecto WHERE nombre = 'Proyecto Temporal DELETE S06';

SELECT * FROM proyecto WHERE nombre = 'Proyecto Temporal DELETE S06';   -- 0 filas
```

Solo es posible directamente si el proyecto **no** tiene experimentos (ni filas en `participacion`) que dependan de él.

### N7. ¿Qué pasa si se elimina un proyecto con experimentos?

```sql
BEGIN TRANSACTION;
BEGIN TRY
    DELETE FROM proyecto WHERE nombre = 'Prediccion de demanda (practica S06)';
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS numero_error, ERROR_MESSAGE() AS mensaje_error;
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
```

**Respuesta de negocio:** depende de la política `ON DELETE` de la FK. Con `NO ACTION` SQL Server impide el borrado (error 547) para no dejar experimentos huérfanos; con `CASCADE` se eliminarían también sus experimentos. En ambos casos, el `ROLLBACK` deja los datos intactos durante la prueba.

### N8. ¿Qué pasa si se registra un experimento de un proyecto inexistente?

```sql
BEGIN TRY
    INSERT INTO experimento (id_proyecto, id_cientifico, fecha_ejecucion, configuracion)
    SELECT 9999, c.id_cientifico, '20260924', 'Prueba de integridad'
    FROM cientifico_datos c
    WHERE c.correo = 'elian.pacheco@datalab.com';
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS numero_error, ERROR_MESSAGE() AS mensaje_error;   -- 547
END CATCH;
```

**Respuesta de negocio:** el sistema rechaza el registro. Garantiza que no existan experimentos sin proyecto, es decir, que todo resultado de ciencia de datos esté asociado a un proyecto real.
