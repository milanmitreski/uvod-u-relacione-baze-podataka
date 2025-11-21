-- 1. Izdvojiti podatke o svim studentima koji nisu diplomirali
SELECT *
FROM DA.DOSIJE
WHERE DATDIPLOMIRANJA IS NULL;

-- 2. Izdvojiti podatke o svim studentima koji su diplomirali
SELECT *
FROM DA.DOSIJE
WHERE DATDIPLOMIRANJA IS NOT NULL;

-- 3. Prikaziti podatke o studentima i ispitma
SELECT *
FROM DA.DOSIJE, DA.ISPIT;

-- 4. Prikazati podatke o studentima i njihovim ispitima
SELECT *
FROM DA.DOSIJE, DA.ISPIT
WHERE DA.ISPIT.INDEKS = DA.DOSIJE.INDEKS;

SELECT *
FROM DA.DOSIJE D JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS;

-- 5. Prikazati podatke o studentima i njihovim ispitima koji su
-- odrzani 28.01.2016. Izdvojiti indeks, ime i prezime studenta,
-- idpredmeta i ocenu.

SELECT D.INDEKS /* I.INDEKS */, D.IME, D.PREZIME, I.IDPREDMETA, I.OCENA
FROM DA.DOSIJE D JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS
WHERE I.DATPOLAGANJA = '2016-01-28';

-- 6. Izdvojiti podatke o polozenim ispitima. Prikazati indeks, ime i
-- prezime studenta koji je polozio ispit, naziv polozenog preddmeat i
-- ocenu

SELECT D.INDEKS, D.IME, D.PREZIME, P.NAZIV, I.OCENA
FROM DA.ISPIT I JOIN DA.DOSIJE D ON I.INDEKS = D.INDEKS
                JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID
WHERE STATUS = 'o' AND OCENA > 5;

-- 7. Izdvojiti podatke o studentima za koje vazi da su diplomirali
-- dana kada je odrzan neki ispit

SELECT DISTINCT D.*
FROM DA.DOSIJE D JOIN DA.ISPIT I ON D.DATDIPLOMIRANJA = I.DATPOLAGANJA;

-- 8. Izdvojiti parove predmeta koji imaju isti broj espb bodova. Izdvojit
-- oznake predmeta i broj espb bodova

SELECT *
FROM DA.PREDMET P1 JOIN DA.PREDMET P2 ON P1.ESPB = P2.ESPB
                                        AND P1.ID < P2.ID;

-- 9. Izdvojiti indeks, ime i prezime studenata cije prezime sadrzi
-- malo slovo na 4. poziciji i zavrsava se na malo slovo c i koji su
-- predmet ciji je broj espb bodova izmedju 2 i 10 polozili sa ocenom 6, 8
-- ili 10 izmedju 5. januara 2018 i 15. decembra 2018. Rezultat urediti
-- prema prezimenu u rastucem poretku i imenu u opadajucem poretku.

SELECT DISTINCT D.INDEKS, D.IME, D.PREZIME
FROM DA.DOSIJE D JOIN DA.ISPIT I ON D.INDEKS = I.INDEKS
                JOIN DA.PREDMET P ON I.IDPREDMETA = P.ID
WHERE D.PREZIME LIKE '___a%c'
    AND I.STATUS = 'o'
    AND I.OCENA IN (6, 8, 10)
    AND I.DATPOLAGANJA BETWEEN '2018-01-05' AND '2018-12-15'
    AND P.ESPB BETWEEN 2 AND 10
ORDER BY D.PREZIME ASC, D.IME DESC;

-- 10. Za svaki predmet koji moze da se slusa na nekom studijskom programu
-- izdvojiti uslovne predmete tog predmeta. Izdvojiti identifikator
-- studijskog programa, identifikator predmeta, vrstu tog predmeta
-- (obavezni ili izborni) na studijskom programu i identifikator
-- uslovnog predmeta. Izdvojiti i predmete koji nemaju uslovne predmete

SELECT PP.IDPROGRAMA, PP.IDPREDMETA, PP.VRSTA, UP.IDUSLOVNOGPREDMETA
FROM DA.PREDMETPROGRAMA PP LEFT JOIN DA.USLOVNIPREDMET UP
                            ON PP.IDPROGRAMA = UP.IDPROGRAMA
                                AND PP.IDPREDMETA = UP.IDPREDMETA;

-- 11. U prethodnom zadatku pored identifikatora predmeta dodati
-- njihove naziv

SELECT PP.IDPROGRAMA, PP.IDPREDMETA, P1.NAZIV,
        PP.VRSTA, UP.IDUSLOVNOGPREDMETA, P2.NAZIV
FROM DA.PREDMETPROGRAMA PP LEFT JOIN DA.USLOVNIPREDMET UP
                            ON PP.IDPROGRAMA = UP.IDPROGRAMA
                                AND PP.IDPREDMETA = UP.IDPREDMETA
                            JOIN DA.PREDMET P1 ON (PP.IDPREDMETA = P1.ID)
                            LEFT JOIN DA.PREDMET P2 ON (UP.IDUSLOVNOGPREDMETA = P2.ID)

-- 13. Izdvojiti parove student-ispitni rok za koje vazi da je student
-- diplomirao poslednjeg dana roka. Izdvojiti indeks, ime, prezime,
-- datum diplomiranja studenta, naziv ispitnog roka i datum kraja ispitnog
-- roka. Prikazati i studente i ispitne rokove koji nemaju odgovarajuceg
-- para

SELECT D.INDEKS, D.IME, D.PREZIME, D.DATDIPLOMIRANJA, IR.NAZIV, IR.DATKRAJA
FROM DA.DOSIJE D FULL JOIN DA.ISPITNIROK IR ON D.DATDIPLOMIRANJA = IR.DATKRAJA