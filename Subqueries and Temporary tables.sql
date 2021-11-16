## Apply subqueries ##

############################################################################
############################################################################
USE publications; 

-- Basic subqueries
-- Most of the time, used inside a WHERE, as an alternative to JOINS

-- We want a list of all the titles published by American publishers
-- these are the American publishers:
select * from publishers
where country = "USA";

-- get titles from books published in USA
-- Join
select t.title
from titles t
left join publishers p on t.pub_id = p.pub_id
where p.country = "USA";

-- we can grab the pub_id's and "pass it" to a broader query
select title from titles 
where pub_id IN (
	select pub_id from publishers
	where country = "USA"
); 


-- temporary table
drop table if exists titles_publishers;
create temporary table titles_publishers 
	select t.title, p.* from titles t
	left join publishers p on t.pub_id = p.pub_id
	where p.country = "USA";

select * from titles_publishers where state = 'DC';


-- CHALLENGE: WE WILL FIND OUT THE TOP 3 MOST PROFITING AUTHORS

-- Step 0: how are "profits" defined in the databasee?

-- authors get a fixed amount called "advance" for each title they publish
select title, advance from titles; 

-- joining titles with authors, we get the advance each author got:
select 
	t.title_id, 
    t.title, 
    a.au_fname, 
    a.au_lname, 
    t.advance
from titles t
left join titleauthor ta on t.title_id = ta.title_id
left join authors a on ta.au_id = a.au_id;

-- but as you see with 'Cooking with Computers..." a title can be published by several authors. 
-- how do Michael and Steearns split the 5000 dollars advance?
-- the answer is in the column "royaltyper" fromo the titleauthor table

select 
	t.title_id, 
    t.title, 
    a.au_fname, 
    a.au_lname, 
    t.advance, 
    ta.royaltyper
from titles t
left join titleauthor ta on t.title_id = ta.title_id
left join authors a on ta.au_id = a.au_id;

-- it looks like Michael gets 40% of that money and Stearns 60%
-- let's bring this to a column

select 
	t.title_id, 
    t.title, 
    a.au_fname, 
    a.au_lname, 
    t.advance, 
    ta.royaltyper,
    ROUND((t.advance * (ta.royaltyper / 100)), 2) as advance_au
from titles t
left join titleauthor ta on t.title_id = ta.title_id
left join authors a on ta.au_id = a.au_id;


-- the other side of profits are actual royalties: 
-- a percentage of the price that goes to the authors for each sale
-- that percentage can vary from title to title. it's stored in titles.royalty
-- the sales are in the sales table as "qty"
-- and, again, for titles with multiple authors, they split the money following "royaltyper"

select 
	t.title_id, 
    ta.au_id, 
    a.au_fname, 
    t.price, 
    s.qty, 
    t.royalty, 
    ta.royaltyper,
    ROUND(
		(t.price *s.qty *t.royalty / 100 * ta.royaltyper / 100)
		, 2) as sales_royalty
from 
	sales s
    left join titles t on s.title_id = t.title_id
    left join titleauthor ta on t.title_id = ta.title_id
    left join authors a on ta.au_id = a.au_id; 

-- As you can seee, some authors like Anne have published several books.
-- the profit for each author will be calculated as the sum of
-- advance + royalty
-- grouped by author

-- When queries are that long and complex, we use subqueries & temporary tables.
-- Sometimes subqueries are a must
-- Other times they just allow us to break a huge query into simpler steeps

-- Step 1: Calculate the royalty of each sale for each author
--  and the advance for each author and publication
-- 

drop table if exists royalties_per_sale; 
create temporary table royalties_per_sale 
	select 
		t.title_id, 
		ta.au_id, 
		a.au_fname, 
		a.au_lname, 
        ROUND((t.advance * (ta.royaltyper / 100)), 2) as advance,
		ROUND(
			(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100)
			, 2) as sales_royalty
	from 
		sales s
		left join titles t on s.title_id = t.title_id
		left join titleauthor ta on t.title_id = ta.title_id
		left join authors a on ta.au_id = a.au_id; 

select * from royalties_per_sale;

-- Step 2: Aggregate the total royalties for each title and author
drop table if exists roy_adv_per_title_author; 
create temporary table roy_adv_per_title_author
	select 
		title_id, 
        au_id, 
        au_fname, 
        au_lname, 
        sum(sales_royalty) as total_roy, 
        round(sum(advance)) as advance 
    from royalties_per_sale
    group by title_id, au_id, au_fname, au_lname; 

select * from roy_adv_per_title_author;

-- Step 3: Calculate the total profits of each author and order by profit

select 
	au_id, 
    au_fname, 
    au_lname, 
    sum(total_roy + advance) as total_profit_author
from 
	roy_adv_per_title_author
group by
	au_id, au_fname, au_lname
order by total_profit_author desc
limit 3;


-- try subqueries instead:

select 
	s2.au_id, 
    s2.au_fname, 
    s2.au_lname, 
    sum(s2.total_roy + s2.advance) as total_profit_author
from (
	select 
		s1.title_id, 
        s1.au_id, 
        s1.au_fname, 
        s1.au_lname, 
        sum(s1.sales_royalty) as total_roy, 
        round(sum(s1.advance)) as advance 
    from (
		select 
			t.title_id, 
			ta.au_id, 
			a.au_fname, 
			a.au_lname, 
			ROUND((t.advance * (ta.royaltyper / 100)), 2) as advance,
			ROUND((t.price *s.qty *t.royalty / 100 * ta.royaltyper / 100),
					2) as sales_royalty
		from sales s
		left join titles t on s.title_id = t.title_id
		left join titleauthor ta on t.title_id = ta.title_id
		left join authors a on ta.au_id = a.au_id
    ) s1
    group by s1.title_id, s1.au_id, s1.au_fname, s1.au_lname
) s2
group by s2.au_id, s2.au_fname, s2.au_lname
order by total_profit_author desc
limit 3;




## check if a temporarly table exists

DELIMITER //
CREATE PROCEDURE check_table_exists(table_name VARCHAR(100)) 
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLSTATE '42S02' SET @err = 1;
    SET @err = 0;
    SET @table_name = table_name;
    SET @sql_query = CONCAT('SELECT 1 FROM ',@table_name);
    PREPARE stmt1 FROM @sql_query;
    IF (@err = 1) THEN
        SET @table_exists = 0;
    ELSE
        SET @table_exists = 1;
        DEALLOCATE PREPARE stmt1;
    END IF;
END //
DELIMITER ;

# call the function to see if the table exists, if it gives 1 then exixt if it gives 0 then not exist
CALL check_table_exists('roy_adv_per_title_author');
SELECT @table_exists;


