-- ============================================================
-- DATOS MAESTROS: TIPOCTA
-- DESCRIPCION: Tipos de cuenta - 4 valores fijos
-- ============================================================

INSERT INTO Z78724.TIPOCTA (CODTIPO, DESTIPO, TASA)
  VALUES ('CA', 'Caja de Ahorro',        1.50);

INSERT INTO Z78724.TIPOCTA (CODTIPO, DESTIPO, TASA)
  VALUES ('CC', 'Cuenta Corriente',      0.00);

INSERT INTO Z78724.TIPOCTA (CODTIPO, DESTIPO, TASA)
  VALUES ('PF', 'Plazo Fijo',           78.00);

INSERT INTO Z78724.TIPOCTA (CODTIPO, DESTIPO, TASA)
  VALUES ('CR', 'Credito Personal',     95.00);
