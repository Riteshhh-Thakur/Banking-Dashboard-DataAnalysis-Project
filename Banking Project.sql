SELECT * FROM bank 

-- The Questions are made by CHAT GPT  

-- Q1) Calculate the number of clients who joined each month in each year
SELECT DISTINCT(EXTRACT(YEAR FROM joined_bank))AS year FROM bank ORDER BY year ASC

SELECT
    EXTRACT(YEAR FROM joined_bank) AS year_joined,
	EXTRACT( MONTH FROM joined_bank) AS month_joined,
    COUNT(*) AS clients_joined
FROM bank
GROUP BY year_joined , 2
ORDER BY year_joined, 2

SELECT
  EXTRACT(YEAR FROM joined_bank)::INT AS year,
  COUNT(*) FILTER (WHERE EXTRACT(MONTH FROM joined_bank) = 1) AS jan,
  COUNT(*) FILTER (WHERE EXTRACT(MONTH FROM joined_bank) = 2) AS feb,
  COUNT(*) FILTER (WHERE EXTRACT(MONTH FROM joined_bank) = 3) AS mar,
  COUNT(*) FILTER (WHERE EXTRACT(MONTH FROM joined_bank) = 4) AS apr,
  COUNT(*) FILTER (WHERE EXTRACT(MONTH FROM joined_bank) = 5) AS may,
  COUNT(*) FILTER (WHERE EXTRACT(MONTH FROM joined_bank) = 6) AS jun,
  COUNT(*) FILTER (WHERE EXTRACT(MONTH FROM joined_bank) = 7) AS jul,
  COUNT(*) FILTER (WHERE EXTRACT(MONTH FROM joined_bank) = 8) AS aug,
  COUNT(*) FILTER (WHERE EXTRACT(MONTH FROM joined_bank) = 9) AS sep,
  COUNT(*) FILTER (WHERE EXTRACT(MONTH FROM joined_bank) = 10) AS oct,
  COUNT(*) FILTER (WHERE EXTRACT(MONTH FROM joined_bank) = 11) AS nov,
  COUNT(*) FILTER (WHERE EXTRACT(MONTH FROM joined_bank) = 12) AS dec,
  COUNT(*) AS total
FROM bank
GROUP BY year
ORDER BY year ASC;


-- Q2) Identify the most common occupation for each nationality.
SELECT DISTINCT(occupation) FROm bank
SELECT DISTINCT(nationality) From bank

WITH occupation_counts AS (
SELECT nationality, occupation, COUNT(*) AS occ_count
FROM bank
GROUP BY nationality, occupation
)
SELECT nationality, occupation, occ_count
FROM 
(   SELECT *,
    ROW_NUMBER() OVER (PARTITION BY nationality ORDER BY occ_count DESC) AS rn
    FROM occupation_counts
)sub
WHERE rn = 1;


-- Q3) Calculate month-over-month growth in new client sign-ups.
SELECT * FROM bank

CREATE TEMP TABLE monthly_signups AS 
  SELECT EXTRACT(YEAR FROM joined_bank ) AS year,
  EXTRACT (MONTH FROM joined_bank ) AS month, 
  COUNT(*) AS signups
  FROM bank
  GROUP BY YEAR, month
  ORDER BY YEAR, month;

SELECT * FROM monthly_signups

SELECT year, month, signups, 
LAG(signups) OVER (PARTITION By year ORDER BY year , month) AS prev_month_signups,
CASE 
    WHEN LAG(signups) OVER (PARTITION BY year ORDER BY month) IS NULL THEN NULL
	ELSE
	    ROUND(((
        signups::numeric - LAG(signups) OVER (PARTITION BY year ORDER BY month)::numeric)
		/ LAG(signups) OVER (ORDER BY month)::numeric
    ) * 100,
    2)
	END AS growth_rate_pct
FROM monthly_signups
ORDER BY year,month;


-- Q4) Calculate rolling 3-month average of new clients joining the bank.
WITH monthly_signups AS (
  SELECT DATE_TRUNC('month', joined_bank) AS month, COUNT(*) AS signups
  FROM bank
  GROUP BY month
)
SELECT
  month,
  signups,
  ROUND(AVG(signups) OVER (
    ORDER BY month
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ), 2) AS rolling_3_month_avg
FROM monthly_signups
ORDER BY month;


-- Q5)	Calculate the percentage contribution of each client’s credit card balance to the total credit card balance.
SELECT SUM(credit_card_balance) AS total_amount FROM bank

SELECT * FROM bank

WITH total_bal AS 
(SELECT SUM(credit_card_balance) AS total_amount FROM bank
)
SELECT b.client_id, b.name, b.credit_card_balance,
ROUND((((b.credit_card_balance / t.total_amount):: numeric)* 100), 2) AS pecrent_of_total_amount
FROM bank AS b , total_bal AS t
ORDER BY pecrent_of_total_amount dESC

--- BY CHAT GPT 
WITH grand_total AS (
-- Step 1: Calculate the total balance across all years
SELECT SUM(credit_card_balance) AS total_amount FROM bank )
SELECT 
-- 1. Get the distinct year
EXTRACT(YEAR FROM joined_bank) AS join_year, 
-- 2. Calculate the year's total balance and its percentage of the grand total
ROUND(
        (    -- Sum of balances for the current year * 100.0
            (SUM(b.credit_card_balance) * 100.0) / 
            
            -- Divided by the Grand Total from the CTE
            (SELECT total_amount FROM grand_total)
        )::NUMERIC,
        2
    ) AS percent_of_grand_total
FROM bank b
GROUP BY join_year -- Group the results by the year
ORDER BY join_year ASC;


-- Q6)	Analyze which month has the highest number of clients joining the bank.
WITH cl AS (
SELECT 
EXTRACT(YEAR FROM joined_bank) AS year,
EXTRACT(MONTH FROM joined_bank) AS month,
COUNT(*) AS monthly_count
FROM BANK
GROUP BY year , month
ORDER BY year, month)
SELECT year, month, monthly_count FROM 
(      SELECT year, month, monthly_count,
       DENSE_RANK () OVER (PARTITION BY year ORDER BY monthly_count DESC) AS rank_num
	   FROM cl
) ranked_cl
WHERE rank_num = 1 
ORDER BY year


-- Q7) Identify dormant clients who joined over 6 years ago but have zero bank deposits.
SELECT * FROM bank
WHERE joined_bank > CURRENT_DATE - INTERVAL '6 years' 
AND 
(bank_deposits = 0 OR bank_deposits IS NULL);


-- Q8)	Calculate customer lifetime value (CLV) as the sum of bank deposits per client.
SELECT client_id, name, SUM(bank_deposits) AS lifetime_value FROM bank
GROUP BY client_id , name 
ORDER BY lifetime_value DESC ;


-- Q9) Calculate the average credit card balance by loyalty classification.
SELECT loyalty_classification ,
ROUND(AVG(credit_card_balance)::int,2)
FROM bank
GROUP BY loyalty_classification


-- Q10) Count how many clients are classified under each loyalty classification.
SELECT loyalty_classification, COUNT(DISTINCT client_id) FROM bank
GROUP BY 1
ORDER BY 2 DESC


-- Q11) List the first 10 customers who signed up.
SELECT * FROM bank
ORDER By joined_bank
LIMIT 10

-- Q12) Count the number of clients per Location ID.
SELECT location_id, COUNT(*) AS cient_counts FROM bank
GROUP BY location_id
ORDER BY 2 DESC

-- Q13) Find the top 5 occupations with the most clients.
SELECT occupation, COUNT(*) AS occupation_count FROM bank
GROUP BY 1
ORDER BY 2 DESC

--Q14) Calculate the total number of credit cards held by all clients.
SELECT client_id, COUNT(*) AS no_of_credit_cards FROM bank
GROUP BY client_id
ORDER by 2 DESC

SELECT COUNT(amount_of_credit_cards)AS total_credt_cards 
FROM bank
WHERE amount_of_credit_cards > 0 

-- Q15) Retrieve all clients who joined the bank in the last 5 years
SELECT * FROM bank
WHERE joined_bank > CURRENT_DATE - INTERVAL'5 years'

-- Q16) Find the total number of unique fee structures.
SELECT DISTINCT(fee_structure) FROM bank

SELECT COUNT(DISTINCT fee_structure) FROM bank

-- Q17) List distinct banking contact methods used by clients.
SELECT DISTINCT(banking_contact) AS types_of_banking_contact FROM bank

-- Q18) Find the average estimated income of all clients.
SELECT 
ROUND(AVG(estimated_income)::integer,2) AS average 
FROM bank



-- Q19) Find the top 5 clients with the highest estimated income.
SELECT client_id, name, estimated_income, 
DENSE_RANK() OVER (ORDER by estimated_income DESC)
FROM bank
LIMIT 5

-- Q20) Calculate the ratio of clients who have credit cards to total clients.
SELECT (
(( SELECT COUNT(*)FROM bank WHERE amount_of_credit_cards > 0)::int)/
((SELECT COUNT(*) from bank)::int)
) 

-- Q21) Find clients who own more than 2 properties.
SELECT client_id, name, properties_owned FROM bank
WHERE properties_owned > 2



-- Q22) Identify the client with the highest superannuation savings.
SELECT client_id , name , superannuation_savings FROM bank
ORDER BY superannuation_savings DESC
LIMIT 1

-- Q23)	Find the average number of checking accounts per client.
SELECT client_id, AVG(checking_accounts) FROM bank
GROUP BY 1

-- Q24)	Find clients who have joined the bank and made transactions in at least 3 different months.
-- Assuming we have transaction data linked by Client ID and Transaction Date
SELECT client_id  
FROM bank
GROUP BY client_id 
HAVING COUNT(DISTINCT DATE_PART('year', joined_bank)) >= 3;

-- Q25)	Find clients who have all types of accounts: Checking, Saving, and Foreign Currency.
SELECT * FROM bank
WHERE checking_accounts <> 0
AND saving_accounts <> 0 
AND foreign_currency_account <> 0 
	
-- Q26)	Find the most common gender of clients joining the bank.
SELECT genderid, COUNT(*) no_of_people FROM bank 
GROUP BY genderid
ORDER BY no_of_people;

-- Q27)	Find the average age difference between clients who have credit cards and those who do not.
SELECT  COUNT(*) FROM bank
WHERE amount_of_credit_cards >0

SELECT
  AVG(CASE WHEN amount_of_credit_cards > 0 THEN age END) AS avg_age_with_cc,
  AVG(CASE WHEN amount_of_credit_cards = 0 THEN age END) AS avg_age_without_cc
FROM bank

-- Q28)	Calculate the percentage of clients who have a business lending account.
SELECT
  ROUND(
    (COUNT(*) FILTER (WHERE business_lending > 0)::numeric /
     COUNT(*)) * 100, 2
  ) AS percentage_of_business_lending_clients
FROM bank;

-- Q29) Get the total number of orders placed in the dataset.
SELECT COUNT(DISTINCT client_id) AS No_of_customers
FROM bank

SELECT COUNT(*) AS total_orders FROM bank;

-- Q30)	Rank clients by their bank deposits using a window function
SELECT client_id, name, bank_deposits, 
DENSE_RANK() OVER (ORDER BY bank_deposits DESC)
FROM bank

