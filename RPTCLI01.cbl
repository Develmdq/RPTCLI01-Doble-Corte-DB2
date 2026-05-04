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
                                                                        
       01 REG-SALIDA            PIC X(132).                           
                                                                        
      *------------------------*                                        
       WORKING-STORAGE SECTION.                                         
      *------------------------*                                        
       77 FILLER                PIC X(26)   VALUE '* INICIO WS *'.       
                                                                        
      * CONTROL FILES STATUS SALIDA *                                   
       01 WS-FS-SALIDA          PIC X(2).                                  
          88 WS-FSS-OK                      VALUE '00'. 
                                                                        
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
          88 IND-DETALLE                    VALUE 4.
          88 IND-SUBTOTAL-SEXO              VALUE 5.
          88 IND-TOTAL-DEPT                 VALUE 6.                    
                                                                        
      * VALORES ANTERIORES PARA CONTROL DE CORTE *                 
       01 WS-DATO-ANTERIOR.                                             
          05 WS-WORKDEPT-ANT    PIC X(3)    VALUE SPACES.               
          05 WS-SEXO-ANT        PIC X       VALUE SPACES.               
                                                                        
      * CONTADORES Y ACUMULADORES *
       01 WS-CONTADORES-ACUMULADORES.
          05 WS-CONT-SEXO       PIC 9(5)    VALUE ZEROS.
          05 WS-ACUM-SEXO       PIC 9(9)V99 VALUE ZEROS.
          05 WS-CONT-DEPTO      PIC 9(5)    VALUE ZEROS.
          05 WS-ACUM-DEPTO      PIC 9(9)V99 VALUE ZEROS.
          05 WS-CONT-TOTAL      PIC 9(5)    VALUE ZEROS.
          05 WS-ACUM-TOTAL      PIC 9(9)V99 VALUE ZEROS. 

      * CONTADORES GLOBALES *
          05 WS-CNT-LEIDOS      PIC 9(4)    VALUE ZEROS.
          05 WS-CNT-IMPRESOS    PIC 9(4)    VALUE ZEROS.
                                                                  
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
       DECLARATIVES.
      *----------------------------------------------------------------*
      *                                                                *
      *----------------------------------------------------------------*
       ERROR-SALIDA SECTION.
           USE AFTER STANDARD ERROR PROCEDURE ON OUTPUT.
       MANEJADOR-ERROR-SALIDA.
           GO TO 2300-I-INVOCAR-RUTINA-ERROR 
           .
       END DECLARATIVES.                                           
                                                                        
           EXEC SQL WHENEVER SQLERROR  
              GO TO 2300-I-INVOCAR-RUTINA-ERROR 
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
      * Por medio de los niveles 88 de 01 WS-OPERACION + SET se crea un*
      * estado general y junto a EVALUATE TRUE se maneja el fujo.      *
      ******************************************************************
                                                                        
       1000-I-INICIO.
           MOVE FUNCTION 
                FORMATTED-CURRENT-DATE("%d/%m/%Y") TO WS-RPT-FECHA

           INITIALIZE WS-CONTADORES-ACUMULADORES
                                                                       
           SET ABRIENDO-ARCHIVO TO TRUE       *> APERTURA ARCHIVO SALIDA 
           OPEN OUTPUT SALIDA                                           
                                                                        
           SET ABRIENDO-CURSOR TO TRUE         *> APERTURA DE CURSOR     
           EXEC SQL OPEN EMPDEPT-CURSOR END-EXEC
           .
       1000-F-INICIO. 
           EXIT.                                           
                                                                        
      ******************************************************************
      *                 CUERPO PRINCIPAL DE PROCESOS                   *
      ******************************************************************
                                                                        
       2000-I-PROCESO.                                                 
                                        
           PERFORM 2100-I-LEER-CURSOR THRU  2100-F-LEER-CURSOR                                      
                                                                        
          *> ---------------| INICIO PERFORM EXTERIOR |---------------<*
           PERFORM UNTIL PGM-FIN                                       
              MOVE WS-WORKDEPT TO WS-WORKDEPT-ANT  *> MOVER KEY SUPERIOR
              INITIALIZE WS-CONT-DEPTO WS-ACUM-DEPTO    
              SET IND-SUBTITULO-DEPT TO TRUE      *> IMPRIMIR SUBTITULO
              PERFORM 2200-I-GRABAR-REG THRU 2200-F-GRABAR-REG                                 
                                                                        
             *> -----------| INICIO PERFORM CORTE SUPERIOR |----------<*
              PERFORM UNTIL WS-WORKDEPT NOT = WS-WORKDEPT-ANT OR PGM-FIN
                 MOVE WS-SEX TO WS-SEXO-ANT       *> MOVER KEY INFERIOR
                 INITIALIZE WS-CONT-SEXO WS-ACUM-SEXO                                 
                 SET IND-SUBTITULO-SEXO TO TRUE
                 PERFORM 2200-I-GRABAR-REG THRU 2200-F-GRABAR-REG 

                *> --------| INICIO PERFORM CORTE INFERIOR |----------<*
                 PERFORM UNTIL WS-WORKDEPT NOT = WS-WORKDEPT-ANT
                               OR WS-SEX NOT = WS-SEXO-ANT OR PGM-FIN
                    SET IND-DETALLE TO TRUE       *> IMPRIMIR DETALLES 
                    PERFORM 2200-I-GRABAR-REG THRU 2200-F-GRABAR-REG           
                    ADD 1 TO WS-CLI-SEX                    
                    ADD 1 TO WS-CLI-ANIO                      
                    ADD 1 TO WS-TOTAL-IMPRES        
                    PERFORM 2300-GRABAR-SALIDA                          
                    SET WS-FETCH-CURSOR TO TRUE    *> LECTURA SIGUIENTE
                    PERFORM 2200-LEER-CURSOR                            
                 END-PERFORM
                 *> --------| FINAL PERFORM CORTE INFERIOR |--------- <*
                 
                 SET WS-LINEA-SUBTOTAL TO TRUE      *> IMPRIMIR SUBTOTAL
                 PERFORM 2200-I-GRABAR-REG THRU 2200-F-GRABAR-REG       
              END-PERFORM
             *> ------------| FINAL PERFORM CORTE SUPERIOR |--------- <* 
                                                                        
              SET WS-LINEA-TOTALES TO TRUE     *> IMPRIMIR TOTALES 
              PERFORM 2200-I-GRABAR-REG THRU 2200-F-GRABAR-REG       
           END-PERFORM 
          *> -----------------| FINAL PERFORM EXTERIOR |------------- <*
           .
       2000-F-PROCESO. EXIT.                                              
                                                                                                                                                                                
       2100-I-LEER-CURSOR.                                                
                                                                        
           SET LEYENDO-CURSOR TO TRUE                                  
                                                                        
               EXEC SQL FETCH ITEM
                   INTO :WS-EMPNO,
                        :WS-FIRSTNME,
                        :WS-LASTNAME,
                        :WS-WORKDEPT,
                        :WS-SEX,
                        :WS-SALARY
               END-EXEC                                                 
                         
           ADD 1 TO WS-CNT-LEIDOS
           .                                    
       2100-F-LEER-CURSOR.  EXIT.                                             
                                                                        
       2200-I-GRABAR-REG.                                              
                                                                        
           SET GRABANDO-ARCHIVO TO TRUE                                   
                                                                        
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
           .                                                       
       2200-F-GRABAR-REG.                                             
                                                                        
       2300-I-INVOCAR-RUTINA-ERROR.                                              
           MOVE 'RPTCLI01'   TO WS-ERR-PROGRAMA
           MOVE WS-OPERACION TO WS-ERR-OPERACION
           MOVE WS-FS-SALIDA TO WS-ERR-FILE-STATUS
           SET ERR-ES-BATCH  TO TRUE
           CALL 'PGMERROR'   USING WS-ERROR
           SET PGM-FIN       TO TRUE 

           EVALUATE TRUE 
              WHEN ABRIENDO-ARCHIVO 
                   GO TO 1000-F-INICIO
              WHEN GRABANDO-ARCHIVO OR LEYENDO-CURSOR 
                   GO TO 2000-F-PROCESO 
           END-EVALUATE 
           EXEC SQL WHENEVER NOT FOUND CONTINUE END-EXEC                                                            
           .                                         
       2300-F-INVOCAR-RUTINA-ERROR.  EXIT. 
                                                                        
      ******************************************************************
      *                    CUERPO PRINCIPAL FINAL                      *
      ******************************************************************
       3000-I-FINAL.                                                    
                                                                        
                                                                
                                                                      
       3000-F-FINAL. 
           EXIT.                                              
      *                                                                 