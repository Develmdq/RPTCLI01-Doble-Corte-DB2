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
          LINAGE IS 20 LINES
          WITH FOOTING AT 18
          LINES AT TOP 1
          LINES AT BOTTOM 1.                                     
                                                                        
       01 REG-SALIDA              PIC X(132).                           
                                                                        
      *------------------------*                                        
       WORKING-STORAGE SECTION.                                         
      *------------------------*                                        
       77  FILLER            PIC X(26)    VALUE '* INICIO WS *'.       
                                                                        
      * CONTROL FILES STATUS SALIDA *                                   
       01 WS-FS-SALIDA       PIC X(2).                                  
          88 WS-FSS-OK                    VALUE '00'. 
                                                                        
      * INDICADOR DE CORTE DEL PROGRAMA *
       01 WS-IND-PROGRAMA    PIC X(1)     VALUE 'A'.
          88 IND-PGM-ACTIVO               VALUE 'F'.                 
                      
      * INDICADOR DE OPERACION EN CURSO *
       01 WS-IND-OPERACION   PIC X(1)     VALUE SPACE.
          88 IND-ABRIENDO-CURSOR          VALUE 'A'.
          88 IND-LEYENDO-CURSOR           VALUE 'L'.
          88 IND-CERRANDO-CURSOR          VALUE 'C'.
          88 IND-ABRIENDO-SALIDA          VALUE 'S'.
          88 IND-GRABANDO-SALIDA          VALUE 'G'.
          88 IND-CERRANDO-SALIDA          VALUE 'X'.
                     
      * INDICADOR DE LINEA A IMPRIMIR *
       01 WS-IND-LINEA        PIC 9       VALUE 0.
          88 IND-TITULO                   VALUE 1.
          88 IND-SUBTITULO-ANIO           VALUE 2.
          88 IND-SUBTITULO-SEXO           VALUE 3.
          88 IND-COLUMNAS                 VALUE 4.
          88 IND-DETALLE                  VALUE 5.
          88 IND-SUBTOTAL-SEXO            VALUE 6.
          88 IND-TOTAL-ANIO               VALUE 7.                    
                                                                        
      * CONTROL DE LINEAS IMPRESAS POR CAMBIO DE CURSOR                 
       01 WS-DATO-ANTERIOR.                                             
          05 WS-ANIO-ANT     PIC X(4)     VALUE SPACES.               
          05 WS-SEXO-ANT     PIC X        VALUE SPACES.               
                                                                        
      * TOTALIZADORES / CONTADORES *                                    
       01 WS-TOTALES.                                                   
          05 WS-CLI-SEX      PIC 9(3)     VALUE ZEROS.                
          05 WS-CLI-ANIO     PIC 9(3)     VALUE ZEROS.                
          05 WS-TOTAL-LEIDOS PIC 9(3)     VALUE ZEROS.                
          05 WS-TOTAL-IMPRES PIC 9(3)     VALUE ZEROS.                
                                                                        
       77 WS-MASCARA         PIC Z(3)      VALUE ZEROS.                
                                                                        
      * ACTIVACION SQLCODE + VARIABLES DCLGEN *                         
                EXEC SQL INCLUDE SQLCA END-EXEC.                        
                EXEC SQL INCLUDE TBCURCLI END-EXEC.                     
                                                                        
      * CURSOR CLIENTE DUPLICADO *                                      
                                                                        
      ******************************************************************
      * LA QUERY RETORNA LAS COLUMNAS SELECCIONADAS DE CADA REGISTRO Y *
      * ORDENADO EL RESULTADO POR EL CORTE SUPERIOR Y LUEGO INFERIOR   *
      ******************************************************************
           EXEC SQL                                                     
             DECLARE ITEM CURSOR FOR                                    
               SELECT NROCLI,                                           
                      NOMAPE,                                           
                      FECNAC,                                           
                      SEXO                                              
                    FROM KC02803.TBCURCLI                               
                    ORDER BY FECNAC ASC,                                
                             SEXO                                       
           END-EXEC.                                                    
                                                                        
      * COPY ARCHIVO DE SALIDA *                                        
                                                                        
       COPY CPERROR.                                                    
                                                                        
       77  FILLER            PIC X(26)    VALUE '* FINAL  WS *'.        
                                                                        
      ******************************************************************
       PROCEDURE DIVISION.                                              
      ******************************************************************
       DECLARATIVES.                                                    
       ERROR-FILES SECTION.                                             
            USE AFTER STANDARD ERROR PROCEDURE ON OUTPUT.               
       MANEJADOR-PROCESO.                                               
            IF WS-WRITE-SFILE                                           
               SET WS-CLOSE-SFILE TO TRUE                               
               CLOSE SALIDA                                             
            END-IF                                                      
            DISPLAY WS-ACCION WS-CODE-SAL                               
            SET WS-PGM-FIN TO TRUE                                      
            GO TO 2000-F-PROCESO.                                       
       END DECLARATIVES.                                                
                                                                        
           EXEC SQL                                                     
             WHENEVER SQLERROR GO TO 2400-CERRAR-CURSOR                 
           END-EXEC                                                     
                                                                        
           EXEC SQL                                                     
             WHENEVER NOT FOUND GO TO 2400-CERRAR-CURSOR                
           END-EXEC                                                     
                                                                        
       MAIN-PROGRAM.                                                    
                                                                        
           PERFORM 1000-I-INICIO  THRU 1000-F-INICIO                    
           PERFORM 2000-I-PROCESO THRU 2000-F-PROCESO UNTIL WS-PGM-FIN  
           PERFORM 3000-I-FINAL   THRU 3000-F-FINAL                     
           .                                                            
       F-MAIN-PROGRAM. GOBACK.                                          
                                                                        
      ******************************************************************
      *                 CUERPO PRINCIPAL DE INICIO                     *
      ******************************************************************
      * POR MEDIO DE NIVELES 88 + EL USO DE SET PARA ACTIVAR EL VALOR +*
      * EVALUATE TRUE SE MANEJA EL FLUJO DE EJECUCION Y MENSAJES       *
      ******************************************************************
                                                                        
       1000-I-INICIO.                                                   
                                                                        
           ACCEPT WS-FECHA    FROM DATE        *> MANEJO DE LA FECHA    
           MOVE   WS-FECHA-AA TO WS-AA                                  
           MOVE   WS-FECHA-MM TO WS-MM                                  
           MOVE   WS-FECHA-DD TO WS-DD                                  
                                                                        
           INITIALIZE WS-TOTAL-LEIDOS          *> LIMPIAR TOTALES GRALES
                      WS-TOTAL-IMPRES                                   
           .                                                            
       1000-F-INICIO.   EXIT.                                           
                                                                        
      ******************************************************************
      *                 CUERPO PRINCIPAL DE PROCESOS                   *
      ******************************************************************
                                                                        
       2000-I-PROCESO.                                                  
                                                                        
           PERFORM 2100-ABRIR-RECURSOS                                  
           PERFORM 2200-LEER-CURSOR                                     
                                                                        
      *> -----------------| INICIO PERFORM EXTERIOR |------------------*
                                                                        
           PERFORM UNTIL WS-PGM-FIN                                     
                                                                        
             MOVE WS-ANIO-NAC TO WS-ANIO-ANT      *> MOVER KEY SUPERIOR 
                                                                        
             INITIALIZE WS-CLI-ANIO                                     
                                                                        
             SET WS-LINEA-SUBTITULO TO TRUE        *> IMPRIMIR SUBTITULO
             PERFORM 2300-GRABAR-SALIDA                                 
                                                                        
      *> --------------| INICIO PERFORM CORTE SUPERIOR |---------------*
                                                                        
           PERFORM UNTIL WS-ANIO-NAC NOT = WS-ANIO-ANT OR WS-PGM-FIN    
                                                                        
             MOVE WT-SEXO    TO WS-SEXO-ANT        *> MOVER KEY INFERIOR
                                                                        
             INITIALIZE WS-CLI-SEX                                      
                                                                        
             SET WS-LINEA-SUBTITULO-2 TO TRUE     *> IMPRIMIR SUBTITULO 
             PERFORM 2300-GRABAR-SALIDA                                 
                                                                        
             SET WS-LINEA-COLUMNAS TO TRUE          *> IMPRIMIR COLUMNAS
             PERFORM 2300-GRABAR-SALIDA                                 
                                                                        
      *> --------------| INICIO PERFORM CORTE INFERIOR |---------------*
                                                                        
             PERFORM UNTIL WS-ANIO-NAC NOT = WS-ANIO-ANT OR             
                           WT-SEXO     NOT = WS-SEXO-ANT OR WS-PGM-FIN  
                                                                        
               ADD 1  TO WS-CLI-SEX                                     
               ADD 1  TO WS-CLI-ANIO                                    
               ADD 1  TO WS-TOTAL-IMPRES                                
                                                                        
               SET WS-LINEA-DETALLE  TO TRUE       *> IMPRIMIR DETALLES 
               PERFORM 2300-GRABAR-SALIDA                               
                                                                        
               SET WS-FETCH-CURSOR   TO TRUE       *> LECTURA SIGUIENTE 
               PERFORM 2200-LEER-CURSOR                                 
                                                                        
               END-PERFORM *> ---| FINAL PERFORM CORTE INFERIOR |--- <* 
                                                                        
               SET WS-LINEA-SUBTOTAL TO TRUE        *> IMPRIMIR SUBTOTAL
               PERFORM 2300-GRABAR-SALIDA                               
                                                                        
             END-PERFORM *> -----| FINAL PERFORM CORTE SUPERIOR |--- <* 
                                                                        
             SET WS-LINEA-TOTALES    TO TRUE        *> IMPRIMIR TOTALES 
             PERFORM 2300-GRABAR-SALIDA                                 
                                                                        
           END-PERFORM *> -------| FINAL PERFORM EXTERIOR |--------- <* 
           EXIT PARAGRAPH.                                              
                                                                        
       2100-ABRIR-RECURSOS.                                             
                                                                        
           SET  WS-OPEN-SFILE TO TRUE        *> APERTURA ARCHIVO SALIDA 
           OPEN OUTPUT SALIDA                                           
                                                                        
           SET WS-OPEN-CURSOR TO TRUE         *> APERTURA DE CURSOR     
           EXEC SQL OPEN ITEM END-EXEC                                  
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
              ADD 1              TO WS-NUM-PAG                          
              WRITE REG-SALIDA   FROM WS-TITULO                         
              WRITE REG-SALIDA   FROM WS-LINEA-VACIA                    
           END-IF                                                       
                                                                        
           EVALUATE WT-SEXO                                             
             WHEN 'F'                                                   
                  MOVE 'FEMENINO '   TO WS-SEXO-COPY                    
             WHEN 'M'                                                   
                  MOVE 'MASCULINO'   TO WS-SEXO-COPY                    
             WHEN 'O'                                                   
                  MOVE 'OTRO     '   TO WS-SEXO-COPY                    
           END-EVALUATE                                                 
                                                                        
           EVALUATE TRUE                                                
             WHEN WS-LINEA-SUBTITULO                                    
                  WRITE REG-SALIDA   FROM WS-SUBTITULO                  
             WHEN WS-LINEA-SUBTITULO-2                                  
                  MOVE  WS-SEXO-COPY TO   WS-SEXO-COP2                  
                  WRITE REG-SALIDA   FROM WS-SUBTITULO-2                
             WHEN WS-LINEA-COLUMNAS                                     
                  WRITE REG-SALIDA   FROM WS-COLUMNAS                   
             WHEN WS-LINEA-DETALLE                                      
                  MOVE WT-NROCLI     TO   REG-NROCLI                    
                  MOVE WT-NOMAPE     TO   REG-NOMAPE                    
                  MOVE WT-FECNAC     TO   REG-FECNAC                    
                  MOVE WT-SEXO       TO   REG-SEXO                      
                  WRITE REG-SALIDA   FROM WS-REG-SALIDA                 
             WHEN WS-LINEA-SUBTOTAL                                     
                  MOVE WS-CLI-SEX    TO   WS-CLI-SEX-2                  
                  WRITE REG-SALIDA   FROM WS-SUBTOTALES                 
             WHEN WS-LINEA-TOTALES                                      
                  MOVE WS-ANIO-ANT   TO   WS-ANIO-NA-2                  
                  MOVE WS-CLI-ANIO   TO   WS-CLI-ANIO2                  
                  WRITE REG-SALIDA   FROM WS-TOTALES-COPY               
           END-EVALUATE                                                 
                                                                        
           WRITE REG-SALIDA          FROM WS-LINEA-VACIA                
                                                                        
           IF WS-FSS-OK                                                 
              SET WS-FETCH-CURSOR    TO TRUE                            
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
               SET WS-PGM-FIN      TO TRUE                              
               SET WS-CLOSE-CURSOR TO TRUE                              
               EXEC SQL CLOSE ITEM END-EXEC                             
           END-IF                                                       
           EXIT PARAGRAPH.                                              
                                                                        
       2000-F-PROCESO. EXIT.                                            
                                                                        
      ******************************************************************
      *                    CUERPO PRINCIPAL FINAL                      *
      ******************************************************************
       3000-I-FINAL.                                                    
                                                                        
           IF WS-TOTAL-LEIDOS > 0 AND SQLCODE = 0 AND WS-FSS-OK         
              MOVE WS-TOTAL-LEIDOS TO WS-MASCARA                        
              DISPLAY 'TOTAL DE REGISTROS LEIDOS:   '  WS-MASCARA       
              MOVE WS-TOTAL-IMPRES TO WS-MASCARA                        
              DISPLAY 'TOTAL DE REGISTROS IMPRESOS: '  WS-MASCARA       
           END-IF                                                       
           .                                                            
       3000-F-FINAL. EXIT.                                              
      *                                                                 