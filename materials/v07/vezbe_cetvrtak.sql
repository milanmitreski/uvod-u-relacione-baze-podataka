-- 1. Predmeti se kategorisu kao
-- laki: ukoliko nose manje od 6 bodova
-- teski: ukoliko nose vise od 8 bodova
-- inace su srednje teski
-- Prebrojati koliko predmeta pripada kojoj kategoriji
-- Izdvojiti kategoriju i broj predmeta iz te kategorije

SELECT CASE
           WHEN P.ESPB < 6 THEN 'lak'
           WHEN P.ESPB > 8 THEN 'tezak'
           ELSE 'srednje tezak'
       END AS KATEGORIJA, COUNT(*)
FROM DA.PREDMET P
GROUP BY CASE
           WHEN P.ESPB < 6 THEN 'lak'
           WHEN P.ESPB > 8 THEN 'tezak'
           ELSE 'srednje tezak'
       END;

WITH POM AS (
    SELECT P.ID, CASE
               WHEN P.ESPB < 6 THEN 'lak'
               WHEN P.ESPB > 8 THEN 'tezak'
               ELSE 'srednje tezak'
           END AS KATEGORIJA -- svaka kolona u pomocnoj tabeli MORA biti imenovana
    FROM DA.PREDMET P
)
SELECT KATEGORIJA, COUNT(*)
FROM POM
GROUP BY KATEGORIJA;

-- 2. Izracunati koliko studenata je polozilo vise od 20 bodova

WITH STUDENTI_POLOZENO AS (
    SELECT I.INDEKS, SUM(P.ESPB) AS POLOZENO_ESPB
    FROM DA.ISPIT I JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
    WHERE I.STATUS = 'o' AND I.OCENA > 5
    GROUP BY I.INDEKS
)
SELECT COUNT(*)
FROM STUDENTI_POLOZENO
WHERE POLOZENO_ESPB > 20;

WITH STUDENTI_POLOZENO AS (
    SELECT I.INDEKS
    FROM DA.ISPIT I JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
    WHERE I.STATUS = 'o' AND I.OCENA > 5
    GROUP BY I.INDEKS
    HAVING SUM(P.ESPB) > 20
)
SELECT COUNT(*)
FROM STUDENTI_POLOZENO;

-- 3. Za svakog studenta naci broj ispitnih rokova u kojima je on
-- polozio bar 2 predmeta

WITH STUDENT_ISPITNIROK_POLOZENO_BAR_DVA AS (
    SELECT I.INDEKS, I.SKGODINA, I.OZNAKAROKA
    FROM DA.ISPIT I
    WHERE I.STATUS = 'o' AND I.OCENA > 5
    GROUP BY I.INDEKS, I.SKGODINA, I.OZNAKAROKA
    HAVING COUNT(*) >= 2
)
SELECT INDEKS, COUNT(*) AS "BROJ ISPITNIH ROKOVA"
FROM STUDENT_ISPITNIROK_POLOZENO_BAR_DVA
GROUP BY INDEKS;

-- 4. Za svakog studenta izdvojiti ime i prezime i broj
-- razlicitih predmeta iz kojih je pao ispit (ako nije pao
-- ispit - izdvojiti 0)

SELECT D.INDEKS, COUNT(DISTINCT IDPREDMETA)
FROM DA.DOSIJE D LEFT JOIN DA.ISPIT I ON (
        D.INDEKS = I.INDEKS
            AND I.STATUS = 'o'
            AND I.OCENA = 5
    )
GROUP BY D.INDEKS;

WITH BROJ_PALIH AS (
    SELECT I.INDEKS, COUNT(DISTINCT IDPREDMETA) AS BROJ_PALIH
    FROM DA.ISPIT I
    WHERE I.STATUS = 'o'AND I.OCENA = 5
    GROUP BY I.INDEKS
)
SELECT D.IME, D.PREZIME, COALESCE(BP.BROJ_PALIH, 0)
FROM DA.DOSIJE D LEFT JOIN BROJ_PALIH BP ON (D.INDEKS = BP.INDEKS);

-- 6. Izdvojiti broj studenata koji su polozili neke predmete
-- u bar 2 razlicita roka

WITH STUDENTI_ISPITNIROK_POLOZENO AS (
    SELECT DISTINCT I.INDEKS, I.SKGODINA, I.OZNAKAROKA
    FROM DA.ISPIT I
    WHERE I.STATUS = 'o' AND I.OCENA > 5
), STUDENTI_POLOZILI_U_BAR_DVA_ISPITNA_ROKA AS (
    SELECT INDEKS
    FROM STUDENTI_ISPITNIROK_POLOZENO
    GROUP BY INDEKS
    HAVING COUNT(*) >= 2
)
SELECT COUNT(*)
FROM STUDENTI_POLOZILI_U_BAR_DVA_ISPITNA_ROKA;

-- 7. Izdvojiti ime i prezime studenta i naziv ispitnog roka u kome
-- student ima svoj najmanji procenat uspešnosti na ispitima.
-- Izdvojiti i procenat uspešnosti na ispitima u tom roku kao
-- decimalan broj sa 2 cifre iza decimalne tačke. Procenat uspešnosti
-- studenta u ispitnom roku se računa kao procenat broja položenih
-- ispita u odnosu na broj prijavljenih ispita. Izdvojiti samo podatke
-- za studente iz Aranđelovca i koji u tom roku imaju najmanji
-- procenat uspešnosti u poređenju sa ostalim studentima.

WITH STUDENT_ISPITNIROK_PROCENAT AS (
    SELECT I.INDEKS, I.SKGODINA, I.OZNAKAROKA,
            COUNT(
                CASE
                    WHEN I.STATUS = 'o' AND I.OCENA > 5 THEN 1
                    ELSE NULL
                END
            )*1.0/COUNT(*) AS PROCENAT
    FROM DA.ISPIT I
    GROUP BY I.INDEKS, I.SKGODINA, I.OZNAKAROKA
), STUDENT_ISPITNIROK_NAJMANJIPROCENAT AS (
    SELECT INDEKS, SKGODINA, OZNAKAROKA, PROCENAT
    FROM STUDENT_ISPITNIROK_PROCENAT SIP1
    WHERE SIP1.PROCENAT = (
            SELECT MIN(PROCENAT)
            FROM STUDENT_ISPITNIROK_PROCENAT SIP2
            WHERE  SIP1.INDEKS = SIP2.INDEKS
        )
)
SELECT D.IME, D.PREZIME, IR.NAZIV, DECIMAL(SINP.PROCENAT, 5, 2) AS PROCENAT
FROM DA.DOSIJE D JOIN STUDENT_ISPITNIROK_NAJMANJIPROCENAT SINP ON (D.INDEKS = SINP.INDEKS)
        JOIN DA.ISPITNIROK IR ON (SINP.SKGODINA = IR.SKGODINA AND SINP.OZNAKAROKA = IR.OZNAKAROKA)
WHERE D.MESTORODJENJA = 'Arandjelovac' AND SINP.PROCENAT = (
        SELECT MIN(PROCENAT)
        FROM STUDENT_ISPITNIROK_PROCENAT SIP
        WHERE SIP.SKGODINA = SINP.SKGODINA
            AND SIP.OZNAKAROKA = SINP.OZNAKAROKA
    );