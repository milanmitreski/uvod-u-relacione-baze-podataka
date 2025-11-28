-- 1. Izdvojiti nazive predmeta na koje je IZASAO student sa indeksom 22/2017.

-- Varijanta 1 - resenje spajanjem

SELECT  DISTINCT P.NAZIV
FROM    DA.ISPIT I
    JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
WHERE   I.INDEKS = 20170022 AND I.STATUS NOT IN ('p', 'n');

-- Varijanta 2 - podupit sa EXISTS

SELECT  P.NAZIV
FROM    DA.PREDMET P
WHERE   EXISTS (
    SELECT  *
    FROM    DA.ISPIT I
    WHERE   I.IDPREDMETA = P.ID
        AND I.INDEKS = 20170022
        AND I.STATUS NOT IN ('p', 'n')
);

-- Varijanta 3 - podupit sa IN

SELECT  P.NAZIV
FROM    DA.PREDMET P
WHERE   P.ID IN (
    SELECT  I.IDPREDMETA
    FROM    DA.ISPIT I
    WHERE   I.INDEKS = 20170022
        AND I.STATUS NOT IN ('p', 'n')
);

-- Varijanta 4 - podupit as IN, na malo drugaciji nacin

SELECT P.NAZIV
FROM DA.PREDMET P
WHERE 20170022 IN (
    SELECT  I.INDEKS
    FROM    DA.ISPIT I
    WHERE   I.IDPREDMETA = P.ID
        AND I.STATUS NOT IN ('p', 'n')
);

-- 2. Izdvojiti ime i prezime studenta koji ima ispit polozen sa ocenom 9.

-- Varijanata sa spajanjem

SELECT  DISTINCT D.IME, D.PREZIME
FROM    DA.DOSIJE D
    JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS)
WHERE   I.STATUS = 'o'
  AND   I.OCENA = 9;

-- Varijanta sa EXISTS

SELECT  D.IME, D.PREZIME
FROM    DA.DOSIJE D
WHERE   EXISTS (
    SELECT  *
    FROM    DA.ISPIT I
    WHERE   I.INDEKS = D.INDEKS
        AND I.STATUS = 'o'
        AND I.OCENA = 9
)

-- 3. Izdvojiti indekse studenata koji su polozili bar jedan predmet koji
-- nije polozio student sa indeksom 22/2017.

SELECT  DISTINCT I.INDEKS
FROM    DA.ISPIT I
WHERE   I.STATUS = 'o'
    AND I.OCENA > 5
    AND NOT EXISTS (
        SELECT  *
        FROM    DA.ISPIT I1
        WHERE   I1.IDPREDMETA = I.IDPREDMETA
            AND I1.STATUS = 'o'
            AND I1.OCENA > 5
            AND I1.INDEKS = 20170022
    );

SELECT  D.INDEKS
FROM    DA.DOSIJE D
WHERE   EXISTS (
    SELECT  *
    FROM    DA.ISPIT I
    WHERE   D.INDEKS = I.INDEKS
        AND I.STATUS = 'o'
        AND I.OCENA > 5
        AND NOT EXISTS (
            SELECT  *
            FROM    DA.ISPIT I1
            WHERE   I1.IDPREDMETA = I.IDPREDMETA
                AND I1.STATUS = 'o'
                AND I1.OCENA > 5
                AND I1.INDEKS = 20170022
        )
);

-- 4. Koriscenjem egzistencijalnog kvantifikatora exists izdvojiti
-- nazive predmeta koje je polozio student sa indeksom 22/2017.

SELECT  P.NAZIV
FROM    DA.PREDMET P
WHERE   EXISTS (
    SELECT  *
    FROM    DA.ISPIT I
    WHERE   I.IDPREDMETA = P.ID
        AND I.STATUS = 'o'
        AND I.OCENA > 5
        AND I.INDEKS = 20170022
);

-- 5. Izdvojiti naziv predmeta ciji je kurs organizovan u svim skolskim
-- godinama o kojima postoje podaci u bazi podataka.

SELECT  P.NAZIV
FROM    DA.PREDMET P
WHERE   NOT EXISTS (
    SELECT  *
    FROM    DA.SKOLSKAGODINA SG
    WHERE   NOT EXISTS (
        SELECT  *
        FROM    DA.KURS K
        WHERE   K.IDPREDMETA = P.ID
            AND K.SKGODINA = SG.SKGODINA
    )
);

-- Za resenje sa nekorelisanim podupitom pogledati script.sql

-- 6. Izdvojiti podatke o studentu koji je upisao sve skolske godine o
-- kojima postoje podaci u bazi podataka.

-- Slicna stvar samo sa tabelom DA.UPISGODINE

-- Varijanta sa IN

-- Varijanta sa EXISTS

-- 7. Izdvojiti indekse studenata koji su izasli u svim ispitnim rokovima.

SELECT  *
FROM    DA.DOSIJE D
WHERE   NOT EXISTS (
    SELECT  *
    FROM    DA.ISPITNIROK IR
    WHERE   NOT EXISTS (
        SELECT  *
        FROM    DA.ISPIT I
        WHERE   I.SKGODINA = IR.SKGODINA
            AND I.OZNAKAROKA = IR.OZNAKAROKA
            AND I.INDEKS = D.INDEKS
            AND I.STATUS NOT IN ('p', 'n')
    )
);

-- Nema takvih studenata!

-- 8. Izdvojiti indekse studenata koji su polagali u svim ispitnim rokovima
-- odrzanim u 2018/2019. sk. godini.

SELECT  *
FROM    DA.DOSIJE D
WHERE   NOT EXISTS (
    SELECT  *
    FROM    DA.ISPITNIROK IR
    WHERE   IR.SKGODINA = 2018
        AND NOT EXISTS (
            SELECT  *
            FROM    DA.ISPIT I
            WHERE   I.SKGODINA = IR.SKGODINA
                AND I.OZNAKAROKA = IR.OZNAKAROKA
                AND I.INDEKS = D.INDEKS
                AND I.STATUS NOT IN ('p', 'n')
        )
);

-- Nema takvih studenata!

-- 9. Izdvojiti podatke o predmetima sa najvecim brojem espb bodova.

-- Varijanta sa EXISTS

SELECT  *
FROM    DA.PREDMET P
WHERE   NOT EXISTS (
    SELECT  *
    FROM    DA.PREDMET P1
    WHERE   P1.ESPB > P.ESPB
);

-- Varijanta sa ALL

SELECT  *
FROM    DA.PREDMET P
WHERE   P.ESPB >= ALL (
        SELECT P1.ESPB
        FROM DA.PREDMET P1
    );

-- 10. Izdvojiti podatke o studentima sa najranijim datumom diplomiranja.

-- Za vezbu

-- 11. Izdvojiti podatke o svim studentima osim onih sa najranijim datumom diplomiranja.

-- Varijanta sa negacijom od ALL

SELECT  *
FROM    DA.DOSIJE D
WHERE   NOT D.DATDIPLOMIRANJA <= ALL (
        SELECT D1.DATDIPLOMIRANJA
        FROM DA.DOSIJE D1
        WHERE D1.DATDIPLOMIRANJA IS NOT NULL
    ) OR D.DATDIPLOMIRANJA IS NULL;

-- Varijanta sa ANY

SELECT  *
FROM    DA.DOSIJE D
WHERE   DATDIPLOMIRANJA > ANY (
        SELECT  D1.DATDIPLOMIRANJA
        FROM    DA.DOSIJE D1
        WHERE   D1.DATDIPLOMIRANJA IS NOT NULL
    ) OR D.DATDIPLOMIRANJA IS NULL;

-- Varijanta sa EXISTS

SELECT  *
FROM    DA.DOSIJE D
WHERE   EXISTS (
    SELECT  *
    FROM    DA.DOSIJE D1
    WHERE   D1.DATDIPLOMIRANJA < D.DATDIPLOMIRANJA
) OR DATDIPLOMIRANJA IS NULL;

-- 12. Izdvojiti podatke o predmetima koje su upisali neki studenti.

-- Varijanta sa SOME

SELECT  *
FROM    DA.PREDMET P
WHERE   P.ID = SOME (
        SELECT  UK.IDPREDMETA
        FROM    DA.UPISANKURS UK
    )

-- Varijanta sa ANY

SELECT  *
FROM    DA.PREDMET P
WHERE   P.ID = ANY (
        SELECT  UK.IDPREDMETA
        FROM    DA.UPISANKURS UK
    )

-- 13. Za studente koji su polagali ispit u ispitnom roku odrzanom
-- u 2018/2019. sk. godini izdvojiti podatke o polozenim ispitima.
-- Izdvojiti indeks, ime, prezime studenta, naziv polozenog predmeta,
-- oznaku ispitnog roka i skolsku godinu u kojoj je ispit polozen.

-- Prvo izdvajamo podatke o studentima koji su polagali ispit
-- u ispitnom roku 2018/2019

-- Nakon toga dodajemo informacije o polozenim ispitima

SELECT  *
FROM    DA.DOSIJE D
        JOIN DA.ISPIT I on D.INDEKS = I.INDEKS
        JOIN DA.PREDMET P on I.IDPREDMETA = P.ID
WHERE I.STATUS = 'o'
    AND I.OCENA > 5
    AND EXISTS (
        SELECT  *
        FROM    DA.ISPIT I
        WHERE   I.INDEKS = D.INDEKS
            AND I.SKGODINA = 2018
            AND I.STATUS NOT IN ('p', 'n')
    );

-- 14. Izdvojiti podatke o predmetima koje su polagali svi studenti
-- iz Berana koji studiraju smer sa oznakom I.

SELECT  *
FROM    DA.PREDMET P
WHERE   NOT EXISTS (
    SELECT  *
    FROM    DA.DOSIJE D
        JOIN DA.STUDIJSKIPROGRAM SP ON (D.IDPROGRAMA = SP.ID)
    WHERE   D.MESTORODJENJA = 'Berane'
        AND SP.OZNAKA = 'I'
        AND NOT EXISTS (
            SELECT  *
            FROM    DA.ISPIT I
            WHERE   I.INDEKS = D.INDEKS
                AND I.IDPREDMETA = P.ID
                AND I.STATUS NOT IN ('p', 'n')
        )
);