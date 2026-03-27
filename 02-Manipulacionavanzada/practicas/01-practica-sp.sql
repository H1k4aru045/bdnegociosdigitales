-- Crear BD > bdpracticas
-- Crear el siguiente diagrama utilizando como base los datos de NORTHWIND en las tablas de catalogo.

/*
    CatProducto     NORTHWIND.dbo.products
    - idProducto INT IDENTITY
    - nombre_Producto NVARCHAR(40)
    - existencias INT
    - precio MONEY

    CatCliente      NORTHWIND.dbo.customers
    - id_cliente NCHAR(5)
    - nombre_Cliente NVARCHAR(40)
    - pais NVARCHAR(15)
    - ciudad NVARCHAR(15)

        1
        ⬇️
        n

    TblVenta
    - id_venta PK IDENTITY
    - fecha DATE
    - id_cliente FK 

        1
        ⬇️
        n

    TblDetalleVenta
    - id_Venta INT PK FK
    - id_producto INT PK FK
    - precio_venta MONEY
    - cantidad_vendida INT
        n
        ⬇️
        1
    NORTHWIND.dbo.products



*/

-- Crear un store Procedure llamado usp_agregar_venta (TRY,CATCH,TRANSACTION)
    /* Insertar en la tabla tblVenta, la fecha debe ser la fecha actual (GETDATE()), 
    verificar si el cliente EXISTE > Store Termina */
    
    /* Insertar en la tabla tblVenta, verificar si el producto EXISTE > Store Termina 
       Obtener de la tabla catProducto el precio del producto
       Cantidad_Vendida sea suficiente en la existencia de la tabla CatProducto 
    */
 -- Actualizar la existencia del producto en la tabla CatProducto mediante la operacion de existencia - cantidad_vendida

-- Documentar todo el procedimiento de la solucion en archivo md
-- Crear un commit llamado "Practica venta con Store Procedure"
-- Hacer merge a main
-- Hacer push a github


CREATE DATABASE bdpracticas;
GO

USE bdpracticas;
GO

CREATE TABLE CatProducto (
    id_producto INT IDENTITY PRIMARY KEY,
    nombre_Producto NVARCHAR(40),
    existencias INT,
    precio MONEY
);
GO


CREATE TABLE CatCliente (
    id_cliente NCHAR(5) PRIMARY KEY,
    nombre_Cliente NVARCHAR(40),
    pais NVARCHAR(40),
    ciudad NVARCHAR(40)
);
GO

CREATE TABLE TblVenta (
    id_venta INT IDENTITY PRIMARY KEY,
    fecha DATETIME,
    id_cliente NCHAR(5) FOREIGN KEY 
    REFERENCES CatCliente(id_cliente)
);
GO

CREATE TABLE TblDetalleVenta (
    id_Venta INT,
    id_producto INT,
    precio_venta MONEY,
    cantidad_vendida INT,
    PRIMARY KEY (id_venta, id_producto),
    FOREIGN KEY (id_venta) REFERENCES TblVenta(id_venta),
    FOREIGN KEY (id_producto) REFERENCES CatProducto(id_producto)
);
GO

INSERT INTO CatCliente (Id_cliente, nombre_cliente, Pais, Ciudad)
SELECT CustomerID, ContactName, Country, City FROM NORTHWND.dbo.Customers;
GO

INSERT INTO CatProducto (nombre_Producto, existencias, precio)
SELECT ProductName, UnitsInStock, UnitPrice FROM NORTHWND.dbo.Products;
GO

CREATE OR ALTER PROC usp_agregar_venta
    @id_cliente NCHAR(5),
    @id_producto INT,
    @cantidad_vendida INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION
            -- Validación de Cliente
            IF NOT EXISTS (SELECT 1 FROM CatCliente WHERE id_cliente = @id_cliente)
            BEGIN
                THROW 50001, 'El cliente no existe.', 1;
            END

            -- Validación de Producto
            IF NOT EXISTS (SELECT 1 FROM CatProducto WHERE id_producto = @id_producto)
            BEGIN
                THROW 50002, 'El producto no existe.', 1;
            END

            -- Obtención de datos y validación de existencia
            DECLARE @precio_actual MONEY, @stock_disponible INT;
            
            SELECT @precio_actual = precio, @stock_disponible = existencias
            FROM CatProducto WHERE id_producto = @id_producto;

            IF @cantidad_vendida > @stock_disponible
            BEGIN
                THROW 50003, 'Existencias insuficientes.', 1;
            END

            -- Agregar la Venta
            INSERT INTO TblVenta (fecha, id_cliente)
            VALUES (GETDATE(), @id_cliente);

            -- Capturar el ID de la venta recién generada
            DECLARE @id_nueva_venta INT = SCOPE_IDENTITY();

            -- Actualizacion de existencias
            UPDATE CatProducto
            SET existencias = existencias - @cantidad_vendida
            WHERE id_producto = @id_producto;

            -- Generar los detalles de la venta 
            INSERT INTO TblDetalleVenta (id_venta, id_producto, precio_venta, cantidad_vendida)
            VALUES (@id_nueva_venta, @id_producto, @precio_actual, @cantidad_vendida);

        COMMIT;
        PRINT 'Venta registrada exitosamente.';
    END TRY
    BEGIN CATCH
        -- El único ROLLBACK necesario
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK;
        END
        
        PRINT 'Ocurrio un error al registrar la venta';
        PRINT 'ERROR: ' + ERROR_MESSAGE();
        
        THROW; 
    END CATCH
END;
GO

SELECT * FROM catProducto;
SELECT * FROM catCliente;
SELECT * FROM TblVenta;
SELECT * FROM TblDetalleVenta;
EXEC usp_agregar_venta 
    @id_cliente = 'OCEAN',
    @id_producto = 78,
    @cantidad_vendida = 500;