-- 도서 대여 DB 스키마 (SQLite)
-- 관계: category 1:N book, member 1:N rental, book 1:N rental

-- [SQLite 전용] FK 검사는 기본값이 OFF라서 접속할 때마다 켜야 한다
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS rental;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS category;

CREATE TABLE category (
    id   INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE member (
    id        INTEGER PRIMARY KEY,
    name      VARCHAR(50)  NOT NULL,
    email     VARCHAR(100) NOT NULL UNIQUE,
    joined_at DATE         NOT NULL
);

CREATE TABLE book (
    id             INTEGER PRIMARY KEY,
    category_id    INTEGER      NOT NULL,
    title          VARCHAR(200) NOT NULL,
    author         VARCHAR(100) NOT NULL,
    price          INTEGER      NOT NULL CHECK (price >= 0),
    published_year INTEGER      NOT NULL,
    FOREIGN KEY (category_id) REFERENCES category (id)
);

CREATE TABLE rental (
    id          INTEGER PRIMARY KEY,
    member_id   INTEGER     NOT NULL,
    book_id     INTEGER     NOT NULL,
    rented_at   DATE        NOT NULL,
    due_date    DATE        NOT NULL,
    returned_at DATE,                      -- NULL이면 아직 반납 안 함
    status      VARCHAR(10) NOT NULL DEFAULT 'RENTED'
                CHECK (status IN ('RENTED', 'RETURNED', 'OVERDUE')),
    FOREIGN KEY (member_id) REFERENCES member (id),
    FOREIGN KEY (book_id)   REFERENCES book (id)
);
