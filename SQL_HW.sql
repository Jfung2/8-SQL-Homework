#load in database
USE sakila;

#1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name FROM actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. 
#    Name the column Actor Name
SELECT CONCAT_WS(' ',first_name, last_name) AS Actor_Name FROM actor;

#2a. Find id, first name, last name of actor. 
SELECT * FROM actor 
WHERE first_name = 'joe';

#2b. Find all actors who's last name contains gen. 
SELECT * FROM actor 
WHERE last_name LIKE '%gen%';

#2c. Find all actors who's last name contains LI. Order rows by lastname, firstname. 
SELECT last_name, first_name
FROM actor 
WHERE last_name LIKE '%li%';

#2d.Using IN, display the country_id and country columns of the following countries: 
#   Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM country
WHERE country 
IN ('Afghanistan', 'Bangladesh', 'China');

#3a. Create a column in the table actor named description and use the data type BLOB
ALTER TABLE actor
ADD COLUMN description blob; 

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
#    Delete the description column.
ALTER TABLE actor 
DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS 'Count'
FROM actor
GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, 
#    but only for names that are shared by at least two actors.
SELECT last_name, COUNT(*) AS 'Count'
FROM actor 
GROUP BY last_name
HAVING COUNT > 1;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
#    Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

#4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
DESCRIBE sakila.address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
#    Use the tables staff and address
SELECT s.first_name, s.last_name, a.address
FROM staff s
INNER JOIN address a
ON s.address_id = a.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
#    Use tables staff and payment.
SELECT s.first_name, s.last_name,
SUM(p.amount) AS 'Total Amount Rung'
FROM staff s 
INNER JOIN payment p 
ON s.staff_id = p.staff_id
AND p.payment_date 
BETWEEN '2005-08-01 00:00:44' AND '2005-08-23 22:50:12'
GROUP BY first_name, last_name;

#6c. List each film and the number of actors who are listed for that film. 
#    Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(*) AS '# of actors'
FROM film f 
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY f.film_id;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.film_id, f.title, COUNT(*) AS '# of films'
FROM film f 
LEFT JOIN inventory i 
ON f.film_id = i.film_id
WHERE f.film_id = '439';

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#    List the customers alphabetically by last name
SELECT c.first_name, c.last_name, SUM(p.amount) AS 'Total Amount Paid'
FROM payment p 
INNER JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY last_name;

#7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film 
WHERE (title LIKE 'K%' OR title LIKE 'Q%') AND
(SELECT language_id 
FROM language
WHERE language_id = '1'
);

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(SELECT actor_id 
FROM film_actor
WHERE film_id IN
(SELECT film_id
FROM film 
WHERE title = 'Alone Trip'
)
);

#7c. You will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer cu
JOIN address a on (cu.address_id = a.address_id)
JOIN city c on (c.city_id = a.city_id)
JOIN country co on (co.country_id = c.country_id)
WHERE country = 'Canada';

#7d. Identify all movies categorized as family films.
SELECT title
FROM film f 
JOIN film_category fc on (f.film_id = fc.film_id)
JOIN category c on (fc.category_id = c.category_id)
WHERE name = 'Family';

#7e. Display the most frequently rented movies in descending order.
SElECT title, COUNT(f.film_id) AS 'Frequency Rented'
FROM film f 
JOIN inventory i on (i.film_id = f.film_id)
JOIN rental r on (r.inventory_id = i.inventory_id)
GROUP BY title
ORDER BY 'Frequecy Rented' DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, SUM(amount) AS 'Revenue'
FROM payment p 
JOIN staff s on (s.staff_id = p.staff_id)
GROUP BY store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country 
FROM store s 
JOIN address a on (s.address_id = a.address_id)
JOIN city c on (c.city_id = a.city_id)
JOIN country cc on (cc.country_id = c.country_id);

#7h. List the top five genres in gross revenue in descending order. 
#category, film_category, inventory, payment, and rental
SELECT name AS 'Top Five Genres', SUM(amount) AS 'Revenue'
FROM category c 
JOIN film_category fc on (c.category_id = fc.category_id)
JOIN inventory i on (fc.film_id = i.film_id)
JOIN rental r on (r.inventory_id = i.inventory_id)
JOIN payment p on (p.customer_id = r.customer_id)
GROUP BY name
ORDER BY Revenue DESC
LIMIT 5;

#8a.  View the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
#     If you havent solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_Five_Genres AS
SELECT name AS 'Top Five Genres', SUM(amount) AS 'Revenue'
FROM category c 
JOIN film_category fc on (c.category_id = fc.category_id)
JOIN inventory i on (fc.film_id = i.film_id)
JOIN rental r on (r.inventory_id = i.inventory_id)
JOIN payment p on (p.customer_id = r.customer_id)
GROUP BY name 
ORDER BY Revenue DESC
LIMIT 5;

#8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;



