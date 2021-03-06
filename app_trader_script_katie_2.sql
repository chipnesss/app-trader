
/* OPTION 2
approach: looks at all apps, regardless of store 
challenges left: we haven't considered where in the life cycle of the app these apps are
deliverables: 
1. Develop some general recommendations as to the price range, genre, content rating, 
or anything else for apps that the company should target
2. Develop a Top 10 List of the apps that App Trader should buy next week for its Black Friday debut.
3. Prepare a 5-10 minute presentation for the leadership team of App Trader*/ 



-- the names cte limits the query results to distinct names once the two tables are combined (there are 16,526)
WITH names AS (SELECT DISTINCT(name)
				FROM play_store_apps
			  	UNION
			   	SELECT DISTINCT(name)
				FROM app_store_apps),
-- the psa_calculations cte normalizes the data type for rating and price and 
-- creates the two new columns:
-- the initial cost for App Trader to purchase the app
-- the expected total life span of the app, based on the app rating
-- all for just the play store apps
psa_calculations AS (
	SELECT name AS name, 
	CAST(rating AS FLOAT) AS ps_rating, 
	CAST(replace(price,'$','')AS FLOAT) AS ps_price,
	CASE WHEN CAST(replace(price,'$','')AS FLOAT) <=1 THEN 10000
		ELSE CAST(replace(price,'$','')AS FLOAT)*10000 END AS ps_initial_cost,
	CASE WHEN rating IS NULL THEN 1
		WHEN rating <.5 THEN 1
		WHEN rating <1 THEN 2
		WHEN rating <1.5 THEN 3
		WHEN rating <2 THEN 4
		WHEN rating <2.5 THEN 5
		WHEN rating <3 THEN 6
		WHEN rating <3.5 THEN 7
		WHEN rating <4 THEN 8
		WHEN rating <4.5 THEN 9
		WHEN rating <5 THEN 10 
		WHEN rating = 5 THEN 11 END AS ps_life_span_yr
	FROM play_store_apps),
-- the asa_calculations cte normalizes the data type for rating and price and 
-- creates the two new columns:
-- the initial cost for App Trader to purchase the app
-- the expected total life span of the app, based on the app rating
-- all for just the app store apps
asa_calculations AS (
	SELECT name AS name, 
	CAST(rating AS FLOAT) AS as_rating, 
	CAST(price AS FLOAT) AS as_price,
	CASE WHEN CAST(price AS FLOAT) <=1 THEN 10000
		ELSE CAST(price AS FLOAT)*10000 END AS as_initial_cost,
	CASE WHEN rating IS NULL THEN 1
		WHEN rating <.5 THEN 1
		WHEN rating <1 THEN 2
		WHEN rating <1.5 THEN 3
		WHEN rating <2 THEN 4
		WHEN rating <2.5 THEN 5
		WHEN rating <3 THEN 6
		WHEN rating <3.5 THEN 7
		WHEN rating <4 THEN 8
		WHEN rating <4.5 THEN 9
		WHEN rating <5 THEN 10 
		WHEN rating = 5 THEN 11 END AS as_life_span_yr
	FROM app_store_apps)
-- the main query brings the two calculation ctes and LEFT JOINS them to the names cte
-- also creates a play_store_app profit column, an app_store_app profit column,
-- a marketing cost column and a total profit column
SELECT DISTINCT(names.name),
psa.ps_price,
psa.ps_initial_cost,
psa.ps_rating,
psa.ps_life_span_yr,
(2500*12*psa.ps_life_span_yr - psa.ps_initial_cost) AS psa_profit,
asa.as_price,
asa.as_initial_cost,
asa.as_rating,
asa.as_life_span_yr,
(2500*12*asa.as_life_span_yr - asa.as_initial_cost) AS asa_profit,
CASE WHEN as_life_span_yr > ps_life_span_yr THEN 1000*12*as_life_span_yr
ELSE 1000*12*ps_life_span_yr END AS marketing_cost,
(2500*12*psa.ps_life_span_yr - psa.ps_initial_cost) + (2500*12*asa.as_life_span_yr - asa.as_initial_cost) - 
(CASE WHEN as_life_span_yr > ps_life_span_yr THEN 1000*12*as_life_span_yr ELSE 1000*12*ps_life_span_yr END) AS total_life_span_profit
FROM names
LEFT JOIN psa_calculations AS psa
USING (name)
LEFT JOIN asa_calculations AS asa
USING (name)
WHERE ((2500*12*psa.ps_life_span_yr - psa.ps_initial_cost) + (2500*12*asa.as_life_span_yr - asa.as_initial_cost) - 
(CASE WHEN as_life_span_yr > ps_life_span_yr THEN 1000*12*as_life_span_yr ELSE 1000*12*ps_life_span_yr END))  IS NOT NULL
ORDER BY total_life_span_profit DESC;