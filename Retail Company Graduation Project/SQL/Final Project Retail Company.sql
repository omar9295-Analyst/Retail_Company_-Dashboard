#Creating database 
create database Retail_company
use Retail_company;

#cleaning and transformation for calender table

ALTER TABLE `Retail_company`.`Calendar`
ADD Full_Date DATE;

UPDATE `Retail_company`.`Calendar`
SET Full_Date = DATEFROMPARTS(`Year`, `Month`, `Day`);

ALTER TABLE `Retail_company`.`Calendar`
ADD `Quarter` INT,
`Month_Name` VARCHAR(20);

    UPDATE `Retail_company`.`Calendar`
SET `Quarter` = QUARTER( Full_Date),
    `Month_Name` = MONTHNAME( Full_Date);


ALTER TABLE `Retail_company`.`Calendar`
ADD `Day_Name` VARCHAR(15);
 

UPDATE `Retail_company`.`Calendar`
SET `Day_Name` = DAYNAME( Full_Date);


SELECT * 
FROM `Retail_company`.`Calendar`;


ALTER TABLE `Retail_company`.`customers` 
ADD PRIMARY KEY (customer_id);

#cleaning and transformation for Customers table
ALTER TABLE `Retail_company`.`Customers`
ADD Full_Name VARCHAR(100);
UPDATE `Retail_company`.`Customers`
SET Full_Name = CONCAT(first_name, ' ', last_name);

ALTER TABLE `Retail_company`.`Customers`
ADD Age INT;
UPDATE `Retail_company`.`Customers` 
SET Age = TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%m/%d/%Y'), NOW());

ALTER TABLE `Retail_company`.`Customers`
MODIFY COLUMN marital_status VARCHAR(20);
UPDATE `Retail_company`.`Customers`
SET marital_status = CASE 
    WHEN marital_status = 'M' THEN 'Married' 
    WHEN marital_status = 'S' THEN 'Single' 
    ELSE marital_status 
END;


ALTER TABLE `Retail_company`.`Customers`
MODIFY COLUMN gender VARCHAR(15);
UPDATE `Retail_company`.`Customers`
SET gender = CASE 
    WHEN gender = 'F' THEN 'Female' 
    WHEN gender = 'M' THEN 'Male' 
    ELSE gender 
END;


ALTER TABLE `Retail_company`.`Customers`
MODIFY COLUMN homeowner VARCHAR(10);
UPDATE `Retail_company`.`Customers`
SET homeowner = CASE 
    WHEN homeowner = '1' THEN 'Yes' 
    WHEN homeowner = '0' THEN 'No' 
    ELSE homeowner 
END;

SELECT * 
FROM `Retail_company`.`Customers`;

#cleaning and transformation for Products table

ALTER TABLE `Retail_company`.`products` 
ADD PRIMARY KEY (product_id);

ALTER TABLE `Retail_company`.`Products`
MODIFY COLUMN recyclable VARCHAR(5);
UPDATE `Retail_company`.`Products`
SET recyclable = CASE 
    WHEN recyclable = '1' THEN 'Yes' 
    ELSE 'No' 
END;

ALTER TABLE `Retail_company`.`Products`
MODIFY COLUMN low_fat VARCHAR(5);
UPDATE `Retail_company`.`Products`
SET low_fat = CASE 
    WHEN low_fat = '1' THEN 'Yes' 
    ELSE 'No' 
END;

ALTER TABLE `Retail_company`.`Products`
ADD Profit_Per_Unit Double;

UPDATE `Retail_company`.`Products`
SET Profit_Per_Unit = product_retail_price - product_cost;

#cleaning and transformation for Region table

ALTER TABLE `Retail_company`.`Region` 
ADD PRIMARY KEY (region_id);

SELECT * FROM `Retail_company`.`Region`;

#cleaning and transformation for Stores table

ALTER TABLE `Retail_company`.`stores` 
ADD PRIMARY KEY (Store_id);

ALTER TABLE `Retail_company`.`Stores`
ADD Store_Age_Years INT;
UPDATE `Retail_company`.`Stores` 
SET Store_Age_Years = TIMESTAMPDIFF(YEAR, STR_TO_DATE(first_opened_date, '%m/%d/%Y'), NOW());

ALTER TABLE `Retail_company`.`Stores`
ADD Non_Grocery_SqFt INT;
UPDATE `Retail_company`.`Stores`
SET Non_Grocery_SqFt = total_sqft - grocery_sqft;

UPDATE `Retail_company`.`Stores` 
SET first_opened_date = STR_TO_DATE(first_opened_date, '%m/%d/%Y');

UPDATE `Retail_company`.`Stores` 
SET last_remodel_date = STR_TO_DATE(last_remodel_date, '%m/%d/%Y');

ALTER TABLE `Retail_company`.`Stores`
ADD FOREIGN KEY (region_id) REFERENCES `Retail_company`.`Region`(region_id);

#cleaning and transformation for Returns table

ALTER TABLE `Retail_company`.`Returns`
ADD FOREIGN KEY (product_id) REFERENCES `Retail_company`.`Products`(product_id);

ALTER TABLE `Retail_company`.`Returns`
ADD FOREIGN KEY (store_id) REFERENCES `Retail_company`.`Stores`(store_id);

#cleaning and transformation for Sales tables

ALTER TABLE `Retail_company`.`Sales 2017`
ADD FOREIGN KEY (customer_id) REFERENCES `Retail_company`.`Customers`(customer_id);

ALTER TABLE `Retail_company`.`Sales 2017`
ADD FOREIGN KEY (product_id) REFERENCES `Retail_company`.`Products`(product_id);

ALTER TABLE `Retail_company`.`Sales 2017`
ADD FOREIGN KEY (store_id) REFERENCES `Retail_company`.`Stores`(store_id);

ALTER TABLE `Retail_company`.`Sales 2018`
ADD FOREIGN KEY (customer_id) REFERENCES `Retail_company`.`Customers`(customer_id);

ALTER TABLE `Retail_company`.`Sales 2018`
ADD FOREIGN KEY (product_id) REFERENCES `Retail_company`.`Products`(product_id);

ALTER TABLE `Retail_company`.`Sales 2018`
ADD FOREIGN KEY (store_id) REFERENCES `Retail_company`.`Stores`(store_id);

ALTER TABLE `Retail_company`.`Sales 2017`
ADD Sales_ID INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE `Retail_company`.`Sales 2018`
ADD Sales_ID INT AUTO_INCREMENT PRIMARY KEY;

#Creating View (Fact Table)

CREATE VIEW vw_All_Sales AS
SELECT * 
FROM `Retail_company`.`Sales 2017`

UNION ALL

SELECT * 
FROM `Retail_company`.`Sales 2018`;

SELECT * 
FROM vw_All_Sales;

#Bussiness Questions

-- =========================================================================================
-- Q1: ما هو إجمالي الإيرادات، إجمالي التكاليف، وصافي الأرباح الإجمالية للشركة؟
-- الفائدة: تحديد الموقف المالي العام للشركة ومعرفة هل البزنس بيكسب وبحجم كام.
-- =========================================================================================
SELECT 
    ROUND(SUM(s.quantity * p.product_retail_price), 2) AS Total_Revenue,
    ROUND(SUM(s.quantity * p.product_cost), 2) AS Total_Cost,
    ROUND(SUM(s.quantity * (p.product_retail_price - p.product_cost)), 2) AS Total_Net_Profit
FROM (
    SELECT product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT product_id, quantity FROM `Sales 2018`
) s
JOIN Products p ON s.product_id = p.product_id;


-- =========================================================================================
-- Q2: ما هي أعلى 5 علامات تجارية (Brands) تحقيقاً للأرباح؟
-- الفائدة: معرفة البراندات القائدة للمبيعات للتركيز عليها في التعاقدات والتسويق.
-- =========================================================================================
SELECT 
    p.product_brand AS Brand_Name,
    SUM(s.quantity) AS Total_Units_Sold,
    ROUND(SUM(s.quantity * (p.product_retail_price - p.product_cost)), 2) AS Brand_Profit
FROM (
    SELECT product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT product_id, quantity FROM `Sales 2018`
) s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.product_brand
ORDER BY Brand_Profit DESC
LIMIT 5;


-- =========================================================================================
-- Q3: كيف تتوزع الأرباح وحجم المبيعات بناءً على الجنس (Male vs Female)؟
-- الفائدة: تحديد الجمهور المستهدف بدقة ومعرفة هل المنتجات تميل لخدمة الرجال أم النساء لتوجيه الإعلانات.
-- =========================================================================================
SELECT 
    c.gender AS Customer_Gender,
    COUNT(*) AS Total_Transactions,
    SUM(s.quantity) AS Total_Units_Bought,
    ROUND(SUM(s.quantity * (p.product_retail_price - p.product_cost)), 2) AS Total_Profit
FROM (
    SELECT customer_id, product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT customer_id, product_id, quantity FROM `Sales 2018`
) s
JOIN Customers c ON s.customer_id = c.customer_id
JOIN Products p ON s.product_id = p.product_id
GROUP BY c.gender;


-- =========================================================================================
-- Q4: هل العملاء المتزوجون (Married) ينفقون أكثر من العزاب (Single)؟
-- الفائدة: تحليل تأثير الحالة الاجتماعية على السلوك الشرائي لتقديم عروض عائلية مخصصة.
-- =========================================================================================
SELECT 
    c.marital_status AS Marital_Status,
    COUNT(DISTINCT s.customer_id) AS Unique_Customers,
    ROUND(SUM(s.quantity * p.product_retail_price), 2) AS Total_Sales,
    ROUND(AVG(s.quantity * p.product_retail_price), 2) AS Avg_Order_Value
FROM (
    SELECT customer_id, product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT customer_id, product_id, quantity FROM `Sales 2018`
) s
JOIN Customers c ON s.customer_id = c.customer_id
JOIN Products p ON s.product_id = p.product_id
GROUP BY c.marital_status;


-- =========================================================================================
-- Q5: ما هي أفضل 5 مدن (Store Cities) من حيث حجم المبيعات الإجمالية؟
-- الفائدة: رصد المدن الأكثر نجاحاً لفتح فروع جديدة فيها أو دعم الفروع الحالية.
-- =========================================================================================
SELECT 
    st.store_city AS Store_City,
    st.store_state AS Store_State,
    SUM(s.quantity) AS Total_Units_Sold,
    ROUND(SUM(s.quantity * p.product_retail_price), 2) AS Total_Revenue
FROM (
    SELECT store_id, product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT store_id, product_id, quantity FROM `Sales 2018`
) s
JOIN Stores st ON s.store_id = st.store_id
JOIN Products p ON s.product_id = p.product_id
GROUP BY st.store_city, st.store_state
ORDER BY Total_Revenue DESC
LIMIT 5;


-- =========================================================================================
-- Q6: ما هي المنتجات الـ 5 الأكثر إرجاعاً (Highest Returned Products)؟
-- الفائدة: رصد مشاكل الجودة في منتجات معينة لاستبعادها أو مراجعة المورد الخاص بها.
-- =========================================================================================
SELECT 
    p.product_name AS Product_Name,
    p.product_brand AS Brand,
    SUM(r.quantity) AS Total_Returned_Quantity
FROM Returns r
JOIN Products p ON r.product_id = p.product_id
GROUP BY p.product_name, p.product_brand
ORDER BY Total_Returned_Quantity DESC
LIMIT 5;


-- =========================================================================================
-- Q7: مقارنة بين أداء مبيعات عام 2017 وعام 2018 كأرقام إجمالية؟
-- الفائدة: رصد نسبة النمو السنوي للشركة (Year-over-Year Growth) ومعرفة هل المؤشر يتصاعد أم يتراجع.
-- =========================================================================================
SELECT 
    '2017' AS Sales_Year,
    SUM(quantity) AS Total_Units_Sold,
    ROUND(SUM(quantity * product_retail_price), 2) AS Total_Revenue
FROM `Sales 2017` s JOIN Products p ON s.product_id = p.product_id
UNION ALL
SELECT 
    '2018' AS Sales_Year,
    SUM(quantity) AS Total_Units_Sold,
    ROUND(SUM(quantity * product_retail_price), 2) AS Total_Revenue
FROM `Sales 2018` s JOIN Products p ON s.product_id = p.product_id;


-- =========================================================================================
-- Q8: ما هو متوسط عمر المتاجر (Store Age) حالياً وتأثيره على الأرباح؟
-- الفائدة: تحديد ما إذا كانت المتاجر القديمة والراسخة تحقق أرباحاً أعلى من المتاجر الحديثة.
-- =========================================================================================
SELECT 
    st.store_id,
    st.Store_Age_Years,
    ROUND(SUM(s.quantity * (p.product_retail_price - p.product_cost)), 2) AS Total_Store_Profit
FROM (
    SELECT store_id, product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT store_id, product_id, quantity FROM `Sales 2018`
) s
JOIN Stores st ON s.store_id = st.store_id
JOIN Products p ON s.product_id = p.product_id
GROUP BY st.store_id, st.Store_Age_Years
ORDER BY Total_Store_Profit DESC
LIMIT 5;


-- =========================================================================================
-- Q9: هل المنتجات القابلة لإعادة التدوير (Recyclable) تحقق مبيعات أعلى؟
-- الفائدة: فهم وعي المستهلك وتفضيلاته تجاه المنتجات الصديقة للبيئة وتوجيه المسؤولية المجتمعية.
-- =========================================================================================
SELECT 
    p.recyclable AS Is_Recyclable,
    COUNT(*) AS Total_Transactions,
    SUM(s.quantity) AS Total_Units_Sold
FROM (
    SELECT product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT product_id, quantity FROM `Sales 2018`
) s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.recyclable;


-- =========================================================================================
-- Q10: من هم أفضل 5 عملاء (VIP Customers) إنفاقاً في المتجر؟
-- الفائدة: تتبع العملاء الأكثر ولاءً لتقديم مكافآت خاصة بهم وضمان استمراريتهم مع الشركة.
-- =========================================================================================
SELECT 
    c.customer_id,
    c.Full_Name,
    COUNT(*) AS Number_Of_Purchases,
    ROUND(SUM(s.quantity * p.product_retail_price), 2) AS Total_Spent
FROM (
    SELECT customer_id, product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT customer_id, product_id, quantity FROM `Sales 2018`
) s
JOIN Customers c ON s.customer_id = c.customer_id
JOIN Products p ON s.product_id = p.product_id
GROUP BY c.customer_id, c.Full_Name
ORDER BY Total_Spent DESC
LIMIT 5;


-- =========================================================================================
-- Q11: ما هي أكثر فئات الدخل السنوي للعملاء (Yearly Income) شراءً من المتجر؟
-- الفائدة: تحديد القدرة الشرائية للجمهور الأساسي لتسعير المنتجات الجديدة بشكل مناسب.
-- =========================================================================================
SELECT 
    c.yearly_income AS Income_Bracket,
    COUNT(DISTINCT s.customer_id) AS Total_Customers,
    SUM(s.quantity) AS Total_Units_Purchased
FROM (
    SELECT customer_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT customer_id, quantity FROM `Sales 2018`
) s
JOIN Customers c ON s.customer_id = c.customer_id
GROUP BY c.yearly_income
ORDER BY Total_Units_Purchased DESC;


-- =========================================================================================
-- Q12: ما هي العلاقة بين مستوى تعليم العميل (Education) وحجم مشترياته؟
-- الفائدة: عمل دراسة ديموغرافية متقدمة لربط المستويات التعليمية والثقافية بنوع الاستهلاك.
-- =========================================================================================
SELECT 
    c.education AS Education_Level,
    COUNT(*) AS Total_Transactions,
    SUM(s.quantity) AS Total_Units_Sold
FROM (
    SELECT customer_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT customer_id, quantity FROM `Sales 2018`
) s
JOIN Customers c ON s.customer_id = c.customer_id
GROUP BY c.education
ORDER BY Total_Units_Sold DESC;


-- =========================================================================================
-- Q13: ما هو الأداء المالي للمتاجر بناءً على نوع ملكية المنزل للعميل (Homeowner)؟
-- الفائدة: قياس مدى استقرار العميل مادياً (مستأجر ضد مالك) وتأثيره على حجم سلة المشتريات.
-- =========================================================================================
SELECT 
    c.homeowner AS Owns_Home,
    ROUND(SUM(s.quantity * p.product_retail_price), 2) AS Total_Sales,
    ROUND(AVG(s.quantity * p.product_retail_price), 2) AS Avg_Transaction_Value
FROM (
    SELECT customer_id, product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT customer_id, product_id, quantity FROM `Sales 2018`
) s
JOIN Customers c ON s.customer_id = c.customer_id
JOIN Products p ON s.product_id = p.product_id
GROUP BY c.homeowner;


-- =========================================================================================
-- Q14: ما هي أكثر 3 وظائف (Occupations) ينتمي إليها عملائنا؟
-- الفائدة: فهم الخلفية المهنية للعملاء لتقديم خصومات مهنية مستهدفة (مثال: عروض للمهنيين أو العمال).
-- =========================================================================================
SELECT 
    c.occupation AS Customer_Occupation,
    COUNT(DISTINCT s.customer_id) AS Unique_Customers_Count,
    SUM(s.quantity) AS Total_Items_Bought
FROM (
    SELECT customer_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT customer_id, quantity FROM `Sales 2018`
) s
JOIN Customers c ON s.customer_id = c.customer_id
GROUP BY c.occupation
ORDER BY Total_Items_Bought DESC
LIMIT 3;


-- =========================================================================================
-- Q15: ما هو إجمالي المبيعات حسب الأقاليم الجغرافية (Sales Regions)؟
-- الفائدة: مقارنة جغرافية كبرى لتحديد الإقليم الذي يمثل "العمود الفقري" لأرباح الشركة.
-- =========================================================================================
SELECT 
    r.sales_region AS Region_Name,
    COUNT(*) AS Total_Transactions,
    ROUND(SUM(s.quantity * p.product_retail_price), 2) AS Total_Revenue
FROM (
    SELECT store_id, product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT store_id, product_id, quantity FROM `Sales 2018`
) s
JOIN Stores st ON s.store_id = st.store_id
JOIN Region r ON st.region_id = r.region_id
JOIN Products p ON s.product_id = p.product_id
GROUP BY r.sales_region
ORDER BY Total_Revenue DESC;


-- =========================================================================================
-- Q16: ما هي المتاجر الـ 3 الأقل أداءً وتحقيقاً للأرباح (Underperforming Stores)؟
-- الفائدة: لفت انتباه الإدارة للمتاجر المتعثرة لاتخاذ قرارات إصلاحية أو نقل الإدارة أو إغلاقها.
-- =========================================================================================
SELECT 
    st.store_id,
    st.store_city AS Store_City,
    ROUND(SUM(s.quantity * (p.product_retail_price - p.product_cost)), 2) AS Total_Profit
FROM (
    SELECT store_id, product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT store_id, product_id, quantity FROM `Sales 2018`
) s
JOIN Stores st ON s.store_id = st.store_id
JOIN Products p ON s.product_id = p.product_id
GROUP BY st.store_id, st.store_city
ORDER BY Total_Profit ASC
LIMIT 3;


-- =========================================================================================
-- Q17: ما هي نسبة المرتجعات الإجمالية مقارنة بإجمالي المبيعات؟
-- الفائدة: مؤشر جودة عام للبزنس؛ فزيادة النسبة عن 5% تعني وجود هدر وخسائر شحن بسب عيوب المنتجات.
-- =========================================================================================
SELECT 
    (SELECT SUM(quantity) FROM Returns) AS Total_Units_Returned,
    SUM(s.quantity) AS Total_Units_Sold,
    ROUND(((SELECT SUM(quantity) FROM Returns) / SUM(s.quantity)) * 100, 2) AS Global_Return_Rate_Percentage
FROM (
    SELECT quantity FROM `Sales 2017`
    UNION ALL
    SELECT quantity FROM `Sales 2018`
) s;


-- =========================================================================================
-- Q18: هل المساحات غير البقالية الكبيرة (Non_Grocery_SqFt) تزيد من مبيعات المتجر؟
-- الفائدة: دراسة هندسية داخلية للمحلات؛ هل التوسع في الأقسام الجانبية يزيد الأرباح أم نهتم بالبقاليات؟
-- =========================================================================================
SELECT 
    st.store_id,
    st.Non_Grocery_SqFt,
    ROUND(SUM(s.quantity * p.product_retail_price), 2) AS Store_Revenue
FROM (
    SELECT store_id, product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT store_id, product_id, quantity FROM `Sales 2018`
) s
JOIN Stores st ON s.store_id = st.store_id
JOIN Products p ON s.product_id = p.product_id
GROUP BY st.store_id, st.Non_Grocery_SqFt
ORDER BY st.Non_Grocery_SqFt DESC
LIMIT 5;


-- =========================================================================================
-- Q19: ما هو متوسط أعمار العملاء (Average Age) 
-- الفائدة: تحديد الشريحة العمرية المهتمة بالصحة والرشاقة لتوجيه حملات تسويقية خاصة بالمنتجات الصحية لهم.
-- =========================================================================================
SELECT 
    p.low_fat AS Low_Fat_Product,
    ROUND(AVG(c.Age), 1) AS Average_Customer_Age
FROM (
    SELECT customer_id, product_id FROM `Sales 2017`
    UNION ALL
    SELECT customer_id, product_id FROM `Sales 2018`
) s
JOIN Customers c ON s.customer_id = c.customer_id
JOIN Products p ON s.product_id = p.product_id
WHERE p.low_fat = 'Yes'
GROUP BY p.low_fat;


-- =========================================================================================
-- Q20: ما هو أكثر المنتجات مبيعاً على الإطلاق في تاريخ الشركة (The Best Seller)؟
-- الفائدة: معرفة المنتج "النجم" الأكثر طلباً لضمان عدم نفاد مخزونه نهائياً من المستودعات.
-- =========================================================================================
SELECT 
    p.product_id,
    p.product_name AS Top_Product_Name,
    SUM(s.quantity) AS Total_Quantity_Sold,
    ROUND(SUM(s.quantity * p.product_retail_price), 2) AS Generated_Revenue
FROM (
    SELECT product_id, quantity FROM `Sales 2017`
    UNION ALL
    SELECT product_id, quantity FROM `Sales 2018`
) s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY Total_Quantity_Sold DESC
LIMIT 1;