-- 핵심 쿼리 15개 (SQLite, 기준일 2026-11-24)
-- [SQLite 전용]
PRAGMA foreign_keys = ON;

-- ===== 기본 조회 =====

-- Q01: 2021년 이후 출간된 도서를 최신순으로 조회
SELECT id, title, author, published_year
FROM book
WHERE published_year >= 2021
ORDER BY published_year DESC, id;

-- Q02: 가격이 가장 비싼 도서 TOP 5
SELECT title, price
FROM book
ORDER BY price DESC
LIMIT 5;

-- Q03: 제목에 '파이썬'이 들어간 도서 검색
SELECT id, title, author
FROM book
WHERE title LIKE '%파이썬%';

-- Q04: 반납 예정일이 가까운 미반납 대여 기록 3건
SELECT id, book_id, member_id, due_date
FROM rental
WHERE returned_at IS NULL
ORDER BY due_date
LIMIT 3;

-- ===== 조인 =====

-- Q05: [INNER JOIN] 현재 대여 중인 책 목록 (누가, 무엇을, 언제까지)
SELECT m.name AS member_name, b.title, r.rented_at, r.due_date
FROM rental r
JOIN member m ON m.id = r.member_id
JOIN book   b ON b.id = r.book_id
WHERE r.returned_at IS NULL
ORDER BY r.due_date;

-- Q06: [INNER JOIN] 도서와 카테고리 이름을 함께 조회
SELECT b.title, c.name AS category
FROM book b
JOIN category c ON c.id = b.category_id
ORDER BY c.id, b.id;

-- Q07: [INNER JOIN] 최근 30일(2026-10-25 이후) 대여 기록
SELECT r.rented_at, m.name AS member_name, b.title
FROM rental r
JOIN member m ON m.id = r.member_id
JOIN book   b ON b.id = r.book_id
WHERE r.rented_at >= '2026-10-25'
ORDER BY r.rented_at DESC;

-- Q08: [LEFT JOIN] 한 번도 대여되지 않은 도서
SELECT b.id, b.title
FROM book b
LEFT JOIN rental r ON r.book_id = b.id
WHERE r.id IS NULL;

-- ===== 집계 =====

-- Q09: 회원별 대여 횟수 (대여 0회 회원 포함, 많은 순)
SELECT m.name, COUNT(r.id) AS rental_count
FROM member m
LEFT JOIN rental r ON r.member_id = m.id
GROUP BY m.id, m.name
ORDER BY rental_count DESC, m.id;

-- Q10: 카테고리별 도서 수, 가격 합계, 평균 가격 (도서가 있는 카테고리만)
SELECT c.name, COUNT(b.id) AS book_count, SUM(b.price) AS total_price, AVG(b.price) AS avg_price
FROM category c
JOIN book b ON b.category_id = c.id
GROUP BY c.id, c.name
ORDER BY book_count DESC, c.id;

-- Q11: 가장 많이 대여된 도서 TOP 3 (랭킹)
SELECT b.title, COUNT(*) AS rental_count
FROM rental r
JOIN book b ON b.id = r.book_id
GROUP BY b.id, b.title
ORDER BY rental_count DESC, b.id
LIMIT 3;

-- ===== 서브쿼리 =====

-- Q12: 대여 기록이 한 번도 없는 회원
SELECT id, name, joined_at
FROM member
WHERE id NOT IN (SELECT member_id FROM rental);

-- ===== 수정 / 삭제 =====

-- Q13: 반납 예정일이 지났는데 반납하지 않은 대여를 연체(OVERDUE)로 변경
UPDATE rental
SET status = 'OVERDUE'
WHERE returned_at IS NULL
  AND due_date < '2026-11-24';
-- 확인
SELECT id, member_id, due_date, status FROM rental WHERE status = 'OVERDUE';

-- Q14: 대여 기록이 없는 회원(임하은, id=10) 탈퇴 처리
DELETE FROM member
WHERE id = 10;
-- 확인
SELECT COUNT(*) AS member_count FROM member;

-- ===== 인덱스 =====

-- Q15: rental.member_id 인덱스 생성
-- 이유: 회원별 대여 조회/집계(Q05, Q09)에서 JOIN·WHERE 조건으로 자주 쓰이는데, SQLite는 FK 컬럼에 인덱스를 자동으로 만들지 않는다.
CREATE INDEX idx_rental_member_id ON rental (member_id);
-- 확인 [SQLite 전용] 실행 계획에 인덱스 사용 여부 출력
EXPLAIN QUERY PLAN
SELECT * FROM rental WHERE member_id = 1;
