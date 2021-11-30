/*
Lab 1 report Carl Terve carte495, Mattias Erlingsson mater915>
*/


/*
Drop all user created tables that have been created when solving the lab
*/

DROP TABLE IF EXISTS custom_table CASCADE;
DROP TABLE IF EXISTS newjbitems;
DROP VIEW IF EXISTS jbitemview;
DROP VIEW IF EXISTS totdebitcost;
DROP VIEW IF EXISTS totdebitcost_join;
DROP VIEW IF EXISTS jbsale_supply;


/* Have the source scripts in the file so it is easy to recreate!*/

SOURCE company_schema.sql;
SOURCE company_data.sql;

/*
Question 1: Print a message that says "hello world"
*/

SELECT 'hello world!' AS 'message';

/* Show the output for every question.
+--------------+
| message      |
+--------------+
| hello world! |
+--------------+
1 row in set (0.00 sec)
*/ 
/*Question 1*/
SELECT name FROM jbemployee;
/*+--------------------+
| name               |
+--------------------+
| Ross, Stanley      |
| Ross, Stuart       |
| Edwards, Peter     |
| Thompson, Bob      |
| Smythe, Carol      |
| Hayes, Evelyn      |
| Evans, Michael     |
| Raveen, Lemont     |
| James, Mary        |
| Williams, Judy     |
| Thomas, Tom        |
| Jones, Tim         |
| Bullock, J.D.      |
| Collins, Joanne    |
| Brunet, Paul C.    |
| Schmidt, Herman    |
| Iwano, Masahiro    |
| Smith, Paul        |
| Onstad, Richard    |
| Zugnoni, Arthur A. |
| Choy, Wanda        |
| Wallace, Maggie J. |
| Bailey, Chas M.    |
| Bono, Sonny        |
| Schwarz, Jason B.  |
+--------------------+
25 rows in set (0.02 sec)*/
/*Alternativly:
mysql> SELECT * FROM jbemployee;
+------+--------------------+--------+---------+-----------+-----------+
| id   | name               | salary | manager | birthyear | startyear |
+------+--------------------+--------+---------+-----------+-----------+
|   10 | Ross, Stanley      |  15908 |     199 |      1927 |      1945 |
|   11 | Ross, Stuart       |  12067 |    NULL |      1931 |      1932 |
|   13 | Edwards, Peter     |   9000 |     199 |      1928 |      1958 |
|   26 | Thompson, Bob      |  13000 |     199 |      1930 |      1970 |
|   32 | Smythe, Carol      |   9050 |     199 |      1929 |      1967 |
|   33 | Hayes, Evelyn      |  10100 |     199 |      1931 |      1963 |
|   35 | Evans, Michael     |   5000 |      32 |      1952 |      1974 |
|   37 | Raveen, Lemont     |  11985 |      26 |      1950 |      1974 |
|   55 | James, Mary        |  12000 |     199 |      1920 |      1969 |
|   98 | Williams, Judy     |   9000 |     199 |      1935 |      1969 |
|  129 | Thomas, Tom        |  10000 |     199 |      1941 |      1962 |
|  157 | Jones, Tim         |  12000 |     199 |      1940 |      1960 |
|  199 | Bullock, J.D.      |  27000 |    NULL |      1920 |      1920 |
|  215 | Collins, Joanne    |   7000 |      10 |      1950 |      1971 |
|  430 | Brunet, Paul C.    |  17674 |     129 |      1938 |      1959 |
|  843 | Schmidt, Herman    |  11204 |      26 |      1936 |      1956 |
|  994 | Iwano, Masahiro    |  15641 |     129 |      1944 |      1970 |
| 1110 | Smith, Paul        |   6000 |      33 |      1952 |      1973 |
| 1330 | Onstad, Richard    |   8779 |      13 |      1952 |      1971 |
| 1523 | Zugnoni, Arthur A. |  19868 |     129 |      1928 |      1949 |
| 1639 | Choy, Wanda        |  11160 |      55 |      1947 |      1970 |
| 2398 | Wallace, Maggie J. |   7880 |      26 |      1940 |      1959 |
| 4901 | Bailey, Chas M.    |   8377 |      32 |      1956 |      1975 |
| 5119 | Bono, Sonny        |  13621 |      55 |      1939 |      1963 |
| 5219 | Schwarz, Jason B.  |  13374 |      33 |      1944 |      1959 |
+------+--------------------+--------+---------+-----------+-----------+
25 rows in set (0,00 sec)
*/
/*Question 2*/
SELECT name FROM jbdept ORDER BY name ASC;
/*+------------------+
| name             |
+------------------+
| Bargain          |
| Book             |
| Candy            |
| Children's       |
| Children's       |
| Furniture        |
| Giftwrap         |
| Jewelry          |
| Junior Miss      |
| Junior's         |
| Linens           |
| Major Appliances |
| Men's            |
| Sportswear       |
| Stationary       |
| Toys             |
| Women's          |
| Women's          |
| Women's          |
+------------------+
19 rows in set (0.01 sec)
*/
/*Question 3*/
SELECT name, qoh FROM jbparts WHERE qoh=0;
/*+-------------------+------+
| name              | qoh  |
+-------------------+------+
| card reader       |    0 |
| card punch        |    0 |
| paper tape reader |    0 |
| paper tape punch  |    0 |
+-------------------+------+
4 rows in set (0.01 sec)
*/
/*Question 4*/
SELECT name, salary FROM jbemployee WHERE salary>=9000 AND salary<=10000;
/*+----------------+--------+
| name           | salary |
+----------------+--------+
| Edwards, Peter |   9000 |
| Smythe, Carol  |   9050 |
| Williams, Judy |   9000 |
| Thomas, Tom    |  10000 |
+----------------+--------+
4 rows in set (0.02 sec)
*/
/*Question 5*/
SELECT name, startyear-birthyear FROM jbemployee;
/*+--------------------+---------------------+
| name               | startyear-birthyear |
+--------------------+---------------------+
| Ross, Stanley      |                  18 |
| Ross, Stuart       |                   1 |
| Edwards, Peter     |                  30 |
| Thompson, Bob      |                  40 |
| Smythe, Carol      |                  38 |
| Hayes, Evelyn      |                  32 |
| Evans, Michael     |                  22 |
| Raveen, Lemont     |                  24 |
| James, Mary        |                  49 |
| Williams, Judy     |                  34 |
| Thomas, Tom        |                  21 |
| Jones, Tim         |                  20 |
| Bullock, J.D.      |                   0 |
| Collins, Joanne    |                  21 |
| Brunet, Paul C.    |                  21 |
| Schmidt, Herman    |                  20 |
| Iwano, Masahiro    |                  26 |
| Smith, Paul        |                  21 |
| Onstad, Richard    |                  19 |
| Zugnoni, Arthur A. |                  21 |
| Choy, Wanda        |                  23 |
| Wallace, Maggie J. |                  19 |
| Bailey, Chas M.    |                  19 |
| Bono, Sonny        |                  24 |
| Schwarz, Jason B.  |                  15 |
+--------------------+---------------------+
25 rows in set (0.01 sec)
*/
/*Question 6*/
SELECT name FROM jbemployee WHERE name LIKE '%son,%';
/*+---------------+
| name          |
+---------------+
| Thompson, Bob |
+---------------+
1 row in set (0.00 sec)
*/
/*Question 7*/
SELECT name FROM jbitem WHERE supplier IN (SELECT id FROM jbsupplier WHERE name = 'Fisher-Price');
/*+-----------------+
| name            |
+-----------------+
| Maze            |
| The 'Feel' Book |
| Squeeze Ball    |
+-----------------+
3 rows in set (0.01 sec)
*/
/*Question 8*/
SELECT jbsupplier.name, jbitem.name FROM jbsupplier, jbitem WHERE jbsupplier.id=jbitem.supplier AND jbsupplier.name='Fisher-Price';
/*+--------------+-----------------+
| name         | name            |
+--------------+-----------------+
| Fisher-Price | Maze            |
| Fisher-Price | The 'Feel' Book |
| Fisher-Price | Squeeze Ball    |
+--------------+-----------------+
3 rows in set (0.00 sec)
*/
/*Question 9*/
SELECT name FROM jbcity WHERE id IN (SELECT city FROM jbsupplier);
/*+----------------+
| name           |
+----------------+
| Amherst        |
| Boston         |
| New York       |
| White Plains   |
| Hickville      |
| Atlanta        |
| Madison        |
| Paxton         |
| Dallas         |
| Denver         |
| Salt Lake City |
| Los Angeles    |
| San Diego      |
| San Francisco  |
| Seattle        |
+----------------+
15 rows in set (0.01 sec)
*/
/*Question 10*/
SELECT name, color,weight FROM jbparts WHERE weight > (SELECT weight FROM jbparts WHERE name='card reader');
/*+--------------+--------+--------+
| name         | color  | weight |
+--------------+--------+--------+
| disk drive   | black  |    685 |
| tape drive   | black  |    450 |
| line printer | yellow |    578 |
| card punch   | gray   |    427 |
+--------------+--------+--------+
4 rows in set (0.00 sec)
*/
/*Question 11*/
SELECT E.name AS 'NAME',E.color AS 'COLOR', E.weight AS 'WEIGHT' FROM jbparts E, jbparts S WHERE E.weight>S.weight AND S.name='card reader';
/*+--------------+--------+--------+
| NAME         | COLOR  | WEIGHT |
+--------------+--------+--------+
| disk drive   | black  |    685 |
| tape drive   | black  |    450 |
| line printer | yellow |    578 |
| card punch   | gray   |    427 |
+--------------+--------+--------+
4 rows in set (0.06 sec)
*/
/*Question 12*/
SELECT AVG(weight) FROM jbparts WHERE color='black';
/*+-------------+
| AVG(weight) |
+-------------+
|    347.2500 |
+-------------+
1 row in set (0.00 sec)
*/
/*Question 13*/
SELECT name, sum(totweight) FROM (SELECT weight*quan AS 'totweight', weight, quan, supplier, name FROM (SELECT weight, part, A.quan, A.supplier, A.name FROM jbparts, (SELECT part,quan,supplier,name FROM jbsupplier,jbsupply WHERE supplier IN (SELECT id FROM jbsupplier WHERE city IN (SELECT id FROM jbcity WHERE state='Mass')) AND jbsupplier.id = jbsupply.supplier) AS A WHERE part = jbparts.id) AS B) AS C GROUP BY name;
/*+--------------+----------------+
| name         | sum(totweight) |
+--------------+----------------+
| DEC          |           3120 |
| Fisher-Price |        1135000 |
+--------------+----------------+
2 rows in set (0.01 sec)
*/
/*Question 14*/
CREATE TABLE newjbitems (
id INTEGER NOT NULL,
name TINYTEXT,
dept INTEGER,
price INTEGER,
qoh INTEGER,
supplier INTEGER,
PRIMARY KEY(id),
FOREIGN KEY(supplier) REFERENCES jbsupplier(id),
FOREIGN KEY(dept) REFERENCES jbdept(id)
);
/*Insert items*/
INSERT INTO newjbitems() SELECT * FROM (SELECT * FROM jbitem WHERE price < (SELECT AVG(price) FROM jbitem)) AS A;
/*Selects table*/
SELECT * FROM newjbitems;
/*+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  26 | Earrings        |   14 |  1000 |   20 |      199 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
+-----+-----------------+------+-------+------+----------+
14 rows in set (0.01 sec)
*/
/*Question 15*/
CREATE VIEW jbitemview AS SELECT * FROM jbitem WHERE price < (SELECT AVG(price) FROM jbitem);
/*CREATE VIEW jbitemview AS SELECT * FROM newjbitems;*/
SELECT * FROM jbitemview;
/*+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  26 | Earrings        |   14 |  1000 |   20 |      199 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
+-----+-----------------+------+-------+------+----------+
14 rows in set (0.02 sec)
*/
/*Question 16*/
/*A view is a virtual table and does therefore not hold data itself, but is built on top of tables or views. If a change is made in the underlying table the same change will be seen in the views. Views are useful when we frequently send queries to access some data. A view is limited in its update operations but not for queries, therefore a view is considered to be static.
A table holds the physical data and allows for data to be added or altered directly. It is therefore considered to be dynamic. 
*/
/*Question 17*/
CREATE VIEW totdebitcost AS SELECT debit, SUM(quantity*price) AS 'total cost' FROM jbsale, jbitem WHERE id=item  GROUP BY debit;
SELECT * FROM totdebitcost;
/*+--------+------------+
| debit  | total cost |
+--------+------------+
| 100581 |       2050 |
| 100582 |       1000 |
| 100586 |      13446 |
| 100592 |        650 |
| 100593 |        430 |
| 100594 |       3295 |
+--------+------------+
6 rows in set (0.01 sec)
*/
/*Question 18*/
CREATE VIEW totdebitcost_join AS SELECT debit, SUM(quantity*price) AS 'total cost' FROM jbsale INNER JOIN jbitem ON item=id GROUP BY debit;

SELECT * FROM totdebitcost;
/*+--------+------------+
| debit  | total cost |
+--------+------------+
| 100581 |       2050 |
| 100582 |       1000 |
| 100586 |      13446 |
| 100592 |        650 |
| 100593 |        430 |
| 100594 |       3295 |
+--------+------------+
6 rows in set (0.02 sec)
*/
/*Question 19*/
/*a)*/
/*STEP 1*/
DELETE FROM jbsale WHERE item IN (SELECT id FROM jbitem WHERE supplier = (SELECT id FROM jbsupplier WHERE city = (SELECT id FROM jbcity WHERE name='Los Angeles')));
SELECT * FROM jbsale;
/*+--------+------+----------+
| debit  | item | quantity |
+--------+------+----------+
| 100581 |  118 |        5 |
| 100581 |  120 |        1 |
| 100586 |  106 |        2 |
| 100586 |  127 |        3 |
| 100592 |  258 |        1 |
| 100593 |   23 |        2 |
| 100594 |   52 |        1 |   
+--------+------+-----------
*/
/*STEP 2*/
DELETE FROM jbitem WHERE supplier = (SELECT id FROM jbsupplier WHERE city = (SELECT id FROM jbcity WHERE name='Los Angeles'));
SELECT * FROM jbitem;
/*+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
|  52 | Jacket          |   60 |  3295 |  300 |       15 |
| 101 | Slacks          |   63 |  1600 |  325 |       15 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 121 | Queen Sheet     |   26 |  1375 |  600 |      213 |
| 127 | Ski Jumpsuit    |   65 |  4350 |  125 |       15 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
| 301 | Boy's Jean Suit |   43 |  1250 |  500 |       33 |
+-----+-----------------+------+-------+------+----------+
18 rows in set (0.03 sec)
*/
/*STEP 3*/
DELETE FROM newjbitems WHERE supplier = (SELECT id FROM jbsupplier WHERE city = (SELECT id FROM jbcity WHERE name='Los Angeles'));
SELECT * FROM newjbitems;
/*+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
+-----+-----------------+------+-------+------+----------+
13 rows in set (0.01 sec)
*/

/*STEP 4*/
DELETE FROM jbsupplier WHERE city = (SELECT id FROM jbcity WHERE name='Los Angeles');
SELECT * FROM jbsupplier;
/*+-----+--------------+------+
| id  | name         | city |
+-----+--------------+------+
|   5 | Amdahl       |  921 |
|  15 | White Stag   |  106 |
|  20 | Wormley      |  118 |
|  33 | Levi-Strauss |  941 |
|  42 | Whitman's    |  802 |
|  62 | Data General |  303 |
|  67 | Edger        |  841 |
|  89 | Fisher-Price |   21 |
| 122 | White Paper  |  981 |
| 125 | Playskool    |  752 |
| 213 | Cannon       |  303 |
| 241 | IBM          |  100 |
| 440 | Spooley      |  609 |
| 475 | DEC          |   10 |
| 999 | A E Neumann  |  537 |
+-----+--------------+------+
15 rows in set (0.02 sec

Since we in step 4 could delete the supplier, it means that there was no supplier in jbsuply from Los Angeles.
*/
/*b)
We made sure to remove all child tuples to the suppliers in Los Angeles as can be seen above. As an example we can’t remove a row in  a table with a  foreign key connecting to  another table, since then it would point to null. Therefore we must move down the chain and remove all children in the chain of foreign keys. 
*/

/*Question 20*/
CREATE VIEW jbsale_supply(supplier, item, quantity) AS (SELECT sname, iname, quantity FROM ((SELECT jbsupplier.name AS 'sname', jbitem.name AS 'iname', jbitem.id FROM jbsupplier, jbitem WHERE jbsupplier.id=jbitem.supplier) AS A) LEFT JOIN jbsale ON jbsale.item=A.id);

SELECT supplier, sum(quantity) AS 'sum' FROM jbsale_supply GROUP BY supplier;
/*+--------------+------+
| supplier     | sum  |
+--------------+------+
| Cannon       |    6 |
| Fisher-Price | NULL |
| Levi-Strauss |    1 |
| Playskool    |    2 |
| White Stag   |    4 |
| Whitman's    |    2 |
+--------------+------+
6 rows in set (0.01 sec)
*/