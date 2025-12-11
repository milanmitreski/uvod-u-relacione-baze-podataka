-- 1. Izracunati koji je dan u nedelji (njegovo ime) bio 03.11.2019.

SELECT DAYNAME('03.11.2019')
FROM SYSIBM.SYSDUMMY1;

-- 2. Za danasnji datum izracunati:
--      - koji je dan u godini
--      - u kojoj je nedelji u godini
--      - koji je dan u nedelji
--      - ime dana
--      - ime meseca

SELECT DAYOFYEAR(CURRENT_DATE) AS "DAN U GODINI",
       WEEK(CURRENT_DATE) AS "NEDELJA U GODINI",
       DAYOFWEEK(CURRENT_DATE) AS "DAN U NEDELJI",
       DAYNAME(CURRENT_DATE, 'sr_latn_sr') AS "IME DANA",
       MONTHNAME(CURRENT_DATE, 'sr_latn_sr') AS "IME MESECA"
FROM SYSIBM.SYSDUMMY1;

-- 3. Izdvojiti sekunde iz trenutnog vremena

SELECT CURRENT_TIME, SECOND(CURRENT_TIME)
FROM SYSIBM.SYSDUMMY1;

-- 4. Izracunati koliko vremena je proslo izmedju 06.08.2005. i 11.11.2008

SELECT YEAR(DATE('11.11.2008') - DATE('06.08.2005')) AS "GODINE",
       MONTH(DATE('11.11.2008') - DATE('06.08.2005')) AS "MESECI",
       DAY(DATE('11.11.2008') - DATE('06.08.2005')) AS "DANI"
FROM SYSIBM.SYSDUMMY1;

SELECT DAYS_BETWEEN(DATE('11.11.2008'), DATE('06.08.2005'))
FROM SYSIBM.SYSDUMMY1;

-- 5. Izracunati koji ce datum biti za 12 godina, 5 meseci i 25 dana

SELECT CURRENT_DATE + 12 YEARS + 5 MONTHS + 25 DAYS
FROM SYSIBM.SYSDUMMY1;

-- 6. Izdvojiti ispite koji su odrazani posle 28. septembra 2020

SELECT DISTINCT SKGODINA, OZNAKAROKA, IDPREDMETA, DATPOLAGANJA
FROM DA.ISPIT I
WHERE I.DATPOLAGANJA > DATE('28.09.2020');

-- 7. Pronaci ispite koji su odrzani u poslednjih 8 meseci

-- CURRENT_DATE - DATPOLAGANJA < 00000...00800
--                               yyyyy...ymmdd

SELECT *
FROM DA.ISPIT I
WHERE CURRENT_DATE - I.DATPOLAGANJA < 800;

SELECT *
FROM DA.ISPIT I
WHERE MONTHS_BETWEEN(CURRENT_DATE, I.DATPOLAGANJA) < 8;

-- 8. Za sve ispite koi su odrzani u poslednjih 7 godina
-- izracunati koliko je godina, meseci i dana proslo od njihovog
-- odrzavanja. Izdvojiti indeks, naziv predmeta, ocenu, broj godina,
-- broj meseci i broj dana od datuma polaganja.

SELECT I.INDEKS,
       P.NAZIV,
       I.OCENA,
       YEAR(CURRENT_DATE - I.DATPOLAGANJA) AS GODINE,
       MONTH(CURRENT_DATE - I.DATPOLAGANJA) AS MESECI,
       DAY(CURRENT_DATE - I.DATPOLAGANJA) AS DANI
FROM DA.ISPIT I JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
WHERE CURRENT_DATE - I.DATPOLAGANJA < 70000;

-- 9. Prikazati trenutno vreme i trenutni datum u
--      - ISO formatu
--      - USA formatu
--      - EUR formatu

SELECT CHAR(CURRENT_DATE, ISO) || ' ' || CHAR(CURRENT_TIME, ISO) AS ISO,
       CHAR(CURRENT_DATE, USA) || ' ' || CHAR(CURRENT_TIME, USA) AS USA,
       CHAR(CURRENT_DATE, EUR) || ' ' || CHAR(CURRENT_TIME, EUR) AS EUR
FROM SYSIBM.SYSDUMMY1;

-- 10. Ako je predmetima potrebno uvecati broj espb bodova za 20%
-- prikazati koliko ce svaki predmet imati espb bodova nakon uvecanja
-- Uvecani broj bodova prikazati sa dve decimale

SELECT P.ID, P.NAZIV, P.ESPB, DECIMAL(1.2*ESPB, 4, 2) AS "UVECANI ESPB"
FROM DA.PREDMET P;

-- 11. Ako je predmetima potrebno uvecati broj ESPB bodova za 20%
-- prikazati koliko ce ESPB bodova imati predmeti koji nakon uvecanja
-- imaju vise od 8 bodova. Uvecani broj espb bodova zaokruziti na
-- vecu ili jednaku celobrojnu vrednost

SELECT P.ID, P.NAZIV, P.ESPB, CEIL(DECIMAL(1.2*ESPB, 4, 2)) AS "UVECANI ESPB"
FROM DA.PREDMET P
WHERE 1.2*ESPB > 8;

-- 12. Pronaci indekse studenata koji su jedini polozili ispit iz
-- nekog predmeta sa ocenom 10. Za studenta sa brojem indeksa GGGGBBBB
-- izdvojiti indeks u formatu BBBB/GGGG.

SELECT SUBSTR(CHAR(INDEKS), 5, 4) || '/' || SUBSTR(CHAR(INDEKS), 1, 4)
FROM DA.DOSIJE D
WHERE EXISTS(
    SELECT *
    FROM DA.ISPIT I
    WHERE I.INDEKS = D.INDEKS
        AND I.STATUS = 'o'
        AND I.OCENA = 10
        AND NOT EXISTS (
            SELECT *
            FROM DA.ISPIT I1
            WHERE I1.INDEKS <> I.INDEKS
                AND I1.IDPREDMETA = I.IDPREDMETA
                AND I1.STATUS = 'o'
                AND I1.OCENA = 10
        )
);

-- 13. Izlistati ocene dobijene na ispitima i ako je ocena jednaka
-- 5 ispisati NULL

SELECT NULLIF(OCENA, 5) AS OCENA
FROM DA.ISPIT
ORDER BY OCENA DESC NULLS LAST;

-- 14. Izdvojiti indeks, ime, prezime i mesto rodjenja za svakog
-- studenta. Ako je mesto rodjenja 'Sabac', prikazati NULL

SELECT D.INDEKS, D.IME, D.PREZIME, D.MESTORODJENJA, NULLIF(D.MESTORODJENJA, 'Sabac')
FROM DA.DOSIJE D;

-- 15. Izdvojiti indeks, ime, prezime i mesto rodjenja za svakog
-- studenta. Ako je mesto rodjenja nepoznato, umesto NULL vrednosti
-- ispisati "Nepoznato"

SELECT D.INDEKS, D.IME, D.PREZIME, D.MESTORODJENJA, COALESCE(D.MESTORODJENJA, 'Nepoznato')
FROM DA.DOSIJE D;

-- 16. Izdvojiti indeks, ime, prezime i datum diplomiranja za svakog
-- studenta. Ako je datum diplomiranja nepoznat, umesto NULL vrednosti
-- ispisati "Nije diplomirao"

SELECT D.INDEKS, D.IME, D.PREZIME, D.DATDIPLOMIRANJA,
       COALESCE(CHAR(D.DATDIPLOMIRANJA), 'Nepoznato') AS STRING,
       COALESCE(D.DATDIPLOMIRANJA, DATE('31.12.9999')) AS DATUM
FROM DA.DOSIJE D;

-- 17. Za svaki polagan ispit izdvojit indeks, identifikator
-- predmeta i dobijenu ocenu. Vrednost ocene ispisati i slovima.
-- ko je predmet nepolozen, umesto ocene ispisati nepolozen

SELECT I.INDEKS, I.IDPREDMETA, COALESCE(CHAR(NULLIF(I.OCENA, 5)), 'Nepolozen'),
    CASE
        WHEN OCENA=10 THEN 'Deset'
        WHEN OCENA=9 THEN 'Devet'
        WHEN OCENA=8 THEN 'Osam'
        WHEN OCENA=7 THEN 'Sedam'
        WHEN OCENA=6 THEN 'Sest'
        ELSE 'Nepolozen'
    END
FROM DA.ISPIT I
WHERE I.STATUS NOT IN ('p', 'n');

-- 18. Klasifikovati predmete prema broju ESPB bodova na sledeci nacin:
--  - Ako predmet ima vise od 15 ESPB bodova, tada pripada I kategoriji
--  - Ako je broj ESPB bodova predmeta u intervalu [10, 15], tada pripada
--    II kategoriji
--  - Inace predmet pripada III kategoriji
-- Izdvojiti naziv predmeta, ESPB bodove i kategoriju.

SELECT P.NAZIV, P.ESPB,
    CASE
        WHEN ESPB > 15 THEN 'I'
        WHEN ESPB BETWEEN 10 AND 15 THEN 'II'
        ELSE 'III'
    END AS KATEGORIJA
FROM DA.PREDMET P;

-- 19. Izdvojiti indeks, ime, prezime, mesto rodjenja i inicijale studenata
-- Ime i prezime napisati u jednoj kolone, a za studente rodjene u Beogradu
-- kao mesto rodjenja ispisati BG

SELECT D.IME || ' ' || D.PREZIME AS "Ime i prezime",
    CASE
        WHEN MESTORODJENJA LIKE '%Beograd%' THEN 'BG'
        WHEN MESTORODJENJA LIKE '%Nis%' THEN 'NI'
        ELSE MESTORODJENJA
    END AS "MESTORODJENJA",
    SUBSTR(D.IME, 1, 1) || '. ' || SUBSTR(D.PREZIME, 1, 1) || '.'
    AS "INICIJALI"
FROM DA.DOSIJE D;