-- 1. Izdvojiti nazive predmeta koje je POLAGAO student sa indeksom 22/2017.

-- Varijanta 1 - resenje spajanjem
SELECT	DISTINCT P.NAZIV
FROM	DA.PREDMET AS P JOIN
		DA.ISPIT AS I ON P.ID = I.IDPREDMETA
WHERE	I.INDEKS = 20170022 AND I.STATUS NOT IN ('p', 'n');

-- Varijanta 2 - podupit sa EXISTS
SELECT	P.NAZIV
FROM	DA.PREDMET AS P
WHERE	EXISTS (
	SELECT	*
	FROM	DA.ISPIT AS I
	WHERE	I.IDPREDMETA = P.ID AND
			I.INDEKS = 20170022 AND
			I.STATUS NOT IN ('p', 'n')
);

-- Varijanta 3 - podupit sa IN
SELECT	P.NAZIV
FROM	DA.PREDMET AS P
WHERE	P.ID IN (
	SELECT	I.IDPREDMETA
	FROM	DA.ISPIT AS I
	WHERE	I.INDEKS = 20170022 AND
			I.STATUS NOT IN ('p', 'n')
);

-- Varijanta 4 - podupit as IN, na malo drugaciji nacin
SELECT	P.NAZIV
FROM	DA.PREDMET AS P
WHERE	20170022 IN (
	SELECT	I.INDEKS
	FROM	DA.ISPIT AS I
	WHERE	I.IDPREDMETA = P.ID AND
			I.STATUS NOT IN ('p', 'n')
);

-- 2. Izdvojiti ime i prezime studenta koji ima ispit polozen sa ocenom 9.

SELECT	DISTINCT D.IME, D.PREZIME
FROM	DA.DOSIJE AS D JOIN
		DA.ISPIT AS I ON D.INDEKS = I.INDEKS
WHERE	I.STATUS = 'o' AND I.OCENA = 9;

SELECT	D.IME, D.PREZIME
FROM	DA.DOSIJE AS D
WHERE	EXISTS (
	SELECT	*
	FROM	DA.ISPIT AS I
	WHERE	I.INDEKS = D.INDEKS AND
			I.STATUS = 'o' AND I.OCENA = 9
);

-- 3. Izdvojiti indekse studenata koji su polozili bar jedan predmet koji
-- nije polozio student sa indeksom 22/2017.

SELECT	DISTINCT INDEKS
FROM	DA.ISPIT
WHERE	STATUS = 'o' AND OCENA > 5 AND
		IDPREDMETA NOT IN (
			SELECT	IDPREDMETA
			FROM	DA.ISPIT
			WHERE	INDEKS = 20170022 AND
					STATUS = 'o' AND OCENA > 5
		);

-- 4. Koriscenjem egzistencijalnog kvantifikatora exists izdvojiti 
-- nazive predmeta koje je polozio student sa indeksom 22/2017.

SELECT	NAZIV
FROM	DA.PREDMET AS P
WHERE	EXISTS (
	SELECT	*
	FROM	DA.ISPIT AS I
	WHERE	I.INDEKS = 20170022 AND
			I.STATUS = 'o' AND I.OCENA > 5 AND
			I.IDPREDMETA = P.ID
);

-- 5. Izdvojiti naziv predmeta ciji je kurs organizovan u svim skolskim 
-- godinama o kojima postoje podaci u bazi podataka.

SELECT	P.NAZIV
FROM	DA.PREDMET AS P
WHERE	NOT EXISTS (
	SELECT	*
	FROM	DA.SKOLSKAGODINA AS SG
	WHERE	P.ID NOT IN (
		SELECT	K.IDPREDMETA
		FROM	DA.KURS AS K
		WHERE	K.SKGODINA = SG.SKGODINA
	)
);

-- 6. Izdvojiti podatke o studentu koji je upisao sve skolske godine o
-- kojima postoje podaci u bazi podataka.

-- Varijanta sa IN
SELECT	*
FROM	DA.DOSIJE AS D
WHERE	NOT EXISTS (
	SELECT	*
	FROM	DA.SKOLSKAGODINA AS SG
	WHERE	(D.INDEKS, SG.SKGODINA) NOT IN (
		SELECT	INDEKS, SKGODINA
		FROM	DA.UPISGODINE
	)
);

-- Varijanta sa EXISTS
SELECT	*
FROM	DA.DOSIJE AS D
WHERE	NOT EXISTS (
	SELECT	*
	FROM	DA.SKOLSKAGODINA AS SG
	WHERE	NOT EXISTS (
		SELECT	*
		FROM	DA.UPISGODINE AS UG
		WHERE	UG.INDEKS = D.INDEKS AND
				UG.SKGODINA = SG.SKGODINA
	)
);

-- Rezultat je isti, ali se performanse razlikuju. Cesto je bolje izbegavati
-- upotrebu IN u podupitima.

-- 7. Izdvojiti indekse studenata koji su polagali u svim ispitnim rokovima.

SELECT	D.INDEKS
FROM	DA.DOSIJE AS D
WHERE	NOT EXISTS (
	SELECT	*
	FROM	DA.ISPITNIROK AS IR
	WHERE	NOT EXISTS (
		SELECT	*
		FROM	DA.ISPIT AS I
		WHERE	I.INDEKS = D.INDEKS AND
				(I.SKGODINA, I.OZNAKAROKA) = (IR.SKGODINA, IR.OZNAKAROKA) AND
				I.STATUS NOT IN ('p', 'n')
	)
);

-- Nema takvih studenata!

-- 8. Izdvojiti indekse studenata koji su polagali u svim ispitnim rokovima
-- odrzanim u 2018/2019. sk. godini.

SELECT	D.INDEKS
FROM	DA.DOSIJE AS D
WHERE	NOT EXISTS (
	SELECT	*
	FROM	DA.ISPITNIROK AS IR
	WHERE	IR.SKGODINA = 2018 AND
			NOT EXISTS (
				SELECT	*
				FROM	DA.ISPIT AS I
				WHERE	I.INDEKS = D.INDEKS AND
						(I.SKGODINA, I.OZNAKAROKA) = (IR.SKGODINA, IR.OZNAKAROKA) AND
						I.STATUS NOT IN ('p', 'n')
			)
);

-- Opet nema takvih studenata!

-- 9. Izdvojiti podatke o predmetima sa najvecim brojem espb bodova.

-- Varijanta sa EXISTS
SELECT	*
FROM	DA.PREDMET AS P1
WHERE	NOT EXISTS (
	SELECT	*
	FROM	DA.PREDMET AS P2
	WHERE	P2.ESPB > P1.ESPB
);

-- Varijanta sa ALL
SELECT	*
FROM	DA.PREDMET
WHERE	ESPB >= ALL (
	SELECT	ESPB
	FROM	DA.PREDMET
);

-- 10. Izdvojiti podatke o studentima sa najranijim datumom diplomiranja.

SELECT	*
FROM	DA.DOSIJE
WHERE	DATDIPLOMIRANJA <= ALL (
	SELECT	DATDIPLOMIRANJA
	FROM	DA.DOSIJE
	WHERE	DATDIPLOMIRANJA IS NOT NULL
);

-- 11. Izdvojiti podatke o svim studentima osim onih sa najranijim datumom diplomiranja.

-- Varijanta sa negacijom od ALL
SELECT	*
FROM	DA.DOSIJE
WHERE	NOT DATDIPLOMIRANJA <= ALL (
	SELECT	DATDIPLOMIRANJA
	FROM	DA.DOSIJE
	WHERE	DATDIPLOMIRANJA IS NOT NULL
)	OR DATDIPLOMIRANJA IS NULL;

-- Varijanta sa ANY
SELECT	*
FROM	DA.DOSIJE
WHERE	DATDIPLOMIRANJA > ANY (
	SELECT	DATDIPLOMIRANJA
	FROM	DA.DOSIJE
	WHERE	DATDIPLOMIRANJA IS NOT NULL
)	OR DATDIPLOMIRANJA IS NULL;

-- Varijanta sa EXISTS
SELECT	*
FROM	DA.DOSIJE AS D1
WHERE	EXISTS (
	SELECT	*
	FROM	DA.DOSIJE AS D2
	WHERE	D2.DATDIPLOMIRANJA < D1.DATDIPLOMIRANJA
)	OR DATDIPLOMIRANJA IS NULL;

-- 12. Izdvojiti podatke o predmetima koje su upisali neki studenti.

SELECT	*
FROM	DA.PREDMET
WHERE	ID = SOME ( -- SOME je isto sto i ANY
	SELECT	IDPREDMETA
	FROM	DA.UPISANKURS
);

-- 13. Za studente koji su polagali ispit u ispitnom roku odrzanom
-- u 2018/2019. sk. godini izdvojiti podatke o polozenim ispitima. 
-- Izdvojiti indeks, ime, prezime studenta, naziv polozenog predmeta,
-- oznaku ispitnog roka i skolsku godinu u kojoj je ispit polozen.

SELECT	D.INDEKS, D.IME, D.PREZIME,
		P.NAZIV,
		I.OZNAKAROKA, I.SKGODINA
FROM	DA.DOSIJE AS D JOIN
		DA.ISPIT AS I ON I.INDEKS = D.INDEKS JOIN
		DA.PREDMET AS P ON P.ID = I.IDPREDMETA
WHERE	I.STATUS = 'o' AND I.OCENA > 5 AND
		EXISTS (
			SELECT	*
			FROM	DA.ISPIT
			WHERE	INDEKS = D.INDEKS AND
					STATUS NOT IN ('p', 'n') AND
					SKGODINA = 2018
		);

-- 14. Izdvojiti podatke o predmetima koje su polagali svi studenti 
-- iz Berana koji studiraju smer sa oznakom I.

SELECT	*
FROM	DA.PREDMET AS P
WHERE	NOT EXISTS (
	SELECT	*
	FROM	DA.DOSIJE AS D JOIN
			DA.STUDIJSKIPROGRAM AS SP ON D.IDPROGRAMA = SP.ID
	WHERE	D.MESTORODJENJA = 'Berane' AND SP.OZNAKA = 'I' AND
			NOT EXISTS (
				SELECT	*
				FROM	DA.ISPIT AS I
				WHERE	(I.INDEKS, I.IDPREDMETA) = (D.INDEKS, P.ID) AND
						I.STATUS NOT IN ('p', 'n')
			)
);
