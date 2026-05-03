-- =============================================================
-- konfigurace.sql
-- Počáteční konfigurace databáze pro aplikaci Piškvorky
-- =============================================================


-- -------------------------------------------------------------
-- Tabulka OMEZENI
-- Parametry hry: šířka papíru, výška papíru, vítězná řada
-- -------------------------------------------------------------

INSERT INTO omezeni (omezeni_id, nazev, min_hodnota, max_hodnota)
VALUES (1, 'sirka', 5, 20);

INSERT INTO omezeni (omezeni_id, nazev, min_hodnota, max_hodnota)
VALUES (2, 'vyska', 5, 20);

INSERT INTO omezeni (omezeni_id, nazev, min_hodnota, max_hodnota)
VALUES (3, 'vitezna_rada', 5, 15);


-- -------------------------------------------------------------
-- Tabulka STAV
-- Číselník stavů hry
-- -------------------------------------------------------------

INSERT INTO stav (stav_id, nazev)
VALUES (1, 'rozehraná');

INSERT INTO stav (stav_id, nazev)
VALUES (2, 'vítězství začínajícího hráče');

INSERT INTO stav (stav_id, nazev)
VALUES (3, 'prohra začínajícího hráče');

INSERT INTO stav (stav_id, nazev)
VALUES (4, 'remíza');


-- -------------------------------------------------------------
-- Tabulka HRAC
-- Registrace testovacích hráčů
-- Všechny statistiky začínají na 0
-- -------------------------------------------------------------

INSERT INTO hrac (hrac_id, jmeno,
    pocet_vitezstvi_z, pocet_vitezstvi_d,
    pocet_proher_z,    pocet_proher_d,
    pocet_remiz_z,     pocet_remiz_d)
VALUES (1, 'Alice', 0, 0, 0, 0, 0, 0);

INSERT INTO hrac (hrac_id, jmeno,
    pocet_vitezstvi_z, pocet_vitezstvi_d,
    pocet_proher_z,    pocet_proher_d,
    pocet_remiz_z,     pocet_remiz_d)
VALUES (2, 'Bob', 0, 0, 0, 0, 0, 0);

INSERT INTO hrac (hrac_id, jmeno,
    pocet_vitezstvi_z, pocet_vitezstvi_d,
    pocet_proher_z,    pocet_proher_d,
    pocet_remiz_z,     pocet_remiz_d)
VALUES (3, 'Charlie', 0, 0, 0, 0, 0, 0);


COMMIT;