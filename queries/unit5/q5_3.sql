-- =================================================================
-- EX 603 Assignment 5 — q5_3.sql (Task 5.3: Join performance and plans)
-- Theme: Movie/TV Ratings Platform
-- Author: Jordan Kahng
-- Target: PostgreSQL
-- =================================================================

-- 5.3A-1 CROSS JOIN: every possible movie-and-genre pairing.
--        Requirement: CROSS JOIN between two small tables.
--        Question: What does the full set of movie-genre combinations
--        look like when nothing is matched?
--        Finding: The CROSS JOIN produced all 75 possible movie-genre
--        combinations without matching movies to their actual genres.
--        This is different from the junction table query in 5.1, which
--        returned only 25 actual movie-genre relationships.
SELECT
    m.movie_id,
    m.title,
    g.genre_name
FROM movies m
CROSS JOIN genres g
ORDER BY m.movie_id, g.genre_name;

-- 5.3A-2 Row counts: the CROSS JOIN equals movies × genres.
--        Requirement: count each source table and the CROSS JOIN result.
--        Question: Does the number of combined rows equal the two table
--        sizes multiplied together?
--        Finding: The movies table contained 15 rows and the genres table
--        contained 5 rows, giving an expected product of 75 rows. The CROSS
--        JOIN also returned 75 rows, confirming that it pairs every movie with
--        every genre (15 × 5 = 75).
SELECT
    (SELECT COUNT(*) FROM movies)                         AS movie_rows,
    (SELECT COUNT(*) FROM genres)                         AS genre_rows,
    (SELECT COUNT(*) FROM movies)
      * (SELECT COUNT(*) FROM genres)                     AS expected_product,
    (SELECT COUNT(*) FROM movies CROSS JOIN genres)       AS cross_join_rows;

-- 5.3B-1 Execution plan for the three-table join from 5.1-1.
--        Requirement: EXPLAIN on the three-table join.
--        Question: Which join algorithms does PostgreSQL choose for
--        ratings → users → movies, and why?
--        Plan reading: PostgreSQL used two join algorithms. First, a
--        Hash Join between ratings and users: both tables were read with
--        a Seq Scan, and a hash lookup was built from the smaller users
--        table (30 rows). Second, a Nested Loop joined that result to
--        movies, using an Index Scan on movies_pkey. A Memoize cache
--        meant only 13 real movie lookups (13 misses, 187 hits), since
--        only 13 movies have ratings. A top-N heapsort then kept the 20
--        earliest ratings. Total execution time: about 0.3 ms. The
--        planner estimated 100 users but found 30, so its statistics
--        were slightly out of date. As ratings grows, the Seq Scan and
--        Sort on ratings would slow down first; an index on rated_at
--        could let PostgreSQL read the earliest ratings directly.
EXPLAIN ANALYZE
SELECT
    r.rating_id,
    u.user_name,
    m.title    AS movie_title,
    r.rated_at
FROM ratings r
JOIN users  u ON u.user_id  = r.user_id
JOIN movies m ON m.movie_id = r.movie_id
ORDER BY r.rated_at
LIMIT 20;