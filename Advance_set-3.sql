/*
#########		Question Set 3 – Advance		###################
1. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent.

2. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres.

3. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount.
*/

/*
QUS- 1:
 Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent.
*/

-- explaination is below the script...
-- method: #######	"CTE: Comman Table Expression"	############

with best_selling_artist as (
select
	artist.artist_id,
    artist.name as artist_name,
    sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
from music.invoice_line
	join music.track on invoice_line.track_id = track.track_id
    join music.album_01 on track.album_id = album_01.album_id
    join music.artist on album_01.artist_id = artist.artist_id
group by artist.artist_id
order by total_sales desc
limit 1)
select
	customer.customer_id,
    customer.first_name,
    customer.last_name,
    best_selling_artist.artist_name,
    sum(invoice_line.unit_price * invoice_line.quantity) as total_spent
from music.customer
	join music.invoice on customer.customer_id = invoice.customer_id
    join music.invoice_line on invoice.invoice_id = invoice_line.invoice_id
    join music.track on invoice_line.track_id = track.track_id
    join music.album_01 on track.album_id = album_01.album_id
    join best_selling_artist on album_01.artist_id = best_selling_artist.artist_id
group by customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.artist_name
order by total_spent desc;

-- # @ first check only with artist..
 -- so for total sales of artist's track we need track quantity * price which is invoice_line table..
 -- for that we will join the table where we need connected tables... 
	-- so first open all connected tables in line by below steps of table...
		-- invoice_line --> track --> album_01 --> artist
        
-- @ second step for customer..
-- for that we also need tio join the table...
	-- so open connected table line wise so it will easy to connect each table using join 
    -- follow the steps for connected table..
		-- customer --> invoice --> linvoice_line --> album_01 --> best_sellling_artist (# this table we created above)
			-- [best_selling_artist table we created just because with customer table for best selling track of the artist...
            -- and which customer spent more on that artist...]
    
    -- ANS:
			-- first row...
    # customer_id, 			first_name, 		last_name,		 artist_name, 		total_spent
	-- '54', 					'Steve', 		'Murray', 			'AC/DC', 			'17.82'
	
			-- last row will be...
    -- # customer_id, 		first_name, 		last_name, 		artist_name, 		total_spent
		-- '10', 			'Eduardo', 			'Martins', 			'AC/DC', 			 '0.99'

 /*
 -- Qus-2:
We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres.
*/

-- #####	method-1: 		"CTE" 		#######
with Popular_Genre as (
select
	genre.genre_id,
    genre.name as genre_name,
    count(invoice_line.quantity) as Purchase,
    customer.country,
    row_number()
    over (partition by customer.country
			order by count(invoice_line.quantity) desc) as RowNo
from music.customer
	join music.invoice on customer.customer_id = invoice.customer_id
    join music.invoice_line on invoice.invoice_id = invoice_line.invoice_id
    join music.track on invoice_line.track_id = track.track_id
    join music.genre on track.genre_id = genre.genre_id
group by country, genre_name, genre_id
order by country asc, Purchase desc)
select 
	*
from Popular_Genre
	where RowNo <= 1; 
    
    -- @ first step we are focusing on the genre...
    -- which will give us the popular genre with the help of invoice_line table's quanntity.
    -- with quantity we will get the purchase total_purchase_amount.
    -- so will make dummy table of "Popular_genre"
		-- we are also using "row_number"..
			-- which will give us row number from country and purchase...,
            -- where best country name with highest purchase will give the row_number as 1.
		-- apart with that will use "partation by"..
			-- partition for country where it will show each best country from the customer table 

    -- @ second stage will use dummy table "Polular_genre" ...
		-- where we want only the data which has row_number 1 or less than 1.
		-- which give the result of best populat genre from and country which has max purchase genre. 
    
-- #####	method-2: 		"RECURSIVE" 		#######

with recursive
	Sales_per_Country as (
select
	genre.genre_id,
    genre.name as genre_name,
    count(*) as Purchase_per_genre,
    country
from music.invoice_line
	join music.invoice on invoice_line.invoice_id  = invoice.invoice_id
    join music.customer on invoice.customer_id = customer.customer_id
    join music.track on invoice_line.track_id = track.track_id
    join music.genre on track.genre_id = genre.genre_id
group by genre_id, genre_name, country
order by country),
max_genre_per_country as (
select
	max(Purchase_per_genre) as max_genre_num,
    country
from Sales_per_Country
	group by country
    order by country)
select 
	Sales_per_Country. *
from Sales_per_Country
	join max_genre_per_country on Sales_per_Country.country = max_genre_per_country.country
where Sales_per_Country.Purchase_per_genre = max_genre_per_country.max_genre_num;
    
    -- in "recursive" we are making 2 dummies tables here
    
    -- @ first "Sales_per_Country" dummy table:
    -- where we are focusing sales only..
    -- here, from invoice_line table we are counting whole purchase of genre. 
    
    -- @ second "max_genre_per_country" dummy table
    -- where we are counting total purchese from each country 
		-- by using our first dummy table "Sales_per_Country
        
	-- @ last stage we will combine two dummies table 
    -- for final output with country with most purchase with best genre. 
    
    -- ANS:
    -- #   genre_id, 		genre_name, 		Purchase_per_genre, 		country
	-- 			'1', 		'Rock', 					'1', 			  'Argentina'.......
    
    -- last row output:
    -- 			'1', 		'Rock', 					'70', 					'USA'

/*
QUS-3:
Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount.
*/

-- method-1: #########		CTE		###############

with Customer_with_Country as (
select
	customer.customer_id,
    customer.first_name,
    customer.last_name,
    invoice.billing_country,
    sum(total) as total_spending,
    row_number() 
    over (partition by invoice.billing_country 
			order by sum(total)desc) as RowNo
from music.customer 
	join music.invoice on customer.customer_id = invoice.customer_id
group by customer_id, first_name, last_name, billing_country
order by billing_country asc, total_spending desc)
select 
	*
from Customer_with_Country
	where RowNo <= 1;
    
-- method-2: ############		RECURSIVE		#############	

with recursive 
	customer_with_country as(
    select
	customer.customer_id,
    customer.first_name,
    customer.last_name,
    invoice.billing_country,
    sum(total) as total_spent
from music.customer
	join music.invoice on customer.customer_id = invoice.customer_id
    group by customer_id, first_name, last_name, billing_country
    order by first_name, last_name desc),
max_spending_country as(
select 
	billing_country,
	max(total_spent) as max_spending
from customer_with_country
	group by billing_country)
 
select
	customer_with_country.customer_id,
    customer_with_country.first_name,
    customer_with_country.last_name,
    customer_with_country.billing_country,
    customer_with_country.total_spent
from customer_with_country
	join max_spending_country on customer_with_country.billing_country = max_spending_country.billing_country
where customer_with_country.total_spent = max_spending_country.max_spending
	order by billing_country;
    
    
    






























































