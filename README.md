# Real-Time Machine Operation Monitoring

Small university project for the course "Database Systems" at the University of Firenze, Italy.

## Overview
This project provides a system for monitoring the operation of machines in real time, designed to support efficient management, maintenance, and analysis of industrial equipment. It leverages a relational database to track machines, projects, clients, and their interrelations.

## Features

- **Real-Time Monitoring:** Track the status and performance of machines as they operate.
- **Project Management:** Associate machines with specific projects and clients.
- **Data Analysis:** Generate reports and queries to analyze machine usage, project involvement, and client activity.
- **Extensible Database Schema:** Easily add new machines, projects, or clients.

## Database Structure

The system uses a relational database with the following main tables:

- `Macchine`: Stores information about each machine.
- `Progetti`: Contains project details.
- `Clienti`: Holds client information.
- `Progetto_Macchina`: Junction table linking machines to projects.

## Example Query

```sql
SELECT M.nome_macchina, M.tipo, P.nome AS Progetto
FROM Macchine M
JOIN Progetto_Macchina PM ON M.id_macchina = PM.id_macchina
JOIN Progetti P ON PM.id_progetto = P.id_progetto
JOIN Clienti C ON P.id_cliente = C.id_cliente
WHERE C.nome = 'Nasa';
```
This query lists all machines and their types involved in projects for the client "Nasa."


