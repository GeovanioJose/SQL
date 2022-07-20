
----------------------
-- Backup Encryption
----------------------

	
-- Criado a master key no exemplo da TDE

use master

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'kjhkgO72DVG%$14!';
go


-- Criando um novo certificado
use master

CREATE CERTIFICATE Certificado_BKP WITH SUBJECT = 'Certificado para a criptografia de backups';
go


-- Criptografando o backup
-- Atenção: realizar Backup certificatado

BACKUP DATABASE DB_VENDAS  
TO DISK = N'C:\Dados\DB_VENDAS2.bak'  
WITH  
	COMPRESSION,  
	ENCRYPTION   
	 (  
	 ALGORITHM = AES_256, 
	 SERVER CERTIFICATE = Certificado_BKP  
	 ),  
STATS = 10,  
format
