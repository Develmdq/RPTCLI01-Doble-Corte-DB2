      *************************************************************
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
             FILE STATUS IS WS-FS-SALIDA.                                
                                                                        
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
           WITH FOOTING AT 55
           LINES AT TOP 3
           LINES AT BOTTOM 2.                                     
                                                                        
       01 REG-SALIDA             PIC X(132).                           
                                                                        
      *------------------------*                                        
       WORKING-STORAGE SECTION.                                         
      *------------------------*                                        
       77 FILLER                 PIC X(26)  VALUE '* INICIO WS *'.       
                                                                        
      * CONTROL FILES STATUS SALIDA *                                   
       01 WS-FS-SALIDA           PIC X(2).                                  
          88 WS-FSS-OK                      VALUE '00'. 
                                                                        
      * INDICADOR DE CORTE DEL PROGRAMA *
       01 WS-PROGRAMA            PIC X(1)   VALUE 'A'.
          88 PGM-FIN                        VALUE 'F'.                 
                      
      * INDICADOR DE OPERACION EN CURSO *
       01 WS-OPERACION           PIC X(1)   VALUE SPACE.
          88 CURSOR-ABIERTO                 VALUE 'A'.
          88 CURSOR-LECTURA                 VALUE 'L'.
          88 CURSOR-CERRADO                 VALUE 'C'.
          88 SALIDA-ABIERTO                 VALUE 'S'.
          88 SALIDA-GRABAR                  VALUE 'G'.
          88 SALIDA-CERRADO                 VALUE 'X'.
                     
      * INDICADOR DE LINEA A IMPRIMIR *
       01 WS-IND-LINEA           PIC 9      VALUE 0.
          88 IND-TITULO                     VALUE 1.
          88 IND-SUBTITULO-DEPT             VALUE 2.
          88 IND-SUBTITULO-SEXO             VALUE 3.
          88 IND-COLUMNAS                   VALUE 4.
          88 IND-DETALLE                    VALUE 5.
          88 IND-SUBTOTAL-SEXO              VALUE 6.
          88 IND-TOTAL-DEPT                 VALUE 7.                    
                                                                        
      * VALORES ANTERIORES PARA CONTROL DE CORTE *                 
       01 WS-DATO-ANTERIOR.                                             
          05 WS-DEPT-ANT         PIC X(4)   VALUE SPACES.               
          05 WS-SEXO-ANT         PIC X      VALUE SPACES.               
                                                                        
      * CONTADORES DE CORTE *
       01 WS-CONTADORES-CORTE.
          05 WS-CNT-SEXO         PIC 9(4)   VALUE ZEROS.
          05 WS-CNT-DEPT         PIC 9(4)   VALUE ZEROS.

      * CONTADORES GLOBALES *
       01 WS-CONTADORES-TOTAL.
          05 WS-CNT-LEIDOS       PIC 9(4)   VALUE ZEROS.
          05 WS-CNT-IMPRESOS     PIC 9(4)   VALUE ZEROS.
                                                                       
       77 WS-MASCARA             PIC Z(4)   VALUE ZEROS.                
                                                                        
      * INCLUDE SQLCA Y DCLGEN *                      
           EXEC SQL INCLUDE SQLCA END-EXEC.                        
           EXEC SQL INCLUDE DCLGEMP END-EXEC. 
           EXEC SQL INCLUDE DCLGDEPT END-EXEC.                    
                                                                        
      * DECLARACION DE CURSOR - CLIENTES POR ANIO Y SEXO *
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
       DECLARATIVES.
      *----------------------------------------------------------------*
      * SECCION DE ERROR I/O — ARCHIVO SALIDA                          *
      *----------------------------------------------------------------*
       ERROR-SALIDA SECTION.
           USE AFTER STANDARD ERROR PROCEDURE ON OUTPUT.
       MANEJADOR-ERROR-SALIDA.
           MOVE 'RPTCLI01' TO WS-ERR-PROGRAMA
           MOVE WS-OPERACION TO WS-ERR-OPERACION
           MOVE WS-FS-SALIDA TO WS-ERR-FILE-STATUS
           SET ERR-ES-BATCH TO TRUE
           CALL 'PGMERROR' USING WS-ERROR
           SET PGM-FIN TO TRUE
           .
       END DECLARATIVES.                                           
                                                                        
           EXEC SQL WHENEVER SQLERROR CONTINUE END-EXEC               
           EXEC SQL WHENEVER NOT FOUND CONTINUE END-EXEC.  
                                                                        
       MAIN-PROGRAM.                                                    
                                                                        
           PERFORM 1000-I-INICIO THRU 1000-F-INICIO                    
           PERFORM 2000-I-PROCESO THRU 2000-F-PROCESO UNTIL PGM-FIN 
           PERFORM 3000-I-FINAL THRU 3000-F-FINAL                     
           .                                                            
       F-MAIN-PROGRAM. 
           GOBACK.                                          
                                                                        
      ******************************************************************
      *                 CUERPO PRINCIPAL DE INICIO                     *
      ******************************************************************
      * POR MEDIO DE NIVELES 88 + EL USO DE SET PARA ACTIVAR EL VALOR +*
      * EVALUATE TRUE SE MANEJA EL FLUJO DE EJECUCION                  *
      ******************************************************************
                                                                        
       1000-I-INICIO.

           MOVE FUNCTION FORMATTED-CURRENT-DATE("%d/%m/%Y")
              TO WS-RPT-FECHA

           INITIALIZE WS-CONTADORES-TOTAL
                      WS-CONTADORES-CORTE
                      WS-ACUMULADORES-TOTAL
                      WS-ACUMULADORES-CORTE

                                                                       
           SET WS-OPEN-SFILE TO TRUE         *> APERTURA ARCHIVO SALIDA 
           OPEN OUTPUT SALIDA                                           
                                                                        
           SET WS-OPEN-CURSOR TO TRUE         *> APERTURA DE CURSOR     
           EXEC SQL OPEN EMPDEPT-CURSOR END-EXEC                                  
           EXIT PARAGRAPH.    


           .
       1000-F-INICIO. 
           EXIT.                                           
                                                                        
      ******************************************************************
      *                 CUERPO PRINCIPAL DE PROCESOS                   *
      ******************************************************************
                                                                        
       2000-I-PROCESO.                                                  
                                                                        
           PERFORM 2100-ABRIR-RECURSOS                                  
           PERFORM 2200-LEER-CURSOR                                     
                                                                        
      *> -----------------| INICIO PERFORM EXTERIOR |------------------*
                                                                        
           PERFORM UNTIL WS-PGM-FIN                                     
                                                                        
                   MOVE WS-ANIO-NAC TO WS-ANIO-ANT*> MOVER KEY SUPERIOR 
                                                                        
                   INITIALIZE WS-CLI-ANIO                                     
                                                                        
                   SET WS-LINEA-SUBTITULO TO TRUE  *> IMPRIMIR SUBTITULO
                   PERFORM 2300-GRABAR-SALIDA                                 
                                                                        
      *> --------------| INICIO PERFORM CORTE SUPERIOR |---------------*
                                                                        
                   PERFORM UNTIL WS-ANIO-NAC NOT = WS-ANIO-ANT OR
                      WS-PGM-FIN    
                                                                        
                           MOVE WT-SEXO TO WS-SEXO-ANT
                                                   *> MOVER KEY INFERIOR
                                                                        
                           INITIALIZE WS-CLI-SEX                                      
                                                                        
                           SET WS-LINEA-SUBTITULO-2 TO TRUE
                                                  *> IMPRIMIR SUBTITULO 
                           PERFORM 2300-GRABAR-SALIDA                                 
                                                                        
                           SET WS-LINEA-COLUMNAS TO TRUE
                                                    *> IMPRIMIR COLUMNAS
                           PERFORM 2300-GRABAR-SALIDA                                 
                                                                        
      *> --------------| INICIO PERFORM CORTE INFERIOR |---------------*
                                                                        
                           PERFORM UNTIL WS-ANIO-NAC NOT = WS-ANIO-ANT
                              OR
                              WT-SEXO NOT = WS-SEXO-ANT OR WS-PGM-FIN  
                                                                        
                                   ADD 1 TO WS-CLI-SEX                                     
                                   ADD 1 TO WS-CLI-ANIO                                    
                                   ADD 1 TO WS-TOTAL-IMPRES                                
                                                                        
                                   SET WS-LINEA-DETALLE TO TRUE
                                                   *> IMPRIMIR DETALLES 
                                   PERFORM 2300-GRABAR-SALIDA                               
                                                                        
                                   SET WS-FETCH-CURSOR TO TRUE
                                                   *> LECTURA SIGUIENTE 
                                   PERFORM 2200-LEER-CURSOR                                 
                                                                        
                           END-PERFORM
                           *> ---| FINAL PERFORM CORTE INFERIOR |--- <* 
                                                                        
                           SET WS-LINEA-SUBTOTAL TO TRUE
                                                    *> IMPRIMIR SUBTOTAL
                           PERFORM 2300-GRABAR-SALIDA                               
                                                                        
                   END-PERFORM
                         *> -----| FINAL PERFORM CORTE SUPERIOR |--- <* 
                                                                        
                   SET WS-LINEA-TOTALES TO TRUE     *> IMPRIMIR TOTALES 
                   PERFORM 2300-GRABAR-SALIDA                                 
                                                                        
           END-PERFORM *> -------| FINAL PERFORM EXTERIOR |--------- <* 
           EXIT PARAGRAPH.                                              
                                                                                                                 
                                                                        
       2200-LEER-CURSOR.                                                
                                                                        
           SET WS-FETCH-CURSOR TO TRUE                                  
                                                                        
               EXEC SQL FETCH ITEM
                   INTO :WT-NROCLI,
                        :WT-NOMAPE,
                        :WT-FECNAC,
                        :WT-SEXO
               END-EXEC                                                 
                                                                        
           MOVE WT-FECNAC(1:4) TO WS-ANIO-NAC       *> CAPTURA SOLO ANIO
           ADD 1 TO WS-TOTAL-LEIDOS                                     
           EXIT PARAGRAPH.                                              
                                                                        
       2300-GRABAR-SALIDA.                                              
                                                                        
           SET WS-WRITE-SFILE TO TRUE                                   
                                                                        
           IF LINAGE-COUNTER = 1                                        
              ADD 1 TO WS-NUM-PAG                          
              WRITE REG-SALIDA FROM WS-TITULO                         
              WRITE REG-SALIDA FROM WS-LINEA-VACIA                    
           END-IF                                                       
                                                                        
           EVALUATE WT-SEXO                                             
           WHEN 'F'                                                   
                MOVE 'FEMENINO ' TO WS-SEXO-COPY                    
           WHEN 'M'                                                   
                MOVE 'MASCULINO' TO WS-SEXO-COPY                    
           WHEN 'O'                                                   
                MOVE 'OTRO     ' TO WS-SEXO-COPY                    
           END-EVALUATE                                                 
                                                                        
           EVALUATE TRUE                                                
           WHEN WS-LINEA-SUBTITULO                                    
                WRITE REG-SALIDA FROM WS-SUBTITULO                  
           WHEN WS-LINEA-SUBTITULO-2                                  
                MOVE WS-SEXO-COPY TO WS-SEXO-COP2                  
                WRITE REG-SALIDA FROM WS-SUBTITULO-2                
           WHEN WS-LINEA-COLUMNAS                                     
                WRITE REG-SALIDA FROM WS-COLUMNAS                   
           WHEN WS-LINEA-DETALLE                                      
                MOVE WT-NROCLI TO REG-NROCLI                    
                MOVE WT-NOMAPE TO REG-NOMAPE                    
                MOVE WT-FECNAC TO REG-FECNAC                    
                MOVE WT-SEXO TO REG-SEXO                      
                WRITE REG-SALIDA FROM WS-REG-SALIDA                 
           WHEN WS-LINEA-SUBTOTAL                                     
                MOVE WS-CLI-SEX TO WS-CLI-SEX-2                  
                WRITE REG-SALIDA FROM WS-SUBTOTALES                 
           WHEN WS-LINEA-TOTALES                                      
                MOVE WS-ANIO-ANT TO WS-ANIO-NA-2                  
                MOVE WS-CLI-ANIO TO WS-CLI-ANIO2                  
                WRITE REG-SALIDA FROM WS-TOTALES-COPY               
           END-EVALUATE                                                 
                                                                        
           WRITE REG-SALIDA FROM WS-LINEA-VACIA                
                                                                        
           IF WS-FSS-OK                                                 
              SET WS-FETCH-CURSOR TO TRUE                            
           END-IF                                                       
           EXIT PARAGRAPH.                                              
                                                                        
       2400-CERRAR-CURSOR.                                              
                                                                        
           EXEC SQL WHENEVER SQLERROR CONTINUE END-EXEC.                
                                                                        
           IF SQLCODE < 0                                               
              IF WS-FETCH-CURSOR                                       
                 SET WS-CLOSE-CURSOR TO TRUE                            
                 EXEC SQL CLOSE ITEM END-EXEC                           
              END-IF                                                   
              DISPLAY WS-ACCION SQLCODE                                
              MOVE 9999 TO RETURN-CODE                                 
           ELSE                                                         
              IF WS-TOTAL-LEIDOS = 0                                   
                 DISPLAY 'CONSULTA SIN RESULTADOS'                      
              END-IF                                                   
              SET WS-PGM-FIN TO TRUE                              
              SET WS-CLOSE-CURSOR TO TRUE                              
               EXEC SQL CLOSE ITEM END-EXEC                             
           END-IF                                                       
           EXIT PARAGRAPH.                                              
                                                                        
       2000-F-PROCESO. 
           EXIT.                                            
                                                                        
      ******************************************************************
      *                    CUERPO PRINCIPAL FINAL                      *
      ******************************************************************
       3000-I-FINAL.                                                    
                                                                        
           IF WS-TOTAL-LEIDOS > 0 AND SQLCODE = 0 AND WS-FSS-OK         
              MOVE WS-TOTAL-LEIDOS TO WS-MASCARA                        
              DISPLAY 'TOTAL DE REGISTROS LEIDOS:   ' WS-MASCARA       
              MOVE WS-TOTAL-IMPRES TO WS-MASCARA                        
              DISPLAY 'TOTAL DE REGISTROS IMPRESOS: ' WS-MASCARA       
           END-IF                                                       
           .                                                            
       3000-F-FINAL. 
           EXIT.                                              
      *                                                                 