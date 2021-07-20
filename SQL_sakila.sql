-- 1. Email Campaigns for customers of Store 2, First, Last name and Email address of customers from Store 2
select first_name, last_name, email, store_id
from sakila.customer
where store_id = 2

-- 2. no of movies with rental rate of 0.99$
select rental_rate, count(*) as no_of_movies
from sakila.film
where rental_rate = '0.99'

-- 3. we want to see rental rate and how many movies are in each rental rate categories
select rental_rate, count(*) as total_movies
from sakila.film
group by rental_rate

-- 4. Which rating do we have the most films in?
-- creating a table using subquery which is grouped by rating and then we get the max valuegiving an alias name to the table created
select rat, max(no_of_films)
from (select rating as rat, count(*) as no_of_films 				 
from sakila.film 													 
group by rating														
order by no_of_films desc) as tab									

-- 5. Which rating is most prevalant in each store?
-- joining two tables on a common column
select store_id, rating, max(no_of_films)
from (select i.store_id, f.rating, count(*) as no_of_films
from sakila.film f
right join sakila.inventory i										
on f.film_id = i.film_id											
group by i.store_id, f.rating
order by no_of_films desc) as tab1									
group by store_id

-- 6. We want to mail the customers about the upcoming promotion
select c.customer_id, c.first_name, c.last_name, c.email, a.address
from sakila.customer c
left join sakila.address a
on c.address_id = a.address_id

-- 7. List of films by Film Name, Category, Language
select f.title as name, ca.name as category, l.name as language
from sakila.film f
left join sakila.film_category c
on f.film_id = c.film_id
left join sakila.language l
on f.language_id = l.language_id
left join sakila.category ca
on c.category_id = ca.category_id

-- 8. How many times each movie has been rented out?
select f.film_id, f.title, count(*) as times_movie_rented
from sakila.rental r
left join sakila.inventory i
on r.inventory_id = i.inventory_id
left join sakila.film f
on i.film_id = f.film_id
group by f.title
order by times_movie_rented desc

-- 9. Revenue per Movie
select f.film_id, f.title, count(*) as times_movie_rented, f.rental_rate, count(*) * f.rental_rate as revenue
from sakila.rental r
left join sakila.inventory i
on r.inventory_id = i.inventory_id
left join sakila.film f
on i.film_id = f.film_id
group by f.title
order by revenue desc

-- 10. Most Spending Customers so that we can send him/her rewards or debate points
select c.customer_id, c.first_name, c.last_name, sum(p.amount) as amount
from sakila.customer c
join sakila.payment p
on c.customer_id = p.customer_id
group by customer_id 
order by amount desc

-- 11. What Store has historically brought the most revenue
select c.store_id, sum(p.amount) as amount
from sakila.customer c
join sakila.payment p
on c.customer_id = p.customer_id
group by c.store_id 
order by amount desc

-- 12. How many rentals we have for each month
-- getting 7 characters from the left
select left(rental_date,7) as month, count(*) as no_of_rentals		
from sakila.rental
group by month

-- 13. Rentals per Month (such Jan => How much, etc)
-- getting only month name from the date
select monthname(rental_date) as month, count(*) as no_of_rentals	
from sakila.rental
group by month

-- 14. Which date first movie was rented out ?
select min(rental_date)
from sakila.rental

-- 15. Which date last movie was rented out ?
select max(rental_date)
from sakila.rental

-- 16. For each movie, when was the first time and last time it was rented out?
select f.title, min(r.rental_date) as first_date, max(r.rental_date) as last_date
from sakila.rental r
join sakila.inventory i
on r.inventory_id = i.inventory_id
join sakila.film f
on f.film_id = i.film_id
group by f.film_id

-- 17. Last Rental Date of every customer
select c.customer_id, c.first_name, c.last_name, max(r.rental_date) as last_date
from sakila.rental r
join sakila.customer c
on r.customer_id = c.customer_id
group by c.customer_id

-- 18. Revenue Per Month
select monthname(payment_date) as month, sum(amount) as revenue
from sakila.payment
group by month

-- 19. How many distint Renters per month
select monthname(payment_date) as month, count(distinct(customer_id)) as no_of_renters
from sakila.payment
group by month

-- 20. Number of Distinct Film Rented Each Month
select f.film_id, f.title, monthname(r.rental_date) as month, count(f.film_id) as times_rented
from sakila.rental r
join sakila.inventory i
on r.inventory_id = i.inventory_id
join sakila.film f
on f.film_id = i.film_id
group by f.film_id, f.title, month

-- 21. Number of Rentals in Comedy , Sports and Family
select ca.name, count(*) as no_of_rentals
from sakila.rental r
join sakila.inventory i
on r.inventory_id = i.inventory_id
join sakila.film f
on f.film_id = i.film_id
join sakila.film_category c
on f.film_id = c.film_id
join sakila.category ca
on c.category_id = ca.category_id
where ca.name in ('Comedy', 'Sports', 'Family')
group by ca.name

-- 22. Users who have been rented at least 3 times
-- using having as we want to put condition on group by
select c.customer_id, concat(c.first_name, " ", c.last_name), count(*) as no_of_rentals
from sakila.payment p 
join sakila.customer c
on p.customer_id = c.customer_id
group by p.customer_id 												
having no_of_rentals >= 3											

-- 23. How much revenue has one single store made over PG13 and R rated films
select i.store_id, f.rating, sum(p.amount) as revenue
from sakila.rental r
join sakila.inventory i
on r.inventory_id = i.inventory_id
join sakila.film f
on f.film_id = i.film_id
join sakila.payment p
on r.rental_id= p.rental_id
group by i.store_id, f.rating 
having f.rating in ('PG-13', 'R')

-- 24. Active User  where active = 1
-- will drop table if any
drop temporary table if exists active_customers;					
create temporary table active_customers(
select c.*, a.phone
from sakila.customer c
join sakila.address a
on c.address_id = a.address_id
where c.active = 1)

-- 25. Reward Users : who has rented at least 30 times
drop temporary table if exists rentals;
create temporary table rentals(
select *, count(*) as no_of_rentals
from sakila.rental 
group by customer_id 
having no_of_rentals >= 30)

-- 26. Reward Users who are also active
select a.customer_id, a.first_name, a.last_name, a.email
from sakila.active_customers a
join sakila.rentals r
on a.customer_id = r.customer_id

-- 27. All Rewards Users with Phone
select a.customer_id, a.first_name, a.last_name, a.email, a.phone
from sakila.active_customers a
right join sakila.rentals r
on a.customer_id = r.customer_id