----- Creazione del database
DROP DATABASE IF EXISTS MonitoraggioOperativoIngegneristico;
CREATE DATABASE IF NOT EXISTS MonitoraggioOperativoIngegneristico;
USE MonitoraggioOperativoIngegneristico;

-- Rimozione delle tabelle se esistono già (in ordine di dipendenza)
DROP TABLE IF EXISTS DatiOperativi;
DROP TABLE IF EXISTS Sensori;
DROP TABLE IF EXISTS Sensori_Specifiche;
DROP TABLE IF EXISTS Progetto_Macchina;
DROP TABLE IF EXISTS Asssegnazione;
DROP TABLE IF EXISTS Progetti;
DROP TABLE IF EXISTS Macchine;
DROP TABLE IF EXISTS Ingegneri;
DROP TABLE IF EXISTS Clienti;
DROP TABLE IF EXISTS Dipartimenti;

-- Creazione della tabella Dipartimenti
CREATE TABLE IF NOT EXISTS Dipartimenti (
    nome VARCHAR(100) PRIMARY KEY
)ENGINE=INNODB;

-- Creazione della tabella Ingegneri
CREATE TABLE IF NOT EXISTS Ingegneri (
    matricola INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL,
    dipartimento VARCHAR(100),
    FOREIGN KEY (dipartimento) REFERENCES Dipartimenti(nome)
)ENGINE=INNODB;

-- Creazione della tabella Clienti
CREATE TABLE IF NOT EXISTS Clienti (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(20) NOT NULL,
    settore VARCHAR(50) NOT NULL
)ENGINE=INNODB;

-- Creazione della tabella Progetti
CREATE TABLE IF NOT EXISTS Progetti (
    nome VARCHAR(50) PRIMARY KEY,
    descrizione TEXT,
    data_inizio DATE NOT NULL,
    data_fine DATE,
    budget DECIMAL(12,2) NOT NULL,
    id_cliente INT,
    FOREIGN KEY (id_cliente) REFERENCES Clienti(id_cliente)
)ENGINE=INNODB;

-- Creazione della tabella Assegnazione, associata a Progetti e Ingegneri
CREATE TABLE IF NOT EXISTS Assegnazione (
    progetto VARCHAR(50),
    ingegnere INT,
    data_inizio DATE NOT NULL,
    data_fine DATE,
    PRIMARY KEY (progetto, ingegnere),
    FOREIGN KEY (progetto) REFERENCES Progetti(nome),
    FOREIGN KEY (ingegnere) REFERENCES Ingegneri(matricola)
)ENGINE=INNODB;

-- Creazione della tabella Macchine
CREATE TABLE IF NOT EXISTS Macchine (
    seriale INT PRIMARY KEY,
    nome_macchina VARCHAR(50) NOT NULL,
    tipo VARCHAR(20),
    anno_produzione INT
)ENGINE=INNODB;

-- Tabella di relazione "impiego" (uso delle macchine nei progetti)
CREATE TABLE IF NOT EXISTS Progetto_Macchina (
    progetto VARCHAR(50),
    macchina INT,
    utilizzo_ore INT,
    PRIMARY KEY (progetto, macchina),
    FOREIGN KEY (progetto) REFERENCES Progetti(nome),
    FOREIGN KEY (macchina) REFERENCES Macchine(seriale)
)ENGINE=INNODB;

-- Creazione della tabella Sensori (ogni macchina può avere uno o più sensori, un sensore può essere associato a una sola macchina)
CREATE TABLE IF NOT EXISTS Sensori (
    id_sensore INT PRIMARY KEY,
    macchina INT,
    FOREIGN KEY (macchina) REFERENCES Macchine(seriale)
)ENGINE=INNODB;

-- Creazione della tabelle delle specifiche dei sensori (ogni sensore ha una specifica unica)
CREATE TABLE IF NOT EXISTS Sensori_Specifiche (
    id_sensore INT PRIMARY KEY,
    tipo_sensore VARCHAR(20) NOT NULL,
    tipo_acquisizione ENUM('Analogico', 'Digitale') NOT NULL,
    descrizione VARCHAR(100),
    FOREIGN KEY (id_sensore) REFERENCES Sensori(id_sensore)
)ENGINE=INNODB;

-- Creazione della tabella DatiOperativi per registrare i dati in tempo reale dai sensori
CREATE TABLE IF NOT EXISTS DatiOperativi (
    id_dato INT PRIMARY KEY,
    id_sensore INT,
    timestamp DATETIME NOT NULL,
    valore DECIMAL(10,3),
    unita_misura VARCHAR(30),
    tipo VARCHAR(20) DEFAULT 'Operativo',
    motivazione VARCHAR(100) DEFAULT NULL,
    FOREIGN KEY (id_sensore) REFERENCES Sensori(id_sensore)
)ENGINE=INNODB;

-- =============================================
-- Popolamento di esempio delle tabelle
-- =============================================

-- Inserimento dei Dipartimenti
INSERT INTO Dipartimenti (nome) VALUES
('Ricerca e Sviluppo'),
('Produzione'),
('Ricerca materiali extraterrestri'),
('Sistemi di controllo');

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

-- Update del progetto 'Progetto turbo' per aggiungere il budget
UPDATE Progetti
SET budget = 50000.00
WHERE nome = 'Progetto turbo';

-- Inserimento dei Assegnazioni
INSERT INTO Assegnazione (progetto, ingegnere, data_inizio, data_fine) VALUES
('Progetto turbo', 1, '2024-01-01', '2024-06-30'),
('Progetto Solare', 2, '2024-02-01', '2024-07-31'),
('Progetto SmartHome', 3, '2024-03-01', '2024-08-31'),
('Motore a improbabilità finita', 4, '2024-04-01', '2024-09-30'),
('Modulo stazione spaziale', 5, '2024-05-01', '2024-10-31');


-- Inserimento delle Macchine
INSERT INTO Macchine (seriale, nome_macchina, tipo, anno_produzione) VALUES
(1, 'CNC Lathe', 'Tornio', 2018),
(2, '3D Printer', 'Stampante 3D', 2021),
(3, 'Smerigliatrice per metalli', 'Smerigliatrice', 2019),
(4, 'Robot Saldatore', 'Robotica', 2020),
(5, 'Sega laser', 'taglio laser', 2022);


-- Inserimento dei dati di utilizzo delle Macchine nei Progetti
INSERT INTO Progetto_Macchina (progetto, macchina, utilizzo_ore) VALUES
('Progetto turbo', 1, 120),
('Progetto Solare', 2, 80),
('Progetto SmartHome', 3, 100),
('Motore a improbabilità finita', 4, 150),
('Modulo stazione spaziale', 5, 200);

-- Inserimento dei Sensori associati alle Macchine
INSERT INTO Sensori (id_sensore, macchina) VALUES
(1, 1),  -- Sensore di temperatura per il tornio
(2, 1),  -- Sensore di vibrazione per il tornio
(3, 2),  -- Sensore di umidità per la stampante 3D
(4, 3),  -- Sensore di pressione per la smerigliatrice
(5, 4),  -- Sensore di corrente per il robot saldatore
(6, 5);  -- Sensore di luminosità per la sega laser

-- Inserimento delle specifiche dei Sensori
INSERT INTO Sensori_Specifiche (id_sensore, tipo_sensore, tipo_acquisizione, descrizione) VALUES
(1, 'Temperatura', 'Analogico', 'Sensore di temperatura per il tornio'),
(2, 'Vibrazione', 'Digitale', 'Sensore di vibrazione per il tornio'),
(3, 'Umidità', 'Analogico', 'Sensore di umidità per la stampante 3D'),
(4, 'Pressione', 'Digitale', 'Sensore di pressione per la smerigliatrice'),
(5, 'Corrente', 'Analogico', 'Sensore di corrente per il robot saldatore'),
(6, 'Luminosità', 'Digitale', 'Sensore di luminosità per la sega laser');

-- Inserimento di alcuni dati operativi simulati dai sensori
INSERT INTO DatiOperativi (id_dato, id_sensore, timestamp, valore, unita_misura, tipo, motivazione) VALUES
(1, 1, '2024-01-01 08:00:00', 75.5, 'Celsius', 'Operativo', NULL),
(2, 2, '2024-01-01 08:05:00', 0.02, 'm/s^2', 'Operativo', NULL),
(3, 3, '2024-01-01 08:10:00', 45.0, '%', 'Operativo', NULL),
(4, 4, '2024-01-01 08:15:00', 101.3, 'kPa', 'Operativo', NULL),
(5, 5, '2024-01-01 08:20:00', 10.5, 'A', 'Operativo', NULL),
(6, 6, '2024-01-01 08:25:00', 300.0, 'lux', 'Operativo', NULL);

-- Inserimento di alcuni dati operativi con errori
INSERT INTO DatiOperativi (id_dato, id_sensore, timestamp, valore, unita_misura, tipo, motivazione) VALUES
(7, 1, '2024-01-01 08:30:00', NULL, 'Celsius', 'Errore', 'Sensore di temperatura non funzionante'),
(8, 2, '2024-01-01 08:35:00', -999.9, 'm/s^2', 'Errore', 'Valore di vibrazione anomalo'),
(9, 3, '2024-01-01 08:40:00', NULL, '%', 'Errore', 'Sensore di umidità non disponibile');