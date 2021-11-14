/*
SQL JOIN
------------------------------------------------------------------------------------------------
HOW TO GET THE SCHEMA OF A DATABASE: 
* Windows/Linux: Ctrl + r
* MacOS: Cmd + r
*/
USE publications; 

-- AS 
# Change the column name qty to Quantity into the sales table
# https://www.w3schools.com/sql/sql_alias.asp
SELECT *, qty as 'Quantity'
FROM sales;

# Assign a new name into the table sales, and call the column order number using the table alias
SELECT s.ord_num
FROM sales AS s;

SELECT ord_num FROM sales;
/* These two above queries gives the same result, but from now on we will work with many tables at the same query 
where these tables most of the cases has the same column name, in this case we have to use the same format from the 
first query using ALIAS to tell SQL the needed column from which table */

-- JOINS
# https://www.w3schools.com/sql/sql_join.asp
-- LEFT JOIN
/* Selects all the columns from the first table (stores) and all the rows from the second table (discounts) that have the same (stor_id)
notice that there is only one common id_stor betrween the two tables which is stor_id = 8042*/
SELECT * 
FROM stores;

SELECT * 
FROM discounts;

SELECT * 
FROM stores s 
LEFT JOIN discounts d ON d.stor_id = s.stor_id;

-- RIGHT JOIN
/* Selects all the columns from the second table (discounts) and all the rows from the first table (stores) that have the same (stor_id)*/

SELECT * 
FROM stores s 
RIGHT JOIN discounts d ON d.stor_id = s.stor_id;

-- INNER JOIN
/* Selects only the common rows that have the same stor_id (in this case) from the two givin tables */
SELECT * 
FROM stores s 
INNER JOIN discounts d ON d.stor_id = s.stor_id;

-- CHALLENGES: 
# In which cities has "Is Anger the Enemy?" been sold?
# HINT: you can add WHERE function after the joins

-- Step 1: we choose the tables 
-- first table is titles
SELECT * FROM titles; # because this table hase the title name we can check as follows:

SELECT *
FROM titles 
WHERE title = "Is Anger the Enemy?";

-- second table is sales
SELECT * FROM sales; # I need this table to move from titles table to stores table by usnig the stor_id column - see the schema

SELECT * FROM stores; # I need it because it has the column city that i am looking for 

-- Step 2: do the join on the 3 tables  + adding the WHERE function 
SELECT *
FROM titles AS t
LEFT JOIN sales AS s ON t.title_id = s.title_id
LEFT JOIN stores AS st ON s.stor_id = st.stor_id
WHERE t.title = "Is Anger the Enemy?";

-- Step 3: select only the requered columns (title and city)
SELECT t.title, st.city 
FROM titles AS t
LEFT JOIN sales AS s ON t.title_id = s.title_id
LEFT JOIN stores AS st ON s.stor_id = st.stor_id
WHERE t.title = "Is Anger the Enemy?";

/* you can use the function DISTINCT just to make sure that the results will be unique and not dublicated */
SELECT DISTINCT( st.city )
FROM titles AS t
LEFT JOIN sales AS s ON t.title_id = s.title_id
LEFT JOIN stores AS st ON s.stor_id = st.stor_id
WHERE t.title = "Is Anger the Enemy?";

# Select all the books (and show their title) where the employee
# Howard Snyder had work.

SELECT t.title, e.fname, e.lname
FROM employee e 
RIGHT JOIN titles t ON e.pub_id = t.pub_id
WHERE e.fname = "Howard" AND e.lname = "Snyder";

## Not necessary: use CONCAT() to reduce the number of columns like this 
SELECT t.title, CONCAT(e.fname, ' ', e.lname) AS employee_name
FROM employee e 
RIGHT JOIN titles t ON e.pub_id = t.pub_id
WHERE e.fname = "Howard" AND e.lname = "Snyder";

# Select all the authors that have work (directly or indirectly)
# with the employee Howard Snyder

SELECT a.au_lname, a.au_fname, e.fname, e.lname
FROM authors a
INNER JOIN titleauthor ta ON a.au_id = ta.au_id
INNER JOIN titles t ON ta.title_id = t.title_id
INNER JOIN publishers p ON t.pub_id = p.pub_id
INNER JOIN employee e ON p.pub_id = e.pub_id
WHERE e.fname = "Howard" AND e.lname = "Snyder";

## USE CONCAT()
SELECT CONCAT(a.au_fname, ' ', a.au_lname) AS author_name, CONCAT(e.fname, ' ', e.lname) AS employee_name
FROM authors a
INNER JOIN titleauthor ta ON a.au_id = ta.au_id
INNER JOIN titles t ON ta.title_id = t.title_id
INNER JOIN publishers p ON t.pub_id = p.pub_id
INNER JOIN employee e ON p.pub_id = e.pub_id
WHERE e.fname = "Howard" AND e.lname = "Snyder";

# Select the book title with higher number of sales (qty)
SELECT s.title_id, t.title, SUM(s.qty) AS qty
FROM sales AS s
RIGHT JOIN titles AS t ON s.title_id = t.title_id
GROUP BY s.title_id, t.title
ORDER BY SUM(s.qty) DESC
LIMIT 1;