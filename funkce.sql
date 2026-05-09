-- -------------------------------------------------------------
-- Funkce RADEK_PAPIRU
-- Vrátí řetězec odpovídající jednomu řádku papíru dané hry.
-- Symboly:
--   'X' = křížek
--   'O' = kolečko
--   ' ' = volné políčko
--
-- Parametry:
--   p_hra_id  ... ID hry
--   p_radek   ... číslo řádku (1 = první řádek)
-- -------------------------------------------------------------

CREATE OR REPLACE FUNCTION radek_papiru (
    p_hra_id  IN tah.hra_hra_id%TYPE,
    p_radek   IN tah.radek%TYPE
) RETURN VARCHAR2 IS

    v_sirka     hra.sirka%TYPE;
    v_radek_str VARCHAR2(4000) := '';
    v_symbol    VARCHAR2(1);
    v_hrac_krizek  hra.hrac_krizek%TYPE;
    v_hrac_kolecko hra.hrac_kolecko%TYPE;

BEGIN
    -- Načtení šířky papíru a hráčů dané hry
    SELECT h.sirka, h.hrac_krizek, h.hrac_kolecko
    INTO v_sirka, v_hrac_krizek, v_hrac_kolecko
    FROM hra h
    WHERE h.hra_id = p_hra_id;

    -- Procházení sloupců zleva doprava
    FOR v_sloupec IN 1 .. v_sirka LOOP

        -- Hledáme tah na pozici (radek, sloupec) v dané hře
        BEGIN
            SELECT
                CASE
                    WHEN t.hrac_hrac_id = v_hrac_krizek  THEN 'X'
                    WHEN t.hrac_hrac_id = v_hrac_kolecko THEN 'O'
                END
            INTO v_symbol
            FROM tah t
            WHERE t.hra_hra_id = p_hra_id
              AND t.radek       = p_radek
              AND t.sloupec     = v_sloupec;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Políčko je volné
                v_symbol := ' ';
        END;

        v_radek_str := v_radek_str || v_symbol;
    END LOOP;

    RETURN v_radek_str;

END radek_papiru;
/

