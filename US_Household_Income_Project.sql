
SELECT * FROM US_Household_Income.USHouseholdIncome;

SELECT * FROM US_Household_Income.ushouseholdincome_statistics;

-- count
SELECT COUNT(id)
FROM US_Household_Income.USHouseholdIncome;

SELECT COUNT(id) 
FROM US_Household_Income.ushouseholdincome_statistics;

-- cleaning data
-- identify duplicates
SELECT id, COUNT(id)
FROM US_Household_Income.USHouseholdIncome
GROUP BY id
HAVING COUNT(id) > 1
;

-- use row_id to delete duplicates
DELETE FROM USHouseholdIncome
WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id,
		id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
		FROM US_Household_Income.USHouseholdIncome
		) AS row_table
	WHERE row_num > 1)
;

SELECT id, COUNT(id)
FROM ushouseholdincome_statistics
GROUP BY id
HAVING COUNT(id) > 1
;

-- explore other errors
SELECT DISTINCT(State_Name)
FROM USHouseholdIncome;

-- found 'georia' suppose to be 'Georgia' 
UPDATE USHouseholdIncome
SET State_Name = 'Georgia'
WHERE State_name = 'georia';

-- found NULL vale in Place, populate it
SELECT *
FROM USHouseholdIncome
WHERE Place IS NULL
;

UPDATE USHouseholdIncome
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont'
;

SELECT DISTINCT(Type), COUNT(Type)
FROM USHouseholdIncome
GROUP BY Type
;

-- correct spelling mistake and group data 
UPDATE USHouseholdIncome
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;

-- change names, remove duplicates, update State_Name to correct format, populate missing/NULL value

-- EDA project
-- which state has more land
SELECT State_Name, SUM(Aland), Sum(Awater)
FROM USHouseholdIncome
GROUP BY State_Name
ORDER BY SUM(Aland) DESC
LIMIT 10
;

-- which state has more water
SELECT State_Name, SUM(Aland), Sum(Awater)
FROM USHouseholdIncome
GROUP BY State_Name
ORDER BY SUM(Awater) DESC
LIMIT 10
;

-- join two tables together 
SELECT * 
FROM US_Household_Income.USHouseholdIncome ui
INNER JOIN US_Household_Income.ushouseholdincome_statistics us
	ON ui.id = us.id
    ;

-- explore statistics at the state level
-- which state has lowest average income
SELECT ui.State_Name, ROUND(AVG(Mean)), ROUND(AVG(Median)) 
FROM US_Household_Income.USHouseholdIncome ui
INNER JOIN US_Household_Income.ushouseholdincome_statistics us
	ON ui.id = us.id
WHERE Mean <> 0
GROUP BY ui.State_Name 
ORDER BY 2 
LIMIT 5
    ;


-- which state has the highest average income
SELECT ui.State_Name, ROUND(AVG(Mean)), ROUND(AVG(Median)) 
FROM US_Household_Income.USHouseholdIncome ui
INNER JOIN US_Household_Income.ushouseholdincome_statistics us
	ON ui.id = us.id
WHERE Mean <> 0
GROUP BY ui.State_Name 
ORDER BY 2 DESC
LIMIT 5
    ;

-- explore the income according to Type - highest 
SELECT ui.Type, COUNT(Type), ROUND(AVG(Mean)), ROUND(AVG(Median)) 
FROM US_Household_Income.USHouseholdIncome ui
INNER JOIN US_Household_Income.ushouseholdincome_statistics us
	ON ui.id = us.id
WHERE Mean <> 0
GROUP BY ui.Type
ORDER BY 3 DESC
LIMIT 10
    ;

-- lowest income according to Type 
SELECT ui.Type, COUNT(Type), ROUND(AVG(Mean)), ROUND(AVG(Median)) 
FROM US_Household_Income.USHouseholdIncome ui
INNER JOIN US_Household_Income.ushouseholdincome_statistics us
	ON ui.id = us.id
WHERE Mean <> 0
GROUP BY ui.Type
ORDER BY 3 
LIMIT 10
    ;

-- filter out outliners
SELECT ui.Type, COUNT(Type), ROUND(AVG(Mean)), ROUND(AVG(Median)) 
FROM US_Household_Income.USHouseholdIncome ui
INNER JOIN US_Household_Income.ushouseholdincome_statistics us
	ON ui.id = us.id
WHERE Mean <> 0
GROUP BY 1
HAVING COUNT(Type) > 100
ORDER BY 4 DESC
LIMIT 10
    ;
    
-- city level -- highest income city
SELECT ui.State_Name, ui.City, ROUND(AVG(Mean)), ROUND(AVG(Median)) 
FROM US_Household_Income.USHouseholdIncome ui
INNER JOIN US_Household_Income.ushouseholdincome_statistics us
	ON ui.id = us.id
GROUP BY ui.State_Name, ui.City
ORDER BY ROUND(AVG(Mean)) DESC
    ;
    
-- median, CAP at 300000 (how do they report?)
SELECT ui.State_Name, ui.City, ROUND(AVG(Mean)), ROUND(AVG(Median)) 
FROM US_Household_Income.USHouseholdIncome ui
INNER JOIN US_Household_Income.ushouseholdincome_statistics us
	ON ui.id = us.id
GROUP BY ui.State_Name, ui.City
ORDER BY ROUND(AVG(Median)) DESC
    ;
    
-- ranking the cities that I visited
SELECT ui.State_Name, ui.City, ROUND(AVG(Mean)), ROUND(AVG(Median)),
DENSE_RANK() OVER (ORDER BY ROUND(AVG(Median)) DESC) AS ranking 
FROM US_Household_Income.USHouseholdIncome ui
INNER JOIN US_Household_Income.ushouseholdincome_statistics us
	ON ui.id = us.id
GROUP BY ui.State_Name, ui.City
HAVING ui.City IN ('New York', 'Boston', 'San Francisco', 'Chicago', 'Philadelphia' )
ORDER BY ranking 
    ;

SELECT ui.State_Name, ui.City, ROUND(AVG(Mean)), ROUND(AVG(Median)),
DENSE_RANK() OVER (ORDER BY ROUND(AVG(Mean)) DESC) AS ranking 
FROM US_Household_Income.USHouseholdIncome ui
INNER JOIN US_Household_Income.ushouseholdincome_statistics us
	ON ui.id = us.id
GROUP BY ui.State_Name, ui.City
HAVING ui.City IN ('New York', 'Boston', 'San Francisco', 'Chicago', 'Philadelphia' )
ORDER BY ranking 
    ;
