/* 
    Crear como base el store (Inserta un producto)
    Crear un store que permita agregar n productos.
    Tabla tipo type (Enviar como parametro al store)
    Parametros:
    - id_cliente
    - cantidad
    -tabla type

    SELECT
        cliente_id,
        orderDate,
        SUM(od.quantity * od.unitPrice) OVER (PARTITION BY order by ASC)
    FROM @TYPE
*/
USE bdpracticas;
GO

CREATE TYPE dbo.TypeDetalleVenta AS TABLE
(
    id_producto INT NOT NULL,
    cantidad_vendido INT NOT NULL
);
GO

CREATE OR ALTER PROCEDURE dbo.usp_agregar_venta_multiple
    @id_cliente NCHAR(5),
    @detalle dbo.TypeDetalleVenta READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        -- 1. Validar cliente
        IF NOT EXISTS (SELECT 1 FROM dbo.CatCliente WHERE Id_cliente = @id_cliente)
        BEGIN
            THROW 50001, 'Error: el cliente no existe.', 1;
        END

        -- 2. Validar que la tabla no venga vacía
        IF NOT EXISTS (SELECT 1 FROM @detalle)
        BEGIN
            THROW 50002, 'Error: debe enviar al menos un producto en la lista.', 1;
        END

        -- 3. Validar cantidades negativas o en cero
        IF EXISTS (SELECT 1 FROM @detalle WHERE cantidad_vendido <= 0)
        BEGIN
            THROW 50003, 'Error: la cantidad vendida debe ser mayor a 0.', 1;
        END

        -- 4. Validar que no manden el mismo producto dos veces en la lista
        IF EXISTS (SELECT id_producto FROM @detalle GROUP BY id_producto HAVING COUNT(*) > 1)
        BEGIN
            THROW 50004, 'Error: no se debe repetir el mismo producto en la lista.', 1;
        END

        -- 5. Validar que TODOS los productos existan en el catálogo
        IF EXISTS (
            SELECT 1 
            FROM @detalle d
            LEFT JOIN dbo.CatProducto p ON d.id_producto = p.id_producto
            WHERE p.id_producto IS NULL
        )
        BEGIN
            THROW 50005, 'Error: uno o más productos de la lista no existen en el catálogo.', 1;
        END

        -- 6. Validar que haya stock suficiente para TODOS los productos
        -- CORRECTED: Changed p.existencia to p.existencias
        IF EXISTS (
            SELECT 1 
            FROM @detalle d
            INNER JOIN dbo.CatProducto p ON d.id_producto = p.id_producto
            WHERE d.cantidad_vendido > p.existencias 
        )
        BEGIN
            THROW 50006, 'Error: no hay existencia suficiente para uno o más productos.', 1;
        END

        -- Si el código llega aquí, todas las reglas de negocio se cumplieron.
        -- Abrimos la transacción para afectar las tablas físicas.
        BEGIN TRANSACTION;

            -- 7. Insertar cabecera de la venta
            INSERT INTO dbo.TblVenta (fecha, Id_cliente)
            VALUES (GETDATE(), @id_cliente);

            DECLARE @id_venta INT = SCOPE_IDENTITY();

            -- 8. Insertar todo el detalle de un solo golpe
            -- CORRECTED: Changed Fk_Id_venta to id_Venta and Fk_id_producto to id_producto
            INSERT INTO dbo.TblDetalleVenta (id_Venta, id_producto, precio_venta, cantidad_vendida)
            SELECT 
                @id_venta,
                d.id_producto,
                p.precio,
                d.cantidad_vendido
            FROM @detalle d
            INNER JOIN dbo.CatProducto p ON d.id_producto = p.id_producto;

            -- 9. Descontar el stock de un solo golpe
            -- CORRECTED: Changed p.existencia to p.existencias
            UPDATE p
            SET p.existencias = p.existencias - d.cantidad_vendido
            FROM dbo.CatProducto p
            INNER JOIN @detalle d ON p.id_producto = d.id_producto;

        COMMIT TRANSACTION;
        PRINT 'Venta múltiple registrada correctamente.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
        
        PRINT 'Falló la transacción:';
        PRINT ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- Ejemplo
DECLARE @Carrito dbo.TypeDetalleVenta;

INSERT INTO @Carrito (Id_producto, cantidad_vendido)
VALUES 
    (1, 2), 
    (2, 5);  

EXEC dbo.usp_agregar_venta_multiple 
    @id_cliente = 'ALFKI', 
    @detalle = @Carrito;

SELECT * FROM TblVenta;
SELECT * FROM TblDetalleVenta;


