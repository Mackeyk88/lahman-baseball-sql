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

SELECT 100*ROUND(CAST(COUNT(*) as numeric)/CAST(2016-1970 as numeric),2)
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


SELECT *
FROM awardsmanagers

SELECT *
FROM managers


SELECT CONCAT(namefirst,' ', namelast), t.name, t.lgid 
FROM awardsmanagers as am1
CROSS JOIN awardsmanagers as am2
INNER JOIN people as p
ON am1.playerid = p.playerid
INNER JOIN managershalf as mh
ON p.playerid = mh.playerid
INNER JOIN teams as t
ON mh.yearid = t.yearid
WHERE am1.awardid = 'TSN Manager of the Year' AND t.lgid = 'AL' AND t.lgid = 'NL'


-- SELECT t.yearid, CONCAT(namefirst,' ', namelast) as full_name, name, awardid, t.lgid
-- FROM awardsmanagers as am
-- INNER JOIN people as p
-- ON am.playerid = p.playerid
-- INNER JOIN managershalf as mh
-- ON p.playerid = mh.playerid
-- INNER JOIN teams as t
-- ON mh.teamid = t.teamid
-- WHERE awardid = 'TSN Manager of the Year' AND t.lgid = 'AL'
-- GROUP BY t.yearid, full_name, name, awardid, t.lgid
-- ORDER BY t.yearid DESC






WITH subq as (SELECT playerid 
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year' AND yearid > 1985 AND lgid = 'NL' 

INTERSECT

SELECT playerid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year' AND yearid > 1985 AND lgid = 'AL'
ORDER BY playerid)





-- SELECT yearid, playerid, lgid
-- FROM awardsmanagers
-- WHERE awardid = 'TSN Manager of the Year' AND yearid > 1985 AND lgid = 'NL' 

-- UNION

-- SELECT yearid, playerid, lgid
-- FROM awardsmanagers
-- WHERE awardid = 'TSN Manager of the Year' AND yearid > 1985 AND lgid = 'AL'
-- ORDER BY yearid







WITH subq1 as (SELECT playerid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'),

subq2 as (SELECT playerid 
FROM awardsmanagers as am
WHERE lgid = 'AL'),

subq3 as (SELECT playerid 
FROM awardsmanagers as am
WHERE lgid = 'NL'),

subq4 as (SELECT yearid, playerid, lgid
FROM
(SELECT yearid, am.playerid, lgid
FROM awardsmanagers as am
WHERE awardid = 'TSN Manager of the Year' AND am.yearid > 1985 AND am.lgid = 'NL'
UNION
SELECT yearid, am.playerid, lgid
FROM awardsmanagers as am
WHERE awardid = 'TSN Manager of the Year' AND am.yearid > 1985 AND am.lgid = 'AL') as subq
ORDER BY playerid)



SELECT CONCAT(namefirst, ' ', namelast) as full_name, name 





WITH subq as (SELECT yearid, am.playerid, lgid
FROM awardsmanagers as am
WHERE awardid = 'TSN Manager of the Year' AND am.yearid > 1985 AND am.lgid = 'NL'
UNION
SELECT yearid, am.playerid, lgid
FROM awardsmanagers as am
WHERE awardid = 'TSN Manager of the Year' AND am.yearid > 1985 AND am.lgid = 'AL')

SELECT playerid, lgid
FROM subq
WHERE lgid = 'NL'
UNION
SELECT playerid, lgid
FROM subq
WHERE lgid = 'AL'

