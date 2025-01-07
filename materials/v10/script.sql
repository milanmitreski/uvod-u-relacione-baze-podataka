/*
	Uvod u relacione baze podataka - cas 10
	MERGE naredba. Okidaci (TRIGGER).
*/

/*
	** MERGE naredba **
	
	Sintaksa:
	
	MERGE INTO IME_TABELE
	USING (NEKI_UPIT)
	ON USLOV_POKLAPANJA
	WHEN MATCHED THEN
		...
	WHEN MATCHED AND ... THEN
		...
	WHEN NOT MATCHED THEN
		...
	WHEN NOT MATCHED AND ... THEN
		... 
		
	TABELA
	
	|	A	|	B	|	C	| (A,B je PK)
	-------------------------
		a		1		2
		a		2		2
		b		1		4
		
	NOVI PODACI
	
	|	A	|	B	|	C	| (A,B je PK)
	-------------------------
		a		1		3
		a		3		4
		
	USLOV_POKLAPANJA -> poklapaju se vrednosti u kolonama A i B
			
	MERGE naredba se u SQL koristi za azuriranje tabele (IME_TABELE) 
	na osnovu novih podataka (iz upita NEKI_UPIT) na sledeci nacin:
		- prolazimo kroz nove podatke (tj. kroz redove tabele dobijene
		  izvrsavajem upita NEKI_UPIT) i na osnovu uslova USLOV_POKLAPANJA
		  pokusavamo da nadjemo da li informaciju o tom redu vec imamo u
		  tabeli IME_TABELE (jasnije ce biti na primeru)
		- ako poklopimo redove iz te dve tabele, izvrsavamo naredbu koja 
		  sledi nakon WHEN MATCHED THEN (mozemo dodavati i dodatne uslove,
		  pa se ovakva klauza moze vise puta ponavljati)
		- ako ne poklopimo red iz izvorisne tabele sa redom iz IME_TABELE,
		  tada izvrsavamo naredbu koja sledi nakon WHEN NOT MATCHED THEN
		  i kao u prvom slucaju, mozemo dodavati dodatne uslove, pa se ovakve
		  klauze mogu ponavljati vise puta u okviru jedne MERGE naredbe
*/

/*
	** OKIDACI **
	
	Sintaksa:
	
	CREATE TRIGGER NAZIV_TRIGERA
	[BEFORE|AFTER] [INSERT|UPDATE|DELETE]
	ON NAZIV_TABELE
	REFERENCING
		[OLD AS STARI]
		[NEW AS NOVI]
	FOR EACH [ROW|STATEMENT]
	[WHEN (USLOV_KOJI_ISPUNJAVAJU_REDOVI_NA_KOJE_CE_SE_PRIMENITI_TRIGGER)]
	BEGIN ATOMIC
		... ;
		... ;
		... ;
	END @ 
	
	Okidaci su objekti u okviru date baze podataka pomocu kojih se pre ili posle
	izvrsavanja naredbi INSERT, UPDATE ili DELETE mogu definisati niz naredbi
	koje treba izvrsiti. Razlikujemo BEFORE (okidanje se izvrsava pre izvrsavanja
	same naredbe) i AFTER (okidanje se izvrsava nakon izvrsavanja same naredbe )
	okidace.
	
		- BEFORE okidace koristimo za:
			1. Sprecavanje INSERT/UPDATE/DELETE pomocu SIGNAL naredbe
				SIGNAL SQLSTATE '75000' 
					('Poruka o grešci koja će se ispisati korisniku.')
			2. Izmena vrednosti koja se ubacuje/menja.
		- AFTER okidace koristimo za:
			1. Azuriranje drugih tabela na osnovu novog stanja
			   tabele nad kojom je definisan okidac
			   
	Napomena: treba paziti da telo okidaca ne okine isti okidac ponovo.
	
	Za pristup vrednostima koje se nalaze u tabeli pre izvrsavanje naredbe
	(ovo moze samo u BEFORE okidacu) ili vrednostima koje se nalaze u tabeli
	nakon izvrsavanja naredbe koristimo NEW/OLD vrednosti.
		
		- OLD vrednost referencira red koji se nalazi u tabeli pre izvrsavanja
		  naredbe i on se moze referencirati iskljucivo u BEFORE okidacu.
		- NEW vrednost referencira red koji ce se naci u tabeli nakon izvrsavanja
		  naredbe i on se moze referencirati u proizvoljnom okidacu.
		  
	Takodje treba imati na umu kada uopste postoje OLD/NEW vrednosti:
	
		- OLD vrednost ne postoji pri naredbi INSERT
			-> unosimo red u tabelu, on ne postoji pre toga
		- NEW vrednost ne postoji pri naredbi DELETE
			-> brisemo red iz tabele, nece ostati nakon DELETE naredbe
			
	TEHNICKA NAPOMENA: Kada radimo sa triggerima u većini slučajva ćemo imati 
	više naredbi u telu i te naredbe treba razdvojiti sa ";". Ali ako ";" 
	iskoistimo unutar kreiranja triggera (koji je jedna komanda), onda ne možemo 
	to iskoristiti za kraj naredbe. Zbog toga uvodimo novi terminator, tipično @.
	
	Komanda: "--#SET TERMINATOR @" (u okviru DS)
			 db2 -td@ -f putanja_do_fajla (u terminalu)
	
	Svi okidaci mogu se videti u tabeli SYSCAT.TRIGGERS
	
	NOVA NAREDBA: IF statement (razlicit od CASE naredbe)
		CASE naredba -> vraca razlicite vrednosti na osnovu nekih uslova
		IF statement -> proceduralna naredba kojom se vrsi grananje
			IF statement je deo SQL PL (procedure language)
*/

-- 1. Napisati naredbu na SQL-u koja:
-- 	- pravi tabelu predmet_student koja čuva podatke koliko studenata je 
--	  položilo koji predmet. Tabela ima kolone: idpredmeta (tipa integer) 
--    i student (tipa smallint).
-- 	- unosi u tabelu predmet_student podatke o obaveznim predmetima na smeru 
--    Informatika na osnovnim akademskim studijama (može se uzeti da je id 103). 
--    Za svaki predmet uneti podatak da ga je položilo 5 studenata.
-- 	- ažurira tabelu predmet_student, tako što predmetima o kojima postoji 
--    evidencija ažurira broj studenata koji su ga položili, a za predmete o 
--    kojima ne postoji evidencija unosi podatke.

DROP TABLE IF EXISTS PREDMET_STUDENT;

CREATE TABLE IF NOT EXISTS PREDMET_STUDENT (
	IDPREDMETA	INTEGER NOT NULL PRIMARY KEY,
	STUDENT		SMALLINT
);

SELECT * FROM PREDMET_STUDENT;

INSERT INTO PREDMET_STUDENT
SELECT IDPREDMETA, 5
FROM DA.PREDMETPROGRAMA
WHERE IDPROGRAMA = 103 AND VRSTA = 'obavezan';

SELECT * FROM PREDMET_STUDENT;

MERGE INTO PREDMET_STUDENT AS PS
USING (
	SELECT IDPREDMETA, COUNT(*) AS BR
	FROM DA.ISPIT I
	WHERE I.OCENA > 5 AND I.STATUS = 'o'
	GROUP BY IDPREDMETA
) AS P
ON PS.IDPREDMETA = P.IDPREDMETA
WHEN MATCHED THEN
	UPDATE SET PS.STUDENT = P.BR
WHEN NOT MATCHED THEN
	INSERT VALUES (IDPREDMETA, BR);
	
SELECT * FROM PREDMET_STUDENT;
	

-- 2. Napisati naredbu na SQL-u koja:
--  - pravi tabelu student_podaci sa kolonama: indeks (tipa integer), 
--    broj _predmeta (tipa smallint), prosek (tipa float) i datupisa (tipa date);
--  - u tabelu student_podaci unosi indeks, broj položenih predmeta i prosek 
--    za studente koji imaju prosek iznad 8 i nisu diplomirali; za studente 
--    koji su diplomirali kao broj predmeta uneti vrednost 10, a kao prosek 
--    vrednost 10;
--  - ažurira tabelu student_podaci tako što studentima o kojima u tabeli postoje 
--    podaci i koji su:
--      * diplomirali ažurira datum upisa na fakultet
--      * trenutno na budžetu ažurira broj položenih predmeta i prosek;
--      * studente koji su ispisani briše iz tabele;
--      * unosi podatke o studentima koji nisu ispisani i o njima ne postoje 
--        podaci u tabeli student_podaci; uneti indeks, broj položenih predmeta 
--        i prosek;
--  - uklanja tabelu student_podaci.

DROP TABLE IF EXISTS STUDENT_PODACI;

CREATE TABLE IF NOT EXISTS STUDENT_PODACI (
	INDEKS			INTEGER NOT NULL PRIMARY KEY,
	BROJ_PREDMETA	SMALLINT,
	PROSEK			FLOAT,
	DATUPISA 		DATE
);

INSERT INTO STUDENT_PODACI (INDEKS, BROJ_PREDMETA, PROSEK)
SELECT INDEKS, COUNT(*), AVG(OCENA+0.0)
FROM DA.ISPIT I
WHERE I.INDEKS NOT IN (
	SELECT INDEKS
	FROM DA.DOSIJE D JOIN DA.STUDENTSKISTATUS SS
		ON D.IDSTATUSA = SS.ID
	WHERE SS.NAZIV = 'Diplomirao'
) AND I.OCENA > 5 AND I.STATUS = 'o'
GROUP BY INDEKS
HAVING AVG(OCENA+0.0) > 8
UNION
SELECT INDEKS, 10, 10
FROM DA.DOSIJE D JOIN DA.STUDENTSKISTATUS SS
	ON D.IDSTATUSA = SS.ID
WHERE SS.NAZIV = 'Diplomirao';

SELECT * FROM STUDENT_PODACI;

MERGE INTO STUDENT_PODACI SP
USING ( 
	SELECT D.INDEKS, DATUPISA, SS.NAZIV STATUS,
			AVG(OCENA+0.0) PROSEK, COUNT(*) BROJ_PREDMETA
	FROM DA.DOSIJE D JOIN DA.STUDENTSKISTATUS SS
			ON D.IDSTATUSA = SS.ID
					 JOIN DA.ISPIT I
			ON D.INDEKS = I.INDEKS
	WHERE I.OCENA > 5 AND I.STATUS = 'o'
	GROUP BY D.INDEKS, DATUPISA, SS.NAZIV
) AS TMP
ON SP.INDEKS = TMP.INDEKS
WHEN MATCHED AND TMP.STATUS = 'Diplomirao' THEN
	UPDATE SET SP.DATUPISA = TMP.DATUPISA
WHEN MATCHED AND TMP.STATUS = 'Budzet' THEN
	UPDATE SET SP.BROJ_PREDMETA = TMP.BROJ_PREDMETA, 
		SP.PROSEK = TMP.PROSEK
WHEN MATCHED AND LOWER(TMP.STATUS) LIKE '%ispis%' THEN
	DELETE
WHEN NOT MATCHED AND LOWER(TMP.STATUS) NOT LIKE '%ispis%' THEN
	INSERT (INDEKS, BROJ_PREDMETA, PROSEK)
	VALUES (TMP.INDEKS, TMP.BROJ_PREDMETA, TMP.PROSEK);
	
SELECT * FROM STUDENT_PODACI;
			
-- 3. Napraviti okidač koji sprečava brisanje studenata koji su diplomirali. 
-- U tabelu uneti studenta koji je diplomirao i proveriti da li trigger radi. 
-- Na kraju obrisati trigger.

--#SET TERMINATOR @
CREATE TRIGGER BRISANJE_STUDENTA
BEFORE DELETE
ON DA.DOSIJE
REFERENCING 
	OLD AS O
FOR EACH ROW
WHEN (
	O.IDSTATUSA IN (
		SELECT ID
		FROM DA.STUDENTSKISTATUS
		WHERE NAZIV = 'Diplomirao'
	)
)
BEGIN ATOMIC
	SIGNAL SQLSTATE '75000' ('Student je diplomirao, brisanje zabranjeno.');
END @

--#SET TERMINATOR ;
INSERT INTO DA.DOSIJE (INDEKS, IDPROGRAMA, IME, PREZIME, IDSTATUSA, DATUPISA)
VALUES (20220001, 103, 'Marko', 'Petrovic', -2, current date);

DELETE FROM DA.DOSIJE
WHERE INDEKS=20220001;

DROP TRIGGER BRISANJE_STUDENTA;

DELETE FROM DA.DOSIJE
WHERE INDEKS=20220001;

-- 4. Napraviti okidač koji dozvoljava ažuriranje broja espb bodova predmetima 
-- samo za jedan bod. Ako je nova vrednost espb bodova veća od postojeće, 
-- broj bodova se povećava za 1, a ako je manja smajuje se za 1. 

--#SET TERMINATOR @
CREATE TRIGGER BROJ_ESPB
BEFORE UPDATE
ON DA.PREDMET 
REFERENCING
	OLD AS O 
	NEW AS N
FOR EACH ROW
BEGIN ATOMIC
	SET N.ESPB = CASE
		WHEN N.ESPB > O.ESPB THEN O.ESPB + 1
		WHEN N.ESPB < O.ESPB THEN O.ESPB - 1
		ELSE O.ESPB
	END;
END @

--#SET TERMINATOR ;
INSERT INTO DA.PREDMET(ID, OZNAKA, NAZIV, ESPB)
VALUES (5000, 'X', 'X', 4);

UPDATE DA.PREDMET
SET ESPB = 10
WHERE ID = 5000;

SELECT *
FROM DA.PREDMET
WHERE ID = 5000;

UPDATE DA.PREDMET
SET ESPB = 1
WHERE ID = 5000;

SELECT *
FROM DA.PREDMET
WHERE ID = 5000;

DROP TRIGGER BROJ_ESPB;

DELETE
FROM DA.PREDMET
WHERE ID = 5000;

-- 5. 
--  - Napraviti tabelu broj_predmeta koja ima jednu kolonu broj tipa smallint 
--    i u nju uneti jedan entitet koji predstavlja broj predmeta u tabeli predmet.
--  - Napraviti okidač koji ažurira tabelu broj_predmeta tako što povećava 
--    vrednosti u koloni broj za 1 kada se unese novi predmet u tabelu predmet.
--  - Napisati okidač koji ažurira tabelu broj_predmeta tako što smanjuje 
--    vrednost u koloni broj za 1 kada se obriše predmet iz tabele predmet.
--  - Uneti podatke o novom predmetu čiji je id 2002, oznaka predm1, 
--    naziv Predmet 1, i ima 15 espb.

DROP TABLE IF EXISTS BROJ_PREDMETA;

CREATE TABLE IF NOT EXISTS BROJ_PREDMETA (
	BROJ SMALLINT NOT NULL PRIMARY KEY
);

INSERT INTO BROJ_PREDMETA
SELECT COUNT(*)
FROM DA.PREDMET;

SELECT *
FROM BROJ_PREDMETA;

--#SET TERMINATOR @
CREATE TRIGGER PREDMET_UNESEN
AFTER INSERT
ON DA.PREDMET
FOR EACH ROW
BEGIN ATOMIC
	UPDATE BROJ_PREDMETA
	SET BROJ = BROJ + 1;
END @

CREATE TRIGGER PREDMET_OBRISAN
AFTER DELETE
ON DA.PREDMET
FOR EACH ROW
BEGIN ATOMIC
	UPDATE BROJ_PREDMETA
	SET BROJ = BROJ - 1;
END @

--#SET TERMINATOR ;

INSERT INTO DA.PREDMET (ID, OZNAKA, NAZIV, ESPB)
VALUES (2002, 'X', 'X', 15);

SELECT *
FROM BROJ_PREDMETA;

DELETE FROM DA.PREDMET
WHERE ID = 2002;

SELECT *
FROM BROJ_PREDMETA;

DROP TRIGGER PREDMET_UNESEN;
DROP TRIGGER PREDMET_OBRISAN;

--#SET TERMINATOR @
CREATE TRIGGER PROMENA_PREDMETA
AFTER INSERT OR DELETE
ON DA.PREDMET
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		UPDATE BROJ_PREDMETA
		SET BROJ = BROJ + 1;
	ELSEIF DELETING THEN
		UPDATE BROJ_PREDMETA 
		SET BROJ = BROJ - 1;
	END IF;
END @

--#SET TERMINATOR ;
SELECT * FROM SYSCAT.TRIGGERS;
DROP TRIGGER PROMENA_PREDMETA;

-- 6.     
-- 	- Napraviti tabelu student_polozeno koja za svakog studenta koji je 
--    položio barem jedan predmet sadrži podatak koliko je espb bodovoa položio. 
--    Tabela ima kolone indeks i espb.
-- 	- Napraviti tabelu predmet_polozeno koja za svaki predmet koji je položio 
--    barem jedan student sadrži podatak koliko je studenata položilo taj predmet.
--    Tabela ima kolone idpredmeta i brojstudenata.
-- 	- Uneti podatke u tabelu student_polozeno za studente koji su položili sve 
--    obavezne predmete na smeru koji studiraju.
-- 	- Napisati naredbu koja menja tabelu student_polozeno tako što ažurira broj 
--    položenih espb bodova za studente o kojima sadrži podatke, a unosi 
--    informaicje za studente o kojima ne postoje podaci u tabeli student_polozeno.
--	- Uneti podatke u tabelu predmet_polozeno.
-- 	- Napraviti okidač koji nakon unosa položenog ispita ažurira tabele 
--    student_polozeno i predmet_polozeno tako da sadrže podatak o novom ispitu.
-- 	- Uneti podatak da je student sa indeksom 20150320 polagao predmet sa 
--    id 2010 u ispitnom roku jun2 2017/2018. šk. godine. Student je ispit 
--    položio sa 95 poena i dobio ocenu 10.
-- 	- Uneti podatak da je student sa indeksom 20152003 polagao predmet sa 
--    id 1695 u ispitnom roku jun1 2017/2018. šk. godine. Student je ispit 
--    položio sa 95 poena i dobio je ocenu 10.

CREATE TABLE STUDENT_POLOZENO (
	INDEKS			INTEGER	NOT NULL PRIMARY KEY,
	ESPB			SMALLINT
);

CREATE TABLE PREDMET_POLOZENO (
	IDPREDMETA		INTEGER NOT NULL PRIMARY KEY,
	BROJSTUDENATA	SMALLINT
);

INSERT INTO STUDENT_POLOZENO (INDEKS, ESPB)
SELECT D.INDEKS, SUM(P.ESPB)
FROM DA.DOSIJE D JOIN DA.ISPIT I 
		ON D.INDEKS = I.INDEKS
				 JOIN DA.PREDMET P
		ON I.IDPREDMETA = P.ID
WHERE I.OCENA > 5 AND I.STATUS = 'o'
GROUP BY D.INDEKS, D.IDPROGRAMA
HAVING NOT EXISTS (
	SELECT *
	FROM DA.PREDMETPROGRAMA PP
	WHERE PP.IDPROGRAMA = D.IDPROGRAMA 
		AND PP.VRSTA = 'obavezan'
		AND NOT EXISTS(
			SELECT *
			FROM DA.ISPIT I1
			WHERE I1.INDEKS = D.INDEKS
				AND I1.IDPREDMETA = PP.IDPREDMETA
				AND I1.OCENA > 5 AND I1.STATUS = 'o'
		)
);

MERGE INTO STUDENT_POLOZENO SP
USING (
	SELECT INDEKS, SUM(P.ESPB) POLOZENO
	FROM DA.ISPIT I JOIN DA.PREDMET P
		ON P.ID = I.IDPREDMETA
	WHERE I.OCENA > 5 AND I.STATUS = 'o'
	GROUP BY INDEKS
) TMP
ON SP.INDEKS = TMP.INDEKS
WHEN MATCHED THEN
	UPDATE 
	SET SP.ESPB = TMP.POLOZENO
WHEN NOT MATCHED THEN
	INSERT
	VALUES (TMP.INDEKS, TMP.POLOZENO);

INSERT INTO PREDMET_POLOZENO
SELECT IDPREDMETA, COUNT(*)
FROM DA.ISPIT I
WHERE I.OCENA > 5 AND I.STATUS = 'o'
GROUP BY IDPREDMETA;

--#SET TERMINATOR @
CREATE TRIGGER POLOZEN_ISPIT
AFTER INSERT
ON DA.ISPIT
REFERENCING 
	NEW AS N
FOR EACH ROW
WHEN (N.OCENA > 5 AND N.STATUS = 'o')
BEGIN ATOMIC
	IF N.INDEKS IN (SELECT INDEKS FROM STUDENT_POLOZENO) THEN
		UPDATE STUDENT_POLOZENO
		SET ESPB = ESPB + (
			SELECT ESPB
			FROM DA.PREDMET
			WHERE ID = N.IDPREDMETA
		)
		WHERE INDEKS = N.INDEKS;
	ELSE
		INSERT INTO STUDENT_POLOZENO
		VALUES(N.INDEKS, (
			SELECT ESPB
			FROM DA.PREDMET
			WHERE ID = N.INDEKS
		));
	END IF;
	
	IF N.IDPREDMETA IN (SELECT IDPREDMETA FROM PREDMET_POLOZENO) THEN
		UPDATE PREDMET_POLOZENO
		SET BROJSTUDENATA = BROJSTUDENATA + 1
		WHERE IDPREDMETA = N.IDPREDMETA;
	ELSE
		INSERT INTO PREDMET_POLOZENO
		VALUES (N.IDPREDMETA, 1);
	END IF;
END @

--#SET TERMINATOR ;
INSERT INTO DA.ISPIT (INDEKS, IDPREDMETA, OZNAKAROKA, SKGODINA, STATUS, POENI, OCENA)
VALUES (20150320, 2010, 'jun2', 2017, 'o', 95, 10);

INSERT INTO DA.ISPIT (INDEKS, IDPREDMETA, OZNAKAROKA, SKGODINA, STATUS, POENI, OCENA)
VALUES (20152003, 1695, 'jun2', 2017, 'o', 95, 10);
