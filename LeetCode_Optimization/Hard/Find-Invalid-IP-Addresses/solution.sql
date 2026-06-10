/*
===================================================================================================
📌 Problem: Find Invalid IP Addresses (LeetCode - Hard)
👤 Author: Sondos Mohamed (Sondos Analytics)
📈 Objective: Identify and count malformed/invalid IP addresses based on strict T-SQL performance tuning.
===================================================================================================

🗄️ BENCHMARK ARCHIVES & EVOLUTION TRACKING:
-------------------------------------------

🚀 Approach 1: Window Functions (Baseline)
   - Runtime: 423 ms
   - Bottleneck: Heavy memory spooling caused by nested OVER(PARTITION BY) and DISTINCT.
   
   [Code Archive]:
   -- WITH SS as (
   --     SELECT ip,log_id , value AS CuttedPart
   --     FROM logs
   --     CROSS APPLY STRING_SPLIT(ip, '.')
   -- )
   -- ,MM AS (
   --     SELECT log_id ,ip ,CuttedPart,COUNT(CuttedPart) OVER(PARTITION BY  log_id,ip) AS DD
   --     FROM SS
   --     WHERE CuttedPart <= 255 AND NOT (LEN(CuttedPart) > 1 AND LEFT(CuttedPart, 1) = '0')
   -- )
   -- ,LL AS (
   --     SELECT log_id ,ip ,COUNT(*) OVER(PARTITION BY ip) AS invalid_count
   --     FROM MM
   --     WHERE DD != 4
   --     GROUP BY log_id,ip
   -- )
   -- SELECT DISTINCT ip , invalid_count
   -- FROM LL
   -- ORDER BY invalid_count DESC, ip DESC


🚀 Approach 2: Group By & Hard Cast
   - Runtime: 292 ms
   - Risk Factor: Fast but vulnerable; will crash the pipeline if alphabetic corruption exists.
   
   [Code Archive]:
   -- with base as (
   --     select log_id , ip , value from logs cross apply string_split(ip,'.')
   -- ) , filtering as (
   -- select log_id ,  ip ,  SUM(case when  value like '0%' or cast(value as int) > 255 then 1 else 0 end) as incorrect_condition , count(value) as octet_count  from base group by log_id , ip
   -- )
   -- select ip , count(ip) as invalid_count from filtering where incorrect_condition != 0 or octet_count != 4
   -- group by ip 
   -- order by count(ip) desc , ip desc


🚀 Approach 3: Conditional Aggregation with TRY_CAST
   - Runtime: 317 ms
   - Trade-off: High type safety, but slightly slowed by the string-matching 'LIKE' operator.
   
   [Code Archive]:
   -- WITH base AS (
   --     SELECT log_id, ip, value 
   --     FROM logs 
   --     CROSS APPLY STRING_SPLIT(ip, '.')
   -- ), 
   -- filtering AS (
   --     SELECT 
   --         log_id,  
   --         ip,  
   --         SUM(CASE 
   --                 WHEN TRY_CAST(value AS INT) IS NULL 
   --                   OR TRY_CAST(value AS INT) > 255 
   --                   OR (LEN(value) > 1 AND value LIKE '0%') THEN 1 
   --                 ELSE 0 
   --             END) AS incorrect_condition, 
   --         COUNT(value) AS octet_count  
   --     FROM base 
   --     GROUP BY log_id, ip
   -- ),
   -- invalid_list AS (
   --     SELECT ip
   --     FROM filtering 
   --     WHERE incorrect_condition != 0 OR octet_count != 4
   -- )
   -- SELECT 
   --     ip, 
   --     COUNT(*) AS invalid_count 
   -- FROM invalid_list
   -- GROUP BY ip 
   -- ORDER BY invalid_count DESC, ip DESC;
*/

-- ===================================================================================================
-- 🏆 APPROACH 4: THE WINNING PRODUCTION SOLUTION (OPTIMAL TUNING)
-- ===================================================================================================
-- Runtime: 302 ms
-- Strategy: Early Filtering Pipeline using Pure Numeric Inversion & Semi-Join logic.
-- Type Safety: Absolute (guaranteed by TRY_CAST).

WITH SplitIP AS (
    -- Step 1: Fragment the IP strings into octet rows using CROSS APPLY
    SELECT log_id, ip, value AS Part
    FROM logs
    CROSS APPLY STRING_SPLIT(ip, '.')
),
InvalidLogs AS (
    -- Step 2: Early filter to capture invalid log IDs instantly using low-overhead CPU checks
    SELECT DISTINCT log_id
    FROM SplitIP
    WHERE 
        TRY_CAST(Part AS INT) IS NULL                          -- Catches alphabetical data corruption safely
        OR TRY_CAST(Part AS INT) NOT BETWEEN 0 AND 255         -- Catches out-of-bounds octets
        OR (TRY_CAST(Part AS INT) > 0 AND LEFT(Part, 1) = '0') -- Catches leading zeros on values > 0 (e.g., '015')
        OR (TRY_CAST(Part AS INT) = 0 AND LEN(Part) > 1)       -- Catches malformed zeros (e.g., '00')
    
    UNION
    
    -- Catch structural failures (IPs that do not contain exactly 4 octets)
    SELECT log_id
    FROM SplitIP
    GROUP BY log_id
    HAVING COUNT(Part) != 4
)
-- Step 3: Stream aggregation over the main table leveraging optimized Left Semi-Join behavior
SELECT ip, COUNT(*) AS invalid_count
FROM logs
WHERE log_id IN (SELECT log_id FROM InvalidLogs)
GROUP BY ip
ORDER BY invalid_count DESC, ip DESC;
