-- =================================================================
-- EX 603 Assignment 4 — q4_2.sql (Task 4.2: Build the breakdown)
-- Theme: Movie/TV Ratings Platform
-- Author: Jordan Kahng
-- Target: PostgreSQL
--
-- Roles: producer = movie (movie_id), event = rating, metric = score
-- Failure = a rating withdrawn as spam (withdrawn_reason = 'Spam detected').
-- Region  = the movie's origin_country.
-- =================================================================

-- 4.2A Two numbers in one pass: for each movie, its total ratings and
--      how many of those were withdrawn as spam.
--      Requirement: CASE inside an aggregate, both totals as separate
--      columns, no WHERE clause filtering the whole query.
--      Question 1: How many ratings did each movie receive?
--      Question 2: How many of those ratings were spam failures?
--      Finding: The platform-wide spam failure rate is 6%, with 12
--      spam ratings out of 200 total ratings. Movies 2 and 3 stand
--      out with 3 and 2 spam failures, and failure rates of 18.8%
--      and 15.4%, respectively. Movie 4 also has a high rate of
--      16.7%, but this comes from only 1 spam rating out of 6, so
--      its rate is less reliable. Movies 1 and 9 are slightly above
--      the platform rate but have only 1 spam failure each. Spam
--      does not fully explain movie 11's low average score, since
--      only 1 of its 16 ratings was marked as spam. Other withdrawn
--      ratings may also affect its average and should be checked.
--      Four movies (5, 8, 10, and 13) had no spam at all, so spam is
--      concentrated in a few movies rather than spread across the platform.

SELECT
    movie_id,
    COUNT(*) AS total_ratings,
    SUM(CASE WHEN withdrawn_reason = 'Spam detected' THEN 1 ELSE 0 END) AS spam_failures,
    ROUND(100.0 * SUM(CASE WHEN withdrawn_reason = 'Spam detected' THEN 1 ELSE 0 END)
          / COUNT(*), 1) AS spam_rate_pct
FROM ratings
GROUP BY movie_id
ORDER BY spam_rate_pct DESC, total_ratings DESC;

-- 4.2B Regional subtotals and a platform grand total, without the
--      per-movie detail rows.
--      Requirement: GROUP BY ROLLUP.
--      Question: How many ratings and spam failures does each region
--      have, and what is the platform-wide total?
--      Which rows are which: The Brazil, India, UK, US, and Vietnam
--      rows are regional subtotals. The ALL REGIONS row is the grand
--      total, identified using GROUPING() to detect the extra row
--      created by ROLLUP.
--      Finding: Vietnam has the highest spam failure rate at 10.8%,
--      compared with the platform-wide rate of 6%. Brazil has the
--      same number of spam failures as Vietnam, with 4, but its rate
--      is lower at 6.3% because it has more ratings overall. The UK
--      has the lowest rate at 2.2%. Vietnam's failures should be
--      investigated further to see whether they are concentrated in
--      one or two movies, as the regional summary does not show which
--      movies contribute to the failures.

SELECT
    CASE WHEN GROUPING(m.origin_country) = 1 THEN 'ALL REGIONS'
        ELSE m.origin_country END AS region,
    COUNT(*) AS total_ratings,
    SUM(CASE WHEN r.withdrawn_reason = 'Spam detected' THEN 1 ELSE 0 END) AS spam_failures,
    ROUND(100.0 * SUM(CASE WHEN r.withdrawn_reason = 'Spam detected' THEN 1 ELSE 0 END)
          / COUNT(*), 1) AS spam_rate_pct
FROM ratings r
JOIN movies m ON m.movie_id = r.movie_id
GROUP BY ROLLUP(m.origin_country)
ORDER BY GROUPING(m.origin_country), region;

-- 4.2C Two-step pipeline: a baseline spam rate for high-volume movies.
--      Requirement: a WITH clause producing an intermediate aggregate,
--      then a second aggregation on that result.
--      Question: Among movies with at least 10 ratings, what is the
--      typical spam rate?
--      Step 1 (movie_stats): one row per movie with its ratings, spam
--      failures, and spam rate.
--      Step 2: keeps only movies with 10+ ratings and averages their
--      spam rates into one baseline number.
--      Finding: The baseline spam rate is 6.1% across the 12 movies
--      with at least 10 ratings. It is slightly different from the
--      platform-wide rate of 6% because the baseline averages each
--      movie's spam rate equally instead of dividing all spam
--      failures by all ratings. Movies 2 and 3 stand out the most,
--      with rates of 18.8% and 15.4%, well above the baseline.
--      These two movies are the strongest candidates for further investigation.

WITH movie_stats AS (
    SELECT
        movie_id,
        COUNT(*) AS total_ratings,
        SUM(CASE WHEN withdrawn_reason = 'Spam detected' THEN 1 ELSE 0 END) AS spam_failures,
        ROUND(100.0 * SUM(CASE WHEN withdrawn_reason = 'Spam detected' THEN 1 ELSE 0 END)
            / COUNT(*), 1) AS spam_rate_pct
    FROM ratings
    GROUP BY movie_id
)
SELECT
    COUNT(*) AS high_volume_movies,
    ROUND(AVG(spam_rate_pct), 1) AS baseline_spam_rate_pct
FROM movie_stats
WHERE total_ratings >= 10;