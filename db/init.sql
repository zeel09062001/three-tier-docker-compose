-- ============================================================================
-- Runs automatically ONCE, the first time the MySQL container starts with an
-- empty data volume. It runs inside the database named in MYSQL_DATABASE.
-- ============================================================================

CREATE TABLE IF NOT EXISTS notes (
    id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    title       VARCHAR(200)  NOT NULL,
    content     TEXT          NOT NULL,
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_notes_created_at (created_at)
);

-- A couple of sample notes, so we can see data straight away
INSERT INTO notes (title, content) VALUES
    ('Welcome', 'This note was created by init.sql when the database first started.'),
    ('Three tiers', 'Frontend (Nginx) -> Backend (Python) -> Database (MySQL).');