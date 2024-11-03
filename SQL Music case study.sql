-- 1. Customer Purchase Analysis
-- Finding the total number of purchases made by each customer.

SELECT c.customer_id, c.first_name, c.last_name, SUM(il.quantity) AS total_purchases
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_purchases DESC;

-- 2. Playlist Popularity
-- Find the most frequently included tracks in playlists.

SELECT
    t.Name AS SongName,        -- Get the song's name
    COUNT(pt.track_id) AS PlaylistCount   -- Count how many playlists this song is in
FROM
    playlist_track pt          -- Look at the table that tells us which songs are in which playlists
JOIN
    track t ON pt.track_id = t.track_id   -- Join it with the table that has the song details (like its name)
GROUP BY
    t.Name                     -- Group the results by the song name so we can count each song separately
ORDER BY
    PlaylistCount DESC          -- Show the songs with the highest count first


-- 3. Employee Supervision :
-- Identify which employees report to specific supervisors.
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS EmployeeName,
    CONCAT(s.first_name, ' ', s.last_name) AS SupervisorName
FROM
    employee e
LEFT JOIN
    employee s ON e.reports_to = s.employee_id
ORDER BY
    s.first_name, s.last_name;

/*
Moderate
*/
-- 1. Top ten tracks
-- Find the top 10 tracks with the highest sales.

SELECT TOP 10 track.track_id, SalesSummary.final_unit_price, track.name
FROM (
    SELECT track_id, SUM(unit_price * quantity) AS final_unit_price
    FROM invoice_line
    GROUP BY track_id
) AS SalesSummary
JOIN track ON SalesSummary.track_id = track.track_id
ORDER BY final_unit_price DESC;

-- Using CTE

WITH SalesSummary AS (
    SELECT track_id, SUM(unit_price * quantity) AS final_unit_price
    FROM invoice_line
    GROUP BY track_id
)
SELECT TOP 10 t.track_id, s.final_unit_price, t.name
FROM SalesSummary s
JOIN track t ON s.track_id = t.track_id
ORDER BY s.final_unit_price DESC;

-- 2. Media Type Sales 
-- Compare sales of different media types (e.g., physical vs. digital).
SELECT
    COUNT(t.track_id) AS trackids_count,        -- Count the number of tracks
    mt.media_type_id AS [media type],           -- Media type ID
    mt.name AS MediaType,                       -- Media type name (e.g., "Physical", "Digital")
    SUM(il.unit_price * il.quantity) AS total_sales -- Total sales for each media type
FROM
    track t
JOIN
    media_type mt ON t.media_type_id = mt.media_type_id -- Join track with media type
JOIN
    invoice_line il ON il.track_id = t.track_id         -- Join invoice_line to get sales info
GROUP BY
    mt.media_type_id, mt.name;                          -- Group by media type ID and name

-- Using Case function to name as audio and video file --
SELECT
    COUNT(t.track_id) AS trackids_count,
    CASE
        WHEN mt.name LIKE '%MPEG audio file%' THEN 'Audio'
        WHEN mt.name LIKE '%Protected AAC audio file' THEN 'Audio'
        WHEN mt.name LIKE '%Protected MPEG-4 video file' THEN 'Video'
        WHEN mt.name LIKE '%Purchased AAC audio file' THEN 'Audio'
        WHEN mt.name LIKE '%AAC audio file' THEN 'Audio'
        ELSE 'Other'
    END AS MediaTypeCategory,
    SUM(il.unit_price * il.quantity) AS total_sales
FROM
    track t
JOIN
    media_type mt ON t.media_type_id = mt.media_type_id
JOIN
    invoice_line il ON il.track_id = t.track_id
GROUP BY
    CASE
        WHEN mt.name LIKE '%MPEG audio file%' THEN 'Audio'
        WHEN mt.name LIKE '%Protected AAC audio file' THEN 'Audio'
        WHEN mt.name LIKE '%Protected MPEG-4 video file' THEN 'Video'
        WHEN mt.name LIKE '%Purchased AAC audio file' THEN 'Audio'
        WHEN mt.name LIKE '%AAC audio file' THEN 'Audio'
        ELSE 'Other'
    END;

-- 3. Genre Popularity 
-- Determine which genre has the highest number of tracks sold.


SELECT TOP 10 track.track_id, SalesSummary.final_unit_price, track.name
FROM (
    SELECT track_id, SUM(unit_price * quantity) AS final_unit_price
    FROM invoice_line
    GROUP BY track_id
) AS SalesSummary
JOIN track ON SalesSummary.track_id = track.track_id
ORDER BY final_unit_price DESC;

WITH SalesSummary AS (
    SELECT track_id, SUM(unit_price * quantity) AS final_unit_price
    FROM invoice_line
    GROUP BY track_id
)
SELECT TOP 10 t.track_id, s.final_unit_price, t.name
FROM SalesSummary s
JOIN track t ON s.track_id = t.track_id
ORDER BY s.final_unit_price DESC;

-- 4. Invoice trends
-- Problem Statement:** Analyze monthly or yearly sales trends based on invoices.

-- Analyze sales by year and month

SELECT 
    YEAR(invoice_date) AS sales_year,
    MONTH(invoice_date) AS sales_month,
    SUM(total) AS total_sales
FROM 
    invoice
GROUP BY 
    YEAR(invoice_date), MONTH(invoice_date)
ORDER BY 
    sales_year, sales_month;

-- Analyze sales by year.

SELECT 
    YEAR(invoice_date) AS sales_year,
    SUM(total) AS total_sales
FROM 
    invoice
GROUP BY 
    YEAR(invoice_date)
ORDER BY 
    sales_year;

-- 5. Employee sales peformance
--  Identifying which employees (support representatives) are responsible for the highest total sales.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    SUM(i.total) AS total_sales
FROM
    employee e
JOIN
    customer c ON e.employee_id = c.support_rep_id
JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY
    e.employee_id, e.first_name, e.last_name
ORDER BY
    total_sales DESC

/* Advanced*/

-- 1. Customer Segmentation by Region
-- Analyze sales by geographic region (city, state, country) 
-- to identify the regions with the highest customer activity.

select c.city,c.state,c.country,sum(i.total) as [sum of sales]
from customer c JOIN invoice i on 
i.customer_id = c.customer_id
GROUP by c.country,c.state,c.city
order by c.country,[sum of sales] desc 

-- But if we want top sales by overall all country wise: 

select c.country,ROUND(sum(i.total),2) as [sum of sales]
from customer c JOIN invoice i on 
i.customer_id = c.customer_id
GROUP by c.country
order by [sum of sales] desc 

--2. Customer Lifetime Value (CLV) 
--Calculate the lifetime value of each customer based on their total purchases.

SELECT
i.customer_id,
sum(il.unit_price*il.quantity) as lifetime_value
FROM customer c
INNER JOIN invoice i ON i.customer_id = c.customer_id
JOIN invoice_line il
ON il.invoice_id = i.invoice_id
GROUP BY i.customer_id
ORDER BY lifetime_value DESC

-- 3. Album Sales Insights 
-- Which albums are generating the most revenue?

WITH SalesSummary AS (
    SELECT track_id, SUM(unit_price * quantity) AS final_unit_price
    FROM invoice_line
    GROUP BY track_id
)
SELECT 
    top 10 a.album_id, 
    a.title AS album_title,  -- Album title included
    SUM(s.final_unit_price) AS total_revenue, 
    MAX(t.name) AS sample_track -- Sample track from the album
FROM SalesSummary s
JOIN track t ON s.track_id = t.track_id
JOIN album a ON a.album_id = t.album_id
GROUP BY a.album_id, a.title  -- Include album_id and album_title in the GROUP BY
ORDER BY total_revenue DESC;


-- 4. Track Duration and Sales Correlation
-- Finding out the correlation between track duration (milliseconds) and sales volume.

SELECT
    t.track_id,
    t.milliseconds,
    SUM(il.quantity) AS total_sales_volume
FROM
    track t
INNER JOIN
    invoice_line il ON t.track_id = il.track_id
GROUP BY
    t.track_id, t.milliseconds;

    -- exporting this result as csv
