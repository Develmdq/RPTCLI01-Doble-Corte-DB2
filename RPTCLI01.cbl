      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTCLI01.

      ******************************************************************
      *       PGM DE CORTE DE CONTROL DOBLE + DB2 + IMPRESION          *
      ******************************************************************
      * AUTOR: MARCET EDUARDO                        FECHA  20/01/2026 *
      ******************************************************************

      ******************************************************************
       ENVIRONMENT DIVISION.
      ******************************************************************
      *----------------------*
       CONFIGURATION SECTION.
      *----------------------*
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.

      *---------------------*
       INPUT-OUTPUT SECTION.
      *---------------------*
       FILE-CONTROL.
             SELECT SALIDA ASSIGN DDSALE
             FILE STATUS IS WS-ERR-FS.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
      *-------------*
       FILE SECTION.
      *-------------*
       FD SALIDA
           BLOCK CONTAINS 0 RECORDS
           RECORDING MODE IS F
           LINAGE IS 60 LINES

       01 REG-SALIDA            PIC X(132).

      *------------------------*
       WORKING-STORAGE SECTION.
      *------------------------*
       77 FILLER                PIC X(26)   VALUE '* INICIO WS *'.

      * INDICADOR DE FIN DEL PROGRAMA *
       01 WS-PROGRAMA           PIC X(1)    VALUE 'A'.
          88 PGM-FIN                        VALUE 'F'.

      * INDICADOR DE OPERACION EN CURSO *
       01 WS-OPERACION          PIC X(1)    VALUE SPACE.
          88 ABRIENDO-ARCHIVO               VALUE 'O'.
          88 GRABANDO-ARCHIVO               VALUE 'W'.
          88 CERRANDO-ARCHIVO               VALUE 'C'.
          88 ABRIENDO-CURSOR                VALUE 'O'.
          88 LEYENDO-CURSOR                 VALUE 'R'.
          88 CERRANDO-CURSOR                VALUE 'C'.

      * INDICADOR DE LINEA A IMPRIMIR *
       01 WS-IND-LINEA          PIC 9       VALUE ZEROS.
          88 IND-TITULO                     VALUE 1.
          88 IND-SUBTITULO-DEPT             VALUE 2.
          88 IND-SUBTITULO-SEXO             VALUE 3.
          88 IND-COLUMNAS                   VALUE 4.
          88 IND-DETALLE                    VALUE 5.
          88 IND-SUBTOTAL-SEXO              VALUE 6.
          88 IND-SUBTOTAL-DEPT              VALUE 7.
          88 IND-TOTAL-GRAL                 VALUE 8.

      * VALORES ANTERIORES PARA CONTROL DE CORTE *
       01 WS-DATO-ANTERIOR.
          05 WS-WORKDEPT-ANT    PIC X(3)    VALUE SPACES.
          05 WS-SEX-ANT         PIC X       VALUE SPACES.

      * CONTADORES Y ACUMULADORES *
       01 WS-CONTADORES-ACUMULADORES.
          05 WS-CONT-SEXO       PIC 9(4)    VALUE ZEROS.
          05 WS-ACUM-SEXO       PIC 9(7)V99 VALUE ZEROS.
          05 WS-CONT-DEPTO      PIC 9(5)    VALUE ZEROS.
          05 WS-ACUM-DEPTO      PIC 9(7)V99 VALUE ZEROS.
          05 WS-CONT-TOTAL      PIC 9(5)    VALUE ZEROS.
          05 WS-ACUM-TOTAL      PIC 9(7)V99 VALUE ZEROS.
          05 WS-CNT-LEIDOS      PIC 9(4)    VALUE ZEROS.
          05 WS-CNT-GRABADOS    PIC 9(4)    VALUE ZEROS.
          05 WS-NUM-PAGINA      PIC 9(4)    VALUE ZEROS.

       01 WS-INDICADORES-NULL.
          05 IND-SALARY         PIC S9(4)   USAGE COMP-5.

      * INCLUDE SQLCA Y DCLGEN *
           EXEC SQL INCLUDE SQLCA    END-EXEC.
           EXEC SQL INCLUDE DCLGEMP  END-EXEC.
           EXEC SQL INCLUDE DCLGDEPT END-EXEC.

      * DECLARACION DE CURSOR *
           EXEC SQL
             DECLARE EMPDEPT-CURSOR CURSOR FOR
               SELECT E.EMPNO,
                      E.FIRSTNME,
                      E.LASTNAME,
                      E.WORKDEPT,
                      D.DEPTNAME,
                      E.SEX,
                      E.SALARY
               FROM IBMUSER.EMP E,
                      IBMUSER.DEPT D
               WHERE E.WORKDEPT = D.DEPTNO
               ORDER BY E.WORKDEPT, E.SEX
           END-EXEC.

      * COPYs ARCHIVO DE SALIDA y ESTRUCTURA DE ERRORES  *
       COPY CPRPT001.
       COPY CPERROR.

       77 FILLER                 PIC X(26)  VALUE '* FINAL  WS *'.

      ******************************************************************
       PROCEDURE DIVISION.
      ******************************************************************
      *----------------------------------------------------------------*
      * NOTA SOBRE EL USO DE GO TO:                                    *
      * Su uso esta segmentado exclusivamente para manejar el flujo    *
      * de ejecucion dentro del estado de error. No interfiere en el   *
      * flujo de la logica de negocio, el cual respeta la              *
      * programacion estructurada y la ejecucion TOP-DOWN.             *
      *----------------------------------------------------------------*
      *----------------------------------------------------------------*
      * MANEJO DE ERRORES                                              *
      * - DECLARATIVES: Captura errores de E/S en archivo de salida    *
      * - WHENEVER SQLERROR: Captura errores SQL                       *
      * En ambos casos se deriva a 2300-INVOCAR-RUTINA-ERROR que:      *
      *   1. Carga WS-ERROR con el contexto del error                  *
      *   2. Llama a PGMERROR via CALL                                 *
      *   3. Activa PGM-FIN para encauzar el flujo al cierre           *
      * WS-OPERACION refleja el estado en curso al momento del error   *
      * garantizando un cierre ordenado en 3000-FINAL                  *
      *----------------------------------------------------------------*
       DECLARATIVES.
       ERROR-SALIDA SECTION.
           USE AFTER STANDARD ERROR PROCEDURE ON OUTPUT.
       MANEJADOR-ERROR-SALIDA.
           GO TO 2300-INVOCAR-RUTINA-ERROR
           .
       END DECLARATIVES.

           EXEC SQL WHENEVER SQLERROR
              GO TO 2300-INVOCAR-RUTINA-ERROR
           END-EXEC.

       MAIN-PROGRAM.
           PERFORM 1000-I-INICIO  THRU 1000-F-INICIO
           PERFORM 2000-I-PROCESO THRU 2000-F-PROCESO UNTIL PGM-FIN
           PERFORM 3000-I-FINAL   THRU 3000-F-FINAL
           .
       F-MAIN-PROGRAM. GOBACK.
      ******************************************************************
      *                 CUERPO PRINCIPAL DE INICIO                     *
      ******************************************************************
      * Por medio de niveles 88 de 01 WS-OPERACION + SET se crea un    *
      * estado general y junto a EVALUATE TRUE se maneja el fujo.      *
      ******************************************************************
       1000-I-INICIO.
           MOVE FUNCTION
                FORMATTED-CURRENT-DATE("%d/%m/%Y") TO RPT-TIT-FECHA

           SET ABRIENDO-ARCHIVO TO TRUE       *> Apertura Archivo Salida
           OPEN OUTPUT SALIDA

           SET ABRIENDO-CURSOR TO TRUE             *> Apertura de Cursor
           EXEC SQL OPEN EMPDEPT-CURSOR END-EXEC
           PERFORM 2100-I-LEER-CURSOR THRU  2100-F-LEER-CURSOR
           .
       1000-F-INICIO.
           EXIT.
      ******************************************************************
      *                 CUERPO PRINCIPAL DE PROCESOS                   *
      ******************************************************************
       2000-I-PROCESO.
           INITIALIZE WS-CONTADORES-ACUMULADORES
           SET IND-TITULO TO TRUE                     *> Grabar titulo
           PERFORM 2200-I-PROC-SALIDA THRU 2200-F-PROC-SALIDA
          *> ---------------| INICIO PERFORM EXTERIOR |---------------<*
           PERFORM UNTIL PGM-FIN
              MOVE WS-WORKDEPT TO WS-WORKDEPT-ANT  *> Mover Key superior
              INITIALIZE WS-CONT-DEPTO WS-ACUM-DEPTO
              SET IND-SUBTITULO-DEPT TO TRUE     *> Grabar Subtitulo Dep
              PERFORM 2200-I-PROC-SALIDA THRU 2200-F-PROC-SALIDA
             *> -----------| INICIO PERFORM CORTE SUPERIOR |----------<*
              PERFORM UNTIL WS-WORKDEPT NOT = WS-WORKDEPT-ANT OR PGM-FIN
                 MOVE WS-SEX TO WS-SEX-ANT         *> Mover Key inferior
                 INITIALIZE WS-CONT-SEXO WS-ACUM-SEXO
                 SET IND-SUBTITULO-SEXO TO TRUE *> Grabar Subtitulo Sexo
                 PERFORM 2200-I-PROC-SALIDA THRU 2200-F-PROC-SALIDA
                *> --------| INICIO PERFORM CORTE INFERIOR |----------<*
                 PERFORM UNTIL WS-WORKDEPT NOT = WS-WORKDEPT-ANT
                               OR WS-SEX NOT = WS-SEX-ANT OR PGM-FIN
                    ADD 1 TO WS-CONT-SEXO
                    ADD WS-SALARY TO WS-ACUM-SEXO
                    SET IND-DETALLE TO TRUE            *> Grabar Detalle
                    PERFORM 2200-I-PROC-SALIDA THRU 2200-F-PROC-SALIDA
                    PERFORM 2100-I-LEER-CURSOR THRU  2100-F-LEER-CURSOR
                 END-PERFORM
                 *> --------| FINAL PERFORM CORTE INFERIOR |--------- <*
                 ADD WS-CONT-SEXO TO WS-CONT-DEPTO
                 ADD WS-ACUM-SEXO TO WS-ACUM-DEPTO
                 SET IND-SUBTOTAL-SEXO TO TRUE
                 PERFORM 2200-I-PROC-SALIDA THRU 2200-F-PROC-SALIDA
              END-PERFORM
             *> ------------| FINAL PERFORM CORTE SUPERIOR |--------- <*
              ADD WS-CONT-DEPTO TO WS-CONT-TOTAL
              ADD WS-ACUM-DEPTO TO WS-ACUM-TOTAL
              SET IND-SUBTOTAL-DEPT TO TRUE *> Imprimir Subtotal Dept
              PERFORM 2200-I-PROC-SALIDA THRU 2200-F-PROC-SALIDA
           END-PERFORM
          *> -----------------| FINAL PERFORM EXTERIOR |------------- <*
           SET IND-TOTAL-GRAL TO TRUE          *> Imprimir Gran Total
           PERFORM 2200-I-PROC-SALIDA THRU 2200-F-PROC-SALIDA
           .
       2000-F-PROCESO. EXIT.

       2100-I-LEER-CURSOR.

           SET LEYENDO-CURSOR TO TRUE

               EXEC SQL FETCH EMPDEPT-CURSOR
                   INTO :WS-EMPNO,
                        :WS-FIRSTNME,
                        :WS-LASTNAME,
                        :WS-WORKDEPT,
                        :WS-SEX,
                        :WS-SALARY :IND-SALARY
               END-EXEC

           IF SQLCODE = +100 SET PGM-FIN TO TRUE END-IF

      * Control tipo de dato
           EVALUATE TRUE
              WHEN WS-SALARY NOT NUMERIC OR IND-SALARY < 0
              SET ERR-TIPO-DATO  TO TRUE
              GO TO 2300-INVOCAR-RUTINA-ERROR
           END-EVALUATE

           ADD 1 TO WS-CNT-LEIDOS
           .
       2100-F-LEER-CURSOR.  EXIT.

       2200-I-PROC-SALIDA.

           SET GRABANDO-ARCHIVO TO TRUE

           EVALUATE TRUE
           WHEN IND-TITULO
              PERFORM 2210-I-GRABAR-TITULO THRU 2210-F-GRABAR-TITULO
           WHEN IND-SUBTITULO-DEPT
              PERFORM 2220-I-GRABAR-SUBTITULO-DEPT
                 THRU 2220-F-GRABAR-SUBTITULO-DEPT
           WHEN IND-SUBTITULO-SEXO
              PERFORM 2230-I-GRABAR-SUBTITULO-SEXO
                 THRU 2230-F-GRABAR-SUBTITULO-SEXO
           WHEN IND-DETALLE
              PERFORM 2240-I-GRABAR-DETALLE THRU 2240-F-GRABAR-DETALLE
           WHEN IND-SUBTOTAL-SEXO
              PERFORM 2250-I-GRABAR-SUBTOTAL-SEXO
                 THRU 2250-F-GRABAR-SUBTOTAL-SEXO
           WHEN IND-SUBTOTAL-DEPT
              PERFORM 2260-I-GRABAR-SUBTOTAL-DEPT
                 THRU 2260-F-GRABAR-SUBTOTAL-DEPT
           WHEN IND-TOTAL-GRAL
              PERFORM 2270-I-GRABAR-TOTAL THRU 2270-F-GRABAR-TOTAL
           END-EVALUATE

           ADD 1 TO WS-CNT-GRABADOS
           .
       2200-F-PROC-SALIDA.

       2210-I-GRABAR-TITULO.
           ADD 1 TO WS-NUM-PAGINA
           MOVE WS-NUM-PAGINA TO RPT-TIT-PAGINA
           WRITE REG-SALIDA FROM RPT-BORDE-ASTERISCO
           WRITE REG-SALIDA FROM RPT-TITULO
           WRITE REG-SALIDA FROM RPT-BORDE-ASTERISCO
           .
       2210-F-GRABAR-TITULO.  EXIT.

       2220-I-GRABAR-SUBTITULO-DEPT.
           MOVE  WS-WORKDEPT      TO RPT-CDP-DEPTNO
           MOVE  WS-DEPTNAME-TEXT TO RPT-CDP-DEPTNAME
           WRITE REG-SALIDA FROM RPT-CAB-DEPT
           WRITE REG-SALIDA FROM RPT-BORDE-GUION
           .
       2220-F-GRABAR-SUBTITULO-DEPT.  EXIT.

       2230-I-GRABAR-SUBTITULO-SEXO.
           EVALUATE WS-SEX
              WHEN 'F'
                MOVE 'FEMENINO ' TO RPT-CSX-DESC-SEXO
              WHEN 'M'
                MOVE 'MASCULINO' TO RPT-CSX-DESC-SEXO
              WHEN 'O'
                MOVE 'OTRO     ' TO RPT-CSX-DESC-SEXO
           END-EVALUATE
           WRITE REG-SALIDA FROM RPT-CAB-SEXO
           WRITE REG-SALIDA FROM RPT-BORDE-GUION
           .
       2230-F-GRABAR-SUBTITULO-SEXO.  EXIT.

       2240-I-GRABAR-DETALLE.
           MOVE WS-EMPNO         TO RPT-DET-EMPNO
           MOVE WS-FIRSTNME-TEXT TO RPT-DET-NOMBRE
           MOVE WS-LASTNAME-TEXT TO RPT-DET-APELLIDO
           MOVE WS-SALARY        TO RPT-DET-SALARIO
           WRITE REG-SALIDA FROM RPT-DETALLE
           .
       2240-F-GRABAR-DETALLE.  EXIT.

       2250-I-GRABAR-SUBTOTAL-SEXO.
           WRITE REG-SALIDA FROM RPT-BORDE-IGUAL
           COMPUTE RPT-SSX-PROMEDIO ROUNDED =
                        WS-ACUM-SEXO / WS-CONT-SEXO
           MOVE WS-SEX       TO RPT-SSX-SEXO
           MOVE WS-CONT-SEXO TO RPT-SSX-CANTIDAD
           WRITE REG-SALIDA FROM RPT-SUBTOTAL-SEXO
           WRITE REG-SALIDA FROM RPT-BORDE-IGUAL
           .
       2250-F-GRABAR-SUBTOTAL-SEXO.  EXIT.

       2260-I-GRABAR-SUBTOTAL-DEPT.
           WRITE REG-SALIDA FROM RPT-BORDE-IGUAL
           COMPUTE RPT-TDP-PROMEDIO ROUNDED =
                   WS-ACUM-DEPTO / WS-CONT-DEPTO
           MOVE WS-WORKDEPT-ANT TO RPT-TDP-DEPTNO
           MOVE WS-CONT-DEPTO   TO RPT-TDP-CANTIDAD
           WRITE REG-SALIDA FROM RPT-LINEA-BLANCA
           WRITE REG-SALIDA FROM RPT-TOTAL-DEPT
           WRITE REG-SALIDA FROM RPT-BORDE-ASTERISCO
           .
       2260-F-GRABAR-SUBTOTAL-DEPT.  EXIT.

       2270-I-GRABAR-TOTAL.
           COMPUTE RPT-TGR-PROMEDIO ROUNDED =
                   WS-ACUM-TOTAL / WS-CONT-TOTAL
           MOVE WS-CONT-TOTAL TO RPT-TGR-CANTIDAD
           WRITE REG-SALIDA FROM RPT-LINEA-BLANCA
           WRITE REG-SALIDA FROM RPT-TOTAL-GRAL
           WRITE REG-SALIDA FROM RPT-LINEA-BLANCA
           .
       2270-F-GRABAR-TOTAL.  EXIT.

       2300-INVOCAR-RUTINA-ERROR.
           MOVE 'RPTCLI01'   TO WS-ERR-PROGRAMA
           MOVE SQLCODE      TO WS-ERR-SQLCODE
           MOVE 9999         TO RETURN-CODE
           SET ERR-ES-BATCH  TO TRUE
           CALL 'PGMERROR'   USING WS-ERROR
           SET PGM-FIN       TO TRUE

           EVALUATE TRUE
              WHEN ABRIENDO-ARCHIVO OR ABRIENDO-CURSOR
                   GO TO 1000-F-INICIO
              WHEN GRABANDO-ARCHIVO OR LEYENDO-CURSOR
                   GO TO 2000-F-PROCESO
              WHEN ERR-TIPO-DATO
                   GO TO 2100-F-LEER-CURSOR
              WHEN CERRANDO-ARCHIVO OR CERRANDO-CURSOR
                   GO TO 3000-F-FINAL
           END-EVALUATE
           .

      ******************************************************************
      *                    CUERPO PRINCIPAL FINAL                      *
      ******************************************************************
       3000-I-FINAL.
           IF RETURN-CODE = 9999
              EVALUATE TRUE
                 WHEN ABRIENDO-ARCHIVO
                   CONTINUE
                 WHEN ABRIENDO-CURSOR
                   CLOSE SALIDA
                 WHEN LEYENDO-CURSOR OR GRABANDO-ARCHIVO
                   CLOSE SALIDA
                   EXEC SQL CLOSE EMPDEPT-CURSOR END-EXEC
                 WHEN CERRANDO-ARCHIVO OR CERRANDO-CURSOR
                   CONTINUE
              END-EVALUATE
           ELSE
             CLOSE SALIDA
             EXEC SQL CLOSE EMPDEPT-CURSOR END-EXEC
           END-IF
           .
       3000-F-FINAL. EXIT.
      *