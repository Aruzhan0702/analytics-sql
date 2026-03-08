#список клиентов с непрерывной историей (период с 01.06.2015 по 01.06.2016)
SELECT
  id_client
FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new <  '2016-06-01'
GROUP BY id_client
HAVING COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) = 12;

#количество операций, средний чек, средняя сумма покупок в месяц

SELECT
    t.id_client,
    COUNT(*) AS total_operations,                          -- количество операций
    ROUND(AVG(t.Sum_payment), 2) AS avg_check,             -- средний чек
    ROUND(SUM(t.Sum_payment) / 12, 2) AS avg_monthly_sum   -- средняя сумма покупок в месяц
FROM transactions t
WHERE t.date_new >= '2015-06-01'
  AND t.date_new <  '2016-06-01'
  AND t.id_client IN (
        SELECT id_client
        FROM transactions
        WHERE date_new >= '2015-06-01'
          AND date_new <  '2016-06-01'
        GROUP BY id_client
        HAVING COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) = 12
  )
GROUP BY t.id_client;

#2

#Средняя сумма чека в месяц
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    ROUND(AVG(Sum_payment), 2) AS avg_check_month
FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new <  '2016-06-01'
GROUP BY DATE_FORMAT(date_new, '%Y-%m')
ORDER BY month;

#Среднее количество операций в месяц

SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(*) AS operations_in_month
FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new <  '2016-06-01'
GROUP BY DATE_FORMAT(date_new, '%Y-%m')
ORDER BY month;

#Среднее количество клиентов, совершавших операции

SELECT
    ROUND(COUNT(DISTINCT id_client) / 12, 2) AS avg_clients_per_month
FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new <  '2016-06-01';
  
  #Доля операций от общего количества за год
  SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(*) AS operations_in_month,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM transactions
         WHERE date_new >= '2015-06-01'
           AND date_new <  '2016-06-01'),
    2) AS percent_of_year
FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new <  '2016-06-01'
GROUP BY DATE_FORMAT(date_new, '%Y-%m')
ORDER BY month;

#Доля месяца в общей сумме операций
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    SUM(Sum_payment) AS total_sum_month,
    ROUND(
        SUM(Sum_payment) * 100.0 /
        (SELECT SUM(Sum_payment)
         FROM transactions
         WHERE date_new >= '2015-06-01'
           AND date_new <  '2016-06-01'),
    2) AS percent_of_total_sum
FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new <  '2016-06-01'
GROUP BY DATE_FORMAT(date_new, '%Y-%m')
ORDER BY month;
  
  #% соотношение M / F / NA
  SELECT
    DATE_FORMAT(t.date_new, '%Y-%m') AS month,
    c.Gender,
    COUNT(*) AS operations,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY DATE_FORMAT(t.date_new, '%Y-%m')),
    2) AS percent_operations,
    ROUND(
        SUM(t.Sum_payment) * 100.0 /
        SUM(SUM(t.Sum_payment)) OVER (PARTITION BY DATE_FORMAT(t.date_new, '%Y-%m')),
    2) AS percent_spend
FROM transactions t
JOIN customers c ON t.id_client = c.id_client
WHERE t.date_new >= '2015-06-01'
  AND t.date_new <  '2016-06-01'
GROUP BY month, c.Gender
ORDER BY month, c.Gender;

#3
#Возрастные группы (шаг 10 лет)
SELECT
    CASE
        WHEN c.Age IS NULL THEN 'No Age'
        WHEN c.Age BETWEEN 0  AND 9  THEN '0-9'
        WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS age_group,
    COUNT(*) AS total_operations,
    ROUND(SUM(t.Sum_payment), 2) AS total_sum
FROM transactions t
JOIN customers c ON t.id_client = c.id_client
WHERE t.date_new >= '2015-06-01'
  AND t.date_new <  '2016-06-01'
GROUP BY age_group
ORDER BY age_group;

#Поквартально
SELECT
    QUARTER(t.date_new) AS quarter,
    CASE
        WHEN c.Age IS NULL THEN 'No Age'
        WHEN c.Age BETWEEN 0  AND 9  THEN '0-9'
        WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS age_group,

    COUNT(*) AS operations,
    ROUND(AVG(t.Sum_payment), 2) AS avg_check,
    ROUND(SUM(t.Sum_payment), 2) AS total_sum,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY QUARTER(t.date_new)),
    2) AS percent_operations,

    ROUND(
        SUM(t.Sum_payment) * 100.0 /
        SUM(SUM(t.Sum_payment)) OVER (PARTITION BY QUARTER(t.date_new)),
    2) AS percent_sum

FROM transactions t
JOIN customers c ON t.id_client = c.id_client
WHERE t.date_new >= '2015-06-01'
  AND t.date_new <  '2016-06-01'
GROUP BY quarter, age_group
ORDER BY quarter, age_group;

