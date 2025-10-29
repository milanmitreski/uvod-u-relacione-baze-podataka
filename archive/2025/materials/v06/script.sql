/*
	Uvod u relacione baze podataka - cas 6
	Agregatne funkcije. Klauze GROUP BY i HAVING
*/

/**

	PROSLI CAS:
	
	Zaposleni
	
	ID  |    SEKTOR    |  PLATA
	1 		  IT			2000
	2		  IT			1800
	3 		  Uprava		3000
	4 		  Uprava		2000
	5 		  HR			1500
	6 	      HR 			2200
	
	1. Ukupan broj zaposlenih -- COUNT
	2. Prosecna plata -- AVG
	3. Minimalna plata -- MIN
	4. Maksimalana plata -- MAX
	5. Zbir svih plata (koliko kompanija trosi na zarade) -- SUM
	
	--- ovo se racunalo na osnovu svih redova u tabeli
	
	6. Prosecna zarada po sektorima -- GROUP BY sektor
	
	ID  |    SEKTOR    |  PLATA
	1 		  IT			2000  -- AVG(plata)
	2		  IT			1800
	-----------------------------
	ID  |    SEKTOR    |  PLATA   -- AVG(plata)
	3 		  Uprava		3000
	4 		  Uprava		2000
	------------------------------ 
	ID  |    SEKTOR    |  PLATA
	5 		  HR			1500 -- AVG(plata)
	6 	      HR 			2200
	
	SELECT sektor, AVG(plata) FROM Zaposleni GROUP BY sektor;
	
	Redosled: FROM, WHERE, GROUP BY, SELECT, ORDER BY;
	
	Ako u SELECT klauzi se nalazi neka agregatna funkcija, sve kolone
	koje nisu pod agregatnom funkcijom moraju se nalaziti u GROUP BY.
	
**/

-- 1. Izdvojiti ukupan broj studenata.

SELECT COUNT(*)
FROM DA.DOSIJE;

SELECT COUNT(INDEKS)
FROM DA.DOSIJE;

-- 2. Izdvojiti ukupan broj studenata koji bar iz jednog 
-- predmeta imaju ocenu 10.

SELECT COUNT(DISTINCT INDEKS)
FROM DA.ISPIT
WHERE OCENA = 10 AND STATUS = 'o';

SELECT COUNT(INDEKS)
FROM DA.DOSIJE D
WHERE EXISTS (
	SELECT *
	FROM DA.ISPIT I
	WHERE D.INDEKS = I.INDEKS AND
		I.OCENA = 10 AND
		I.STATUS = 'o'
);

-- 3. Izdvojiti ukupan broj položenih predmeta i položenih 
-- espb bodova za studenta sa indeksom 25/2016.

SELECT COUNT(*) "Broj polozenih ispita", SUM(P.ESPB) "Ostvareni ESPB"
FROM DA.ISPIT I JOIN DA.PREDMET P ON (I.IDPREDMETA = P.ID)
WHERE I.INDEKS = 20160025
	AND I.OCENA > 5
	AND I.STATUS = 'o';

-- 4. Koliko ima različitih ocena dobijenih na ispitima, a 
-- da ocena nije 5.

/**

kol1 -- AVG(kol1) = (5 + 10 + 4 + 3 + 2) / 5 = 4.8 -- preskacu se NULL vrednosti

5
10
4
3
NULL
2

COUNT(*) jedini "racuna" i NULL vrednosti

**/

SELECT COUNT(DISTINCT NULLIF(OCENA, 5))
FROM DA.ISPIT;

SELECT COUNT(DISTINCT OCENA)
FROM DA.ISPIT
WHERE OCENA <> 5;

-- 5. Izdvojiti oznake, nazive i espb bodove predmeta čiji 
-- je broj espb bodova veći od prosečnog broja espb bodova 
-- svih predmeta.

SELECT P1.OZNAKA, P1.NAZIV, P1.ESPB
FROM DA.PREDMET P1
WHERE P1.ESPB > (
	SELECT AVG(P2.ESPB)
	FROM DA.PREDMET P2
);

-- 6. Za svakog studenta upisanog na fakultet 2018. godine, 
-- koji ima bar jedan položen ispit, izdvojiti broj indeksa, 
-- prosečnu ocenu zaokruženu na dve decimale, najmanju ocenu 
-- i najveću ocenu iz položenih ispita.

SELECT D.INDEKS, DECIMAL(AVG(I.OCENA*1.0), 4, 2) "Prosek",
		MIN(I.OCENA) "Najmanja ocena", MAX(I.OCENA) "Najveca ocena"
FROM DA.ISPIT I JOIN DA.DOSIJE D ON (I.INDEKS = D.INDEKS)
WHERE I.OCENA > 5 AND I.STATUS = 'o' AND YEAR(D.DATUPISA) = 2018
GROUP BY D.INDEKS;

-- 7. Izdvojiti naziv predmeta, školsku godinu u kojoj je održan 
-- ispit iz tog predmeta i najveću ocenu dobijenu na ispitima iz 
-- tog predmeta u toj školskoj godini.

SELECT P.NAZIV, I.SKGODINA, COALESCE(MAX(I.OCENA), 5)
FROM DA.PREDMET P JOIN DA.ISPIT I ON (P.ID = I.IDPREDMETA)
GROUP BY P.NAZIV, I.SKGODINA;

-- 8. Za svaki predmet izračunati koliko studenata ga je položilo. 
-- Izdvojite i predmete koje niko nije položio.

SELECT P.NAZIV, COUNT(I.OCENA)
FROM DA.PREDMET P LEFT JOIN DA.ISPIT I ON (
	P.ID = I.IDPREDMETA AND
	I.OCENA > 5 AND
	I.STATUS = 'o'
)
GROUP BY P.NAZIV;

-- 9. Izdvojiti identifikatore predmeta za koje je ispit prijavilo 
-- više od 50 različitih studenata.

SELECT ID
FROM DA.PREDMET P
WHERE 50 < (
	SELECT COUNT(DISTINCT INDEKS)
	FROM DA.ISPIT I
	WHERE I.IDPREDMETA = P.ID
);

-- HAVING klauza == WHERE klauza za agregatne funkcije

SELECT IDPREDMETA
FROM DA.ISPIT
GROUP BY IDPREDMETA
HAVING COUNT(DISTINCT INDEKS) > 50;

-- 10. Za ispitne rokove koji su održani u 2016. godini i u kojima 
-- su svi regularno polagani ispiti i položeni, izdvojiti oznaku 
-- roka, broj položenih ispita u tom roku i broj studenata koji 
-- su položili ispite u tom roku.

SELECT OZNAKAROKA, COUNT(OCENA), COUNT(DISTINCT INDEKS)
FROM DA.ISPIT
WHERE STATUS = 'o' AND SKGODINA = 2016
GROUP BY OZNAKAROKA
HAVING MIN(OCENA) > 5;


-- 11. Za svakog studenta izdvojiti broj indeksa i mesec u kome 
-- je položio više od dva ispita (nije važno koje godine). 
-- Izdvojiti indeks studenta, ime meseca i broj položenih predmeta. 
-- Rezultat urediti prema broju indeksa i mesecu polaganja.

SELECT INDEKS, MONTHNAME(DATPOLAGANJA)
FROM DA.ISPIT
WHERE STATUS = 'o' AND OCENA > 5
GROUP BY INDEKS, MONTHNAME(DATPOLAGANJA)
HAVING COUNT(*) > 2
ORDER BY INDEKS, MONTHNAME(DATPOLAGANJA);

-- 12. Za svaki predmet koji nosi najmanje espb bodova izdvojiti 
-- studente koji su ga položili. Izdvojiti naziv predmeta i ime i 
-- prezime studenta. Ime i prezime studenta izdvojiti u jednoj koloni.
-- Za predmete sa najmanjim brojem espb koje nije položio nijedan 
-- student umesto imena i prezimena ispisati nema.

SELECT P.NAZIV, COALESCE(IME || ' ' || PREZIME, 'nema')
FROM DA.PREDMET P LEFT JOIN DA.ISPIT I ON (P.ID = I.IDPREDMETA AND
											I.OCENA > 5 AND
											I.STATUS = 'o')
					LEFT JOIN DA.DOSIJE D ON (I.INDEKS = D.INDEKS)
WHERE ESPB = (
	SELECT MIN(ESPB)
	FROM DA.PREDMET
);

-- 13. Za svakog studenta koji je položio između 15 i 25 bodova 
-- i čije ime sadrži malo ili veliko slovo o ili a izdvojiti indeks, 
-- ime, prezime, broj prijavljenih ispita, broj različitih predmeta 
-- koje je prijavio, broj ispita koje je položio i prosečnu ocenu. 
-- Rezultat urediti prema indeksu.

-- sledeci cas

-- 14. Izdvojiti parove studenata čija imena počinju na slovo M 
-- i za koje važi da su bar dva ista predmeta položili u istom 
-- ispitnom roku. 

SELECT D1.INDEKS, D2.INDEKS
FROM DA.DOSIJE D1 JOIN DA.DOSIJE D2 ON (
	D1.IME LIKE 'M%' AND D2.IME LIKE 'M%' AND D1.INDEKS < D2.INDEKS
) JOIN DA.ISPIT I1 ON (D1.INDEKS = I1.INDEKS AND
						I1.OCENA > 5 AND I1.STATUS = 'o') 
  JOIN DA.ISPIT I2 ON (D2.INDEKS = I2.INDEKS AND
  						I1.IDPREDMETA = I2.IDPREDMETA AND
  						I1.OZNAKAROKA = I2.OZNAKAROKA AND
  						I1.SKGODINA = I2.SKGODINA AND
  						I2.OCENA > 5 AND I2.STATUS = 'o')
GROUP BY D1.INDEKS, D2.INDEKS
HAVING COUNT(*) > 2;

-- VEZBANJE (ako stignemo - na casu, ako ne - za "domaci") 
-- po materijalima Milana Cugurovica i Ane Vulovic

-- 1. Izdvojiti ukupan broj studenata, leksikografski gledano najmanje
-- ime i najveci broj indeksa studenta iz tabele dosije.

-- 2. Odrediti ukupan broj studenata, broj studenata kojima 
-- je poznat datum diplomiranja i broj razlicitih vrednosti 
-- za mesto rodenja.

-- 3. Za studente koji su nesto polozili, izdvojiti broj indeksa i 
-- ukupan broj skupljenih bodova.

-- 4. Za studenta koji je skupio bar 20 bodova prikazati ukupan 
-- broj skupljenih bodova. Rezultat urediti rastuce po ukupnom 
-- broju skupljenih bodova.

-- 5. Izracunati prosek studentima koji su polozili neki ispit.
-- Rezultat urediti opadajuce po proseku.

-- 6. Za svaki od ispitnih rokova i za svaki polagan predmet u 
-- tom roku odrediti broj uspesnih polaganja. Uzeti u obzir samo 
-- rokove i predmete takve da je u izdvojenom roku bilo polozenih 
-- ispita iz izdvojenog predmeta.

-- 7.  Izdvojiti brojeve indeksa studenata koji su polozili 
-- bar 3 ispita i identifikatore predmeta koje su polozila bar 
-- tri studenta. Sve to uradi u jednom upitu i rezultat urediti 
-- u opadajucem poretku po broju polozenih ispita, odnosno broju 
-- studenata.

-- 8. Za svaki predmet izdvojiti broj studenata koji su ga polagali.
-- Izdvojiti naziv predmeta i broj studenata. Za predmete koje niko 
-- nije polagao izdvojiti 0. Rezultat urediti prema broju studenata 
-- koji su polagali predmet u opadajucem poretku.

-- 9. Za studenta koji je polagao neki ispit izracunati iz koliko 
-- ispita je dobio ocenu 8 i iz koliko ispita je dobio ocenu 9. 
-- Izdvojiti indeks studenta,

-- 10.Izdvojiti informacije o studentima koji su prvi diplomirali 
-- na fakultetu.