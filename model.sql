CREATE TABLE hra 
    ( 
     hra_id          NUMBER  NOT NULL , 
     sirka           NUMBER  NOT NULL , 
     vyska           NUMBER  NOT NULL , 
     vitezna_rada    NUMBER  NOT NULL , 
     cas_hrac1       NUMBER , 
     cas_hrac2       NUMBER , 
     stav_id         NUMBER  NOT NULL , 
     hrac_kolecko    NUMBER  NOT NULL , 
     hrac_krizek     NUMBER  NOT NULL , 
     hrac_zacinajici NUMBER  NOT NULL 
    ) 
;

ALTER TABLE hra 
    ADD CONSTRAINT hra_PK PRIMARY KEY ( hra_id ) ;

CREATE TABLE hrac 
    ( 
     hrac_id           NUMBER  NOT NULL , 
     jmeno             VARCHAR2 (100)  NOT NULL , 
     pocet_vitezstvi_z NUMBER  NOT NULL , 
     pocet_vitezstvi_d NUMBER  NOT NULL , 
     pocet_proher_z    NUMBER  NOT NULL , 
     pocet_proher_d    NUMBER  NOT NULL , 
     pocet_remiz_z     NUMBER  NOT NULL , 
     pocet_remiz_d     NUMBER  NOT NULL 
    ) 
;

ALTER TABLE hrac 
    ADD CONSTRAINT hrac_PK PRIMARY KEY ( hrac_id ) ;

ALTER TABLE hrac 
    ADD CONSTRAINT hrac_jmeno_UN UNIQUE ( jmeno ) ;

CREATE TABLE omezeni 
    ( 
     omezeni_id  NUMBER  NOT NULL , 
     nazev       VARCHAR2 (100)  NOT NULL , 
     min_hodnota NUMBER  NOT NULL , 
     max_hodnota NUMBER  NOT NULL 
    ) 
;

ALTER TABLE omezeni 
    ADD CONSTRAINT omezeni_PK PRIMARY KEY ( omezeni_id ) ;

ALTER TABLE omezeni 
    ADD CONSTRAINT omezeni_nazev_UN UNIQUE ( nazev ) ;

CREATE TABLE stav 
    ( 
     stav_id NUMBER  NOT NULL , 
     nazev   VARCHAR2 (50)  NOT NULL 
    ) 
;

ALTER TABLE stav 
    ADD 
    CHECK (nazev IN ('prohra začínajícího hráče', 'remíza', 'rozehraná', 'vítězství začínajícího hráče')) 
;

ALTER TABLE stav 
    ADD CONSTRAINT stav_PK PRIMARY KEY ( stav_id ) ;

CREATE TABLE tah 
    ( 
     tah_id       NUMBER  NOT NULL , 
     radek        NUMBER  NOT NULL , 
     sloupec      NUMBER  NOT NULL , 
     cas_tahu     TIMESTAMP  NOT NULL , 
     hra_hra_id   NUMBER  NOT NULL , 
     hrac_hrac_id NUMBER  NOT NULL 
    ) 
;

ALTER TABLE tah 
    ADD CONSTRAINT tah_PK PRIMARY KEY ( tah_id ) ;

ALTER TABLE hra 
    ADD CONSTRAINT hra_hrac_FK FOREIGN KEY 
    ( 
     hrac_kolecko
    ) 
    REFERENCES hrac 
    ( 
     hrac_id
    ) 
;

ALTER TABLE hra 
    ADD CONSTRAINT hra_hrac_FKv1 FOREIGN KEY 
    ( 
     hrac_zacinajici
    ) 
    REFERENCES hrac 
    ( 
     hrac_id
    ) 
;

ALTER TABLE hra 
    ADD CONSTRAINT hra_hrac_FKv3 FOREIGN KEY 
    ( 
     hrac_krizek
    ) 
    REFERENCES hrac 
    ( 
     hrac_id
    ) 
;

ALTER TABLE hra 
    ADD CONSTRAINT hra_stav_FK FOREIGN KEY 
    ( 
     stav_id
    ) 
    REFERENCES stav 
    ( 
     stav_id
    ) 
;

ALTER TABLE tah 
    ADD CONSTRAINT tah_hra_FK FOREIGN KEY 
    ( 
     hra_hra_id
    ) 
    REFERENCES hra 
    ( 
     hra_id
    ) 
    ON DELETE CASCADE 
;

ALTER TABLE tah 
    ADD CONSTRAINT tah_hrac_FK FOREIGN KEY 
    ( 
     hrac_hrac_id
    ) 
    REFERENCES hrac 
    ( 
     hrac_id
    ) 
;

