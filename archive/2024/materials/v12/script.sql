/*
    Uvod u relacione baze podataka - cas 12
    Relacioni racun.
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
    ** RELACIONI RACUN **
    
    Slicno relacionoj algebri, jedan od matematickih formalizama
    iza relacionih baza podataka i upitnih jezika. Za razliku
    od relacione algebre, u kojoj je centralni pojam bila RELACIJA
    i sve se radilo nad relacijama, ovde je centralni pojam N-TORKA
    ciji je domen tj. RANGE jednak nekoj relaciji
    
    Pre uvodjenja operacija u relacionom racunu, moraju se uvesti
    n-torke pomocu kojih radimo
    
    RANGE OF n-torka IS relacija
        (npr. RANGE OF px IS predmet -> ovo znaci da n-torku
                                        px uzimamo iz relacije predmet)
                                        
    Osnovne operacije:
        
        - PROJEKCIJA
            SINTAKSA: RANGE OF red IS relacija
                      red.kol1, red.kol2, ...
        
        - RESTRIKCIJA
            SINTAKSA: RANGE OF red IS relacija
                      red.X
                      WHERE ...
            
        - PROIZVOD (Dekartov prozivod)
            SINTAKSA: RANGE OF red1 IS relacija1
                      RANGE OF red2 IS relacija2
                      
        - EXISTS red (uslov) -> navedeni uslov mora vaziti
                                barem za jedan red
                              
        - FORALL red (uslov) -> navedeni uslov mora vaziti
                                za sve redove
                                
            FORALL red (uslov) <=> NOT EXISTS red (NOT uslov)
        
        - IMPLIKACIJA
            SINTAKSA: IF uslov1 THEN uslov2
            
        Napomena: Ako radimo nad dve tabele, na primer predmet i ispit. 
        U rezultatu možemo izdvojiti samo kolone iz na primer predmeta, 
        ali onda kolone iz ispita ne možemo imati u where. Da bi u ovom
        slučaju gli da koristimo kolone iz where potrebno je da ispisujemo
        bar jednu kolonu iz tabele ispit (ne nužno onu koju koristimo) 
        ili da koristimo exists/forall.
            
*/

-- 1. Prikazati oznaku i naziv predmeta.

RANGE OF px IS predmet
px.sifra, px.naziv

-- 2. Prikazati podatke o predmetima koji imaju po 6 espb bodova.

RANGE OF px IS predmet
px.id_predmeta, px.sifra, px.naziv, px.bodovi
WHERE px.bodovi = 6

-- ovo je validno, ali ne prolazi RARRChecker
RANGE OF px IS predmet
px.*
WHERE px.bodovi = 6

-- 3. Za svakog studenta izdvojiti podatke o polaganim ispitima. 
--    Izdvojiti indeks studenta, naziv polaganog predmeta i 
--    ocenu koju je dobio.

RANGE OF ix IS ispit
RANGE OF px IS predmet
ix.indeks, px.naziv, ix.ocena
WHERE ix.id_predmeta = px.id_predmeta

-- 4. Izdvojiti parove predmeta koji imaju isti broj bodova. 
--    Izdvojiti oznake i nazive predmeta.

RANGE OF px IS predmet
RANGE OF py IS predmet
px.sifra, px.naziv, py.sifra, py.naziv
WHERE px.bodovi = py.bodovi AND px.id_predmeta < py.id_predmeta

-- 5. Izdvojiti oznake i nazive predmeta 
--    koje je položio student sa indeksom 26/2014.

RANGE OF px IS predmet
RANGE OF ix IS ispit
px.sifra, px.naziv
WHERE EXISTS ix (ix.id_predmeta = px.id_predmeta 
    AND ix.indeks = 20140026
    AND ix.ocena > 5)

-- 6. Izdvojiti indekse studenata koji su polagali sve predmete.

RANGE OF ix IS ispit
RANGE OF px IS predmet
RANGE OF dx IS dosije
dx.indeks
WHERE FORALL px (
    EXISTS ix (
        ix.id_predmeta = px.id_predmeta AND
        ix.indeks = dx.indeks
    )
)

-- 7. Izdvojiti nazive predmeta koje su polagali svi studenti.

RANGE OF ix IS ispit
RANGE OF dx IS dosije
RANGE OF px IS predmet
px.naziv
WHERE FORALL dx (
    EXISTS ix (
        ix.indeks = dx.indeks AND
        ix.id_predmeta = px.id_predmeta
    )
)

-- 8. Izdvojiti nazive predmeta koji imaju po 6 espb bodova i
--    koje je polagao student sa prezimenom Vukovic.

RANGE OF ix IS ispit
RANGE OF dx IS dosije
RANGE OF px IS predmet
px.naziv
WHERE px.bodovi = 6
    AND EXISTS dx (
        dx.prezime = 'Vukovic' AND
        EXISTS ix (
            ix.indeks = dx.indeks AND
            ix.id_predmeta = px.id_predmeta
        )
    )

-- 9. Izdvojiti indekse studenata koji su položili bar sve predmete 
--    koje je položio student sa indeksom 25/2014.

RANGE OF ix IS ispit
RANGE OF px IS predmet
RANGE OF dx IS dosije
dx.indeks
WHERE FORALL px (
    IF EXISTS ix (
        ix.id_predmeta = px.id_predmeta AND
        ix.ocena > 5 AND
        ix.indeks = 20140025
    ) THEN EXISTS ix (
        ix.id_predmeta = px.id_predmeta AND
        ix.ocena > 5 AND
        ix.indeks = dx.indeks
    )
)

-- 10. Izdvojiti indeks, ime i prezime studenta 
--     koji je položio samo Programiranje 1.

RANGE OF px IS predmet
RANGE OF ix IS ispit
RANGE OF iy IS ispit
RANGE OF dx IS dosije
dx.indeks, dx.ime, dx.prezime
WHERE EXISTS ix (
    ix.indeks = dx.indeks AND
    ix.ocena > 5 AND
    EXISTS px (
        px.naziv = 'Programiranje 1' AND
        px.id_predmeta = ix.id_predmeta
    ) AND
    NOT EXISTS iy (
        iy.indeks = dx.indeks AND
        iy.id_predmeta <> ix.id_predmeta
    )
)


RANGE OF px IS predmet
RANGE OF ix IS ispit
RANGE OF iy IS ispit
RANGE OF dx IS dosije
dx.indeks, dx.ime, dx.prezime
WHERE EXISTS ix (
    ix.indeks = dx.indeks AND
    ix.ocena > 5 AND
    EXISTS px (
        px.naziv = 'Programiranje 1' AND
        px.id_predmeta = ix.id_predmeta
        AND NOT EXISTS iy (
            iy.indeks = dx.indeks AND
            iy.id_predmeta <> px.id_predmeta
        )
    )
)

-- 11. Pronaći predmet sa najvećim brojem espb bodova. 
--     Izdvojiti naziv i broj espb bodova predmeta.

RANGE OF px IS predmet
RANGE OF py IS predmet
px.naziv, px.bodovi
WHERE NOT EXISTS py (py.bodovi > px.bodovi)

-- 12. Pronaći studente koji su položili neki predmet od 6 espb bodova. 
--     Izdvojiti indeks, ime, prezime i naziv predmeta.

RANGE OF dx IS dosije
RANGE OF px IS predmet
RANGE OF ix IS ispit
dx.indeks, dx.ime, dx.prezime, px.naziv
WHERE px.bodovi = 6 AND EXISTS ix (
    ix.indeks = dx.indeks AND
    ix.ocena > 5 AND
    ix.id_predmeta = px.id_predmeta
)

RANGE OF dx IS dosije
RANGE OF px IS predmet
RANGE OF ix IS ispit
ix.indeks, dx.ime, dx.prezime, px.naziv
WHERE px.bodovi = 6 AND
    ix.indeks = dx.indeks AND
    ix.ocena > 5 AND
    ix.id_predmeta = px.id_predmeta

-- 13. Pronaći studenta koji je u jednoj školskoj 
--     godini položio sve predmete. Izdvojiti školsku godinu i indeks. 

RANGE OF ix IS ispit
RANGE OF iy IS ispit
RANGE OF px IS predmet
ix.indeks, ix.godina_roka
WHERE FORALL px (
    EXISTS iy (
        px.id_predmeta = iy.id_predmeta AND
        ix.indeks = iy.indeks AND
        ix.godina_roka = iy.godina_roka AND
        iy.ocena > 5
    )
)

RANGE OF dx IS dosije
RANGE OF irx IS ispitni_rok
RANGE OF ix IS ispit
RANGE OF px IS predmet
dx.indeks, irx.godina_roka
WHERE FORALL px (
    EXISTS ix (
        px.id_predmeta = ix.id_predmeta AND
        dx.indeks = ix.indeks AND
        irx.godina_roka = ix.godina_roka AND
        ix.ocena > 5
    )
)
