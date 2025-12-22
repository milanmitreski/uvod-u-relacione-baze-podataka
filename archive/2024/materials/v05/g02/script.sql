/*
	Uvod u relacione baze podataka - cas 5
	Skalarne funkcije (nastavak). CASE izraz.
	Funkcije za rad sa nedefinisanim vrednostima.
	Agregatne funkcije.
*/

/*** Skalarne funkcije (nastavak) ***/

-- 1. Izračunati koji je dan u nedelji (njegovo ime) bio 3.11.2019.

VALUES DAYNAME(DATE('03.11.2019'));
VALUES DAYNAME('03.11.2019');

SELECT DAYNAME('03.11.2019'), 2+3
FROM SYSIBM.SYSDUMMY1;

-- 2. Za današnji datum izračunati: 
--    - koji je dan u godini
--    - u kojoj je nedelji u godini
--    - koji je dan u nedelji
--    - ime dana
--    - ime meseca.

SELECT DAYOFYEAR(CURRENT_DATE),
		WEEK(CURRENT_DATE),
		DAYOFWEEK(CURRENT_DATE),
		DAYNAME(CURRENT_DATE),
		MONTHNAME(CURRENT_DATE)
FROM SYSIBM.SYSDUMMY1;

-- 3. Izdvojiti sekunde iz trenutnog vremena. 

SELECT SECOND(CURRENT_TIME), CURRENT_TIME
FROM SYSIBM.SYSDUMMY1;

-- 4. Izračunati koliko vremena je prošlo između 6.8.2005. 
-- i 11.11.2008.

SELECT YEAR(DATE('11.11.2008') - DATE('6.8.2005')), -- broj oblika YYYYMMDD
		MONTH(DATE('11.11.2008') - DATE('6.8.2005')),
		DAY(DATE('11.11.2008') - DATE('6.8.2005'))
FROM SYSIBM.SYSDUMMY1;

-- 5. Izračunati koji će datum biti za 12 godina, 5 meseci i 25 dana. 

SELECT CURRENT_DATE + 12 YEARS + 5 MONTHS + 25 DAYS
FROM SYSIBM.SYSDUMMY1;

-- 6. Izdvojiti ispite koji su održani posle 28. septembra 
-- 2020. godine. 

SELECT * 
FROM DA.ISPIT
WHERE DATPOLAGANJA > DATE('28.09.2020');

-- 7. Pronaći ispite koji su održani u poslednjih 8 meseci.

SELECT * 
FROM DA.ISPIT
WHERE DATPOLAGANJA > CURRENT_DATE - 56 MONTHS;

SELECT *
FROM DA.ISPIT
WHERE MONTHS_BETWEEN(CURRENT_DATE, DATPOLAGANJA) < 56;

SELECT *
FROM DA.ISPIT
WHERE CURRENT_DATE - DATPOLAGANJA < 40800;

-- 8. Za sve ispite koji su održani u poslednjih 5 godina 
-- izračunati koliko je godina, meseci i dana prošlo od 
-- njihovog održavanja. Izdvojiti indeks, naziv predmeta, 
-- ocenu, broj godina, broj meseci i broj dana. 

SELECT I.INDEKS, P.NAZIV, I.OCENA, YEAR(CURRENT_DATE-DATPOLAGANJA) GODINE,
		MONTH(CURRENT_DATE-DATPOLAGANJA) MESECI, 
		DAY(CURRENT_DATE-DATPOLAGANJA) DANI 
FROM DA.PREDMET P JOIN DA.ISPIT I ON (P.ID = I.IDPREDMETA)
WHERE I.DATPOLAGANJA > CURRENT_DATE - 5 YEARS;

-- 9. Prikazati trenutno vreme i trenutni datum u
--    - ISO formatu
--    - USA formatu
--    - EUR formatu.

SELECT CHAR(CURRENT_TIME, ISO), CHAR(CURRENT_DATE, ISO)
FROM SYSIBM.SYSDUMMY1;

SELECT CHAR(CURRENT_TIME, USA), CHAR(CURRENT_DATE, USA)
FROM SYSIBM.SYSDUMMY1;

SELECT CHAR(CURRENT_TIME, EUR), CHAR(CURRENT_DATE, EUR)
FROM SYSIBM.SYSDUMMY1;

-- 10. Ako je predmetima potrebno uvećati broj espb bodova za 20% 
-- prikazati koliko će svaki predmet imati espb bodova nakon uvećanja.
-- Uvećani broj bodova prikazati sa dve decimale.

SELECT ROUND(20.81572, 3), DECIMAL(20.8157, 5, 3)
FROM SYSIBM.SYSDUMMY1;

SELECT DECIMAL(1.2*ESPB,4,2) BODOVI
FROM DA.PREDMET;

-- 11. Ako je predmetima potrebno uvećati broj espb bodova za 20% 
-- prikazati koliko će espb bodova imati predmeti koji nakon uvećanja
-- imaju više od 8 bodova. Uvećani broj espb bodova zaokružiti na 
-- veću ili jednaku celobrojnu vrednost.

SELECT CEIL(1.2*ESPB) BODOVI
FROM DA.PREDMET
WHERE 1.2*ESPB > 8; -- ovde ne moze BODOVI jer se WHERE izvrsava pre SELECT-a

-- 12. Pronaći indekse studenata koji su jedini položili ispit 
-- iz nekog predmeta sa ocenom 10. Za studenta sa brojem 
-- indeksa GGGGBBBB izdvojiti indeks u formatu BBBB/GGGG.

SELECT SUBSTR(INDEKS, 5, 4) || '/' || SUBSTR(INDEKS, 1, 4)
FROM DA.ISPIT I1
WHERE I1.OCENA = 10 AND I1.STATUS = 'o' AND NOT EXISTS (
	SELECT * 
	FROM DA.ISPIT I2
	WHERE I2.OCENA = 10 
		AND I2.STATUS = 'o' 
		AND I1.INDEKS <> I2.INDEKS
		AND I1.IDPREDMETA = I2.IDPREDMETA
);

/*** CASE izraz ***/

/*
dva oblika

CASE
	WHEN uslov1 THEN nesto1
	WHEN uslov2 THEN nesto2
	...
	WHEN uslovN THEN nestoN
	ELSE nestoElse
END

CASE kolona
	WHEN vrednost1 THEN nesto1
	WHEN vrednost2 THEN nesto2
	...
	WHEN vrednostN THEN nestoN
	ELSE nestoElse
END -- moraju biti "zakucane" vrednosti
<===>
CASE
	WHEN kolona = vrednost1 THEN nesto1
	WHEN kolona = vrednost2 THEN nesto2
	...
	WHEN kolona = vrednostN THEN nestoN
	ELSE nestoElse
END

CASE kolona
	WHEN < 5 THEN 'Manje od 5'
	ELSE 'Vece jednako od 5'
END -- ovo ne moze!
*/

-- 13. Za svaki polagan ispit izdvojiti indeks, identifikator 
-- predmeta i dobijenu ocenu. Vrednost ocene ispisati i slovima. 
-- Ako je predmet nepoložen umesto ocene ispisati nepolozen.

SELECT INDEKS, IDPREDMETA, OCENA, 
		CASE
			WHEN ocena = 10 THEN 'deset'
			WHEN ocena = 9 THEN 'devet'
			WHEN ocena = 8 THEN 'osam'
			WHEN ocena = 7 THEN 'sedam'
			WHEN ocena = 6 THEN 'sest'
			ELSE 'nepolozen'
		END "OCENA(SLOVIMA)"
FROM DA.ISPIT
WHERE STATUS NOT IN ('p', 'n');


SELECT INDEKS, IDPREDMETA, OCENA, 
		CASE ocena
			WHEN 10 THEN 'deset'
			WHEN 9 THEN 'devet'
			WHEN 8 THEN 'osam'
			WHEN 7 THEN 'sedam'
			WHEN 6 THEN 'sest'
			ELSE 'nepolozen'
		END "OCENA(SLOVIMA)"
FROM DA.ISPIT
WHERE STATUS NOT IN ('p', 'n');

-- 14. Klasifikovati predmete prema broju espb bodova na sledeći način:
--   - ako predmet ima više od 15 espb bodova tada pripada 
--     I kategoriji
--   - ako je broj espb bodova predmeta u intervalu [10,15] tada 
--     pripada II kategoriji
--   - inače predmet pripada III kategoriji.
-- Izdvojiti naziv predmeta, espb bodove i kategoriju.

SELECT NAZIV, ESPB,
		CASE
			WHEN ESPB > 15 THEN 'I'
			WHEN ESPB >= 10 THEN 'II'
			ELSE 'III' 
		END "KATEGORIJA"
FROM DA.PREDMET;

-- 15. Izdvojiti indeks, ime, prezime, mesto rođenja i 
-- inicijale studenata. Ime i prezime napisati u jednoj koloni, 
-- a za studente rođene u Beogradu kao mesto rođenja ispisati Bg.

SELECT INDEKS, 
		IME || ' ' || PREZIME "IME I PREZIME",
		SUBSTR(IME, 1, 1) || '. ' || SUBSTR(PREZIME, 1, 1) || '.' "INICIJALI",
		CASE 
			WHEN MESTORODJENJA LIKE 'Beograd%' THEN 'Bg'
			ELSE MESTORODJENJA
		END "MESTO RODJENJA"
FROM DA.DOSIJE;

/*** Funkcije za rad sa nedefinsanim vrednostima ***/

/*
	COALESCE(x1,...,xn) --> vrati prvi NOT NULL argument
							ako su su svi NULL -- vraca NULL
	CASE
		WHEN x1 IS NOT NULL THEN x1
		...
		WHEN xn IS NOT NULL THEN xn
		ELSE NULL
	END
	
	NULLIF(x, y) -> ako je x = y --> vrati NULL
				    u suprotnom --> vrati x
	CASE
		WHEN x = y THEN NULL
		ELSE x
	END		
*/

-- 16. Izlistati ocene dobijene na ispitima i ako je ocena jednaka 5 
-- ispisati NULL. 

SELECT OCENA, NULLIF(OCENA, 5)
FROM DA.ISPIT
WHERE OCENA IS NOT NULL
ORDER BY 2 DESC NULLS FIRST;

-- 17. Izdvojiti indeks, ime, prezime i mesto rodenja za svakog 
-- studenta.  Ako je mesto rodenja ’Sabac’, prikazati NULL.

SELECT INDEKS, IME, PREZIME, NULLIF(MESTORODJENJA, 'Sabac')
FROM DA.DOSIJE;

-- 18. Izdvojiti indeks, ime, prezime i mesto rodenja za svakog 
-- studenta.  Ako je mesto rodenja nepoznato, umesto NULL vrednosti
-- ispisati “Nepoznato”.

SELECT INDEKS, IME, PREZIME, COALESCE(MESTORODJENJA, 'Nepoznato')
FROM DA.DOSIJE;

/*** AGREGATNE FUNKCIJE ***/

-- 19. Izdvojiti ukupan broj studenata.

SELECT COUNT(*)
FROM DA.DOSIJE;

-- 19a. Izdvojiti ukupan broj diplomiranih studenata

SELECT COUNT(DATDIPLOMIRANJA)
FROM DA.DOSIJE;

SELECT * 
FROM DA.DOSIJE
WHERE DATDIPLOMIRANJA IS NOT NULL;

-- 20. Izdvojiti ukupan broj studenata koji 
-- bar iz jednog predmeta imaju ocenu 10. 

SELECT COUNT(INDEKS)
FROM DA.DOSIJE D
WHERE EXISTS(
	SELECT * 
	FROM DA.ISPIT I
	WHERE D.INDEKS = I.INDEKS AND I.OCENA = 10 AND I.STATUS = 'o'
);

SELECT COUNT(DISTINCT INDEKS)
FROM DA.ISPIT
WHERE OCENA = 10 AND STATUS = 'o';

-- 21. Izdvojiti ukupan broj položenih predmeta i 
-- položenih espb bodova za studenta sa indeksom 25/2016.

SELECT COUNT(*), SUM(P.ESPB)
FROM DA.ISPIT I JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
WHERE I.STATUS = 'o' AND I.OCENA > 5 AND I.INDEKS = 20160025;

SELECT *
FROM DA.ISPIT I
WHERE I.INDEKS = 20160025;
