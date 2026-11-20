-- =================================================================
-- EX 603 Assignment 6 — q6_3.sql (Task 6.3: Build the reporting patterns)
-- Theme: Movie/TV Ratings Platform
-- Author: Jordan Kahng
-- Target: PostgreSQL
--
-- Roles: producer = movie (movie_id), event = rating, metric = score
-- =================================================================

-- 6.3A Top N per category: the top three ratings by score for each movie.
--      Requirement: a ranking window function partitioned by producer, a
--      CTE that filters to rank <= 3, and FIRST_VALUE().
--      Question: What are each movie's three highest ratings, and how
--      close are they to that movie's best score?
--      Ties at third place: ROW_NUMBER keeps exactly three ratings per
--      movie, even when several share the same score. When scores tie,
--      the earliest rating (by rated_at) ranks higher. A top 3 feature
--      should show three reviews: a popular movie could have thousands
--      of 5.0 ratings, and RANK would return all of them.
--      Finding: The query returned 39 rows, exactly three top ratings
--      for each of the 13 movies. Six movies had 5.0 in all three top
--      spots, and in four of them (movies 5, 7, 8, and 10) there were
--      more than three 5.0 ratings, so ROW_NUMBER kept only the three
--      earliest by rated_at. Movie 5 is the clearest example: it had
--      seven 5.0 ratings, but only the first three made the results.
--      Movies 4 and 11 show a different pattern, with a much larger drop
--      between their highest rating and their second and third highest.
WITH ranked AS (
    SELECT
        movie_id,
        rating_id,
        score,
        rated_at,
        ROW_NUMBER() OVER (PARTITION BY movie_id ORDER BY score DESC, rated_at) AS score_rank,
        FIRST_VALUE(score) OVER (PARTITION BY movie_id ORDER BY score DESC) AS best_score
    FROM ratings
)
SELECT
    movie_id,
    score_rank,
    rating_id,
    score,
    score - best_score AS gap_from_best
FROM ranked
WHERE score_rank <= 3
ORDER BY movie_id, score_rank;

-- 6.3B Period over period: each month's ratings and spam rate compared
--      with the month before.
--      Requirement: events grouped by calendar month (DATE_TRUNC), LAG()
--      over the monthly series, a percent-change column that avoids
--      division by zero (NULLIF), and a check for missing months.
--      Question: Is the platform getting better or worse each month, in
--      rating volume and in spam rate?
--      Finding: The query returned 12 rows, one for each month, and every
--      month passed the missing-month check. Rating volume dropped to 11
--      in March and stayed at 11 in April, before rebounding to 17 in May.
--      The monthly spam rate fluctuated quite a bit because there were
--      only 0-2 spam failures per month, making individual months
--      difficult to compare. However, adding up the monthly rows by
--      quarter shows a gradual decline in the spam rate from 7.5% in Q1
--      to 4.2% in Q4, suggesting a modest improvement over the year,
--      though it rests on only 12 spam ratings in total.
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', rated_at)::date AS month_start,
        COUNT(*) AS total_ratings,
        SUM(CASE WHEN withdrawn_reason = 'Spam detected' THEN 1 ELSE 0 END) AS spam_failures,
        ROUND(100.0 * SUM(CASE WHEN withdrawn_reason = 'Spam detected' THEN 1 ELSE 0 END)
              / COUNT(*), 1) AS spam_rate_pct
    FROM ratings
    GROUP BY DATE_TRUNC('month', rated_at)
)
SELECT
    month_start,
    total_ratings,
    LAG(total_ratings) OVER (ORDER BY month_start) AS prev_ratings,
    ROUND(100.0 * (total_ratings - LAG(total_ratings) OVER (ORDER BY month_start))
          / NULLIF(LAG(total_ratings) OVER (ORDER BY month_start), 0), 1) AS pct_change_ratings,
    spam_failures,
    spam_rate_pct,
    spam_rate_pct - LAG(spam_rate_pct) OVER (ORDER BY month_start) AS spam_rate_change_pts,
    CASE
        WHEN LAG(month_start) OVER (ORDER BY month_start) IS NULL THEN 'first month'
        WHEN LAG(month_start) OVER (ORDER BY month_start)
             = month_start - INTERVAL '1 month' THEN 'ok'
        ELSE 'MISSING MONTH BEFORE THIS'
    END AS month_check
FROM monthly
ORDER BY month_start;

