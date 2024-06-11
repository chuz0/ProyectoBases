CREATE TABLE Clientes (
    Id INT PRIMARY KEY,
    Nombre VARCHAR(255),
    Direccion VARCHAR(255),
    Telefono VARCHAR(20)
);

CREATE TABLE Contratos (
    Id INT PRIMARY KEY,
    IdCliente INT,
    FechaFirma DATE,
    TipoTelefono VARCHAR(50),
    IdTipoTarifa INT,
    FOREIGN KEY (IdCliente) REFERENCES Clientes(Id),
    FOREIGN KEY (IdTipoTarifa) REFERENCES TiposTarifa(Id)
);

CREATE TABLE TiposTarifa (
    Id INT PRIMARY KEY,
    Nombre VARCHAR(255)
);

CREATE TABLE TiposUnidades (
    Id INT PRIMARY KEY,
    Tipo VARCHAR(255)
);

CREATE TABLE TiposElemento (
    Id INT PRIMARY KEY,
    Nombre VARCHAR(255),
    IdTipoUnidad INT,
    EsFijo BOOLEAN,
    Valor DECIMAL(10, 2) NULL,
    FOREIGN KEY (IdTipoUnidad) REFERENCES TiposUnidades(Id)
);

CREATE TABLE ElementosDeTipoTarifa (
    Id INT PRIMARY KEY,
    IdTipoTarifa INT,
    IdTipoElemento INT,
    Valor DECIMAL(10, 2),
    FOREIGN KEY (IdTipoTarifa) REFERENCES TiposTarifa(Id),
    FOREIGN KEY (IdTipoElemento) REFERENCES TiposElemento(Id)
);

CREATE TABLE TipoRelacionesFamiliar (
    Id INT PRIMARY KEY,
    Nombre VARCHAR(255)
);

CREATE TABLE Llamadas (
    Id INT PRIMARY KEY,
    IdContrato INT,
    FechaHoraInicio DATETIME,
    FechaHoraFin DATETIME,
    Destino VARCHAR(20),
    DuracionMinutos INT,
    TipoTarifa VARCHAR(50),
    TipoEmpresaDestino VARCHAR(1),
    EsFamiliar BOOLEAN,
    FOREIGN KEY (IdContrato) REFERENCES Contratos(Id)
);

CREATE TABLE DetallesLlamadas (
    Id INT PRIMARY KEY,
    IdLlamada INT,
    IdTipoElemento INT,
    Valor DECIMAL(10, 2),
    FOREIGN KEY (IdLlamada) REFERENCES Llamadas(Id),
    FOREIGN KEY (IdTipoElemento) REFERENCES TiposElemento(Id)
);

CREATE TABLE CorteMensual (
    Id INT PRIMARY KEY,
    FechaCorte DATE,
    MinutosEntrantesEmpresaX INT,
    MinutosEntrantesEmpresaY INT,
    MinutosSalientesEmpresaX INT,
    MinutosSalientesEmpresaY INT,
    TotalMinutos INT
);

CREATE TABLE Facturas (
    Id INT PRIMARY KEY,
    IdContrato INT,
    FechaEmision DATE,
    FechaVencimiento DATE,
    Monto DECIMAL(10, 2),
    Estado VARCHAR(50),
    IVA DECIMAL(10, 2),
    MontoFijo911 DECIMAL(10, 2),
    MontoFijo110 DECIMAL(10, 2),
    MontoFijoOtros DECIMAL(10, 2),
    MinutosTotales INT,
    MinutosFamiliares INT,
    MinutosAdicionales INT,
    FOREIGN KEY (IdContrato) REFERENCES Contratos(Id)
);

CREATE TABLE PagosFactura (
    Id INT PRIMARY KEY,
    IdFactura INT,
    FechaPago DATE,
    Monto DECIMAL(10, 2),
    FOREIGN KEY (IdFactura) REFERENCES Facturas(Id)
);

CREATE TABLE EstadoCuentaEmpresas (
    Id INT PRIMARY KEY,
    FechaCorte DATE,
    Empresa VARCHAR(1),
    TotalMinutosEntrantes INT,
    TotalMinutosSalientes INT
);

CREATE TABLE DetalleEstadoCuentaEmpresas (
    Id INT PRIMARY KEY,
    IdEstadoCuenta INT,
    NumeroTelefonoOrigen VARCHAR(20),
    NumeroTelefonoDestino VARCHAR(20),
    FechaHoraInicio DATETIME,
    FechaHoraFin DATETIME,
    Minutos INT,
    TipoTarifa VARCHAR(50),
    FOREIGN KEY (IdEstadoCuenta) REFERENCES EstadoCuentaEmpresas(Id)
);

CREATE TABLE Historial_Clientes (
    id INT PRIMARY KEY,
    id_cliente INT,
    accion VARCHAR(50),
    fecha_registro DATETIME
);