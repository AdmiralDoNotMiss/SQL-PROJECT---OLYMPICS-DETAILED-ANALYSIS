-- TEAMS WHO HAVE WON THE MAXIMUM GOLD MEDALS OVER THE YEARS.

SELECT  team,COUNT(DISTINCT event) as cnt 
FROM olympics.athlete_events ae
INNER JOIN  olympics.athletes a 
ON ae.athlete_id=a.id
WHERE medal='Gold'
GROUP BY team
ORDER BY cnt DESC;

-- TOTAL SILVER MEDALS WON BY EACH TEAM AND THE YEAR WHERE THEY'VE WON THE MAXIMUM SILVER MEDALS.

WITH CTE AS (
SELECT a.team,ae.year , COUNT(DISTINCT event) as silver_medals
,RANK() OVER(PARTITION BY team ORDER BY COUNT(DISTINCT event) DESC) as rn
FROM olympics.athlete_events ae
INNER JOIN olympics.athletes a 
ON ae.athlete_id=a.id
WHERE medal='Silver'
GROUP BY a.team,ae.year
)
SELECT team,SUM(silver_medals) as total_silver_medals, MAX(case when rn=1 THEN year END) as  year_of_max_silver
FROM CTE
GROUP BY team
ORDER BY total_silver_medals DESC;

-- PLAYER WHO HAS WON MAXIMUM GOLD MEDALS AMONGST ALL THE PLAYERS.

WITH CTE AS (
SELECT name,medal
FROM olympics.athlete_events ae
INNER JOIN olympics.athletes a 
ON ae.athlete_id=a.id
)
SELECT name, COUNT(1) as no_of_gold_medals
FROM CTE 
WHERE name NOT IN (SELECT DISTINCT name FROM CTE WHERE medal in ('Silver','Bronze'))
AND medal='Gold'
GROUP BY name
ORDER BY no_of_gold_medals DESC
LIMIT 1
;
-- YEAR WISE ANALYSIS ON WHICH PLAYER HAS WON MAXIMUM GOLD MEDALS EACH YEAR. 

WITH CTE AS (
SELECT ae.year,a.name,COUNT(1) as no_of_gold
FROM olympics.athlete_events ae
INNER JOIN  olympics.athletes a 
ON ae.athlete_id=a.id
WHERE medal='Gold'
GROUP BY ae.year,a.name
)
SELECT year,no_of_gold,GROUP_CONCAT(name,',') as players 
FROM (
SELECT *,
RANK() OVER(PARTITION BY year ORDER BY no_of_gold DESC) as rn
FROM CTE) a 
WHERE rn=1
GROUP BY year,no_of_gold
;

-- IN WHICH EVENT INDIA HAS WON FIRST GOLD,SILVER AND VRONZE MEDAL

SELECT DISTINCT * FROM (
SELECT medal,year,event,
RANK() OVER(PARTITION BY  medal ORDER BY  year) rn
FROM olympics.athlete_events ae
INNER JOIN  olympics.athletes a 
ON ae.athlete_id=a.id
WHERE team='India' and medal != 'NA'
) A
WHERE rn=1
;

--  PLAYERS WHO HAVE WON GOLD MEDAL IN BOTH SUMMER AND WINTER SEASON
SELECT a.name  
FROM olympics.athlete_events ae
INNER JOIN olympics.athletes a 
ON ae.athlete_id=a.id
WHERE medal='Gold'
GROUP BY a.name 
HAVING COUNT(DISTINCT season)=2;

-- PLAYERS WHO HAVE WON GOLD,SILVER AND BRONZE MEDAL IN A SINGLE OLYMPIC

SELECT year,name
FROM olympics.athlete_events ae
INNER JOIN olympics.athletes a 
ON ae.athlete_id=a.id
WHERE medal != 'NA'
GROUP BY  year,name 
HAVING COUNT(DISTINCT medal)=3;

--  PLAYERS WHO HAVE WON GOLD MEDALS IN 3 CONSECUTIVE SUMMER OLYMPICS AND IN THE SAME EVENT CONSIDERING ONLY OLYMPICS 2000 ONWARDS. 

WITH CTE AS (
SELECT name,year,event
FROM olympics.athlete_events ae
INNER JOIN olympics.athletes a 
ON ae.athlete_id=a.id
WHERE year >=2000 AND season='Summer'AND medal = 'Gold'
GROUP BY name,year,event
)
SELECT * FROM
(SELECT *, LAG(year,1) OVER(PARTITION BY name,event ORDER BY year ) as prev_year
, LEAD(year,1) OVER(PARTITION BY  name,event ORDER BY year ) as next_year
FROM CTE) A
WHERE year=prev_year+4 AND  year=next_year-4





