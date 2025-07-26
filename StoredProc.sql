---Level D Task

--Step 1: Create Table date_dimension
CREATE TABLE IF NOT EXISTS date_dimension (
    SKDate INT PRIMARY KEY,
    KeyDate DATE,
    Date DATE,
    CalendarDay INT,
    CalendarMonth INT,
    CalendarQuarter INT,
    CalendarYear INT,
    DayNameLong VARCHAR(20),
    DayNameShort VARCHAR(10),
    DayNumberOfWeek INT,
    DayNumberOfYear INT,
    DaySuffix VARCHAR(10),
    FiscalWeek INT,
    FiscalPeriod INT,
    FiscalQuarter VARCHAR(10),
    FiscalYear INT,
    FiscalYearPeriod VARCHAR(20)
);

-- Step 2: Create Stored Procedure
DELIMITER $$

CREATE PROCEDURE PopulateDateDimension(IN input_date DATE)
BEGIN
    DECLARE start_date DATE;
    DECLARE end_date DATE;

    SET start_date = DATE_FORMAT(input_date, '%Y-01-01');
    SET end_date = DATE_FORMAT(input_date, '%Y-12-31');

    WITH RECURSIVE date_cte AS (
        SELECT start_date AS d
        UNION ALL
        SELECT DATE_ADD(d, INTERVAL 1 DAY) FROM date_cte WHERE d < end_date
    )
    INSERT INTO date_dimension (
        SKDate, KeyDate, Date, CalendarDay, CalendarMonth, CalendarQuarter,
        CalendarYear, DayNameLong, DayNameShort, DayNumberOfWeek,
        DayNumberOfYear, DaySuffix, FiscalWeek, FiscalPeriod,
        FiscalQuarter, FiscalYear, FiscalYearPeriod
    )
    SELECT
        DATE_FORMAT(d, '%Y%m%d') + 0 AS SKDate,
        d AS KeyDate,
        d AS Date,
        DAY(d) AS CalendarDay,
        MONTH(d) AS CalendarMonth,
        QUARTER(d) AS CalendarQuarter,
        YEAR(d) AS CalendarYear,
        DAYNAME(d) AS DayNameLong,
        LEFT(DAYNAME(d), 3) AS DayNameShort,
        DAYOFWEEK(d) AS DayNumberOfWeek,
        DAYOFYEAR(d) AS DayNumberOfYear,
        CONCAT(DAY(d),
               CASE
                   WHEN DAY(d) IN (11,12,13) THEN 'th'
                   WHEN DAY(d) % 10 = 1 THEN 'st'
                   WHEN DAY(d) % 10 = 2 THEN 'nd'
                   WHEN DAY(d) % 10 = 3 THEN 'rd'
                   ELSE 'th'
               END) AS DaySuffix,
        WEEK(d, 3) AS FiscalWeek,
        MONTH(d) AS FiscalPeriod,
        QUARTER(d) AS FiscalQuarter,
        YEAR(d) AS FiscalYear,
        CONCAT(YEAR(d), LPAD(MONTH(d), 2, '0')) AS FiscalYearPeriod
    FROM date_cte;

END$$

DELIMITER ;


-- Example Usage:
CALL PopulateDateDimension('2020-07-14');


-- Notes:
--If you want custom fiscal calendar logic, let me know the logic/rules or provide a mapping table.

--Recursive CTE is efficient for a one-year span. For large ranges (e.g., decades), a loop may be better.




