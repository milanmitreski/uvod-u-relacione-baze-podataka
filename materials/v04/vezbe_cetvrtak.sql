-- UNION -- unija

-- 1. Izdvojiti indekse studenata koji su rodjeni u Beogradu
-- ili imaju ocenu 10. Rezultat urediti u opadajucem poretku

SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA = 'Beograd'
   OR D.INDEKS IN (
        SELECT I.INDEKS
        FROM DA.ISPIT I
        WHERE I.STATUS = 'o' AND I.OCENA = 10
    )
ORDER BY D.INDEKS DESC;

SELECT DISTINCT D.INDEKS
FROM DA.DOSIJE D LEFT OUTER JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS)
WHERE D.MESTORODJENJA = 'Beograd' OR (I.STATUS = 'o' AND I.OCENA = 10)
ORDER BY D.INDEKS DESC;

SELECT D.INDEKS AS INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA = 'Beograd'
UNION
SELECT I.INDEKS AS INDEKS
FROM DA.ISPIT I
WHERE I.STATUS = 'o' AND I.OCENA = 10
ORDER BY INDEKS DESC;

---- UNION ALL ("multi unija")

VALUES ('a', 2), ('a', 2) -- VALUES se koristi za fiksirane, konstantne tabele
                      -- Ovom narebom je kreirana tabela sa 2 kolone i 2 reda
UNION ALL
VALUES ('a', 2), ('a', 2), ('a', 2);

-- INTERSECT -- presek

-- 2. Izdvojiti indekse studenata koji su rodjeni u Beogradu i imaju ocenu 10.
-- Rezultat urediti u opadajucem poretku

SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA = 'Beograd'
   AND D.INDEKS IN (
        SELECT I.INDEKS
        FROM DA.ISPIT I
        WHERE I.STATUS = 'o' AND I.OCENA = 10
    )
ORDER BY D.INDEKS DESC;

SELECT DISTINCT D.INDEKS
FROM DA.DOSIJE D JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS)
WHERE D.MESTORODJENJA = 'Beograd' AND I.STATUS = 'o' AND I.OCENA = 10
ORDER BY D.INDEKS DESC;

SELECT D.INDEKS AS INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA = 'Beograd'
INTERSECT
SELECT I.INDEKS AS INDEKS
FROM DA.ISPIT I
WHERE I.STATUS = 'o' AND I.OCENA = 10
ORDER BY INDEKS DESC;

-- 3. Izdvojiti indekse studenata koji imaju ocenu 8 i
-- koji imaju ocenu 10

SELECT DISTINCT I1.INDEKS
FROM DA.ISPIT I1 JOIN DA.ISPIT I2 ON (I1.INDEKS = I2.INDEKS)
WHERE I1.STATUS = 'o' AND I1.OCENA = 8 AND I2.STATUS = 'o' and I2.OCENA = 10;

SELECT I.INDEKS
FROM DA.ISPIT I
WHERE I.STATUS = 'o' AND I.OCENA = 8
INTERSECT
SELECT I.INDEKS
FROM DA.ISPIT I
WHERE I.STATUS = 'o' AND I.OCENA = 10;

---- INTERSECT ALL ("multi presek")

VALUES ('a', 2), ('a', 2)
INTERSECT ALL
VALUES ('a', 2), ('a', 2), ('a', 2);

-- EXCEPT -- razika

-- 4. Izdvojiti indekse studenata koji su rodjenu u Beogradu
-- i nisu dobili ocenu 10 na nekom ispitu. Rezultat urediti
-- u opadajucem poretku

SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA = 'Beograd'
    AND NOT EXISTS (
        SELECT *
        FROM DA.ISPIT I
        WHERE I.INDEKS = D.INDEKS
            AND I.STATUS = 'o'
            AND I.OCENA = 10
    )
ORDER BY INDEKS DESC;

SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA = 'Beograd'
EXCEPT
SELECT I.INDEKS
FROM DA.ISPIT I
WHERE I.STATUS = 'o' AND I.OCENA = 10
ORDER BY INDEKS DESC;

---- EXCEPT ALL ("multi razlika")

VALUES ('a', 2), ('a', 2)
EXCEPT ALL
VALUES ('a', 2), ('a', 2), ('a', 2);

VALUES ('a', 2), ('a', 2), ('a', 1)
EXCEPT ALL
VALUES ('a', 2), ('a', 2), ('a', 2);

VALUES ('a', 2), ('a', 2), ('a', 2), ('a', 2), ('a', 2)
EXCEPT ALL
VALUES ('a', 2), ('a', 2), ('a', 2);

-- SKALARNE FUNKCIJE

VALUES (CURRENT_TIME, CURRENT_DATE, CURRENT_TIMESTAMP);

VALUES (DATE('20.03.2022'), DATE('03/20/2022'), DATE('2022-03-20'));

VALUES (DATE('20.03.2022'), YEAR('20.03.2022'),
        MONTH('20.03.2022'), MONTHNAME('20.03.2022'),
        WEEK('20.03.2022'),
        DAY('20.03.2022'), DAYNAME('20.03.2022'), DAYNAME('20.03.2022', 'sr_cirilic_sr'),
        DAYOFYEAR('20.03.2022'), DAYOFWEEK('20.03.2022')); -- 1 je nedelja, 7 je subota

VALUES (TIME('11:54:32'));

VALUES (TIME('11:54:32'), HOUR('11:54:32'),
        MINUTE('11:54:32'), SECOND('11:54:32'));

VALUES TIMESTAMP(DATE('20.03.2022'), TIME('11:54:32'));

VALUES TIMESTAMP('20.03.2022', '11:54:32');

VALUES (MONTHNAME(TIMESTAMP('20.03.2022', '11:54:32')),
        HOUR(TIMESTAMP('20.03.2022', '11:54:32')));

VALUES (YEARS_BETWEEN('12.01.2024', '20.03.2022')); -- vraca PUN broj godina izmedju date1 i date2

VALUES (MONTHS_BETWEEN('12.01.2024', '20.03.2022')); -- vraca RAZLOMLJENI broj meseci

VALUES (DAYS_BETWEEN('12.01.2024', '20.03.2022')); -- vraca UKUPAN broj dana izmedju dva datuma

VALUES (DATE('12.01.2024') - DATE('20.03.2022')); -- yy..yyymmdd - broj godina, meseci i dana izmedju dva datuma

VALUES (YEAR(DATE('12.01.2024') - DATE('20.03.2022')),
        MONTH(DATE('12.01.2024') - DATE('20.03.2022')),
        DAY(DATE('12.01.2024') - DATE('20.03.2022'))); -- YEAR, MONTH, DAY izvlace delove iz razlike datuma

VALUES (CURRENT_TIMESTAMP - 1 YEAR + 3 DAYS - 5 HOURS + 11 SECONDS) -- Nad DATE/TIME/TIMESTAMP mogu da se vrse aritmeticke operacije

VALUES (DECIMAL('123')), (2);

VALUES (CHAR(123.45)), ('a');

VALUES (CHAR(CURRENT_TIME, USA));

VALUES (SUBSTR('1234', 1, 2));

VALUES (DECIMAL(200, 5, 3));

SELECT DISTINCT SUBSTR('1234', 1, 2)
FROM DA.DOSIJE;

SELECT SUBSTR('1234', 1, 2)
FROM SYSIBM.SYSDUMMY1;

