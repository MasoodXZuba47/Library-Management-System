# 📚 Library Management System — SQL Mini Project

A fully-featured **relational database project** built with MySQL, demonstrating real-world SQL concepts including normalized schema design, complex queries, views, stored procedures, and triggers.

---

## 🗂️ Project Structure

```
mini project 3/
│
├── schema.sql              # Table definitions & foreign keys
├── seed_data.sql           # Sample data (authors, books, members, loans, fines)
├── queries.sql             # 10 analytical SQL queries
├── views.sql               # 5 reusable views
├── procedures_triggers.sql # 3 stored procedures + 2 triggers
└── README.md               # This file
```

---

## 🧩 Database Schema

![ER Diagram](https://mermaid.ink/img/pako:eNo1kMFqwzAQRH9l2VMC_oA9FKqGQi9pqS0oYLIsJyayJaQNDcH_XsU-7GWZed_smZmLoqFC0dOHxtExLBZo4ygdWpW2RxB7MK67VBgKa0xpfSIXB6Vj-sHM8Ro7W_aJ5K5I773Ir_H_pPjuLWkOMkU4S5oMVCBTTUUo4SaJ2m4Sxt3HxX9Zzla5RO2aKPPLMnbr1v63UhVzuqD7G1X9kBM2iV9ht5mC51A50BKQR_oAAAA)

| Table | Description |
|---|---|
| `genres` | Book categories |
| `authors` | Author info & nationality |
| `books` | Book titles, ISBN, year |
| `book_copies` | Physical copies with condition & availability |
| `members` | Library member accounts |
| `loans` | Borrow records with due dates |
| `fines` | Late return charges |

**Key Relationships:**
- A `book` belongs to one `author` and one `genre`
- A `book` can have many `book_copies`
- A `loan` links one `book_copy` to one `member`
- A `fine` is raised for a `loan` returned past its due date

---

## ✨ Feature Highlights

### 📋 Queries (`queries.sql`)
| # | Query | Concepts |
|---|---|---|
| Q1 | Full book catalogue | JOIN × 3 |
| Q2 | Book availability snapshot | GROUP BY, SUM |
| Q3 | Active loans | Multi-JOIN, date diff |
| Q4 | Overdue books + estimated fine | WHERE, DATEDIFF |
| Q5 | Most borrowed books | GROUP BY, ORDER BY, LIMIT |
| Q6 | Members with unpaid fines | SUM, HAVING equivalent |
| Q7 | Loans per genre | JOIN × 4, GROUP BY |
| Q8 | Member activity summary | LEFT JOIN, CASE, COALESCE |
| Q9 | Authors with multiple books | HAVING |
| Q10 | Fine revenue report | CASE, GROUP BY |

### 👁️ Views (`views.sql`)
| View | Purpose |
|---|---|
| `vw_book_catalogue` | Joined book + author + genre info |
| `vw_available_books` | Copies ready to be borrowed |
| `vw_active_loans` | Currently unreturned loans |
| `vw_member_stats` | Per-member loan & fine summary |
| `vw_fine_report` | All fines with full context |

### ⚙️ Stored Procedures (`procedures_triggers.sql`)
| Procedure | Description |
|---|---|
| `sp_issue_book(copy_id, member_id, days)` | Issues a copy; rejects if unavailable |
| `sp_return_book(loan_id)` | Records return; auto-calculates fine |
| `sp_member_history(member_id)` | Full loan history for a member |

### ⚡ Triggers
| Trigger | When | Action |
|---|---|---|
| `trg_after_loan_insert` | After new loan | Sets copy `available = FALSE` |
| `trg_after_loan_return` | After loan update | Sets copy `available = TRUE` |

---

## 🚀 How to Run

> **Requires:** MySQL 8.0+

```bash
# 1. Log into MySQL
mysql -u root -p

# 2. Create a new database
CREATE DATABASE library_db;
USE library_db;

# 3. Run files in order
SOURCE schema.sql;
SOURCE seed_data.sql;
SOURCE views.sql;
SOURCE procedures_triggers.sql;

# 4. Run queries
SOURCE queries.sql;
```

Or import them in **MySQL Workbench** one by one in the same order.

---

### Example: Issue a book
```sql
-- Issue copy #2 to member #3 for 14 days
CALL sp_issue_book(2, 3, 14);
```

### Example: Return a book
```sql
-- Return loan #6 (auto-calculates fine if late)
CALL sp_return_book(6);
```

### Example: Check a member's history
```sql
CALL sp_member_history(4);
```

### Example: Use a view
```sql
SELECT * FROM vw_active_loans WHERE days_overdue > 0;
```

---

## 🏗️ SQL Concepts Demonstrated

- ✅ **DDL** — `CREATE TABLE`, `DROP TABLE IF EXISTS`, constraints
- ✅ **DML** — `INSERT`, `UPDATE`
- ✅ **DQL** — Complex `SELECT` with multi-table `JOIN`
- ✅ **Aggregation** — `COUNT`, `SUM`, `GROUP BY`, `HAVING`
- ✅ **Date functions** — `DATEDIFF`, `DATE_ADD`, `CURRENT_DATE`
- ✅ **Conditional logic** — `CASE`, `COALESCE`, `IF`
- ✅ **Views** — Reusable virtual tables
- ✅ **Stored Procedures** — Parameterised business logic with error handling
- ✅ **Triggers** — Automatic side-effects on data change
- ✅ **Foreign Keys** — Referential integrity with `ON DELETE` rules
- ✅ **ENUM** — Constrained column values

---

## 👤 Author

**MasoodXZuba47**  
Built as part of an SQL learning mini-project series.
