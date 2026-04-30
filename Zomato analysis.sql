CREATE DATABASE zomato_db;

USE zomato_db;
SELECT * FROM Restaurants LIMIT 10;

----- Q1. Build a Country Map Table ------
CREATE TABLE Country_Map (
    CountryCode INT,
    CountryName VARCHAR(100)
);

INSERT INTO Country_Map VALUES
(1,'India'),
(14,'Australia'),
(30,'Brazil'),
(37,'Canada'),
(94,'Indonesia'),
(148,'New Zealand'),
(162,'Philippines'),
(166,'Qatar'),
(184,'Singapore'),
(189,'South Africa'),
(191,'Sri Lanka'),
(208,'Turkey'),
(214,'UAE'),
(215,'United Kingdom'),
(216,'United States');
select * from Country_Map;

----- Q2 Create Calendar Table -----
CREATE TABLE Calendar (
    DateKey DATE,
    Year INT,
    MonthNo INT,
    MonthFullName VARCHAR(20),
    Quarter VARCHAR(2),
    YearMonth VARCHAR(10),
    WeekdayNo INT,
    WeekdayName VARCHAR(20),
    FinancialMonth VARCHAR(5),
    FinancialQuarter VARCHAR(3)
);
----- Insert Data ------
INSERT INTO Calendar (DateKey)
SELECT CURDATE() - INTERVAL (a.a + (10*b.a) + (100*c.a)) DAY
FROM 
(SELECT 0 a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a,
(SELECT 0 a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b,
(SELECT 0 a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) c;
------ Update Columns -----
SET SQL_SAFE_UPDATES = 0;
UPDATE Calendar
SET 
    Year = YEAR(DateKey),
    MonthNo = MONTH(DateKey),
    MonthFullName = MONTHNAME(DateKey),
    Quarter = CONCAT('Q', QUARTER(DateKey)),
    YearMonth = DATE_FORMAT(DateKey, '%Y-%b'),
    WeekdayNo = DAYOFWEEK(DateKey),
    WeekdayName = DAYNAME(DateKey);
SET SQL_SAFE_UPDATES = 1;
------ Financial Month ------
SET SQL_SAFE_UPDATES = 0;
UPDATE Calendar
SET FinancialMonth = CONCAT('FM',
    CASE 
        WHEN MONTH(DateKey) >= 4 THEN MONTH(DateKey) - 3
        ELSE MONTH(DateKey) + 9
    END
);
------- Financial Quarter ----
UPDATE Calendar
SET FinancialQuarter =
CASE 
    WHEN MONTH(DateKey) BETWEEN 4 AND 6 THEN 'FQ1'
    WHEN MONTH(DateKey) BETWEEN 7 AND 9 THEN 'FQ2'
    WHEN MONTH(DateKey) BETWEEN 10 AND 12 THEN 'FQ3'
    ELSE 'FQ4'
END;

SELECT * FROM Calendar LIMIT 10;

------ Q3. Number of Restaurants by City and Country ------
DESC Restaurants;
SELECT 
    c.CountryName,
    r.City,
    COUNT(DISTINCT r.RestaurantID) AS Total_Restaurants
FROM Restaurants r
JOIN Country_Map c 
ON r.CountryCode = c.CountryCode
GROUP BY c.CountryName, r.City
ORDER BY Total_Restaurants DESC;

------ Q4. Restaurants Opening by Year, Quarter, Month -----

SELECT 
    YEAR(Opening_date) AS Year,
    CONCAT('Q', QUARTER(Opening_date)) AS Quarter,
    MONTH(Opening_date) AS MonthNo,
    MONTHNAME(Opening_date) AS Month,
    COUNT(*) AS Total_Restaurants
FROM Restaurants
GROUP BY 
    Year, Quarter, MonthNo, Month
ORDER BY 
    Year, Quarter, MonthNo;
    
----- Q5 Restaurants count by Rating -----
SELECT 
    Rating,
    COUNT(*) AS Total_Restaurants
FROM Restaurants
WHERE Rating IS NOT NULL
GROUP BY Rating
ORDER BY Rating DESC;

---- Q6: Bucket Restaurants by Average Price -----
SELECT 'Low' AS Price_Bucket, COUNT(*) AS Total_Restaurants
FROM Restaurants
WHERE Average_Cost_for_two < 1000
UNION ALL
SELECT 'Medium', COUNT(*)
FROM Restaurants
WHERE Average_Cost_for_two BETWEEN 1000 AND 3000
UNION ALL
SELECT 'High', COUNT(*)
FROM Restaurants
WHERE Average_Cost_for_two > 3000;

---- Q7: Percentage of Resturants based on "Has_Table_booking"-----

SELECT 
    Has_Table_booking, 
    COUNT(*) AS Total_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Restaurants), 2) AS Percentage
FROM Restaurants
GROUP BY Has_Table_booking;

---- Q8: Percentage of Resturants based on "Has_Online_delivery" ----
select
 Has_Online_delivery, 
    COUNT(*) AS Total_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Restaurants), 2) AS Percentage
FROM Restaurants
GROUP BY Has_Online_delivery;

---- Q9: Charts based on Cusines, City, Ratings  ----
---- A Top10 Cuisines ----
SELECT 
    Cuisines, 
    COUNT(*) AS Restaurant_Count
FROM Restaurants
WHERE Cuisines IS NOT NULL
GROUP BY Cuisines
ORDER BY Restaurant_Count DESC
LIMIT 10;

---- B City wise restaurant Distribution ----
SELECT 
    City, 
    COUNT(*) AS Total_Restaurants
FROM Restaurants
GROUP BY City
ORDER BY Total_Restaurants DESC;

---- C Restaurant Distribution based on ratings ----
SELECT 
    City, 
    ROUND(AVG(rating), 2) AS Avg_Rating,
    COUNT(*) AS Review_Count
FROM Restaurants
GROUP BY City
HAVING Review_Count > 5 
ORDER BY Avg_Rating DESC;





