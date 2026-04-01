# Documentación: Venta Múltiple con Stored Procedure y Table Types



## 1. Creación del Molde (Table Type)
SQL Server no permite pasar arreglos directamente a un procedure. Para solucionarlo, creamos un `TYPE` que funciona como una plantilla estructural. 

Este "molde" define cómo se verá la lista de productos que el cliente quiere comprar.

```sql
CREATE TYPE dbo.TypeDetalleVenta AS TABLE
(
    id_producto INT NOT NULL,
    cantidad_vendido INT NOT NULL
);
GO
```

## 2. Lógica del Stored Procedure
El procedimiento `usp_agregar_venta_multiple` recibe el ID del cliente y la lista de compras. Está estructurado en dos fases: **Validaciones** y **Transacción**.

### Fase A: Validaciones de Reglas de Negocio
Antes de modificar las tablas físicas, el motor cruza la tabla temporal con los catálogos usando lógica de conjuntos (`IF EXISTS` y `JOINs`) para asegurar la integridad de los datos de forma masiva:

* **Validar Cliente:** Revisa en `CatCliente` si el ID proporcionado es válido.
* **Lista Vacía:** Verifica que la variable `@detalle` traiga al menos un producto.
* **Cantidades Positivas:** Bloquea la venta si detecta cantidades en 0 o negativas para evitar inyección de stock falso.
* **Sin Duplicados:** Usa un `GROUP BY ... HAVING COUNT(*) > 1` para asegurar que el mismo producto no venga dos veces en la lista.
* **Existencia en Catálogo:** Mediante un `LEFT JOIN`, verifica que todos los productos de la lista existan realmente en `CatProducto`.
* **Stock Suficiente:** Mediante un `INNER JOIN`, compara la cantidad solicitada contra las `existencias` físicas. Si un solo producto rebasa el stock, toda la operación se detiene.

### Fase B: Transacción Física
Si todas las validaciones pasan, se abre el `BEGIN TRANSACTION` y se ejecutan las inserciones de forma masiva (Set-Based):

1.  **Cabecera:** Se inserta el cliente y la fecha en `TblVenta`.
2.  **Identidad:** Capturamos el ID de la venta generada usando `SCOPE_IDENTITY()`.
3.  **Detalle Masivo:** Insertamos todos los registros en `TblDetalleVenta` usando un `INSERT INTO ... SELECT`, cruzando la lista temporal con `CatProducto` para obtener los precios actuales de un solo golpe.
4.  **Actualización de Stock:** Restamos las cantidades vendidas en la tabla `CatProducto` usando un `UPDATE` con `INNER JOIN`.

```sql
-- Fragmento clave de la actualización de stock masiva
UPDATE p
SET p.existencias = p.existencias - d.cantidad_vendido
FROM dbo.CatProducto p
INNER JOIN @detalle d ON p.id_producto = d.id_producto;
```


## 3. Ejecución y Pruebas
Para probar el Stored Procedure, es necesario declarar una variable temporal en memoria basada en nuestro `TYPE`, llenarla de datos y pasarla como parámetro. 

**Importante:** Todo este bloque debe seleccionarse y ejecutarse en conjunto para que la variable `@Carrito` no se pierda de la memoria.

```sql
-- 1. Declarar la variable temporal usando el molde
DECLARE @Carrito dbo.TypeDetalleVenta;

-- 2. Llenar el carrito con los productos a vender
INSERT INTO @Carrito (Id_producto, cantidad_vendido)
VALUES 
    (1, 2),  -- Vender 2 unidades del producto 1
    (2, 5);  -- Vender 5 unidades del producto 2

-- 3. Ejecutar el procedure pasando los parámetros
EXEC dbo.usp_agregar_venta_multiple 
    @id_cliente = 'ALFKI', 
    @detalle = @Carrito;

-- 4. Validar el resultado
SELECT * FROM TblVenta;
SELECT * FROM TblDetalleVenta;
```
