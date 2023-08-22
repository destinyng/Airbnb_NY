
-- Average price with OVER()
SELECT id, name, neighbourhood_group, AVG(price) OVER()
FROM airbnb_ny;

-- Average, minimum, maximum with OVER()
SELECT id, name, neighbourhood_group, AVG(price) OVER(),
    MIN(price) OVER(),
    MAX(price) OVER()
FROM airbnb_ny;

-- Difference from average price with OVER
SELECT id, name, neighbourhood_group, 
        price,
        AVG(price) OVER(),
        price - AVG(price) OVER() AS diff_from_avg
FROM airbnb_ny;

--Percentage price over average price
SELECT id, name, neighbourhood_group, 
        price,
        ROUND(AVG(price) OVER(), 2),
        ROUND((price / AVG(price) OVER() * 100),2) AS percent_of_avg_price
FROM airbnb_ny;

--Percentage difference from average price
SELECT id, name, neighbourhood_group, 
        price,
        ROUND(AVG(price) OVER(), 2),
        ROUND((price / AVG(price) OVER()-1) * 100,2) AS percent_of_avg_price
FROM airbnb_ny;

-- PARTITION BY neighbourhood group
SELECT DISTINCT neighbourhood_group
FROM airbnb_ny;

SELECT id, 
        name,
        neighbourhood_group,
        neighbourhood,
        price,
        AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neighborhood       
FROM airbnb_ny;

-- PARTITION BY neighbourhood group and neighbourhood
SELECT id, 
        name,
        neighbourhood_group,
        neighbourhood,
        price,
        AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neighborhood,
        AVG(price) OVER(PARTITION BY neighbourhood_group, neighbourhood) AS avg_price_by_group_and_neigh       
FROM airbnb_ny;

SELECT id, 
        name,
        neighbourhood_group,
        neighbourhood,
        price,
        AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group,
        AVG(price) OVER(PARTITION BY neighbourhood_group, neighbourhood) AS avg_price_by_group_and_neigh,
        ROUND(price -  AVG(price) OVER(PARTITION BY neighbourhood_group), 2) AS neigh_group_delta,
        ROUND(price - AVG(price) OVER(PARTITION BY neighbourhood_group, neighbourhood), 2) AS group_and_neigh_delta
FROM airbnb_ny;

--overall price rank
SELECT id,
        name,
        neighbourhood_group,
        neighbourhood,
        price,
        ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank
FROM airbnb_ny;

--neighborhood price rank
SELECT id,
        name,
        neighbourhood_group,
        neighbourhood,
        price,
        ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
        ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_price_rank
FROM airbnb_ny;

--Top 3:
SELECT id,
        name,
        neighbourhood_group,
        neighbourhood,
        price,
        ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
        ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_price_rank,
        CASE 
            WHEN ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) <= 3 THEN 'Yes'
            ELSE 'No'
        END AS top3_flag
FROM airbnb_ny;

--RANK
SELECT id,
        name,
        neighbourhood_group,
        neighbourhood,
        price,
        ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
        RANK() OVER(ORDER BY price DESC) AS overrall_price_rank_with_rank
        -- ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_price_rank,
        -- RANK() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_price_rank_with_rank
FROM airbnb_ny;

SELECT id,
        name,
        neighbourhood_group,
        neighbourhood,
        price,
        ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
        RANK() OVER(ORDER BY price DESC) AS overrall_price_rank_with_rank,
        DENSE_RANK() OVER(ORDER BY price DESC) overall_price_rank_with_dense_rank
        -- ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_price_rank,
        -- RANK() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_price_rank_with_rank
FROM airbnb_ny;

--LAG by 1 period
SELECT id,
        name,
        host_name,
        price,
        last_review,
        LAG(price) OVER(PARTITION BY host_name ORDER BY last_review)
FROM airbnb_ny

--LAG BY 2 period
SELECT id,
        name,
        host_name,
        price,
        last_review,
        LAG(price,2) OVER(PARTITION BY host_name ORDER BY last_review)
FROM airbnb_ny

--LEAD BY 1 period
SELECT id, 
        name,
        host_name,
        price, 
        last_review,
        LEAD(price) OVER(PARTITION BY host_name ORDER BY last_review)
FROM airbnb_ny

--LEAD BY 2 period
SELECT id, 
        name,
        host_name,
        price, 
        last_review,
        LEAD(price,2) OVER(PARTITION BY host_name ORDER BY last_review)
FROM airbnb_ny

-- TOP 3 listings from each neighbourhood, with subquery to select only the 'yes' values from the top3_flag column:
SELECT * FROM (
    SELECT id,
        name,
        neighbourhood_group,
        neighbourhood,
        price,
        ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
        ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_price_rank,
        CASE 
            WHEN ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) <= 3 THEN 'Yes'
            ELSE 'No'
        END AS top3_flag
FROM airbnb_ny
) a 
WHERE top3_flag = 'Yes'