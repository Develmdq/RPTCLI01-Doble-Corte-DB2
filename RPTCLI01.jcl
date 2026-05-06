//RPTCLI01 JOB 1,NOTIFY=&SYSUID,REGION=0M
//*----------------------------------------------------------*
//*  PASO 1: PRECOMPILADOR DB2                               *
//*----------------------------------------------------------*
//DB2PC   EXEC PGM=DSNHPC,PARM='HOST(COBOL),XREF,SOURCE'
//STEPLIB  DD DSN=DSND10.SDSNLOAD,DISP=SHR
//DBRMLIB  DD DSN=&SYSUID..DBRMLIB(RPTCLI01),DISP=SHR
//SYSIN    DD DSN=&SYSUID..CBL(RPTCLI01),DISP=SHR
//SYSCIN   DD DSN=&&DSNHOUT,DISP=(NEW,PASS),
//            UNIT=SYSDA,SPACE=(800,(500,500))
//SYSLIB   DD DSN=&SYSUID..SYSLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//*----------------------------------------------------------*
//*  PASO 2: COMPILACION COBOL                              *
//*----------------------------------------------------------*
//COBOL   EXEC IGYWCL,COND=(4,LT,DB2PC)
//COBOL.SYSIN   DD DSN=&&DSNHOUT,DISP=(OLD,DELETE)
//COBOL.SYSLIB  DD DSN=&SYSUID..SYSLIB,DISP=SHR
//LKED.SYSLMOD  DD DSN=&SYSUID..LOAD(RPTCLI01),DISP=SHR
//*----------------------------------------------------------*
//*  PASO 3: BIND                                           *
//*----------------------------------------------------------*
//BIND    EXEC PGM=IKJEFT01,COND=(4,LT,COBOL.COBOL)
//STEPLIB  DD DSN=DSND10.SDSNLOAD,DISP=SHR
//DBRMLIB  DD DSN=&SYSUID..DBRMLIB,DISP=SHR
//SYSTSIN  DD *,SYMBOLS=CNVTSYS
 DSN SYSTEM(DBDG)
 BIND PLAN(&SYSUID) MEMBER(RPTCLI01) LIB('&SYSUID..DBRMLIB') -
      ACTION(REPLACE) ISOLATION(CS)
 END
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//*----------------------------------------------------------*
//*  PASO 4: BORRAR SALIDA ANTERIOR                         *
//*----------------------------------------------------------*
//DELETE  EXEC PGM=IDCAMS,COND=(4,LT,BIND)
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE &SYSUID..OUTPUT(RPTCLI01)
  SET MAXCC=0
/*
//*----------------------------------------------------------*
//*  PASO 5: EJECUCION                                      *
//*----------------------------------------------------------*
//RUN     EXEC PGM=IKJEFT01,COND=(4,LT,DELETE)
//STEPLIB  DD DSN=DSND10.SDSNLOAD,DISP=SHR
//         DD DSN=&SYSUID..LOAD,DISP=SHR
//DDSALE   DD DSN=&SYSUID..OUTPUT(RPTCLI01),DISP=SHR,
//            RECFM=FBA,LRECL=132,BLKSIZE=0
//SYSTSIN  DD *,SYMBOLS=CNVTSYS
 DSN SYSTEM(DBDG)
 RUN PROGRAM(RPTCLI01) PLAN(&SYSUID) LIB('&SYSUID..LOAD')
 END
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD DUMMY
//CEEDUMP  DD DUMMY
/*