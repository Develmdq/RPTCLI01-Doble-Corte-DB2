-- ============================================================
-- TABLA: CUENTAS
-- DESCRIPCION: Cuentas bancarias de clientes
-- SCHEMA: Z78724
-- AUTOR: Eduardo
-- FECHA: 2025
-- ============================================================

CREATE TABLE Z78724.CUENTAS
  (
    NROCTA     CHAR(10)        NOT NULL,
    CODTIPO    CHAR(2)         NOT NULL,
    NOMCLI     VARCHAR(40)     NOT NULL,
    SEXO       CHAR(1)         NOT NULL,
    SALDO      DECIMAL(12,2)   NOT NULL WITH DEFAULT 0.00,
    FECALTA    DATE            NOT NULL,
    ESTADO     CHAR(1)         NOT NULL WITH DEFAULT 'A',

    CONSTRAINT PK_CUENTAS
      PRIMARY KEY (NROCTA),

    CONSTRAINT FK_CUENTAS_TIPOCTA
      FOREIGN KEY (CODTIPO)
      REFERENCES Z78724.TIPOCTA (CODTIPO)
      ON DELETE RESTRICT,

    CONSTRAINT CHK_SEXO
      CHECK (SEXO IN ('M', 'F')),

    CONSTRAINT CHK_ESTADO
      CHECK (ESTADO IN ('A', 'S', 'C')),

    CONSTRAINT CHK_SALDO
      CHECK (SALDO >= -99999999.99)
  )
  IN DATABASE DSNDB04;

-- ------------------------------------------------------------
-- INDICE POR TIPO Y SEXO (clave del reporte)
-- ------------------------------------------------------------
CREATE INDEX Z78724.IX_CUENTAS_TIPO_SEXO
  ON Z78724.CUENTAS (CODTIPO ASC, SEXO ASC);

-- ------------------------------------------------------------
-- COMENTARIOS DE COLUMNAS
-- ------------------------------------------------------------
COMMENT ON TABLE Z78724.CUENTAS
  IS 'Cuentas bancarias activas suspendidas y canceladas';

COMMENT ON COLUMN Z78724.CUENTAS.NROCTA
  IS 'Numero de cuenta formato XXXXXXXXXX';

COMMENT ON COLUMN Z78724.CUENTAS.CODTIPO
  IS 'Codigo de tipo de cuenta FK a TIPOCTA';

COMMENT ON COLUMN Z78724.CUENTAS.NOMCLI
  IS 'Apellido y nombre del titular';

COMMENT ON COLUMN Z78724.CUENTAS.SEXO
  IS 'Sexo del titular: M Masculino F Femenino';

COMMENT ON COLUMN Z78724.CUENTAS.SALDO
  IS 'Saldo actual en pesos argentinos';

COMMENT ON COLUMN Z78724.CUENTAS.FECALTA
  IS 'Fecha de apertura de la cuenta';

COMMENT ON COLUMN Z78724.CUENTAS.ESTADO
  IS 'Estado: A Activa S Suspendida C Cancelada';
