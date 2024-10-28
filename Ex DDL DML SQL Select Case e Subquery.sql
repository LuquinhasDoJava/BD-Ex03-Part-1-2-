CREATE DATABASE projetos
GO
USE projetos
go

--Data Base criada e selecionada

CREATE TABLE projects (
id			INT 		NOT NULL IDENTITY(10001,1),
nome		VARCHAR(45)	NOT NULL,
descricao	VARCHAR(45) NULL,
date		DATE		NOT NULL CHECK (date>'2014-09-01'),
PRIMARY KEY (id)
);
--Tabela projects criada
CREATE TABLE users (
id			INT			NOT NULL IDENTITY(1,1),
nome		VARCHAR(45)	NOT NULL,
username	VARCHAR(45)	NOT NULL UNIQUE,
senha		VARCHAR(45)	NOT NULL DEFAULT '123mudar',
email		VARCHAR(45)	NOT NULL,
PRIMARY KEY (id)
);
GO
--Tabela users criada
CREATE TABLE users_has_projects (
id_user INT NOT NULL,
id_project	INT	NOT NULL,
FOREIGN KEY (id_user) REFERENCES users(id),
FOREIGN KEY (id_project) REFERENCES projects(id)
);
GO
--Tabela users_has_projects (tabela auxiliar) criada

SELECT CONSTRAINT_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_NAME = 'users' AND CONSTRAINT_TYPE = 'UNIQUE'; --Query pra achar a constraint
GO

ALTER TABLE users
DROP CONSTRAINT CONSTRAINS_NAME; --Tirando a constraint para alterar o valor.
GO

ALTER TABLE users
ALTER COLUMN username VARCHAR(10) NOT NULL; --Modificar a coluna username da tabela Users para varchar(10).
GO

ALTER TABLE users
ADD CONSTRAINT UQ_users_username UNIQUE (username); --Voltando a constraint UNIQUE para o campo nome
GO



ALTER TABLE users ALTER COLUMN senha VARCHAR(8); --Modificar a coluna password da tabela Users para varchar(8).


INSERT INTO users (nome, username, senha, email) VALUES --Inserindo valores
('Maria','Rh_maria', '123mudar', 'maria@empresa.com'),
('Paulo','Ti_paulo', '123@456', 'paulo@empresa.com'),
('Ana','Rh_ana', '123mudar', 'ana@empresa.com'),
('Clara','Ti_clara', '123mudar', 'clara@empresa.com'),
('Aparecido','Rh_apareci', '55@!cido', 'aparecido@empresa.com');

ALTER TABLE projects ALTER COLUMN descricao VARCHAR(45) NULL; -- Permitindo que a coluna email aceite NULL

INSERT INTO projects (nome, descricao, date) VALUES  --Inserindo outros valores
('Re-folha', 'Refatoração das Folhas', '2014-09-05'),
('Manutenção PC(s)', 'Manutenção PC ́s', '2014-09-06'),
('Auditoria', NULL, '2014-09-07');

INSERT INTO users_has_projects(id_user, id_project) VALUES --Inserindo mais valores
(1,10001),
(5,10001),
(3,10003),
(4,10002),
(2,10001);

SELECT CONSTRAINT_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_NAME = 'projects' AND  CONSTRAINT_TYPE = 'check'; 

ALTER TABLE projects DROP CONSTRAINT CONSTRAINT_NAME; --Tirando constraint check do campo 'data'

EXEC SP_RENAME 'projects.date', 'data_projeto', 'COLUMN'; --Mudando nome do campo

ALTER TABLE projects 
ADD CONSTRAINT UQ_projects_data_projeto_Check --Voltando constraint check no campo 'data'.
CHECK(data_projeto>'2014-09-01');

UPDATE projects SET data_projeto = '2014/09/12' WHERE id = 10002; --O projeto de Manutenção atrasou, mudar a data para 12/09/2014

UPDATE users SET username = 'Rh_cido' WHERE nome = 'Aparecido'; --- O username de aparecido (usar o nome como condição de mudança) está feio, mudar para RH_cido


UPDATE users SET senha = '888@*' WHERE nome = 'Maria' and senha = '123mudar'; --Mudar o password do username Rh_maria (usar o username como condição de mudança) para 888@*, mas a condição deve verificar se o password dela ainda é 123mudar

SELECT CONSTRAINT_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_NAME = 'users_has_projects' AND  CONSTRAINT_TYPE = 'FOREIGN KEY';

ALTER TABLE users_has_projects DROP CONSTRAINT FK__users_has__id_us__3D5E1FD2;

UPDATE users_has_projects SET id_user = 3 WHERE id_project = 10002 AND id_user = 2;

ALTER TABLE users_has_projects 
ADD CONSTRAINT FK_users_has_projects_id_user FOREIGN KEY (id_user) REFERENCES users(id);


--Consultas
--01
SELECT id, nome, email, username,
    CASE 
        WHEN senha <> '123mudar' THEN '********'
        ELSE senha
    END AS senha
FROM users;

--02
SELECT projects.nome, descricao, data_projeto AS data, DATEADD(DAY, +15,+data_projeto) AS data_final
FROM projects JOIN users_has_projects ON users_has_projects.id_project = projects.id JOIN users ON users.id = users_has_projects.id_user
WHERE users.email = 'aparecido@empresa.com';

--03
SELECT users.nome, email
FROM users JOIN users_has_projects ON users_has_projects.id_user = users.id JOIN projects ON projects.id = users_has_projects.id_project
WHERE projects.nome LIKE '%Auditoria%';

--04
SELECT nome, descricao, data_projeto, '2014-09-16' AS data_fim, DATEDIFF(DAY, data_projeto, '2014-09-16') * 79.85 AS total_cost
FROM projects
WHERE nome LIKE '%Manutenção%' AND data_projeto <= '2014-09-16';  -- Garante que a data do projeto é anterior ou igual à data final

--Fim das consultas


SELECT * FROM projects
SELECT * FROM users
SELECT * FROM users_has_projects


