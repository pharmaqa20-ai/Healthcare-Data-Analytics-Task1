-- Task 3: Pharmacy Sales & Drug Analysis
USE pharmacy_sales;

-- Objective 1: top-selling products by quantity
SELECT p.KD_OBAT AS medicine_code, p.NAMA AS medicine_name,
       SUM(d.QTY) AS total_quantity_sold,
       SUM(d.QTY*d.HJ) AS estimated_sales_value
FROM det_sales d JOIN ms_product p ON d.KD_OBAT=p.KD_OBAT
WHERE p.NAMA IS NOT NULL AND TRIM(p.NAMA)<>''
GROUP BY p.KD_OBAT,p.NAMA
ORDER BY total_quantity_sold DESC LIMIT 30;

-- Objective 2: monthly sales and month-over-month growth
WITH monthly AS (
 SELECT DATE_FORMAT(s.TGL,'%Y-%m') AS sales_month,
        SUM(d.QTY*d.HJ) AS monthly_sales
 FROM det_sales d JOIN ms_sales s ON d.NO_RESEP=s.NO_RESEP
 WHERE s.TGL IS NOT NULL
 GROUP BY DATE_FORMAT(s.TGL,'%Y-%m')
), prev AS (
 SELECT sales_month, monthly_sales,
 LAG(monthly_sales) OVER(ORDER BY sales_month) AS previous_month_sales
 FROM monthly
)
SELECT sales_month,ROUND(monthly_sales,2) AS monthly_sales,
 ROUND(previous_month_sales,2) AS previous_month_sales,
 ROUND((monthly_sales-previous_month_sales)/NULLIF(previous_month_sales,0)*100,2) AS growth_percentage
FROM prev ORDER BY sales_month;

-- Objective 3 requires an externally verified brand/generic classification
-- keyed by medicine code before comparing groups. No category is invented here.
