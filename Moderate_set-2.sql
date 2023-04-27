/*
-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A

-- 2. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands

-- 3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first
*/

/*
Qus-1: Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A.
*/

select
	distinct(customer.email), 
    customer.first_name,
    customer.last_name
from music.customer
	join music.invoice
		on customer.customer_id = invoice.customer_id
    join music.invoice_line
		on invoice.invoice_id = invoice_line.invoice_id
	where invoice_line.track_id in 
		(select 
			track.track_id
		from music.track
			join music.genre
				on track.genre_id = genre.genre_id
		where genre.name like 'Rock')
	order by email;
    
      /*
        -- ANS with Explanation:
        -- if you only run our second term which is in the bracket for genre:'rock' music only..
        -- you will get the result of rock music only.
        -- and after that rum whole whole script we will mget the email, first name, last name..
        -- only who is listem=ning the "rock" music only..
		-- and we need the result in the term of alphabetic order means ascending order..
        --  ANS: 
				# email, first_name, last_name
		-- 		'aaronmitchell@yahoo.ca', 'Aaron', 'Mitchell'
		*/
    
-- ############### 		OR		###############
-- QUS-1 : I think this is right script for the set-2 of Qus-1.
-- last script is according to video.
-- this script according to github solution and before checking the solution..
--  I alresy follow thyis script. 
-- as in this script we get the name of genre also...

SELECT
	DISTINCT(email) AS Email,
    first_name AS FirstName, 
    last_name AS LastName, 
    genre.name AS Name
FROM customer
	JOIN invoice 
		ON invoice.customer_id = customer.customer_id
	JOIN invoice_line 
		ON invoice_line.invoice_id = invoice.invoice_id
	JOIN track 
		ON track.track_id = invoice_line.track_id
	JOIN genre 
		ON genre.genre_id = track.genre_id
	WHERE genre.name LIKE 'Rock'
	ORDER BY email;
    
    -- Ans: 
    -- 			Email, 			 FirstName,   LastName, 	   Name:
    -- 'aaronmitchell@yahoo.ca', 'Aaron',    'Mitchell',   'Rock'
    -- 'alero@uol.com.br',      'Alexandre', 'Rocha',       'Rock'...

/*
 QUS-2: Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands.
*/

-- #########			MY SOPLUTION		############

select
	artist.artist_id,
    artist.name, 
    count(artist.artist_id) as count_of_songs,
    genre.name as genreOfSong
from artist
	join album_01 on artist.artist_id = album_01.artist_id
    join track on album_01.album_id = track.album_id
    join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by count_of_songs desc;

	-- ANS: 
    -- # artist_id,		 name, 		count_of_songs,		 genreOfSong
	-- 		'1', 		'AC/DC', 		'18', 				'Rock'
    -- 		'3', 		'Aerosmith', 	'15', 				'Rock' ..........

-- ##############		Voideo Solution		##############
SELECT 
	artist.artist_id, 
    artist.name,
    COUNT(artist.artist_id) AS number_of_songs
FROM track
	JOIN album_01
		ON album_01.album_id = track.album_id
	JOIN artist 
		ON artist.artist_id = album_01.artist_id
	JOIN genre 
		ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;
		
        -- ANS: # artist_id, 		name,		 number_of_songs
		-- 			'1',		    'AC/DC', 			'18'
		--           '3',          'Aerosmith',         '15'.....
        
/*
-- Qus-3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first. 
*/

select
	track.track_id,
    track.name as track_name,
    track.milliseconds as millsec_length
from music.track
	where track.milliseconds >
		(select 
			avg(track.milliseconds) as avg_millisec 
		from music.track)
	order by track.milliseconds desc;

	-- ANS:
    -- # track_id,        track_name,              millsec_length
	--      '350',   'How Many More Times',           '711836'

-- personal query..
-- let's check average length of track.milliseconds.
-- as above qus is milliseconds length is more than average length.

select
	avg(milliseconds) as avg_lenght_millisec
from music.track
		
        -- ANS:
        -- as above qus asked milliseconds length is more then avg length..
        -- so avg length of milliseconds is 251177.7431..
        -- so in above ans. we should get the answewres only more than avg length of milliseconds which is '251177.7431'
		-- which is correct as our last ans from the above qus is..
			-- # track_id, 				track_name,		 millsec_length
			-- 		'275', 			'Da Lama Ao Caos', 		'251559'

		















































