
----------------------------
-- ROW LEVEL SECURITY (RLS)
----------------------------

use db_vendas

-- criação de usuários de teste

CREATE USER Gerente		WITHOUT LOGIN;  
CREATE USER Vendedor1 WITHOUT LOGIN;  
CREATE USER Vendedor2 WITHOUT LOGIN;
GO

CREATE TABLE [dbo].[Pedidos](
	[PedidoID] [int] NULL,
	[Vendedor] [nvarchar](50) NULL,
	[Produto] [nvarchar](50) NULL,
	[Quantidade] [smallint] NULL
) ON [PRIMARY]
GO
INSERT [dbo].[Pedidos] ([PedidoID], [Vendedor], [Produto], [Quantidade]) VALUES (1, N'Vendedor1', N'Celular', 5)
INSERT [dbo].[Pedidos] ([PedidoID], [Vendedor], [Produto], [Quantidade]) VALUES (2, N'Vendedor1', N'Cartão Presente', 2)
INSERT [dbo].[Pedidos] ([PedidoID], [Vendedor], [Produto], [Quantidade]) VALUES (3, N'Vendedor1', N'Celular', 4)
INSERT [dbo].[Pedidos] ([PedidoID], [Vendedor], [Produto], [Quantidade]) VALUES (4, N'Vendedor2', N'Caderno', 2)
INSERT [dbo].[Pedidos] ([PedidoID], [Vendedor], [Produto], [Quantidade]) VALUES (5, N'Vendedor2', N'Cartão Presente', 5)
INSERT [dbo].[Pedidos] ([PedidoID], [Vendedor], [Produto], [Quantidade]) VALUES (6, N'Vendedor2', N'Caneta', 5)
GO


GRANT SELECT ON dbo.Pedidos  TO Gerente;  
GRANT SELECT ON dbo.Pedidos  TO Vendedor1;  
GRANT SELECT ON dbo.Pedidos  TO Vendedor2;

GO

SELECT * FROM Pedidos


-- Criação de schema

CREATE SCHEMA Seguranca;  
GO  
  
-- Criação de função para controle dos registros

CREATE FUNCTION Seguranca.FN_FiltroLinha(@TipoUsuario AS nvarchar(50))  
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN SELECT 1 AS FN_Resultado_FiltroLinha
WHERE @TipoUsuario = USER_NAME() OR USER_NAME() = 'Gerente';  
GO


-- Criação da função para controle da politica da tabela

create SECURITY POLICY SCP_FiltroVendas  
ADD FILTER PREDICATE Seguranca.FN_FiltroLinha(Vendedor)
ON dbo.Pedidos 
WITH (STATE = on);  
GO

-- Concendendo acesso a função 

GRANT SELECT ON Seguranca.FN_FiltroLinha TO Gerente;  
GRANT SELECT ON Seguranca.FN_FiltroLinha TO Vendedor1;  
GRANT SELECT ON Seguranca.FN_FiltroLinha TO Vendedor2;  


-- Testando 

EXECUTE AS USER = 'Vendedor1';  
SELECT * FROM dbo.Pedidos ;
REVERT;  
  
EXECUTE AS USER = 'Vendedor2';  
SELECT * FROM dbo.Pedidos ;
REVERT;  
  
EXECUTE AS USER = 'Gerente';  
SELECT * FROM dbo.Pedidos ;
REVERT; 



SELECT * FROM Pedidos

ALTER SECURITY POLICY SCP_FiltroVendas WITH ( STATE = OFF );  

SELECT * FROM Pedidos
