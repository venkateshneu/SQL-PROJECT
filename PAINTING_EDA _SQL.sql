select * from artist;
select * from canvas_size;
select *  from work;
SELECT * FROM SUBJECT;
SELECT * FROM MUSEUM;
SELECT * FROM MUSEUM_HOURS;
SELECT * FROM PRODUCT_SIZE;
SELECT * FROM  IMAGE_LINK;

#1 QUESTION - Retrieve all paintings not exhibited in any museums.

SELECT * FROM WORK WHERE museum_id is  NULL;

#2 QUESTION - Are there museums without any artworks?

SELECT *
FROM MUSEUM
LEFT JOIN WORK ON MUSEUM.MUSEUM_ID = WORK.MUSEUM_ID WHERE WORK_ID IS NULL;

#3 QUESTION - How many paintings have an asking price exceeding their regular price?
SELECT COUNT(*) AS TOTAL_COUNT FROM PRODUCT_SIZE WHERE SALE_PRICE > REGULAR_PRICE;

#4 QUESTION- Identify paintings with asking prices less than half of their regular price.
SELECT * FROM PRODUCT_SIZE WHERE SALE_PRICE < (REGULAR_PRICE/2);

#5 QUESTION - What canvas size commands the highest cost?
SELECT canvas_size.label, PRODUCT_SIZE.sale_price
FROM PRODUCT_SIZE
JOIN canvas_size ON canvas_size.size_id::text = PRODUCT_SIZE.size_id
ORDER BY  SALE_PRICE DESC LIMIT 1;

#6 QUESTION - Eliminate duplicate records from the work, product size, subject, and image link tables.

-- Delete duplicate records from the WORK table
DELETE FROM WORK w
WHERE w.CTID NOT IN (
    SELECT MIN(w2.CTID)
    FROM WORK w2
    WHERE w.work_id = w2.work_id
);

-- Delete duplicate records from the PRODUCT_SIZE table
DELETE FROM PRODUCT_SIZE ps
WHERE ps.CTID NOT IN (
    SELECT MIN(ps2.CTID)
    FROM PRODUCT_SIZE ps2
    WHERE ps.work_id = ps2.work_id
    AND ps.size_id = ps2.size_id
);

-- Delete duplicate records from the SUBJECT table
DELETE FROM SUBJECT s
WHERE s.CTID NOT IN (
    SELECT MIN(s2.CTID)
    FROM SUBJECT s2
    WHERE s.work_id = s2.work_id
    AND s.SUBJECT = s2.SUBJECT
);

-- Delete duplicate records from the IMAGE_LINK table
DELETE FROM IMAGE_LINK il
WHERE il.CTID NOT IN (
    SELECT MIN(il2.CTID)
    FROM IMAGE_LINK il2
    WHERE il.work_id = il2.work_id
);
 
#7  Identify museums with incorrect city information in the dataset.
SELECT * FROM MUSEUM 
WHERE CITY ~ '^[0-9]' OR CITY IS NULL;

#8 Find and remove the invalid entry in the Museum_Hours table.
SELECT * FROM MUSEUM_HOURS;
DELETE FROM museum_hours 
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM museum_hours
    GROUP BY museum_id, day
);

#9 Retrieve the top 10 most renowned painting subjects. 
SELECT SUBJECT AS Subject, COUNT(*) AS SubjectCount, RANK() OVER(ORDER BY SubjectCount DESC) AS RANKING 
FROM SUBJECT
GROUP BY SUBJECT;

#10  Find museums open on both Sundays and Mondays, displaying their names and cities.
SELECT M.NAME, M.CITY 
FROM MUSEUM M
JOIN MUSEUM_HOURS MH1 ON M.MUSEUM_ID = MH1.MUSEUM_ID AND MH1.DAY = 'Sunday'
JOIN MUSEUM_HOURS MH2 ON M.MUSEUM_ID = MH2.MUSEUM_ID AND MH2.DAY = 'Monday'
GROUP BY M.NAME, M.CITY
HAVING COUNT(DISTINCT MH1.DAY) = 1 AND COUNT(DISTINCT MH2.DAY) = 1;

#11  How many museums are open every day of the week?
select count(*)  from 
(select museum_id from MUSEUM_HOURS group by museum_id having  count(distinct day) = 7);

#12 List the top 5 most popular museums based on the highest number of paintings.

select work.museum_id, museum.name, count(work_id) as total_paintings from work 
join museum on museum.museum_id = work.museum_id
group by work.museum_id, museum.name order by count(work_id) desc limit 5;

#13 Who are the top 5 most favored artists based on the highest number of paintings attributed to them?

select work.artist_id, artist.full_name, count(work_id) as total_paintings from work 
join artist on artist.artist_id = work.artist_id
group by work.artist_id, artist.full_name order by count(work_id) desc limit 5;

#14  Display the 3 least popular canvas sizes.

select PRODUCT_SIZE.size_id, count(work_id) as total_paintings, canvas_size.label, dense_rank() over(order by count(work_id) asc ) as rnk from product_size join 
canvas_size on  canvas_size.size_id:: text  = product_size.size_id  
group by PRODUCT_SIZE.size_id,canvas_size.label; 

#15 Identify the museum open for the longest duration during the day, including its name, state, hours, and corresponding day.
 
SELECT 
    NEW.MUSEUM_ID, 
    NEW.DAY, 
    NEW.DURATION,
    MUSEUM.STATE AS CITY, 
    MUSEUM.NAME
FROM 
    (SELECT 
         MUSEUM_ID,
         DAY,
         TO_TIMESTAMP(OPEN, 'HH:MI:AM') AS OPEN_TIME, 
         TO_TIMESTAMP(CLOSE, 'HH:MI:PM') AS CLOSING_TIME, 
         TO_TIMESTAMP(CLOSE, 'HH:MI:PM') - TO_TIMESTAMP(OPEN, 'HH:MI:AM') AS DURATION  
     FROM 
         MUSEUM_HOURS) AS NEW
JOIN 
    MUSEUM ON NEW.MUSEUM_ID = MUSEUM.MUSEUM_ID
ORDER BY DURATION DESC LIMIT 3;

#16 Determine the museum with the most popular painting style. 
SELECT 
    cte.museum_name, 
    cte.style, 
    cte.no_of_paintings
FROM (
    SELECT 
        w.museum_id,
        m.name AS museum_name,
        w.style,
        COUNT(1) AS no_of_paintings,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM 
        work w
    JOIN 
        museum m ON m.museum_id = w.museum_id
    WHERE 
        w.museum_id IS NOT NULL
        AND w.style IN (
            SELECT 
                style
            FROM (
                SELECT 
                    style,
                    RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
                FROM 
                    work
                GROUP BY 
                    style
            ) AS pop_style
            WHERE 
                pop_style.rnk = 1
        )
    GROUP BY 
        w.museum_id, 
        m.name, 
        w.style
) AS cte
WHERE 
    cte.rnk = 1;
	
#17 Find artists whose paintings are exhibited in multiple countries.

SELECT * FROM ARTIST
SELECT * FROM  WORK

SELECT * FROM MUSEUM 

# SELECT MUSEUM.MUSEUM_ID , MUSEUM.COUNTRY, WORK.ARTIST_ID FROM MUSEUM 
JOIN WORK ON WORK.MUSEUM_ID = MUSEUM.MUSEUM_ID;  

SELECT OLD.ARTIST_ID, OLD.COUNTRIES, ARTIST.FULL_NAME FROM  (SELECT NEW.ARTIST_ID ,COUNT(DISTINCT NEW.COUNTRY) AS COUNTRIES FROM (SELECT MUSEUM.MUSEUM_ID , MUSEUM.COUNTRY, WORK.ARTIST_ID FROM MUSEUM 
JOIN WORK ON WORK.MUSEUM_ID = MUSEUM.MUSEUM_ID) AS NEW GROUP BY ARTIST_ID HAVING COUNT(DISTINCT NEW.COUNTRY)>1 ) AS OLD JOIN ARTIST 
ON ARTIST.ARTIST_ID =  OLD.ARTIST_ID ORDER BY COUNTRIES DESC


# 18  Identify the artist and museum housing the most and least expensive paintings, including their respective details.
 SELECT * 
FROM (
    SELECT * 
    FROM (
        SELECT DISTINCT 
            WORK_ID, 
            SALE_PRICE, 
            DENSE_RANK() OVER (ORDER BY SALE_PRICE DESC) AS RNK,
            DENSE_RANK() OVER (ORDER BY SALE_PRICE ASC) AS RNK_ASC  
        FROM PRODUCT_SIZE 
    ) AS NEW 
    JOIN WORK ON WORK.WORK_ID = NEW.WORK_ID
) AS RESULT WHERE RNK = 1 OR RNK_ASC = 1;

#19 Determine the country with the fifth-highest number of paintings.
SELECT * FROM MUSEUM
SELECT * FROM WORK

WITH CTE AS ( SELECT 
    COUNT(WORK_ID)  AS TOTAL_PAINTNGS,  
    MUSEUM.COUNTRY, 
    DENSE_RANK() OVER (ORDER BY COUNT(WORK_ID) DESC) AS RNK 
FROM 
    MUSEUM 
JOIN
    WORK ON MUSEUM.MUSEUM_ID = WORK.MUSEUM_ID
GROUP BY 
    MUSEUM.COUNTRY) SELECT COUNTRY , TOTAL_PAINTNGS FROM  CTE 
	WHERE RNK = 5 

#20  List the 3 most and least popular painting styles.
WITH CTE AS (SELECT  STYLE , COUNT(STYLE), DENSE_RANK() OVER(ORDER BY COUNT(STYLE) DESC) AS RNK, 
			 DENSE_RANK() OVER(ORDER BY COUNT(STYLE) ASC) AS RNK_ASC 
FROM WORK WHERE STYLE IS NOT NULL 
GROUP BY STYLE ) SELECT STYLE, RNK FROM CTE  WHERE RNK <4 OR RNK_ASC <4     

	



















