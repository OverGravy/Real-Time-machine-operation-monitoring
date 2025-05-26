-- =============================================
-- Query Varie
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

-- 6. Elenco Macchine impiegate per i progetti di un determinato cliente
SELECT M.nome_macchina, M.tipo, P.nome AS Progetto
FROM Macchine M
JOIN Progetto_Macchina PM ON M.id_macchina = PM.id_macchina
JOIN Progetti P ON PM.id_progetto = P.id_progetto
JOIN Clienti C ON P.id_cliente = C.id_cliente
WHERE C.nome = 'Nasa'; 

-- =======================================================
-- Viste
-- =======================================================

-- 1. Tabella che associa tutti gli ingegneri ai progetti a cui sono assegnati
DROP VIEW IF EXISTS Ingegneri_Progetti;
CREATE VIEW Ingegneri_Progetti AS
SELECT I.id_ingegnere, I.nome AS Nome_Ingegnere, I.cognome, P.id_progetto, P.nome AS Nome_Progetto
FROM Ingegneri I
JOIN Compiti C ON I.id_ingegnere = C.id_ingegnere
JOIN Progetti P ON C.id_progetto = P.id_progetto;
GROUP BY I.id_ingegnere, P.id_progetto;

-- ======================================================
-- Funzioni e Procedure
-- ======================================================

-- 1. Funzione per calcolare il budget totale di un cliente

DROP FUNCTION IF EXISTS CalcolaBudgetTotale;

DELIMITER $$
CREATE FUNCTION CalcolaBudgetTotale(id_cliente INT)
RETURNS DECIMAL(12,2)
BEGIN
    DECLARE budget_totale DECIMAL(12,2);
    SELECT SUM(budget) INTO budget_totale
    FROM Progetti
    WHERE id_cliente = id_cliente;
    RETURN budget_totale;
END;

DELIMITER ;

SELECT CalcolaBudgetTotale(1) AS Budget_Totale_Cliente_1;

-- 2. Procedura per la ricerca di ingegneri che hanno terminato i loro compiti
DROP PROCEDURE IF EXISTS TrovaIngegneriCompitiTerminati;
DELIMITER $$
CREATE PROCEDURE TrovaIngegneriCompitiTerminati()
BEGIN
    SELECT I.id_ingegnere, I.nome, I.cognome
    FROM Ingegneri I
    JOIN Compiti C ON I.id_ingegnere = C.id_ingegnere
    WHERE C.data_fine < CURRENT_DATE;
END$$
DELIMITER ;
CALL TrovaIngegneriCompitiTerminati();

-- 3 Funzione per ottenere il numero di progetti attivi per un determinato dipartimento
DROP FUNCTION IF EXISTS NumeroProgettiAttiviDipartimento;
DELIMITER $$
CREATE FUNCTION NumeroProgettiAttiviDipartimento(id_dipartimento INT)
RETURNS INT
BEGIN
    DECLARE numero_progetti INT;
    SELECT COUNT(*) INTO numero_progetti
    FROM Progetti P
    JOIN Ingegneri I ON P.id_cliente = I.id_dipartimento
    WHERE I.id_dipartimento = id_dipartimento
      AND CURRENT_DATE BETWEEN P.data_inizio AND P.data_fine;
    RETURN numero_progetti;
END$$
DELIMITER ;
SELECT NumeroProgettiAttiviDipartimento(1) AS Progetti_Attivi_Dipartimento_1;

-- 4. Procedura che trova un ingegnere senza compiti assegnati
DROP PROCEDURE IF EXISTS TrovaIngegnereSenzaCompiti;
DELIMITER $$
CREATE PROCEDURE TrovaIngegnereSenzaCompiti()
BEGIN
    SELECT I.id_ingegnere, I.nome, I.cognome
    FROM Ingegneri I
    LEFT JOIN Compiti C ON I.id_ingegnere = C.id_ingegnere
    WHERE C.id_compito IS NULL;
END$$
DELIMITER ;
CALL TrovaIngegnereSenzaCompiti();

-- 5 Procedura per la ricerca di progetti con budget superiore a un certo valore
DROP PROCEDURE IF EXISTS TrovaProgettiConBudgetSuperiore;
DELIMITER $$
CREATE PROCEDURE TrovaProgettiConBudgetSuperiore(IN budget_minimo DECIMAL(12,2))
BEGIN
    SELECT P.id_progetto, P.nome, P.budget
    FROM Progetti P
    WHERE P.budget > budget_minimo;
END$$
DELIMITER ;
CALL TrovaProgettiConBudgetSuperiore(10000.00);

-- =========================================================
-- Trigger
-- =========================================================

-- 1. Se una macchina non è più utilizzata in nessun progetto, viene associta a un progetto di manutenzione ( il progetto manutenzione ha id_progetto = 9999)
DROP TRIGGER IF EXISTS AssociaMacchinaManutenzione;
DELIMITER $$
CREATE TRIGGER AssociaMacchinaManutenzione
AFTER DELETE ON Progetto_Macchina
FOR EACH ROW
BEGIN
    DECLARE count_macchine INT;
    SELECT COUNT(*) INTO count_macchine
    FROM Progetto_Macchina
    WHERE id_macchina = OLD.id_macchina;

    IF count_macchine = 0 THEN
        INSERT INTO Progetto_Macchina (id_progetto, id_macchina)
        VALUES (9999, OLD.id_macchina);
    END IF;
END$$
DELIMITER ;
