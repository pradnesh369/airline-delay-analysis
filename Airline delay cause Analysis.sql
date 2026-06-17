Drop table Airline_Delay_cause

CREATE TABLE airline_delay_cause (
    year INT,
    month INT,
    carrier_code VARCHAR(10),
    carrier_name VARCHAR(200),
    airport_code VARCHAR(10),
    airport_name VARCHAR(255),
    number_of_arriving_flights NUMERIC(10,2),
    Number_of_flights_delayed NUMERIC(10,2),
    Carrier_count NUMERIC(10,2),
    weather_count NUMERIC(10,2),
    National_Airspace_System_count NUMERIC(10,2),
    Security_count NUMERIC(10,2),
    late_aircraft_count NUMERIC(10,2),
    number_of_flights_canceled NUMERIC(10,2),
    number_of_flights_diverted NUMERIC(10,2),
    total_arrival_delay NUMERIC(10,2),
	carrier_delay NUMERIC(10,2),
	weather_delay NUMERIC(10,2),
	Delay_attributed_to_the_NAS NUMERIC(10,2),
    security_delay NUMERIC(10,2),
	late_aircraft_delay NUMERIC(10,2)
);

-- import the dataset
 copy airline_delay_cause
 from 'D:\Project\Airline_Delay_Cause.csv'
 delimiter ','
 CSV Header; 

 select * from airline_delay_cause

--Check NULL Values
SELECT
    COUNT(*) FILTER (WHERE year IS NULL) AS year_nulls,
    COUNT(*) FILTER (WHERE month IS NULL) AS month_nulls,
    COUNT(*) FILTER (WHERE carrier_name IS NULL) AS carrier_name_nulls,
    COUNT(*) FILTER (WHERE airport_name IS NULL) AS airport_name_nulls,
    COUNT(*) FILTER (WHERE total_arrival_delay IS NULL) AS total_delay_nulls
FROM airline_delay_cause;

--Check Duplicate Rows
SELECT COUNT(*) - COUNT(DISTINCT (
    ROW(
        year,
        month,
        carrier_Code,
        carrier_name,
        airport_code,
        airport_name
    )
)) AS duplicate_rows
FROM airline_delay_cause;

-- Distinct Airlines
SELECT
    COUNT(DISTINCT carrier_name) AS total_airlines
FROM airline_delay_cause;

-- Total Delayed Flights
SELECT
    SUM( number_of_flights_delayed) AS delayed_flights
FROM airline_delay_cause;

-- Delay Percentage
SELECT
    ROUND(
        SUM(number_of_flights_delayed)::NUMERIC
        /
        SUM(number_of_arriving_flights) * 100,
        2
    ) AS delay_percentage
FROM airline_delay_cause;

--Top 10 Airlines with Highest Delay
SELECT
    carrier_name,
    SUM( number_of_flights_delayed_15) AS total_delays
FROM airline_delay_cause
GROUP BY carrier_name
ORDER BY total_delays DESC
LIMIT 10;

-- Top 10 Airports with Highest Delay
SELECT
    airport_name,
    SUM( number_of_flights_delayed) AS total_delays
FROM airline_delay_cause
GROUP BY airport_name
ORDER BY total_delays DESC
LIMIT 10;

-- Monthly Delay Trend
SELECT
month,
SUM(Number_of_flights_delayed) AS Number_of_flights_delayed
FROM airline_delay_cause
GROUP BY month
ORDER BY month;

-- yearly Delay Trend
SELECT
year,
SUM(Number_of_flights_delayed) AS Number_of_flights_delayed
FROM airline_delay_cause
GROUP BY year
ORDER BY year;

-- Cancellation Analysis
SELECT
carrier_name,
SUM(number_of_flights_canceled) AS number_of_flights_canceled
FROM airline_delay_cause
GROUP BY carrier_name
ORDER BY number_of_flights_canceled DESC;

-- Cancellation Rate %
ALTER TABLE airline_delay_cause
ADD COLUMN cancellation_rate NUMERIC (10,2);

UPDATE airline_delay_cause
SET cancellation_rate =
ROUND(
(number_of_flights_canceled / NULLIF(number_of_arriving_flights,0))*100,
2
);

 select * from airline_delay_cause

-- Carrier vs Weather Impact
SELECT
carrier_name,
SUM(carrier_delay) AS carrier_delay,
SUM(weather_delay) AS weather_delay
FROM airline_delay_cause
GROUP BY carrier_name
ORDER BY carrier_delay DESC;

-- Top 10 Busiest Airports
SELECT
airport_name,
SUM(number_of_arriving_flights) AS total_flights
FROM airline_delay_cause
GROUP BY airport_name
ORDER BY total_flights DESC
LIMIT 10;

-- Top Airports by Cancellation Rate
SELECT
    airport_name,
    SUM(number_of_flights_canceled) AS cancelled_flights,
    SUM(number_of_arriving_flights) AS total_flights,
    ROUND(
        SUM(number_of_flights_canceled)::NUMERIC
        /
        SUM(number_of_arriving_flights) * 100,
        2
    ) AS cancellation_rate
FROM airline_delay_cause
GROUP BY airport_name
HAVING SUM(number_of_arriving_flights) > 1000
ORDER BY cancellation_rate DESC
LIMIT 10;

-- Best Performing Airports
SELECT
    airport_name,
    ROUND(
        SUM(number_of_flights_delayed)::NUMERIC
        /
        SUM(number_of_arriving_flights) * 100,
        2
    ) AS delay_rate
FROM airline_delay_cause
GROUP BY airport_name
HAVING SUM(number_of_arriving_flights) > 1000
ORDER BY delay_rate ASC
LIMIT 10;
 
select * from airline_delay_cause

--Delay Rate
ALTER TABLE airline_delay_cause
ADD COLUMN delay_rate NUMERIC(10,2);

UPDATE airline_delay_cause
SET delay_rate =
ROUND(
(number_of_flights_delayed /
NULLIF(number_of_arriving_flights,0)) * 100,
2
);

select * from airline_delay_cause




--Diversion Rate Column
ALTER TABLE airline_delay_cause
ADD COLUMN diversion_rate NUMERIC(10,2);

UPDATE airline_delay_cause
SET diversion_rate =
ROUND(
(number_of_flights_diverted /NULLIF(number_of_arriving_flights,0)) * 100,
2
);

-- Year-over-Year Delay Analysis
--Delay Growth
WITH yearly_delay AS
(
SELECT
year,
SUM(number_of_flights_delayed) AS total_delays
FROM airline_delay_cause
GROUP BY year
)

SELECT
year,
total_delays,

LAG(total_delays) OVER(
ORDER BY year
) AS previous_year_delay,

ROUND(
(
(total_delays -
LAG(total_delays) OVER(ORDER BY year))
*100.0
/
NULLIF(
LAG(total_delays) OVER(ORDER BY year),
0
)
),
2
) AS yoy_delay_growth_pct

FROM yearly_delay
ORDER BY year;

-- Cancellation Growth
WITH yearly_cancel AS
(
SELECT
year,
SUM(number_of_flights_canceled) AS total_cancelled
FROM airline_delay_cause
GROUP BY year
)

SELECT
year,
total_cancelled,

LAG(total_cancelled) OVER(
ORDER BY year
) AS previous_year,

ROUND(
(
(total_cancelled -
LAG(total_cancelled) OVER(ORDER BY year))
*100.0
/
NULLIF(
LAG(total_cancelled) OVER(ORDER BY year),
0
)
),
2
) AS yoy_cancel_growth_pct

FROM yearly_cancel
ORDER BY year;

-- Carrier Performance Score Column
ALTER TABLE airline_delay_cause
ADD COLUMN performance_score NUMERIC(10,2);

UPDATE airline_delay_cause
SET performance_score =
ROUND(
100
- COALESCE(delay_rate,0)
- COALESCE(cancellation_rate,0)
- COALESCE(diversion_rate,0),
2
);

select * from airline_delay_cause

--Rank Airlines By Delay Rate
WITH airline_delay AS (
SELECT
carrier_name,

ROUND(
100.0 * SUM(  Number_of_flights_delayed) /
SUM(number_of_arriving_flights),2
) AS delay_rate

FROM airline_delay_cause

GROUP BY carrier_name
)

SELECT *,
RANK() OVER(
ORDER BY delay_rate DESC
) AS airline_rank
FROM airline_delay;

-- Export the dataset
 copy airline_delay_cause
 To 'D:\Project\Airline_Delay_Cause_analysis.csv'
 delimiter ','
 CSV Header;
