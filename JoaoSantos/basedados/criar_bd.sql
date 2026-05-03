-- Criação da Base de Dados
CREATE DATABASE IF NOT EXISTS felix_uber_shop;
USE felix_uber_shop;


-- Tabela UTILIZADOR
CREATE TABLE UTILIZADOR (
    id_utilizador INT(11) AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(60) NOT NULL,
    email VARCHAR(60) NOT NULL,
    password VARCHAR(60) NOT NULL,
    tipoContaId INT(11) NOT NULL, -- 1 = admin, 2 = funcionario, 3 = cliente
    validation INT(11) -- 1 = utilizador autorizado, 2 = utilizador por autorizar
);

-- admin
INSERT INTO UTILIZADOR (username, email, password, tipoContaId, validation)
VALUES ('admin', 'admin@felixubershop.pt', MD5('admin'), 1, 1);

-- funcionario
INSERT INTO UTILIZADOR (username, email, password, tipoContaId, validation)
VALUES ('funcionario', 'funcionario@felixubershop.pt', MD5('funcionario'), 2, 1);

-- cliente
INSERT INTO UTILIZADOR (username, email, password, tipoContaId, validation)
VALUES ('cliente', 'cliente@felixubershop.pt', MD5('cliente'), 3, 2);


-- Tabela CARTEIRA
CREATE TABLE CARTEIRA (
    id_carteira INT(11) AUTO_INCREMENT PRIMARY KEY,
    id_utilizador INT(11) NOT NULL, -- chave forasteira
    saldo DECIMAL(10, 2) DEFAULT 0.00,
    tipoCarteiraId INT(11) NOT NULL, -- 1 = carteira simples de cliente, 2 = carteira especial de admin ou funcionário

    FOREIGN KEY (id_utilizador) REFERENCES UTILIZADOR(id_utilizador)
);

-- carteira especial da loja
INSERT INTO CARTEIRA (id_utilizador, tipoCarteiraId)
VALUES (1, 2);

-- carteira cliente
INSERT INTO CARTEIRA (id_utilizador, saldo, tipoCarteiraId)
VALUES (3, 100.00, 1);


-- Tabela MOVIMENTO_CARTEIRA
CREATE TABLE MOVIMENTO_CARTEIRA (
    id_movimento INT(11) AUTO_INCREMENT PRIMARY KEY,
    data_hora DATE NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    tipoOperacaoId INT(11) NOT NULL, -- 1 = adicionar saldo, 2 = retirar saldo, 3 = pagar encomenda;
    id_carteira_origem INT(11) NOT NULL, -- chave forasteira
    id_carteira_destino INT(11) NOT NULL, -- chave forasteira

    FOREIGN KEY (id_carteira_origem) REFERENCES CARTEIRA(id_carteira),
    FOREIGN KEY (id_carteira_destino) REFERENCES CARTEIRA(id_carteira)
);

-- movimento teste
INSERT INTO MOVIMENTO_CARTEIRA (data_hora, valor, tipoOperacaoId, id_carteira_origem, id_carteira_destino)
VALUES ('2026-04-25 12:02:00', 20, 1, 2, 1);


-- Tabela PROMOCAO
CREATE TABLE PROMOCAO (
    id_promocao INT(11) AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(60) NOT NULL,
    mensagem VARCHAR(60),
    data_inicio DATE NOT NULL,
    data_fim DATE,
    estado INT(11) NOT NULL, -- 1 = disponível no site, 2 = não disponível no site
    id_utilizador INT(11) NOT NULL, -- administrador responsável || chave forasteira

    FOREIGN KEY (id_utilizador) REFERENCES UTILIZADOR(id_utilizador)
);

-- promocao 'leve 2 pague 1'
INSERT INTO PROMOCAO (titulo, mensagem, data_inicio, data_fim, estado, id_utilizador)
VALUES ('leve 2 pague 1', 'Escolha dois produtos e apenas pague um!', '2026-04-25 12:20:00', '2026-06-25 12:20:00', 1, 1);


-- Tabela ENCOMENDA
CREATE TABLE ENCOMENDA (
    id_encomenda INT(11) AUTO_INCREMENT PRIMARY KEY,
    id_utilizador INT(11) NOT NULL, -- id do cliente responsável pela encomenda || chave forasteira
    data_hora DATE NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    estado INT(11) NOT NULL, -- 1 = não enviada, 2 = enviada ao cliente

    FOREIGN KEY (id_utilizador) REFERENCES UTILIZADOR(id_utilizador)
);

-- encomenda teste
INSERT INTO ENCOMENDA (id_utilizador, data_hora, valor_total, estado)
VALUES (1, '2026-04-25 12:02:00', 35.25, 1);


-- Tabela PRODUTO
CREATE TABLE PRODUTO (
    id_produto INT(11) AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(60) NOT NULL,
    descricao VARCHAR(60) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL
);

-- 1. produto 'Chocolate Nilka'
INSERT INTO PRODUTO (nome, descricao, preco)
VALUES ('Chocolate Nilka', 'O Chocolate Nilka 30g é um chocolate de leite, prático e saboroso, ideal para lanches, ou para acompanhar sobremesas. Um clássico, agora disponível online.', 1.00);

-- 2. produto 'Agua Vital'
INSERT INTO PRODUTO (nome, descricao, preco)
VALUES ('Agua Vital', 'Água sem Gás Alcalina - pH 9.5 - 1.5L', 1.50);

-- 3. produto 'Next Cereais'
INSERT INTO PRODUTO (nome, descricao, preco)
VALUES ('Next Cereais', 'Cereais Integrais para preparar com leite, para um pequeno-almoço muito saboroso.', 2.80);

-- 4. produto 'Banana'
INSERT INTO PRODUTO (nome, descricao, preco)
VALUES ('Banana', 'Banana - 1kg.', 1.60);

-- 5. produto 'Cebola'
INSERT INTO PRODUTO (nome, descricao, preco)
VALUES ('Cebola', 'BCebola Nova - 100g', 1.20);


-- Tabela ITEM_ENCOMENDA
CREATE TABLE ITEM_ENCOMENDA
(
    id_item        INT(11) AUTO_INCREMENT PRIMARY KEY,
    id_encomenda   INT(11) NOT NULL, -- chave forasteira
    id_produto     INT(11) NOT NULL, -- chave forasteira
    quantidade     INT(11) NOT NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,

    FOREIGN KEY (id_encomenda) REFERENCES ENCOMENDA (id_encomenda),
    FOREIGN KEY (id_produto) REFERENCES PRODUTO (id_produto)
);

INSERT INTO ITEM_ENCOMENDA (id_encomenda, id_produto, quantidade, preco_unitario)
VALUES (1, 1, 1, 1.00);
