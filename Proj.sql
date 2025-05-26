-- =============================================
-- Progetto: MonitoraggioOperativoIngegneristico
-- Descrizione: Database per la gestione di progetti ingegneristici con
--              monitoraggio in tempo reale dei dati operativi dei macchinari.
--              Comprende dipartimenti, ingegneri, clienti, progetti, compiti,
--              macchine, sensori, log dei dati operativi, log degli errori riscontrati.
-- =============================================

----- Creazione del database
DROP DATABASE IF EXISTS MonitoraggioOperativoIngegneristico;
CREATE DATABASE IF NOT EXISTS MonitoraggioOperativoIngegneristico;
USE MonitoraggioOperativoIngegneristico;

-- Rimozione delle tabelle se esistono già (in ordine di dipendenza)
DROP TABLE IF EXISTS DatiOperativi;
DROP TABLE IF EXISTS Sensori;
DROP TABLE IF EXISTS Progetto_Macchina;
DROP TABLE IF EXISTS Compiti;
DROP TABLE IF EXISTS Progetti;
DROP TABLE IF EXISTS Macchine;
DROP TABLE IF EXISTS Ingegneri;
DROP TABLE IF EXISTS Clienti;
DROP TABLE IF EXISTS Dipartimenti;
DROP TABLE IF EXISTS Errori;

-- Creazione della tabella Dipartimenti
CREATE TABLE IF NOT EXISTS Dipartimenti (
    id_dipartimento INT PRIMARY KEY,
    nome VARCHAR(20) NOT NULL
)ENGINE=INNODB;

-- Creazione della tabella Ingegneri
CREATE TABLE IF NOT EXISTS Ingegneri (
    id_ingegnere INT PRIMARY KEY,
    nome VARCHAR(20) NOT NULL,
    cognome VARCHAR(20) NOT NULL,
    id_dipartimento INT,
    FOREIGN KEY (id_dipartimento) REFERENCES Dipartimenti(id_dipartimento)
)ENGINE=INNODB;

-- Creazione della tabella Clienti
CREATE TABLE IF NOT EXISTS Clienti (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(20) NOT NULL,
    settore VARCHAR(20)
)ENGINE=INNODB;

-- Creazione della tabella Progetti
CREATE TABLE IF NOT EXISTS Progetti (
    id_progetto INT PRIMARY KEY,
    nome VARCHAR(20) NOT NULL,
    descrizione TEXT,
    data_inizio DATE,
    data_fine DATE,
    budget DECIMAL(12,2),
    id_cliente INT,
    FOREIGN KEY (id_cliente) REFERENCES Clienti(id_cliente)
)ENGINE=INNODB;

-- Creazione della tabella Compiti, associata a Progetti e Ingegneri
CREATE TABLE IF NOT EXISTS Compiti (
    id_progetto INT,
    id_ingegnere INT,
    descrizione TEXT,
    data_inizio DATE,
    data_fine DATE,
    PRIMARY KEY (id_progetto, id_ingegnere),
    FOREIGN KEY (id_progetto) REFERENCES Progetti(id_progetto),
    FOREIGN KEY (id_ingegnere) REFERENCES Ingegneri(id_ingegnere)
)ENGINE=INNODB;

-- Creazione della tabella Macchine
CREATE TABLE IF NOT EXISTS Macchine (
    id_macchina INT PRIMARY KEY,
    nome_macchina VARCHAR(20) NOT NULL,
    tipo VARCHAR(20),
    anno_produzione INT
)ENGINE=INNODB;

-- Tabella di relazione tra Progetti e Macchine (uso delle macchine nei progetti)
CREATE TABLE IF NOT EXISTS Progetto_Macchina (
    id_progetto INT,
    id_macchina INT,
    utilizzo_ore INT,
    PRIMARY KEY (id_progetto, id_macchina),
    FOREIGN KEY (id_progetto) REFERENCES Progetti(id_progetto),
    FOREIGN KEY (id_macchina) REFERENCES Macchine(id_macchina)
)ENGINE=INNODB;

-- Creazione della tabella Sensori (ogni macchina può avere uno o più sensori)
CREATE TABLE IF NOT EXISTS Sensori (
    id_sensore INT PRIMARY KEY,
    id_macchina INT,
    tipo_acquisizione ENUM('Analogico', 'Digitale') NOT NULL,
    tipo_sensore VARCHAR(30) NOT NULL,
    descrizione TEXT,
    FOREIGN KEY (id_macchina) REFERENCES Macchine(id_macchina)
)ENGINE=INNODB;

-- Creazione della tabella DatiOperativi per registrare i dati in tempo reale dai sensori
CREATE TABLE IF NOT EXISTS DatiOperativi (
    id_dato INT PRIMARY KEY,
    id_sensore INT,
    timestamp DATETIME DEFAULT NOT NULL,
    valore DECIMAL(10,3),
    unita_misura VARCHAR(30),
    FOREIGN KEY (id_sensore) REFERENCES Sensori(id_sensore)
)ENGINE=INNODB;

-- Creazione della tabella degli errori automaticamente rilevati 
CREATE TABLE IF NOT EXISTS Errori (
    id_errore INT PRIMARY KEY,
    id_dato INT,
    descrizione TEXT,
    FOREIGN KEY (id_dato) REFERENCES DatiOperativi(id_dato)
)ENGINE=INNODB;

-- =============================================
-- Popolamento tabelle
-- =============================================

-- Inserimento dei Dipartimenti
INSERT INTO Dipartimenti (id_dipartimento, nome) VALUES
(1, 'Ricerca e Sviluppo'),
(2, 'Produzione'),
(3, 'Ricerca materiali extraterrestri'),
(4, 'Sistemi di controllo');

-- Load degli Ingegneri
LOAD DATA LOCAL INFILE "Ingegneri.csv" INTO TABLE Ingegneri
	FIELDS TERMINATED BY ";"
	LINES TERMINATED BY "\r\n"
	IGNORE 1 ROWS;

-- Inserimento dei Clienti
INSERT INTO Clienti (id_cliente, nome, settore) VALUES
(1, 'ABC S.p.A.', 'Automotive'),
(2, 'XYZ S.r.l.', 'Energia'),
(3, 'G.G.P.A', 'Impossibiltà metafisiche'), 
(4, 'Nasa', 'Aerospaziale'),
(5, 'Black Mesa', 'Ricerca scientifica');

-- Load dati dei Progetti
LOAD DATA LOCAL INFILE "Progetti.txt" INTO TABLE Progetti  
	FIELDS TERMINATED BY ";"
	LINES TERMINATED BY "\r\n"
	IGNORE 1 ROWS;

-- Update del progetto 2
UPDATE Progetti
SET nome = 'Progetto Energia Solare Avanzata', descrizione = 'Sviluppo di un sistema di pannelli solari innovativi per la produzione di energia pulita e sostenibile.'
WHERE id_progetto = 2;

-- Inserimento dei Compiti
INSERT INTO Compiti (id_compito, id_progetto, descrizione, data_inizio, data_fine, id_ingegnere) VALUES
(1, 1, 'Progettazione del sistema di combustione', '2024-01-15', '2024-03-15', 1),
(2, 1, 'Simulazione dinamica e test', '2024-04-01', '2024-08-31', 2),
(3, 2, 'Studio e installazione dei pannelli', '2024-03-10', '2024-06-30', 3),
(4, 3, 'Sviluppo del sistema di automazione', '2024-05-20', '2024-09-30', 4),
(5, 3, 'Verifica e collaudo impianti', '2024-10-01', '2025-02-28', 1);

-- Inserimento delle Macchine
INSERT INTO Macchine (id_macchina, nome_macchina, tipo, anno_produzione) VALUES
(1, 'CNC Lathe', 'Tornio', 2018),
(2, '3D Printer', 'Stampante 3D', 2021),
(3, 'Laser Cutter', 'Taglio Laser', 2019),
(4, 'Robot Saldatore', 'Robotica', 2020),
(5, 'Sega laser', 'taglio laser', 2022);

-- Inserimento dei dati di utilizzo delle Macchine nei Progetti
INSERT INTO Progetto_Macchina (id_progetto, id_macchina, utilizzo_ore) VALUES
(1, 1, 150),
(1, 2, 80),
(2, 3, 120),
(3, 2, 60),
(3, 4, 200);

-- Inserimento dei Sensori associati alle Macchine
INSERT INTO Sensori (id_sensore, id_macchina, tipo_sensore, descrizione) VALUES
(1, 1, 'Temperatura', 'Sensore di temperatura per il controllo del riscaldamento del motore'),
(2, 1, 'Vibrazione', 'Sensore per rilevare vibrazioni anomale nel tornio'),
(3, 2, 'Pressione', 'Sensore per monitorare la pressione durante la stampa 3D'),
(4, 3, 'Luce', 'Sensore per il controllo della precisione del taglio laser'),
(5, 4, 'Corrente', 'Sensore per il monitoraggio del consumo energetico del robot saldatore');

-- Inserimento di alcuni dati operativi simulati dai sensori
INSERT INTO DatiOperativi (id_dato, id_sensore, timestamp, valore, unita_misura) VALUES
(1, 1, '2024-04-01 08:30:00', 75.5, '°C'),
(2, 2, '2024-04-01 08:30:00', 0.02, 'g'),
(3, 3, '2024-04-01 08:30:00', 1.2, 'bar'),
(4, 4, '2024-04-01 08:30:00', 300, 'lux'),
(5, 5, '2024-04-01 08:30:00', 15.8, 'A');

-- Inserimento di errori simulati rilevati dai dati operativi
INSERT INTO Errori (id_errore, id_dato, descrizione) VALUES
(1, 1, 'Temperatura eccessiva nel motore del tornio'),
(2, 2, 'Vibrazione anomala rilevata nel tornio'),
(5, 5, 'Consumo energetico anomalo del robot saldatore');