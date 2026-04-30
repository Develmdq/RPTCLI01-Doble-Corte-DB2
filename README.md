🚧 Proyecto en desarrollo como parte de mi especialización en arquitectura COBOL".

¿Qué hace este programa?
Consulta la base de datos de empleados y genera un reporte impreso que agrupa 
los empleados por departamento y sexo, mostrando cuántos empleados hay en 
cada grupo y cuál es el salario promedio.
Es un programa batch COBOL corriendo en mainframe IBM z/OS, con acceso a DB2 
y salida a archivo de impresión paginado.

Algunos puntos de diseño que vale la pena revisar en el código:

Manejo de errores centralizado en un subprograma reutilizable
El programa nunca continúa después de un error — o sale limpio o no sale
Paginado automático sin lógica manual de conteo de líneas
SQL sin GO TO — control de flujo 100% estructurado