-- Question 1: Case When

/* Write a query that gives an overview of how many films have replacement costs in the following cost ranges:
i)   low: 9.99 - 19.99 (the answer is 514)
ii)  medium: 20.00 - 24.99 (the answer is 250)
iii) high: 25.00 - 29.99 (the answer is 236) */

SELECT 
COUNT(*),
CASE 
     WHEN replacement_cost <= 19.99 THEN 'low'
     WHEN replacement_cost <= 24.99 THEN 'medium'
     ELSE 'high'
     END as cost_category
FROM film
GROUP BY cost_category
ORDER BY Count(*) DESC
-------------------------------------------------------------------------------------------------------------

-- Question 2: Join & Concatenate

/* Create an overview of the actors' first and last names and in how many movies they appear in. 
Which actor is part of most movies?
-> The actor that shows up on top of the list changes, Susan Davis or Gina Degeneres, depending whether we group 
actors just by name, or by name and ID as well. The code for capitalizing names was taken from the following source:
https://www.geeksforgeeks.org/sql/how-to-capitalize-first-letter-in-sql. */

-- Solution 1: Grouping just by name
SELECT 
     first_name || ' ' || last_name as name,
     COUNT(film_id) as number_movies
FROM actor a
INNER JOIN film_actor fa
     ON a.actor_id = fa.actor_id
GROUP BY name
ORDER BY number_movies DESC

-- Solution 2: Grouping by both name and ID
SELECT
     a.actor_id, 
     first_name || ' ' || last_name as name,
     COUNT(film_id) as number_movies
FROM actor a
INNER JOIN film_actor fa
     ON a.actor_id = fa.actor_id
GROUP BY name, a.actor_id
ORDER BY number_movies DESC
-------------------------------------------------------------------------------------------------------------

-- Bonus: Finding Susan insight

/* E.g. Susan Davis shows up twice, with IDs 101 and 110. One of the IDs could be a mistake, especially given it 
has the same digits reordered, making it easy to mistype. But it could also be an entirely different person. 
The best way to confirm would be to reach out to the source/collector of the data. In the absence of that possibility, 
the data is grouped in 2 different ways, as demonstrated previously. 
When querying the 2 different solutions, you might notice that Susan shows up at the top of the list when treated as 
the same person, but not when treated separately. */

SELECT
     a.actor_id, 
     first_name || ' ' || last_name as name,
     COUNT(film_id) as number_movies
FROM actor a
INNER JOIN film_actor fa
     ON a.actor_id = fa.actor_id
WHERE first_name || ' ' || last_name ILIKE 'Susan Davis'
GROUP BY a.actor_id, name
ORDER BY number_movies DESC
-------------------------------------------------------------------------------------------------------------

-- Question 3: Multiple Joins

/* Create an overview of the revenue grouped by a column in the format "country, city". 
Which "country, city" has the least sales?
-> The answer is United States, Tallahassee. */

SELECT
     country || ', ' || city as country_city,
     SUM(amount) as revenue
FROM customer c
LEFT JOIN address a
     On a.address_id = c.address_id
LEFT JOIN city ci
     On ci.city_id = a.city_id
LEFT JOIN country co
     On co.country_id = ci.country_id
INNER JOIN payment p
     On p.customer_id = c.customer_id
GROUP BY country_city
ORDER BY revenue ASC
LIMIT 5
-------------------------------------------------------------------------------------------------------------

-- Bonus: Why use Left and Inner Joins?

/* With the customer table, Left joins are used because we want to keep all customers, but we don't need all addresses, 
cities and countries - including those not related to any customer. Regarding the payment table, it should ideally 
be joined with an Inner or Right join (given the ordering), even though Full join will give the same results in this 
case. This could be because it would be odd to have payments not related to any customer, as payments must be made by 
somebody. The opposite, having customers not related to a payment, could be considered odd too, but it’s not impossible. 
The company could categorize as a customer someone who uses the service/product but doesn't necessarily pay, e.g. 
multiple users of a Netflix account. Or it could have customers who are invoiced, but haven't paid yet.
Since we're interested in the revenue, we care more about including all the payments and not necessarily including 
all of the customers, hence the Inner (or Right) join. */
-------------------------------------------------------------------------------------------------------------

-- Question 4: Uncorrelated Subquery & Extract

/* Create a query that shows average daily revenue by the day of the week. 
What is the average daily revenue of all Sundays?
-> The answer is $1,410.65. */

SELECT
     EXTRACT(ISODoW from date) as day_of_week,
     ROUND(AVG(total_per_day),2) as avg_daily_revenue
FROM
     (SELECT
          DATE(payment_date),
          SUM(amount) as total_per_day
     FROM payment
     GROUP BY DATE(payment_date))
GROUP BY day_of_week
ORDER BY 1 DESC

-- Notes
/* We need to use "Date(payment_date)" because the "payment_date" includes timezones and groups by timezones.
"total_per_day" is the sum for the "Date(payment_date)", aka not yet by weekday. */
-------------------------------------------------------------------------------------------------------------
