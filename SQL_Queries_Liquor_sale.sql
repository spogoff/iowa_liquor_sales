/*** sample master*/
SELECT *
FROM products
	INNER JOIN sales
	ON products.item_no = sales.item
	INNER JOIN counties
	USING (county)
	INNER JOIN stores
	USING (store)
	LIMIT 1000;

/* SALES SUMMARY STATS*/

SELECT COUNT (item) AS number_of_sales, SUM(total) AS total_revenue,
MAX(total) AS max_sales, MIN(total) AS min_sales, ROUND(AVG(total),2) AS average_sale
FROM sales
WHERE item IS NOT NULL;

SELECT DISTINCT category_name, COUNT(category_name)
FROM products
WHERE category_name IS NOT NULL
GROUP BY category_name;

SELECT DISTINCT vendor_name, COUNT(vendor_name)
FROM products
WHERE vendor_name IS NOT NULL
GROUP BY vendor_name
ORDER BY vendor_name;

/*top sold categories*/

SELECT category_name, SUM(total) as total_sales
FROM sales
GROUP BY category_name
ORDER BY total_sales DESC
LIMIT 5;

/* top vendors by revenue*/

SELECT vendor, COUNT (vendor), SUM(total)
FROM sales
GROUP BY vendor
ORDER BY SUM (total) DESC;

/* top 5 counties by sales*/
SELECT county, SUM(total) AS total_sales
FROM sales
WHERE county IS NOT NULL
GROUP BY county
ORDER BY SUM(total) DESC
LIMIT 5;

/** most profitable products*/
SELECT description, 
	SUM(total) AS total_sales, 
	SUM(state_btl_cost) AS total_cost, 
	ROUND(SUM(total) - SUM (state_btl_cost::decimal)) AS gross_profit,
	COUNT (description) 
FROM sales
GROUP BY description
ORDER BY gross_profit DESC
LIMIT 10;


/*  total sales and store per capita in different counties*/
SELECT county, COUNT(store) AS store_count, SUM(population) AS population, (SUM(store)/population) AS store_per_capita, SUM(total) AS total_sales
FROM counties
LEFT JOIN sales
USING(county)
GROUP BY county
ORDER BY store_per_capita DESC;






/** percentage of top categories in sales*/
SELECT ROUND(AVG(
CASE 
WHEN category_name iLIKE ('%whiskies%') THEN 1
ELSE 0
END),2) * 100 AS whiskies_percentage, 
ROUND(AVG(
CASE 
WHEN category_name iLIKE ('%vodka%') THEN 1
ELSE 0
END),2) * 100 AS vodka_percentage,
ROUND(AVG(
CASE 
WHEN category_name iLIKE ('%rum%') THEN 1
ELSE 0
END),2) * 100 AS rum_percentage,
ROUND(AVG(
CASE 
WHEN category_name iLIKE ('%tequila%') THEN 1
ELSE 0
END),2) * 100 AS tequila_percentage
FROM sales;

/*** sales per month*/

SELECT 
EXTRACT(month from date) AS trunc_date, SUM(total) AS total_sales
FROM sales
WHERE category_name IS NOT NULL
GROUP BY trunc_date
ORDER BY trunc_date;


/*sales for major categories per month*/
SELECT SUM(total_sales), liquor_type, trunc_date
FROM (SELECT 
EXTRACT(month from date) AS trunc_date, SUM(total) AS total_sales,
CASE 
	WHEN category_name iLIKE '%Whiskies%' THEN 'Whiskey, Scotch, Bourbon'
	WHEN category_name iLIKE '%Bourbon%' THEN 'Whiskey, Scotch, Bourbon'
	WHEN category_name iLIKE '%Scotch%' THEN 'Whiskey, Scotch, Bourbon'
	WHEN category_name iLIKE '%Rum%' THEN 'Rum'
	WHEN category_name iLIKE '%Vodka%' THEN 'Vodka'
	WHEN category_name iLIKE '%Tequila%' THEN 'Tequila'
	WHEN category_name iLIKE '%Liqueurs%' THEN 'Cordials and Liqueurs'
	WHEN category_name iLIKE '%Brandies%' THEN 'Cordials and Liqueurs'
	WHEN category_name iLIKE '%Schnapps%' THEN 'Cordials and Liqueurs'
	WHEN category_name iLIKE '%Triple Sec%' THEN 'Cordials and Liqueurs'
	WHEN category_name iLIKE '%Spirits%' THEN 'Spirits'
	WHEN category_name iLIKE '%Gin%' THEN 'Gin'
	WHEN category_name iLIKE '%Beer%' THEN 'Beer' 
	ELSE 'Cocktails'
	END
	AS liquor_type
FROM sales
WHERE category_name IS NOT NULL
GROUP BY trunc_date, liquor_type) AS subquery
GROUP BY trunc_date, liquor_type;
