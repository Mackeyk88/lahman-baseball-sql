SELECT * 
FROM teams
ORDER BY yearid DESC

SELECT MIN(yearid), MAX(yearid)
FROM teams
-- 1871-2016

SELECT namefirst, namelast, namegiven,  height
FROM people
ORDER BY height 
-- Eddie Gaedel, 43 in.

SELECT namefirst, namelast, namegiven, g_all, height , name as team_name
FROM people as p
INNER JOIN appearances as a
ON p.playerid = a.playerid
INNER JOIN teams as t
ON a.teamid = t.teamid
ORDER BY height 
-- Eddie Gaedel, 43 in., 1 game appearance, St.Louis Browns



SELECT DISTINCT CONCAT(namefirst, ' ', namelast) as full_name, 
CAST(CAST(SUM(salary) as numeric)as money) as total_salary
FROM people as p
INNER JOIN collegeplaying as cp
ON p.playerid = cp.playerid
INNER JOIN schools as sc
ON cp.schoolid = sc.schoolid
INNER JOIN salaries as sa
ON p.playerid = sa.playerid
WHERE schoolname = 'Vanderbilt University'
GROUP BY full_name
ORDER BY total_salary DESC
-- David Price", $245,553,888


SELECT
CASE WHEN pos = 'OF' THEN 'Outfield'
     WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
     WHEN pos IN ('P','C') THEN 'Battery' END as position_group, SUM(po) as total_putouts
FROM fielding as f
WHERE yearid = 2016
GROUP BY position_group
--  "Battery"	41424
-- "Infield"	58934
-- "Outfield"	29560
 

SELECT CONCAT(LEFT(CAST(yearid as text), 3),'0') as decade, SUM(g) as total_games, 
SUM(so) as total_strikeouts, SUM(hr) as total_homeruns, 
ROUND(CAST(SUM(so)/CAST(SUM(g) as float) as numeric),2) as avg_strikeouts_per_game,  
ROUND(CAST(SUM(hr)/CAST(SUM(g) as float) as numeric),2) as avg_homeruns_per_game
FROM teams as t
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade
-- SO's and HR's increased over time, possibly due to advancement in pitching style,
--  fitness, equiptment, and roids in the late 90's early 2000's
 
 
 SELECT CONCAT(namefirst,' ', namelast) as name, sb as succesful_stolen_bases, 
 cs as unsuccessful_stolen_bases,
 sb + cs as total_tolen_bases, ROUND(CAST(sb/CAST(sb+cs as float) as numeric),2) as success_rate
 FROM batting as b
 LEFT JOIN people as p
 ON b.playerid = p.playerid
 WHERE sb IS NOT NULL AND cs IS NOT NULL AND yearid = 2016 AND sb <> 0 AND cs <> 0 AND sb+cs >= 20
 ORDER BY success_rate DESC
--  "Chris Owings"	91% success rate
 
 
 SELECT name, MAX(w) as max, wswin
 FROM teams
 WHERE wswin = 'N' and yearid BETWEEN 1970 AND 2016
 GROUP BY name, wswin
 ORDER BY max DESC
-- Highest wins with no wswin:   
-- "Seattle Mariners" 116

 SELECT name, MIN(w) as min, wswin, yearid
 FROM teams
 WHERE wswin = 'Y' and yearid BETWEEN 1970 AND 2016
 GROUP BY name, wswin, yearid
 ORDER BY min
--  Lowest wins with a wswin
--  "Los Angeles Dodgers" 63 wins
-- Due to the MLB strike there were only 103 - 111 games played instead of the normal 162 games

SELECT name, MIN(w) as min, wswin, yearid
 FROM teams
 WHERE wswin = 'Y' AND name <> 'Los Angeles Dodgers' and yearid BETWEEN 1970 AND 2016
 GROUP BY name, wswin, yearid
 ORDER BY min
 --  Lowest wins with a wswin
--  "St. Louis Cardinals" 83 wins

WITH subq as (SELECT t.yearid, name, max_w, wswin
FROM teams as t
INNER JOIN 
    (SELECT yearid, MAX(w) as max_w
    FROM teams
    GROUP BY yearid) as s
ON t.yearid = s.yearid
GROUP BY t.yearid, max_w, w, wswin, name
HAVING w = max_w AND t.yearid BETWEEN 1970 AND 2016 AND wswin = 'Y')
-- 12 teams have had the best record and won the world series in the same year.

SELECT 100*ROUND(CAST(COUNT(*) as numeric)/CAST(2016-1970 as numeric),2) as highestwins_wswinnwer
FROM subq
-- 26% of teams who have the best record also win the world series
   
 

SELECT team, park, SUM(attendance)/SUM(games) as avg_attend
FROM homegames
WHERE year = 2016 and games >= 10
GROUP BY team, park
ORDER BY avg_attend DESC
-- "LAN"	"LOS03"	45719
-- "SLN"	"STL10"	42524
-- "TOR"	"TOR02"	41877
-- "SFN"	"SFO03"	41546
-- "CHN"	"CHI11"	39906

SELECT team, park, SUM(attendance)/SUM(games) as avg_attend
FROM homegames
WHERE year = 2016 and games >= 10
GROUP BY team, park
ORDER BY avg_attend 
-- "TBA"	"STP01"	15878
-- "OAK"	"OAK01"	18784
-- "CLE"	"CLE08"	19650
-- "MIA"	"MIA02"	21405
-- "CHA"	"CHI12"	21559



WITH subq1 as (SELECT playerid, awardid, COUNT(DISTINCT lgid) as lg_count
FROM awardsmanagers as am
WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('NL', 'AL')
GROUP BY playerid, awardid
HAVING COUNT(DISTINCT lgid) = 2),

subq2 as (SELECT s1.playerid, s1.awardid, lg_count, yearid, lgid
FROM subq1 as s1
INNER JOIN awardsmanagers as am
ON s1.playerid = am.playerid AND s1.awardid = am.awardid)

SELECT s2.yearid, CONCAT(namefirst, ' ', namelast) as full_name, name, s2.lgid
FROM subq2 as s2
INNER JOIN people as p
ON s2.playerid = p.playerid
INNER JOIN managers as m
ON s2.yearid = m.yearid AND s2.lgid = m.lgid AND s2.playerid = m.playerid
INNER JOIN teams as t
ON m.yearid = t.yearid AND m.teamid = t.teamid AND m.lgid = t.lgid
ORDER BY full_name

-- "Davey Johnson"	"Baltimore Orioles"	"AL"
-- "Davey Johnson"	"Washington Nationals"	"NL"
-- "Jim Leyland"	"Pittsburgh Pirates"	"NL"
-- "Jim Leyland"	"Pittsburgh Pirates"	"NL"
-- "Jim Leyland"	"Pittsburgh Pirates"	"NL"
-- "Jim Leyland"	"Detroit Tigers"	    "AL" 


WITH subq1 as (SELECT playerid, yearid, teamid, lgid, hr
FROM batting as b
WHERE yearid = 2016
ORDER BY hr DESC),

subq2 as (SELECT playerid, MAX(hr) as max_hr
FROM batting as b
GROUP BY playerid
ORDER BY max_hr DESC),

subq3 as (SELECT playerid, CAST(REPLACE(finalgame,'-','') as date), 
CAST(REPLACE(debut,'-','') as date),
(CAST(REPLACE(finalgame,'-','') as date) - CAST(REPLACE(debut,'-','') as date))/365 as years_played
FROM people)


SELECT s1.playerid, CONCAT(namefirst, ' ', namelast), max_hr
FROM subq1 as s1
INNER JOIN subq2 
USING (playerid)
INNER JOIN subq3 as s3
USING (playerid)
INNER JOIN people as p 
USING (playerid)
WHERE max_hr = hr and hr > 0 AND years_played >= 10




WITH subq1 as (SELECT playerid, yearid, teamid, lgid, hr
FROM batting as b
WHERE yearid = 2016
ORDER BY hr DESC),

subq2 as (SELECT playerid, MAX(hr) as max_hr
FROM batting as b
GROUP BY playerid
ORDER BY max_hr DESC),

subq3 as (SELECT playerid, COUNT(yearid) as years_played
          FROM batting
          GROUP BY playerid)


SELECT s1.playerid, CONCAT(namefirst, ' ', namelast), max_hr, years_played, s1.yearid
FROM subq1 as s1
INNER JOIN subq2 
USING (playerid)
INNER JOIN subq3 as s3
USING (playerid)
INNER JOIN people as p 
USING (playerid)
WHERE max_hr = hr and hr > 0 AND years_played >= 10
ORDER BY max_hr DESC












-- BONUS

SELECT yearid, teamid, SUM(salary) as total_salary, w
FROM salaries
INNER JOIN teams as t
USING(yearid,teamid)
WHERE yearid >= 2000 AND teamid = 'BAL'
GROUP BY yearid, teamid,w
ORDER BY total_salary

WITH subq as (SELECT yearid, ROUND(CAST(AVG(salary) as numeric),0) as avg_salary
FROM salaries
WHERE yearid >= 2000 
GROUP BY yearid
ORDER BY yearid),

subq2 as (SELECT yearid, MAX(w) as max_wins
FROM teams
WHERE yearid >= 2000
GROUP BY yearid
ORDER BY yearid),

subq3 as (SELECT yearid, ROUND(AVG(w),0) as avg_wins
FROM teams
WHERE yearid >= 2000
GROUP BY yearid
ORDER BY yearid),

subq4 as (SELECT yearid, ROUND(CAST(MAX(salary) as int),2) as max_salary
FROM salaries
WHERE yearid >= 2000 
GROUP BY yearid
ORDER BY yearid)


SELECT yearid, avg_salary, max_salary, avg_wins, max_wins
FROM subq
INNER JOIN subq2
USING (yearid)
INNER JOIN subq3
USING (yearid)
INNER JOIN subq4
USING (yearid)


WITH subq as (SELECT yearid, MAX(w) as max_w
FROM teams
GROUP BY yearid
ORDER BY yearid)

SELECT yearid, max_w, salary
FROM teams as t
INNER JOIN salaries as s
USING (yearid,teamid,lgid)
INNER JOIN subq as s1
USING (yearid)
GROUP BY yearid, salary, max_w








WITH subq1 as (SELECT yearid, ROUND(CAST(AVG(salary) as numeric),0) as avg_salary
FROM salaries 
WHERE yearid >= 2000
GROUP BY yearid
ORDER BY yearid),

subq2 as (SELECT yearid, 
ROUND(CAST(avg_salary - LAG(avg_salary) OVER(ORDER BY yearid) as numeric),0) as salary_cap_increase
FROM subq1
WHERE yearid >= 2000),

subq3 as (SELECT yearid, MAX(w) as max_wins
FROM teams         
WHERE yearid >= 2000
GROUP BY yearid
ORDER BY yearid),

subq4 as (SELECT yearid, MAX(salary) as max_salary
FROM salaries 
WHERE yearid >= 2000
GROUP BY yearid
ORDER BY yearid)

SELECT yearid, salary_cap_increase, max_wins, avg_salary
FROM subq1
INNER JOIN subq2
USING (yearid)
INNER JOIN subq3
USING (yearid)
INNER JOIN subq4
USING (yearid)


SELECT teamid, SUM(salary) as total_salary
FROM teams
INNER JOIN salaries
USING (yearid, teamid,lgid)
GROUP BY teamid
ORDER BY total_salary DESC



SELECT 