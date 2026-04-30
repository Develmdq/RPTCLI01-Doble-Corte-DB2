-- ============================================================
-- TABLA: TIPOCTA
-- DESCRIPCION: Tipos de cuenta bancaria (tabla maestra)
-- SCHEMA: Z78724
-- AUTOR: Eduardo
-- FECHA: 2025
-- ============================================================

CREATE TABLE Z78724.TIPOCTA
  (
    CODTIPO    CHAR(2)         NOT NULL,
    DESTIPO    VARCHAR(30)     NOT NULL,
    TASA       DECIMAL(5,2)    NOT NULL WITH DEFAULT 0.00,

    CONSTRAINT PK_TIPOCTA
      PRIMARY KEY (CODTIPO),

    CONSTRAINT CHK_TASA
      CHECK (TASA >= 0.00 AND TASA <= 100.00)
  )
  IN DATABASE DSNDB04;

-- ------------------------------------------------------------
-- COMENTARIOS DE COLUMNAS
-- ------------------------------------------------------------
COMMENT ON TABLE Z78724.TIPOCTA
  IS 'Tabla maestra de tipos de cuenta bancaria';

COMMENT ON COLUMN Z78724.TIPOCTA.CODTIPO
  IS 'Codigo de tipo de cuenta: CA CC PF CR';

COMMENT ON COLUMN Z78724.TIPOCTA.DESTIPO
  IS 'Descripcion del tipo de cuenta';

COMMENT ON COLUMN Z78724.TIPOCTA.TASA
  IS 'Tasa de interes nominal anual en porcentaje';
