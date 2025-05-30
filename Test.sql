-- assegna un secondo ingegnere al progetto solare

INSERT INTO Assegnazione (progetto, ingegnere, data_inizio, data_fine)
VALUES ('Progetto Solare', 1, '2023-01-01', '2023-12-31')

INSERT INTO progetti (nome, descrizione, budget, id_cliente, data_inizio, data_fine)
VALUES ('Progetto bho', 'Progetto per la realizzazione di un impianto solare', 100000, 1, '2023-01-01', '2023-12-31')

INSERT INTO progetto_macchina (progetto, macchina, utilizzo_ore)
VALUES ('Progetto bho', 1, 100)

INSERT INTO progetti (nome, descrizione, budget, id_cliente, data_inizio, data_fine)
VALUES ('Progetto Eolico', 'Progetto per la realizzazione di un impianto eolico', 150000, 2, '2023-02-01', '2025-08-30')

INSERT INTO sensori (id_sensore, macchina)
VALUES (8, 4)

INSERT INTO sensori_specifiche (id_sensore, tipo_sensore, tipo_acquisizione , descrizione)
VALUES (8, 'Temperatura', 'Analogico', 'Sensore per la misurazione della temperatura ambiente')

INSERT INTO assegnazione (progetto, ingegnere, data_inizio, data_fine)
VALUES ('Progetto Eolico', 3, '2023-02-01', '2025-08-30');

INSERT INTO ingegneri (matricola, nome, cognome)
VALUES (19, 'Marco', 'Rossinelli');