-- Leer el archivo XML
DECLARE @xml XML

SELECT @xml = BulkColumn
FROM OPENROWSET(BULK 'C:\Users\jesus\Desktop\TEC\TEC SEMESTRE I 24\BASES 1\PROYECTOS\ProyectoBases\config.xml', SINGLE_BLOB) AS x

-- Insertar datos en la tabla TiposTarifa
INSERT INTO TiposTarifa (Id, Nombre)
SELECT
    x.value('@Id', 'INT') AS Id,
    x.value('@Nombre', 'NVARCHAR(255)') AS Nombre
FROM @xml.nodes('/Data/TiposTarifa/TipoTarifa') AS T(x)

-- Insertar datos en la tabla TiposUnidades
INSERT INTO TiposUnidades (Id, Tipo)
SELECT
    x.value('@Id', 'INT') AS Id,
    x.value('@Tipo', 'NVARCHAR(255)') AS Tipo
FROM @xml.nodes('/Data/TiposUnidades/TipoUnidad') AS T(x)

-- Insertar datos en la tabla TiposElemento
INSERT INTO TiposElemento (Id, Nombre, IdTipoUnidad, EsFijo, Valor)
SELECT
    x.value('@Id', 'INT') AS Id,
    x.value('@Nombre', 'NVARCHAR(255)') AS Nombre,
    x.value('@IdTipoUnidad', 'INT') AS IdTipoUnidad,
    x.value('@EsFijo', 'BIT') AS EsFijo,
    x.value('@Valor', 'FLOAT') AS Valor
FROM @xml.nodes('/Data/TiposElemento/TipoElemento') AS T(x)

-- Insertar datos en la tabla ElementosDeTipoTarifa
;WITH Elementos AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Id,
        x.value('@idTipoTarifa', 'INT') AS idTipoTarifa,
        x.value('@IdTipoElemento', 'INT') AS IdTipoElemento,
        x.value('@Valor', 'FLOAT') AS Valor
    FROM @xml.nodes('/Data/ElementosDeTipoTarifa/ElementoDeTipoTarifa') AS T(x)
)
INSERT INTO ElementosDeTipoTarifa (Id, IdTipoTarifa, IdTipoElemento, Valor)
SELECT
    Id,
    idTipoTarifa,
    IdTipoElemento,
    Valor
FROM Elementos;

-- Insertar datos en la tabla TipoRelacionesFamiliar
INSERT INTO TipoRelacionesFamiliar (Id, Nombre)
SELECT
    x.value('@Id', 'INT') AS Id,
    x.value('@Nombre', 'NVARCHAR(255)') AS Nombre
FROM @xml.nodes('/Data/TipoRelacionesFamiliar/TipoRelacionFamiliar') AS T(x)
