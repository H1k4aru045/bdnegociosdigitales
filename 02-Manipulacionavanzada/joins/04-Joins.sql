/**
	JOINS

	1.INNER JOIN
	2.LEFT JOIN
	3.RIGHT JOIN
	4.FULL JOIN
**/

-- Seleccionar las categorias y sus productos

SELECT 
	C.CategoryID,
	C.CategoryName,
	P.ProductID,
	P.ProductName,
	P.UnitPrice,
	P.UnitsInStock,
	(P.UnitPrice*P.UnitsInStock) AS [Precio Total del Inventario]
FROM Categories AS C
INNER JOIN Products AS P
ON C.CategoryID = P.CategoryID;

