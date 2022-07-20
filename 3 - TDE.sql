----------------------------------------------
-- Transparent Data Encryption (TDE)
----------------------------------------------

-- Criação de uma chave mestre
USE master;
GO

-- Criando uma chave mestre para o certificado 

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'kjhkgO72DVG%$14!';
go


-- Criação do certificado

CREATE CERTIFICATE Certificado_TDE WITH SUBJECT = 'Certificado para a criptografia TDE';
go


-- backup do certificado e da chave privada

use master
BACKUP CERTIFICATE Certificado_TDE 
TO FILE = 'C:\Dados\BKP_CertificadoTDE.cer'  
WITH PRIVATE KEY ( FILE = 'C:\Dados\BKP_ChavePrivadaTDE.pvk' ,   
ENCRYPTION BY PASSWORD = 'kjhkgO72DVG%$14!' );  
GO  


-- Analisando o certificado

select  
	name,
	pvt_key_encryption_type_desc,
	subject,
	start_date,
	expiry_date
from sys.certificates
where name = 'Certificado_TDE'


-- Criação do certificado

USE DB_VENDAS;
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE Certificado_TDE;
GO

ALTER DATABASE DB_VENDAS SET ENCRYPTION ON;
GO


-- Analisando as bases criptografadas

SELECT 
	DB_NAME(database_id) AS DatabaseName, 
	CASE encryption_state
         WHEN '0'  THEN  'No database encryption key present, no encryption'
         WHEN '1'  THEN  'Unencrypted'
         WHEN '2'  THEN  'Encryption in progress'
         WHEN '3'  THEN  'Encrypted'
         WHEN '4'  THEN  'Key change in progress'
         WHEN '5'  THEN  'Decryption in progress'
         WHEN '6'  THEN  'Protection change in progress (The certificate or asymmetric key that is encrypting the database encryption key is being changed.)'
         ELSE 'No Status'
    END as encryption_state_desc,
	percent_complete,
	encryptor_type  ,
	key_algorithm,
	key_length
FROM sys.dm_database_encryption_keys
where DB_NAME(database_id) = 'DB_VENDAS'