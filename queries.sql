-- ============================================================
--  Library Management System — Core Queries
--  Demonstrates: SELECT, JOIN, subqueries, aggregation,
--                GROUP BY, HAVING, CASE, and more
-- ============================================================

-- ─────────────────────────────────────────────────────────────
--  Q1. Full book catalogue with author & genre
-- ─────────────────────────────────────────────────────────────
SELECT
    b.book_id,
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) AS author,
    g.name                                 AS genre,
    b.published,
    b.pages
FROM   books b
JOIN   authors a ON b.author_id = a.author_id
JOIN   genres  g ON b.genre_id  = g.genre_id
ORDER  BY b.title;


-- ─────────────────────────────────────────────────────────────
--  Q2. Book availability snapshot
-- ─────────────────────────────────────────────────────────────
SELECT
    b.title,
    COUNT(bc.copy_id)                    AS total_copies,
    SUM(bc.available)                    AS available_copies,
    COUNT(bc.copy_id) - SUM(bc.available) AS on_loan
FROM   books b
JOIN   book_copies bc ON b.book_id = bc.book_id
GROUP  BY b.book_id, b.title
ORDER  BY b.title;


-- ─────────────────────────────────────────────────────────────
--  Q3. Active (unreturned) loans — who has what right now
-- ─────────────────────────────────────────────────────────────
SELECT
    l.loan_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member,
    b.title,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURRENT_DATE, l.due_date)     AS days_overdue
FROM   loans l
JOIN   book_copies bc ON l.copy_id   = bc.copy_id
JOIN   books       b  ON bc.book_id  = b.book_id
JOIN   members     m  ON l.member_id = m.member_id
WHERE  l.return_date IS NULL
ORDER  BY days_overdue DESC;


-- ─────────────────────────────────────────────────────────────
--  Q4. Overdue books (due date passed, not returned)
-- ─────────────────────────────────────────────────────────────
SELECT
    l.loan_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member,
    m.email,
    b.title,
    l.due_date,
    DATEDIFF(CURRENT_DATE, l.due_date)     AS days_overdue,
    DATEDIFF(CURRENT_DATE, l.due_date) * 0.50 AS estimated_fine
FROM   loans l
JOIN   book_copies bc ON l.copy_id   = bc.copy_id
JOIN   books       b  ON bc.book_id  = b.book_id
JOIN   members     m  ON l.member_id = m.member_id
WHERE  l.return_date IS NULL
  AND  l.due_date < CURRENT_DATE
ORDER  BY days_overdue DESC;


-- ─────────────────────────────────────────────────────────────
--  Q5. Most borrowed books (all time)
-- ─────────────────────────────────────────────────────────────
SELECT
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) AS author,
    COUNT(l.loan_id)                       AS total_loans
FROM   loans l
JOIN   book_copies bc ON l.copy_id  = bc.copy_id
JOIN   books       b  ON bc.book_id = b.book_id
JOIN   authors     a  ON b.author_id = a.author_id
GROUP  BY b.book_id, b.title, a.first_name, a.last_name
ORDER  BY total_loans DESC
LIMIT  5;


-- ─────────────────────────────────────────────────────────────
--  Q6. Members with unpaid fines
-- ─────────────────────────────────────────────────────────────
SELECT
    CONCAT(m.first_name, ' ', m.last_name) AS member,
    m.email,
    SUM(f.amount)                          AS total_owed
FROM   fines   f
JOIN   loans   l ON f.loan_id   = l.loan_id
JOIN   members m ON l.member_id = m.member_id
WHERE  f.paid = FALSE
GROUP  BY m.member_id, m.first_name, m.last_name, m.email
ORDER  BY total_owed DESC;


-- ─────────────────────────────────────────────────────────────
--  Q7. Books borrowed per genre (popularity by genre)
-- ─────────────────────────────────────────────────────────────
SELECT
    g.name          AS genre,
    COUNT(l.loan_id) AS total_loans
FROM   loans l
JOIN   book_copies bc ON l.copy_id  = bc.copy_id
JOIN   books       b  ON bc.book_id = b.book_id
JOIN   genres      g  ON b.genre_id = g.genre_id
GROUP  BY g.genre_id, g.name
ORDER  BY total_loans DESC;


-- ─────────────────────────────────────────────────────────────
--  Q8. Member activity summary
-- ─────────────────────────────────────────────────────────────
SELECT
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name)    AS member,
    COUNT(l.loan_id)                           AS total_loans,
    SUM(CASE WHEN l.return_date IS NULL THEN 1 ELSE 0 END) AS active_loans,
    COALESCE(SUM(f.amount), 0)                 AS total_fines
FROM   members m
LEFT   JOIN loans l  ON m.member_id = l.member_id
LEFT   JOIN fines f  ON l.loan_id   = f.loan_id
GROUP  BY m.member_id, m.first_name, m.last_name
ORDER  BY total_loans DESC;


-- ─────────────────────────────────────────────────────────────
--  Q9. Authors with more than one book in the library
-- ─────────────────────────────────────────────────────────────
SELECT
    CONCAT(a.first_name, ' ', a.last_name) AS author,
    a.nationality,
    COUNT(b.book_id)                       AS books_in_library
FROM   authors a
JOIN   books   b ON a.author_id = b.author_id
GROUP  BY a.author_id, a.first_name, a.last_name, a.nationality
HAVING COUNT(b.book_id) > 1
ORDER  BY books_in_library DESC;


-- ─────────────────────────────────────────────────────────────
--  Q10. Fine revenue report (paid vs unpaid)
-- ─────────────────────────────────────────────────────────────
SELECT
    CASE WHEN f.paid THEN 'Paid' ELSE 'Unpaid' END AS status,
    COUNT(*)                                        AS fine_count,
    SUM(f.amount)                                   AS total_amount
FROM   fines f
GROUP  BY f.paid;
