//CMPRPT   JOB 1,NOTIFY=&SYSUID
//*-----------------------------------------------------------------
//* PASO 1: COMPILAR
//*-----------------------------------------------------------------
//COMPILAR EXEC DB2CBL,MBR=RPTCLI01
//COBOL.SYSLIB DD DSN=&SYSUID..SYSLIB,DISP=SHR
//             DD DSN=&SYSUID..DBRMLIB,DISP=SHR
//LKED.SYSLIB  DD DSN=CEE.SCEELKED,DISP=SHR
//             DD DSN=DSND10.SDSNLOAD,DISP=SHR
//             DD DSN=&SYSUID..LOAD,DISP=SHR
//BIND.SYSTSIN DD *,SYMBOLS=CNVTSYS
 DSN SYSTEM(DBDG)
 BIND PLAN(&SYSUID) PKLIST(&SYSUID..*) MEMBER(RPTCLI01) -
      ACT(REP) ISO(CS) ENCODING(EBCDIC)
//*-----------------------------------------------------------------
//* PASO 2: BORRAR EL ARCHIVO
//*-----------------------------------------------------------------
//BORRAR   EXEC PGM=IDCAMS,COND=(8,LT)
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *,SYMBOLS=CNVTSYS
  DELETE &SYSUID..REPORT.SALIDA
  SET MAXCC = 0
/*
//*-----------------------------------------------------------------
//* PASO 3: EJECUCION
//*-----------------------------------------------------------------
//RUNRPT   EXEC PGM=IKJEFT01,COND=(8,LT)
//STEPLIB  DD DSN=&SYSUID..LOAD,DISP=SHR
//         DD DSN=DSND10.SDSNLOAD,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*,OUTLIM=500
//DDSALE   DD DSN=&SYSUID..REPORT.SALIDA,
//            DISP=(NEW,CATLG,CATLG),
//            UNIT=SYSDA,
//            SPACE=(TRK,(10,5),RLSE),
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0)
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *,SYMBOLS=CNVTSYS
 DSN SYSTEM(DBDG)
 RUN PROGRAM(RPTCLI01) PLAN(&SYSUID) -
     LIB('&SYSUID..LOAD')
 END
/*
