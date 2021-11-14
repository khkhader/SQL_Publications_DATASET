

## Create a database called school
CREATE DATABASE school;

## Delete the database
DROP DATABASE IF EXISTS school;

USE school;

/* Create a table called student that has three columns student_id, name, major */
CREATE TABLE student(
student_id INT,  
name VARCHAR(20),
major VARCHAR(20), 
PRIMARY KEY(student_id)
);

# describe the table
DESCRIBE student;

# Delete the table
DROP TABLE student;

# Add new column to the table sudent and name it as gpa
ALTER TABLE student ADD gpa DECIMAL(3, 2);

# Delete the column gpa from the student table
ALTER TABLE student DROP COLUMN gpa;

# Adding rows/values to the table student
INSERT INTO student VALUES(1, 'Jack', 'Biology'),
					      (2, 'Kate', 'Sociology'),
                          (3, 'Claire', 'English'),
						  (4, 'Jack', 'Biology'),
                          (5, 'Mike', 'Comp.Sci');

-- in case i do not know the major 
INSERT INTO student(student_id, name) VALUES(6, 'Mary');

SELECT * FROM student;

DROP TABLE IF EXISTS student;

-- ---------------------------------------------
# Create the table again by using the NOT NULL and UNIQUE functions
CREATE TABLE student(
student_id INT,  
name VARCHAR(20) NOT NULL,
major VARCHAR(20) UNIQUE, 
PRIMARY KEY(student_id)
);

INSERT INTO student VALUES(1, 'Jack', 'Biology');
INSERT INTO student VALUES(2, NULL, 'Biology'); -- not goint to work because of the constrant NOT NULL
INSERT INTO student VALUES(3, 'Mira', 'Biology'); -- not goint to work because of the cosntrant unique

DROP TABLE IF EXISTS student;

-- ---------------------------------------------
# Create the table again and use the AUTO_INCREMENT on the PRIMARY KEY
CREATE TABLE student(
student_id INT AUTO_INCREMENT,  
name VARCHAR(20),
major VARCHAR(20), 
PRIMARY KEY(student_id)
);

INSERT INTO student(name, major) VALUES('Jack', 'Biology');
INSERT INTO student(name, major) VALUES('Kate', 'Math');

SELECT * FROM student;

DROP TABLE IF EXISTS student;

-- ------------------------------------------------
-- Update and delete

-- UPDATE--
CREATE TABLE student(
student_id INT,  
name VARCHAR(20),
major VARCHAR(20), 
PRIMARY KEY(student_id)
);

INSERT INTO student VALUES(1, 'Jack', 'Biology'),
					      (2, 'Kate', 'Sociology'),
                          (3, 'Claire', 'English'),
						  (4, 'Jack', 'Biology'),
                          (5, 'Mike', 'Comp.Sci');
SELECT * FROM student;

/*TO solve this error: Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column */

SET SQL_SAFE_UPDATES = 0; # use this line but after you did the update run the second following line to go back to the safe mode
SET SQL_SAFE_UPDATES = 1;

## change biology to bio use WHERE to define at which row you want to change otherwise it will change all the major values to Bio
UPDATE student 
SET major = 'Bio'
WHERE major = 'Biology';

SELECT * FROM student;

## change comp. Sci to Computer Science
UPDATE student
SET major = 'Computer Science'
WHERE major = 'Comp.Sci';

## change the major of Jack to math 
UPDATE student
SET major = 'math'
WHERE student_id = 4;

-- DELETE--

DELETE FROM student
WHERE student_id = 5;

DELETE FROM student
WHERE name = 'Jack' AND student_id = 1;

DROP TABLE IF EXISTS student;

-- -----------------------------------------------------------------
-- Modify used to change the data type  of a column 

CREATE TABLE student(
student_id INT,  
name VARCHAR(20),
major VARCHAR(20), 
PRIMARY KEY(student_id)
);

## use describe to see the datatype of the columns
DESCRIBE student;

## change the datatype on the column name from CHAR(30)
ALTER TABLE student
MODIFY COLUMN name CHAR(30);

DESCRIBE student;

DROP TABLE IF EXISTS student;








