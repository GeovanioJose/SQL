

---------------------------------------------
--SQL Data Discovery and Classification
---------------------------------------------

-- Criando uma tabela de teste

CREATE TABLE dbo.Agents
(
  AgentID  int,
  FirstName     varchar(500),
  LastName      varchar(500),
  Descont           decimal(18,2),
  Email         varchar(320),
  Address    varchar(500),
  zipcode	varchar(20)
);


-- Adicionando a classificação para a tabela TB_FUNCIONARIOS

ADD SENSITIVITY CLASSIFICATION 
TO dbo.TB_FUNCIONARIOS.Nome
WITH (LABEL = 'Highly Confidential', INFORMATION_TYPE = 'Contact Info');


ADD SENSITIVITY CLASSIFICATION 
TO dbo.TB_FUNCIONARIOS.Salario
WITH (LABEL = 'Highly Confidential', INFORMATION_TYPE = 'Financial');


-- Visualizando a classificação e descoberta
-- Tarefas > Descoberta e classificação > Classificar dados



-- Visualizando as tabelas e colunas 

	SELECT 
    schema_name(O.schema_id) AS schema_name,
    O.NAME AS table_name,
    C.NAME AS column_name,
    information_type,
    label,
    rank,
    rank_desc
FROM sys.sensitivity_classifications sc
    JOIN sys.objects O
    ON  sc.major_id = O.object_id
    JOIN sys.columns C 
    ON  sc.major_id = C.object_id  AND sc.minor_id = C.column_id


	SELECT
    schema_name(O.schema_id) AS schema_name,
    O.NAME AS table_name,
    C.NAME AS column_name,
    information_type,
    sensitivity_label 
FROM
    (
        SELECT
            IT.major_id,
            IT.minor_id,
            IT.information_type,
            L.sensitivity_label 
        FROM
        (
            SELECT
                major_id,
                minor_id,
                value AS information_type 
            FROM sys.extended_properties 
            WHERE NAME = 'sys_information_type_name'
        ) IT 
        FULL OUTER JOIN
        (
            SELECT
                major_id,
                minor_id,
                value AS sensitivity_label 
            FROM sys.extended_properties 
            WHERE NAME = 'sys_sensitivity_label_name'
        ) L 
        ON IT.major_id = L.major_id AND IT.minor_id = L.minor_id
    ) EP
    JOIN sys.objects O
    ON  EP.major_id = O.object_id 
    JOIN sys.columns C 
    ON  EP.major_id = C.object_id AND EP.minor_id = C.column_id