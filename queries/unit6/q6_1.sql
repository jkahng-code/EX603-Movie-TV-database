-- =================================================================
-- EX 603 Assignment 6 — q6_1.sql (Task 6.1: Compute across a window)
-- Theme: Movie/TV Ratings Platform
-- Author: Jordan Kahng
-- Target: PostgreSQL
--
-- Roles: producer = movie (movie_id), event = rating, metric = score
-- =================================================================

-- 6.1-1a Window version: every rating with its movie's average score
--        on the same row.
--        Requirement: AVG(...) OVER (PARTITION BY ...).
--        Question: Is each rating unusually high or low compared with
--        the other ratings for the same movie?
--        Finding: The query returned 200 rows, keeping every individual
--        rating while displaying its movie's average score. The diff_from_avg
--        column shows how far each rating is from its movie's average. For
--        example, the 0.5 placeholder ratings on movie 5 were −3.01 below its
--        average of 3.51.
SELECT
    rating_id,
    movie_id,
    score,
    ROUND(AVG(score) OVER (PARTITION BY movie_id), 2) AS movie_avg,
    ROUND(score - AVG(score) OVER (PARTITION BY movie_id), 2) AS diff_from_avg
FROM ratings
ORDER BY movie_id, rating_id;

-- 6.1-1b GROUP BY version: one row per movie with its average score.
--        Requirement: GROUP BY comparison to 6.1-1a.
--        Question: What does the same average look like when the rows
--        are collapsed, and what is lost?
--        Finding: The query returned 13 rows, one for each movie, with
--        the same averages as the window function query. However, GROUP
--        BY collapses the individual ratings, making it impossible to see
--        how each rating compares to its movie's average.
SELECT
    movie_id,
    COUNT(*)             AS rating_count,
    ROUND(AVG(score), 2) AS movie_avg
FROM ratings
GROUP BY movie_id
ORDER BY movie_id;

-- 6.1-2 Producer leaderboard: rank movies by rating count with
--       ROW_NUMBER, RANK, and DENSE_RANK side by side.
--       Requirement: all three ranking functions in one query, showing
--       at least one tie.
--       Question: When two movies have the same number of ratings, how
--       does each ranking method decide their positions?
--       Finding: The three ranking functions handle ties differently. For
--       example, movies 5 and 7 both have 18 ratings, so ROW_NUMBER() assigns
--       them different positions (4 and 5), while RANK() and DENSE_RANK()
--       assign both position 4. RANK() skips positions after ties, making
--       movie 4 rank 13th, while DENSE_RANK() has no gaps and ranks it 10th.
SELECT
    movie_id,
    COUNT(*) AS rating_count,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC, movie_id) AS row_num,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_num,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS dense_rank_num
FROM ratings
GROUP BY movie_id
ORDER BY rating_count DESC, movie_id;

-- 6.1-3 Sort movies into four bands by rating count.
--       Requirement: NTILE(4).
--       Question: Which movies fall into the top, middle, and bottom
--       quarters by activity, and what happens to tied movies at a
--       band boundary?
--       Finding: NTILE(4) divides the 13 movies into four groups based on
--       rating count, with group sizes of 4, 3, 3, and 3. Movies 5 and 7
--       (18 ratings each) and movies 2 and 11 (16 ratings each) were split
--       across different bands because NTILE ranks by position rather than
--       accounting for ties. If these bands were used for real decisions,
--       such as deciding which movies receive homepage promotion, equally
--       active movies could receive different treatment simply because of
--       their position in the ranking.
SELECT
    movie_id,
    COUNT(*) AS rating_count,
    NTILE(4) OVER (ORDER BY COUNT(*) DESC, movie_id) AS activity_band
FROM ratings
GROUP BY movie_id
ORDER BY rating_count DESC, movie_id;

