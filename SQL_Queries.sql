-- Walmart Project Queries - mysql

select * from walmart;

-- Count total records
SELECT COUNT(*) FROM walmart;


-- Count payment methods and number of transactions by payment method
select  payment_method, count(* ) from walmart group by payment_method;


-- Count distinct branches
select count(distinct branch) branch from walmart;


-- Find the minimum quantity sold
select max(quantity) from walmart;


-- Find the maximum quantity sold
select min(quantity) from walmart;

-- business problem 
-- Q.1 find different payment method and number of transactions, number of quantity sold
select  payment_method, 
			count(* ) ,
            sum(quantity) 
from walmart 
group by payment_method;


-- Q.2 identify highest rated category in each branch, 
--displaying the branch, category and avg category
select * from
(
select 
		branch,
        category,
        avg(rating) as avg_rating,
        rank () over (partition  by branch order by avg(rating) desc) as rank_w
 from walmart
 group by 1, 2
 ) as ranked_data
 where rank_w = 1;


-- Q3 Identify the busiest day for each branch based on the number of transaction
select * from
(
select
		branch,
        dayname(str_to_date(date,' %d/%m/%y')) as day_name,
        count(*) as no_transactions,
          RANK() OVER (
        PARTITION BY branch 
        ORDER BY COUNT(*) DESC
    ) AS rank_w
from walmart
group by Branch,day_name
) as ranked_data
where rank_w= 1;



-- Q4 calculate total quantity of items sold per payment method. List payment_ method and total_quantity

select  payment_method, 
            sum(quantity) 
from walmart 
group by payment_method;

-- Q5 Determine  the average,minimum  and maximum rating of the products for each city 
-- list the city, average_rating,min_rating and max_rating

select 
		city,
        category,
        min(rating) as min_rating,
        max(rating) as max_rating,
        avg(rating) as avg_rating
 from walmart
 group by city,category;
 
 
 -- Q6 calculate the total profit for each category by considering total_profit as (unit_price + quantity* profit_margin)
 -- list the  category  and total_profits, ordered from highest to lowest profit
 select 
		category,
        sum(total) as total_revenue,
        sum(total* profit_margin) as profit
from walmart
group by category;

-- Q7 Determine the most common payment method for each branch.Display branch and the preferred_payment_method.
-- display branch and the preferred_payment_method
with cte 
as
(
select 
		branch,
        payment_method,
        count(*) as total_trans,
        rank () over (partition by branch order by count(*) desc) as rank_q
from walmart
group by branch,payment_method
) 
select  * from cte 
where rank_q=1;


-- Q.8. categorize sales into 3 group morning,afternoon, evening
-- find out which of the shift and number of invoices 
select 
	branch,
case
		when hour(time)  < 12 then 'morning'
        when hour(time)  between 12 and 17 then 'afternoon'
        else	'evening'
        end as time_of_day,
        count(*)
from walmart
group by time_of_day,Branch
order by Branch, count(*) desc;


-- Q.9 Identify 8 branch  with highest  decrease ration in
--  revenue compare to last year*(current year 2023 and last year 2022)
-- revenue decrease ration=last_rev - current_rev / ls_rev*100
select *,

year(str_to_date(date,' %d/%m/%y')) as formatted_date

from walmart;

-- 2022 sell
with revenue_2022 as 
(	
select 
		branch,
        sum(total) as revenue
from walmart
where year(str_to_date(date,' %d/%m/%y')) =2022
group by 1

) ,
revenue_2023 as 
(	
select 
		branch,
        sum(total) as revenue
from walmart
where year(str_to_date(date,' %d/%m/%y')) =2023
group by 1

) 
select 
		ls.branch,
        ls.revenue as last_year_revenue,
        cs.revenue as curren_year_revenue,
    round( ( (  ls.revenue-cs.revenue) / ls.revenue) *100 ,2)as rev_decr_ratio
from  revenue_2022 as ls 
join revenue_2023 as cs
on ls.branch=cs.branch
where
		ls.revenue > cs.revenue
order by rev_decr_ratio desc
limit 5 ;
