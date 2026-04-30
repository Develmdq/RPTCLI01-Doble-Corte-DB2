-- ============================================================
-- PERMISOS: TIPOCTA y CUENTAS
-- DESCRIPCION: GRANTs minimos para ejecucion en Z Xplore
--              Ajustar usuario segun entorno
-- ============================================================

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE Z78724.TIPOCTA
  TO Z78724;

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE Z78724.CUENTAS
  TO Z78724;

-- Solo lectura para reportes
GRANT SELECT ON TABLE Z78724.TIPOCTA TO PUBLIC;
GRANT SELECT ON TABLE Z78724.CUENTAS TO PUBLIC;
