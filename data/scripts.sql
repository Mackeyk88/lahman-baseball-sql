SELECT * 
FROM teams

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
-- Edward Carl, 43 in., 1 game appearance, St.Louis Browns



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
-- David Price", $245,553,888.00


SELECT
CASE WHEN pos = 'OF' THEN 'Outfield'
     WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
     WHEN pos IN ('P','C') THEN 'Battery' END as position_group, SUM(po) as total_putouts
FROM fielding as f
INNER JOIN people as p 
ON f.playerid = p.playerid
INNER JOIN appearances as a 
ON p.playerid = a.playerid
INNER JOIN teams as t
ON a.teamid = t.teamid
WHERE t.yearid = 2016
GROUP BY position_group
     



