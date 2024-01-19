# 1. Who is the senior most employee based on job title?
select * from employee 
order by levels desc limit 1; 

# 2.Which countries have the most invoices?
select count(*) as count,billing_country from invoice
group by billing_country
order by count desc;

# 3.What are top 3 values of total invoices
select total from invoice
order by total desc
limit 3;

# 4.Which city has the best customers?We would like to throw a promotional music festival in the city we made the most money.
# Write a query that returns one city that has the highest sum of totals.Return both the city name and sum of all invoice totals
select billing_city,sum(total) as invoice_total from invoice 
group by billing_city
order by invoice_total desc;

# 5.Who is the best customer?The customer who has spent the most money will be declared the best customer.Write a query that returns the person who has
# spent the most money

-- cte used as first_name and last_name are non-aggregated fields
with cte as(SELECT cust.customer_id, sum(inv.total) as totals FROM customer cust
left join invoice inv
on cust.customer_id=inv.customer_id
group by cust.customer_id
order by totals desc limit 1
)
select cte.customer_id,cust.first_name,cust.last_name,round(cte.totals,2) from cte join customer cust
on cte.customer_id=cust.customer_id;
 
 # 6.Write the query to return email,first_name,last_name and genre of all rock music listeners ,return list ordered alphabetically by email
 select distinct(email),cust.first_name,cust.last_name,g.name from customer cust
 join invoice i on cust.customer_id=i.customer_id
 join invoice_line l on i.invoice_id=l.invoice_id
 join track t on l.track_id=t.track_id
 join genre g on t.genre_id=g.genre_id
 where g.name='Rock'
 order by email;
 
 # 7.Let's invite the artists who have written the most rock music in our dataset.Write a query that returns the artist name and total track count of the top 10
 # rock band
 with cte1 as( select art.artist_id,count(t.track_id) as total_track_count from track t
 join genre g on t.genre_id=g.genre_id
 join album a on a.album_id=t.album_id
 join artist art on art.artist_id=a.artist_id
 where g.name='Rock'
 group by art.artist_id
 )
 select cte1.artist_id,cte1.total_track_count,art.name from cte1
 join artist art on art.artist_id=cte1.artist_id
order by total_track_count desc limit 10;
   
# 8. Return all track names that have song length greater than average song length.Return the name and milliseconds for each track,order by song length with
# the longest song listed first
-- subquery used
SELECT name,milliseconds FROM music_store.track 
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

# 9.Find how much amount spent by each customer on artists?Write a query to return customer_name,artist_name and total_spent
 with best_selling_artist as
 (select art.artist_id,art.name,sum(invl.quantity*invl.unit_price) as totalspent
 from invoice_line invl 
 join track t on t.track_id=invl.track_id
 join album a on a.album_id=t.album_id
 join artist art on art.artist_id=a.artist_id
 group by 1,2
 order by 3 desc
 
 )
 select distinct c.first_name,c.last_name,bsa.name,bsa.totalspent 
 from customer c
 join invoice i on c.customer_id=i.customer_id
 join invoice_line l on i.invoice_id=l.invoice_id
 join track t on l.track_id=t.track_id
 join album a on a.album_id=t.album_id
 join best_selling_artist bsa on bsa.artist_id=a.artist_id
 group by 1,2,3,4
 order by 4 desc;

# 10.Find out the most popular music genre for each country.Most popular genre is defined by the genre with highest amount of purchases.
# Write a query that returns each country along with top genre.For countries where maximum number of purchases is shared return all genres
with most_popular_genre as(
select c.country,count(il.quantity) as purchases,row_number() over(partition by c.country order by count(il.quantity) desc)
from track t
join genre g on g.genre_id=t.genre_id 
join invoice_line il on il.track_id=t.track_id
join invoice i on i.invoice_id=il.invoice_id 
join customer c on c.customer_id=i.customer_id
group by c.country)
select * from most_popular_genre
order by 2 desc,1 asc;


