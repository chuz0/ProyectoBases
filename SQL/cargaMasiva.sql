ALTER PROCEDURE CargarDatosDesdeXML
    @ConfigXML XML
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION; 

        INSERT INTO TipoTarifa(Id, Nombre)
        SELECT 
            TiposTarifa.value('@id', 'int') AS Id
            TiposTarifa.value('@nombre', 'varchar(50)') AS Nombre
        FROM @ConfigXML.nodes('/Data/TiposTarifa/TipoTarifa') AS Tbl(TipoTarifa);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;

        ROLLBACK TRANSACTION;
    END CATCH;
END