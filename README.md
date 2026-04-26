🚧 Proyecto en desarrollo como parte de mi especialización en arquitectura COBOL".

¿Qué hace este programa?
Consulta la base de datos de cuentas bancarias y genera un reporte impreso que agrupa los clientes por tipo de cuenta y sexo, mostrando cuántas cuentas hay en cada grupo y cuál es el saldo promedio.
Es un programa batch COBOL corriendo en mainframe IBM z/OS, con acceso a DB2 y salida a archivo de impresión paginado.
Algunos puntos de diseño que vale la pena revisar en el código:

Manejo de errores centralizado en un subprograma reutilizable
El programa nunca continúa después de un error — o sale limpio o no sale
Paginado automático sin lógica manual de conteo de líneas
SQL sin GO TO — control de flujo 100% estructurado