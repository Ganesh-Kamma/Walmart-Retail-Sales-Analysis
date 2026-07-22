create database walmart;
use walmart;
select * from walmartsales;  

/*Business Questions to answer:*/
-- 1.	How many unique cities does the data have?
SELECT DISTINCT City FROM walmartsales;

-- 2.	In which city is each branch?
SELECT DISTINCT City,Branch FROM walmartsales;

/*Product related Questions:*/
-- 3. How many unique product lines does the data have?
SELECT DISTINCT `Product line` FROM walmartsales;

-- 4. What is the most common payment method?
SELECT DISTINCT Payment,COUNT(Payment) AS cnt FROM walmartsales GROUP BY Payment ORDER BY cnt DESC;

-- 5.	What is the most selling product line?
SELECT DISTINCT `Product line`,COUNT(`Product line`) as cnt FROM walmartsales GROUP BY `Product line` ORDER BY cnt DESC;

-- 6. What is the total revenue by month?
SELECT MONTHNAME(Date) as month_name,ROUND(SUM(Total),2) AS total_revenue FROM walmartsales 
GROUP BY month_name ORDER BY total_revenue DESC;

-- 7. What month had the largest COGS?
SELECT MONTHNAME(Date) AS month_name,ROUND(SUM(cogs),2) as total_cogs FROM walmartsales GROUP BY month_name ORDER BY total_cogs DESC LIMIT 1;

-- 8.	What product line had the largest revenue?
SELECT `Product line`,ROUND(SUM(Total),2) AS total_revenue FROM walmartsales GROUP BY `Product line` ORDER BY total_revenue DESC LIMIT 1; 

-- 9.	What is the city with the largest revenue?
SELECT City,ROUND(SUM(Total),2) AS total_revenue FROM walmartsales GROUP BY City ORDER BY total_revenue DESC LIMIT 1;

-- 10.	What product line had the largest VAT (Value Added Tax)?
SELECT `Product line`,ROUND(SUM(`Tax 5%`),2) AS vat FROM walmartsales GROUP BY `Product line` ORDER BY vat DESC LIMIT 1;

-- 11.	Fetch each product line and add a column to those product line showing “Good”, “Bad”. Good if its greater than average sales.
WITH product_sales AS (SELECT `Product line`, ROUND(SUM(`Unit price`*Quantity),2) AS sales
FROM walmartsales GROUP BY `Product line`)
SELECT `Product line`,sales,
CASE WHEN sales>(SELECT AVG(sales) FROM product_sales) 
THEN 'Good' ELSE 'Bad' END AS Remarks FROM product_sales;

-- 12.	Which branch sold more products than average product sold?
WITH branch_sales AS (SELECT Branch,SUM(Quantity) AS total_product_sold FROM walmartsales GROUP BY Branch)
SELECT Branch,total_product_sold FROM branch_sales 
WHERE total_product_sold > (SELECT AVG(total_product_sold) FROM branch_sales);

-- 13. What is the most common product line by gender?
WITH product_line_gender AS (
SELECT Gender,`Product line`, COUNT(*) AS total_cnt,ROW_NUMBER() OVER (PARTITION BY Gender ORDER BY COUNT(*) DESC) AS rn 
FROM walmartsales GROUP BY Gender,`Product line`)
SELECT Gender,`Product line`,total_cnt FROM product_line_gender WHERE rn IN (1,2);

-- 14.	What is the average rating of each product line?
SELECT `Product line`,ROUND(AVG(Rating),2) AS avg_rating_product_line FROM walmartsales GROUP BY `Product line`;

/*Sales related Questions:*/
-- 15. Number of sales made in each time of the day per weekday.
SELECT Distinct Date,WEEK(Date) AS week_number,WEEKDAY(Date) AS week_day,DAY(Date) AS day_number,DAYNAME(Date) AS day_name 
FROM walmartsales ORDER BY Date ASC;
SELECT DAYNAME(Date) AS Day_Name,
	CASE WHEN TIME(Time) BETWEEN '3:00:00' AND '11:59:59' THEN 'Morning'
	WHEN TIME(Time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
    WHEN TIME(Time) BETWEEN '18:00:00' AND '22:00:00' THEN 'Evening'
	ELSE 'Midnight' END AS Time_of_Day, COUNT(*) AS no_of_sales 
FROM walmartsales GROUP BY Day_Name,Time_of_Day ORDER BY Day_Name,Time_of_Day;

-- 16.	Which of the customer types brings the most revenue?
SELECT `Customer type`,ROUND(SUM(Total),2)AS total_revenue FROM walmartsales GROUP BY `Customer type` ORDER BY total_revenue DESC;

-- 17.	Which city has the largest tax percent / VAT (Value Added Tax)?
SELECT City,ROUND(SUM(`tax 5%`),2) AS vat FROM walmartsales GROUP BY City ORDER BY vat DESC;

-- 18.	Which customer type pays the most in VAT?
SELECT `Customer type`,ROUND(SUM(`tAX 5%`),2) AS vat FROM walmartsales GROUP BY `Customer type` ORDER BY vat; 

/*Customer related Questions:*/
-- 19. How many unique customer types does the data have?
SELECT COUNT(DISTINCT `Customer type`) AS count_customer_type FROM walmartsales;

-- 20.	How many unique payment methods does the data have?
SELECT COUNT(DISTINCT Payment) AS payment_count FROM walmartsales;

-- 21.	What is the most common customer type?
SELECT DISTINCT `Customer type`,COUNT(*) AS customer_type_count 
FROM walmartsales GROUP BY `Customer type` ORDER BY customer_type_count DESC;

-- 22. Which customer type buys the most?
SELECT `Customer type`,SUM(Quantity) AS max_quantity FROM walmartsales GROUP BY `Customer type` ORDER BY max_quantity DESC;

-- 23. What is the gender of most of the customers?
SELECT Gender,COUNT(*) AS gender_cnt FROM walmartsales GROUP BY Gender ORDER BY gender_cnt DESC;

-- 24.	What is the gender distribution per branch?
SELECT DISTINCT Gender,Branch,COUNT(*) AS gender_branch_cnt FROM walmartsales GROUP BY Gender,Branch ORDER BY Branch;

-- 25.	Which time of the day do customers give most ratings?
SELECT CASE WHEN TIME(Time) BETWEEN '3:00:00' AND '11:59:59' THEN 'Morning'
	WHEN TIME(Time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
    WHEN TIME(Time) BETWEEN '18:00:00' AND '22:00:00' THEN 'Evening'
	ELSE 'Midnight' END AS Time_of_Day, COUNT(Rating) AS rating_cnt 
    FROM walmartsales GROUP BY Time_of_Day ORDER BY rating_cnt DESC;

-- 26.	Which time of the data do customers give most ratings per branch?
SELECT CASE WHEN TIME(Time) BETWEEN '3:00:00' AND '11:59:59' THEN 'Morning'
	WHEN TIME(Time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
    WHEN TIME(Time) BETWEEN '18:00:00' AND '22:00:00' THEN 'Evening'
	ELSE 'Midnight' END AS Time_of_Day, Branch,COUNT(Rating) AS rating_cnt 
    FROM walmartsales GROUP BY Time_of_Day,Branch ORDER BY rating_cnt DESC;

-- 27.	Which day of the week has the best average ratings?
SELECT DAYNAME(Date) AS day_name,ROUND(AVG(Rating),2) AS avg_rating FROM walmartsales GROUP BY day_name ORDER BY avg_rating DESC;

-- 28.	Which day of the week has the best average ratings per branch?
WITH day_week AS
(SELECT DAYNAME(Date) AS day_name,Branch,ROW_NUMBER() OVER (PARTITION BY Branch) AS branch_rating,ROUND(AVG(Rating),2) AS avg_rating 
FROM walmartsales GROUP BY day_name,Branch ORDER BY Branch,avg_rating DESC)
SELECT day_name,Branch,avg_rating
FROM day_week WHERE branch_rating=1 GROUP BY Branch,day_name ORDER BY avg_rating DESC; 

