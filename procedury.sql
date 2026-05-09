-- -------------------------------------------------------------
-- Procedura ZABRAN_TAHU
--
-- Účel: Ověřit, zda je vkládaný tah platný. Pokud ne,
--       vyvolá výjimku a tím zabrání jeho uložení do DB.
--
-- Volána z: triggeru TRIGGER_ZABRAN_TAHU (triggery.sql)
--
-- Parametry (hodnoty z nového řádku tabulky TAH):
--   p_hra_id   ... ID hry, do které hráč hraje
--   p_hrac_id  ... ID hráče, který provádí tah
--   p_radek    ... řádek, kam hráč táhne
--   p_sloupec  ... sloupec, kam hráč táhne
-- -------------------------------------------------------------

CREATE OR REPLACE PROCEDURE zabran_tahu (
    p_hra_id  IN tah.hra_hra_id%TYPE,
    p_hrac_id IN tah.hrac_hrac_id%TYPE,
    p_radek   IN tah.radek%TYPE,
    p_sloupec IN tah.sloupec%TYPE
) IS

    -- Proměnné pro načtení dat hry
    v_stav_nazev    stav.nazev%TYPE;
    v_sirka         hra.sirka%TYPE;
    v_vyska         hra.vyska%TYPE;
    v_vitezna_rada  hra.vitezna_rada%TYPE;
    v_hrac_krizek   hra.hrac_krizek%TYPE;
    v_hrac_kolecko  hra.hrac_kolecko%TYPE;

    -- Proměnné pro kontroly
    v_posledni_hrac tah.hrac_hrac_id%TYPE;
    v_pole_obsazeno NUMBER;

    -- Proměnné pro kontrolu omezení
    v_min_sirka         omezeni.min_hodnota%TYPE;
    v_max_sirka         omezeni.max_hodnota%TYPE;
    v_min_vyska         omezeni.min_hodnota%TYPE;
    v_max_vyska         omezeni.max_hodnota%TYPE;
    v_min_vitezna_rada  omezeni.min_hodnota%TYPE;
    v_max_vitezna_rada  omezeni.max_hodnota%TYPE;

BEGIN

    -- ==========================================================
    -- KROK 1: Načtení základních dat hry
    -- Potřebujeme vědět: stav hry, rozměry, kdo jsou hráči
    -- ==========================================================
    SELECT
        s.nazev,
        h.sirka,
        h.vyska,
        h.vitezna_rada,
        h.hrac_krizek,
        h.hrac_kolecko
    INTO
        v_stav_nazev,
        v_sirka,
        v_vyska,
        v_vitezna_rada,
        v_hrac_krizek,
        v_hrac_kolecko
    FROM hra h
    JOIN stav s ON s.stav_id = h.stav_id
    WHERE h.hra_id = p_hra_id;


    -- ==========================================================
    -- KROK 2: Je hra stále rozehraná?
    -- Nelze hrát do hry, která již skončila.
    -- ==========================================================
    IF v_stav_nazev != 'rozehraná' THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Hra č. ' || p_hra_id || ' již skončila (stav: ' || v_stav_nazev || '). Tah nelze provést.'
        );
    END IF;


    -- ==========================================================
    -- KROK 3: Táhne hráč, který je skutečně v této hře?
    -- Hráč musí být buď hráč křížku, nebo hráč kolečka.
    -- ==========================================================
    IF p_hrac_id != v_hrac_krizek AND p_hrac_id != v_hrac_kolecko THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'Hráč č. ' || p_hrac_id || ' není účastníkem hry č. ' || p_hra_id || '.'
        );
    END IF;


    -- ==========================================================
    -- KROK 4: Hraje správný hráč? (střídání)
    -- Hráč nesmí hrát dvakrát za sebou.
    -- Zjistíme, kdo provedl poslední tah v této hře.
    -- ==========================================================
    BEGIN
        SELECT hrac_hrac_id
        INTO v_posledni_hrac
        FROM tah
        WHERE hra_hra_id = p_hra_id
          AND cas_tahu = (
              SELECT MAX(cas_tahu)
              FROM tah
              WHERE hra_hra_id = p_hra_id
          );

        -- Pokud poslední tah provedl stejný hráč → chyba
        IF v_posledni_hrac = p_hrac_id THEN
            RAISE_APPLICATION_ERROR(
                -20003,
                'Hráč č. ' || p_hrac_id || ' již hrál minulý tah. Nyní je na řadě soupeř.'
            );
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Žádný tah ještě neproběhl → jde o první tah hry.
            -- První tah musí provést začínající hráč.
            DECLARE
                v_hrac_zacinajici hra.hrac_zacinajici%TYPE;
            BEGIN
                SELECT hrac_zacinajici
                INTO v_hrac_zacinajici
                FROM hra
                WHERE hra_id = p_hra_id;

                IF p_hrac_id != v_hrac_zacinajici THEN
                    RAISE_APPLICATION_ERROR(
                        -20004,
                        'První tah musí provést začínající hráč (hráč č. ' || v_hrac_zacinajici || ').'
                    );
                END IF;
            END;
    END;


    -- ==========================================================
    -- KROK 5: Je tah v mezích papíru?
    -- Řádek musí být 1..výška, sloupec musí být 1..šířka.
    -- ==========================================================
    IF p_radek < 1 OR p_radek > v_vyska THEN
        RAISE_APPLICATION_ERROR(
            -20005,
            'Řádek ' || p_radek || ' je mimo papír (povoleno 1–' || v_vyska || ').'
        );
    END IF;

    IF p_sloupec < 1 OR p_sloupec > v_sirka THEN
        RAISE_APPLICATION_ERROR(
            -20006,
            'Sloupec ' || p_sloupec || ' je mimo papír (povoleno 1–' || v_sirka || ').'
        );
    END IF;


    -- ==========================================================
    -- KROK 6: Je políčko volné?
    -- Na dané pozici (radek, sloupec) nesmí existovat jiný tah.
    -- ==========================================================
    SELECT COUNT(*)
    INTO v_pole_obsazeno
    FROM tah
    WHERE hra_hra_id = p_hra_id
      AND radek      = p_radek
      AND sloupec    = p_sloupec;

    IF v_pole_obsazeno > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20007,
            'Políčko [řádek=' || p_radek || ', sloupec=' || p_sloupec || '] je již obsazeno.'
        );
    END IF;


    -- ==========================================================
    -- KROK 7: Splňuje hra omezení z tabulky OMEZENI?
    -- Šířka, výška a vítězná řada musí být v povolených mezích.
    -- ==========================================================
    SELECT min_hodnota, max_hodnota
    INTO v_min_sirka, v_max_sirka
    FROM omezeni WHERE nazev = 'sirka';

    SELECT min_hodnota, max_hodnota
    INTO v_min_vyska, v_max_vyska
    FROM omezeni WHERE nazev = 'vyska';

    SELECT min_hodnota, max_hodnota
    INTO v_min_vitezna_rada, v_max_vitezna_rada
    FROM omezeni WHERE nazev = 'vitezna_rada';

    IF v_sirka < v_min_sirka OR v_sirka > v_max_sirka THEN
        RAISE_APPLICATION_ERROR(
            -20008,
            'Šířka hry (' || v_sirka || ') nesplňuje omezení (' || v_min_sirka || '–' || v_max_sirka || ').'
        );
    END IF;

    IF v_vyska < v_min_vyska OR v_vyska > v_max_vyska THEN
        RAISE_APPLICATION_ERROR(
            -20009,
            'Výška hry (' || v_vyska || ') nesplňuje omezení (' || v_min_vyska || '–' || v_max_vyska || ').'
        );
    END IF;

    IF v_vitezna_rada < v_min_vitezna_rada OR v_vitezna_rada > v_max_vitezna_rada THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'Vítězná řada (' || v_vitezna_rada || ') nesplňuje omezení (' || v_min_vitezna_rada || '–' || v_max_vitezna_rada || ').'
        );
    END IF;


    -- Všechny kontroly prošly → tah je platný.
    -- INSERT do TAH bude proveden normálně.

END zabran_tahu;
/

