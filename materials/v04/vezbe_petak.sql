-- UNION -- unija

-- 1. Izdvojiti indekse studenata koji su rodjeni u Beogradu
-- ili imaju ocenu 10. Rezultat urediti u opadajucem poretku

SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA = 'Beograd'
    OR D.INDEKS IN (
        SELECT I.INDEKS
        FROM DA.ISPIT I
        WHERE I.STATUS = 'o'
            AND I.OCENA = 10
    )
ORDER BY D.INDEKS DESC;

SELECT DISTINCT D.INDEKS
FROM DA.DOSIJE D LEFT JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS)
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

VALUES ('a', 2), ('a', 2)
UNION ALL
VALUES ('a', 2), ('a', 2), ('a', 2);

-- INTERSECT -- presek

-- 2. Izdvojiti indekse studenata koji su rodjeni u Beograd i imaju ocenu 10.
-- Rezultat urediti u opadajucem poretku.

SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA = 'Beograd'
    AND D.INDEKS IN (
        SELECT I.INDEKS
        FROM DA.ISPIT I
        WHERE I.STATUS = 'o'
            AND I.OCENA = 10
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

VALUES ('a', 2), ('a', 2)
INTERSECT ALL
VALUES ('a', 2), ('a', 2), ('a', 2);

-- 3. Izdvojiti indekse studenata koji imaju ocenu 8 i koji imaju ocenu 10

SELECT I.INDEKS
FROM DA.ISPIT I
WHERE I.STATUS = 'o' AND I.OCENA = 8
INTERSECT
SELECT I.INDEKS
FROM DA.ISPIT I
WHERE I.STATUS = 'o' AND I.OCENA = 10;

SELECT DISTINCT I8.INDEKS
FROM DA.ISPIT I8 JOIN DA.ISPIT I10 ON (I8.INDEKS = I10.INDEKS)
WHERE I8.STATUS = 'o' AND I8.OCENA = 8 AND I10.STATUS = 'o' AND I10.OCENA = 10;

-- EXCEPT -- razlika

-- 4. Izdvojiti indekse studenata koji su rodjeni u Beogradu
-- i nisu dobili ocenu 10 na nekom ispitu. Rezultat urediti
-- u opadajucem poretku

SELECT D.INDEKS AS INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA = 'Beograd'
EXCEPT
SELECT I.INDEKS AS INDEKS
FROM DA.ISPIT I
WHERE I.STATUS = 'o' AND I.OCENA = 10
ORDER BY INDEKS DESC;

-- preko spajanja ne moze tako lako jer je sada uslov da nijedna ocena
-- nije 10 tj. Vocena ocena != 10 a prethodno je bilo Eocena ocena == 10

SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE D.MESTORODJENJA = 'Beograd'
    AND D.INDEKS NOT IN (
        SELECT I.INDEKS
        FROM DA.ISPIT I
        WHERE I.STATUS = 'o'
            AND I.OCENA = 10
    )
ORDER BY D.INDEKS DESC;

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
ORDER BY D.INDEKS DESC;

VALUES ('a', 2), ('a', 2), ('a', 2), ('a', 2), ('a', 1)
EXCEPT ALL
VALUES ('a', 2), ('a', 2), ('b', 2);

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

VALUES (CURRENT_TIMESTAMP - 1 YEAR + 2 MONTHS - 3 DAYS - 5 HOURS + 5 MINUTES + 11 SECONDS) -- Nad DATE/TIME/TIMESTAMP mogu da se vrse aritmeticke operacije

VALUES (DECIMAL('123')), (2);

VALUES (CHAR(123.45)), ('a');

VALUES (CHAR(CURRENT_DATE, JIS));

VALUES (SUBSTR('1234', 1, 2));

VALUES (DECIMAL(200.123456, 7, 4));

SELECT DISTINCT SUBSTR('1234', 1, 2)
FROM DA.DOSIJE;

SELECT SUBSTR('1234', 1, 2)
FROM SYSIBM.SYSDUMMY1;

SELECT *
FROM SYSIBM.SYSDUMMY1;