/*
	Uvod u relacione baze podataka - cas 4 
    Skupovni operatori. Skalarne funkcije 
*/

-- Podsecanje:

--- 1. Podupiti

--- Podupiti su upiti koji se nalaze u okviru drugog, veceg upita.
--- Podupiti mogu biti korelisani i nekorelisani.

--- Korelisani podupiti su podupiti koji se ne mogu izvrsavati
--- samostalno. (U korelaciji su sa upitom u kom se nalaze)

--- Nekorelisani podupiti su podupiti koji se mogu izvrsavati 
--- samostalno. (Nisu u korelaciji sa upitom u kom se nalaze)

--- Primer: Izdvojiti ime i prezime studenta koji ima 
--- ispit položen sa ocenom 9.

--- Resenje sa korelisanim podupitom: 
	SELECT IME, PREZIME, INDEKS
	FROM DA.DOSIJE AS D
	WHERE 9 IN (
		SELECT OCENA
		FROM DA.ISPIT AS I
		WHERE D.INDEKS = I.INDEKS -- ovde vidimo korelisanost
								  -- koristimo D.INDEKS 
								  -- iz spoljasnjeg upita
		AND STATUS = 'o'
	); -- znacenje samog podupita:
	   -- Za sve polagane ispite koje je polagao student
	   -- sa indeksom D.INDEKS izdvojiti dobijene ocene
	   -- (sta bi bila vrednost D.INDEKS ako bi pokrenuli
	   -- ovaj podupit sam po sebi?)
	
--- Resenje sa nekorelisanim podupitom:
	SELECT IME, PREZIME
	FROM DA.DOSIJE
	WHERE INDEKS IN (
		SELECT INDEKS
		FROM DA.ISPIT I
		WHERE OCENA=9 AND STATUS='o'
	); -- znacenje samog podupita:
	   -- Za sve polozene ispite sa ocenom 9, izdvojiti indekse
	   -- (jasno je da ovaj podupit mozemo izvrsiti samostalno)

	SELECT DISTINCT D.IME, D.PREZIME, D.INDEKS
	FROM DA.DOSIJE D JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS)
	WHERE I.OCENA = 9 AND I.STATUS = 'o';

-- 2. Spajanja tabela

--- Spajanje tabela A (sa kolonama a1 ... an) 
--- i B (sa kolonama b1....bm) podrazumeva konstruisanje nove tabele
--- sa kolonama a1...an, b1...bm pri cemu se redovi iz tabele A
--- spajaju sa redovima iz tabele B. U zavisnosti od toga
--- kako se redovi spajaju, imamo vise vrsta spajanja:

--- Potpuno spajanje (CROSS JOIN)

---- Podrazumeva da se svaki red iz tabele A spoji sa svakim redom
---- iz tabele B. Primer: (izvrsiti sve tri naredbe zajedno)
	 VALUES (1,2), (2,3);
	 
	 VALUES ('ab', CURRENT_DATE), 
     	  		  ('bc', CURRENT_DATE - 1 YEAR),
     	  		  ('cd', CURRENT_DATE + 1 YEAR);
	 
	 SELECT *
	 FROM (VALUES (1,2), (2,3)) CROSS JOIN 
     	  (VALUES ('ab', CURRENT_DATE), 
     	  		  ('bc', CURRENT_DATE - 1 YEAR),
     	  		  ('cd', CURRENT_DATE + 1 YEAR));

--- Unutrasnje spajanje (INNER JOIN ili samo JOIN)

---- Podrazumeva da se svaki red iz tabele A spoji sa onim redovima
---- iz tabele B koji zadovoljavaju dati uslov spajanja.

---- Redovi iz tabele A (odnosno tabele B) koji ne mogu da se spoje
---- sa nijednim redom iz tabele B (odnosno tabele A) se ne nalaze
---- u rezultatu spajanja.

---- Primer:

	SELECT DISTINCT D.INDEKS
	FROM DA.DOSIJE D JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS)
	WHERE D.INDEKS < 20160000;
    --- mozemo primetiti da ovde ne postoji indeks 20150338
    
    SELECT *
    FROM DA.DOSIJE WHERE INDEKS = 20150338;
    --- medjutim on postoji u tabeli dosije
    
    --- zasto se ne nalazi u spajanju?
    SELECT *
    FROM DA.ISPIT WHERE INDEKS = 20150338;
    --- pa jer nema nijednog polaganja!
    
--- Spoljasnje spajanje (LEFT/RIGHT/FULL (OUTER) JOIN)

---- Podrazumeva da se svaki red iz tabele A spoji sa onim redovima
---- iz tabele B koji zadovoljavaju dati uslov spajanja.

---- U zavisnosti od izabrane opcije, spoljasnje spajanje ce redove
---- iz jedne od tabela koje ne mogu da se spoje sa nijednim 
---- redom iz druge tabele spojiti sa redom koji ima sve NULL vrednosti

---- Ako spajamo tabelu A sa tabelom B komandom LEFT OUTER JOIN tada
---- redove iz A koji se ne mogu spojiti ni sa jednim redom iz B
---- spajamo sa redom koji ima sve NULL vrednost (za kolone b1...bm)

---- Ako spajamo tabelu A sa tabelom B komandom RIGHT OUTER JOIN tada
---- redove iz B koji se ne mogu spojiti ni sa jednim redom iz A
---- spajamo sa redom koji ima sve NULL vrednost (za kolone a1...an)

---- Ako spajamo tabelu A sa tabelom B komandom FULL OUTER JOIN tada
---- redove iz A koji se ne mogu spojiti ni sa jednim redom iz B
---- spajamo sa redom koji ima sve NULL vrednost (za kolone b1...bm)
---- i redove iz B koji se ne mogu spojiti ni sa jednim redom iz A
---- spajamo sa redom koji ima sve NULL vrednost (za kolone a1...an)

---- Primer: (samo za LEFT OUTER JOIN, ostale dve verzije su
---- samo male modifikacije)

	SELECT DISTINCT D.INDEKS, I.INDEKS
	FROM DA.DOSIJE D LEFT OUTER JOIN DA.ISPIT I 
	ON (D.INDEKS = I.INDEKS)
	WHERE D.INDEKS < 20160000;
	--- Redovi koji su spojeni sa NULL kolonama se na dnu
	--- Primetiti da se tu nalazi i student sa indeksom 20150338
	
/*** SKUPOVNI OPERATORI ***/ 

--- 1. UNION - unija

---- zadatak 1. Izdvojiti indekse studenata koji su rodjeni u Beogradu ili
---- imaju ocenu 10. Rezultat urediti u opadajucem poretku.

SELECT DISTINCT D.INDEKS
FROM DA.DOSIJE D LEFT OUTER JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS)
WHERE MESTORODJENJA = 'Beograd' OR (I.OCENA = 10 AND I.STATUS = 'o')
ORDER BY D.INDEKS DESC;

SELECT INDEKS
FROM DA.DOSIJE
WHERE MESTORODJENJA = 'Beograd'
UNION -- operator uniranja
SELECT INDEKS -- iako u ovom delu se moze jedan indeks pojaviti vise puta
		      -- UNION svakako ne zadrzava duplikate, pa kada ga koristimo
		      -- ne moramo da vodimo racuna o DISTINCT-u
FROM DA.ISPIT
WHERE OCENA = 10 AND STATUS = 'o'
ORDER BY INDEKS DESC;

---- UNION ALL -- ne sklanja duplikate, tj. ako prva tabela ima n istih redova
---- a druga tabela m istih takvih redova, tada rezultujuca tabela ima
---- m+n istih redova

VALUES (1, 2), (1, 2)
UNION ALL
VALUES (1, 2), (1, 2), (1, 2); -- ovo ima 5 redova oblika (1, 2)

--- 2. INTERSECT - presek

---- zadatak 2. Izdvojiti indekse studenata koji su rodjeni u Beogradu i
---- imaju ocenu 10. Rezultat urediti u opadajucem poretku

SELECT DISTINCT D.INDEKS
FROM DA.DOSIJE D JOIN DA.ISPIT I ON (D.INDEKS = I.INDEKS)
WHERE MESTORODJENJA = 'Beograd' AND (I.OCENA = 10 AND I.STATUS = 'o')
ORDER BY D.INDEKS DESC;

SELECT INDEKS
FROM DA.DOSIJE
WHERE MESTORODJENJA = 'Beograd'
INTERSECT
SELECT INDEKS
FROM DA.ISPIT
WHERE OCENA = 10 AND STATUS = 'o'
ORDER BY INDEKS DESC;

---- zadatak 3. Izdvojiti indekse studenata koji imaju ocenu 8 i
---- koji imaju ocenu 10

SELECT INDEKS
FROM DA.ISPIT
WHERE OCENA = 8 AND STATUS = 'o'
INTERSECT -- sklanja duplikate
SELECT INDEKS
FROM DA.ISPIT
WHERE OCENA = 10 AND STATUS = 'o'
ORDER BY INDEKS DESC;

---- INTERSECT ALL -- ne sklanja duplikate, tj. ako prva tabela ima n istih redova
---- a druga tabela m istih takvih redova, tada rezultujuca tabela ima
---- min{n,m} istih redova

VALUES (1, 2), (1, 2), (1, 2)
INTERSECT ALL
VALUES (1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2);

--- 3. EXCEPT -- razlika

---- zadatak 4. Izdvojiti indekse studenata koji su rodjeni u Beogradu i
---- i nisu dobili ocenu 10 na nekom ispitu. Rezultat urediti u opadajucem poretku

SELECT INDEKS 
FROM DA.DOSIJE 
WHERE MESTORODJENJA = 'Beograd'
INTERSECT
SELECT D.INDEKS
FROM DA.DOSIJE D
WHERE NOT EXISTS(
	SELECT *
	FROM DA.ISPIT I
	WHERE I.OCENA = 10 AND I.STATUS = 'o' AND I.INDEKS = D.INDEKS
);

SELECT INDEKS
FROM DA.DOSIJE
WHERE MESTORODJENJA = 'Beograd'
EXCEPT
SELECT INDEKS
FROM DA.ISPIT
WHERE OCENA = 10 AND STATUS = 'o'
ORDER BY INDEKS DESC;

---- EXCEPT ALL - ne sklanja duplikate, tj. ako prva tabela ima n istih redova
---- a druga tabela m istih takvih redova, tada rezultujuca tabela ima
---- max{0, n-m} istih redova


VALUES (1, 2), (1, 2), (1, 2), (1, 2)
EXCEPT ALL
VALUES (1, 2), (1, 2);

VALUES (1, 2), (1, 2), (1, 2), (1, 2)
EXCEPT ALL
VALUES (1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2);


/*** SKALARNE FUNKCIJE ***/

VALUES (CURRENT_TIME, CURRENT_DATE, NOW);

VALUES (DATE('20.03.2022'), DATE('03/20/2022'), DATE('2022-03-20'));

VALUES (DAYNAME(CURRENT_DATE, 'sr_cirilc_sr'));

VALUES (SUBSTR('1234', 1, 2));

VALUES (DECIMAL(200, 5, 3));

VALUES (DECIMAL(200));

SELECT DECIMAL(200, 6, 3)
FROM SYSIBM.SYSDUMMY1;

SELECT *
FROM SYSIBM.SYSDUMMY1;


