
-----------------------------------
-- Audit SQL
-----------------------------------


USE [master]
GO

-- Criação da auditoria do servidor

CREATE SERVER AUDIT Auditoria_Servidor
TO FILE 
(	FILEPATH = N'C:\DADOS\'
	,MAXSIZE = 1024 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 10000 -- Milisegundos (10 segundos)
	,ON_FAILURE = CONTINUE
)
ALTER SERVER AUDIT Auditoria_Servidor WITH (STATE = ON)
GO


-- Especificando as auditorias da instancia

USE [master]
GO

CREATE SERVER AUDIT SPECIFICATION [Especificacao_Auditoria_Servidor]
FOR SERVER AUDIT Auditoria_Servidor
ADD (SUCCESSFUL_LOGIN_GROUP),
ADD (LOGOUT_GROUP)
WITH (STATE = ON)
GO


-- Habilitando a auditoria para o banco de dados

USE DB_VENDAS
GO

CREATE DATABASE AUDIT SPECIFICATION [Auditoria_DB_Vendas]
FOR SERVER AUDIT Auditoria_Servidor
ADD (DELETE ON DATABASE::DB_VENDAS BY [public]),
ADD (INSERT ON DATABASE::DB_VENDAS BY [public]),
ADD (SELECT ON DATABASE::DB_VENDAS BY [public]),
ADD (UPDATE ON DATABASE::DB_VENDAS BY [public]),
ADD (SCHEMA_OBJECT_CHANGE_GROUP)
WITH (STATE = ON)
GO


/* realizando um teste */

USE DB_VENDAS

--DROP TABLE Cadastro

CREATE TABLE Cadastro
(
    ID        int IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
    PrimeiroNome        varchar(100) MASKED WITH (FUNCTION = 'partial(1, "xxxxx", 1)') NULL,
    UltimoNome        varchar(100) NOT NULL,
    Telefone            varchar(12) MASKED WITH (FUNCTION = 'default()') NULL,
    Email            varchar(100) MASKED WITH (FUNCTION = 'email()') NOT NULL,
    CodigoDisconto    smallint MASKED WITH (FUNCTION = 'random(1, 100)') NULL
);

-- Inserindo registros na tabela criada acima

INSERT INTO Cadastro (PrimeiroNome, UltimoNome, Telefone, Email, CodigoDisconto) 
VALUES  ('Roberto', 'Tamburello', '555.123.4567', 'RTamburello@contoso.com', 10),  
		('Janice', 'Galvin', '555.123.4568', 'JGalvin@contoso.com.co', 5),  
		('Shakti', 'Menon', '555.123.4570', 'SMenon@contoso.net', 50),  
		('Zheng', 'Mu', '555.123.4569', 'ZMu@contoso.net', 40);  


select * from Cadastro
where PrimeiroNome = 'roberto'


-- Analisando as informações auditadas

use master
go


SELECT 
	FORMAT(DATEADD(HOUR, -3, f.event_time), 'yyyy-MM-dd') as event_date,
	server_instance_name,
	database_Name,
	session_server_principal_name as login_name,
	CASE action_id
		WHEN 'IN' THEN 'INSERT'
		WHEN 'SL' THEN 'SELECT'
		WHEN 'CR' THEN 'CREATE'
		WHEN 'DR' THEN 'DROP'
	END AS action_description,
	statement,
	count(*) as qtd
FROM sys.fn_get_audit_file ('C:\DADOS\*.sqlaudit',default,default) as f
WHERE 1=1
AND action_id IN('IN','SL','CR','DR')
group by 
	FORMAT(DATEADD(HOUR, -3, f.event_time), 'yyyy-MM-dd') ,
	server_instance_name,
	database_Name,
	session_server_principal_name,
	action_id,
	statement