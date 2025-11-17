# Prompt entendimiento del proyecto

## Rol

Eres un desarrollador experto en bases de datos con Prisma

## Tarea

entiende a pronfundidad el esquema y genera un diagrama ERD en formato mermaid para entender su relación entre tablas

## Formato

Entrega el documento en un formato markdown

# Prompt  Migración

Eres un experto en bases de datos relacionales y Prisma ORM. Tu tarea es analizar el siguiente diagrama ERD [ERD_update.md] y generar un script SQL de migración para PostgreSQL que actualice la estructura de la base de datos [schema.prisma], asegurando:

1. **Compatibilidad con Prisma**: El script debe ser compatible con el esquema de Prisma proporcionado y mantener la integridad de las migraciones existentes.

2. **Integridad de datos**: 
   - Preservar los datos existentes durante la migración
   - Manejar correctamente las claves foráneas y constraints
   - Aplicar estrategias de migración seguras (ALTER TABLE cuando sea posible, evitando DROP innecesarios)

3. **Estructura correcta**:
   - Crear/modificar tablas según el diagrama ERD
   - Definir correctamente tipos de datos PostgreSQL (VARCHAR con límites, INTEGER, TIMESTAMP, etc.)
   - Implementar constraints: PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL
   - Configurar índices apropiados para mejorar el rendimiento de consultas

4. **Validaciones**:
   - Verificar que todas las relaciones del ERD estén correctamente implementadas
   - Asegurar que los campos opcionales permitan NULL cuando corresponda
   - Validar que los límites de longitud de VARCHAR coincidan con el esquema

5. **Formato del script**:
   - Incluir comentarios explicativos para cada sección
   - Usar transacciones para garantizar atomicidad
   - Proporcionar instrucciones de rollback si es necesario
   - Incluir verificaciones de existencia antes de crear/modificar objetos

6. **Consideraciones adicionales**:
   - Si la base de datos ya existe, identificar qué cambios son necesarios (ALTER vs CREATE)
   - Optimizar el orden de ejecución para evitar errores de dependencias
   - Considerar el impacto en el rendimiento durante la migración

Genera el script SQL completo, listo para ejecutar, que transforme la base de datos actual al estado definido en el diagrama ERD.