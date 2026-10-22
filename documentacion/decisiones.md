# 📜 Bitácora Consolidada de Decisiones de Arquitectura y Diseño — DataLab

**Proyecto:** DataLab — Sistema Relacional de Gestión de Experimentos de Ciencia de Datos  
**Autor:** Ronald Rodríguez  
**Repositorio Oficial:** [github.com/Ronald3Rodriguez/datalab-db](https://github.com/Ronald3Rodriguez/datalab-db)  
**Motor de Base de Datos:** SQL Server 2019+  
**Herramienta:** SQL Server Management Studio (SSMS) / Azure Data Studio  

---

## 📌 Presentación

El presente documento consolida la totalidad de las **decisiones técnicas, arquitectónicas, de diseño y de manipulación de datos** adoptadas por **Ronald Rodríguez** durante el desarrollo del proyecto **DataLab**, abarcando desde la concepción del modelo relacional hasta el cierre del Hito 3 (Semana 9).

---

## 🏛️ 1. Diseño Conceptual, Lógico e Integridad (Semanas 1–4)

### DEC-001: Normalización hasta Tercera Forma Normal (3NF)
* **Categoría:** Diseño Lógico
* **Decisión:** Normalizar las ocho tablas principales del modelo (`cientifico_datos`, `proyecto`, `dataset`, `experimento`, `modelo`, `metrica`, `participacion`, `uso_dataset`) hasta 3NF.
* **Justificación:** Garantiza la eliminación de redundancias y previene anomalías de inserción, actualización y borrado en el registro de experimentos y métricas de modelos.

### DEC-002: Manejo de Claves Primarias con Autoincremento (`IDENTITY`)
* **Categoría:** Diseño Físico
* **Decisión:** Definir claves primarias surrogadas simples mediante `IDENTITY(1,1)` para tablas con alto volumen de inserción (`id_proyecto`, `id_cientifico`, `id_experimento`, `id_modelo`, `id_metrica`, `id_dataset`).
* **Justificación:** Optimiza el rendimiento de indexación y simplifica el establecimiento de Foreign Keys en relaciones 1:N.

### DEC-003: Adopción de `ON DELETE NO ACTION` para Restricción Referencial
* **Categoría:** Integridad Referencial
* **Decisión:** Configurar la política `ON DELETE NO ACTION` en las claves foráneas que vinculan proyectos con experimentos y experimentos con modelos.
* **Justificación:** En SQL Server, la sintaxis `RESTRICT` no existe explícitamente. `ON DELETE NO ACTION` cumple exactamente la misma función al bloquear la eliminación de un registro padre si existen registros hijos asociados, protegiendo la trazabilidad histórica de los experimentos.

---

## 🧪 2. Diseño Físico y Pruebas de Integridad (Semana 5 — Hito 2)

### DEC-004: Restricción Domain CHECK para Métricas de Rendimiento
* **Categoría:** Integridad de Dominio
* **Decisión:** Implementar la restricción `CONSTRAINT chk_metrica_valor CHECK (valor BETWEEN 0.0 AND 1.0)` en la tabla `metrica`.
* **Justificación:** Asegura que métricas estandarizadas como *Accuracy*, *Precision*, *Recall*, *F1-Score* y *ROC-AUC* no contengan valores fuera del dominio matemático válido $[0, 1]$.

### DEC-005: Control de Eliminación en Cascada Controlada (`CASCADE`)
* **Categoría:** Integridad Referencial
* **Decisión:** Aplicar `ON DELETE CASCADE` únicamente en la relación dependiente entre `modelo` y `metrica`.
* **Justificación:** Si un modelo de aprendizaje automático se elimina del catálogo, sus métricas calculadas carecen de significado analítico aislado y deben depurarse automáticamente.

### DEC-006: Captura Dinámica de Errores en Pruebas DDL/DML
* **Categoría:** Pruebas y Aseguramiento
* **Decisión:** Envolver las pruebas de violación de FK y CHECK dentro de bloques `BEGIN TRY ... BEGIN CATCH`.
* **Justificación:** Permite capturar dinámicamente el código de error `Msg 547` sin detener la ejecución de scripts batch completos en SSMS.

---

## 🔄 3. Estrategia de Poblamiento y Control de Datos (Semana 6)

### DEC-007: Reinicio de Datos Mediante `DELETE + DBCC CHECKIDENT`
* **Categoría:** Estrategia DML
* **Decisión:** Implementar la secuencia `DELETE FROM tabla` seguida de `DBCC CHECKIDENT ('tabla', RESEED, 0)` en el script `s06-reset-datos.sql` en lugar de `TRUNCATE TABLE`.
* **Justificación:** SQL Server prohíbe el uso de `TRUNCATE TABLE` en tablas que son referenciadas por Foreign Keys, incluso si las tablas dependientes están vacías. El enfoque `DELETE + DBCC CHECKIDENT` garantiza un reinicio limpio y sin errores.

### DEC-008: Estandarización de Datos Semilla Masivos
* **Categoría:** Gestión de Datos
* **Decisión:** Crear un conjunto de datos semilla controlado (`s06-datos-semilla.sql` / `s08-datos-semilla.sql`) que garantice un volumen mínimo de $100+$ filas por tabla.
* **Justificación:** Permite la ejecución uniforme y la comparabilidad de resultados en consultas avanzadas de filtrado, agregación y JOINs entre miembros del equipo.

---

## 🛠️ 4. Evolución del Esquema y Control DDL Incremental (Semana 7)

### DEC-009: Inserción de Columnas Obligatorias con `ADD DEFAULT WITH VALUES`
* **Categoría:** DDL / Evolución del Esquema
* **Decisión:** Para incorporar la columna `estado` en `experimento`, se utilizó `ALTER TABLE ADD estado VARCHAR(20) NOT NULL CONSTRAINT df_experimento_estado DEFAULT 'planificado' WITH VALUES`.
* **Justificación:** `WITH VALUES` fuerza a SQL Server a poblar los registros existentes con el valor por defecto en lugar de fallar por violación de restricciones `NOT NULL`.

### DEC-010: Aislamiento de Pruebas Destructivas (`DROP`)
* **Categoría:** Seguridad DDL
* **Decisión:** Prohibir el uso de `DROP TABLE` o `DROP COLUMN` sobre las ocho tablas principales de DataLab, restringiendo las prácticas de borrado exclusivamente a una tabla temporal de prueba (`tabla_prueba_drop`).
* **Justificación:** Resguarda la integridad del modelo físico en producción y evita la pérdida inintencionada de estructuras relacionales reales.

### DEC-011: Restricción de Unicidad en Nombres de Proyectos
* **Categoría:** Integridad de Clave Candidata
* **Decisión:** Agregar la restricción `CONSTRAINT uq_proyecto_nombre UNIQUE (nombre_proyecto)` previa verificación de no duplicidad mediante `GROUP BY ... HAVING COUNT(*) > 1`.
* **Justificación:** Previene la creación de proyectos duplicados y facilita la resolución de Foreign Keys mediante claves naturales en scripts de carga DML.

---

## 🔐 5. Seguridad DML, Transacciones y Agregaciones (Semana 8)

### DEC-012: Regla de Lectura Previa Obligatoria (`SELECT` previo a `UPDATE`/`DELETE`)
* **Categoría:** Seguridad en Operaciones DML
* **Decisión:** Adoptar el estándar operacional de ejecutar una consulta `SELECT` con la misma cláusula `WHERE` antes de realizar un `UPDATE` o `DELETE`.
* **Justificación:** Previene la modificación o pérdida accidental de datos masivos provocada por sentencias DML sin la cláusula de filtrado adecuada.

### DEC-013: Uso de Transacciones Explicitas para Pruebas Destructivas
* **Categoría:** TCL (Transaction Control Language)
* **Decisión:** Implementar bloques `BEGIN TRANSACTION ... ROLLBACK TRANSACTION` para probar escenarios destructivos y verificar efectos temporales sin alterar la base persistente.
* **Justificación:** Garantiza la atomicidad de las operaciones y preserva el estado conocido de la base de datos para laboratorios posteriores.

### DEC-014: Filtrado de Grupos Agregados Mediante `HAVING`
* **Categoría:** DQL (Data Query Language)
* **Decisión:** Separar estrictamente los filtros a nivel de fila (`WHERE`) de los filtros aplicados a funciones de agregación (`HAVING`).
* **Justificación:** Garantiza la corrección sintáctica y semántica en SQL Server al evaluar promedios de rendimiento de métricas (`HAVING AVG(valor) > 0.8`).

---

## 📊 6. Consultas Multitable, Subconsultas y Vistas (Semana 9 — Hito 3)

### DEC-015: Límite de Complejidad de Máximo Dos (2) Tablas por Consulta
* **Categoría:** Regla de Negocio / Alcance
* **Decisión:** Acotar todas las consultas del Hito 3 (Semana 9) a un máximo estricto de dos tablas relacionadas, ya sea mediante `INNER JOIN`, `LEFT JOIN` o subconsultas.
* **Justificación:** Garantiza la modularidad, facilita la auditoría del rendimiento de la base de datos y mantiene la alineación con los objetivos pedagógicos de la etapa.

### DEC-016: Encapsulamiento de Consultas Frecuentes en Vistas (`CREATE OR ALTER VIEW`)
* **Categoría:** Abstracción y Seguridad
* **Decisión:** Crear las vistas `vista_modelos_por_experimento`, `vista_resumen_proyecto` y `vista_datasets_sin_uso` en el script `s09-vistas.sql`.
* **Justificación:** Simplifica el acceso a reportes recurrentes, desacopla la capa de consulta de las tablas físicas subyacentes y centraliza la lógica de negocio sin duplicar datos persistentes.

### DEC-017: Protección de Subconsultas `NOT IN` frente a Valores Nulos
* **Categoría:** Seguridad en Consultas
* **Decisión:** Incluir la condición `WHERE columna IS NOT NULL` dentro de las subconsultas utilizadas en operadores `NOT IN`.
* **Justificación:** Si una subconsulta evalúa un conjunto que contiene al menos un valor `NULL`, el operador `NOT IN` devuelve un resultado vacío (*UNKNOWN*), provocando fallos lógicos silenciosos.

### DEC-018: Priorización de Preguntas de Negocio del Hito 3
* **Categoría:** Gestión del Proyecto
* **Decisión:** Dar por resueltas 5 de las 7 preguntas de negocio en el Hito 3, programando las 2 restantes (que requieren vincular 3 o más tablas) para la siguiente fase.
* **Justificación:** Respeta la regla de límite de tablas del Hito 3 manteniendo un registro claro del estado de cada requerimiento analítico.

---

## 📋 Resumen de Decisiones de Arquitectura

| Código | Categoría | Decisión Principal | Impacto en DataLab |
|---|---|---|---|
| **DEC-001** | Diseño Lógico | Normalización a 3NF | Eliminación de redundancias en las 8 tablas reales. |
| **DEC-002** | Diseño Físico | Claves primarias `IDENTITY(1,1)` | Autoincremento eficiente y claves surrogadas homogéneas. |
| **DEC-003** | Integridad Referencial | `ON DELETE NO ACTION` | Reemplazo válido de `RESTRICT` en SQL Server. |
| **DEC-004** | Integridad Dominio | `CHECK (valor BETWEEN 0 AND 1)` | Validación del rango matemático para métricas de modelos. |
| **DEC-005** | Integridad Referencial | `ON DELETE CASCADE` acotado | Depuración automática de métricas al borrar un modelo. |
| **DEC-006** | Aseguramiento | Bloques `TRY ... CATCH` | Captura limpia de errores `Msg 547` en scripts batch. |
| **DEC-007** | Estrategia DML | `DELETE + DBCC CHECKIDENT` | Alternativa segura a `TRUNCATE` ante presencia de FKs. |
| **DEC-008** | Gestión Datos | Datos Semilla ($100+$ filas) | Entorno de pruebas estandarizado y reproducible. |
| **DEC-009** | DDL Incremental | `ADD DEFAULT WITH VALUES` | Inserción de columnas `NOT NULL` sin corromper datos previos. |
| **DEC-010** | Seguridad DDL | Isolation de `DROP TABLE` | Protección estricta de las tablas reales del proyecto. |
| **DEC-011** | Integridad Clave | Restricción `UNIQUE` en proyectos | Eliminación de nombres duplicados de proyectos. |
| **DEC-012** | Seguridad DML | `SELECT` previo a `UPDATE`/`DELETE` | Verificación de impacto antes de ejecutar cambios DML. |
| **DEC-013** | Control TCL | Transacciones con `ROLLBACK` | Ejecución de pruebas destructivas sin alterar la BD. |
| **DEC-014** | DQL Agregación | Filtrado con `HAVING` | Correcta evaluación de funciones de agregación en grupos. |
| **DEC-015** | Alcance Hito 3 | Límite de 2 tablas por consulta | Consultas multitabla enfocadas y mantenibles. |
| **DEC-016** | Abstracción | Creación de Vistas Reutilizables | Encapsulamiento de reportes recurrentes sin duplicar datos. |
| **DEC-017** | Seguridad DQL | Subconsultas `NOT IN` con `IS NOT NULL` | Evita resultados vacíos ante presencia de valores nulos. |
| **DEC-018** | Gestión Requerimientos | Cierre de 5/7 Preguntas de Negocio | Balance claro del Hito 3 y diferimiento justificado. |

---

*Documentación técnica elaborada, consolidada y mantenida por **Ronald Rodríguez**.*
