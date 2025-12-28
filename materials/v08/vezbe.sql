/*
	Uvod u relacione baze podataka - cas 8
	Jezik za definisanje podataka (DDL).
	Jezik za manipulaciju podataka (DML).
*/

/** DQL - Data Query Language **/

/*
	Osnovna naredba:
		SELECT

	(Ovo smo do sada radili)
*/

/** DDL - Data Definition Language **/

/*
	Osnovne naredbe:
		CREATE TABLE - kreiranje tabele
		ALTER TABLE  - menjanje strukture tabele
		DROP TABLE   - brisanje tabele iz baze podataka
*/

/** DML - Data Manipulation Language **/

/*
	Osnovne naredbe:
		INSERT INTO - ubacivanje novih redova u tabelu
		UPDATE      - izmena redova u tabeli
		DELETE FROM - brisanje redova iz tabele
*/

-- Zadaci:

-- 1. Napraviti tabelu kandidati_za_upis u kojoj će se nalaziti podaci
-- o prijavama za upis na fakultet. Tabela ima kolone:
-- 	- id - identifikator prijave, ceo broj
--	- idprograma - identifikator željenog studijskog programa
-- 	- ime - ime kandidata, niska maksimalne dužine 50 karaktera
-- 	- prezime -prezime kandidata, niska maksimalne dužine 50 karaktera
-- 	- pol - pol kandidata; moguće vrednosti su m i z
--	- mestorodjenja -mesto rođenja kandidata, niska maksimalne dužine
--    50 karaktera
--	- datumprijave - datum prijave kandidata
--	- bodovi - bodovi za upis
-- Definisati primarni ključ u tabeli kandidati_za_upis i strani ključ
-- na tabelu studijskiprogram. Postaviti ograničenje za moguće
-- vrednosti kolone pol.

DROP TABLE IF EXISTS DA.KANDIDATI_ZA_UPIS;

CREATE TABLE DA.KANDIDATI_ZA_UPIS (
	ID				INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (MINVALUE 1),
									  -- mora se dodati uslov NOT NULL za kolunu
									  -- primarnog kljuca
	IDPROGRAMA 		INTEGER,
	IME 			VARCHAR(50),
	PREZIME 		VARCHAR(50),
	POL 			CHAR,
	MESTORODJENJA 	VARCHAR(50),
	DATUMPRIJAVE 	DATE,
	BODOVI 			INTEGER,

	PRIMARY KEY (ID),
	FOREIGN KEY FK_ID_PROGRAMA_STUDIJSKI_PROGRAM (IDPROGRAMA)
					REFERENCES DA.STUDIJSKIPROGRAM,
	CONSTRAINT CHK_POL CHECK (POL IN ('m', 'z'))
);

-- 2. U tabelu kandidati_za_upis uneti novog kandidata Marka
-- Markovića, muškog pola , koji je rođen u Kragujevcu, a prijavio
-- se 12.11.2020. za studjski program Informatika (id 103).

INSERT INTO DA.KANDIDATI_ZA_UPIS
			(IDPROGRAMA, IME, PREZIME, POL, MESTORODJENJA,
					DATUMPRIJAVE)
			VALUES (103, 'Marko', 'Markovic', 'm', 'Kragujevac',
						DATE('12.11.2020'));

SELECT * FROM DA.KANDIDATI_ZA_UPIS;

-- 3. Iz tabele kandidati_za_upis ukloniti kolonu mestorodjenja.

ALTER TABLE DA.KANDIDATI_ZA_UPIS
	DROP MESTORODJENJA;

-- 4. Postaviti uslov u tabeli kandidati_za_upis da bodovi za upis
-- mogu biti samo između 0 i 100 i da je podrazumevan datum prijave
-- datum izvršavanja naredbe.

ALTER TABLE DA.KANDIDATI_ZA_UPIS
	ADD CONSTRAINT CHK_BODOVI CHECK (BODOVI BETWEEN 0 AND 100);

ALTER TABLE DA.KANDIDATI_ZA_UPIS
	ALTER COLUMN DATUMPRIJAVE SET DEFAULT CURRENT_DATE;

-- Note: Pokrenuti db2 reorg table da.kandidati_za_upis obavezno

-- 5. U tabelu kandidati_za_upis uneti nove kandidate sa podacima
--	- Snezana Peric, pol ženski, željeni smer Informatika (id 103)
-- 	- Marija Peric, pol ženski, željeni smer Matematika (id 101)



INSERT INTO DA.KANDIDATI_ZA_UPIS
			(IDPROGRAMA, IME, PREZIME, POL)
			VALUES (103, 'Snezana', 'Peric', 'z'),
				   (101, 'Marija', 'Peric', 'z');

-- 6. U tabelu kandidati_za_upis uneti kao kandidate studente koji
-- imaju status Ispisan u tabeli dosije. Kao željeni studijski program
-- navesti studijski program koji su studirali kada su se ispisali.
-- Kao broj ostvarenih bodova za upis uneti vrednost 90.

INSERT INTO DA.KANDIDATI_ZA_UPIS (IDPROGRAMA, IME, PREZIME, POL, BODOVI)
SELECT	D.IDPROGRAMA, D.IME, D.PREZIME, D.POL, 90
FROM	DA.DOSIJE D
WHERE	D.IDSTATUSA = -1;
-- moze i spajanje sa STUDENTSKISTATUS, a moze i "magicna vrednost"

-- 7. Iz tabele kandidati_za_upis obrisati podatke o kandidatima
-- za koje je nepoznat broj bodova za upis.

SELECT * FROM DA.KANDIDATI_ZA_UPIS;
SELECT * FROM DA.KANDIDATI_ZA_UPIS WHERE BODOVI IS NULL;

DELETE FROM DA.KANDIDATI_ZA_UPIS WHERE BODOVI IS NULL;

SELECT * FROM DA.KANDIDATI_ZA_UPIS;
SELECT * FROM DA.KANDIDATI_ZA_UPIS WHERE BODOVI IS NULL;

-- 8. Iz tabele kandidati_za_upis obrisati podatke o kandidatima
-- koji se zovu kao neki student koji ima položen ispit.

DELETE FROM DA.KANDIDATI_ZA_UPIS
WHERE IME IN (
	SELECT DISTINCT IME
	FROM DA.ISPIT I JOIN DA.DOSIJE D ON (I.INDEKS = D.INDEKS)
	WHERE I.OCENA > 5 AND I.STATUS = 'o'
);

-- 9. Svim kandidatima za upis na fakultet koji su se prijavili u
-- poslednja dva dana i imaju unet broj bodova za upis povećati broj
-- bodova za upis za 20%.

UPDATE DA.KANDIDATI_ZA_UPIS
SET BODOVI = 1.2*BODOVI
WHERE DAY(CURRENT_DATE-DATUMPRIJAVE) < 3 AND BODOVI IS NOT NULL;
-- ovo nece proci uslov da je broj bodova izmedju 0 i 100

UPDATE DA.KANDIDATI_ZA_UPIS
SET BODOVI = 1.1*BODOVI
WHERE DAY(CURRENT_DATE-DATUMPRIJAVE) < 3 AND BODOVI IS NOT NULL;

-- 10. Ukloniti tabelu kandidati_za_upis.

DROP TABLE DA.KANDIDATI_ZA_UPIS;

-- 11. Promeniti broj indeksa studenta sa indeksom 20171063 u
-- indeks 20172063 u tabeli dosije.

INSERT INTO DA.DOSIJE
SELECT 20172063, D.IDPROGRAMA, D.IME, D.PREZIME, D.POL, D.MESTORODJENJA,
				D.IDSTATUSA, D.DATUPISA, D.DATDIPLOMIRANJA
FROM DA.DOSIJE D
WHERE INDEKS = 20171063;

UPDATE DA.UPISGODINE
SET INDEKS = 20172063
WHERE INDEKS = 20171063;

INSERT INTO DA.UPISANKURS (INDEKS, SKGODINA, IDPREDMETA, SEMESTAR)
SELECT 20172063, SKGODINA, IDPREDMETA, SEMESTAR
FROM DA.UPISANKURS
WHERE INDEKS = 20171063;

UPDATE DA.ISPIT
SET INDEKS = 20172063
WHERE INDEKS = 20171063;

DELETE FROM DA.UPISANKURS
WHERE INDEKS = 20171063;

DELETE FROM DA.DOSIJE
WHERE INDEKS = 20171063;

SELECT *
FROM DA.DOSIJE
WHERE INDEKS IN (20171063, 20172063);