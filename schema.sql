-- 도서 대여 DB 스키마 (SQLite)
--
-- [테이블 요약]  테이블 | PK | 역할
--   category | id | 도서 분류 (프로그래밍, 소설 ...)
--   member   | id | 대여하는 회원
--   book     | id | 도서 정보, 한 카테고리에 속함
--   rental   | id | "누가 어떤 책을 언제 빌렸는지" 대여 1건의 기록
--
-- [FK 목록 / 1:N 관계]  총 3개
--   book.category_id   → category.id : 카테고리 1개에 도서 여러 권, 도서 1권은 카테고리 1개에만 속함
--   rental.member_id   → member.id   : 회원 1명이 여러 번 대여, 대여 1건의 대여자는 1명
--   rental.book_id     → book.id     : 도서 1권이 시간에 따라 여러 번 대여됨, 대여 1건은 도서 1권
--   (member와 book은 rental을 통해 N:M이 된다. rental이 그 연결 테이블 역할)

-- [SQLite 전용] FK 검사는 기본값이 OFF라서 접속할 때마다 켜야 한다
PRAGMA foreign_keys = ON;

-- 자식 테이블부터 지워야 FK에 걸리지 않는다
DROP TABLE IF EXISTS rental;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS category;

CREATE TABLE category (
    id   INTEGER PRIMARY KEY,              -- 정수 PK: 비교·조인이 빠르고 SQLite에서 자동 증가
    name VARCHAR(50) NOT NULL UNIQUE       -- 같은 이름의 카테고리 중복 방지
);

CREATE TABLE member (
    id        INTEGER PRIMARY KEY,
    name      VARCHAR(50)  NOT NULL,       -- 동명이인이 있을 수 있으므로 UNIQUE 아님
    email     VARCHAR(100) NOT NULL UNIQUE,-- 회원을 실제로 구분하는 값 → UNIQUE
    joined_at DATE         NOT NULL        -- 날짜만 필요(시각 불필요) → DATE, 'YYYY-MM-DD' 형식
);

CREATE TABLE book (
    id             INTEGER PRIMARY KEY,
    category_id    INTEGER      NOT NULL,  -- 분류 없는 책은 허용하지 않음
    title          VARCHAR(200) NOT NULL,
    author         VARCHAR(100) NOT NULL,
    price          INTEGER      NOT NULL CHECK (price >= 0),  -- 원 단위라 소수 불필요 → INTEGER (부동소수 오차 없음)
    published_year INTEGER      NOT NULL,  -- 연도만 비교·정렬하므로 INTEGER
    FOREIGN KEY (category_id) REFERENCES category (id)
);

CREATE TABLE rental (
    id          INTEGER PRIMARY KEY,
    member_id   INTEGER     NOT NULL,
    book_id     INTEGER     NOT NULL,
    rented_at   DATE        NOT NULL,
    due_date    DATE        NOT NULL,      -- 'YYYY-MM-DD' 문자열은 사전순 = 날짜순이라 < > 비교 가능
    returned_at DATE,                      -- NULL이면 아직 반납 안 함
    status      VARCHAR(10) NOT NULL DEFAULT 'RENTED'
                CHECK (status IN ('RENTED', 'RETURNED', 'OVERDUE')),  -- 정해진 값 외 입력 차단
    FOREIGN KEY (member_id) REFERENCES member (id),
    FOREIGN KEY (book_id)   REFERENCES book (id)
);
