# Uvod u relacione baze podataka, 2025/2026

Obavezan kurs na četvrtoj godini Matematičkog fakulteta, za studente modula Matematika i računarstvo\
Profesor: [prof. dr Saša Malkov](http://poincare.matf.bg.ac.rs/~sasa.malkov)\
Asistent: [Milan Mitreski](http://poincare.matf.bg.ac.rs/~milan.mitreski)

## Ispitne obaveze

U toku semestra biće organizovana dva kolokvijuma koji predstavljaju predispitne obaveze. Oba kolokvijuma biće moguće nadoknaditi i to:

1. Prvi kolokvijum u ispitnim rokovima Januar 1, Jun 1 i Septembar 1.
2. Drugi kolokvijum u ispitnim rokovima Januar 2, Jun 2 i Septembar 2.

Uslov za uspešno polaganje predispitnih obaveza (tj. za izlazak na usmeni ispit) jeste 50% od ukupnog broja poena koje je moguće ostvariti na kolokvijumima. Moguće je polagati drugi kolokvijum i bez izlaska na prvi kolokvijum.

### Prvi kolokvijum

Na prvom kolokvijumu moguće je ostvariti najviše 30 poena. Na prvom kolokvijumu radiće se 3 zadatka u SQL i obuhvataće prvih 6 časova vežbi.

### Drugi kolokvijum

Na drugom kolokvijumu moguće je ostvariti najviše 50 poena. Na drugom kolokvijumu izrađuju se zadaci iz teorije kao i zadaci sa vežbi od 7 nedelje pa do kraja kursa. Detaljna struktura drugog kolokvijuma biće naknadno saopštena.

## Konsultacije

Po dogovoru, putem mejla na [milan.mitreski@matf.bg.ac.rs](mailto:milan.mitreski@matf.bg.ac.rs).

## Obrađene teme na kursu

1. Uvod u upitni jezik `SQL` (klauze `SELECT, FROM, WHERE`). Klauza `ORDER BY`.
2. Spajanje tabela (naredba `JOIN`). Nedefinsane (`NULL`) vrednosti 
3. Podupiti. Korelisan i nekorelisan podupit.
4. Skupovni operatori `UNION (ALL), INTERSECT (ALL), EXCEPT (ALL)`. Skalarne funkcije.
5. Funkcije za rad sa nedefinisanim vrednostima. `CASE` izraz.
6. Agregatne funkcije (`COUNT, SUM, AVG, MIN, MAX`). Klauze `GROUP BY` i `HAVING`
7. Složeni `SQL` upit. Pomoćne tabele (`WITH` naredba).
8. Jezik za definisanje podataka (DDL, naredbe `CREATE, ALTER, DROP`). Jezik za manipulaciju podataka (DML, naredbe `INSERT INTO, UPDATE, DELETE FROM`). 
9. Pogledi (`VIEW`). Indeksi (`INDEX`). Korisnički definisane funkcije (`FUNCTION`).
10. `MERGE` naredba. Okidači (`TRIGGER`).
11. Relaciona algebra. Relacioni račun.
12. Vežbanje
13. Vežbanje

## Instalacije

Potrebno je instalirati **JetBrains DataGrip** integrisano razvojno okruženje (besplatna licenca uz studentski nalog sa Alasa) i **Docker** alat za kontejnerizaciju. Potom je potrebno povući sliku **ibmcom/db2** i preuzeti bazu **stud2020**. Baza se može preuzeti [ovde](https://poincare.matf.bg.ac.rs/~milan.mitreski/nastava/urbp/docker.pdf), a detaljno uputstvo za instalaciju i podešavanje može se naći [ovde](https://poincare.matf.bg.ac.rs/~milan.mitreski/nastava/urbp/docker.pdf).

Uputstvo i baza preuzeti su sa sajta koleginice Milice Gnjatović.
