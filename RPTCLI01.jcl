//KC03C61U JOB CLASS=A,MSGCLASS=O,MSGLEVEL=(1,1),NOTIFY=&SYSUID
//JCLLIB   JCLLIB ORDER=KC02788.ALU9999.PROCLIB
//*
//**********************************************************************
//* JCL PARA COMPILAR, BINDEAR, BORRAR/CREAR ARCHIVO FBA Y EJECUTAR:   *
//*                 KC03C61.CURSOS.FUENTE(PGMRDC61)                    *
//* ********************************************************************
//*
//*-------------------------------------------------------
//* STEP1 - COMPILADOR COBOL DB2
//*-------------------------------------------------------
//STEP1      EXEC COMPDB2,
//           ALUMLIB=KC03C61.CURSOS,
//           GOPGM=PGMRDC61
//PC.SYSLIB  DD DSN=KC03C61.CURSOS.DCLGEN,DISP=SHR
//COB.SYSLIB DD DSN=&USERID..COPYLIB,DISP=SHR
//           DD DSN=&USERID..COPYLIB,DISP=SHR
//*
//*-------------------------------------------------------
//* STEP2 - BIND DB2
//*-------------------------------------------------------
//STEP2    EXEC PGM=IKJEFT01,DYNAMNBR=20,COND=(4,LT)
//STEPLIB  DD DSN=DSND10.SDSNLOAD,DISP=SHR
//DBRMLIB  DD DSN=&USERID..CURSOS.DBRMLIB,DISP=SHR
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
  DSN SYSTEM(DBDG)
  RUN  PROGRAM(DSNTIAD) PLAN(DSNTIA13) -
       LIB('DSND10.DBDG.RUNLIB.LOAD')
  BIND PLAN(CURSOC61) MEMBER(PGMRDC61) +
       CURRENTDATA(NO) ACT(REP) ISO(CS) ENCODING(EBCDIC)
  END
/*
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//*
//*-------------------------------------------------------
//* STEP3 - BORRAR ARCHIVO SALIDA
//*-------------------------------------------------------
//STEP3    EXEC PGM=IEFBR14
//DD0      DD   DSN=KC03C61.LISTADO.FINAL1,
//         DISP=(MOD,DELETE),UNIT=SYSDA,SPACE=(TRK,0)
//*
//*-------------------------------------------------------
//* STEP4 - CREAR ARCHIVO FBA
//*-------------------------------------------------------
//STEP4    EXEC PGM=IEFBR14
//DD1      DD   DSN=KC03C61.LISTADO.FINAL1,UNIT=SYSDA,
//         DCB=(LRECL=133,BLKSIZE=0,RECFM=FBA),
//         SPACE=(TRK,(1,1),RLSE),DISP=(,CATLG)
//*
//*-------------------------------------------------------
//* STEP5 - EJECUTAR PROGRAMA COBOL DB2
//*-------------------------------------------------------
//STEP5    EXEC PGM=IKJEFT01,DYNAMNBR=20,COND=(4,LT)
//STEPLIB  DD   DSN=DSND10.SDSNLOAD,DISP=SHR
//         DD   DSN=KC03C61.CURSOS.PGMLIB,DISP=SHR
//SYSTSPRT DD   SYSOUT=*
//DDSALE   DD   DSN=KC03C61.LISTADO.FINAL1,DISP=SHR
//SYSOUT   DD   SYSOUT=*
//SYSTSIN  DD   *
  DSN SYSTEM(DBDG)
  RUN  PROGRAM(PGMRDC61) PLAN(CURSOC61) +
       LIB('KC03C61.CURSOS.PGMLIB')
  END
/*
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//
