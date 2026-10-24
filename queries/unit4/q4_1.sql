-- =================================================================
-- EX 603 Assignment 4 — q4_1.sql (Task 4.1: Measure the platform)
-- Theme: Movie/TV Ratings Platform
-- Author: Jordan Kahng
-- Target: PostgreSQL
--
-- Roles: producer = movie (movie_id)
--        actor    = user (user_id)
--        event    = rating (ratings table)
--        metric   = score
-- Failure = a rating withdrawn as spam (withdrawn_reason = 'Spam detected'),
--           the same definition used in the Unit 3 finding.
-- =================================================================

-- 4.1-1 Platform baseline: count, total, average, minimum, and maximum
--       score across every rating, plus how many distinct users rated.
--       Requirement: COUNT, SUM, AVG, MIN, MAX, COUNT(DISTINCT).
--       Question: What does the whole platform look like in one row?
--       Finding: The platform has 200 ratings, and all 30 users have rated
--       at least one movie. The minimum score is 0.5, which is suspicious
--       because it is a placeholder for withdrawn ratings, not a real score.
--       These 34 withdrawn ratings lower the overall average from 3.33
--       for valid ratings (569.3 − 34 × 0.5 = 552.3, divided by 166) to 2.85
--       when the placeholders are included.

SELECT
    COUNT(*) AS total_ratings,
    COUNT(DISTINCT user_id) AS unique_users,
    SUM(score) AS  total_scores,
    ROUND(AVG(score), 2) AS avg_rating,
    MIN(score) AS min_rating,
    MAX(score) AS max_rating
FROM ratings;

-- 4.1-2 Per producer: how many ratings each movie received and its
--       average score, busiest movie first.
--       Requirement: GROUP BY producer, ORDER BY event count DESC.
--       Question: Which movies get the most activity, and how do their
--       average scores compare?
--       Finding: The query returned 13 movies instead of 15 because
--       movies 14 and 15 have no ratings and do not appear in the
--       ratings table. Most movies received between 11 and 21 ratings,
--       while movie 4 had only 6, making its average less representative.
--       Average scores ranged from 2.09 for movie 11 to 3.51 for movie 5.
--       Movie 11 stands out because it has a relatively normal rating
--       count but a low average, which could be affected by withdrawn
--       ratings and should be investigated further.

SELECT
    movie_id,
    COUNT(*) AS rating_count,
    ROUND(AVG(score), 2) AS avg_score
FROM ratings
GROUP BY movie_id
ORDER BY rating_count DESC, movie_id;

-- 4.1-3 Producers with enough ratings for their numbers to mean
--       anything.
--       Requirement: HAVING with a minimum event-count threshold.
--       Question: Which movies have at least 10 ratings, so one or two
--       unusual ratings can't swing their results by a large amount?
--       Threshold reasoning: I chose 10 ratings because the counts drop
--       from 11 to 6, making movie 4 stand out from the others. With
--       10 ratings, one rating represents 10% of the total, compared
--       with about 17% for a movie with only 6 ratings.
--       Finding: The query returned 12 movies with at least 10 ratings
--       and excluded movie 4, which had only 6 ratings. Its average
--       score of 2.28 may be less reliable because each rating has a
--       larger impact on the result.

SELECT
    movie_id,
    COUNT(*) AS rating_count,
    ROUND(AVG(score), 2) AS avg_score
FROM ratings
GROUP BY movie_id
HAVING COUNT(*) >= 10
ORDER BY rating_count DESC, movie_id;

-- 4.1-4 Two dimensions at once: the movie's region by a second
--       dimension.
--       Requirement: GROUP BY two dimensions, including region; one row
--       per combination.
--       Question: How do average rating scores vary between the
--       movie's origin country and the viewer's device country?
--       Finding: The query returned 25 combinations, covering all
--       5 movie regions and 5 viewer regions. The counts add up to
--       200 ratings, matching the platform total. Brazil had the
--       most ratings, with 64 overall. The US-to-US combination had
--       an average of 0.5 from only one rating, which is a withdrawn
--       placeholder rather than a real score. Many combinations have
--       small counts, so their averages may be affected heavily by
--       individual ratings and should be interpreted cautiously.

SELECT
    m.origin_country AS movie_region,
    r.device_country AS viewer_region,
    COUNT(*) AS rating_count,
    ROUND(AVG(r.score), 2) AS avg_score
FROM ratings r JOIN movies m ON m.movie_id = r.movie_id
GROUP BY m.origin_country, r.device_country
ORDER BY movie_region, viewer_region;