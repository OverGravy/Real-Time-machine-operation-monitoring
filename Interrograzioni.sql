-- =============================================
-- Query Varie
-- =============================================

-- 1. Trovare la lista di tutti i progetti con nome, cliente e budget
SELECT P.nome AS Progetto, C.nome AS Cliente, P.budget
FROM Progetti P
JOIN Clienti C ON P.id_cliente = C.id_cliente;

-- 2. Elencare il numero di assegnazioni per ciascun ingegnere
SELECT I.nome AS Ingegnere, I.cognome, COUNT(A.progetto) AS Numero_Assegnazioni
FROM Ingegneri I
JOIN Assegnazione A ON I.matricola = A.ingegnere
GROUP BY I.matricola, I.nome, I.cognome;

-- 3. Somma Ore totali di utilizzo di una specifica macchina passando il seriale (4 per 'Robot Saldatore') per ogni progetto in cui è in uso o è stata usata
SELECT M.nome_macchina, SUM(PM.utilizzo_ore) AS Ore_Totali
FROM Macchine M
JOIN Progetto_Macchina PM ON M.seriale = PM.macchina
WHERE M.seriale = 4
GROUP BY M.nome_macchina;

-- 4. Trovare i progetti attivi attualmente (la data corrente compresa tra data_inizio e data_fine)
SELECT P.nome AS Progetto, C.nome AS Cliente, P.data_inizio, P.data_fine
FROM Progetti P
JOIN Clienti C ON P.id_cliente = C.id_cliente
WHERE CURRENT_DATE BETWEEN P.data_inizio AND P.data_fine;

-- 5. Trovare tutti i dati operativi dei sensori della macchina con seriale 4 (Robot Saldatore) prodotti dai sensori con tipo di acquisizione 'Analogico'
SELECT D.timestamp, D.valore, D.unita_misura
FROM DatiOperativi D
JOIN Sensori S ON D.id_sensore = S.id_sensore
JOIN sensori_specifiche SP ON S.id_sensore = SP.id_sensore
JOIN Progetto_Macchina PM ON S.macchina = PM.macchina
WHERE S.macchina = 4
    AND SP.tipo_acquisizione = 'Analogico'

-- 6. Elenco Macchine impiegate per i progetti di un determinato cliente (id_cliente = 1 che sta per ABC S.p.A.)
SELECT M.nome_macchina, P.nome AS Progetto
FROM Macchine M
JOIN Progetto_Macchina PM ON M.seriale = PM.macchina
JOIN Progetti P ON PM.progetto = P.nome
JOIN Clienti C ON P.id_cliente = C.id_cliente
WHERE C.id_cliente = 1;




-- =======================================================
-- Viste
-- =======================================================

-- 1. Tabella che mostra quali macchinari hanno prodotto degli errori e con quali dati operativi
DROP VIEW IF EXISTS MacchineConErrori;
CREATE VIEW MacchineConErrori AS
SELECT M.nome_macchina, D.timestamp, D.valore, D.unita_misura
FROM Macchine M
JOIN Progetto_Macchina PM ON M.seriale = PM.macchina
JOIN DatiOperativi D ON PM.macchina = D.id_sensore
WHERE D.tipo = 'Errore';

-- ======================================================
-- Prodedure 
-- ======================================================

-- 1. Procedura per la ricerca di ingegneri che non hanno compiti assegnati
DROP PROCEDURE IF EXISTS TrovaIngegneriLiberi;
DELIMITER $$
CREATE PROCEDURE TrovaIngegneriLiberi()
BEGIN
    SELECT I.matricola, I.nome, I.cognome
    FROM Ingegneri I
    LEFT JOIN Assegnazione A ON I.matricola = A.ingegnere
    WHERE A.progetto IS NULL;
END$$
DELIMITER ;
CALL TrovaIngegneriLiberi();

-- 2. Procedura per l'assegnazione di un ingegnere a un progetto, prende il progetto, la matricola dell'ingegnere e le date di inizio e fine
DROP PROCEDURE IF EXISTS AssegnaIngegnereAProgetto;
DELIMITER $$
CREATE PROCEDURE AssegnaIngegnereAProgetto(IN progetto_nome VARCHAR(50), IN ingegnere_matricola INT, IN data_inizio DATE, IN data_fine DATE)
BEGIN
    DECLARE progetto_esiste INT;
    SELECT COUNT(*) INTO progetto_esiste
    FROM Progetti
    WHERE nome = progetto_nome;

    IF progetto_esiste = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Progetto non esistente';
    ELSE
        INSERT INTO Assegnazione (progetto, ingegnere, data_inizio, data_fine)
        VALUES (progetto_nome, ingegnere_matricola, data_inizio, data_fine);
    END IF;
END$$
DELIMITER ;
CALL AssegnaIngegnereAProgetto('Progetto Solare', 1, '2023-01-01', '2023-12-31');

-- 3 Procedura per la ricerca di progetti con budget superiore a un certo valore
DROP PROCEDURE IF EXISTS TrovaProgettiConBudgetSuperiore;
DELIMITER $$
CREATE PROCEDURE TrovaProgettiConBudgetSuperiore(IN budget_minimo DECIMAL(12,2))
BEGIN
    SELECT P.nome, P.budget
    FROM Progetti P
    WHERE P.budget > budget_minimo;
END$$
DELIMITER ;
CALL TrovaProgettiConBudgetSuperiore(10000.00);




-- ======================================================
-- Funzioni 
-- ======================================================

--1. calcolare il numero di progetti in cui è impiegata una macchina fornito il seriale
DROP FUNCTION IF EXISTS CalcolaNumeroProgettiMacchina;
DELIMITER $$
CREATE FUNCTION CalcolaNumeroProgettiMacchina(seriale_macchina INT)
RETURNS INT
BEGIN
    DECLARE numero_progetti INT;
    SELECT COUNT(DISTINCT progetto) INTO numero_progetti
    FROM Progetto_Macchina
    WHERE macchina = seriale_macchina;

    IF numero_progetti IS NULL THEN
        SET numero_progetti = 0;
    END IF;

    RETURN numero_progetti;
END$$

DELIMITER ;
CALL CalcolaNumeroProgettiMacchina(4); -- Esempio di chiamata per la macchina con seriale 4 (Robot Saldatore)


-- 2. calcolare il numero di ingegneri assegnati a un progetto fornito il nome del progetto
DROP FUNCTION IF EXISTS CalcolaNumeroIngegneriProgetto;
DELIMITER $$
CREATE FUNCTION CalcolaNumeroIngegneriProgetto(progetto_nome VARCHAR(50))
RETURNS INT
BEGIN
    DECLARE numero_ingegneri INT;
    SELECT COUNT(DISTINCT ingegnere) INTO numero_ingegneri
    FROM Assegnazione
    WHERE progetto = progetto_nome;

    IF numero_ingegneri IS NULL THEN
        SET numero_ingegneri = 0;
    END IF;

    RETURN numero_ingegneri;
END$$
DELIMITER ;
CALL CalcolaNumeroIngegneriProgetto('Progetto Solare'); -- Esempio di chiamata per il progetto 'Progetto Solare'

-- =========================================================
-- Trigger
-- =========================================================

-- 1. Se una macchina non è più utilizzata in nessun progetto, viene associta a un progetto di manutenzione ( il progetto manutenzione ha nome = manutenzione)
DROP TRIGGER IF EXISTS AssociaMacchinaManutenzione;
DELIMITER $$
CREATE TRIGGER AssociaMacchinaManutenzione
AFTER DELETE ON Progetto_Macchina
FOR EACH ROW
BEGIN
    DECLARE numero_macchine INT;
    SELECT COUNT(*) INTO numero_macchine
    FROM Progetto_Macchina
    WHERE macchina = OLD.macchina;

    IF numero_macchine = 0 THEN
        INSERT INTO Progetto_Macchina (progetto, macchina, utilizzo_ore)
        VALUES ('manutenzione', OLD.macchina, 0);
    END IF;
END$$
DELIMITER ;
