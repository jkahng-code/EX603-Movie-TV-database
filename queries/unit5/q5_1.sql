-- =================================================================
-- EX 603 Assignment 5 — q5_1.sql (Task 5.1: Connect producers to their data)
-- Theme: Movie/TV Ratings Platform
-- Author: Jordan Kahng
-- Target: PostgreSQL
--
-- Roles: actor    = user (users)
--        producer = movie (movies)
--        event    = rating (ratings)
--        catalog  = genre (genres), linked through movie_genres
-- =================================================================

-- 5.1-1 Three-table join: who rated each movie, and when.
--       Requirement: INNER JOIN across three tables.
--       Question: For each rating, which user made it, which movie was
--       it for, and when did it happen?
--       Finding: The three-table join connects ratings to users and
--       movies, so usernames and movie titles appear instead of just ID
--       numbers. The full join returned exactly 200 rows, matching the
--       ratings table, so no ratings were lost or duplicated. The
--       dataset uses placeholder names such as User_01 and Title_01,
--       and some users have rated multiple movies.
SELECT
    r.rating_id,
    u.user_name    AS user_name,
    m.title    AS movie_title,
    r.rated_at    AS rated_at
FROM ratings r
JOIN users  u ON u.user_id = r.user_id
JOIN movies m ON m.movie_id = r.movie_id
ORDER BY r.rated_at
LIMIT 20;

-- 5.1-2a Junction traversal: which genres each movie is tagged with.
--        Requirement: producer → junction → catalog join.
--        Question: Do the movies flagged in Assignment 4 (2 and 3) share
--        a genre with each other or with other movies?
--        Finding: The query returned 25 rows across 12 movies. Movies
--        13, 14, and 15 do not appear because they have no genre tags
--        in the junction table. Movies 2 and 3 share Comedy, while Drama
--        appears on 9 of the 12 movies, making it too common to explain
--        the higher spam rates.
SELECT
    m.movie_id,
    m.title,
    g.genre_name
FROM movies m
JOIN movie_genres mg ON mg.movie_id = m.movie_id
JOIN genres g        ON g.genre_id  = mg.genre_id
ORDER BY m.movie_id, g.genre_name;

-- 5.1-2b Producers associated with one catalog tag: Comedy.
--        Requirement: producer → junction → catalog join, filtered to a tag.
--        Question: Which movies are tagged Comedy, the genre shared by
--        the two Assignment 4 outliers (movies 2 and 3)?
--        Finding: The query returned 5 movies tagged with Comedy: movies 2,
--        3, 5, 10, and 11. Although movies 2 and 3 share this genre and have
--        higher spam counts, the other Comedy movies have zero or only one
--        spam failure. This suggests that Comedy alone does not explain the
--        higher spam rates.
SELECT
    m.movie_id,
    m.title,
    g.genre_name
FROM movies m
JOIN movie_genres mg ON mg.movie_id = m.movie_id
JOIN genres g        ON g.genre_id  = mg.genre_id
WHERE g.genre_name = 'Comedy'
ORDER BY m.movie_id;

-- 5.1-3 Self join: compare each outlier movie with other movies from
--       the same origin country.
--       Requirement: self join on the producer table.
--       Question: Do movies 2 and 3 share a region with other movies,
--       and do those other movies also have spam problems?
--       Finding: The self join compared movies 2 and 3 with other movies
--       from the same origin country. Region does not appear to explain the
--       higher spam rates because their matching movies had only 0 or 1 spam
--       rating each. Release year also does not explain the pattern, since
--       movie 5 was released in 2023 but had no spam ratings. Movies 2 and 3
--       had fewer ratings than some of their peers, which can make a small
--       number of spam ratings have a larger effect on the percentage. However,
--       both movies had multiple spam ratings, suggesting that other factors
--       may be contributing to the outliers.
SELECT
    m1.movie_id      AS outlier_id,
    m1.origin_country,
    m1.release_year  AS outlier_year,
    m2.movie_id      AS similar_id,
    m2.release_year  AS similar_year,
    m2.is_available  AS similar_available
FROM movies m1
JOIN movies m2
  ON m2.origin_country = m1.origin_country
 AND m2.movie_id <> m1.movie_id
WHERE m1.movie_id IN (2, 3)
ORDER BY m1.movie_id, m2.movie_id;