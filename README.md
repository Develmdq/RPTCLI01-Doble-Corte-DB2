🚧 Proyecto en desarrollo como parte de mi especialización en arquitectura COBOL".

Descripción:
Programa Batch COBOL/DB2 desarrollado para entorno Mainframe (z/OS). El módulo ejecuta una consulta relacional mediante un JOIN de tablas y procesa los datos aplicando lógica de Doble Corte de Control, generando un reporte que muestra totalizadores y promedios.

Algunos puntos de diseño en el código:

* Estructura de INICIO-PROCESO-FINAL;
* Manejo de estados x medio de niveles 88;
* Uso de CURSOR SQL;
* Paginado automático x medio de LINAGE COUNTER;
* Doble corte de control x medio de PERFORM-INLINE;
* Captura de fecha x medio de Funció Intrínseca;
* Manejo de errores centralizado en un subprograma (rutina) reutilizable mediante
código defensivo para evitar ABENDs — el programa intercepta errores en cada 
punto crítico (ON SIZE ERROR, DECLARATIVES, WHENEVER).
Ante cualquier error: cierra lo que se pueda cerrar, emite un mensaje detallado 
por DISPLAY y termina con RC 9999 para que el operador sepa exactamente qué pasó 
y dónde.
