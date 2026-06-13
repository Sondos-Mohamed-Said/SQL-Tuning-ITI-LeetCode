# 🚕 Case Study: Trips and Users (LeetCode - Hard)

## 1️⃣ Problem Description
Write a solution to find the **cancellation rate** of requests with unbanned users (both client and driver must not be banned) each day between `"2013-10-01"` and `"2013-10-03"` with at least one trip. Round the `Cancellation Rate` to two decimal points.

The cancellation rate is computed by dividing the number of canceled requests (by client or driver) involving unbanned users by the total number of requests involving unbanned users on that day.

### 📊 Table Schema

**Trips Table:**
| Column Name | Type | Description |
| :--- | :--- | :--- |
| **id** | INT | Primary Key. |
| **client_id** | INT | Foreign Key linking to Users table. |
| **driver_id** | INT | Foreign Key linking to Users table. |
| **city_id** | INT | City Identifier. |
| **status** | VARCHAR | Status of trip ('completed', 'cancelled_by_driver', 'cancelled_by_client'). |
| **request_at**| DATE | Date of the request. |

**Users Table:**
| Column Name | Type | Description |
| :--- | :--- | :--- |
| **users_id** | INT | Primary Key. |
| **banned** | VARCHAR | Status of the user ('Yes', 'No'). |
| **role** | VARCHAR | User persona ('client', 'driver', 'partner'). |

---

## 2️⃣ The Optimized Winning Solution
This query structures database isolation patterns by avoiding inline filter processing, allowing streaming aggregation loops to complete efficiently.

```sql
WITH SONDOS_SOL AS (
    SELECT  
        T.request_at,
        COUNT(*) AS Total_Trips,
        SUM(CASE 
                WHEN T.status = 'cancelled_by_client' 
                  OR T.status = 'cancelled_by_driver' THEN 1
                ELSE 0 
            END) AS num_of_canceled
    FROM Trips T
    INNER JOIN Users C ON T.client_id = C.users_id   
    INNER JOIN Users D ON T.driver_id = D.users_id   
    WHERE 
        C.banned = 'No' 
        AND D.banned = 'No'
        AND T.request_at BETWEEN '2013-10-01' AND '2013-10-03' 
    GROUP BY T.request_at
) 
SELECT 
    request_at AS Day, 
    ROUND((num_of_canceled * 1.0 / Total_Trips), 2) AS [Cancellation Rate]
FROM SONDOS_SOL;
