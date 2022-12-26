/* Глава 9 -  Подзапросы */
/* Найти человека с максимальным customer_id */
SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id = (SELECT MAX(customer_id) FROM customer);

/* Если сделать через GROUP BY будут все customer_id*/
SELECT first_name, last_name, MAX(customer_id) 
FROM customer
GROUP BY first_name, last_name;

SELECT MAX(customer_id) FROM customer;

SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id = 599;

/* Некоррелированные подзапросы */
SELECT city_id, city 
FROM city
WHERE country_id <>
(SELECT country_id FROM country WHERE country = 'India');

SELECT country_id FROM country WHERE country = 'India';

/* Неcколько строк и один столбец */

SELECT country_id
FROM country
WHERE country IN ('Canada', 'Mexico');
/* или */
SELECT country_id
FROM country
WHERE country  = 'Canada' OR  country  = 'Mexico';

SELECT  city_id, city
FROM city
WHERE country_id in (SELECT country_id FROM country WHERE country in ('Canada', 'Mexico'));

SELECT country_id FROM country WHERE country in ('Canada', 'Mexico');

/* Найти все города расположенные не в Канаде или Мексике*/

SELECT  city_id, city
FROM city
WHERE country_id not in (SELECT country_id FROM country WHERE country in ('Canada', 'Mexico'));

/* Найти всех клиентов, которые никогда не получали фильм напрокат бесплатно*/
SELECT first_name, last_name
FROM customer
WHERE customer_id <> ALL 
(SELECT customer_id FROM payment WHERE amount=0);
/*или*/
SELECT first_name, last_name
FROM customer
WHERE customer_id NOT IN 
(SELECT customer_id FROM payment WHERE amount=0);

/* ANY  - то же что и  IN*/
/* найти клиентов, чьи суммарные продажи превышают ссумарные продажи всех клиентов Боливии, Парагвае, Чили*/
SELECT * FROM payment; /*amount, customer_id*/
SELECT * FROM customer; /*customer_id, addres_id*/
SELECT * FROM country; /*contry, coutry_id*/
SELECT * FROM addres; /*city_id, addres_id*/
SELECT * FROM city; /*city_id, coutry_id*/

SELECT customer_id, sum(amount)
FROM payment
group by costomer_id
having sum(amount) > ANY (SELECT sum(p.amount) FROM payment p
INNER JOIN customer c
ON p.customer_id = c.customer_id
inner join address a
ON c.address_id = a.address_id
INNER JOIN city ct
ON a.city_id = ct.city_id
INNER JOIN country co
ON ct.country_id = co.country_id
WHERE co.country IN ("Bolivia", "Paraguay", "Chile")
GROUP BY co.country);

/*многостолбцовые подзапросы*/
SELECT fa.actor_id, fa.film_id
FROM film_actor fa
WHERE fa.actor_id in
(SELECT actor_id FROM actor WHERE lact_name = "MONROE")
AND fa.film_id in (SELECT film_id from film WHERE rating = "PG");

SELECT actor_id, film_id
FROM film_actor 
WHERE (actor_id, film_id) IN 
(SELECT a.actor_id, film_id
FROM actor a
CROSS JOIN film f
WHERE a.last_name = "MONROE" AND f.rating = "PG");

/*Коррелированный подзапрос*/
SELECT c.first_name, c.last_name
FROM customer c
WHERE 20 = (SELECT count(*) FROM rental r WHERE r.customer_id = c.customer_id);

SELECT c.first_name, c.last_name
FROM customer c 
WHERE
(SELECT sum(p.amount) FROM payment p
WHERE p.customer_id = c.customer_id) BETWEEN 180 AND 240;

/* подзапросы как источник данных*/

SELECT customer_id, count(*) as num_rentals, sum(amount)  as tot_payments
FROM payment
GROUP BY customer_id;

SELECT c.first_name, c.last_name, p.num_rentals, p.tot_payments 
FROM customer c 
JOIN (SELECT customer_id, count(*) as num_rentals, sum(amount)  as tot_payments
FROM payment
GROUP BY customer_id) p
ON c.customer_id = p.customer_id;

/* создание данных*/

/*1. создаем таблицу - группа - нижняя граница - верхняя граница*/
SELECT 'Small Ery' name, 0 low_limit, 74.99 high_limit
UNION ALL
SELECT 'Average Joes' name, 75 low_limit, 149.99 high_limit
UNION ALL
SELECT 'Heavy Hitters' name, 150 low_limit, 9999999.99 high_limit;


SELECT pymnt_g.name, count(*) num_customers
FROM (SELECT cusstomer_id, count(*) num_rentals, sum(amount) tot_payments
FROM payment
GROUP BY costomer_id) pymnt
INNER JOIN
(SELECT 'Small Ery' name, 0 low_limit, 74.99 high_limit
UNION ALL
SELECT 'Average Joes' name, 75 low_limit, 149.99 high_limit
UNION ALL
SELECT 'Heavy Hitters' name, 150 low_limit, 9999999.99 high_limit) pymnt_g
ON pymnt.tot_payments
BETWEEN pymnt_g.low_limit AND pymnt_g.high_limit
GROUP BY pymnt_g.name;

SELECT c.first_name, c.last_name, ct.city, sum(p.amount) tot_payment, count(*) tot_rentals
FROM payment p
JOIN customer c 
ON p.customer_id = c.customer_id
JOIN address a
ON c.address_id = a.address_id
JOIN city ct
ON a.city_id = ct.city_id
GROUP BY c.first_name, c.last_name, ct.city;

SELECT customer_id, count(*) tot_rentals, sum(amount) tot_payments
FROM payment
GROUP BY customer_id;

SELECT c.first_name, c.last_name, ct.city, p.tot_payments, p.tot_payments
FROM( SELECT customer_id, count(*) tot_rentals, sum(amount) tot_payments
FROM payment
GROUP BY customer_id) p
JOIN customer c 
ON p.customer_id = c.customer_id
JOIN address a 
ON c.address_id = a.address_id
JOIN city ct
ON a.city_id = ct.city_id;

SELECT 
(SELECT c.first_name FROM customer c WHERE c.customer_id = p.customer_id) first_name,
(SELECT c.last_name FROM customer c WHERE c.customer_id = p.customer_id) last_name,
(SELECT ct.city FROM customer c 
INNER JOIN address a 
ON c.address_id = a.address_id
INNER JOIN city ct
ON a.city_id = ct.city_id
WHERE c.customer_id = p.customer_id)
city
FROM payment p
GROUP  BY p.customer_id;


SELECT count(*) FROM film_actor fa;


