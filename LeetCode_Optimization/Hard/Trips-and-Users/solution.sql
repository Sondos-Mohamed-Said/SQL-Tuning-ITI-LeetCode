/*
===================================================================================================
📌 Problem: Trips and Users (LeetCode - Hard)
👤 Author: Sondos Mohamed (Sondos Analytics)
📈 Objective: Calculate the cancellation rate of unbanned users using optimized join order and early predicates.
===================================================================================================

🗄️ OPTIMIZATION JOURNEY & PREDICTIVE BOTTLENECKS:
-------------------------------------------------
⚠️ The Inline Case-Filter Trap:
   Placing filters like (T.request_at BETWEEN ...) inside conditional aggregations (COUNT(CASE WHEN)) 
   forces the Query Engine to perform dense joins on the ENTIRE dataset before evaluating conditions row-by-row.
   
🚀 The Optimized Approach:
   Shifting filters to the WHERE clause unlocks "Predicate Pushdown". The SQL Server Query Optimizer 
   filters the underlying tables FIRST, stripping out banned users and out-of-range dates, 
   and then executes low-overhead INNER JOINS on the pruned subsets.
*/

-- ===================================================================================================
-- 🏆 THE WINNING PRODUCTION SOLUTION (OPTIMAL TUNING)
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
