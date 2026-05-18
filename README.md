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
* Integración con **DSNTIAR** — ante errores DB2, el programa pasa el SQLCA
completo a la rutina (RUTERRBA), que internamente invoca la rutina IBM DSNTIAR para
formatear el mensaje de error en texto legible por el operador en el spool,
eliminando la necesidad de interpretar códigos numéricos.

*----------------------------------------------------------------------------------------------------------------------------------*   
NOTA SOBRE EL USO DE GO TO:
Su uso esta **segmentado exclusivamente** para manejar el flujo de ejecución dentro del **estado de error**.
No interfiere en el flujo de la lógica de negocio, el cual respeta la programación estructurada y la ejecución TOP-DOWN.   
*----------------------------------------------------------------------------------------------------------------------------------*   
NOTA SOBRE FILE STATUS: se declara directamente sobre WS-ERR-FILE-STATUS (variable de la COPY de rutina de error), eliminando el MOVE intermedio y estandarizando el manejo de errores en todos los programas que adopten esta arquitectura.   
*----------------------------------------------------------------------------------------------------------------------------------*
```mermaid
graph TD
    %% Configuración Estética Profesional
    classDef inicio_fin fill:#333,stroke:#303030,color:#fff,stroke-width:2px;
    classDef proceso fill:#f9f9f9,stroke:#888,color:#222;
    classDef db2 fill:#def0ff,stroke:#0066cc,color:#003366,stroke-dasharray: 3 3;
    classDef error fill:#fff0f0,stroke:#cc0000,color:#cc0000;

    Start((Inicio)) --> 1000[1000-INICIO]

    subgraph Bloque_Inicialización [1) Inicialización]
        1000 --> OpenFile[Abrir Archivo SALIDA]
        OpenFile --> OpenCursor[EXEC SQL OPEN Cursor]
        OpenCursor --> 2100-F[2100-LEER-CURSOR]
    end

    2100-F --> Loop{¿PGM-FIN?}

    subgraph Bloque_Proceso [2) Núcleo: Doble Corte de Control]
        Loop -- No --> Title[Grabar Títulos]
        Title --> DeptLoop{¿Mismo Depto?}
        
        DeptLoop -- Sí --> SexLoop{¿Mismo Sexo?}
        SexLoop -- Sí --> Detail[Grabar Detalle]
        Detail --> 2100-N[2100-LEER-CURSOR]
        2100-N --> SexLoop

        SexLoop -- No --> SubSex[Grabar Subtotal Sexo]
        SubSex --> DeptLoop

        DeptLoop -- No --> SubDept[Grabar Subtotal Depto]
        SubDept --> Loop
    end

    Loop -- Sí --> 3000[3000-FINAL]

    subgraph Bloque_Cierre [3) Cierre Ordenado]
        3000 --> CloseAll[Cerrar SALIDA y Cursor]
        CloseAll --> Stop((GOBACK))
    end

    subgraph Bloque_Excepciones [Manejo de Errores Global]
        ErrRoutine[2300-INVOCAR-RUTINA-ERROR] --> CallErr[CALL PGMERROR]
        CallErr --> SetFin[SET PGM-FIN TO TRUE]
        SetFin --> 3000
    end

    %% Aplicación de Estilos
    class Start,Stop inicio_fin;
    class OpenCursor,2100-F,2100-N db2;
    class ErrRoutine,CallErr,SetFin error;

```
<img width="2041" height="4757" alt="mermaid-diagram-2026-05-18-180241 (1)" src="https://github.com/user-attachments/assets/b6b57bfd-1d7f-4e3e-b0d0-ee85be009778" />


**CAPTURA DE SALIDA: REPORTE FINAL GENERADO EN ARCHIVO FÍSICO**   

<table>
  <tr>
    <td align="center"><b>EMULADOR WX3270</b></td>
    <td align="center"><b>VSCODE + ZOWE</b></td>
    <td align="center"><b>INTERFAZ WEB Z/OSMF</b></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/d11e3686-0a4d-4495-acd1-7fbd8b673a77" width="100%" alt="wx3270" /></td>
    <td><img src="https://github.com/user-attachments/assets/89a2b0f1-021f-47fa-bbf0-9cc16910cd19" width="100%" alt="VS Code + Zowe" /></td>
    <td><img src="https://github.com/user-attachments/assets/cc01cc14-13fc-4367-8e35-deb959d144b2" width="100%" alt="z/OSMF" /></td>
  </tr>
</table>

**CAPTURA DE SALIDA: REGISTRO DE ERROR EN SYSOUT (RUTINA 2300)**   

<table> 
  <tr>
    <th colspan="2" align="center" bgcolor="#222"><font color="#fff"><b>CAPTURA DE SALIDA: Reporte de Error SQL</b></font></th>
  </tr>
  <tr>
    <td align="center" width="50%"><b>EMULADOR WX3270</b></td>
    <td align="center" width="50%"><b>VSCODE + ZOWE</b></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/ba9932b1-f525-4a89-b37e-2132876441c4" width="100%" alt="wx3270 SQL" /></td>   
    <td><img src="https://github.com/user-attachments/assets/27cc499a-fdbb-4da8-8238-133724293f2a" width="100%" alt="wx3270 File Status" /></td>
  </tr>

  <!-- ESPACIO INTERMEDIO -->
  <tr><td colspan="2" style="border:none; height:20px;"></td></tr>

  <!-- BLOQUE 2: VSCODE + ZOWE -->
  <tr>
    <th colspan="2" align="center" bgcolor="#222"><font color="#fff"><b>CAPTURA DE SALIDA: Reporte File Status</b></font></th>
  </tr>
  <tr>
    <td align="center" width="50%"><b>EMULADOR WX3270</b></td>
    <td align="center" width="50%"><b>VSCODE + ZOWE</b></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/a911b9b8-62bc-44ee-9a78-6171d0c23a57" width="100%" alt="Zowe SQL" /></td>   
    <td><img src="https://github.com/user-attachments/assets/e9fc5537-4cba-4064-ac40-794da138b985" width="100%" alt="Zowe File Status" /></td>
  </tr>
</table>







