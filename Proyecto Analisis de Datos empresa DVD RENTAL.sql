---Identificar patrones de demanda.

---¿Cuál es el género más visto en cada uno de los dias de la semana?

----primero ver en cada dia de la semana cuál es el máximo de rentas
WITH CTE AS (SELECT day, MAX(category_count) AS rental_max
	FROM(SELECT to_char(rental_date, 'Day') as day, ct.name as genre, COUNT(*) as category_count
		FROM category as ct
		JOIN film_category as fc ON ct.category_id = fc.category_id
		JOIN film as f ON fc.film_id = f.film_id
		JOIN inventory as i ON f.film_id = i.film_id
		JOIN rental as r ON i.inventory_id = r.inventory_id
		GROUP BY 1,2
		ORDER BY 1) AS sub
GROUP BY 1),

------luego analizar junto con cada dia de la semana, cuál es el género con esa cantidad de rentas
CTE2 AS (SELECT to_char(rental_date, 'Day') as Day, ct.name as genre, COUNT(*) as category_count
		FROM category as ct
		JOIN film_category as fc ON ct.category_id = fc.category_id
		JOIN film as f ON fc.film_id = f.film_id
		JOIN inventory as i ON f.film_id = i.film_id
		JOIN rental as r ON i.inventory_id = r.inventory_id
		GROUP BY 1,2
		ORDER BY 1)

-----Finalmente se unen las dos cte, igualando el mes y las columnas de  max_rentas y  category_count
SELECT cte.day AS mes, cte2.genre as genero, cte.rental_max as rentas_totales
FROM cte
JOIN cte2
ON cte.day = cte2.day and cte.rental_max = cte2.category_count
ORDER BY 3 DESC;


----Identificar patrones de demanda

----¿Cuál es el género mas visto en cada mes?

----primero ver en cada mes cuál es el máximo de rentas
WITH CTE AS (SELECT month, MAX(category_count) AS rental_max
	FROM(SELECT to_char(rental_date, 'Month') as month, ct.name as genre, COUNT(*) as category_count
		FROM category as ct
		JOIN film_category as fc ON ct.category_id = fc.category_id
		JOIN film as f ON fc.film_id = f.film_id
		JOIN inventory as i ON f.film_id = i.film_id
		JOIN rental as r ON i.inventory_id = r.inventory_id
		GROUP BY 1,2
		ORDER BY 1) AS sub
GROUP BY 1),

------luego ver junto con cada mes, cuál es el genero con esa cantidad de rentas
CTE2 AS (SELECT to_char(rental_date, 'Month') as month, ct.name as genre, COUNT(*) as category_count
		FROM category as ct
		JOIN film_category as fc ON ct.category_id = fc.category_id
		JOIN film as f ON fc.film_id = f.film_id
		JOIN inventory as i ON f.film_id = i.film_id
		JOIN rental as r ON i.inventory_id = r.inventory_id
		GROUP BY 1,2
		ORDER BY 1)

-----unir las dos cte, igualando el mes y el max_rentas y el category_count
SELECT cte.month AS mes, cte2.genre as genero, cte.rental_max as rentas_totales
FROM cte
JOIN cte2
ON cte.month = cte2.month and cte.rental_max = cte2.category_count
ORDER BY 3 DESC;


---Optimizar el inventario

---¡Cuál es el genero más alquilado y cuanto genera de ingresos?

SELECT ct.name as género,
	   count(r.rental_id) as alquileres_totales,
	   sum(p.amount) as ingresos_totales	 
FROM category as ct
LEFT JOIN film_category as fc
ON ct.category_id = fc.category_id
LEFT JOIN film as f
ON fc.film_id = f.film_id
LEFT JOIN inventory as i
ON f.film_id = i.film_id
LEFT JOIN rental as r
ON i.inventory_id = r.inventory_id
LEFT JOIN payment as p
ON r.rental_id = p.rental_id
GROUP BY  1
ORDER BY alquileres_totales DESC;


----Optimizar el inventario

----¿Cualés son las peliculas con mas de 30 alquileres y mas de 100 de ingresos?
----¿En qué tiendas y en qué cantidad se encuentran en las tiendas de la empresa?

SELECT i.store_id as store, f.film_id, f.title as movie_name,  COUNT (i.film_id) as films_in_store
FROM film as f
LEFT JOIN inventory as i
ON f.film_id = i.film_id
WHERE f.film_id IN  (
			SELECT f.film_id
			FROM film as f
			LEFT JOIN inventory as i
			ON f.film_id = i.film_id
			LEFT JOIN rental as r
			ON i.inventory_id = r.inventory_id
			LEFT JOIN payment as p
			ON r.rental_id = p.rental_id
			GROUP BY 1
			HAVING  COUNT (r.rental_id) > 30 and SUM(p.amount) > 100)
GROUP BY 1,2,3
ORDER BY 2, 1;


---Maximizar el uso del espacio físico

---¿Cules son las peliculas menos rentadas y en qué cantidades se encuentran en las tiendas de la empresa?

SELECT i.store_id as store, f.film_id, f.title as movie_name,  COUNT (i.film_id) as films_in_store
FROM film as f
LEFT JOIN inventory as i
ON f.film_id = i.film_id
WHERE f.film_id IN  (
			SELECT f.film_id
			FROM film as f
			LEFT JOIN inventory as i
			ON f.film_id = i.film_id
			LEFT JOIN rental as r
			ON i.inventory_id = r.inventory_id
			LEFT JOIN payment as p
			ON r.rental_id = p.rental_id
			WHERE i.store_id IS NOT NULL ----se agrega esta clausula ya que para muchas de las peliculas ya la tienda no las tiene en inventario
			GROUP BY 1
			HAVING  COUNT (r.rental_id) < 6)
GROUP BY 1,2,3
ORDER BY 2, 1;


----Mejorar la gestión de la programación

----¿Cuáles son las peliculas más rentadas dependiendo la hora del dia?

----primero ver para cada hora cual es el máximo de rentas
WITH CTE AS (SELECT Hour, MAX(category_count) AS rental_max
	FROM(SELECT Extract('hour' from rental_date) as hour, f.title as movie_name, COUNT(*) as category_count
		FROM category as ct
		JOIN film_category as fc ON ct.category_id = fc.category_id
		JOIN film as f ON fc.film_id = f.film_id
		JOIN inventory as i ON f.film_id = i.film_id
		JOIN rental as r ON i.inventory_id = r.inventory_id
		GROUP BY 1,2
		ORDER BY 1) AS sub
GROUP BY 1),

------luego ver junto con cada mes, cual es la pelicula mas vista por hora
CTE2 AS (SELECT Extract('hour' from rental_date) as hour, f.title as movie_name, COUNT(*) as category_count
		FROM category as ct
		JOIN film_category as fc ON ct.category_id = fc.category_id
		JOIN film as f ON fc.film_id = f.film_id
		JOIN inventory as i ON f.film_id = i.film_id
		JOIN rental as r ON i.inventory_id = r.inventory_id
		GROUP BY 1,2
		ORDER BY 1)

-----unir las dos cte, igualando la hora y el max_rentas y el category_count
SELECT ('00:00:00'::time + (cte.hour) * interval '1 hour') AS hora, cte2.movie_name as nombre_pelicula, cte.rental_max as rentas_totales
FROM cte
JOIN cte2
ON cte.hour = cte2.hour and cte.rental_max = cte2.category_count
ORDER BY 3 DESC;


----Seleccionar el nombre de la pelicula, genero, pago total y tiempo total de alquiler
----para peliculas cuya fecha de pago fue en 2007, hacen parte del genero children y family
---- y con una cantidad de pago mayor o igual a 100

SELECT f.title as movie_name,
	   ct.name as genre,
	   SUM(p.amount) as total_payment,
	   SUM(AGE(r.return_date,r.rental_date)) AS total_duration
FROM category as ct
LEFT JOIN film_category as fc
ON ct.category_id = fc.category_id
LEFT JOIN film as f
ON fc.film_id = f.film_id
LEFT JOIN inventory as i
ON f.film_id = i.film_id
LEFT JOIN rental as r
ON i.inventory_id = r.inventory_id
LEFT JOIN payment as p
ON r.rental_id = p.rental_id
WHERE EXTRACT(year from p.payment_date) IN ('2007') AND ct.name IN ('Children', 'Family') 
GROUP BY f.title, ct.name
HAVING SUM(p.amount) > 100
ORDER BY total_payment DESC
LIMIT 100;


--- ¿Cuál es el alquiler promedio por cliente?

SELECT	customer_id, customer_name, ROUND(avg(count))
FROM(SELECT c.customer_id, c.first_name || ' ' || c.last_name AS customer_name,
		   count(rental_id)	----- cantidad de alquileres totales por cliente
	FROM customer AS c
	JOIN rental AS r
	ON c.customer_id = r.customer_id
	GROUP BY 1,2
	ORDER BY 3 DESC) AS sub
GROUP BY 1,2
ORDER BY 3 desc;


----¿Cuál es lacantidad de alquiler de peliculas por mes?
SELECT to_char(rental_date, 'Month'), COUNT(rental_id) as rental_per_month
FROM rental
GROUP BY 1 
ORDER BY 2 DESC;


----¿Cuáles son los actores y actrices más populares?

SELECT a.first_name || ' ' || a.last_name AS nombre_actor,
	   COUNT(r.rental_id) as cantidad_alquileres	
FROM actor as a
JOIN film_actor as f
ON a.actor_id = f.actor_id
JOIN inventory as i
ON f.film_id = i.film_id
JOIN rental as r
ON i.inventory_id = r.inventory_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 20;


----¿Cuáles son los clientes que más veces entregan la pelicula despues de la fecha esperada?
----(o los que menos modificando la ascendencia en el ORDER BY)
WITH CTE AS(SELECT  nombre_cliente,
		CASE WHEN expected_return_date > return_date THEN 0
		ELSE 1 END AS tiempo_entrega
		FROM(SELECT
		c.first_name || ' ' || c.last_name AS nombre_cliente,
		f.title,
		INTERVAL '1' day * f.rental_duration + r.rental_date AS expected_return_date,
		r.return_date	
		FROM film AS f
		INNER JOIN inventory AS i ON f.film_id = i.film_id
		INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
		INNER JOIN customer AS c ON r.customer_id = c.customer_id) AS sub
		ORDER BY 1 )

SELECT nombre_cliente, sum(tiempo_entrega) as cantidad_entregas_tarde
FROM CTE
GROUP BY 1
ORDER BY 2 DESC
;


	















