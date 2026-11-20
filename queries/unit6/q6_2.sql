-- =================================================================
-- EX 603 Assignment 6 — q6_2.sql (Task 6.2: Compare each row to its neighbors)
-- Theme: Movie/TV Ratings Platform
-- Author: Jordan Kahng
-- Target: PostgreSQL
--
-- Roles: producer = movie (movie_id), event = rating, metric = score,
--        timestamp = rated_at
-- =================================================================

-- 6.2A Row to row: each rating for movie 2 next to the previous and
--      next rating, in time order, with the change from the previous one.
--      Requirement: LAG() and LEAD() partitioned by producer and ordered
--      by timestamp, a delta column, filtered to one producer.
--      Question: Is movie 2's score trending up or down from one rating
--      to the next, and where are the biggest jumps?
--      Finding: The first rating has a NULL for prev_score because there
--      is no previous rating, and the last rating has a NULL for
--      next_score because there is no following rating. The biggest
--      changes are mostly caused by the 0.5 placeholder scores rather
--      than real changes in viewer opinion. For example, the score drops
--      by 2.9 on December 17 when it goes from 3.4 to 0.5, and rises by
--      2.8 in April when it moves from 0.5 to 3.3. Setting the
--      placeholders aside, the actual ratings from June through August
--      are mostly high, with four scores between 4.0 and 4.9.
SELECT
    rating_id,
    rated_at,
    score,
    LAG(score) OVER (PARTITION BY movie_id ORDER BY rated_at) AS prev_score,
    LEAD(score) OVER (PARTITION BY movie_id ORDER BY rated_at) AS next_score,
    score - LAG(score) OVER (PARTITION BY movie_id ORDER BY rated_at) AS delta
FROM ratings
WHERE movie_id = 2
ORDER BY rated_at;

-- 6.2B Cumulative and smoothed: running totals of ratings (overall and
--      per quarter, against a target) and a 7-row moving average of
--      real scores across the whole platform.
--      Requirement: SUM(...) OVER (... ROWS BETWEEN UNBOUNDED PRECEDING
--      AND CURRENT ROW), AVG(...) OVER (... ROWS BETWEEN n PRECEDING AND
--      CURRENT ROW), and a stated target.
--      Target: 50 ratings per quarter, based on the platform's actual
--      pace of about 50 ratings each quarter in 2023.
--      Question: How close does each quarter's running total get to the
--      50-rating target, and is the recent average score going up or down?
--      Finding: The platform collected 200 ratings by December 28.
--      Against the target of 50 ratings per quarter, it reached the
--      target in Q1 (53 ratings) and Q3 (51 ratings), but fell 2 ratings
--      short in Q2 and Q4 (48 each). Overall activity was fairly
--      consistent throughout the year. The 7-row moving average
--      fluctuated between approximately 2.0 and 4.5, ending at 3.50,
--      without showing a steady upward or downward trend. ROWS counts a
--      specific number of physical rows before the current row, while
--      RANGE includes rows with matching ORDER BY values together. They
--      produce the same results here because the daily CTE groups
--      ratings into one row per date, so there are no duplicate dates.
WITH daily AS (
    SELECT
        rated_at::date AS rating_day,
        COUNT(*)       AS daily_ratings,
        AVG(CASE WHEN rating_status <> 'withdrawn' THEN score END) AS daily_avg_score
    FROM ratings
    GROUP BY rated_at::date
)
SELECT
    rating_day,
    DATE_TRUNC('quarter', rating_day)::date AS quarter_start,
    daily_ratings,
    SUM(daily_ratings) OVER (ORDER BY rating_day
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    SUM(daily_ratings) OVER (PARTITION BY DATE_TRUNC('quarter', rating_day) ORDER BY rating_day
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS qtr_running_total,
    ROUND(100.0 * SUM(daily_ratings) OVER (PARTITION BY DATE_TRUNC('quarter', rating_day) ORDER BY rating_day
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / 50, 1) AS pct_of_qtr_target,
    ROUND(AVG(daily_avg_score) OVER (ORDER BY rating_day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS moving_avg_7
FROM daily
ORDER BY rating_day;

-- 6.2C Where the series stops: movies that went 60+ days without a
--      rating and then started again.
--      Requirement: LAG() comparing adjacent rows, a CTE that computes the
--      gap, and an outer WHERE that keeps only the gaps.
--      Question: Which movies stopped receiving ratings for a long stretch
--      before ratings resumed, and how long was each gap?
--      Threshold: 60 days, more than double the average spacing of about
--      24 days between a movie's ratings.
--      Finding: The query found 11 gaps of 60 or more days across 9
--      movies. Movie 9 had the longest gap at 113 days, while movie 2
--      had an 86-day gap. The steady platform-wide growth of about 50
--      ratings per quarter suggests that ratings continued to be
--      recorded even when individual movies went quiet. Movies with
--      fewer total ratings were more likely to have long gaps, and the
--      four movies with no long gaps (6, 7, 8, and 10) are among the
--      most active, with 19-21 ratings each. This could reflect normal
--      differences in viewer activity rather than data loss. However,
--      the data only shows when ratings were recorded. It does not tell
--      us whether a movie was still available, whether viewers tried to
--      rate it, or why activity stopped.
WITH rating_gaps AS (
    SELECT
        movie_id,
        rating_id,
        LAG(rated_at::date) OVER (PARTITION BY movie_id ORDER BY rated_at) AS prev_rating_day,
        rated_at::date AS rating_day,
        rated_at::date - LAG(rated_at::date) OVER (PARTITION BY movie_id ORDER BY rated_at) AS gap_days
    FROM ratings
)
SELECT movie_id, prev_rating_day, rating_day, gap_days
FROM rating_gaps
WHERE gap_days >= 60
ORDER BY gap_days DESC;