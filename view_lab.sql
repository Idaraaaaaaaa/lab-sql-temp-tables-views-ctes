# Write SQL queries to perform the following tasks using the Sakila database:
USE sakila;
#First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
CREATE VIEW customer_rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email AS email_address,
    COUNT(r.rental_id) AS rental_count
FROM customer AS c
INNER JOIN rental AS r 
USING (customer_id)
GROUP BY
    c.customer_id, c.first_name, c.last_name, c.email;

SELECT * FROM customer_rental_summary;

#views are persistent and can be treated as a query.

#Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
#The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
CREATE TEMPORARY TABLE payment_summary AS
SELECT customer_id, customer_name, SUM(payment.amount) AS total_amount_paid
FROM customer_rental_summary
INNER JOIN payment
USING(customer_id)
GROUP BY customer_id, customer_name;

SELECT * FROM payment_summary;
#temporary table lives as long as the session is open
#Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
#The CTE should include the customer's name, email address, rental count, and total amount paid.

#Next, using the CTE, create the query to generate the final customer summary report, which should 
#include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
WITH customer_summary_cte AS (
    SELECT
        r.customer_name,
        r.email_address,
        r.rental_count,
        p.total_amount_paid,
        p.total_amount_paid / r.rental_count AS average_payment_per_rental
    FROM
        customer_rental_summary AS r
    INNER JOIN
        payment_summary AS p 
        ON r.customer_id = p.customer_id)
SELECT
    customer_name,
    email_address,
    rental_count,
    total_amount_paid,
    average_payment_per_rental
FROM
    customer_summary_cte;

#cte lives as long as the query is open

WITH sakila