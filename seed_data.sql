-- ============================================================
--  Library Management System — Seed Data
--  Run AFTER schema.sql
-- ============================================================

-- ── GENRES ──────────────────────────────────────────────────
INSERT INTO genres (name, description) VALUES
  ('Fiction',          'Narrative works created from imagination'),
  ('Non-Fiction',      'Factual and informational writing'),
  ('Science Fiction',  'Speculative fiction set in the future or alternate realities'),
  ('Mystery',          'Stories involving puzzling crimes or events'),
  ('Biography',        'Account of a real person''s life'),
  ('Fantasy',          'Fiction involving magic and supernatural elements'),
  ('Self-Help',        'Books focused on personal development'),
  ('History',          'Study of past events'),
  ('Technology',       'Computing, engineering, and applied science'),
  ('Philosophy',       'Fundamental questions about existence and knowledge');

-- ── AUTHORS ─────────────────────────────────────────────────
INSERT INTO authors (first_name, last_name, birth_year, nationality) VALUES
  ('George',    'Orwell',       1903, 'British'),
  ('J.K.',      'Rowling',      1965, 'British'),
  ('Agatha',    'Christie',     1890, 'British'),
  ('Isaac',     'Asimov',       1920, 'American'),
  ('Yuval',     'Harari',       1976, 'Israeli'),
  ('Frank',     'Herbert',      1920, 'American'),
  ('Stephen',   'King',         1947, 'American'),
  ('Malala',    'Yousafzai',    1997, 'Pakistani'),
  ('Walter',    'Isaacson',     1952, 'American'),
  ('Fyodor',    'Dostoevsky',   1821, 'Russian');

-- ── BOOKS ───────────────────────────────────────────────────
INSERT INTO books (title, isbn, author_id, genre_id, published, pages) VALUES
  ('1984',                          '978-0451524935',  1,  1, 1949, 328),
  ('Animal Farm',                   '978-0451526342',  1,  1, 1945, 112),
  ('Harry Potter and the Sorcerer''s Stone', '978-0590353427', 2, 6, 1997, 309),
  ('Harry Potter and the Chamber of Secrets','978-0439064873', 2, 6, 1998, 341),
  ('Murder on the Orient Express',  '978-0062693662',  3,  4, 1934, 256),
  ('And Then There Were None',      '978-0062073488',  3,  4, 1939, 264),
  ('Foundation',                    '978-0553293357',  4,  3, 1951, 255),
  ('I, Robot',                      '978-0553382563',  4,  3, 1950, 224),
  ('Sapiens',                       '978-0062316110',  5,  2, 2011, 443),
  ('Dune',                          '978-0441013593',  6,  3, 1965, 412),
  ('The Shining',                   '978-0385121675',  7,  1, 1977, 447),
  ('I Am Malala',                   '978-0316322409',  8,  5, 2013, 327),
  ('Steve Jobs',                    '978-1451648539',  9,  5, 2011, 630),
  ('The Brothers Karamazov',        '978-0374528379', 10,  1, 1880, 796);

-- ── BOOK COPIES ─────────────────────────────────────────────
INSERT INTO book_copies (book_id, condition, available) VALUES
  (1,  'Good',  TRUE),  (1,  'Fair',  TRUE),
  (2,  'New',   TRUE),
  (3,  'Good',  TRUE),  (3,  'Good',  FALSE),  -- one on loan
  (4,  'Fair',  TRUE),
  (5,  'New',   TRUE),  (5,  'Good',  TRUE),
  (6,  'Fair',  FALSE), -- on loan
  (7,  'Good',  TRUE),
  (8,  'New',   TRUE),
  (9,  'Good',  TRUE),  (9,  'Good',  TRUE),
  (10, 'Poor',  TRUE),
  (11, 'Good',  TRUE),
  (12, 'New',   TRUE),
  (13, 'Good',  FALSE), -- on loan
  (14, 'Fair',  TRUE);

-- ── MEMBERS ─────────────────────────────────────────────────
INSERT INTO members (first_name, last_name, email, phone, joined_date) VALUES
  ('Alice',   'Johnson',  'alice@email.com',   '555-0101', '2024-01-10'),
  ('Bob',     'Smith',    'bob@email.com',     '555-0102', '2024-02-14'),
  ('Carol',   'White',    'carol@email.com',   '555-0103', '2024-03-05'),
  ('David',   'Brown',    'david@email.com',   '555-0104', '2024-04-20'),
  ('Eve',     'Taylor',   'eve@email.com',     '555-0105', '2024-05-18'),
  ('Frank',   'Wilson',   'frank@email.com',   '555-0106', '2024-06-22'),
  ('Grace',   'Moore',    'grace@email.com',   '555-0107', '2024-07-30'),
  ('Henry',   'Anderson', 'henry@email.com',   '555-0108', '2024-08-11'),
  ('Isabelle','Thomas',   'isabelle@email.com','555-0109', '2024-09-03'),
  ('Jack',    'Jackson',  'jack@email.com',    '555-0110', '2024-10-25');

-- ── LOANS ───────────────────────────────────────────────────
INSERT INTO loans (copy_id, member_id, loan_date, due_date, return_date) VALUES
  -- returned on time
  (1,  1, '2025-11-01', '2025-11-15', '2025-11-13'),
  (3,  2, '2025-11-05', '2025-11-19', '2025-11-18'),
  (7,  3, '2025-11-10', '2025-11-24', '2025-11-22'),
  -- returned late (generates fines)
  (5,  4, '2025-12-01', '2025-12-15', '2025-12-20'),  -- 5 days late
  (9,  5, '2025-12-03', '2025-12-17', '2025-12-25'),  -- 8 days late
  -- still on loan (active)
  (6,  6, '2026-03-01', '2026-03-15', NULL),
  (13, 7, '2026-03-05', '2026-03-19', NULL),
  (17, 8, '2026-02-20', '2026-03-06', NULL);           -- overdue

-- ── FINES ───────────────────────────────────────────────────
-- $0.50 per day late
INSERT INTO fines (loan_id, amount, paid, issued_on) VALUES
  (4, 2.50, TRUE,  '2025-12-20'),  -- 5 days × $0.50, paid
  (5, 4.00, FALSE, '2025-12-25');  -- 8 days × $0.50, unpaid
