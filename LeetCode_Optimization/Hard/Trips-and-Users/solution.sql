/*
===================================================================================================
📌 Problem: Trips and Users (LeetCode - Hard)
👤 Author: Sondos Mohamed (Sondos Analytics)
📈 Objective: Calculate the cancellation rate of unbanned users using optimized join order and early predicates.
===================================================================================================

🗄️ OPTIMIZATION JOURNEY & PERFORMANCE ARCHIVES:
-------------------------------------------------

🚀 Approach 1: The Inline Case-Filter (Initial Attempt)
   - Vulnerability: Placing filters inside COUNT(CASE WHEN) forces dense joins on the ENTIRE dataset 
     before evaluating conditions row-by-row, heavy memory spooling.
   
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
*/

-- ===================================================================================================
-- 🏆 APPROACH 2: THE WINNING PRODUCTION SOLUTION (OPTIMAL TUNING)
-- ===================================================================================================
-- Strategy: Predicate Pushdown (WHERE Filters) + High-Speed INNER JOIN Pipelines
-- Math Safety: Multiplied by 1.0 to enforce high-precision Float/Decimal division before rounding.

WITH SONDOS_SOL AS (
    SELECT  
        T.request_at,
        -- Total valid trips after discarding banned users via WHERE clause
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
        AND T.request_at BETWEEN '2013-10-01' AND '2013-10-03' -- Pushed down predicates
    GROUP BY T.request_at
) 
SELECT 
    request_at AS Day, 
    ROUND((num_of_canceled * 1.0 / Total_Trips), 2) AS [Cancellation Rate]
FROM SONDOS_SOL;
