 -- MODULO 5 Pre-entrega: Consultas con JOINs para el proyecto -- 


 -- Consulta 1 — Vista base del proyecto (INNER JOIN) -- 

 SELECT 
	v.id_venta, v.id_cliente, v.id_producto, v.cantidad as cantidad_vendida, v.precio_unitario as precio_unitario_venta, v.fecha_venta,
	cl.nombre as nombre_cliente, cl.email as cliente_mail, cl.ciudad as ciudad_cliente, cl.id_segmento,
	pr.nombre_producto, pr.id_categoria,
	seg.nombre_segmento,
	cat.nombre_categoria, cat.descripcion

 FROM ventas as v 
 INNER JOIN clientes   as cl  ON v.id_cliente = cl.id_cliente
 INNER JOIN productos  as pr  ON v.id_producto = pr.id_producto
 INNER JOIN segmentos  as seg ON cl.id_segmento = seg.id_segmento
 INNER JOIN categorias as cat ON pr.id_categoria = cat.id_categoria

 -- Agregamos la tabla "segmentos"-

 ---- CREATE TABLE | segmentos --

CREATE TABLE segmentos(
    id_segmento      INT          PRIMARY KEY,
    nombre_segmento  VARCHAR(50)  NOT NULL
);


-- Insertamos los datos en la tabla segmentos -- 

INSERT INTO segmentos (id_segmento, nombre_segmento) VALUES
  (1, 'Minorista'),
  (2, 'Mayorista'),
  (3, 'Corporativo');

 -- Actualizamos la tabla "clientes" para agregarle los segmentos --
  
ALTER TABLE clientes
ADD id_segmento INT;

-- Cargamos los valores (UPDATE) --

UPDATE clientes SET id_segmento = 3 WHERE id_cliente IN (1, 5);
UPDATE clientes SET id_segmento = 2 WHERE id_cliente = 2;
UPDATE clientes SET id_segmento = 1 WHERE id_cliente IN (3, 4);

-- Agregamos la foreign key (ALTER) --

ALTER TABLE    clientes
ADD CONSTRAINT fk_clientes_segmentos
FOREIGN KEY    (id_segmento) REFERENCES segmentos(id_segmento);



-- Consulta 2  — Clientes sin ventas (LEFT JOIN -- 

-- Propósito: detectar clientes registrados que nunca compraron, para que CRM los contacte.

SELECT 
	cl.id_cliente, cl.nombre, cl.email, cl.fecha_registro,
	v.id_venta

FROM clientes    AS cl  

LEFT JOIN ventas AS v ON cl.id_cliente = v.id_cliente

WHERE v.id_venta is NULL; 

-- Hallazgo: 0 registros. Los 5 clientes registrados realizaron al menos una compra
-- (2 cada uno), por lo que CRM no tiene clientes inactivos para contactar.



-- Consulta 3 — Productos sin ventas (LEFT JOIN) -- 

-- Propósito: detectar productos que nunca se vendieron, para que el área de producto
-- revise su precio, su stock o su continuidad.

SELECT 
	pr.id_producto, pr.nombre_producto, pr.id_categoria, pr.precio,
	v.id_venta
	

FROM productos   AS pr

LEFT JOIN ventas AS v ON pr.id_producto = v.id_producto

WHERE V.id_venta IS NULL;

-- Hallazgo: 0 registros. Los 6 productos activos se vendieron al menos una vez,
-- por lo que el área de producto no tiene artículos sin rotación para revisar.


-- Consulta 4 — Consolidado por canal (UNION ALL) -- 

-- Propósito: comparar la facturación de cada canal de venta.
-- Supuesto: las ventas hasta el 10/03/2024 son Online y las posteriores, Presencial.

SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Online' AS canal
    FROM ventas
    WHERE fecha_venta <= '2024-03-10'

    UNION ALL

    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Presencial' AS canal
    FROM ventas
    WHERE fecha_venta > '2024-03-10'
) AS consolidado
GROUP BY canal;

-- Hallazgo: el canal Online facturó $3.620 (56%) contra $2.824 (44%) del Presencial,
-- con 5 ventas cada uno.
