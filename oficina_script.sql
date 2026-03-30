-- Criação do Banco de Dados para o cenário de Oficina
CREATE DATABASE IF NOT EXISTS mechanical_workshop;
USE mechanical_workshop;

-- 1. Tabela Cliente
CREATE TABLE clients (
    idClient INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(45) NOT NULL,
    cpf CHAR(11) UNIQUE,
    contact VARCHAR(11)
);

-- 2. Tabela Veículo
CREATE TABLE vehicle (
    idVehicle INT AUTO_INCREMENT PRIMARY KEY,
    idClient INT,
    licensePlate CHAR(7) UNIQUE NOT NULL,
    model VARCHAR(45),
    brand VARCHAR(45),
    CONSTRAINT fk_vehicle_client FOREIGN KEY (idClient) REFERENCES clients(idClient)
);

-- 3. Tabela Equipe
CREATE TABLE team (
    idTeam INT AUTO_INCREMENT PRIMARY KEY,
    teamName VARCHAR(45) NOT NULL
);

-- 4. Tabela Mecânico
CREATE TABLE mechanic (
    idMechanic INT AUTO_INCREMENT PRIMARY KEY,
    idTeam INT,
    name VARCHAR(45) NOT NULL,
    address VARCHAR(255),
    specialty VARCHAR(45),
    CONSTRAINT fk_mechanic_team FOREIGN KEY (idTeam) REFERENCES team(idTeam)
);

-- 5. Tabela Ordem de Serviço (OS)
CREATE TABLE serviceOrder (
    idServiceOrder INT AUTO_INCREMENT PRIMARY KEY,
    idVehicle INT,
    idTeam INT,
    issueDate DATE NOT NULL,
    completionDate DATE,
    totalValue FLOAT DEFAULT 0,
    orderStatus ENUM('Open', 'In analysis', 'Waiting for parts', 'Finished', 'Canceled') DEFAULT 'Open',
    CONSTRAINT fk_order_vehicle FOREIGN KEY (idVehicle) REFERENCES vehicle(idVehicle),
    CONSTRAINT fk_order_team FOREIGN KEY (idTeam) REFERENCES team(idTeam)
);

-- 6. Tabela Peça
CREATE TABLE parts (
    idPart INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(45) NOT NULL,
    unitPrice FLOAT NOT NULL
);

-- 7. Tabela Serviço (Tabela de referência de preços de mão de obra)
CREATE TABLE service (
    idService INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(45) NOT NULL,
    laborValue FLOAT NOT NULL
);

-- 8. Relacionamento M:N entre OS e Peças
CREATE TABLE orderParts (
    idServiceOrder INT,
    idPart INT,
    quantity INT DEFAULT 1,
    PRIMARY KEY (idServiceOrder, idPart),
    CONSTRAINT fk_orderparts_order FOREIGN KEY (idServiceOrder) REFERENCES serviceOrder(idServiceOrder),
    CONSTRAINT fk_orderparts_part FOREIGN KEY (idPart) REFERENCES parts(idPart)
);

-- 9. Relacionamento M:N entre OS e Serviços
CREATE TABLE orderServices (
    idServiceOrder INT,
    idService INT,
    quantity INT DEFAULT 1,
    PRIMARY KEY (idServiceOrder, idService),
    CONSTRAINT fk_orderservices_order FOREIGN KEY (idServiceOrder) REFERENCES serviceOrder(idServiceOrder),
    CONSTRAINT fk_orderservices_service FOREIGN KEY (idService) REFERENCES service(idService)
);

-- ==========================================
-- PERSISTÊNCIA DE DADOS PARA TESTES
-- ==========================================

INSERT INTO clients (name, cpf, contact) VALUES 
('Diego Silva', '12345678901', '11988887777'),
('Juliana Costa', '98765432100', '11977776666');

INSERT INTO vehicle (idClient, licensePlate, model, brand) VALUES 
(1, 'ABC1234', 'Civic', 'Honda'),
(2, 'XYZ9876', 'Onix', 'Chevrolet');

INSERT INTO team (teamName) VALUES ('Equipe de Motores'), ('Equipe de Suspensão');

INSERT INTO mechanic (idTeam, name, specialty) VALUES 
(1, 'Roberto Santos', 'Retífica'),
(1, 'Marcos Oliveira', 'Injeção Eletrônica'),
(2, 'Carlos Lima', 'Amortecedores');

INSERT INTO service (description, laborValue) VALUES 
('Troca de Óleo', 50.00),
('Alinhamento', 80.00),
('Revisão Geral', 250.00);

INSERT INTO parts (description, unitPrice) VALUES 
('Filtro de Óleo', 35.00),
('Amortecedor Dianteiro', 450.00),
('Pastilha de Freio', 120.00);

INSERT INTO serviceOrder (idVehicle, idTeam, issueDate, totalValue, orderStatus) VALUES 
(1, 1, '2026-03-25', 85.00, 'Finished'),
(2, 2, '2026-03-29', 530.00, 'Open');

INSERT INTO orderServices (idServiceOrder, idService) VALUES (1, 1), (2, 2);
INSERT INTO orderParts (idServiceOrder, idPart) VALUES (1, 1), (2, 2);

-- ==========================================
-- QUERIES SQL
-- ==========================================

-- 1. Relação completa de Clientes, Veículos e suas Ordens de Serviço (JOINS):
SELECT c.name AS Cliente, v.model AS Carro, v.licensePlate, o.idServiceOrder, o.orderStatus
FROM clients c
INNER JOIN vehicle v ON c.idClient = v.idClient
LEFT JOIN serviceOrder o ON v.idVehicle = o.idVehicle;

-- 2. Valor final da OS somando uma taxa de serviço de 10% (Atributo Derivado):
SELECT idServiceOrder, totalValue, (totalValue * 1.10) AS totalValueWithTax
FROM serviceOrder;

-- 3. Listar mecânicos e suas equipes, ordenados por nome (ORDER BY):
SELECT m.name AS Mecanico, t.teamName AS Equipe
FROM mechanic m
JOIN team t ON m.idTeam = t.idTeam
ORDER BY m.name;

-- 4. Quais equipes possuem mais de 1 Ordem de Serviço cadastrada? (GROUP BY + HAVING):
SELECT t.teamName, COUNT(o.idServiceOrder) AS totalOrders
FROM team t
JOIN serviceOrder o ON t.idTeam = o.idTeam
GROUP BY t.teamName
HAVING totalOrders > 0;

-- 5. Buscar todas as peças utilizadas na OS do cliente 'Diego Silva' (WHERE com JOINS):
SELECT p.description, op.quantity, p.unitPrice
FROM parts p
JOIN orderParts op ON p.idPart = op.idPart
JOIN serviceOrder os ON op.idServiceOrder = os.idServiceOrder
JOIN vehicle v ON os.idVehicle = v.idVehicle
JOIN clients c ON v.idClient = c.idClient
WHERE c.name = 'Diego Silva';
