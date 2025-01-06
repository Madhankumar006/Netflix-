DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT * FROM netflix






--Count the number of Movies vs TV Shows 

SELECT type,COUNT(*) as total_content
FROM netflix
GROUP BY type

--Find the most common rating for movies and TV shows
WITH CTE as (
SELECT 
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as rk
FROM netflix
GROUP BY 1,2 ) 

SELECT type,rating FROM CTE 
WHERE rk = 1 

---List all movies released in a specific year (e.g., 2020)

SELECT * FROM netflix 
WHERE release_year = 2020 and type='Movie'

--Find the top 5 countries with the most content on Netflix

SELECT UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
COUNT(*) 
FROM netflix
GROUP BY new_country
ORDER BY COUNT(*) DESC
LIMIT 5

--Identify the longest movie
SELECT *
FROM netflix 
WHERE type = 'Movie' and duration =(SELECT MAX(duration) FROM netflix)

---Find content added in the last 5 years

SELECT * 
FROM netflix 
WHERE 
	TO_DATE(date_added,'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM netflix
WHERE director = 'Rajiv Chilaka'

--List all TV shows with more than 5 seasons
SELECT * 
FROM netflix 
WHERE type = 'TV Show' and 
		SPLIT_PART(duration,' ',1)::numeric > 5

-- Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as genres,
	COUNT(show_id) as no_of_content
FROM netflix
GROUP BY genres


-- Find each year and the average numbers of content release in India on netflix. 
SELECT 
EXTRACT (YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) as year,
COUNT(*) as contents,
COUNT(*)::numeric /(SELECT COUNT(*) FROM netflix WHERE country='India')::numeric * 100 as AVG_CONTENT
FROM netflix 
WHERE country = 'India'
GROUP BY 1




--return top 5 year with highest avg content release
SELECT release_year,
COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix)::numeric * 100 as AVG_counts
FROM netflix
GROUP BY release_year
ORDER BY 2 DESC
LIMIT 5

--List all movies that are documentaries
SELECT * 
FROM netflix
WHERE listed_in ILIKE '%documentaries%'


--Find all content without a director

SELECT * 
FROM netflix 
WHERE director IS NULL


--Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *  
FROM netflix
WHERE casts Ilike '%Salman Khan%' and 
		release_year >= EXTRACT(YEAR FROM CURRENT_DATE)-10 


--Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
UNNEST(STRING_TO_ARRAY(casts,',')) as actor_list,
COUNT(*) as countLIst
FROM netflix 
WHERE country = 'India'
GROUP BY actor_list
ORDER BY 2 DESC
LIMIT 10



--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

with cte as (
SELECT *,
	CASE 
		WHEN description ILIKE '%kill%' or description ILIKE '%violence%' THEN 'Bad_content'
		ELSE 'Good_content'
		END as Category
FROM netflix )

SELECT category,COUNT(Category) as counts
FROM cte 
GROUP BY category



