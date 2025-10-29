/*
	Uvod u relacione baze podataka - cas 7
	Slozeni SQL upit. Pomocne tabele (WITH nareba)	
*/

/** Ponavljanje: Agregatne funkcije, GROUP BY, HAVING **/

-- Bitnije teme za podsecanje:
-- 1. Kada uslove stavljamo u ON, a kada u WHERE (zadatak 8.)
-- 2. Po cemu sve moze da se vrsi grupisanje (zadatak 11.)
-- 3. Redosled izvrsavanja i svojstva klauza GROUP BY i HAVING,
--	  razlika klauza WHERE i HAVING (zadatak 9.)

-- zadatak od proslog casa:
-- 13. Za svakog studenta koji je položio između 15 i 25 bodova 
-- i čije ime sadrži malo ili veliko slovo o ili a izdvojiti indeks, 
-- ime, prezime, broj prijavljenih ispita, broj različitih predmeta 
-- koje je prijavio, broj ispita koje je položio i prosečnu ocenu. 
-- Rezultat urediti prema indeksu.

SELECT D.INDEKS, D.IME, D.PREZIME, COUNT(*) BROJ_PRIJAVLJENIH,
		COUNT(DISTINCT IDPREDMETA) BROJ_PREDMETA,
		COUNT(CASE
			WHEN I.STATUS = 'o' AND I.OCENA > 5 THEN 1
			ELSE NULL
		   END) BROJ_POLOZENIH,
		DECIMAL(AVG(CASE
			WHEN I.STATUS = 'o' AND I.OCENA > 5 THEN 1.0*I.OCENA
			ELSE NULL
		   END), 4, 2) PROSEK
FROM DA.DOSIJE D JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS)
			 	 JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
WHERE LOWER(IME) LIKE '%o%' OR LOWER(IME) LIKE '%a%'
GROUP BY D.INDEKS, D.IME, D.PREZIME
HAVING SUM(CASE
			WHEN I.STATUS = 'o' AND I.OCENA > 5 THEN P.ESPB
			ELSE 0
		   END) BETWEEN 15 AND 25;

-- 0. Za studenta koji ima ocenu 8 ili 9 izračunati iz koliko
-- ispita je dobio ocenu 8 i iz koliko ispita je dobio ocenu 9.
-- Izdvojiti indeks studenta, broj ispita iz kojih je student 
-- dobio ocenu 8 i broj ispita iz kojih je student dobio ocenu 9.

SELECT INDEKS, COUNT(CASE
						WHEN OCENA = 8 THEN 1
						ELSE NULL
				 	 END) OSMICE,
			   COUNT(CASE
						WHEN OCENA = 9 THEN 1
						ELSE NULL
				 	 END) DEVETKE
FROM DA.ISPIT
WHERE OCENA IN (8, 9) AND STATUS = 'o'
GROUP BY INDEKS;

/** Slozeni SQL upit **/

-- 1. Predmeti  se  kategorisu  kao
-- laki: ukoliko  nose  manje  od  6  bodova,
-- teski: ukoliko nose vise od 8 bodova,
-- inace su srednje teski.
-- Prebrojati koliko predmeta pripada kojoj kategoriji.
-- Izdvojiti kategoriju i broj predmeta iz te kategorije.

SELECT CASE
		WHEN ESPB < 6 THEN 'lak'
		WHEN ESPB < 9 THEN 'srednje tezak'
		ELSE 'tezak'
	   END KATEGORIJA, COUNT(*)
FROM DA.PREDMET
GROUP BY CASE
		WHEN ESPB < 6 THEN 'lak'
		WHEN ESPB < 9 THEN 'srednje tezak'
		ELSE 'tezak'
	   END;


WITH POMOCNA AS (
	SELECT ID, CASE
			WHEN ESPB < 6 THEN 'lak'
			WHEN ESPB < 9 THEN 'srednje tezak'
			ELSE 'tezak'
		   END KATEGORIJA
	FROM DA.PREDMET
)
SELECT KATEGORIJA, COUNT(*)
FROM POMOCNA
GROUP BY KATEGORIJA;

-- 2. Izracunati koliko studenata je polozilo vise od 20 bodova.

WITH POMOCNA AS (
	SELECT INDEKS
	FROM DA.ISPIT I JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
	WHERE I.OCENA > 5 AND I.STATUS = 'o'
	GROUP BY INDEKS
	HAVING SUM(P.ESPB) > 20
)
SELECT COUNT(*)
FROM POMOCNA;

/** 

Ovako bi trebali da pravimo grupe dva puta - prvi put za racunanje
bodova, a drugi put za prebrojavanje studenata koji imaju vise od 20 bodova
(to prebrojavanje je nad grupama)

Ovako dobijamo broj uspesnih polaganja za svakog studenta

SELECT COUNT(*)
FROM DA.ISPIT I JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
WHERE I.OCENA > 5 AND I.STATUS = 'o'
GROUP BY INDEKS
HAVING SUM(P.ESPB) > 20;

**/

-- 3.  Za svakog studenta naci broj ispitnih rokova
-- u kojima je on polozio bar 2 predmeta

WITH POMOCNA AS (
	SELECT INDEKS, SKGODINA, OZNAKAROKA
	FROM DA.ISPIT
	WHERE OCENA > 5 AND STATUS = 'o'
	GROUP BY INDEKS, SKGODINA, OZNAKAROKA
	HAVING COUNT(*) >= 2
) 
SELECT INDEKS, COUNT(*)
FROM POMOCNA
GROUP BY INDEKS;

-- 4. Za svaki predmet izdvojiti identifikator i broj razlicitih 
-- studenata koji su ga polagali. Uz identifikatore predmeta 
-- koje niko nije polagao izdvojiti 0.

SELECT I.IDPREDMETA, COUNT(DISTINCT INDEKS)
FROM DA.ISPIT I RIGHT JOIN DA.PREDMET P 
					ON (I.IDPREDMETA = P.ID AND I.STATUS NOT IN ('n', 'p'))
GROUP BY I.IDPREDMETA;

-- 5. Za svakog studenta izdvojiti ime i prezime i broj razlicitih 
-- predmeta iz kojih je pao ispit (ako nije pao ispit - izdvojiti 0).

SELECT D.INDEKS, COUNT(DISTINCT IDPREDMETA)
FROM DA.DOSIJE D LEFT JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS AND
										I.OCENA = 5 AND I.STATUS = 'o')
GROUP BY D.INDEKS;

WITH POMOCNA AS (
	SELECT INDEKS, COUNT(DISTINCT IDPREDMETA) BROJPALIH
	FROM DA.ISPIT
	WHERE OCENA = 5 AND STATUS = 'o'
	GROUP BY INDEKS
)
SELECT IME, PREZIME, COALESCE(BROJPALIH, 0)
FROM DA.DOSIJE D LEFT JOIN POMOCNA P ON (D.INDEKS = P.INDEKS);

-- 6. Izdvojiti broj studenata koji su polozili neke predmete 
-- u bar 2 razlicita roka.

WITH POMOCNA AS (
	SELECT DISTINCT INDEKS, SKGODINA, OZNAKAROKA
	FROM DA.ISPIT
	WHERE OCENA > 5 AND STATUS = 'o'
), POMOCNA_2 AS (
	SELECT INDEKS
	FROM POMOCNA
	GROUP BY INDEKS
	HAVING COUNT(*) > 2
)
SELECT COUNT(*)
FROM POMOCNA_2;

-- 7. Izdvojiti ime i prezime studenta i naziv ispitnog roka u kome 
-- student ima svoj najmanji procenat uspešnosti na ispitima. 
-- Izdvojiti i procenat uspešnosti na ispitima u tom roku kao 
-- decimalan broj sa 2 cifre iza decimalne tačke. Procenat uspešnosti 
-- studenta u ispitnom roku se računa kao procenat broja položenih 
-- ispita u odnosu na broj prijavljenih ispita. Izdvojiti samo podatke
-- za studente iz Aranđelovca i koji u tom roku imaju najmanji 
-- procenat uspešnosti u poređenju sa ostalim studentima.   

WITH POMOCNA AS (
	SELECT INDEKS, SKGODINA, OZNAKAROKA,
			COUNT(CASE
					WHEN OCENA > 5 AND STATUS = 'o' THEN 1
					ELSE NULL
				  END)*1.0/ COUNT(*) PROCENAT
	FROM DA.ISPIT
	GROUP BY INDEKS, SKGODINA, OZNAKAROKA
), POMOCNA_2 AS (
	SELECT INDEKS, SKGODINA, OZNAKAROKA, PROCENAT
	FROM POMOCNA P1
	WHERE PROCENAT = (
		SELECT MIN(PROCENAT)
		FROM POMOCNA P2
		WHERE P1.INDEKS = P2.INDEKS
	)
)
SELECT D.IME, D.PREZIME, IR.NAZIV
FROM DA.DOSIJE D JOIN POMOCNA_2 P2 ON (D.INDEKS = P2.INDEKS)
				JOIN DA.ISPITNIROK IR ON ( P2.SKGODINA = IR.SKGODINA AND
											P2.OZNAKAROKA = IR.OZNAKAROKA)
WHERE MESTORODJENJA = 'Arandjelovac' AND P2.PROCENAT = (
	SELECT MIN(PROCENAT)
	FROM POMOCNA P
	WHERE P.SKGODINA = P2.SKGODINA AND P.OZNAKAROKA = P2.OZNAKAROKA
);