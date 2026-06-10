# 🏎️ SQL Tuning Hub: ITI & LeetCode Challenges

Welcome to my advanced SQL repository! This space serves as a comprehensive portfolio containing my database engineering tasks from the **Information Technology Institute (ITI)** alongside rigorous query optimization challenges from **LeetCode**.

Rather than just writing queries that return the correct results, my core focus here is **Performance Tuning, Execution Plan Analysis, Type Safety, and Resource Efficiency (T-SQL)**.

---

## 📁 Repository Structure

### 🎓 1. ITI Tasks & Modules
This section contains structured database assignments, architectural designs, and hands-on labs completed during my intensive technical training at ITI. The files are organized directly by module titles and topics to track academic and practical progress.

### 🚀 2. LeetCode Advanced Tuning (`/LeetCode-Optimization`)
This is a dedicated space where I tackle algorithmic SQL challenges, bench-marking execution times, and document how the **SQL Server Query Optimizer** behaves under pressure. 

Each challenge folder includes:
1. The baseline solution.
2. Performance bottleneck identification (e.g., catching expensive Table Spools or implicit conversions).
3. The final optimized, production-ready script.

---

## 🌟 Featured Tuning Case Studies

* **[Find Invalid IP Addresses (Medium) 🛠️](./LeetCode-Optimization/Medium/Find-Invalid-IP-Addresses/)**
  * **Concepts tuned:** Swapped heavy Window Functions (`OVER`) with high-speed Early Filtering pipelines, utilized `CROSS APPLY` + `STRING_SPLIT`, and implemented absolute Type Safety using `TRY_CAST`.
  * **Result:** Successfully optimized execution runtime from **423ms** down to **302ms** while ensuring production-grade stability against corrupted data logs.

---

## 🛠️ Tech Stack & Tooling
* **Database Management Systems:** Microsoft SQL Server (MSSQL)
* **Development Environments:** SQL Server Management Studio (SSMS)
* **Core Practices:** Query Execution Plan Analysis, Conditional Aggregations, Performance Tuning (Tuning Indexes, Table Spools, and Joins).

---
📫 *Connect with me on LinkedIn to discuss Data Analytics, AI Agent workflows, or Database Engineering!*
