CREATE TRIGGER Tr_Clientes_AfterInsertUpdateDelete
ON Clientes
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Insertar un registro en Historial_Clientes con la acción realizada y la fecha actual
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        -- Si se realizó una inserción
        INSERT INTO Historial_Clientes (id_cliente, accion, fecha_registro)
        SELECT id, 'INSERT', GETDATE()
        FROM inserted;
    END;
    
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        -- Si se realizó una eliminación
        INSERT INTO Historial_Clientes (id_cliente, accion, fecha_registro)
        SELECT id, 'DELETE', GETDATE()
        FROM deleted;
    END;
    
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        -- Si se realizó una actualización
        INSERT INTO Historial_Clientes (id_cliente, accion, fecha_registro)
        SELECT id, 'UPDATE', GETDATE()
        FROM inserted;
    END;
END;