# slutprojektvt19webbserver

# Projektplan

## 1. Projektbeskrivning
En sida där man kan slumpa fram D&D-karaktärer. Man ska ha ett konto där man kan se sina egna karaktärer och man ska även kunna se andras karaktärer. Man ska även kunna dela karaktärer med andra användare. 
## 2. Vyer (sidor)
  Start - Startsidan för hemsidan. Det är här man loggar in eller gör sitt konto. 
  Hem - Här får man se alla sina egna karaktärer och även andras karaktärer. Det är också här man kan göra sin karaktär. 
  Se specifik karaktär - Här kan man se en karaktär i mer detalj. Man kan antingen se en av sina egna eller en som tillhör en annan person. Om man ser en som man har äganedrätt till karaktären så kan man göra om den, dela den med en annnan användare och radera den. 
## 3. Funktionalitet (med sekvensdiagram)
## 4. Arkitektur (Beskriv filer och mappar)
  db - mappen för databasen
  db.db - själva databasen. 
  
  misc - i den här mappen liger sådant som är relevant för projektet men som inte används av koden på något sätt, främst bilder på diagram och liknande. 
  
  public - mappen där filer som skulle vara tillgängliga till alla besökare på sidan skulle ligga. Just nu fyller den ingen funktion, men om css skulle läggas till så skulle det vara här. 

  views - det här är mappen för alla slim-filer. 
  home.slim - det här är filen för hemsidan, där där man kommer när man har loggat in. 
  index.slim - detta är filen för sidan som man kommer till först. Den används för inloggningssystemet. 
  
## 5. (Databas med ER-diagram)
