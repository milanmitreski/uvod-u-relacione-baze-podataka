-- 1. Izdvojiti podatke o svim predmetima

-- 3 SELECT (projekcija) -- OBAVEZAN -- prikazuje zeljene podatke odnosno atribute
-- 1 FROM -- OBAVEZAN -- izvlaci podatke iz tabele
-- 2 WHERE (restrikcija) -- NIJE OBAVEZAN -- filtrira redove na osnovu datog uslova

-- SELECT -> listu kolona ili * (oznacava sve redove tabele)
-- FROM -> ocekuje tabelu
-- WHERE -> ocekuje logicki uslov

SELECT *
FROM DA.PREDMET;

-- 2. Izdvojiti podatke o svim studentima rodjenim u Beogradu

SELECT *
FROM DA.DOSIJE
WHERE MESTORODJENJA = 'Beograd';

-- 3. Izdvojiti podatke o svim studentima koji nisu rodjeni u Beogradu

SELECT *
FROM DA.DOSIJE
WHERE MESTORODJENJA <> 'Beograd';

-- 4. Izdvojiti podatke o svim studentima koji su rodjeni u Beogradu ili Zrenjaninu

SELECT *
FROM DA.DOSIJE
WHERE MESTORODJENJA = 'Beograd'
    OR MESTORODJENJA =  'Zrenjanin';

-- 5. Izdvojiti podatke o svim studentkinjama rodjenim u Beogradu

SELECT *
FROM DA.DOSIJE
WHERE POL = 'z'
    AND MESTORODJENJA = 'Beograd';

-- 6. Izdvojiti nazive mesta u kojima su rodjeni studenti.

SELECT DISTINCT MESTORODJENJA
FROM DA.DOSIJE;

-- 7. Izdvojiti nazive predmeta koji imaju vise od 6 ESPB

SELECT NAZIV
FROM DA.PREDMET
WHERE ESPB > 6;

-- 8. Izdvojiti oznake i nazive predmeta koji imaju izmedju 8 i 15 ESPB

SELECT OZNAKA, NAZIV
FROM DA.PREDMET
WHERE ESPB BETWEEN 8 AND 15;

-- 9. Izdvojiti podatke o ispitnim rokovima odrzanim u 2015/2016,
-- 2016/2017 ili 2018/2019 skolskoj godini

SELECT *
FROM DA.ISPITNIROK
WHERE SKGODINA IN (2015, 2016, 2018);

-- 10. Izdvojiti podatke o ispitnim rokovima koji nisu odrzani u 2015/2016,
-- -- 2016/2017 ili 2018/2019 skolskoj godini

SELECT *
FROM DA.ISPITNIROK
WHERE SKGODINA NOT IN (2015, 2016, 2018);

-- 11. Izdvojiti podatke o studentima koji su fakultet upisali 2015. godine,
-- pod pretpostavkom da godina iz indeksa odgovara godini upisa na fakultet

SELECT *
FROM DA.DOSIJE
WHERE INDEKS / 10000 = 2015;

-- 12. Izdvojiti nazive predmeta i njihovu cenu za samofinansirajuce studente
-- izrazenu u dinarima. Jedan ESPB kosta 2000 dinara

SELECT NAZIV, ESPB * 2000 AS "CENA UPISA"
FROM DA.PREDMET;

-- 13. U prethodnom upitu izdvojiti samo redove sa cenom bodova vecom od 10000

SELECT NAZIV, ESPB * 2000 AS CENA_UPISA
FROM DA.PREDMET
WHERE ESPB * 2000 > 10000;

-- 14. Izdvojiti nazive predmeta i njihovu cenu za samofinansirajuce studente
-- izrazenu u dinarima. Jedan ESPB kosta 2000 dinara. Izmedju kolone naizv i
-- kolone cena dodati kolonu u kojoj ce za svaku vrstu biti ispisano 'Cena u dinarima'.

SELECT NAZIV, 'Cena u dinarima' AS OPIS, ESPB * 2000 AS "CENA UPISA"
FROM DA.PREDMET;

-- 15. Izdvojiti podatke o studentima koji su rodjeni u mestu ciji naziv sadrzi malo slovo o
-- kao drugo slovo

SELECT *
FROM DA.DOSIJE
WHERE MESTORODJENJA LIKE '_o%'; -- U LIKE se moze koristii _ koja predstavlja 1 karakter
                                --                         % koji predstavlja 0 ili vise karaktera

-- 19. Napraviti masku koja bi mogla da prepozna string %x_

SELECT *
FROM DA.PREDMET
WHERE '%x_' LIKE '/%x/_' ESCAPE '/';

-- 22. Izdvojiti podatke o predmetima. Rezultat urediti po ESPB u rastucem poretku i po nazivu u
-- u opadajucem poretku

-- 3 SELECT
-- 1 FROM
-- 2 WHERE
-- 4 ORDER BY

SELECT *
FROM DA.PREDMET
ORDER BY ESPB, NAZIV DESC;
