CREATE DATABASE locadora
GO
USE locadora
go
--Criando e selecionando a data base Locadora;

CREATE TABLE cliente (
num_cadrastado	INT				NOT NULL,
nome			VARCHAR(70)		NOT NULL,
logradouro		VARCHAR(150)	NOT NULL,
num				INT				NOT NULL	CHECK(num > 0),
cep				CHAR(8)			NULL		CHECK(LEN(cep) = 8),
PRIMARY KEY (num_cadrastado)
);

CREATE TABLE estrela(
id		INT			NOT NULL,
nome	VARCHAR(50)	NOT NULL,
PRIMARY KEY (id)
);

CREATE TABLE filme(
id		INT			NOT NULL,
titulo	VARCHAR(40)	NOT NULL,
ano		INT			NULL CHECK (ano <= 2021),
PRIMARY KEY (id)
);
GO

CREATE TABLE dvd(
num				INT		NOT NULL,
data_fabricacao	DATE	NOT NULL CHECK(data_fabricacao < GETDATE()),
filmeid			INT		NOT NULL,
PRIMARY KEY (num),
FOREIGN KEY (filmeid) REFERENCES filme(id)
);

CREATE TABLE filme_estrela (
filmeid		INT	NOT NULL,
estrelaid	INT	NOT NULL,
FOREIGN KEY (filmeid) REFERENCES filme(id),
FOREIGN KEY (estrelaid) REFERENCES estrela(id),
);

CREATE TABLE locacao (
dvdnum				INT				NOT NULL,
clientenum_cadastro	INT				NOT NULL,
data_locacao		DATE			NOT NULL DEFAULT GETDATE(),
data_devolucao		DATE			NOT NULL,
valor				DECIMAL(7,2)	NOT NULL CHECK (valor > 0),
PRIMARY KEY (data_locacao, dvdnum, clientenum_cadastro),
FOREIGN KEY (dvdnum) REFERENCES dvd(num),
FOREIGN KEY	(clientenum_cadastro) REFERENCES cliente(num_cadrastado)
);

ALTER TABLE locacao
ADD CONSTRAINT chk_data
CHECK (data_devolucao > data_locacao);

--Esquemas--

ALTER TABLE estrela
ADD nome_real VARCHAR(50) NULL;
-- A entidade estrela deveria ter o nome real da estrela, com 50 caracteres.

ALTER TABLE filme
ALTER COLUMN titulo VARCHAR(80);
--Verificando um dos nomes de filme, percebeu-se que o nome do filme deveria ser um atributo com 80 caracteres.


--Inserindo dados----

INSERT INTO	filme(id, titulo, ano) VALUES
(1001, 'Whiplash', 2015),
(1002, 'Birdman', 2015),
(1003, 'Interestelar', 2014),
(1004, 'A Culpa é das estrelas', 2014),
(1005, 'Alexandre e o Dia Terrível Horrível Espantoso e Horroros', 2014),
(1006, 'Sing', 2016);

INSERT INTO estrela(id,nome, nome_real) VALUES
(9901, 'Michael Keaton', 'Michael John Douglas'),
(9902, 'Emma Stone', 'Emily Jean Stone'),
(9903, 'Miles Teller', NULL),
(9904, 'Steve Carell' , 'Steven John Carell'),
(9905, 'Jennifer Garner', 'Jennifer Anne Garner');


INSERT INTO filme_estrela (filmeid, estrelaid) VALUES
(1002 ,9901),
(1002 ,9902),
(1001 ,9903),
(1005 ,9904),
(1005 ,9905);

INSERT INTO dvd (num, data_fabricacao, filmeid) VALUES
(10001, '2020-12-02', 1001),
(10002, '2019-10-18', 1002),
(10003, '2020-04-03', 1003),
(10004, '2020-12-02', 1001),
(10005, '2019-10-18', 1004),
(10006, '2020-04-03', 1002),
(10007, '2020-12-02', 1005),
(10008, '2019-10-18', 1002),
(10009, '2020-04-03', 1003);

INSERT INTO cliente (num_cadrastado, nome, logradouro, num, cep) VALUES
(5501, 'Matilde Luz', 'Rua Síria', 150, '03086040'),
(5502, 'Carlos Carreiro', 'Rua Bartolomeu Aires', 1250, '04419110'),
(5503, 'Daniel Ramalho', 'Rua Itajutiba', 169, NULL),
(5504, 'Roberta Bento', 'Rua Jayme Von Rosenburg', 36, NULL),
(5505, 'Rosa Cerqueira', 'Rua Arnaldo Simões Pinto', 235, '02917110');

INSERT INTO locacao (dvdnum, clientenum_cadastro, data_locacao, data_devolucao, valor) VALUES
(10001, 5502, '2021-02-18', '2021-02-21', 3.50),
(10009, 5502, '2021-02-18', '2021-02-21', 3.50),
(10002, 5503, '2021-02-18', '2021-02-19', 3.50),
(10002, 5505, '2021-02-20', '2021-02-23', 3.00),
(10004, 5505, '2021-02-20', '2021-02-23', 3.00),
(10005, 5505, '2021-02-20', '2021-02-23', 3.00),
(10001, 5501, '2021-02-24', '2021-02-26', 3.50),
(10008, 5501, '2021-02-24', '2021-02-26', 3.50);

--Fim da inserção de dados---

--Os CEP dos clientes 5503 e 5504 são 08411150 e 02918190 respectivamente
UPDATE cliente
SET cep = '85411150'
WHERE num_cadrastado = 5503;

UPDATE cliente
SET cep = '02918190'
WHERE num_cadrastado = 5504;

UPDATE locacao
SET valor = 3.25
WHERE clientenum_cadastro = 5502 AND data_locacao = '2021-02-18';

UPDATE locacao
SET valor = 3.10
WHERE clientenum_cadastro = 5501 AND data_locacao = '2021-02-24';

UPDATE dvd 
SET data_fabricacao = '2019-07-14'
WHERE num = 10005;

UPDATE estrela
SET nome_real = 'Miles Alexander Teller'
WHERE nome = 'Miles Teller';

DELETE FROM filme
WHERE titulo = 'Sing';

--Fim dos UPdates.

--Inicio dos SELECTS;

--01
SELECT id, ano, CASE 
					WHEN LEN(titulo)> 10 THEN LEFT(titulo,10)+'...'
					ELSE titulo
					END AS nome_filme
FROM filme JOIN dvd ON id = dvd.filmeid
WHERE dvd.data_fabricacao > '2020-01-01';

--02
SELECT num, data_fabricacao, DATEDIFF(MONTH,data_fabricacao, GETDATE()) as qtd_meses_desde_fabricacao
FROM filme JOIN dvd On id = dvd.filmeid
WHERE titulo = 'Interestelar';

--03
SELECT dvdnum, data_locacao, data_devolucao, DATEDIFF(DAY, data_locacao, data_devolucao) as dias_alocado, valor
FROM locacao JOIN cliente ON clientenum_cadastro = num_cadrastado
WHERE nome LIKE '%Rosa%';

--04
SELECT nome, CONCAT(logradouro,', ', num) AS endereço_completo, STUFF(cep,6,0, '-') as cep
FROM cliente JOIN locacao ON num_cadrastado = clientenum_cadastro
WHERE dvdnum = 10002;


--Fim dos SELECTS;
SELECT * FROM cliente;
SELECT * FROM dvd;
SELECT * FROM filme;
SELECT * FROM estrela;
SELECT * FROM filme_estrela
