-- 1. Izdvojiti podatke o studentima ciji je datum diplomiranja nepoznat.
SELECT	*
FROM	DA.DOSIJE
WHERE	DATDIPLOMIRANJA IS NULL;

-- 2. Izdvojiti podatke o studentima ciji datum diplomiranja nije nepoznat.
SELECT	*
FROM	DA.DOSIJE
WHERE	DATDIPLOMIRANJA IS NOT NULL;

-- 3. Prikazati podatke o studentima i ispitima.
SELECT	*
FROM	DA.DOSIJE, DA.ISPIT;

-- 4. Prikazati podatke o studentima i njihovim ispitima.
SELECT	*
FROM	DA.DOSIJE, DA.ISPIT
WHERE	DA.DOSIJE.INDEKS = DA.ISPIT.INDEKS;

SELECT	*
FROM	DA.DOSIJE JOIN
		DA.ISPIT ON DA.DOSIJE.INDEKS = DA.ISPIT.INDEKS;

SELECT	*
FROM	DA.DOSIJE AS D JOIN
		DA.ISPIT AS I ON D.INDEKS = I.INDEKS;
		
-- 5. Prikazati podatke o studentima i njihovim ispitima koji su odrzani 28.1.2016. Izdvojiti indeks, ime i prezime studenta, id predmeta i ocenu.
SELECT	D.INDEKS, D.IME, D.PREZIME, I.IDPREDMETA, I.OCENA
FROM	DA.DOSIJE AS D JOIN
		DA.ISPIT AS I ON D.INDEKS = I.INDEKS
WHERE	DATPOLAGANJA = '28.01.2016';

-- 6. Izdvojiti podatke o polozenim ispitima. Prikazati indeks, ime i prezime studenta koji je polozio ispit, naziv polozenog predmeta i ocenu.
SELECT	D.INDEKS, D.IME, D.PREZIME, P.NAZIV, I.OCENA
FROM	DA.ISPIT AS I JOIN
		DA.DOSIJE AS D ON I.INDEKS = D.INDEKS JOIN
		DA.PREDMET AS P ON I.IDPREDMETA = P.ID
WHERE	I.STATUS = 'o' AND I.OCENA > 5;

-- 7. Izdvojiti podatke o studentima za koje vazi da su diplomirali dana kada je odrzan neki ispit.
SELECT	DISTINCT D.*
FROM	DA.ISPIT AS I JOIN
		DA.DOSIJE AS D ON I.DATPOLAGANJA = D.DATDIPLOMIRANJA;
		
-- 8. Izdvojiti parove predmeta koji imaju isti broj espb bodova. Izdvojiti oznake predmeta i broj espb bodova.
SELECT	P1.OZNAKA AS "OZNAKA 1", P2.OZNAKA AS "OZNAKA 2", P1.ESPB
FROM	DA.PREDMET AS P1 JOIN
		DA.PREDMET AS P2 ON P1.ESPB = P2.ESPB
WHERE	P1.ID < P2.ID;

/*
9. Izdvojiti indeks, ime i prezime studenata cije prezime sadrzi malo slovo a na 4. poziciji
i zavrsava na malo slovo c i koji su predmet ciji je broj espb bodova izmedju 2 i 10 polozili
sa ocenom 6, 8 ili 10 izmedju 5. januara 2018. i 15. decembra 2018. Rezultat urediti prema
prezimenu u rastucem poretku i imenu u opadajucem poretku. 
*/
SELECT	DISTINCT D.INDEKS, D.IME, D.PREZIME
FROM	DA.DOSIJE AS D JOIN
		DA.ISPIT AS I ON D.INDEKS = I.INDEKS JOIN
		DA.PREDMET AS P ON I.IDPREDMETA = P.ID
WHERE	D.PREZIME LIKE '___a%c' AND
		I.STATUS = 'o' AND
		I.OCENA IN (6, 8, 10) AND
		I.DATPOLAGANJA BETWEEN '05.01.2018' AND '15.12.2018' AND
		P.ESPB BETWEEN 2 AND 10
ORDER BY D.PREZIME ASC, D.IME DESC;

/*
10. Za svaki predmet koji moze da se slusa na nekom studijskom programu izdvojiti uslovne predmete
tog predmeta. Izdvojiti identifikator studijskog programa, identifikator predmeta, 
vrstu tog predmeta (obavezan ili izborni) na studijskom programu i identifikator uslovnog predmeta. 
Izdvojiti i predmete koji nemaju uslovne predmete.
*/
SELECT	PP.IDPROGRAMA, PP.IDPREDMETA, PP.VRSTA, UP.IDUSLOVNOGPREDMETA
FROM	DA.USLOVNIPREDMET AS UP RIGHT JOIN
		DA.PREDMETPROGRAMA AS PP ON UP.IDPROGRAMA = PP.IDPROGRAMA AND
									UP.IDPREDMETA = PP.IDPREDMETA;

-- 11. U prethodnom zadatku pored identifikatora predmeta dodati njihove nazive.
SELECT	PP.IDPROGRAMA, PP.IDPREDMETA, P1.NAZIV, PP.VRSTA, UP.IDUSLOVNOGPREDMETA, P2.NAZIV
FROM	DA.USLOVNIPREDMET AS UP RIGHT JOIN
		DA.PREDMETPROGRAMA AS PP ON UP.IDPROGRAMA = PP.IDPROGRAMA AND
									UP.IDPREDMETA = PP.IDPREDMETA JOIN
		DA.PREDMET AS P1 ON PP.IDPREDMETA = P1.ID LEFT JOIN
		DA.PREDMET AS P2 ON UP.IDUSLOVNOGPREDMETA = P2.ID;

-- 12. Izdvojiti parove naziva razlicitih ispitnih rokova u kojima je isti student polagao isti predmet.
SELECT	IR1.NAZIV, IR2.NAZIV
FROM	DA.ISPIT AS I1 JOIN
		DA.ISPIT AS I2 ON I1.INDEKS = I2.INDEKS AND
						  I1.IDPREDMETA = I2.IDPREDMETA JOIN
		DA.ISPITNIROK AS IR1 ON (IR1.SKGODINA, IR1.OZNAKAROKA) = (I1.SKGODINA, I1.OZNAKAROKA) JOIN
		DA.ISPITNIROK AS IR2 ON (IR2.SKGODINA, IR2.OZNAKAROKA) = (I2.SKGODINA, I2.OZNAKAROKA)
WHERE	I1.DATPOLAGANJA < I2.DATPOLAGANJA AND
		I1.STATUS NOT IN ('p', 'n') AND
		I2.STATUS NOT IN ('p', 'n');
		
/*
13. Izdvojiti parove student-ispitni rok za koje vazi da je student diplomirao poslednjeg dana roka. 
Izdvojiti indeks, ime, prezime, datum diplomiranja studenta, naziv ispitnog roka i datum kraja ispitnog 
roka. Prikazati i studente i ispitne rokove koji nemaju odgovarajuceg para.
*/
SELECT	D.INDEKS, D.IME, D.PREZIME, D.DATDIPLOMIRANJA,
		IR.NAZIV, IR.DATKRAJA
FROM	DA.DOSIJE AS D FULL JOIN
		DA.ISPITNIROK AS IR ON D.DATDIPLOMIRANJA = IR.DATKRAJA;

/*
14. Za svaki ispitni rok izdvojiti ocene sa kojima su studenti polozili ispite u tom roku. 
Izdvojiti naziv ispitnog roka i ocene. Izdvojiti i ispitne rokove u kojima nije polozen nijedan ispit. 
Rezultat urediti prema nazivu ispitnog roka u rastucem poretku i prema oceni u opadajucem poretku.
*/
SELECT	DISTINCT IR.NAZIV, I.OCENA
FROM	DA.ISPITNIROK AS IR LEFT JOIN
		DA.ISPIT AS I ON (I.SKGODINA, I.OZNAKAROKA) = (IR.SKGODINA, IR.OZNAKAROKA) AND
						 I.STATUS = 'o' AND I.OCENA > 5
ORDER BY IR.NAZIV ASC, I.OCENA DESC;

/*
15. Za svakog studenta koji u imenu sadrzi nisku ark izdvojiti podatke o polozenim ispitima. 
Izdvojiti indeks, ime i prezime studenta, naziv polozenog predmeta i dobijenu ocenu. 
Izdvojiti podatke i o studentu koji nema nijedan polozen ispit. Rezultat urediti prema indeksu.
*/
SELECT	D.INDEKS, D.IME, D.PREZIME,
		P.NAZIV,
		I.OCENA
FROM	DA.DOSIJE AS D LEFT JOIN
		DA.ISPIT AS I ON D.INDEKS = I.INDEKS AND I.STATUS = 'o' AND I.OCENA > 5 LEFT JOIN
		DA.PREDMET AS P ON I.IDPREDMETA = P.ID
WHERE	D.IME LIKE '%ark%'
ORDER BY D.INDEKS;
