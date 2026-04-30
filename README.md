🚧 Proyecto en desarrollo como parte de mi especialización en arquitectura COBOL".

¿Qué hará este programa?
Realizará un JOIN entre las tablas de empleados y departamentos, y generará un reporte 
impreso que agrupa los resultados por departamento y por sexo, mostrando cuántos 
empleados hay en cada grupo y cuál es el salario promedio.
Es un programa batch COBOL corriendo en mainframe IBM z/OS, con acceso a DB2 
y salida a archivo de impresión paginado.

Algunos puntos de diseño que vale la pena revisar en el código:

* Estructura de INICIO-PROCESO-FINAL;
* Manejo de esados x medio de niveles 88;
* Uso de CURSOR SQL;
* Paginado automático sin lógica manual de conteo de líneas  x medio de LINAGE COUNTER;
* Doble corte de control x medio de PERFORM-INLINE;
* Captura de fecha x medio de Funciones Intrínsecas;
* Manejo de errores centralizado en un subprograma (rutina) reutilizable mediante
código defensivo para evitar ABENDs — el programa intercepta errores en cada 
punto crítico (ON SIZE ERROR, control de SQLCODE, Declaratives).
Ante cualquier error: cierra lo que se pueda cerrar, emite un mensaje detallado 
por DISPLAY y termina con RC 9999 para que el operador sepa exactamente qué pasó 
y dónde.
