-- =================================================================
-- EX 603 Assignment 5 — q5_2.sql (Task 5.2: Find records joins may exclude)
-- Theme: Movie/TV Ratings Platform
-- Author: Jordan Kahng
-- Target: PostgreSQL
--
-- Roles: producer = movie (movies), event = rating (ratings)
-- A producer with "no events" = a movie with no rows in ratings.
-- =================================================================

-- 5.2A-1 LEFT JOIN: every movie with its rating count, including
--        movies that have never been rated.
--        Requirement: LEFT JOIN returning all producers.
--        Question: How many ratings does each movie have, counting
--        movies with none as 0?
--        Finding: The LEFT JOIN returned all 15 movies, including movies
--        14 and 15, which had 0 ratings. Using `COUNT(r.rating_id)`
--        instead of `COUNT(*)` was necessary because COUNT on the ratings
--        ID ignores NULL values from unmatched rows, while COUNT(*) would
--        incorrectly count those rows as 1.
SELECT
    m.movie_id,
    m.title,
    COUNT(r.rating_id) AS rating_count
FROM movies m
LEFT JOIN ratings r ON r.movie_id = m.movie_id
GROUP BY m.movie_id, m.title
ORDER BY rating_count, m.movie_id;

-- 5.2A-2 INNER JOIN: the same query, but only movies that have at
--        least one rating.
--        Requirement: equivalent query using INNER JOIN.
--        Question: Which movies remain when only matching rows are kept?
--        Finding: The INNER JOIN returned 13 movies, compared to all 15
--        in the LEFT JOIN results. Movies 14 and 15 disappeared because
--        they have no matching ratings, and an INNER JOIN only keeps rows
--        with matches in both tables.
SELECT
    m.movie_id,
    m.title,
    COUNT(r.rating_id) AS rating_count
FROM movies m
JOIN ratings r ON r.movie_id = m.movie_id
GROUP BY m.movie_id, m.title
ORDER BY rating_count, m.movie_id;

-- 5.2A-3 How many movies the INNER JOIN excludes.
--        Requirement: count of producers excluded by the inner join,
--        counting unique identifiers.
--        Question: How many movies does each join keep, and how many
--        does the INNER JOIN drop?
--        Finding: The LEFT JOIN kept all 15 movies, while the INNER
--        JOIN kept only 13, meaning 2 movies were excluded. Movies 14
--        and 15 were excluded because they have no matching ratings,
--        and counting DISTINCT movie IDs ensures each movie is counted only once.
SELECT
    (SELECT COUNT(DISTINCT m.movie_id)
     FROM movies m LEFT JOIN ratings r ON r.movie_id = m.movie_id) AS left_join_movies,
    (SELECT COUNT(DISTINCT m.movie_id)
     FROM movies m JOIN ratings r ON r.movie_id = m.movie_id)      AS inner_join_movies,
    (SELECT COUNT(DISTINCT m.movie_id)
     FROM movies m LEFT JOIN ratings r ON r.movie_id = m.movie_id)
  - (SELECT COUNT(DISTINCT m.movie_id)
     FROM movies m JOIN ratings r ON r.movie_id = m.movie_id)      AS excluded_by_inner;

-- 5.2B-1 RIGHT JOIN: the same result as 5.2A-1, written with the
--        tables in the opposite order.
--        Requirement: RIGHT JOIN that returns the same records as the
--        LEFT JOIN.
--        Question: Does keeping every movie from the right side give
--        the same 15 rows as the LEFT JOIN?
--        Finding: The RIGHT JOIN returned the same 15 movies and rating
--        counts as the LEFT JOIN. By placing movies on the right side of
--        the RIGHT JOIN, all movies were preserved, including movies 14
--        and 15, which had 0 ratings.
SELECT
    m.movie_id,
    m.title,
    COUNT(r.rating_id) AS rating_count
FROM ratings r
RIGHT JOIN movies m ON r.movie_id = m.movie_id
GROUP BY m.movie_id, m.title
ORDER BY rating_count, m.movie_id;

-- 5.2B-2 PROOF: the LEFT JOIN and RIGHT JOIN return identical rows.
--        Requirement: verify the results match rather than assuming.
--        Question: Are there any rows in one result that are missing
--        from the other? (Expect 0 rows.)
--        Finding: The comparison returned 0 rows, proving that the LEFT
--        JOIN and RIGHT JOIN produced identical results. I checked both
--        directions because using EXCEPT only once would show rows missing
--        from one result but would not catch rows that were missing from the other.
(
  SELECT m.movie_id, COUNT(r.rating_id) AS rating_count
  FROM movies m LEFT JOIN ratings r ON r.movie_id = m.movie_id
  GROUP BY m.movie_id
  EXCEPT
  SELECT m.movie_id, COUNT(r.rating_id)
  FROM ratings r RIGHT JOIN movies m ON r.movie_id = m.movie_id
  GROUP BY m.movie_id
)
UNION ALL
(
  SELECT m.movie_id, COUNT(r.rating_id)
  FROM ratings r RIGHT JOIN movies m ON r.movie_id = m.movie_id
  GROUP BY m.movie_id
  EXCEPT
  SELECT m.movie_id, COUNT(r.rating_id) AS rating_count
  FROM movies m LEFT JOIN ratings r ON r.movie_id = m.movie_id
  GROUP BY m.movie_id
);

-- 5.2B-3 FULL OUTER JOIN: matched and unmatched rows from both tables.
--        Requirement: FULL OUTER JOIN including unmatched records from
--        both sides.
--        Question: How many rating rows match a movie, how many movies
--        have no ratings, and are there any ratings with no movie?
--        Finding: The FULL OUTER JOIN returned 202 total rows, including
--        200 matched ratings, 2 movies without ratings, and 0 ratings
--        without a matching movie. The 0 unmatched ratings result is
--        expected because the foreign key on `ratings.movie_id` ensures
--        every rating references an existing movie.
SELECT
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN m.movie_id IS NOT NULL AND r.rating_id IS NOT NULL THEN 1 END) AS matched,
    COUNT(CASE WHEN r.rating_id IS NULL THEN 1 END) AS movies_without_ratings,
    COUNT(CASE WHEN m.movie_id  IS NULL THEN 1 END) AS ratings_without_movie
FROM movies m
FULL OUTER JOIN ratings r ON r.movie_id = m.movie_id;

-- 5.2C-1 NOT EXISTS: movies that have never been rated.
--        Requirement: anti-join with NOT EXISTS.
--        Question: Which movies have no ratings at all?
--        Finding: The NOT EXISTS query returned movies 14
--        and 15, which have never received any ratings.
--        It checks each movie for a matching record in the
--        ratings table and only keeps movies when no matching rating exists.
SELECT m.movie_id, m.title
FROM movies m
WHERE NOT EXISTS (
    SELECT 1
    FROM ratings r
    WHERE r.movie_id = m.movie_id
)
ORDER BY m.movie_id;

-- 5.2C-2 EXCEPT: movies that have never been rated.
--        Requirement: set difference with EXCEPT.
--        Question: Which movie IDs are in the movies table but never
--        appear in the ratings table?
--        Finding: The EXCEPT query also returned movie IDs 14 and 15
--        by subtracting the movie IDs in the ratings table from all
--        movie IDs. Unlike NOT EXISTS, which checks for matching ratings
--        for each movie and can return additional columns such as titles,
--        EXCEPT compares two result sets with matching columns. Both
--        approaches identified the same two movies.
SELECT movie_id FROM movies
EXCEPT
SELECT movie_id FROM ratings
ORDER BY movie_id;