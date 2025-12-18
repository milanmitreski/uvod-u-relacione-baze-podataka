/*
	Uvod u relacione baze podataka - cas 5
	Skalarne funkcije (nastavak). CASE izraz.
	Funkcije za rad sa nedefinisanim vrednostima.
	Agregatne funkcije
*/
/*** Skalarne funkcije (nastavak) ***/

-- 1. Izračunati koji je dan u nedelji (njegovo ime) bio 3.11.2019.

SELECT DAYNAME('03.11.2019')
FROM SYSIBM.SYSDUMMY1; /** sta je SYSIBM.SYSDUMMY1 **/

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

SELECT SECOND(CURRENT_TIME)
FROM SYSIBM.SYSDUMMY1;

-- 4. Izračunati koliko vremena je prošlo između 6.8.2005. 
-- i 11.11.2008. 

SELECT DATE('11.11.2018') - DATE('06.08.2005') /** sta je razlika dva datuma **/
FROM SYSIBM.SYSDUMMY1;

-- 5. Izračunati koji će datum biti za 12 godina, 5 meseci i 25 dana. 

SELECT CURRENT_DATE + 12 YEARS + 5 MONTH + 25 DAYS
FROM SYSIBM.SYSDUMMY1;

-- 6. Izdvojiti ispite koji su održani posle 28. septembra 
-- 2020. godine. 

SELECT *
FROM DA.ISPIT
WHERE DATPOLAGANJA > DATE('28.09.2020');

-- 7. Pronaći ispite koji su održani u poslednjih 8 meseci.

SELECT *
FROM DA.ISPIT
WHERE MONTHS_BETWEEN(CURRENT_DATE, DATPOLAGANJA) < 8;

-- 8. Za sve ispite koji su održani u poslednjih 5 godina 
-- izračunati koliko je godina, meseci i dana prošlo od 
-- njihovog održavanja. Izdvojiti indeks, naziv predmeta, 
-- ocenu, broj godina, broj meseci i broj dana. 

SELECT I.INDEKS, 
       P.NAZIV, 
       I.OCENA,
       YEAR(CURRENT_DATE - I.DATPOLAGANJA) AS GODINE,
       MONTH(CURRENT_DATE - I.DATPOLAGANJA)AS MESECI,
       DAY(CURRENT_DATE - I.DATPOLAGANJA) AS DANI
FROM DA.ISPIT I JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
WHERE CURRENT_DATE - I.DATPOLAGANJA < 50000;

-- 9. Prikazati trenutno vreme i trenutni datum u
--    - ISO formatu
--    - USA formatu
--    - EUR formatu.

SELECT CHAR(CURRENT_DATE, ISO),
	   CHAR(CURRENT_DATE, USA),
	   CHAR(CURRENT_DATE, EUR)
FROM SYSIBM.SYSDUMMY1;


-- 10. Ako je predmetima potrebno uvećati broj espb bodova za 20% 
-- prikazati koliko će svaki predmet imati espb bodova nakon uvećanja.
-- Uvećani broj bodova prikazati sa dve decimale.

SELECT DECIMAL(1.2*ESPB, 4, 2)
FROM DA.PREDMET;

-- 11. Ako je predmetima potrebno uvećati broj espb bodova za 20% 
-- prikazati koliko će espb bodova imati predmeti koji nakon uvećanja
-- imaju više od 8 bodova. Uvećani broj espb bodova zaokružiti na 
-- veću ili jednaku celobrojnu vrednost.

SELECT CEIL(ESPB*1.2) UVECANO
FROM DA.PREDMET
WHERE ESPB*1.2 > 8;


-- 12. Pronaći indekse studenata koji su jedini položili ispit 
-- iz nekog predmeta sa ocenom 10. Za studenta sa brojem 
-- indeksa GGGGBBBB izdvojiti indeks u formatu BBBB/GGGG.

SELECT SUBSTR(CHAR(INDEKS), 5, 4) || '/' || SUBSTR(CHAR(INDEKS), 1, 4)
FROM DA.ISPIT I1
WHERE OCENA = 10 AND STATUS = 'o' AND NOT EXISTS (
	SELECT *
	FROM DA.ISPIT I2
	WHERE I1.INDEKS <> I2.INDEKS AND OCENA = 10
	AND STATUS = 'o' AND I1.IDPREDMETA = I2.IDPREDMETA
);

/*** CASE izraz ***/

-- 13. Za svaki polagan ispit izdvojiti indeks, identifikator 
-- predmeta i dobijenu ocenu. Vrednost ocene ispisati i slovima. 
-- Ako je predmet nepoložen umesto ocene ispisati nepolozen.

SELECT I.INDEKS, P.OZNAKA, OCENA,
		CASE OCENA
			WHEN 10 THEN 'deset'
			WHEN 9 THEN 'devet'
			WHEN 8 THEN 'osam'
			WHEN 7 THEN 'sedam'
			WHEN 6 THEN 'sest'
			ELSE 'nepolozen'
		END OCENA_SLOVIMA
FROM DA.ISPIT I JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
WHERE I.STATUS NOT IN ('p', 'n');

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
	   		WHEN ESPB BETWEEN 10 AND 15 THEN 'II'
	   		ELSE 'III'
	   END KATEGORIJA
FROM DA.PREDMET;

-- 15. Izdvojiti indeks, ime, prezime, mesto rođenja i 
-- inicijale studenata. Ime i prezime napisati u jednoj koloni, 
-- a za studente rođene u Beogradu kao mesto rođenja ispisati Bg.

SELECT IME || ' ' ||  PREZIME AS "ImePrezime",
       CASE
       	WHEN MESTORODJENJA LIKE '%Beograd%' THEN 'Bg'
       	ELSE MESTORODJENJA
       END AS "mesto rodjenja",
       SUBSTR(IME, 1, 1) || '. ' || SUBSTR(PREZIME, 1, 1) || '.' AS INICIJALI
FROM DA.DOSIJE;

/*** Funkcije za rad sa nedefinsanim vrednostima ***/

-- 16. Izlistati ocene dobijene na ispitima i ako je ocena jednaka 5 
-- ispisati NULL. 

SELECT OCENA, NULLIF(OCENA, 5)
FROM DA.ISPIT
ORDER BY OCENA;

-- 17. Izdvojiti indeks, ime, prezime i mesto rodenja za svakog 
-- studenta.  Ako je mesto rodenja ’Sabac’, prikazati NULL.

SELECT INDEKS, IME, PREZIME, NULLIF(MESTORODJENJA, 'Sabac')
FROM DA.DOSIJE;

-- 18. Izdvojiti indeks, ime, prezime i mesto rodenja za svakog 
-- studenta.  Ako je mesto rodenja nepoznato, umesto NULL vrednosti
-- ispisati “Nepoznato”.

SELECT INDEKS, IME, PREZIME, COALESCE(MESTORODJENJA, 'Nepoznato')
FROM DA.DOSIJE;
