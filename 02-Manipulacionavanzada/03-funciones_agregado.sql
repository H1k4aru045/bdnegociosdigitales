/*
	Funciones de agregado:
	1. sum()
	2. max()
	3. min()
	4. avg()
	5. count(*)
	6. count(campo)

	Nota: Estas funciones solamente regresan un solo registro
*/

-- Seleccionar los paises dde donde son los clientes

SELECT DISTINCT
	Country
FROM Customers;

-- Seleccionar el total de ordenes que fueron enviadas a Alemania

SELECT COUNT(*) AS [Total de Ordenes Enviadas]
FROM Orders
WHERE ShipCountry = 'Germany';

SELECT ShipCountry, COUNT(*) AS [Total de Ordenes Enviadas]
FROM Orders
GROUP BY ShipCountry;

-- Agregaci�n count(+) cuenta el numero de registros que tiene una tabla

SELECT COUNT(*) AS [Total de Ordenes]
FROM Orders;

SELECT *
FROM Customers;

SELECT COUNT(CustomerID)
FROM Customers;

SELECT COUNT(Region)
FROM Customers;

-- Selecciona de cuantas ciudades son las ciudades de los clientes

SELECT City
FROM Customers;

SELECT COUNT(City)
FROM Customers;

SELECT DISTINCT City
FROM Customers
ORDER BY City ASC;

SELECT COUNT(DISTINCT City) AS [CIUDADES CLIENTES]
FROM Customers;

-- Selecciona el precio m�ximo de los productos

SELECT *
FROM Products
ORDER BY UnitPrice DESC;

SELECT MAX(UnitPrice) AS [Precio Mas Alto]
FROM Products;

-- Seleccionar la fecha de compra mas actual

SELECT *
FROM Orders;

SELECT MAX(OrderDate) AS [Orden mas reciente]
FROM Orders;

-- Seleccionar el a�o de la fecha de compra mas reciente

SELECT MAX(YEAR(OrderDate)) AS [A�o mas reciente]
FROM Orders;
-- Son lo mismo 
SELECT MAX(DATEPART(YEAR, OrderDate)) AS [A�o mas reciente]
FROM Orders;

-- Cual es la minima cantidad de los pedidos

SELECT *
FROM [Order Details];

SELECT MIN(Quantity) AS [Cantidad Minima]
FROM [Order Details];

-- Cual es el importe m�s bajo de las compras

SELECT (UnitPrice * Quantity * (1-Discount)) AS [Importe]
FROM [Order Details]
ORDER BY [Importe] ASC;

SELECT (UnitPrice * Quantity * (1-Discount)) AS [Importe]
FROM [Order Details]
ORDER BY (UnitPrice * Quantity * (1-Discount)) ASC;

SELECT (UnitPrice * Quantity * (1-Discount)) AS [Importe]
FROM [Order Details]
ORDER BY 1 ASC;

SELECT MIN((UnitPrice * Quantity * (1-Discount))) AS [Importe mas bajo]
FROM [Order Details];

-- Quieron el total de los precio de los productos

SELECT *
FROM Products;

SELECT SUM(UnitPrice) AS [Total de Productos]
FROM Products;

-- Obtener el total de dinero percibido por las ventas

SELECT *
FROM [Order Details];

SELECT SUM(UnitPrice * Quantity * (1-Discount)) AS [Importe]
FROM [Order Details];

-- Cuanto se vendio del producto 4, 10 y 20

SELECT *
FROM [Order Details];

SELECT SUM(UnitPrice * Quantity * (1-Discount)) AS [Importe]
FROM [Order Details]
WHERE ProductID IN (4, 10, 20)
GROUP BY ProductID;

-- Seleccionar el numero de ordenes hechas por los siguientes clientes:
-- Around the Horn, Bolido Comidas Preparadas, Chop-suey Chinese

SELECT *
FROM Customers;

SELECT *
FROM Orders;

SELECT *
FROM [Order Details];

SELECT COUNT(CustomerID) AS [PEDIDOS DE LOS 3], CustomerID
FROM Orders
WHERE CustomerID IN ('AROUT', 'BOLID', 'CHOPS')
GROUP BY CustomerID;

-- Seleccionar el total de ordenes del segundo trimestre de 1995

SELECT *
FROM Orders;

SELECT COUNT(*) AS TotalOrdenes_1997
FROM Orders
WHERE DATEPART(QUARTER, OrderDate) = 2
AND DATEPART(YEAR, OrderDate) = 1997

-- Seleccionar el numero de ordenes entre 1996 a 1997

SELECT *
FROM Orders;

SELECT COUNT(*) AS [ORDENES ENTRE 1991 A 1994]
FROM Orders
WHERE YEAR(OrderDate) BETWEEN 1996 AND 1997;

-- Seleccionar el numero de clientes que comienzan con A o que comiencen con B

SELECT *
FROM Customers;

SELECT COUNT(CompanyName) AS [CLIENTES QUE COMIENCEN CON A Y B]
FROM Customers
WHERE CompanyName LIKE 'a%' OR CompanyName LIKE 'b%';

-- Seleccionar el numero de clientes que comienzan con B y que terminen con S

SELECT *
FROM Customers;

SELECT COUNT(CompanyName) AS [CLIENTES QUE COMIENCEN CON A Y B]
FROM Customers
WHERE CompanyName LIKE 'b%s';

-- Seleccionar el numero de ordenes realizadas por el cliente Chop-suey Chinese en 1996 'CHOPS'

SELECT *
FROM Orders
ORDER BY CustomerID ASC;

SELECT COUNT(CustomerID) AS [Numero de Ordenes en 1996], CustomerID
FROM Orders
WHERE YEAR(OrderDate) = 1996 AND CustomerID = 'CHOPS'
GROUP BY CustomerID;

/*
	GROUP BY Y HAVING
*/

SELECT  
	COUNT(*) AS [Numero de Ordenes]
FROM Orders;

SELECT 
	Customers.CompanyName, 
	COUNT(*) AS [Numero de Ordenes]
FROM Orders
INNER JOIN
Customers
ON Orders.CustomerID = Customers.CustomerID
GROUP BY Customers.CompanyName
ORDER BY 2 DESC;

SELECT 
	c.CompanyName, 
	COUNT(*) AS [Numero de Ordenes]
FROM Orders AS o
INNER JOIN
Customers AS c
ON o.CustomerID = c.CustomerID
GROUP BY c.CompanyName
ORDER BY 2 DESC;

-- Seleccionar el numero de productos (Conteo) por categoria, mostrar CategoriaID, TotaldeProductos
-- Ordenarlos de mayor a menor por el totaldeproductos

SELECT *
FROM Products;

SELECT 
	CategoryID,
	COUNT(UnitsInStock) AS [Total de Productos]
FROM Products
GROUP BY CategoryID
ORDER BY 2 DESC;

-- Seleccionar el precio promedio por provedor de los productos
-- Redondear a dos decimales el resultado
-- Ordenar de forma descendente por el precio promedio

SELECT *
FROM Products;

SELECT 
	SupplierID,
	ROUND(SUM(UnitPrice/ SupplierID),2) AS [Promedio por provedor]
FROM Products
GROUP BY SupplierID
ORDER BY 2 DESC;

-- Seleccionar el numero de clientes por pais
-- Ordenarlos por Pais alfabeticamente

SELECT *
FROM Customers;

SELECT
	COUNT(*) AS [Numero de Clientes],
	Country
FROM Customers
GROUP BY Country;

-- Obtener la Cantidad Total vendida agrupada por producto y por pedido

SELECT *
FROM [Order Details];

SELECT
	SUM(UnitPrice * Quantity) AS [Total]
FROM [Order Details];

SELECT
	ProductID,
	SUM(UnitPrice * Quantity) AS [Total]
FROM [Order Details]
GROUP BY ProductID
ORDER BY ProductID;

SELECT
	ProductID,
	OrderID,
	SUM(UnitPrice * Quantity) AS [Total]
FROM [Order Details]
GROUP BY ProductID, OrderID
ORDER BY ProductID, Total DESC;

SELECT *, (UnitPrice * Quantity) AS [Total]
FROM [Order Details]
WHERE OrderID = 10847 AND ProductID = 1;

-- Seleccionar la cantidad maxima vendida por producto en cada pedido

SELECT *
FROM [Order Details];

SELECT
	ProductID,
	OrderID,
	MAX(Quantity) AS [Cantidad Maxima]
FROM [Order Details]
GROUP BY ProductID, OrderID
ORDER BY ProductID, OrderID;

/*
Flujo Logico de Ejecucion en SQL

	1. FROM
	2. JOIN
	3. WHERE
	4. GROUP
	5. HAVING
	6. SELECT
	7. DISTINCT
	8. ORDER BY
*/


-- HAVING (Filtro pero de Grupos)

-- Seleccionar los clientes que hayan realizado mas de 10 pedidos

SELECT CustomerID,Count(*) AS [Numero de Ordenes]
FROM Orders
GROUP BY CustomerID
HAVING COUNT(*) > 10
ORDER BY 2 DESC;


SELECT C.CompanyName,Count(*) AS [Numero de Ordenes]
FROM Orders AS O
INNER JOIN Customers AS C
ON O.CustomerID = C.CustomerID
GROUP BY C.CompanyName
HAVING COUNT(*) > 10
ORDER BY 2 DESC;

-- Seleccionar los empleados que hayan gestionado pedido por un total superior a 100k en ventas 
-- (Mostrar el id y el nombre del empleado, tota compras)

SELECT 
	CONCAT(E.FirstName,' ',E.LastName) AS [Nombre Completo],
	ROUND(SUM(OD.Quantity * OD.UnitPrice * (1 - Discount)),2) AS [IMPORTE]
FROM Employees AS E
INNER JOIN Orders AS O
ON E.EmployeeID = O.EmployeeID
INNER JOIN [Order Details] AS OD
ON O.OrderID = OD.OrderID
GROUP BY E.FirstName,E.LastName
HAVING 	SUM(OD.Quantity * OD.UnitPrice * (1 - Discount))>100000
ORDER BY [IMPORTE] DESC;


-- Seleccionar el numero de productos vendidos en mas de 20 pedidos distintos
-- Mostrar el id del producto, el nombre del producto, numero de ordenes

SELECT 
	P.ProductID,
	P.ProductName, 
	COUNT(DISTINCT O.OrderID) AS [Numero de Ordenes] 
FROM Products AS P
INNER JOIN [Order Details] AS OD
ON OD.ProductID = P.ProductID
INNER JOIN Orders AS O
ON O.OrderID = OD.OrderID
GROUP BY 
	P.ProductID,
	P.ProductName
HAVING COUNT(DISTINCT O.OrderID) > 20;

-- Seleccionar los productos no descontinuados, calcular el precio promedio vendido
-- y mostrar solo aquellos que se hayan vendido en menos de 15 pedidos
SELECT P.ProductName,ROUND(AVG(OD.UnitPrice),2) AS [Promedio Vendido]
FROM Products AS P
INNER JOIN [Order Details] AS OD
ON OD.ProductID = P.ProductID
WHERE P.Discontinued = 0
GROUP BY P.ProductName
HAVING COUNT(OrderID) < 15;

-- Seleccionar el precio maximo de productos por categoria pero solo si la suma de unidades es menor a 200
-- Y ademas que no esten descontinuados
SELECT 
	C.CategoryID,
	C.CategoryName,
	P.ProductName,
	MAX(P.UnitPrice) AS [Suma Unidades]
FROM Products AS P
INNER JOIN Categories AS C
ON P.CategoryID = C.CategoryID
WHERE Discontinued = 0
GROUP BY C.CategoryID,
		 C.CategoryName,
		 P.ProductName
HAVING SUM(P.UnitsInStock) < 200
ORDER BY CategoryName DESC,P.ProductName ASC;

SELECT * FROM [Order Details];

