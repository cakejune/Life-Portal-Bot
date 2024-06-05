-- Exercise 1:

-- What is the abbreviation of New York State?

-- Answer:

SELECT abbreviation FROM state.abbrevs
WHERE state = 'New York';
-- > NY

-- Exercise 2:

-- What is the area of New York State?

-- Answer:

SELECT state, area FROM state.areas
WHERE state = 'New York';
--> New York	54475

-- Exercise 3:

-- What is the population of NY (New York State)?

-- Answer:
    
SELECT * FROM state.population
WHERE region = 'NY' AND ages = 'total'
-- --> 
-- NY	total	2013	19,651,127
-- NY	total	2012	19,576,125
-- NY	total	2011	19,502,728
-- NY	total	2010	19,398,228

-- Exercise 4:

-- For each year, what is the average state population (round to 2 decimal places with the 
-- ROUND function) for age under 18? (remember to exclude “USA”)

-- Answer: Since a year was not specified, I'm going to choose the most recent year recorded (2013). I did the query first to inspect the populations with the parameters, then used that as a subquery and further tuned the query.

SELECT ROUND(AVG(population), 2) AS average_population
FROM
(
SELECT region, ages, year, population
FROM state.population
WHERE ages = 'under18' AND year = '2013' AND region != 'USA'
) AS subquery;
--> 1,430,768.08

-- Exercise 5:

-- Which state has the largest area? What about the smallest state?

SELECT state, area
FROM state.areas
WHERE area = (SELECT MAX(area) FROM state.areas);
--> Alaska	656425;

-- also I liked this version:

SELECT state, area
FROM state.areas
ORDER BY area DESC
LIMIT 1;

SELECT state, area
FROM state.areas
WHERE area = (SELECT MIN(area) FROM state.areas);
-- > District of Columbia	68
-- (that almost doesn't count. let's get the second smallest)

SELECT state, area
FROM state.areas
ORDER BY area
LIMIT 1 OFFSET 1;
-- > Rhode Island	1545

-- Exercise 6:

-- What is the area of state CA (do not use California)?

-- Answer: I assume you meant to get the result California from another table via another search query, but I'm not sure, so used CA to get the state name from state.abbrevs table, and then used that as a subquery.

SELECT area
FROM state.areas
WHERE state = (
SELECT state
FROM state.abbrevs
WHERE abbreviation = 'CA'
);
-- > 163,707

-- Exercise 7:

-- What is the (total) population density per square mile (round to 2 decimal places) for each state in 2013?

-- assuming the area given in the state.areas table is in square miles, then the following should yield the answer:

SELECT 
	ab.state,
    ab.abbreviation,
    a.area,
    p.population,
    p.year,
    ROUND((p.population / a.area), 2) AS population_density
FROM state.population AS p
LEFT JOIN state.abbrevs AS ab ON p.region = ab.abbreviation
LEFT JOIN state.areas AS a ON ab.state = a.state
WHERE
	p.year = '2013' AND p.ages = 'total'

-- My results include a lot more information just so the user can see the data more clearly, but I'll just paste the two columns for convenience sake.

-- Alabama	92.21
-- Alaska	1.12
-- Arizona	58.13
-- Arkansas	55.65
-- California	234.15
-- Colorado	50.61
-- Connecticut	648.64
-- Delaware	473.77
-- District of Columbia	9506.60
-- Florida	297.35
-- Georgia	168.10
-- Hawaii	128.44
-- Idaho	19.29
-- Illinois	222.42
-- Indiana	180.42
-- Iowa	54.92
-- Kansas	35.17
-- Kentucky	108.76
-- Louisiana	89.22
-- Maine	37.54
-- Maryland	477.86
-- Massachusetts	634.09
-- Michigan	102.22
-- Minnesota	62.34
-- Mississippi	61.76
-- Missouri	86.71
-- Montana	6.90
-- Nebraska	24.15
-- Nevada	25.23
-- New Hampshire	141.53
-- New Jersey	1020.33
-- New Mexico	17.15
-- New York	360.74
-- North Carolina	182.98
-- North Dakota	10.23
-- Ohio	258.12
-- Oklahoma	55.08
-- Oregon	39.95
-- Pennsylvania	277.34
-- Rhode Island	680.59
-- South Carolina	149.18
-- South Dakota	10.96
-- Tennessee	154.13
-- Texas	98.47
-- Utah	34.17
-- Vermont	65.17
-- Virginia	193.14
-- Washington	97.77
-- West Virginia	76.53
-- Wisconsin	87.67
-- Wyoming	5.96

-- Exercise 8:

-- What are the top 3 most populated states for each year? Return year, state, rank, and (total) population. (Hint: window functions)

-- I used WITH here but learned that I could have used a subquery structure. To me, this method of 
-- using WITH seems more intuitive, as you're defining the piece of data, and then manipulating it later

WITH ranked_data AS (
SELECT
    region,
    year,
    population,
    RANK() OVER (PARTITION BY year ORDER BY population DESC) AS population_rank

FROM
    state.population
WHERE region != 'USA'
ORDER BY year, population_rank
)
SELECT region, year, population, population_rank FROM ranked_data WHERE population_rank <= 3


