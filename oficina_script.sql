-- Criação do Banco de Dados para Oficina
CREATE DATABASE IF NOT EXISTS oficina;
USE oficina;

-- 1. Tabela Cliente
CREATE TABLE cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(45) NOT NULL,
    cpf CHAR(11) UNIQUE,
    contato VARCHAR(11)
);

-- 2. Tabela Veículo
CREATE TABLE veiculo (
    idVeiculo INT AUTO_INCREMENT PRIMARY KEY,
    idCliente INT,
    placa CHAR(7) UNIQUE NOT NULL,
    modelo VARCHAR(45),
    marca VARCHAR(45),
    CONSTRAINT fk_veiculo_cliente FOREIGN KEY (idCliente) REFERENCES cliente(idCliente)
);

-- 3. Tabela Equipe
CREATE TABLE equipe (
    idEquipe INT AUTO_INCREMENT PRIMARY KEY,
    nome_equipe VARCHAR(45) NOT NULL
);

-- 4. Tabela Mecânico
CREATE TABLE mecanico (
    idMecanico INT AUTO_INCREMENT PRIMARY KEY,
    idEquipe INT,
    nome VARCHAR(45) NOT NULL,
    endereco VARCHAR(255),
    especialidade VARCHAR(45),
    CONSTRAINT fk_mecanico_equipe FOREIGN KEY (idEquipe) REFERENCES equipe(idEquipe)
);

-- 5. Tabela Ordem de Serviço (OS)
CREATE TABLE ordem_servico (
    idOS INT AUTO_INCREMENT PRIMARY KEY,
    idVeiculo INT,
    idEquipe INT,
    data_emissao DATE NOT NULL,
    data_conclusao DATE,
    valor_total FLOAT DEFAULT 0,
    status_os ENUM('Aberta', 'Em análise', 'Aguardando Peça', 'Finalizada', 'Cancelada') DEFAULT 'Aberta',
    CONSTRAINT fk_os_veiculo FOREIGN KEY (idVeiculo) REFERENCES veiculo(idVeiculo),
    CONSTRAINT fk_os_equipe FOREIGN KEY (idEquipe) REFERENCES equipe(idEquipe)
);

-- 6. Tabela Peça
CREATE TABLE peca (
    idPeca INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(45) NOT NULL,
    valor_unitario FLOAT NOT NULL
);

-- 7. Tabela Serviço (Tabela de referência de preços de mão de obra)
CREATE TABLE servico (
    idServico INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(45) NOT NULL,
    valor_mao_de_obra FLOAT NOT NULL
);

-- 8. Relacionamento M:N entre OS e Peças
CREATE TABLE os_pecas (
    idOS INT,
    idPeca INT,
    quantidade INT DEFAULT 1,
    PRIMARY KEY (idOS, idPeca),
    CONSTRAINT fk_ospecas_os FOREIGN KEY (idOS) REFERENCES ordem_servico(idOS),
    CONSTRAINT fk_ospecas_peca FOREIGN KEY (idPeca) REFERENCES peca(idPeca)
);

-- 9. Relacionamento M:N entre OS e Serviços
CREATE TABLE os_servicos (
    idOS INT,
    idServico INT,
    quantidade INT DEFAULT 1,
    PRIMARY KEY (idOS, idServico),
    CONSTRAINT fk_osservicos_os FOREIGN KEY (idOS) REFERENCES ordem_servico(idOS),
    CONSTRAINT fk_osservicos_servico FOREIGN KEY (idServico) REFERENCES servico(idServico)
);

-- ==========================================
-- PERSISTÊNCIA DE DADOS PARA TESTES
-- ==========================================

INSERT INTO cliente (nome, cpf, contato) VALUES 
('Diego Silva', '12345678901', '11988887777'),
('Juliana Costa', '98765432100', '11977776666');

INSERT INTO veiculo (idCliente, placa, modelo, marca) VALUES 
(1, 'ABC1234', 'Civic', 'Honda'),
(2, 'XYZ9876', 'Onix', 'Chevrolet');

INSERT INTO equipe (nome_equipe) VALUES ('Equipe de Motores'), ('Equipe de Suspensão');

INSERT INTO mecanico (idEquipe, nome, especialidade) VALUES 
(1, 'Roberto Santos', 'Retífica'),
(1, 'Marcos Oliveira', 'Injeção Eletrônica'),
(2, 'Carlos Lima', 'Amortecedores');

INSERT INTO servico (descricao, valor_mao_de_obra) VALUES 
('Troca de Óleo', 50.00),
('Alinhamento', 80.00),
('Revisão Geral', 250.00);

INSERT INTO peca (descricao, valor_unitario) VALUES 
('Filtro de Óleo', 35.00),
('Amortecedor Dianteiro', 450.00),
('Pastilha de Freio', 120.00);

INSERT INTO ordem_servico (idVeiculo, idEquipe, data_emissao, valor_total, status_os) VALUES 
(1, 1, '2026-03-25', 85.00, 'Finalizada'),
(2, 2, '2026-03-29', 530.00, 'Aberta');

INSERT INTO os_servicos (idOS, idServico) VALUES (1, 1), (2, 2);
INSERT INTO os_pecas (idOS, idPeca) VALUES (1, 1), (2, 2);

-- ==========================================
-- QUERIES
-- ==========================================

-- 1 Relação completa de Clientes, Veículos e suas Ordens de Serviço (JOINS):

SELECT c.nome AS Cliente, v.modelo AS Carro, v.placa, o.idOS, o.status_os
FROM cliente c
INNER JOIN veiculo v ON c.idCliente = v.idCliente
LEFT JOIN ordem_servico o ON v.idVeiculo = o.idVeiculo;

-- 2 Qual o valor final da OS somando uma taxa de serviço de 10% (Atributo Derivado)?

SELECT idOS, valor_total, (valor_total * 1.10) AS valor_com_taxa_urgencia
FROM ordem_servico;

-- 3 Listar mecânicos e suas equipes, ordenados por nome (ORDER BY):

SELECT m.nome AS Mecanico, e.nome_equipe AS Equipe
FROM mecanico m
JOIN equipe e ON m.idEquipe = e.idEquipe
ORDER BY m.nome;

-- 4 Quais equipes possuem mais de 1 Ordem de Serviço aberta? (GROUP BY + HAVING):

SELECT e.nome_equipe, COUNT(o.idOS) AS total_os
FROM equipe e
JOIN ordem_servico o ON e.idEquipe = o.idEquipe
GROUP BY e.nome_equipe
HAVING total_os > 0;

-- 5 Buscar todas as peças utilizadas na OS do Diego (Filtros complexos com WHERE):

SELECT p.descricao, op.quantidade, p.valor_unitario
FROM peca p
JOIN os_pecas op ON p.idPeca = op.idPeca
JOIN ordem_servico os ON op.idOS = os.idOS
JOIN veiculo v ON os.idVeiculo = v.idVeiculo
JOIN cliente c ON v.idCliente = c.idCliente
WHERE c.nome = 'Diego Silva';
