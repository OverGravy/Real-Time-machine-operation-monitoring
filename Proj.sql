-- =============================================
-- Progetto: MonitoraggioOperativoIngegneristico
-- Descrizione: Database per la gestione di progetti ingegneristici con
--              monitoraggio in tempo reale dei dati operativi dei macchinari.
--              Comprende dipartimenti, ingegneri, clienti, progetti, compiti,
--              macchine, sensori e log dei dati operativi.
-- =============================================

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

-- Creazione della tabella Dipartimenti
CREATE TABLE Dipartimenti (
    id_dipartimento INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

-- Creazione della tabella Ingegneri
CREATE TABLE Ingegneri (
    id_ingegnere INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL,
    id_dipartimento INT,
    FOREIGN KEY (id_dipartimento) REFERENCES Dipartimenti(id_dipartimento)
);

-- Creazione della tabella Clienti
CREATE TABLE Clienti (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    settore VARCHAR(100)
);

-- Creazione della tabella Progetti
CREATE TABLE Progetti (
    id_progetto INT PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    descrizione TEXT,
    data_inizio DATE,
    data_fine DATE,
    budget DECIMAL(12,2),
    id_cliente INT,
    FOREIGN KEY (id_cliente) REFERENCES Clienti(id_cliente)
);

-- Creazione della tabella Compiti
CREATE TABLE Compiti (
    id_compito INT PRIMARY KEY,
    id_progetto INT,
    descrizione TEXT,
    data_inizio DATE,
    data_fine DATE,
    id_ingegnere INT,
    FOREIGN KEY (id_progetto) REFERENCES Progetti(id_progetto),
    FOREIGN KEY (id_ingegnere) REFERENCES Ingegneri(id_ingegnere)
);

-- Creazione della tabella Macchine
CREATE TABLE Macchine (
    id_macchina INT PRIMARY KEY,
    nome_macchina VARCHAR(100) NOT NULL,
    tipo VARCHAR(100),
    anno_produzione INT
);

-- Tabella di relazione tra Progetti e Macchine (uso delle macchine nei progetti)
CREATE TABLE Progetto_Macchina (
    id_progetto INT,
    id_macchina INT,
    utilizzo_ore INT,
    PRIMARY KEY (id_progetto, id_macchina),
    FOREIGN KEY (id_progetto) REFERENCES Progetti(id_progetto),
    FOREIGN KEY (id_macchina) REFERENCES Macchine(id_macchina)
);

-- Creazione della tabella Sensori (ogni macchina può avere uno o più sensori)
CREATE TABLE Sensori (
    id_sensore INT PRIMARY KEY,
    id_macchina INT,
    tipo_sensore VARCHAR(100) NOT NULL,
    descrizione TEXT,
    FOREIGN KEY (id_macchina) REFERENCES Macchine(id_macchina)
);

-- Creazione della tabella DatiOperativi per registrare i dati in tempo reale dai sensori
CREATE TABLE DatiOperativi (
    id_dato INT PRIMARY KEY,
    id_sensore INT,
    timestamp DATETIME NOT NULL,
    valore DECIMAL(10,3),
    unita_misura VARCHAR(50),
    FOREIGN KEY (id_sensore) REFERENCES Sensori(id_sensore)
);

-- =============================================
-- Inserimenti di esempio
-- =============================================

-- Inserimento dei Dipartimenti
INSERT INTO Dipartimenti (id_dipartimento, nome) VALUES
(1, 'Ricerca e Sviluppo'),
(2, 'Produzione'),
(3, 'Amministrazione');

-- Inserimento degli Ingegneri
INSERT INTO Ingegneri (id_ingegnere, nome, cognome, id_dipartimento) VALUES
(1, 'Mario', 'Rossi', 1),
(2, 'Luigi', 'Bianchi', 1),
(3, 'Anna', 'Verdi', 2),
(4, 'Giulia', 'Neri', 2),
(5, 'Paolo', 'Gialli', 3);

-- Inserimento dei Clienti
INSERT INTO Clienti (id_cliente, nome, settore) VALUES
(1, 'ABC S.p.A.', 'Automotive'),
(2, 'XYZ S.r.l.', 'Energia'),
(3, 'Innovatech', 'Tecnologia');

-- Inserimento dei Progetti
INSERT INTO Progetti (id_progetto, nome, descrizione, data_inizio, data_fine, budget, id_cliente) VALUES
(1, 'Progetto Turbo', 'Sviluppo di un nuovo motore ad alte prestazioni', '2024-01-10', '2024-12-31', 500000.00, 1),
(2, 'Progetto Solare', 'Implementazione di pannelli solari ad alta efficienza', '2024-03-01', '2025-03-01', 300000.00, 2),
(3, 'Progetto Smart', 'Progettazione di sistemi di automazione per edifici intelligenti', '2024-05-15', '2025-05-15', 450000.00, 3);

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
(4, 'Robot Saldatore', 'Robotica', 2020);

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

-- =============================================
-- Esempi di query
-- =============================================

-- 1. Lista di tutti i progetti con nome, cliente e budget
SELECT P.nome AS Progetto, C.nome AS Cliente, P.budget
FROM Progetti P
JOIN Clienti C ON P.id_cliente = C.id_cliente;

-- 2. Elenco dei compiti assegnati a ciascun ingegnere e il numero totale di compiti
SELECT I.nome, I.cognome, COUNT(CO.id_compito) AS Numero_Compiti
FROM Ingegneri I
LEFT JOIN Compiti CO ON I.id_ingegnere = CO.id_ingegnere
GROUP BY I.id_ingegnere;

-- 3. Ore totali di macchina utilizzate per ogni progetto
SELECT P.nome AS Progetto, SUM(PM.utilizzo_ore) AS Ore_Totali
FROM Progetti P
JOIN Progetto_Macchina PM ON P.id_progetto = PM.id_progetto
GROUP BY P.id_progetto;

-- 4. Progetti attivi al momento (la data corrente compresa tra data_inizio e data_fine)
SELECT nome, data_inizio, data_fine
FROM Progetti
WHERE CURRENT_DATE BETWEEN data_inizio AND data_fine;

-- 5. Monitoraggio in tempo reale: ultimi dati operativi registrati per ciascun sensore
SELECT S.id_sensore, S.tipo_sensore, S.descrizione, D.timestamp, D.valore, D.unita_misura
FROM Sensori S
JOIN DatiOperativi D ON S.id_sensore = D.id_sensore
WHERE D.timestamp = (
    SELECT MAX(timestamp)
    FROM DatiOperativi
    WHERE id_sensore = S.id_sensore
)
ORDER BY S.id_sensore;
