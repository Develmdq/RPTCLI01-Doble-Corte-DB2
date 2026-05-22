🔂 Programa **COBOL Batch** (DB2).

**Qué resuelve**
Genera un reporte batch desde DB2 con datos agrupados, totales y promedios, usando lógica de doble corte de control.

**Enfoque de solución**
El problema se resuelve combinando tres capas:

1. Acceso a datos
   → SQL con CURSOR sobre DB2

2. Procesamiento en COBOL
   → lógica de doble corte de control
   → manejo de estados con niveles 88

3. Presentación
   → reporte paginado con LINAGE COUNTER

**Algunos puntos de diseño en el código**

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
   %% Configuración de Colores Profesionales
    classDef inicio_fin fill:#333,stroke:#000,color:#fff,stroke-width:2px;
    classDef proceso fill:#f4f4f4,stroke:#666,color:#000;
    classDef db2 fill:#d1e9ff,stroke:#005fb8,color:#000;
    classDef error fill:#ffebee,stroke:#c62828,color:#c62828

    Start((Inicio)) --> Init[1000-INICIO]

    subgraph "Inicialización"
        Init --> OpenFile[Abrir Archivo SALIDA]
        OpenFile --> OpenCursor[EXEC SQL OPEN Cursor]
        OpenCursor --> FirstRead[2100-LEER-CURSOR]
    end

    FirstRead --> Loop{¿PGM-FIN?}

    subgraph "Corte de Control (2000-PROCESO)"
        Loop -- No --> Title[Grabar Títulos]
        Title --> DeptLoop{Mismo Depto?}
        DeptLoop -- Sí --> SexLoop{Mismo Sexo?}
        SexLoop -- Sí --> Detail[Grabar Detalle]
        Detail --> NextRead[2100-LEER-CURSOR]
        NextRead --> SexLoop

        SexLoop -- No --> SubSex[Grabar Subtotal Sexo]
        SubSex --> DeptLoop

        DeptLoop -- No --> SubDept[Grabar Subtotal Depto]
        SubDept --> Loop
    end

    Loop -- Sí --> Final[3000-FINAL]

    subgraph "Cierre Ordenado"
        Final --> CloseAll[Cerrar SALIDA y Cursor]
        CloseAll --> Stop((GOBACK))
    end

    %% Flujo de Errores
    OpenFile -. Error .-> ErrRoutine
    OpenCursor -. Error .-> ErrRoutine
    NextRead -. Error .-> ErrRoutine
    Detail -. Error .-> ErrRoutine

    subgraph "Manejo de Excepciones"
        ErrRoutine[2300-INVOCAR-RUTINA-ERROR] --> CallErr[CALL PGMERROR]
        CallErr --> SetFin[SET PGM-FIN TO TRUE]
        SetFin --> Final
    end

    %% Asignación de estilos
    class Start,Stop inicio_fin;
    class ErrRoutine,CallErr error;
    class OpenCursor,NextRead,FirstRead db2;
```
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
** CAPTURA ERROR ARCHIVO **


<br>
** CAPTURA ERROR SQL **
<img width="1319" height="819" alt="err2 (1)" src="https://github.com/user-attachments/assets/ba9932b1-f525-4a89-b37e-2132876441c4" />
<img width="1329" height="821" alt="err1 (1)" src="https://github.com/user-attachments/assets/27cc499a-fdbb-4da8-8238-133724293f2a" />



