-- DB setup script 

PRAGMA foreign_keys = ON;
PRAGMA encoding = "UTF-8";

BEGIN TRANSACTION;

-- Bagasje tabell 
CREATE TABLE IF NOT EXISTS Bagasje (
    Registreringsnummer VARCHAR(20) PRIMARY KEY,
    Vekt DECIMAL(5,2) NOT NULL,
    BagasjeInnsjekk TIMESTAMP NOT NULL,
    BillettID INT NOT NULL,
    FOREIGN KEY (BillettID) REFERENCES Billett(BillettID)
);

-- BetjentAv tabell
CREATE TABLE IF NOT EXISTS BetjenesAv (
    FlyruteID VARCHAR(10),
    FlytypeID VARCHAR(100),
    FlyselskapID VARCHAR(10),
    PRIMARY KEY (FlyruteID),
    FOREIGN KEY (FlyruteID) REFERENCES Flyrute(Flyrutenummer),
    FOREIGN KEY (FlytypeID) REFERENCES Flytype(Navn),
    FOREIGN KEY (FlyselskapID) REFERENCES Flyselskap(Flyselskapskode)
);

-- Billett tabell
CREATE TABLE IF NOT EXISTS Billett (
    BillettID INT PRIMARY KEY,
    RadNummer INT,
    RadBokstav CHAR(1),
    Klasse VARCHAR(10) NOT NULL CHECK (Klasse IN ('budget', 'economy', 'premium')),
    Pris DECIMAL(10,2) NOT NULL,
    Innsjekk TIMESTAMP,
    BillettKjøpID INT NOT NULL,
    FOREIGN KEY (BillettKjøpID) REFERENCES BillettKjøp(Referansenummer)
);

-- BillettKjøp tabell
CREATE TABLE IF NOT EXISTS BillettKjøp (
    Referansenummer INT PRIMARY KEY,
    Totalpris DECIMAL(10,2) NOT NULL,
    Kjøper INT NOT NULL,
    FOREIGN KEY (Kjøper) REFERENCES Kunde(KundeNr)
);

-- Delreise tabell
CREATE TABLE IF NOT EXISTS Delreise (
    Flyrutenummer VARCHAR(10),
    SekvensNummer INT,
    Avgangstid TIME NOT NULL,
    Ankomsttid TIME NOT NULL,
    Budsjett DECIMAL(10,2) NOT NULL,
    Økonomi DECIMAL(10,2) NOT NULL,
    Premium DECIMAL(10,2) NOT NULL,
    Startflyplass CHAR(3) NOT NULL,
    Endeflyplass CHAR(3) NOT NULL,
    PRIMARY KEY (Flyrutenummer, SekvensNummer),
    FOREIGN KEY (Flyrutenummer) REFERENCES Flyrute(Flyrutenummer),
    FOREIGN KEY (Startflyplass) REFERENCES Flyplass(Flyplasskode),
    FOREIGN KEY (Endeflyplass) REFERENCES Flyplass(Flyplasskode)
);

-- Fly tabell
CREATE TABLE IF NOT EXISTS Fly (
    Registreringsnummer VARCHAR(20) PRIMARY KEY,
    Serienummer VARCHAR(50) UNIQUE NOT NULL,
    Navn VARCHAR(100),
    FørsteDriftsår INT NOT NULL,
    Flytype VARCHAR(100) NOT NULL,
    FOREIGN KEY (Flytype) REFERENCES Flytype(Navn)
);

-- Flyplass tabell
CREATE TABLE IF NOT EXISTS Flyplass (
    Flyplasskode CHAR(3) PRIMARY KEY,
    Flyplassnavn VARCHAR(100) NOT NULL UNIQUE
);

-- Flyprodusent tabell 
CREATE TABLE IF NOT EXISTS Flyprodusent (
    Navn VARCHAR(100) PRIMARY KEY,
    Stiftelsesår INT NOT NULL
);

-- Nasjonalitet tabell
CREATE TABLE IF NOT EXISTS Nasjonalitet (
    FlyprodusentNavn VARCHAR(100) NOT NULL,
    Land VARCHAR(50) NOT NULL,
    PRIMARY KEY (FlyprodusentNavn, Land),
    FOREIGN KEY (FlyprodusentNavn) REFERENCES Flyprodusent(Navn)
);

-- Flyrute tabell
CREATE TABLE IF NOT EXISTS Flyrute (
    Flyrutenummer VARCHAR(10) PRIMARY KEY,
    Ukedagskode VARCHAR(7) NOT NULL,
    Oppstartdato DATE NOT NULL,
    Sluttdato DATE
);

-- Flyselskap tabell
CREATE TABLE IF NOT EXISTS Flyselskap (
    Flyselskapskode VARCHAR(10) PRIMARY KEY,
    Navn VARCHAR(100) NOT NULL UNIQUE
);

-- Flytype tabell
CREATE TABLE IF NOT EXISTS Flytype (
    Navn VARCHAR(100) PRIMARY KEY,
    Produsent VARCHAR(100) NOT NULL,
    Produksjonsstart INT NOT NULL,
    Produksjonsslutt INT,
    RadAntall INT NOT NULL,
    SeteAntall INT NOT NULL,
    FOREIGN KEY (Produsent) REFERENCES Flyprodusent(Navn)
);

-- Flyvning tabell
CREATE TABLE IF NOT EXISTS Flyvning (
    Løpenummer INT PRIMARY KEY,
    Dato DATE NOT NULL,
    Status VARCHAR(10) CHECK (Status IN ('planned', 'active', 'completed', 'cancelled')),
    FaktiskAvgangstid TIME,
    FaktiskAnkomstid TIME,
    FlyID VARCHAR(20),
    FlyruteID VARCHAR(10) NOT NULL,
    FOREIGN KEY (FlyID) REFERENCES Fly(Registreringsnummer),
    FOREIGN KEY (FlyruteID) REFERENCES Flyrute(Flyrutenummer)
);

-- Flåte tabell
CREATE TABLE IF NOT EXISTS Flåte (
    FlyID VARCHAR(20) PRIMARY KEY,
    FlytypeID VARCHAR(100) NOT NULL,
    FlyselskapID VARCHAR(10) NOT NULL,
    FOREIGN KEY (FlyID) REFERENCES Fly(Registreringsnummer),
    FOREIGN KEY (FlytypeID) REFERENCES Flytype(Navn),
    FOREIGN KEY (FlyselskapID) REFERENCES Flyselskap(Flyselskapskode)
);

-- Kunde tabell
CREATE TABLE IF NOT EXISTS Kunde (
    KundeNr INT PRIMARY KEY,
    Navn VARCHAR(100) NOT NULL,
    Telefon VARCHAR(20) NOT NULL UNIQUE,
    Epost VARCHAR(100) NOT NULL UNIQUE,
    Nasjonalitet VARCHAR(50) NOT NULL,
    Fordelsprogram BOOLEAN
);

-- Sete tabell
CREATE TABLE IF NOT EXISTS Sete (
    FlyRegNummer VARCHAR(20),
    RadNummer INT,
    RadBokstav CHAR(1),
    Nødutgang BOOLEAN NOT NULL,
    PRIMARY KEY (FlyRegNummer, RadNummer, RadBokstav),
    FOREIGN KEY (FlyRegNummer) REFERENCES Fly(Registreringsnummer)
);

-- Inserts av flyplasser
INSERT INTO Flyplass (Flyplasskode, Flyplassnavn) 
VALUES ("BOO", "Bodø Lufthavn");

INSERT INTO Flyplass (Flyplasskode, Flyplassnavn) 
VALUES ("BGO", "Bergen lufthavn, Flesland");

INSERT INTO Flyplass (Flyplasskode, Flyplassnavn) 
VALUES ("OSL", "Oslo lufthavn, Gardermoen");

INSERT INTO Flyplass (Flyplasskode, Flyplassnavn) 
VALUES ("SVG", "Stavanger lufthavn, Sola");

INSERT INTO Flyplass (Flyplasskode, Flyplassnavn) 
VALUES ("TRD", "Trondheim lufthavn, Værnes");

-- Inserts av flyselskap
INSERT INTO Flyselskap(Flyselskapskode, Navn)
VALUES ("DY", "Norwegian");

INSERT INTO Flyselskap(Flyselskapskode, Navn)
VALUES ("SK", "SAS");

INSERT INTO Flyselskap(Flyselskapskode, Navn)
VALUES ("WF", "Widerøe");

-- Inserts av flyprodusenter
INSERT INTO Flyprodusent(Navn, Stiftelsesår)
VALUES ("The Boeing Company", 1916);

INSERT INTO Flyprodusent(Navn, Stiftelsesår)
VALUES ("De Havilland Canada", 1928);

INSERT INTO Flyprodusent(Navn, Stiftelsesår)
VALUES ("Airbus Group", 1970);

-- Inserts av nasjonalitetene til flyprodusenter
INSERT INTO Nasjonalitet (FlyprodusentNavn, Land) 
VALUES ("The Boeing Company", "USA");

INSERT INTO Nasjonalitet (FlyprodusentNavn, Land) 
VALUES ("Airbus Group", "Frankrike");

INSERT INTO Nasjonalitet (FlyprodusentNavn, Land) 
VALUES ("Airbus Group", "Tyskland");

INSERT INTO Nasjonalitet (FlyprodusentNavn, Land) 
VALUES ("Airbus Group", "Spania");

INSERT INTO Nasjonalitet (FlyprodusentNavn, Land) 
VALUES ("Airbus Group", "Storbritannia");

INSERT INTO Nasjonalitet (FlyprodusentNavn, Land) 
VALUES ("De Havilland Canada", "Canada");

-- Inserts av flytyper 
INSERT INTO Flytype(Navn, Produsent, Produksjonsstart, Produksjonsslutt, RadAntall, SeteAntall)
VALUES ("Boeing 737 800", "The Boeing Company", 1997, 2020, 31, 31*6);

INSERT INTO Flytype(Navn, Produsent, Produksjonsstart, Produksjonsslutt, RadAntall, SeteAntall)
VALUES ("Airbus a320neo", "Airbus Group", 2016, NULL, 30, 30*6);

INSERT INTO Flytype(Navn, Produsent, Produksjonsstart, Produksjonsslutt, RadAntall, SeteAntall)
VALUES ("Dash-8 100", "De Havilland Canada", 1984, 2005, 10, 2+9*4);

-- Inserts av Boeing fly
INSERT INTO Fly (Registreringsnummer, Serienummer, Navn, FørsteDriftsår, Flytype)
VALUES ("LN-ENU", "42069", NULL, 2015, "Boeing 737 800");

INSERT INTO Fly (Registreringsnummer, Serienummer, Navn, FørsteDriftsår, Flytype)
VALUES ("LN-ENR", "42093", "Jan Bålsrud", 2018, "Boeing 737 800");

INSERT INTO Fly (Registreringsnummer, Serienummer, Navn, FørsteDriftsår, Flytype)
VALUES ("LN-NIQ", "39403", "Max Manus", 2011, "Boeing 737 800");

INSERT INTO Fly (Registreringsnummer, Serienummer, Navn, FørsteDriftsår, Flytype)
VALUES ("LN-ENS", "42281", NULL, 2017, "Boeing 737 800");

-- Inserts av Airbus fly
INSERT INTO Fly (Registreringsnummer, Serienummer, Navn, FørsteDriftsår, Flytype)
VALUES ("SE-RUB", "9518", "Birger Viking", 2020, "Airbus a320neo");

INSERT INTO Fly (Registreringsnummer, Serienummer, Navn, FørsteDriftsår, Flytype)
VALUES ("SE-DIR", "11421", "Nora Viking", 2023, "Airbus a320neo");

INSERT INTO Fly (Registreringsnummer, Serienummer, Navn, FørsteDriftsår, Flytype)
VALUES ("SE-RUP", "12066", "Ragnhild Viking", 2024, "Airbus a320neo");

INSERT INTO Fly (Registreringsnummer, Serienummer, Navn, FørsteDriftsår, Flytype)
VALUES ("SE-RZE", "12166", "Ebbe Viking", 2024, "Airbus a320neo");

-- Inserts av De Havilland Canada fly
INSERT INTO Fly (Registreringsnummer, Serienummer, Navn, FørsteDriftsår, Flytype)
VALUES ("LN-WIH", "383", "Oslo", 1994, "Dash-8 100");

INSERT INTO Fly (Registreringsnummer, Serienummer, Navn, FørsteDriftsår, Flytype)
VALUES ("LN-WIA", "359", "Nordland", 1993, "Dash-8 100");

INSERT INTO Fly (Registreringsnummer, Serienummer, Navn, FørsteDriftsår, Flytype)
VALUES ("LN-WIL", "298", "Narvik", 1995, "Dash-8 100");

-- Inserts av flyrute med tilhørende delreise og BetjenesAv relasjon
INSERT INTO Flyrute (Flyrutenummer, Ukedagskode, Oppstartdato, Sluttdato)
VALUES ("WF1311", "12345", "2000-01-01", NULL);

INSERT INTO Delreise (Flyrutenummer, SekvensNummer, Avgangstid, Ankomsttid, Budsjett, Økonomi, Premium, Startflyplass, Endeflyplass)
VALUES ("WF1311", 999, "15:15:00", "16:20:00", 599, 899, 2018, "TRD", "BOO");

INSERT INTO BetjenesAv (FlyruteID, FlytypeID, FlyselskapID)
VALUES ("WF1311", "Dash-8 100", "WF");

-- Inserts av flyrute med tilhørende delreise og BetjenesAv relasjon
INSERT INTO Flyrute (Flyrutenummer, Ukedagskode, Oppstartdato, Sluttdato)
VALUES ("WF1302", "12345", "2000-01-01", NULL);

INSERT INTO Delreise (Flyrutenummer, SekvensNummer, Avgangstid, Ankomsttid, Budsjett, Økonomi, Premium, Startflyplass, Endeflyplass)
VALUES ("WF1302", 999, "07:35:00", "08:40:00", 599, 899, 2018, "BOO", "TRD");

INSERT INTO BetjenesAv (FlyruteID, FlytypeID, FlyselskapID)
VALUES ("WF1302", "Dash-8 100", "WF");

-- Inserts av flyrute med tilhørende delreise og BetjenesAv relasjon
INSERT INTO Flyrute (Flyrutenummer, Ukedagskode, Oppstartdato, Sluttdato)
VALUES ("DY753", "1234567", "2000-01-01", NULL);

INSERT INTO Delreise (Flyrutenummer, SekvensNummer, Avgangstid, Ankomsttid, Budsjett, Økonomi, Premium, Startflyplass, Endeflyplass)
VALUES ("DY753", 999, "10:20:00", "11:15:00", 500, 1000, 1500, "TRD", "OSL");

INSERT INTO BetjenesAv (FlyruteID, FlytypeID, FlyselskapID)
VALUES ("DY753", "Boeing 737 800", "DY");

-- Inserts av flyrute med tilhørende delreise og BetjenesAv relasjon
INSERT INTO Flyrute (Flyrutenummer, Ukedagskode, Oppstartdato, Sluttdato)
VALUES ("SK332", "1234567", "2000-01-01", NULL);

INSERT INTO Delreise (Flyrutenummer, SekvensNummer, Avgangstid, Ankomsttid, Budsjett, Økonomi, Premium, Startflyplass, Endeflyplass)
VALUES ("SK332", 999, "08:00:00", "09:05:00", 500, 1000, 1500, "OSL", "TRD");

INSERT INTO BetjenesAv (FlyruteID, FlytypeID, FlyselskapID)
VALUES ("SK332", "Airbus a320neo", "SK");

-- Inserts av flyrute med tilhørende delreise og BetjenesAv relasjon
INSERT INTO Flyrute (Flyrutenummer, Ukedagskode, Oppstartdato, Sluttdato)
VALUES ("SK888", "12345", "2000-01-01", NULL);

INSERT INTO Delreise (Flyrutenummer, SekvensNummer, Avgangstid, Ankomsttid, Budsjett, Økonomi, Premium, Startflyplass, Endeflyplass)
VALUES ("SK888", 1, "10:00:00", "11:10:00", 800, 1500, 2000, "TRD", "BGO");

INSERT INTO Delreise (Flyrutenummer, SekvensNummer, Avgangstid, Ankomsttid, Budsjett, Økonomi, Premium, Startflyplass, Endeflyplass)
VALUES ("SK888", 2, "11:40:00", "12:10:00", 350, 700, 1000, "BGO", "SVG");

INSERT INTO Delreise (Flyrutenummer, SekvensNummer, Avgangstid, Ankomsttid, Budsjett, Økonomi, Premium, Startflyplass, Endeflyplass)
VALUES ("SK888", 999, "10:00:00", "12:10:00", 1000, 1700, 2200, "TRD", "SVG");

INSERT INTO BetjenesAv (FlyruteID, FlytypeID, FlyselskapID)
VALUES ("SK888", "Airbus a320neo", "SK");

-- Inserts av flyvningene

INSERT INTO Flyvning (Løpenummer, Dato, Status, FaktiskAvgangstid, FaktiskAnkomstid, FlyID, FlyruteID)
VALUES (1, "2025-04-01", "planned", NULL, NULL, NULL, "WF1302");

INSERT INTO Flyvning (Løpenummer, Dato, Status, FaktiskAvgangstid, FaktiskAnkomstid, FlyID, FlyruteID)
VALUES (2, "2025-04-01", "planned", NULL, NULL, NULL, "DY753");

INSERT INTO Flyvning (Løpenummer, Dato, Status, FaktiskAvgangstid, FaktiskAnkomstid, FlyID, FlyruteID)
VALUES (3, "2025-04-01", "planned", NULL, NULL, NULL, "SK888");

-- Inserts til flåte tabellen

-- Norwegian sin flåte (Boeing 737 800)
INSERT INTO Flåte (FlyID, FlytypeID, FlyselskapID) 
VALUES ("LN-ENU", "Boeing 737 800", "DY");

INSERT INTO Flåte (FlyID, FlytypeID, FlyselskapID) 
VALUES ("LN-ENR", "Boeing 737 800", "DY");

INSERT INTO Flåte (FlyID, FlytypeID, FlyselskapID) 
VALUES ("LN-NIQ", "Boeing 737 800", "DY");

INSERT INTO Flåte (FlyID, FlytypeID, FlyselskapID) 
VALUES ("LN-ENS", "Boeing 737 800", "DY");

-- SAS sin flåte (Airbus a320neo)
INSERT INTO Flåte (FlyID, FlytypeID, FlyselskapID) 
VALUES ("SE-RUB", "Airbus a320neo", "SK");

INSERT INTO Flåte (FlyID, FlytypeID, FlyselskapID) 
VALUES ("SE-DIR", "Airbus a320neo", "SK");

INSERT INTO Flåte (FlyID, FlytypeID, FlyselskapID)
 VALUES ("SE-RUP", "Airbus a320neo", "SK");

INSERT INTO Flåte (FlyID, FlytypeID, FlyselskapID) 
VALUES ("SE-RZE", "Airbus a320neo", "SK");

-- Widerøe sin flåte (Dash-8 100)
INSERT INTO Flåte (FlyID, FlytypeID, FlyselskapID) 
VALUES ("LN-WIH", "Dash-8 100", "WF");

INSERT INTO Flåte (FlyID, FlytypeID, FlyselskapID) 
VALUES ("LN-WIA", "Dash-8 100", "WF");

INSERT INTO Flåte (FlyID, FlytypeID, FlyselskapID) 
VALUES ("LN-WIL", "Dash-8 100", "WF");

-- Insert av fiktiv kunde
INSERT INTO Kunde (KundeNr, Navn, Telefon, Epost, Nasjonalitet, Fordelsprogram)
VALUES (1, "Jasper Steinberg", 96922262, "jasper@stud.ntnu.no", "Norsk", NULL);

-- Insert av fiktivt billettkjøp

INSERT INTO BillettKjøp (Referansenummer, Totalpris, Kjøper)
VALUES (1, 2*2018 + 4*899 + 4*599, 1);

-- Inserts av fiktive billetter

INSERT INTO Billett(BillettID, RadNummer, RadBokstav, Klasse, Pris, Innsjekk, BillettKjøpID)
VALUES (1, 1, "C", "premium", 2018, NULL, 1);

INSERT INTO Billett(BillettID, RadNummer, RadBokstav, Klasse, Pris, Innsjekk, BillettKjøpID)
VALUES (2, 1, "D", "premium", 2018, NULL, 1);

INSERT INTO Billett(BillettID, RadNummer, RadBokstav, Klasse, Pris, Innsjekk, BillettKjøpID)
VALUES (3, 2, "A", "economy", 899, NULL, 1);

INSERT INTO Billett(BillettID, RadNummer, RadBokstav, Klasse, Pris, Innsjekk, BillettKjøpID)
VALUES (4, 2, "B", "economy", 899, NULL, 1);

INSERT INTO Billett(BillettID, RadNummer, RadBokstav, Klasse, Pris, Innsjekk, BillettKjøpID)
VALUES (5, 2, "C", "economy", 899, NULL, 1);

INSERT INTO Billett(BillettID, RadNummer, RadBokstav, Klasse, Pris, Innsjekk, BillettKjøpID)
VALUES (6, 2, "D", "economy", 899, NULL, 1);

INSERT INTO Billett(BillettID, RadNummer, RadBokstav, Klasse, Pris, Innsjekk, BillettKjøpID)
VALUES (7, 3, "A", "budget", 599, NULL, 1);

INSERT INTO Billett(BillettID, RadNummer, RadBokstav, Klasse, Pris, Innsjekk, BillettKjøpID)
VALUES (8, 3, "B", "budget", 599, NULL, 1);

INSERT INTO Billett(BillettID, RadNummer, RadBokstav, Klasse, Pris, Innsjekk, BillettKjøpID)
VALUES (9, 3, "C", "budget", 599, NULL, 1);

INSERT INTO Billett(BillettID, RadNummer, RadBokstav, Klasse, Pris, Innsjekk, BillettKjøpID)
VALUES (10, 3, "D", "budget", 599, NULL, 1);


COMMIT;