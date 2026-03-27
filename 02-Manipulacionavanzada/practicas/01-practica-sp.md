# Documentación: Práctica de Ventas con Stored Procedure

## 1. Creación de la Base de Datos
Creamos la base de datos principal `bdpracticas` para manejar los catálogos y el registro de ventas.
![Código de creación de bdpracticas](/img/Practica_Imgs/image.png)

## 2. Tablas y Modelo Relacional
Armamos la estructura basándonos en los datos de `Northwind.dbo`, ajustando los tipos de datos a lo que necesitamos.

### Catálogo de Productos (`CatProducto`)
Guarda el stock y los precios. Nos trajimos la información directamente de la tabla `Products` de Northwind.
* **Campos:** `PId_producto` (PK, Identity), `nombre_Producto`, `existencia`, `precio`.
![Código de la tabla CatProducto](/img/Practica_Imgs/tabla1.png)

### Catálogo de Clientes (`CatCliente`)
Tiene la información de contacto. Los datos vienen de la tabla `Customers` de Northwind.
* **Campos:** `Id_cliente` (PK), `nombre_cliente`, `Pais`, `Ciudad`.
![Código de la tabla CatCliente](/img/Practica_Imgs/tabla2.png)

### Tabla de Ventas (`TblVenta`)
Registra los datos generales de cada ticket (la fecha y el cliente que compra).
* **Campos:** `Id_venta` (PK, Identity), `fecha`, `Id_cliente` (FK).
![Código de la tabla TblVenta](/img/Practica_Imgs/tabla3.png)

### Tabla de Detalle de Ventas (`TblDetalleVenta`)
Conecta la venta con los productos específicos, guardando a qué precio se vendió y cuántas unidades.
* **Campos:** `Fk_Id_venta` (PK, FK), `Fk_Id_producto` (PK, FK), `precio_venta`, `cantidad_vendida`.
![Código de la tabla TblDetalleVenta](/img/Practica_Imgs/tabla4.png)

*(Nota: Script usado para migrar la información desde Northwind)*
![Código de los INSERT INTO... SELECT](/img/Practica_Imgs/scriptMigra.png)

## 3. Stored Procedure: `usp_agregar_venta`
Armamos el procedure usando transacciones y un bloque `TRY...CATCH`. Si algo falla a la mitad, no se guarda nada a medias.

**Así funciona la lógica paso a paso:**
1. **Inicio de Transacción:** Abrimos la transacción para proteger los datos.
2. **Fecha de la Venta:** Usamos `GETDATE()` para registrar la hora exacta al insertar en `TblVenta`.
3. **Validar Cliente:** Revisamos si el cliente existe. Si no, abortamos la operacion con throw.
4. **Validar Producto y Stock:** Checamos que el producto exista y que la `cantidad_vendida` no sea mayor a la `existencia` actual.
5. **Guardar Detalle:** Si todo está en orden, insertamos el registro en `TblDetalleVenta`.
6. **Descontar Inventario:** Le restamos la cantidad vendida al stock de `CatProducto`.
7. **Commit/Rollback:** Si todo salió bien aplicamos los cambios; si hubo error, el Catch deshace todo.

![Código del Stored Procedure usp_agregar_venta](/img/Practica_Imgs/Proc.png)

## 5. Control de Versiones: Commit
Guardamos los cambios en el repositorio local con el nombre exacto de la práctica. Antes de esto, los archivos fueron agregados al stage usando `git add .`.

Comando ejecutado:
`git commit -m "Practica venta con Store Procedure"`

![Comando git commit](/img/Practica_Imgs/git%20commit.png)

## 6. Control de Versiones: Merge a Main
Pasamos todo el código de nuestra rama de trabajo hacia la rama principal (`main`). Primero cambiamos a main con `git checkout main` y luego fusionamos los cambios.
![Comando git checkout](/img/Practica_Imgs/git%20checkout.png)

Comando ejecutado:
`git merge <practica-sp>`

![Comando git merge](/img/Practica_Imgs/git%20merge.png)

## 7. Control de Versiones: Push a GitHub
Subimos la versión final al repositorio remoto para respaldar el proyecto.

Comando ejecutado:
`git push origin main`

![Comando git push](/img/Practica_Imgs/git%20push.png)