CREATE DATABASE sales_trends1;
USE sales_trends1;

CREATE TABLE learners(
    learner_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    country VARCHAR(50)
);

CREATE TABLE courses(
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

CREATE TABLE purchases(
    purchase_id INT PRIMARY KEY,
    learner_id INT,
    course_id INT,
    quantity INT,
    purchase_date DATE,
    FOREIGN KEY (learner_id) REFERENCES learners(learner_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO learners VALUES
(1,'Rishan','India'),
(2,'Priya','India'),
(3,'Jas','USA'),
(4,'Subha','UK'),
(5,'Anshi','UAE');

INSERT INTO courses VALUES
(101,'Python','Programming',5000),
(102,'SQL','Database',4000),
(103,'Power BI','Analytics',6000),
(104,'Excel','Analytics',3000),
(105,'Java','Programming',7000);

INSERT INTO purchases VALUES
(1,1,101,2,'2026-03-01'),
(2,2,102,1,'2026-03-02'),
(3,3,103,2,'2026-03-03'),
(4,4,104,3,'2026-03-04'),
(5,5,105,1,'2026-03-05'),
(6,1,103,1,'2026-03-06'),
(7,2,104,2,'2026-03-07'),
(8,3,101,1,'2026-03-08');

SELECT * FROM learners;
SELECT * FROM courses;
SELECT * FROM purchases;
SELECT
    l.learner_id,
    l.full_name,
    SUM(p.quantity * c.unit_price) AS Total_Spending
FROM learners l
JOIN purchases p
    ON l.learner_id = p.learner_id
JOIN courses c
    ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name
ORDER BY Total_Spending DESC;

SELECT
    l.full_name AS Learner_Name,
    c.course_name AS Course_Name,
    c.category,
    p.quantity,
    (p.quantity * c.unit_price) AS Total_Amount,
    p.purchase_date
FROM purchases p
INNER JOIN learners l
    ON p.learner_id = l.learner_id
INNER JOIN courses c
    ON p.course_id = c.course_id
ORDER BY Total_Amount DESC;


SELECT
l.full_name,
    c.course_name,
    p.quantity,
    p.purchase_date
FROM learners l
LEFT JOIN purchases p
    ON l.learner_id = p.learner_id
LEFT JOIN courses c
    ON p.course_id = c.course_id;


SELECT
    l.full_name AS Learner_Name,
    c.course_name AS Course_Name,
    p.quantity,
    p.purchase_date
FROM learners l
RIGHT JOIN purchases p
    ON l.learner_id = p.learner_id
RIGHT JOIN courses c
    ON p.course_id = c.course_id;


SELECT
    c.course_name,
    SUM(p.quantity) AS Total_Quantity
FROM courses c
JOIN purchases p
    ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name
ORDER BY Total_Quantity DESC
LIMIT 3;


SELECT
    c.category,
    SUM(p.quantity * c.unit_price) AS Total_Revenue,
    COUNT(DISTINCT p.learner_id) AS Unique_Learners
FROM purchases p
JOIN courses c
    ON p.course_id = c.course_id
GROUP BY c.category;


SELECT
    l.full_name,
    COUNT(DISTINCT c.category) AS Category_Count
FROM learners l
JOIN purchases p
    ON l.learner_id = p.learner_id
JOIN courses c
    ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name
HAVING COUNT(DISTINCT c.category) > 1;


SELECT
    c.course_name
FROM courses c
LEFT JOIN purchases p
    ON c.course_id = p.course_id
WHERE p.course_id IS NULL;
SELECT
    l.full_name,
    SUM(p.quantity * c.unit_price) AS Total_Spending
FROM learners l
JOIN purchases p
    ON l.learner_id = p.learner_id
JOIN courses c
    ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name
HAVING SUM(p.quantity * c.unit_price) >
(
    SELECT AVG(total_spending)
    FROM
    (
        SELECT
            SUM(p2.quantity * c2.unit_price) AS total_spending
        FROM purchases p2
        JOIN courses c2
            ON p2.course_id = c2.course_id
        GROUP BY p2.learner_id
    ) AS avg_table
);

SELECT *
FROM courses
WHERE unit_price >
(
    SELECT MAX(unit_price)
    FROM courses
    WHERE category = 'Beginner'
);

-- Q11: Learners Spending Above Country Average
SELECT
    l.full_name,
    l.country,
    SUM(p.quantity * c.unit_price) AS Total_Spending
FROM learners l
JOIN purchases p
    ON l.learner_id = p.learner_id
JOIN courses c
    ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name, l.country
HAVING SUM(p.quantity * c.unit_price) >
(
    SELECT AVG(country_total)
    FROM
    (
        SELECT
            SUM(p2.quantity * c2.unit_price) AS country_total
        FROM learners l2
        JOIN purchases p2
            ON l2.learner_id = p2.learner_id
        JOIN courses c2
            ON p2.course_id = c2.course_id
        WHERE l2.country = l.country
        GROUP BY l2.learner_id
    ) AS country_avg
);

WITH learner_spending AS
(
    SELECT
        l.learner_id,
        l.full_name,
        SUM(p.quantity * c.unit_price) AS Total_Spending
    FROM learners l
    JOIN purchases p
        ON l.learner_id = p.learner_id
    JOIN courses c
        ON p.course_id = c.course_id
    GROUP BY l.learner_id, l.full_name
)
SELECT *
FROM learner_spending
WHERE Total_Spending > 10000;

-- Q13: CASE Statement
SELECT
    l.full_name,
    SUM(p.quantity * c.unit_price) AS Total_Spending,
    CASE
        WHEN SUM(p.quantity * c.unit_price) > 15000 THEN 'High Value'
        WHEN SUM(p.quantity * c.unit_price) BETWEEN 8000 AND 15000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Customer_Type
FROM learners l
JOIN purchases p
    ON l.learner_id = p.learner_id
JOIN courses c
    ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name;

SELECT
    c.course_name,
    IFNULL(SUM(p.quantity),0) AS Purchase_Count
FROM courses c
LEFT JOIN purchases p
    ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name;
CREATE VIEW category_performance_view AS
SELECT
    c.category,
    SUM(p.quantity * c.unit_price) AS Total_Revenue,
    COUNT(p.purchase_id) AS Number_of_Purchases,
    AVG(p.quantity * c.unit_price) AS Average_Revenue
FROM purchases p
JOIN courses c
    ON p.course_id = c.course_id
GROUP BY c.category;

SELECT * FROM category_performance_view;