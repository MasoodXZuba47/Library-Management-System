-- ============================================================
--  Library Management System — Views
--  Run AFTER schema.sql and seed_data.sql
-- ============================================================

-- ─────────────────────────────────────────────────────────────
--  VIEW 1: vw_book_catalogue
--  Complete book information in one handy view
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_book_catalogue AS
SELECT
    b.book_id,
    b.title,
    b.isbn,
    CONCAT(a.first_name, ' ', a.last_name) AS author,
    a.nationality,
    g.name   AS genre,
    b.published,
    b.pages
FROM   books   b
JOIN   authors a ON b.author_id = a.author_id
JOIN   genres  g ON b.genre_id  = g.genre_id;


-- ─────────────────────────────────────────────────────────────
--  VIEW 2: vw_available_books
--  Only shows books that have at least one available copy
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_available_books AS
SELECT
    bc.copy_id,
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) AS author,
    g.name   AS genre,
    bc.condition
FROM   book_copies bc
JOIN   books   b  ON bc.book_id  = b.book_id
JOIN   authors a  ON b.author_id = a.author_id
JOIN   genres  g  ON b.genre_id  = g.genre_id
WHERE  bc.available = TRUE;


-- ─────────────────────────────────────────────────────────────
--  VIEW 3: vw_active_loans
--  All currently unreturned loans with member & book details
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_active_loans AS
SELECT
    l.loan_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member,
    m.email,
    b.title,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURRENT_DATE, l.due_date)     AS days_overdue
FROM   loans       l
JOIN   book_copies bc ON l.copy_id   = bc.copy_id
JOIN   books       b  ON bc.book_id  = b.book_id
JOIN   members     m  ON l.member_id = m.member_id
WHERE  l.return_date IS NULL;


-- ─────────────────────────────────────────────────────────────
--  VIEW 4: vw_member_stats
--  Quick stats per member: loans, fines, status
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_member_stats AS
SELECT
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name)            AS member,
    m.email,
    COUNT(l.loan_id)                                   AS total_loans,
    SUM(CASE WHEN l.return_date IS NULL THEN 1 ELSE 0 END) AS active_loans,
    COALESCE(SUM(f.amount), 0)                         AS total_fines,
    COALESCE(SUM(CASE WHEN f.paid = FALSE THEN f.amount ELSE 0 END), 0) AS unpaid_fines
FROM   members m
LEFT   JOIN loans l ON m.member_id = l.member_id
LEFT   JOIN fines f ON l.loan_id   = f.loan_id
GROUP  BY m.member_id, m.first_name, m.last_name, m.email;


-- ─────────────────────────────────────────────────────────────
--  VIEW 5: vw_fine_report
--  All fines with member and book info
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_fine_report AS
SELECT
    f.fine_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member,
    m.email,
    b.title,
    l.due_date,
    l.return_date,
    f.amount,
    CASE WHEN f.paid THEN 'Paid' ELSE 'Unpaid' END AS payment_status,
    f.issued_on
FROM   fines       f
JOIN   loans       l  ON f.loan_id   = l.loan_id
JOIN   book_copies bc ON l.copy_id   = bc.copy_id
JOIN   books       b  ON bc.book_id  = b.book_id
JOIN   members     m  ON l.member_id = m.member_id;
