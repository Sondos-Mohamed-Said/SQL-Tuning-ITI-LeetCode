/*
===================================================================================================
📌 Problem: Trips and Users (LeetCode - Hard)
👤 Author: Sondos Mohamed (Sondos Analytics)
📈 Objective: Calculate the cancellation rate of unbanned users using optimized join order and early predicates.
===================================================================================================

🗄️ OPTIMIZATION JOURNEY & PERFORMANCE ARCHIVES:
-------------------------------------------------

🚀 Approach 1: The Inline Case-Filter (Initial Attempt)
   - Status: WRONG ANSWER / RUNTIME ERROR
   - Bottleneck: Placed the date filter only in the numerator's CASE WHEN. 
     This forced dense joins on the ENTIRE dataset before evaluating conditions row-by-row, leading to memory bloating.
   
   [Code Archive]:
   -- WITH SONDOS_SOL AS (
   --     SELECT  T.request_at ,COUNT(
   --     CASE WHEN 
   --     (C.banned ='NO' AND D.banned ='NO')
   --     THEN 1
   --     ELSE NULL
   --     END) AS Total_Trips,
   --     
   --     COUNT(
   --     CASE WHEN (
   --     T.status = 'cancelled_by_client' 
   --     OR T.status = 'cancelled_by_driver')
   --     AND C.banned ='NO' 
   --     AND D.banned ='NO' AND T.request_at BETWEEN '2013-10-01' and '2013-10-03'
   --     THEN 1
   --     ELSE NULL
   --     END ) AS num_of_canceled
   --     FROM Trips T
   --     LEFT JOIN Users C
   --     ON T.client_id = C.users_id 
   --     LEFT JOIN Users D
   --     ON T.client_id = D.users_id 
   --     GROUP BY T.request_at
   -- ) SELECT request_at AS Day , ROUND(CAST(num_of_canceled AS DECIMAL(10,2)) / Total_Trips, 2) AS 'Cancellation Rate'
   -- FROM SONDOS_SOL


🚀 Approach 2: Inline Case-Filter with Date Attempt (The Logic Trap)
   - Status: RUNTIME ERROR (Divide by zero error encountered - Error 8134)
   - Vulnerability: Trying to fix Approach 1 by placing the date inside both CASE blocks. 
     When LeetCode tested an input outside the date bounds (e.g., '2013-10-04'), the denominator CASE 
     evaluated to NULL, resulting in a COUNT of 0. The final query then triggered a fatal division by zero.
   
   [Code Archive]:
   -- WITH SONDOS_SOL AS (
   --     SELECT  
   --         T.request_at,
   --         COUNT(CASE 
   --             WHEN (C.banned ='NO' AND D.banned ='NO') 
   --                  AND T.request_at BETWEEN '2013-10-01' AND '2013-10-03' THEN 1
   --             ELSE NULL
   --         END) AS Total_Trips,
   --         COUNT(CASE 
   --             WHEN (T.status = 'cancelled_by_client' OR T.status = 'cancelled_by_driver')
   --                  AND C.banned ='NO' AND D.banned ='NO' 
   --                  AND T.request_at BETWEEN '2013-10-01' AND '2013-10-03' THEN 1
   --             ELSE NULL
   --         END) AS num_of_canceled
   --     FROM Trips T
   --     LEFT JOIN Users C ON T.client_id = C.users_id 
   --     LEFT JOIN Users D ON T.driver_id = D.users_id 
   --     GROUP BY T.request_at
   -- ) 
   -- SELECT request_at AS Day, ROUND(CAST(num_of_canceled AS DECIMAL(10,2)) / Total_Trips, 2) AS [Cancellation Rate]
   -- FROM SONDOS_SOL;
*/

-- ===================================================================================================
-- 🏆 APPROACH 3: THE WINNING PRODUCTION SOLUTION (OPTIMAL TUNING)
-- ===================================================================================================
-- Strategy: Predicate Pushdown (WHERE Filters) + High-Speed INNER JOIN Pipelines
-- Performance: Safe from Divide-by-Zero because out-of-bound dates are dropped completely BEFORE aggregation.
-- Math Safety: Multiplied by 1.0 to enforce high-precision Float/Decimal division before rounding.

WITH SONDOS_SOL AS (
    SELECT  
        T.request_at,
        -- Total valid trips after discarding banned users and out-of-bound dates via WHERE clause
        COUNT(*) AS Total_Trips,
        
        -- High-speed scalar accumulation instead of heavy conditional logging
        SUM(CASE 
                WHEN T.status = 'cancelled_by_client' 
                  OR T.status = 'cancelled_by_driver' THEN 1
                ELSE 0 
            END) AS num_of_canceled
    FROM Trips T
    INNER JOIN Users C ON T.client_id = C.users_id   -- Client binding
    INNER JOIN Users D ON T.driver_id = D.users_id   -- Driver binding (Fixed cross-binding bottleneck)
    WHERE 
        C.banned = 'No' 
        AND D.banned = 'No'
        AND T.request_at BETWEEN '2013-10-01' AND '2013-10-03' -- Pushed down predicates (Safeguards against zero-division)
    GROUP BY T.request_at
) 
SELECT 
    request_at AS Day, 
    ROUND((num_of_canceled * 1.0 / Total_Trips), 2) AS [Cancellation Rate]
FROM SONDOS_SOL;
