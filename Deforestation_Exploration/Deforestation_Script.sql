/*
Global Situation
*/
/*
Build a view that joins all three tables that will serve as a single source of truth
*/
CREATE VIEW
forestation AS
SELECT f.country_code, f.country_name, r.region, r.income_group, f.year, f.forest_area_sqkm,
l.total_area_sq_mi, l.total_area_sq_mi*2.59 AS total_area_sq_km,
(f.forest_area_sqkm / (l.total_area_sq_mi*2.59) * 100) AS percent_forest
FROM forest_area f
JOIN land_area l
ON f.country_code = l.country_code
AND f.year = l.year
JOIN regions r
ON l.country_code = r.country_code;
/*
What was the total forest area (in sq km) of the world in 1990?
*/
SELECT *
FROM forestation
WHERE country_name = 'World'
AND year = 1990;
/*
What was the total forest area (in sq km) of the world in 2016?
*/
SELECT *
FROM forestation
WHERE country_name = 'World'
AND year = 2016;
/*
What was the change (in sq km) in the forest area of the world from 1990 to 2016?
*/
SELECT *,
LAG(forest_area_sqkm) OVER (ORDER BY country_name) AS
difference,
LAG(forest_area_sqkm) OVER (ORDER BY country_name) -forest_area_sqkm AS
forestarea_diff_1990_2016
FROM forestation
WHERE country_name = 'World'
AND year = 1990
OR country_name = 'World'
AND year = 2016;
/*
What was the percent change in forest area of the world between 1990 and 2016?
*/
SELECT A.country_name, A.forest_area_sqkm forest_area_1990, B.forest_area_sqkm
forest_area_2016, (B.forest_area_sqkm - A.forest_area_sqkm) forest_difference
FROM forestation A, forestation B
WHERE A.year=1990 AND B.year=2016 AND A.country_name=B.country_name AND
A.country_name='World'
/*
If you compare the amount of forest area lost between 1990 and 2016, to which country's total
area in 2016 is it closest to?
*/
SELECT *
FROM forestation
WHERE year = 2016
AND total_area_sq_km IS NOT NULL
ORDER BY total_area_sq_km DESC;
/*
Regional Outlook
*/
/*
Create a table that groups countries by region and calculates percent of area given to forest
*/
CREATE VIEW
regional_outlook AS
SELECT region, year, SUM(forest_area_sqkm) sum_forest_area, SUM(total_area_sq_km)
sum_total_area,
((SUM(forest_area_sqkm) / SUM(total_area_sq_km)) * 100) AS percent_forest
FROM forestation
WHERE year = 1990 OR year = 2016
GROUP BY region, year
ORDER BY region, year;
/*
What was the percent forest of the entire world in 2016? 31.375 Which region had the
HIGHEST percent forest in 2016 Latin America & Caribbean 46.16 , and which had the
LOWEST Middle East & North Africa 2.068, to 2 decimal places?
*/
SELECT *
FROM regional_outlook
WHERE year = 2016
ORDER BY percent_forest;
/*
What was the percent forest of the entire world in 1990? 32.42 Which region had the HIGHEST
percent forest in 1990 Latin America & Caribbean 51.029, and which had the LOWEST Middle
East & North Africa 1.775, to 2 decimal places?
*/
SELECT *
FROM regional_outlook
WHERE year = 1990
ORDER BY percent_forest;
/*
Based on the table you created, which regions of the world DECREASED in forest area from
1990 to 2016?
*/
SELECT *,
LAG(sum_forest_area) OVER (PARTITION BY region ORDER BY region, year DESC) AS
difference,
LAG(sum_forest_area) OVER (PARTITION BY region ORDER BY region, year DESC) -
sum_forest_area AS forestarea_diff_1990_2016
FROM regional_outlook;
/*
Country-Level Detail
*/
/*
Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What
was the difference in forest area for each?
*/
WITH sub AS (
SELECT country_name, year, forest_area_sqkm
FROM forestation
WHERE year = 1990 OR year = 2016
ORDER BY country_name, year)
SELECT country_name, year, forest_area_sqkm,
LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY
country_name) AS forest_area_1990,
forest_area_sqkm - LAG(forest_area_sqkm) OVER (PARTITION BY country_name
ORDER BY country_name) AS forestarea_diff_1990_2016
FROM sub
ORDER BY forestarea_diff_1990_2016 ASC;
/*
Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What
was the percent change to 2 decimal places for each?
*/
CREATE VIEW
crosstab_forestarea1990 AS
WITH sub AS (
SELECT country_name, year, forest_area_sqkm
FROM forestation
WHERE year = 1990 OR year = 2016
ORDER BY country_name, year)
SELECT country_name, year, forest_area_sqkm,
LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY
country_name) AS forest_area_1990,
forest_area_sqkm - LAG(forest_area_sqkm) OVER (PARTITION BY country_name
ORDER BY country_name) AS forestarea_diff_1990_2016
FROM sub
ORDER BY forestarea_diff_1990_2016 ;
SELECT *,
((forest_area_sqkm - forest_area_1990) / (forest_area_1990) *
100) AS percent_change
FROM crosstab_forestarea1990
WHERE forestarea_diff_1990_2016 IS NOT NULL
ORDER BY percent_change DESC;
/*
If countries were grouped by percent forestation in quartiles, which group had the most
countries in it in 2016?
*/
CREATE VIEW
quartiles AS
SELECT *, CASE
WHEN percent_forest < 25 THEN '1'
WHEN percent_forest >= 25 AND percent_forest < 50 THEN '2'
WHEN percent_forest >= 50 AND percent_forest < 75 THEN '3'
ELSE '4'
END quartiles
FROM (SELECT *
FROM forestation
WHERE year = 2016
AND percent_forest IS NOT NULL) sub;
SELECT quartiles, COUNT(*)
FROM quartiles
GROUP BY quartiles;
/*
List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016
*/
CREATE VIEW
quartiles AS
SELECT *, CASE
WHEN percent_forest < 25 THEN '1'
WHEN percent_forest >= 25 AND percent_forest < 50 THEN '2'
WHEN percent_forest >= 50 AND percent_forest < 75 THEN '3'
ELSE '4'
END quartiles
FROM (SELECT *
FROM forestation
WHERE year = 2016
AND percent_forest IS NOT NULL) sub;
SELECT *
FROM quartiles
WHERE quartiles = '4'
/*
How many countries had a percent forestation higher than the United States in 2016?
*/
SELECT *
FROM forestation
WHERE year = 2016
AND percent_forest >
(SELECT percent_forest
FROM forestation
WHERE country_name = 'United States'
AND year = 2016);
