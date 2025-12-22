/*
    Uvod u relacione baze podataka - cas 11
    Relaciona algebra.
*/

/*
    TABELE/RELACIJE SA KOJIMA RADIMO:
    
    DOSIJE           PREDMET       ISPITNI_ROK      ISPIT
    ------           -------       ----------       -----
    indeks           id_predmeta   godina_roka      indeks
    ime              sifra         oznaka_roka      id_predmeta
    prezime          naziv         naziv            godina_roka
    mesto_rodjenja   bodovi                         oznaka_roka
    datum_upisa                                     ocena
    datum_rodjenja                                  datum_ispita
                                                    bodovi
*/

/*
    ** RELACIONA ALGEBRA **
    
    Jedna od teorijskih osnova za relacione baze podataka, 
    kao i za upitne jezike. Relacione baze podataka podatke
    koje nazivamo tabelama cuvaju u obliku relacija.
    
    U relacionoj algebri radimo sa relacijama (dosije, predmet
    ispitni_rok, ispit) i na osnovu njih izracunavamo nove relacije
    (Kao sto smo u SQL na osnovu tabela, upitima izracunavali nove
    tabele).
    
    Osnovne operacije:
        
        - PROJEKCIJA (biramo atribute/kolone)
            SINTAKSA: relacija[kol1, kol2,...]
            
        - RESTRIKCIJA (biramo/filtriramo redove)
            SINTAKSA: relacija WHERE uslov
        
        - PROIZVOD (Dekartov proizvod "svaki sa svakim")
            SINTAKSA: rel1 TIMES rel2
            
        - UNIJA
            SINTAKSA: rel1 UNION rel2
        
        - PRESEK
            SINTAKSA: rel1 INTERSECT rel2
            
        - RAZLIKA
            SINTAKSA: rel1 MINUS rel2
            
        - SLOBODNO SPAJANJE (restrikcija proizvoda dve relacije)
            SINTAKSA: (rel1 TIMES rel2) WHERE uslov
            
        - PRIRODNO SPAJANJE (spaja dve relacije po kolonama
                             koje imaju isti NAZIV i TIP)
            SINTAKSA: rel1 JOIN rel2
            
        - DELJENJE ( rel1 ima skupove kolona X i Y
                     rel2 ima skup kolona Y (i ima neke redove)
                     
                     rel1 DELJENO sa rel2 je projekcija 
                        rel1 na kolone iz X onih redova
                        cije su sve kombinacije sa redovima
                        iz rel2 prisutne u rel1)
            SINTAKSA: rel1 DIVIDEBY rel2
*/

-- 1. Izdvojiti oznaku i naziv predmeta.

predmet[sifra, naziv]

-- 2. Izdvojiti podatke o predmetima koji imaju po 6 espb bodova.

predmet
WHERE espb = 6

-- 3. Izdvojiti ime i prezime studenta sa indeksom 25/2014.

(dosije
WHERE indeks=20140025)[ime, prezime]

-- 4. Izdvojiti indeks studenata koji imaju:
--  - ocenu 10 ili 9

(ispit 
WHERE ocena = 10)[indeks]
UNION
(ispit
WHERE ocena = 9)[indeks]

(ispit
WHERE ocena = 9 OR ocena = 10)[indeks]

--  - ocenu 10 i 9

(ispit 
WHERE ocena = 10)[indeks]
INTERSECT
(ispit
WHERE ocena = 9)[indeks]

--  - ocenu 10 a nemaju ocenu 9

(ispit 
WHERE ocena = 10)[indeks]
MINUS
(ispit
WHERE ocena = 9)[indeks]

--  - samo ocene 10.

(ispit 
WHERE ocena = 10)[indeks]
MINUS
(ispit
WHERE ocena != 10)[indeks]

(ispit 
WHERE ocena = 10)[indeks]
MINUS
(ispit
WHERE ocena < 10)[indeks]


-- 5. Pronaći studente koji su upisali fakultet kada je održan neki ispit. 
--    Izdvojiti indeks, ime i prezime studenta.

((dosije TIMES ispit)
WHERE dosije.datum_upisa = ispit.datum_ispita)[dosije.indeks, ime, prezime]

-- 6. Za svakog studenta izdvojiti podatke o ispitima koje je polagao. 
--    Izdvojiti indeks, ime, prezime studenta, identifikator predmeta 
--    i ocenu koju je dobio.

((ispit TIMES dosije
WHERE dosije.indeks = ispit.indeks)
[dosije.indeks, ime, prezime, ispit.id_predmeta, ispit.ocena]

(ispit JOIN dosije)
[indeks, ime, prezime, id_predmeta, ocena]

-- 7. Izdvojiti identifikatore predmeta koje su polagali svi studenti.

ispit[id_predmeta, indeks]
DIVIDEBY
dosije[indeks]

-- 8. Izdvojiti parove predmeta koji imaju isti broj bodova. 
--    Izdvojiti šifre i nazive predmeta.

DEFINE ALIAS predmet1 FOR predmet
DEFINE ALIAS predmet2 FOR predmet
((predmet1 TIMES predmet2)
WHERE predmet1.bodovi = predmet2.bodovi
    AND predmet1.id_predmeta < predmet2.id_predmeta)
[predmet1.sifra, predmet1.naziv, predmet2.sifra, predmet2.naziv]

-- 9. Izdvojiti nazive ispitnih rokova u kojima je 
--    polozen predmet Analiza 1.

(((predmet
WHERE naziv = 'Analiza 1')[id_predmeta]
JOIN
(ispit
WHERE ocena > 5))
JOIN
ispitni_rok)[naziv]

-- 10. Izdvojiti indekse studenata koji nisu polagali ispite 
--     u ispitnom roku sa oznakom apr.

dosije[indeks]
MINUS
(ispit
WHERE oznaka_roka='apr')[indeks]

-- 11. Pronaći ispitni rok u kome su isti predmet polagali svi studenti. 
--     Izdvojiti šk. godinu roka, oznaku roka i identifikator predmeta.

ispit[godina_roka, oznaka_roka, id_predmeta, indeks]
DIVIDEBY
dosije[indeks]

-- 12. Izdvojiti identifikatore predmeta koji imaju više od 5 bodova
--     ili ih je položio neki student 20.01.2015.

(predmet
WHERE bodovi > 5)[id_predmeta]
UNION
(ispit
WHERE ocena > 5 AND datum_ispita='20.01.2015')[id_predmeta]

-- 13. Izdvojiti identifikatore predmeta koji imaju više od 5 bodova i 
--     nije ih položio neki student 20.01.2015.

(predmet
WHERE bodovi > 5)[id_predmeta]
MINUS
(ispit
WHERE ocena > 5 AND datum_ispita='20.01.2015')[id_predmeta]

-- 14. Pronaći predmet sa najvećim brojem espb bodova. 
--     Izdvojiti naziv i broj espb bodova predmeta.

DEFINE ALIAS p1 FOR predmet
DEFINE ALIAS p2 FOR predmet
DEFINE ALIAS p3 FOR predmet
p3[naziv, bodovi]
MINUS
((p1 TIMES p2)
WHERE p1.bodovi < p2.bodovi)[p1.naziv, p1.bodovi]

-- 15. Pronaći studenta koji je u jednoj šk. godini položio sve predmete. 
--     Izdvojiti šk. godinu i indeks.

(ispit
WHERE ocena > 5)[indeks, godina_roka, id_predmeta]
DIVIDEBY
predmet[id_predmeta]
