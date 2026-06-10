# 🛠️ Case Study: Finding & Counting Invalid IP Addresses (LeetCode - Hard)

## 1️⃣ Problem Description
You are given a system log table containing IP addresses. The goal is to identify all **invalid** IP addresses and calculate how many times each invalid IP appears in the logs.

An IP address is considered **invalid** if it violates any of the following networking rules:
1. **Structural Failure:** It does not contain exactly four octets separated by dots (e.g., `192.168.1` or `10.0.0.1.2`).
2. **Out of Bounds:** Any of its octets is not a valid integer between `0` and `255` inclusive (e.g., `172.16.300.1`).
3. **Leading Zeros:** Any octet contains leading zeros (e.g., `192.168.01.1` or `172.16.00.1`). *Note: A single `0` by itself is completely valid.*
4. **Data Corruption:** Any octet contains alphabetical characters or symbols (e.g., `10.0.abc.1`).

### 📊 Table Schema (`logs`)
| Column Name | Type | Description |
| :--- | :--- | :--- |
| **log_id** | INT | Primary Key for this table. |
| **ip** | VARCHAR | The IP address recorded in the system logs. |

### 📊 Sorting Requirements
The final output must be sorted by `invalid_count` in **descending** order, and then by `ip` in **descending** order.

---

## 2️⃣ The Winning Solution (302 ms)
This production-ready query isolates data anomalies early in the lifecycle, allowing the database engine to utilize streaming operators efficiently and safely.

```sql
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
