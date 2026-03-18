-- ============================================================
--  Library Management System — Schema
--  Author : MasoodXZuba47
--  Date   : 2026-03-18
-- ============================================================

-- Drop existing tables (safe re-run)
DROP TABLE IF EXISTS fines;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS book_copies;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS members;

-- ──────────────────────────────────────────────
--  1. GENRES
-- ──────────────────────────────────────────────
CREATE TABLE genres (
    genre_id   INT          PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- ──────────────────────────────────────────────
--  2. AUTHORS
-- ──────────────────────────────────────────────
CREATE TABLE authors (
    author_id   INT          PRIMARY KEY AUTO_INCREMENT,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    birth_year  YEAR,
    nationality VARCHAR(100)
);

-- ──────────────────────────────────────────────
--  3. BOOKS
-- ──────────────────────────────────────────────
CREATE TABLE books (
    book_id     INT          PRIMARY KEY AUTO_INCREMENT,
    title       VARCHAR(255) NOT NULL,
    isbn        VARCHAR(20)  UNIQUE,
    author_id   INT          NOT NULL,
    genre_id    INT          NOT NULL,
    published   YEAR,
    pages       INT,
    CONSTRAINT fk_books_author FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE,
    CONSTRAINT fk_books_genre  FOREIGN KEY (genre_id)  REFERENCES genres(genre_id)   ON DELETE RESTRICT
);

-- ──────────────────────────────────────────────
--  4. BOOK COPIES  (physical copies in the library)
-- ──────────────────────────────────────────────
CREATE TABLE book_copies (
    copy_id   INT          PRIMARY KEY AUTO_INCREMENT,
    book_id   INT          NOT NULL,
    condition ENUM('New','Good','Fair','Poor') DEFAULT 'Good',
    available BOOLEAN      DEFAULT TRUE,
    CONSTRAINT fk_copies_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- ──────────────────────────────────────────────
--  5. MEMBERS
-- ──────────────────────────────────────────────
CREATE TABLE members (
    member_id    INT          PRIMARY KEY AUTO_INCREMENT,
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(150) UNIQUE NOT NULL,
    phone        VARCHAR(20),
    joined_date  DATE         DEFAULT (CURRENT_DATE),
    is_active    BOOLEAN      DEFAULT TRUE
);

-- ──────────────────────────────────────────────
--  6. LOANS
-- ──────────────────────────────────────────────
CREATE TABLE loans (
    loan_id      INT      PRIMARY KEY AUTO_INCREMENT,
    copy_id      INT      NOT NULL,
    member_id    INT      NOT NULL,
    loan_date    DATE     NOT NULL DEFAULT (CURRENT_DATE),
    due_date     DATE     NOT NULL,
    return_date  DATE,                          -- NULL = still on loan
    CONSTRAINT fk_loans_copy   FOREIGN KEY (copy_id)   REFERENCES book_copies(copy_id) ON DELETE RESTRICT,
    CONSTRAINT fk_loans_member FOREIGN KEY (member_id) REFERENCES members(member_id)   ON DELETE RESTRICT
);

-- ──────────────────────────────────────────────
--  7. FINES
-- ──────────────────────────────────────────────
CREATE TABLE fines (
    fine_id    INT            PRIMARY KEY AUTO_INCREMENT,
    loan_id    INT            NOT NULL UNIQUE,
    amount     DECIMAL(8, 2)  NOT NULL DEFAULT 0.00,
    paid       BOOLEAN        DEFAULT FALSE,
    issued_on  DATE           DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_fines_loan FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE
);
