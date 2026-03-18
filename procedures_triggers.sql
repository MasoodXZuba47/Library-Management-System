-- ============================================================
--  Library Management System — Stored Procedures & Triggers
--  Run AFTER schema.sql and seed_data.sql
-- ============================================================

DELIMITER $$

-- ─────────────────────────────────────────────────────────────
--  PROCEDURE 1: sp_issue_book
--  Issues a book copy to a member and marks it unavailable.
--  Usage: CALL sp_issue_book(copy_id, member_id, due_days);
-- ─────────────────────────────────────────────────────────────
CREATE PROCEDURE sp_issue_book (
    IN  p_copy_id   INT,
    IN  p_member_id INT,
    IN  p_due_days  INT         -- e.g. 14 for a two-week loan
)
BEGIN
    DECLARE v_available BOOLEAN;

    SELECT available INTO v_available
    FROM   book_copies
    WHERE  copy_id = p_copy_id;

    IF v_available = FALSE THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Copy is not available for loan.';
    ELSE
        INSERT INTO loans (copy_id, member_id, loan_date, due_date)
        VALUES (p_copy_id, p_member_id, CURRENT_DATE,
                DATE_ADD(CURRENT_DATE, INTERVAL p_due_days DAY));

        UPDATE book_copies
        SET    available = FALSE
        WHERE  copy_id = p_copy_id;
    END IF;
END $$


-- ─────────────────────────────────────────────────────────────
--  PROCEDURE 2: sp_return_book
--  Records a book return and raises a fine if overdue.
--  Usage: CALL sp_return_book(loan_id);
-- ─────────────────────────────────────────────────────────────
CREATE PROCEDURE sp_return_book (
    IN p_loan_id INT
)
BEGIN
    DECLARE v_copy_id   INT;
    DECLARE v_due_date  DATE;
    DECLARE v_returned  DATE;
    DECLARE v_days_late INT;

    SELECT copy_id, due_date, return_date
    INTO   v_copy_id, v_due_date, v_returned
    FROM   loans
    WHERE  loan_id = p_loan_id;

    IF v_returned IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Book has already been returned.';
    END IF;

    -- Record the return
    UPDATE loans
    SET    return_date = CURRENT_DATE
    WHERE  loan_id = p_loan_id;

    -- Mark copy as available
    UPDATE book_copies
    SET    available = TRUE
    WHERE  copy_id = v_copy_id;

    -- Calculate fine if late ($0.50 per day)
    SET v_days_late = DATEDIFF(CURRENT_DATE, v_due_date);
    IF v_days_late > 0 THEN
        INSERT INTO fines (loan_id, amount, paid, issued_on)
        VALUES (p_loan_id, v_days_late * 0.50, FALSE, CURRENT_DATE);
    END IF;
END $$


-- ─────────────────────────────────────────────────────────────
--  PROCEDURE 3: sp_member_history
--  Shows the full loan history of a member.
--  Usage: CALL sp_member_history(member_id);
-- ─────────────────────────────────────────────────────────────
CREATE PROCEDURE sp_member_history (
    IN p_member_id INT
)
BEGIN
    SELECT
        l.loan_id,
        b.title,
        l.loan_date,
        l.due_date,
        COALESCE(l.return_date, 'Not returned') AS return_date,
        COALESCE(f.amount, 0)                   AS fine_amount,
        CASE WHEN f.paid THEN 'Paid'
             WHEN f.fine_id IS NULL THEN 'N/A'
             ELSE 'Unpaid' END                  AS fine_status
    FROM   loans       l
    JOIN   book_copies bc ON l.copy_id   = bc.copy_id
    JOIN   books       b  ON bc.book_id  = b.book_id
    LEFT   JOIN fines  f  ON l.loan_id   = f.loan_id
    WHERE  l.member_id = p_member_id
    ORDER  BY l.loan_date DESC;
END $$


-- ─────────────────────────────────────────────────────────────
--  TRIGGER 1: trg_after_loan_insert
--  Ensures book_copies.available is FALSE on new loan (safety net).
-- ─────────────────────────────────────────────────────────────
CREATE TRIGGER trg_after_loan_insert
AFTER INSERT ON loans
FOR EACH ROW
BEGIN
    UPDATE book_copies
    SET    available = FALSE
    WHERE  copy_id = NEW.copy_id;
END $$


-- ─────────────────────────────────────────────────────────────
--  TRIGGER 2: trg_after_loan_return
--  Frees the copy automatically when return_date is set.
-- ─────────────────────────────────────────────────────────────
CREATE TRIGGER trg_after_loan_return
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
    IF OLD.return_date IS NULL AND NEW.return_date IS NOT NULL THEN
        UPDATE book_copies
        SET    available = TRUE
        WHERE  copy_id = NEW.copy_id;
    END IF;
END $$

DELIMITER ;
