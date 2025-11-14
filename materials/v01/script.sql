-- 1. Izdvojiti podatke o svim predmetima.
SELECT	*
FROM	DA.PREDMET;

-- 2. Izdvojiti podatke o svim studentima rodjenim u Beogradu.
SELECT	*
FROM	DA.DOSIJE
WHERE	MESTORODJENJA = 'Beograd';

-- 3. Izdvojiti podatke o svim studentima koji nisu rodjeni u Beogradu.
SELECT	*
FROM	DA.DOSIJE
WHERE	MESTORODJENJA <> 'Beograd';

-- 4. Izdvojiti podatke o svim studentima koji su rodjeni u Beogradu ili Zrenjaninu.
SELECT	*
FROM	DA.DOSIJE
WHERE	MESTORODJENJA = 'Beograd' OR
		MESTORODJENJA = 'Zrenjanin';  -- Alternativno: MESTORODJENJA IN ('Beograd', 'Zrenjanin')

-- 5. Izdvojiti podatke o svim studentkinjama rodjenim u Beogradu.
SELECT	*
FROM	DA.DOSIJE
WHERE	POL = 'z' AND
		MESTORODJENJA = 'Beograd';
		
-- 6. Izdvojiti nazive mesta u kojima su rodjeni studenti.
SELECT	DISTINCT MESTORODJENJA
FROM	DA.DOSIJE;

-- 7. Izdvojiti nazive predmeta koji imaju vise od 6 ESPB.
SELECT	NAZIV, ESPB
FROM	DA.PREDMET
WHERE	ESPB > 6;

-- 8. Izdvojiti oznake i nazive predmeta koji imaju izmedju 8 i 15 ESPB.
SELECT	OZNAKA, NAZIV
FROM	DA.PREDMET
WHERE	ESPB BETWEEN 8 AND 15;

-- 9. Izdvojiti podatke o ispitnim rokovima odrzanim u 2015/2016, 2016/2017. ili 2018/2019. skolskoj godini.
SELECT	*
FROM	DA.ISPITNIROK
WHERE	SKGODINA IN (2015, 2016, 2017);

-- 10. Izdvojiti podatke o ispitnim rokovima koji nisu odrzani u 2015/2016, 2016/2017. ili 2018/2019. skolskoj godini.
SELECT	*
FROM	DA.ISPITNIROK
WHERE	SKGODINA NOT IN (2015, 2016, 2017);

/*
11. Izdvojiti podatke o studentima koji su fakultet upisali 2015. godine,
pod pretpostavkom da godina iz indeksa odgovara godini upisa na fakultet.
*/
SELECT	*
FROM	DA.DOSIJE
WHERE	INDEKS / 10000 = 2015;

-- 12. Izdvojiti nazive predmeta i njihovu cenu za samofinansirajuce studente izrazenu u dinarima. Jedan ESPB kosta 2000 dinara.
SELECT	NAZIV, ESPB * 2000 AS "Cena upisa"
FROM	DA.PREDMET;

-- 13. U prethodnom upitu izdvojiti samo redove sa cenom bodova vecom od 10000.
SELECT	NAZIV, ESPB * 2000 AS "Cena upisa"
FROM	DA.PREDMET
WHERE	ESPB * 2000 > 10000; -- Zbog redosleda izvrsavanja klauzula u upitu, nismo mogli da napisemo WHERE "Cena upisa" > 10000

/*
Redosled:
1 - FROM
2 - WHERE
3 - SELECT
*/

/*
14. Izdvojiti nazive predmeta i njihovu cenu za samofinansirajuce studente
izrazenu u dinarima. Jedan ESPB kosta 2000 dinara. Izmedju kolone naziv i kolone
cena dodati kolonu u kojoj ce za svaku vrsti biti ispisano Cena u dinarima.
*/
SELECT	NAZIV, 'Cena u dinarima' AS OPIS, ESPB * 2000 AS "Cena upisa"
FROM	DA.PREDMET;

-- 15. Izdvojiti podatke o studentima koji su rodjeni u mestu ciji naziv sadrzi malo slovo o kao drugo slovo.
SELECT	*
FROM	DA.DOSIJE
WHERE	MESTORODJENJA LIKE '_o%';

-- 16. Izdvojiti podatke o studentima koji su rodjeni u mestu ciji naziv sadrzi malo slovo o.
SELECT	*
FROM	DA.DOSIJE
WHERE	MESTORODJENJA LIKE '%o%';

-- 17. Izdvojiti podatke o studentima koji su rodjeni u mestu ciji naziv se zavrsava sa malo e.
SELECT	*
FROM	DA.DOSIJE
WHERE	MESTORODJENJA LIKE '%e';

-- 18. Izdvojiti podatke o studentima koji su rodjeni u mestu ciji naziv pocinje sa N a zavrsava se sa d.
SELECT	*
FROM	DA.DOSIJE
WHERE	MESTORODJENJA LIKE 'N%d';

-- 19. Napraviti masku koja bi mogla da prepozna naredni string "%x_".
SELECT	*
FROM	DA.DOSIJE
WHERE	'%x_' LIKE '/%x/_' ESCAPE '/';

-- 20. Izdvojiti podatke o predmetima. Rezultat urediti po ESPB u rastucem poretku.
SELECT	*
FROM	DA.PREDMET
ORDER BY ESPB ASC; -- ASC je podrazumevano prilikom upotrebe ORDER BY klauzule, te je u ovom slucaju moglo i biti izostavljeno

-- 21. Izdvojiti podatke o predmetima. Rezultat urediti po ESPB u opadajucem poretku.
SELECT	*
FROM	DA.PREDMET
ORDER BY ESPB DESC;

-- 22. Izdvojiti podatke o predmetima. Rezultat urediti po ESPB u rastucem poretku i po nazivu u opadajucem poretku.
SELECT	*
FROM	DA.PREDMET
ORDER BY ESPB ASC, NAZIV DESC;

/*
23. Izdvojiti ime, prezime i datum upisa na fakultet za studente koji su fakultet upisali
izmedju 10. jula 2017. i 15.9.2017. godine. Rezultat urediti prema prezimenu studenta.
*/
SELECT	IME, PREZIME, DATUPISA
FROM	DA.DOSIJE
WHERE	DATUPISA BETWEEN '10.07.2017' AND '15.09.2017'
ORDER BY PREZIME;

/*
24. Izdvojiti podatke o studijskim programima cija je predvidjena duzina studiranja 3 ili vise godina.
Izdvojiti oznaku i naziv studijskog programa i broj godina predvidjenih za studiranje studijskog
programa. Rezultat urediti prema predvidjenom broju godina za studiranje i nazivu studijskog programa.
*/
SELECT	OZNAKA, NAZIV, OBIMESPB / 60 AS "Predvidjeno godina"
FROM	DA.STUDIJSKIPROGRAM
WHERE	OBIMESPB / 60 >= 3
ORDER BY "Predvidjeno godina", NAZIV; -- U ORDER BY mozemo koristiti alijas zadat u okviru SELECT klauzule

/*
Redosled:
1 - FROM
2 - WHERE
3 - SELECT
4 - ORDER BY
*/

-- 25. Izdvojiti podatke o studentima za koje nije poznato mesto rodjenja.
SELECT	*
FROM	DA.STUDENT
WHERE	MESTORODJENJA IS NULL; -- Hint: U bazi nema takvih studenata!

-- 26. Prikazati, u jednom redu i tri kolone, trenutni datum, trenutno vreme, i trenutni datum sa preciznim vremenom.
VALUES	(CURRENT_DATE, CURRENT_TIME, CURRENT_TIMESTAMP);

-- 27. Prikazati, u tri reda i tri kolone, prirodne brojeve od 1 do 9.
VALUES	(1, 2, 3), (4, 5, 6), (7, 8, 9);
