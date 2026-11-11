 -- PRE ENTREGA 4 | Extrayendo métricas clave con SQL  --

 -- Consulta 1 --

SELECT 
    MONTH(fecha_venta)				AS mes,
    SUM(cantidad * precio_unitario) AS Total_facturado, -- ✅ Usamos SUM() para resumir
    COUNT(DISTINCT id_venta)		AS cantidad_pedidos,
	SUM(cantidad * precio_unitario) / COUNT(DISTINCT id_venta) AS ticket_promedio
FROM ventas 
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

 -- Consulta 2 --

SELECT TOP 5
	p.nombre_producto,
	SUM (v.cantidad * v.precio_unitario) AS Total_facturado,
	SUM (v.cantidad)                   AS unidades_vendidas
	
FROM ventas AS v
 LEFT JOIN productos p ON p.id_producto = v.id_producto
GROUP BY p.nombre_producto
ORDER BY Total_facturado DESC;

 -- Consulta 3 --

SELECT 
	id_cliente, 
	SUM (cantidad * precio_unitario)	AS total_gastado,
	COUNT(DISTINCT id_venta)			AS cantidad_pedidos

 FROM ventas

 GROUP BY id_cliente

 HAVING COUNT(DISTINCT id_venta) > 1

 ORDER BY total_gastado DESC;

 -- Consulta 4--

WITH ventas_por_producto AS

	 (SELECT 
		id_producto,
		SUM (cantidad * precio_unitario) AS total_producto_facturado

	 FROM ventas 
	 GROUP BY id_producto
)


 SELECT	
	id_producto,
	total_producto_facturado,
	CASE 
		WHEN total_producto_facturado >= (SELECT AVG(total_producto_facturado) FROM ventas_por_producto) THEN 'Por encima'
		ELSE 'Por debajo'
	END AS comparacion_promedio

 FROM ventas_por_producto

 ORDER BY total_producto_facturado DESC;
 
  -- BLOQUE DE CIERRE | Hallazgos

 -- 1. Alta concentración en un solo producto: la Laptop Pro 15 (id 1)
 --    facturó $3.600 de un total de $6.444, es decir el 55,9% de la
 --    facturación de marzo 2024. Es el único producto por encima del
 --    promedio por producto ($1.074); los otros 5 quedan por debajo.

 -- 2. Volumen no es igual a facturación: el Mouse Inalámbrico (id 2) es el
 --    producto con más unidades vendidas (13 de 29, el 45% de las unidades),
 --    pero solo aporta $364, el 5,6% de la facturación.

 -- 3. Clientes concentrados: María López ($2.640) y Laura Torres ($2.100)
 --    suman el 73,6% de la facturación, y ambas compraron la Laptop Pro 15.
 --    Los 5 clientes tienen exactamente 2 pedidos, por lo que el filtro
 --    HAVING > 1 de la Consulta 3 no excluye a ninguno.
