🔂 Proyecto como parte de mi especialización en **COBOL**.

Descripción:
Programa **Batch COBOL/DB2** desarrollado para entorno Mainframe (z/OS). El módulo ejecuta una consulta relacional mediante un JOIN de tablas y procesa los datos aplicando lógica de **Doble Corte de Control**, generando un reporte que muestra totalizadores y promedios.

Algunos puntos de diseño en el código:

* Estructura de INICIO-PROCESO-FINAL;
* Manejo de estados x medio de niveles 88;
* Uso de CURSOR SQL;
* Paginado automático x medio de LINAGE COUNTER;
* Centrado dinámico de subtítulos mediante FUNCTION TRIM y FUNCTION LENGTH
* Doble corte de control x medio de PERFORM-INLINE;
* Captura de fecha x medio de Función Intrínseca;
* Manejo de errores centralizado en un subprograma (rutina) reutilizable mediante
código defensivo para evitar ABENDs — el programa intercepta errores en cada
punto crítico (ON SIZE ERROR, DECLARATIVES, WHENEVER, variable indicadora de DB2, IS NUMERIC, ETC).
Ante cualquier error: cierra lo que se pueda cerrar, emite un mensaje detallado
por DISPLAY y termina con RC 9999 para que el operador sepa exactamente qué pasó
y dónde.

*----------------------------------------------------------------------------------------------------------------------------------*   
NOTA SOBRE EL USO DE GO TO:
Su uso esta **segmentado exclusivamente** para manejar el flujo de ejecucion dentro del **estado de error**.
No interfiere en el flujo de la logica de negocio, el cual respeta la programacion estructurada y la ejecucion TOP-DOWN.   
*----------------------------------------------------------------------------------------------------------------------------------*   
NOTA SOBRE FILE STATUS: se declara directamente sobre WS-ERR-FILE-STATUS de CPERROR, eliminando el MOVE intermedio y estandarizando el manejo de errores en todos los programas que adopten esta arquitectura.   
*----------------------------------------------------------------------------------------------------------------------------------*   
<br>
** CAPTURA DE SALIDA EMULADOR WX3270 **
   
<img width="1597" height="859" alt="Sin título" src="https://github.com/user-attachments/assets/d11e3686-0a4d-4495-acd1-7fbd8b673a77" />   

<br>
** CAPTURA DE SALIDA VSCODE + ZOWE **
   
<img width="1597" height="861" alt="Sin título (1)" src="https://github.com/user-attachments/assets/89a2b0f1-021f-47fa-bbf0-9cc16910cd19" />   

<br>
** CAPTURA DE SALIDA interfaz web de z/OSMF (z/OS Management Facility) **
   
<img width="1595" height="745" alt="Sin título (2)" src="https://github.com/user-attachments/assets/cc01cc14-13fc-4367-8e35-deb959d144b2" />   
   
<br>   

** CAPTURA DEL SPOOL POR FORZADO DE ERROR **

<br><img width="1597" height="865" alt="Sin título (1)" src="https://github.com/user-attachments/assets/8ed9b198-92f7-4076-a129-fe352416ec26" />

