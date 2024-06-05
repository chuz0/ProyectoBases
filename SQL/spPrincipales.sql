-- Eliminar el procedimiento almacenado existente si existe
IF OBJECT_ID('InsertarNuevoCliente', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE InsertarNuevoCliente;
END
GO

-- Crear el procedimiento almacenado de nuevo
CREATE PROCEDURE InsertarNuevoCliente
    @nombre VARCHAR(255),
    @direccion VARCHAR(255),
    @telefono VARCHAR(20)
AS
BEGIN
    INSERT INTO Clientes (Nombre, Direccion, Telefono)
    VALUES (@nombre, @direccion, @telefono);
END
GO

-- Eliminar el procedimiento almacenado existente si existe
IF OBJECT_ID('InsertarNuevoContrato', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE InsertarNuevoContrato;
END
GO

-- Crear el procedimiento almacenado de nuevo
CREATE PROCEDURE InsertarNuevoContrato
    @idCliente INT,
    @fechaFirma DATE,
    @tipoTelefono VARCHAR(50),
    @idTipoTarifa INT
AS
BEGIN
    INSERT INTO Contratos (IdCliente, FechaFirma, TipoTelefono, IdTipoTarifa)
    VALUES (@idCliente, @fechaFirma, @tipoTelefono, @idTipoTarifa);
END
GO

-- Eliminar el procedimiento almacenado existente si existe
IF OBJECT_ID('AsociarRelacionFamiliar', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE AsociarRelacionFamiliar;
END
GO

-- Crear el procedimiento almacenado de nuevo
CREATE PROCEDURE AsociarRelacionFamiliar
    @idCliente1 INT,
    @idCliente2 INT,
    @tipoRelacion VARCHAR(50)
AS
BEGIN
    INSERT INTO RelacionesFamiliares (IdCliente1, IdCliente2, TipoRelacion)
    VALUES (@idCliente1, @idCliente2, @tipoRelacion);
END
GO

-- Eliminar el procedimiento almacenado existente si existe
IF OBJECT_ID('RegistrarNuevaLlamada', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE RegistrarNuevaLlamada;
END
GO

-- Crear el procedimiento almacenado de nuevo
CREATE PROCEDURE RegistrarNuevaLlamada
    @idContrato INT,
    @fechaHoraInicio DATETIME,
    @fechaHoraFin DATETIME,
    @destino VARCHAR(20),
    @tipoTarifa VARCHAR(50),
    @tipoEmpresaDestino CHAR(1),
    @esFamiliar BIT
AS
BEGIN
    INSERT INTO Llamadas (IdContrato, FechaHoraInicio, FechaHoraFin, Destino, TipoTarifa, TipoEmpresaDestino, EsFamiliar)
    VALUES (@idContrato, @fechaHoraInicio, @fechaHoraFin, @destino, @tipoTarifa, @tipoEmpresaDestino, @esFamiliar);
END
GO

-- Eliminar el procedimiento almacenado existente si existe
IF OBJECT_ID('RegistrarUsoDatos', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE RegistrarUsoDatos;
END
GO

-- Crear el procedimiento almacenado de nuevo
CREATE PROCEDURE RegistrarUsoDatos
    @idContrato INT,
    @fecha DATETIME,
    @cantidadGigas DECIMAL(10, 2)
AS
BEGIN
    INSERT INTO UsoDatos (IdContrato, Fecha, CantidadGigas)
    VALUES (@idContrato, @fecha, @cantidadGigas);
END
GO

-- Eliminar el procedimiento almacenado existente si existe
IF OBJECT_ID('PagarFacturaPendiente', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE PagarFacturaPendiente;
END
GO

-- Crear el procedimiento almacenado de nuevo
CREATE PROCEDURE PagarFacturaPendiente
    @idContrato INT
AS
BEGIN
    DECLARE @idFactura INT;
    SELECT TOP 1 @idFactura = Id
    FROM Facturas
    WHERE IdContrato = @idContrato AND Estado = 'Pendiente'
    ORDER BY FechaEmision ASC;
    
    IF @idFactura IS NOT NULL
    BEGIN
        UPDATE Facturas
        SET Estado = 'Pagado'
        WHERE Id = @idFactura;
    END
END
GO

-- Eliminar el procedimiento almacenado existente si existe
IF OBJECT_ID('CerrarFactura', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE CerrarFactura;
END
GO

-- Crear el procedimiento almacenado de nuevo
CREATE PROCEDURE CerrarFactura
    @fecha DATE
AS
BEGIN
    DECLARE @idContrato INT;
    DECLARE @idFactura INT;
    DECLARE @monto DECIMAL(10, 2);
    DECLARE @minutosTotales INT;
    DECLARE @minutosAdicionales INT;
    DECLARE @minutosFamiliares INT;
    DECLARE @usoDatos DECIMAL(10, 2);
    DECLARE @iva DECIMAL(10, 2);
    DECLARE @monto911 DECIMAL(10, 2);
    DECLARE @monto110 DECIMAL(10, 2);
    DECLARE @montoOtros DECIMAL(10, 2);
    DECLARE @multaMorosidad DECIMAL(10, 2);

    DECLARE contratoCursor CURSOR FOR
        SELECT Id 
        FROM Contratos 
        WHERE DATEADD(MONTH, 1, FechaFirma) = @fecha;

    OPEN contratoCursor;
    FETCH NEXT FROM contratoCursor INTO @idContrato;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calcular los cargos de la factura
        SELECT @monto = SUM(Valor) 
        FROM ElementosDeTipoTarifa 
        WHERE IdTipoTarifa = (SELECT IdTipoTarifa FROM Contratos WHERE Id = @idContrato);
        
        SELECT @minutosTotales = SUM(DATEDIFF(MINUTE, FechaHoraInicio, FechaHoraFin)) 
        FROM Llamadas 
        WHERE IdContrato = @idContrato AND CAST(FechaHoraFin AS DATE) = @fecha;
        
        SELECT @minutosFamiliares = SUM(CASE WHEN EsFamiliar = 1 THEN DATEDIFF(MINUTE, FechaHoraInicio, FechaHoraFin) ELSE 0 END) 
        FROM Llamadas 
        WHERE IdContrato = @idContrato AND CAST(FechaHoraFin AS DATE) = @fecha;
        
        SELECT @minutosAdicionales = SUM(CASE WHEN EsFamiliar = 0 AND TipoTarifa != 'Familiar' THEN DATEDIFF(MINUTE, FechaHoraInicio, FechaHoraFin) ELSE 0 END) 
        FROM Llamadas 
        WHERE IdContrato = @idContrato AND CAST(FechaHoraFin AS DATE) = @fecha;
        
        SELECT @usoDatos = SUM(CantidadGigas) 
        FROM UsoDatos 
        WHERE IdContrato = @idContrato AND CAST(Fecha AS DATE) = @fecha;

        -- Agregar cargos fijos
        SET @monto911 = 1300;
        SET @monto110 = 20 * (SELECT SUM(DATEDIFF(MINUTE, FechaHoraInicio, FechaHoraFin)) FROM Llamadas WHERE IdContrato = @idContrato AND Destino = '110' AND CAST(FechaHoraFin AS DATE) = @fecha);
        SET @montoOtros = 0; -- Otros cargos fijos si los hay

        -- Calcular IVA
        SET @iva = (@monto + @monto911 + @monto110 + @montoOtros) * 0.13;

        -- Calcular multa por morosidad
        SET @multaMorosidad = 0;
        SELECT TOP 1 @idFactura = Id 
        FROM Facturas 
        WHERE IdContrato = @idContrato AND Estado = 'Pendiente' 
        ORDER BY FechaEmision ASC;
        
        IF @idFactura IS NOT NULL
        BEGIN
            SET @multaMorosidad = (SELECT Valor FROM ElementosDeTipoTarifa WHERE IdTipoTarifa = (SELECT IdTipoTarifa FROM Contratos WHERE Id = @idContrato) AND IdTipoElemento = (SELECT Id FROM TiposElemento WHERE Nombre = 'Multa Morosidad'));
        END

        -- Insertar la factura
        INSERT INTO Facturas (IdContrato, FechaEmision, FechaVencimiento, Monto, Estado, IVA, MontoFijo911, MontoFijo110, MontoFijoOtros, MinutosTotales, MinutosFamiliares, MinutosAdicionales)
        VALUES (@idContrato, @fecha, DATEADD(MONTH, 1, @fecha), @monto + @monto911 + @monto110 + @montoOtros + @iva + @multaMorosidad, 'Pendiente', @iva, @monto911, @monto110, @montoOtros, @minutosTotales, @minutosFamiliares, @minutosAdicionales);

        FETCH NEXT FROM contratoCursor INTO @idContrato;
    END
    
    CLOSE contratoCursor;
END
GO

