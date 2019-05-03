# slutprojektvt19webbserver

# Projektplan

## 1. Projektbeskrivning
En sida där man kan slumpa fram D&D-karaktärer. Man ska ha ett konto där man kan se sina egna karaktärer och man ska även kunna se andras karaktärer. Man ska även kunna dela karaktärer med andra användare. 
## 2. Vyer (sidor)
### Start
Startsidan för hemsidan. Det är här man loggar in eller gör sitt konto. 

### Hem
  Här får man se alla sina egna karaktärer och även andras karaktärer. Det är också här man kan göra sin karaktär. 
  
### Se specifik karaktär
  Här kan man se en karaktär i mer detalj. Man kan antingen se en av sina egna eller en som tillhör en annan person. Om man ser en som man har äganedrätt till karaktären så kan man göra om den, dela den med en annnan användare och radera den. 
## 3. Funktionalitet (med sekvensdiagram)
<!-- TODO: alla diagram -->
### Inloggning
![Sekvens-Login](https://github.com/itggot-markus-moen/slutprojektvt19webbserver/tree/master/misc/Sekvens-Login.jpg)
  Man kan skriva in ett användarnamn och ett löseond och välja om man vill logga in eller om man vill göra ett konto. Om man väljer att göra ett konto så kontrollerar servern att användarnamnet är unikt och om det är det så läggs uppgifterna in i databasen. Om man väljer att logga in kontrollerar servern att lösenordet stämmer med användarnamnet. Om det inte stämmer så får man ett felmeddelande. Om det stämmer så loggas man in och skickas vidare till hemsidan. 

###Karaktärslistning
  Alla karaktärer kan listas upp och de är sorterade i de som personen som är inloggad äger och de som personen inte äger. 

### Skapa en karaktär
![Sekvens-Skapande](https://github.com/itggot-markus-moen/slutprojektvt19webbserver/tree/master/misc/Sekvens-Skapande.jpg)
  Man kan slumpa karaktärer. Man skriver in ett namn och resten får man slumpat. Denna karaktär listat bland alla andra karaktärer. När karaktären är skapad så kan man även välja att slumpa om den. Den har då samma namn men resten slumpas om. 

###Visa karaktär
  Man kan gå in på alla karaktärer, även de som man inte äger, och se mer detaljer om dem. 

### Radera karaktär
  Om man har äganderätt så kan man radera en karaktär. 

### Dela karaktär
  Om man har äganderätt så kan man dela en karaktär med en annan användare. De kan då också slumpa om och radera karaktären. 
## 4. Arkitektur (Beskriv filer och mappar)
  db - mappen för databasen
  db.db - själva databasen. 
  
  misc - i den här mappen liger sådant som är relevant för projektet men som inte används av koden på något sätt, främst bilder på diagram och liknande. 
  
  public - mappen där filer som skulle vara tillgängliga till alla besökare på sidan skulle ligga. Just nu fyller den ingen funktion, men om css skulle läggas till så skulle det vara här. 

  views - det här är mappen för alla slim-filer. 
  home.slim - det här är filen för hemsidan, där där man kommer när man har loggat in. 
  index.slim - detta är filen för sidan som man kommer till först. Den används för inloggningssystemet. 
  layout.slim - filen med layouten för sidan. 
  view.slim - detta är sidan där man får se en karaktär i detalj. 

  Controller.rb - filen med alla routes. 

  model.rb - det här är filen som används för funktioner, som främst kommunicerar med databasen. 

## 5. (Databas med ER-diagram)
  Classes - Listar alla klasser. 
  Subclasses - Listar alla subclasser och klassen som de tillhör. 
  Races - Listar alla raser. 
  Subraces - Listar alla subraser och raserna som de tillhör. 
  Backgrounds - Listar alla bakgrunder. 
  Users - Innehåller användarnamn och krypterade lösenord. 
  Characters - Listar karaktärers namn, klass, subklass, ras, subras, bakgrund, och ability scores. 
  Ownership - Används för "många till många"-relationen av användare och karaktärer. 
![ER-diagram](https://github.com/itggot-markus-moen/slutprojektvt19webbserver/tree/master/misc/ER-diagram.jpg)