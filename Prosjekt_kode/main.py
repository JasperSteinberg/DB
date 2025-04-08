import sqlite3
import os
import sys


#Lager en tom database
MAIN_DB = "FlyDB.sqlite"
SETUP_SQL = "setupFlyDB.sql"

def database_setup():
    #Funksjon som initaliserer FlyDB, altså laster inn tabeller og data fra setupFlyDB.sql

    #Sjekker om MAIN_DB finnes fra før, sletter den hvis slik at vi starter med en tom database
    if os.path.exists(MAIN_DB):
        os.remove(MAIN_DB)

    conn = sqlite3.connect(MAIN_DB) #Kobler til SQLite databasen
    print("Connection successful")

    cursor = conn.cursor() #Oppretter cursor objekt

    with open("setupFlyDB.sql", "r", encoding="utf-8") as setup_file: #Åpner setup filen 
        setup_script = setup_file.read() #Leser inn alle setup kommandoer i sql_script
        cursor.executescript(setup_script) #Kjører alle kommandoene i setupFlyDB

    conn.commit() #Lagrer endringer
    conn.close() #Lukker tilgang

    print("DB initialization successful")

def test_brukstilfelle5():
    #Funksjon for å reprodusere spørringen i brukstilfelle 5

    conn = sqlite3.connect(MAIN_DB)

    cursor = conn.cursor()

    #Vi kjører spørringen
    cursor.execute("""
    SELECT Flyselskap.Navn as Flyselskap, Flåte.FlytypeID as Flytype, COUNT(*) AS AntallFly 
    FROM Flåte INNER JOIN Flyselskap ON (Flåte.FlyselskapID = Flyselskap.Flyselskapskode) 
    GROUP BY Flyselskap.Navn, Flåte.FlytypeID;
    """)

    rows = cursor.fetchall() #Henter resultatet

    #Henter ut kolonnenavnene
    headers = [description[0] for description in cursor.description]
    print(headers)

    #Henter ut radene
    for row in rows:
        print(row)

    conn.close()

weekday_to_number = {
    "mandag": 1,
    "tirsdag": 2,
    "onsdag": 3,
    "torsdag": 4,
    "fredag": 5,
    "lørdag": 6,
    "søndag": 7
}

def brukstilfelle6_flyrute_printout(ukedag: int, flyplass, flyplass_type):
    """
    Funksjon som printer ut gyldige flyruter som går på en gitt ukedag, fra eller til en gitt 
    flyplass. Om vi sjekker fra eller til kommer ann på om flyplass_type er startsflyplass 
    eller endeflyplass. 
    """

    conn = sqlite3.connect(MAIN_DB)
    cursor = conn.cursor()

    #Betingelse til SQL-spørring basert på om brukeren vil ha flyruter til eller fra den gitte flyplassen
    where_clause = "D.Startflyplass = ?" if flyplass_type == "startsflyplass" else "D.Endeflyplass = ?"

    #Hent alle delreiser hvor flyplassen er start/endeflyplass
    cursor.execute(f"""
        SELECT D.Flyrutenummer, D.SekvensNummer, D.Avgangstid, D.Ankomsttid, D.Startflyplass, D.Endeflyplass
        FROM Delreise AS D
        INNER JOIN Flyrute AS FR 
        ON D.Flyrutenummer = FR.Flyrutenummer
        WHERE {where_clause}
        AND FR.Ukedagskode LIKE ?
        ORDER BY D.Flyrutenummer, D.SekvensNummer;
    """, (flyplass, f"%{ukedag}%"))

    rows = cursor.fetchall()
    conn.close()

    #Oppretter et dictionary for strukturering av spørringen
    #Flyrturenummer blir nøkkel, og resten av informasjonen blir lagret rad-vis
    flyruter = {}
    for row in rows:
        flyrutenummer, sekvens, avgang, ankomst, start, slutt = row
        if flyrutenummer not in flyruter:
            flyruter[flyrutenummer] = []
        flyruter[flyrutenummer].append((sekvens, avgang, ankomst, start, slutt))

    #Printer ut alle etappene, alstå delflyvningene/totalflyvningene som går til den oppgitte flyplassen
    for flyrute, etapper in flyruter.items():
        print(f"\nFlyrute: {flyrute}")

        for sekvens, avgang, ankomst, start, slutt in etapper:
            print(f"  {start} ({avgang}) → {slutt} ({ankomst})")




def brukstilfelle6_userinput():
    """
    Vi henter informasjon fra bruker og mater inn i brukstilfelle6_flyrute_printout
    """

    #Vi tar inn en ukedag og konverterer til tilsvarende tall
    print("\nFor hvilken ukedag ønsker du å sjekke flyruter? (skriv en ukedag) \n")
    ukedag_string = input().strip().lower()
    ukedag_nummer = weekday_to_number[ukedag_string]

    print("\nFor hvilken flyplass ønsker du å sjekke reiser? (skriv flyplasskode)\n" )

    conn = sqlite3.connect(MAIN_DB)
    cursor = conn.cursor()

    #Henter mulige utreiseflyplasser
    cursor.execute("SELECT DISTINCT Startflyplass FROM Delreise")
    rows = cursor.fetchall()
    utreiseflyplasser = [row[0] for row in rows]
    print("Flyplasser med utreiser")
    print(f"{utreiseflyplasser}\n")

    #Henter mulige ankomstflyplasser
    cursor.execute("SELECT DISTINCT Endeflyplass FROM Delreise")
    rows = cursor.fetchall()
    ankomstflyplasser = [row[0] for row in rows]
    print("Flyplasser med ankomster")
    print(f"{ankomstflyplasser}\n")

    conn.close()

    #Henter ønsket flyplass fra bruker
    flyplass = input().strip().upper()

    print("\nØnsker du å sjekke utreise eller ankomst? (skriv utreise eller ankomst)\n")

    reisetype = input().strip().lower()

    #Sjekker for gyldig input
    if reisetype == "utreise" and flyplass in utreiseflyplasser:
        brukstilfelle6_flyrute_printout(ukedag_nummer, flyplass, "startsflyplass")

    elif reisetype == "ankomst" and flyplass in ankomstflyplasser:
         brukstilfelle6_flyrute_printout(ukedag_nummer, flyplass, "endeflyplass")
    
    else:
        print("Ugyldig input")


if __name__ == "__main__":

    database_setup()

    print("\nResulatet av spørringen i brukstilfelle 5: \n")
    test_brukstilfelle5()


    brukstilfelle6_userinput()


