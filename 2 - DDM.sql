
-----------------------------------
-- Dynamic Data Masking (DDM)
-----------------------------------

USE DB_VENDAS

-- Criando schema

CREATE SCHEMA Data

-- Criando Tabela com o schema criado acima.

CREATE TABLE Data.Cadastro
(
    MemberID        int IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
    PrimeiroNome        varchar(100) MASKED WITH (FUNCTION = 'partial(1, "xxxxx", 1)') NULL,
    UltimoNome        varchar(100) NOT NULL,
    Telefone            varchar(12) MASKED WITH (FUNCTION = 'default()') NULL,
    Email            varchar(100) MASKED WITH (FUNCTION = 'email()') NOT NULL,
    CodigoDisconto    smallint MASKED WITH (FUNCTION = 'random(1, 100)') NULL
);

-- Inserindo registros na tabela criada acima

INSERT INTO Data.Cadastro (PrimeiroNome, UltimoNome, Telefone, Email, CodigoDisconto) 
VALUES  ('Roberto', 'Tamburello', '555.123.4567', 'RTamburello@contoso.com', 10),  
		('Janice', 'Galvin', '555.123.4568', 'JGalvin@contoso.com.co', 5),  
		('Shakti', 'Menon', '555.123.4570', 'SMenon@contoso.net', 50),  
		('Zheng', 'Mu', '555.123.4569', 'ZMu@contoso.net', 40);  

 
-- Criação de um usuário

CREATE USER UserDM WITHOUT LOGIN;  
GO

GRANT SELECT ON SCHEMA::Data TO UserDM;  
GO

EXECUTE AS USER = 'UserDM';  
GO
SELECT * FROM Data.Cadastro;  
GO
REVERT;  
