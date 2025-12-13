-- 1. Izdvojiti ukupan broj studenata

SELECT COUNT(INDEKS)
FROM DA.DOSIJE; -- ako se ne navede group by, celu tabelu posmatramo kao jednu grupu

SELECT COUNT(DATDIPLOMIRANJA)
FROM DA.DOSIJE; -- COUNT ne broji NULL vrednosti!

SELECT COUNT(*)
FROM DA.DOSIJE; -- ovo broji sve redove

-- 2. Izdvojiti ukupan broj studenata koji bar iz jednog predmeta imaju ocenu 10

SELECT COUNT(DISTINCT I.INDEKS) -- broji samo razlicite vrednosti indeksa
FROM DA.ISPIT I
WHERE I.STATUS = 'o' AND I.OCENA = 10;

SELECT COUNT(INDEKS)
FROM DA.DOSIJE D
WHERE EXISTS (
    SELECT *
    FROM DA.ISPIT I
    WHERE D.INDEKS = I.INDEKS
        AND I.STATUS = 'o'
        AND I.OCENA = 10
);

-- 3. Izdvojiti ukupan broj polozenih predmeta i polozenih ESPB poena
-- za studenta sa indeksom 25/2016

SELECT COUNT(*) AS "Broj polozenih ispita", SUM(P.ESPB) AS "Broj polozenih ESPB"
FROM DA.ISPIT I JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
WHERE I.INDEKS = 20160025
    AND I.STATUS = 'o'
    AND I.OCENA > 5;

-- 4. Koliko ima razlicitih ocena dobijenih na ispitima, a
-- da ocena nije 5

SELECT COUNT(DISTINCT NULLIF(OCENA, 5))
FROM DA.ISPIT;

SELECT COUNT(DISTINCT OCENA)
FROM DA.ISPIT
WHERE OCENA <> 5;

-- 5. Izdvojiti oznake, nazive i espb bodove predmeta
-- ciji je broj espb bodova veci od prosecnog broja
-- espb bodova svih predmeta

SELECT P.OZNAKA, P.NAZIV, P.ESPB
FROM DA.PREDMET P
WHERE P.ESPB > (
        SELECT AVG(P2.ESPB+0.0)
        FROM DA.PREDMET P2
    );

-- 6. Za svakog studenta upisanog na fakultet 2018. godine,
-- koji ima bar jedan polozen ispit, izdvojiti broj indeksa,
-- prosecnu ocenu zaokruzenu na dve decimale, najmanju i najevcu
-- ocenu iz polozenih ispita

SELECT D.INDEKS, DECIMAL(AVG(I.OCENA+0.0), 4, 2) AS PROSEK,
        MIN(I.OCENA) AS "NAJMANJA OCENA", MAX(I.OCENA) AS "NAJVECA OCENA"
FROM DA.DOSIJE D JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS)
WHERE YEAR(D.DATUPISA) = 2018
    AND I.STATUS = 'o'
    AND I.OCENA > 5
GROUP BY D.INDEKS;

-- izdvojiti samo one studente ciji je prosek > 7.5 ali nisu dobili ocenu 10

SELECT D.INDEKS, DECIMAL(AVG(I.OCENA+0.0), 4, 2) AS PROSEK,
        MIN(I.OCENA) AS "NAJMANJA OCENA", MAX(I.OCENA) AS "NAJVECA OCENA"
FROM DA.DOSIJE D JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS)
WHERE YEAR(D.DATUPISA) = 2018
    AND I.STATUS = 'o'
    AND I.OCENA > 5
GROUP BY D.INDEKS
HAVING AVG(I.OCENA+0.0) > 7.5 AND MAX(I.OCENA) <= 9;

-- 7. Izdvojiti naziv predmeta, skolsku godinu u kojoj je odrzan ispit
-- iz tog predmeta i najvecu ocenu dobijenu na ispitima iz tog predmeta
-- u toj skolskoj godini

SELECT P.NAZIV, I.SKGODINA, COALESCE(CHAR(NULLIF(MAX(I.OCENA), 5)), 'Niko nije polozio ispit')
FROM DA.ISPIT I JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
GROUP BY P.ID, P.NAZIV, I.SKGODINA;

-- 8. Za svaki predmet izracunati koliko studenata ga je polozilo.
-- Izdvojiti i predmete koje niko nije polozio

SELECT P.ID, COUNT(I.OCENA)
FROM DA.PREDMET P LEFT JOIN DA.ISPIT I ON (
    P.ID = I.IDPREDMETA AND
        I.OCENA > 5 AND
        I.STATUS = 'o'
    )
GROUP BY P.ID;

-- 9. Izdvojiti identifikatore predmeta za koje je ipsit
-- prijavilo vise od 50 razlicitih studenata

SELECT P.ID
FROM DA.PREDMET P
WHERE 50 < (
    SELECT COUNT(DISTINCT INDEKS)
    FROM DA.ISPIT I
    WHERE I.IDPREDMETA = P.ID
);

SELECT I.IDPREDMETA
FROM DA.ISPIT I
GROUP BY I.IDPREDMETA
HAVING COUNT(DISTINCT INDEKS) > 50;

-- 10. Za ispitne rokove koji su odrzani u 2016. godini i u kojima su svi
-- regularno polagani ispiti i polozeni, izdvojiti oznaku roka,
-- broj polozenih ispita u tom roku i broj studenata koji su polozili
-- ispite u tom roku

SELECT I.OZNAKAROKA, COUNT(I.OCENA) AS POLOZENI, COUNT(DISTINCT I.INDEKS) AS STUDENTI
FROM DA.ISPIT I
WHERE I.STATUS = 'o'
    AND I.SKGODINA = 2016
GROUP BY I.OZNAKAROKA
HAVING MIN(I.OCENA) > 5;

-- 11. Za svakog studenta izdvojiti broj indeksa i mesec u kome je polozio
-- vise od dva ispita (nije vazno koje godine). Izdvojiti indeks studenta,
-- ime meseca i broj polozenih predmeta. Rezultat urediti prema broju indeksa
-- i mesecu polaganja

SELECT INDEKS, MONTH(I.DATPOLAGANJA) AS MESEC
FROM DA.ISPIT I
WHERE I.STATUS = 'o' AND I.OCENA > 5
GROUP BY I.INDEKS, MONTH(I.DATPOLAGANJA)
HAVING COUNT(*) > 2
ORDER BY INDEKS, MESEC;

-- 12. Za svaki predmet koji nosi najmanje ESPB bodova izdvojiti
-- studente koji su ga polozili. Izdvojiti naziv predmeta i ime i
-- prezime studenta. Ime i prezime studenta izdvojiti  jednoj koloni
-- Za predmete sa najmanjim broje espb koje nije polozio nijedan student, umesto
-- imena i prezimena ispisati "Nema".

SELECT P.NAZIV, COALESCE(D.IME || ' ' || D.PREZIME, 'Nema')
FROM DA.PREDMET P LEFT JOIN DA.ISPIT I ON (
        I.IDPREDMETA = P.ID AND
            I.STATUS = 'o' AND
            I.OCENA > 5
    ) LEFT JOIN DA.DOSIJE D ON (I.INDEKS = D.INDEKS)
WHERE P.ESPB = (
    SELECT MIN(P2.ESPB)
    FROM DA.PREDMET P2
);

-- 13. Izdvojiti parove studenata cija imena pocinju na slovo M
-- i za koje vazi da su bar dva ista predmeta polozili u istom ispitnom roku.

SELECT D1.INDEKS, D2.INDEKS
FROM DA.DOSIJE D1
    JOIN DA.DOSIJE D2 ON (D1.IME LIKE 'M%' AND D2.IME LIKE 'M%' AND D1.INDEKS < D2.INDEKS)
    JOIN DA.ISPIT I1 ON (D1.INDEKS = I1.INDEKS AND I1.STATUS = 'o' AND I1.OCENA > 5)
    JOIN DA.ISPIT I2 ON (D2.INDEKS = I2.INDEKS AND I2.STATUS = 'o' AND I2.OCENA > 5
                         AND I1.IDPREDMETA = I2.IDPREDMETA AND I1.SKGODINA = I2.SKGODINA
                         AND I1.OZNAKAROKA = I2.OZNAKAROKA)
GROUP BY D1.INDEKS, D2.INDEKS
HAVING COUNT(*) > 2;

-- 14. Za svakog studenta koji je polozio izmedju 15 i 25 bodova
-- i cije ime sadrzi malo ili veliko slovo o ili a, izdvojit indeks,
-- ime, prezime, broj prijavljenih ispita, broj razlicitih predmeta
-- koje je prijavio, broj ispita koje je polozio i prosecnu ocenu
-- Rezultat urediti prema indeksu.

SELECT D.INDEKS, D.IME, D.PREZIME, COUNT(*) AS BROJ_PRIJAVLJENIH,
        COUNT(DISTINCT I.IDPREDMETA) AS BROJ_RAZLICITIH_PREDMETA,
        COUNT(
            CASE
                WHEN I.STATUS = 'o' AND I.OCENA > 5 THEN 1
                ELSE NULL
            END
        ) AS BROJ_POLOZENIH,
        DECIMAL(AVG(
            CASE
                WHEN I.STATUS = 'o' AND I.OCENA > 5 THEN I.OCENA+0.0
                ELSE NULL
            END
        ), 4, 2) AS PROSECNA_OCENA
FROM DA.DOSIJE D
    JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS)
    JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
WHERE LOWER(D.IME) LIKE '%a%' OR LOWER(D.IME) LIKE '%o%'
GROUP BY D.INDEKS, D.IME, D.PREZIME
HAVING SUM(CASE
            WHEN I.STATUS = 'o' AND I.OCENA > 5 THEN P.ESPB
            ELSE 0
           END) BETWEEN 15 AND 25;

-- Zadaci za vezbanje

-- 1. Izdvojiti ukupan broj studenata, leksikografski gledano najmanje
-- ime i najveci broj indeksa studenta iz tabele dosije.

-- 2. Odrediti ukupan broj studenata, broj studenata kojima
-- je poznat datum diplomiranja i broj razlicitih vrednosti
-- za mesto rodenja.

-- 3. Za studente koji su nesto polozili, izdvojiti broj indeksa i
-- ukupan broj skupljenih bodova.

-- 4. Za studenta koji je skupio bar 20 bodova prikazati ukupan
-- broj skupljenih bodova. Rezultat urediti rastuce po ukupnom
-- broju skupljenih bodova.

-- 5. Izracunati prosek studentima koji su polozili neki ispit.
-- Rezultat urediti opadajuce po proseku.

-- 6. Za svaki od ispitnih rokova i za svaki polagan predmet u
-- tom roku odrediti broj uspesnih polaganja. Uzeti u obzir samo
-- rokove i predmete takve da je u izdvojenom roku bilo polozenih
-- ispita iz izdvojenog predmeta.

-- 7.  Izdvojiti brojeve indeksa studenata koji su polozili
-- bar 3 ispita i identifikatore predmeta koje su polozila bar
-- tri studenta. Sve to uradi u jednom upitu i rezultat urediti
-- u opadajucem poretku po broju polozenih ispita, odnosno broju
-- studenata.

-- 8. Za svaki predmet izdvojiti broj studenata koji su ga polagali.
-- Izdvojiti naziv predmeta i broj studenata. Za predmete koje niko
-- nije polagao izdvojiti 0. Rezultat urediti prema broju studenata
-- koji su polagali predmet u opadajucem poretku.

-- 9. Za studenta koji je polagao neki ispit izracunati iz koliko
-- ispita je dobio ocenu 8 i iz koliko ispita je dobio ocenu 9.
-- Izdvojiti indeks studenta,

-- 10.Izdvojiti informacije o studentima koji su prvi diplomirali
-- na fakultetu.