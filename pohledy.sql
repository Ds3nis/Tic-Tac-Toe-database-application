-- -------------------------------------------------------------
-- Pohled PAPIR
-- Zobrazí všechny řádky papíru všech her.
-- Každý řádek papíru je generován voláním funkce RADEK_PAPIRU.
-- Filtraci konkrétní hry provedeme podmínkou: WHERE hra_id = ?
-- -------------------------------------------------------------

CREATE OR REPLACE VIEW papir AS
SELECT
    h.hra_id,
    r.radek                              AS cislo_radku,
    radek_papiru(h.hra_id, r.radek)      AS obsah_radku
FROM
    hra h
    -- Generujeme čísla řádků od 1 do výšky papíru
    JOIN (
        SELECT LEVEL AS radek
        FROM dual
        CONNECT BY LEVEL <= (SELECT MAX(vyska) FROM hra)
    ) r ON r.radek <= h.vyska
ORDER BY
    h.hra_id,
    r.radek;


-- -------------------------------------------------------------
-- Pohled VYHRY_ZACINAJICI
-- Hry, ve kterých zvítězil začínající hráč.
-- Obsahuje: rozměry papíru, vítěznou řadu, jména hráčů,
--           kdo začínal, jaké symboly používali,
--           celkovou dobu hry v sekundách,
--           počet zahraných tahů.
--
-- Technika CTE (Common Table Expression) je povinně použita.
-- -------------------------------------------------------------

CREATE OR REPLACE VIEW vyhry_zacinajici AS
WITH
    -- CTE: Základní info o hrách, které vyhrál začínající hráč
    hry_vyhry AS (
        SELECT
            h.hra_id,
            h.sirka,
            h.vyska,
            h.vitezna_rada,
            h.hrac_zacinajici,
            h.hrac_kolecko,
            h.hrac_krizek,
            h.cas_hrac1,
            h.cas_hrac2
        FROM hra h
        JOIN stav s ON s.stav_id = h.stav_id
        WHERE s.nazev = 'vítězství začínajícího hráče'
    ),
    -- CTE: Počet tahů v každé hře
    pocty_tahu AS (
        SELECT
            t.hra_hra_id,
            COUNT(*) AS pocet_tahu
        FROM tah t
        GROUP BY t.hra_hra_id
    )
SELECT
    hv.hra_id,
    hv.sirka,
    hv.vyska,
    hv.vitezna_rada,
    -- Jméno začínajícího hráče
    hz.jmeno                                    AS jmeno_zacinajiciho,
    -- Jméno druhého hráče (ten, kdo nezačínal)
    CASE
        WHEN hv.hrac_zacinajici = hv.hrac_kolecko THEN hk.jmeno
        ELSE hkr.jmeno
    END                                         AS jmeno_druheho,
    -- Symbol začínajícího hráče
    CASE
        WHEN hv.hrac_zacinajici = hv.hrac_kolecko THEN 'O'
        ELSE 'X'
    END                                         AS symbol_zacinajiciho,
    -- Symbol druhého hráče
    CASE
        WHEN hv.hrac_zacinajici = hv.hrac_kolecko THEN 'X'
        ELSE 'O'
    END                                         AS symbol_druheho,
    -- Celková doba hry = součet herních dob obou hráčů
    (hv.cas_hrac1 + hv.cas_hrac2)              AS doba_hry_sekundy,
    -- Počet zahraných tahů
    pt.pocet_tahu
FROM
    hry_vyhry       hv
    JOIN hrac hz    ON hz.hrac_id = hv.hrac_zacinajici
    JOIN hrac hk    ON hk.hrac_id = hv.hrac_kolecko
    JOIN hrac hkr   ON hkr.hrac_id = hv.hrac_krizek
    JOIN pocty_tahu pt ON pt.hra_hra_id = hv.hra_id;

-- -------------------------------------------------------------
-- Pohled REMIZY
--
-- Zobrazí hry, které skončily remízou.
-- Struktura je analogická k VYHRY_ZACINAJICI.
-- CTE:
--   hry_remizy ... filtruje hry se stavem 'remíza'
--   pocty_tahu ... počet tahů v každé hře
-- -------------------------------------------------------------
 
CREATE OR REPLACE VIEW remizy AS
WITH
    hry_remizy AS (
        SELECT h.hra_id, h.sirka, h.vyska, h.vitezna_rada,
               h.hrac_zacinajici, h.hrac_kolecko, h.hrac_krizek,
               h.cas_hrac1, h.cas_hrac2
        FROM hra h
        JOIN stav s ON s.stav_id = h.stav_id
        WHERE s.nazev = 'remíza'
    ),
    pocty_tahu AS (
        SELECT t.hra_hra_id, COUNT(*) AS pocet_tahu
        FROM tah t
        GROUP BY t.hra_hra_id
    )
SELECT
    hr.hra_id,
    hr.sirka,
    hr.vyska,
    hr.vitezna_rada,
    hz.jmeno                                        AS jmeno_zacinajiciho,
    CASE WHEN hr.hrac_zacinajici = hr.hrac_kolecko
         THEN hk.jmeno ELSE hkr.jmeno END           AS jmeno_druheho,
    CASE WHEN hr.hrac_zacinajici = hr.hrac_kolecko
         THEN 'O' ELSE 'X' END                      AS symbol_zacinajiciho,
    CASE WHEN hr.hrac_zacinajici = hr.hrac_kolecko
         THEN 'X' ELSE 'O' END                      AS symbol_druheho,
    (hr.cas_hrac1 + hr.cas_hrac2)                  AS doba_hry_sekundy,
    pt.pocet_tahu
FROM hry_remizy hr
    JOIN hrac hz    ON hz.hrac_id  = hr.hrac_zacinajici
    JOIN hrac hk    ON hk.hrac_id  = hr.hrac_kolecko
    JOIN hrac hkr   ON hkr.hrac_id = hr.hrac_krizek
    JOIN pocty_tahu pt ON pt.hra_hra_id = hr.hra_id;
 
 
-- -------------------------------------------------------------
-- Pohled PROHRY_ZACINAJICI
--
-- Zobrazí hry, ve kterých začínající hráč prohrál.
-- CTE:
--   hry_prohry ... filtruje stav 'prohra začínajícího hráče'
--   pocty_tahu ... počet tahů
-- -------------------------------------------------------------
 
CREATE OR REPLACE VIEW prohry_zacinajici AS
WITH
    hry_prohry AS (
        SELECT h.hra_id, h.sirka, h.vyska, h.vitezna_rada,
               h.hrac_zacinajici, h.hrac_kolecko, h.hrac_krizek,
               h.cas_hrac1, h.cas_hrac2
        FROM hra h
        JOIN stav s ON s.stav_id = h.stav_id
        WHERE s.nazev = 'prohra začínajícího hráče'
    ),
    pocty_tahu AS (
        SELECT t.hra_hra_id, COUNT(*) AS pocet_tahu
        FROM tah t
        GROUP BY t.hra_hra_id
    )
SELECT
    hp.hra_id,
    hp.sirka,
    hp.vyska,
    hp.vitezna_rada,
    hz.jmeno                                        AS jmeno_zacinajiciho,
    CASE WHEN hp.hrac_zacinajici = hp.hrac_kolecko
         THEN hk.jmeno ELSE hkr.jmeno END           AS jmeno_druheho,
    CASE WHEN hp.hrac_zacinajici = hp.hrac_kolecko
         THEN 'O' ELSE 'X' END                      AS symbol_zacinajiciho,
    CASE WHEN hp.hrac_zacinajici = hp.hrac_kolecko
         THEN 'X' ELSE 'O' END                      AS symbol_viteze,
    (hp.cas_hrac1 + hp.cas_hrac2)                  AS doba_hry_sekundy,
    pt.pocet_tahu
FROM hry_prohry hp
    JOIN hrac hz    ON hz.hrac_id  = hp.hrac_zacinajici
    JOIN hrac hk    ON hk.hrac_id  = hp.hrac_kolecko
    JOIN hrac hkr   ON hkr.hrac_id = hp.hrac_krizek
    JOIN pocty_tahu pt ON pt.hra_hra_id = hp.hra_id;