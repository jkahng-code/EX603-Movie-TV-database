-- 3.1a Available movies released after 2015, newest first.
--      Requirement: SELECT, WHERE, ORDER BY, LIMIT.
--      Finding: Only 7 of the 15 movies pass both conditions, so the
--      query returns fewer than 10 rows. Movie 3 was also released after
--      2015, but its is_available is FALSE, so it does not show up, which
--      shows that our filter is working.
SELECT movie_id, title, release_year
FROM movies
WHERE is_available = TRUE
AND release_year > 2015
ORDER BY release_year DESC, title
LIMIT 10;

-- 3.1b Every rating status that exists in the data.
--      Requirement: DISTINCT.
--      Finding: Based on the dashboard story, I was expecting only two
--      statuses: published and withdrawn. When I ran my query, I found an
--      unexpected third status: flagged. A flagged rating is under review
--      but is still on the site and is not a failure. If the dashboard
--      counted everything that isn't published as a failure, flagged
--      ratings would wrongly push the failure rate up.
SELECT DISTINCT rating_status
FROM ratings
ORDER BY rating_status;

-- 3.1c Highly rated ratings: score between 4.0 and 5.0.
--      Requirement: BETWEEN (numeric range).
--      Finding: 70 of the 200 ratings have a high score between 4.0 and
--      5.0. None of them are withdrawn; they are all either published or
--      flagged. Only 4 are flagged, but again we see that flagged ratings
--      don't necessarily mean anything other than that they are under review.
SELECT rating_id, movie_id, score, rating_status
FROM ratings
WHERE score BETWEEN 4.0 AND 5.0
ORDER BY score DESC, rating_id;

-- 3.1c Ratings that are withdrawn or flagged.
--      Requirement: IN (list of values).
--      Finding: There are 34 withdrawn ratings and 10 flagged ratings for a
--      total of 44 rows. The flagged ratings have normal scores ranging from
--      1.2 to 5.0, which again confirms that flagged ratings are just under
--      review. Every withdrawn rating has a score of 0.5, which seems to be a
--      placeholder rather than a real score. Counting both groups, only 22%
--      of the 200 ratings are withdrawn or flagged, which is far from the
--      half that was stated in the dashboard.
SELECT rating_id, movie_id, score, rating_status
FROM ratings
WHERE rating_status IN ('withdrawn', 'flagged')
ORDER BY rating_status, rating_id;

-- 3.1d Movies whose title ends in 5.
--      Requirement: LIKE (text pattern).
--      Finding: 2 of the 15 movies have a title ending in 5: Title_05 and
--      Title_15. I used '%Title__5' to get these results. All the movie
--      titles start with "Title," and each underscore in the pattern matches
--      exactly one character: the first matches the underscore in the
--      title and the second matches the first digit. The pattern then ends
--      with 5, so it catches any movie whose title ends in 5. I realized I
--      could also just use '%5' to get the same result.
SELECT movie_id, title
FROM movies
WHERE title LIKE '%Title__5'
ORDER BY title;

-- 3.1d Ratings with no withdrawal reason (the value is missing / NULL).
--      Requirement: IS NULL.
--      Finding: 166 of the 200 ratings have no withdrawal reason (NULL).
--      That adds up because there are 34 withdrawn ratings (200 - 34 = 166).
--      These values are missing because published and flagged ratings are
--      not withdrawn, so they won't have a withdrawn reason. Only withdrawn
--      ratings get a reason.
SELECT COUNT(*) AS ratings_with_no_reason
FROM ratings
WHERE withdrawn_reason IS NULL;

-- 3.1d Each rating's withdrawal reason, with missing reasons labeled.
--      Requirement: COALESCE.
--      Finding: COALESCE replaces the NULL (missing) reasons with "No reason
--      provided," so published and flagged ratings have a readable label
--      instead of nothing. The data in the table remains the same; only what
--      is displayed changes. We can see that the withdrawn ratings have
--      different reasons, including Spam detected, Duplicate rating, and User
--      request. Not every withdrawn rating is a spam failure, so counting
--      every withdrawal as spam would overstate the failure rate.
SELECT
  rating_id,
  rating_status,
  COALESCE(withdrawn_reason, 'No reason provided') AS reason_label
FROM ratings
ORDER BY rating_id
LIMIT 15;

-- 3.1e Ratings described in plain language: a score category and
--      watch time in hours.
--      Requirement: calculated columns, aliases, CASE.
--      Finding: This query turns scores into plain-language categories and
--      converts watch time from minutes to hours. In my first version, the
--      withdrawn ratings were labeled "Did not like it" because of the 0.5
--      placeholder score, which is incorrect and misleading. I added a WHEN
--      line at the beginning that checks for withdrawn ratings first, so they
--      are labeled "Removed, no real score." This works because CASE stops at
--      the first true condition. Last, all the watch times are under half an
--      hour, so these are either very short movies or the column measures the
--      time watched before giving a rating.
SELECT
  rating_id,
  score,
  CASE
    WHEN rating_status = 'withdrawn' THEN 'Removed, no real score'
    WHEN score >= 3.75 THEN 'Loved it'
    WHEN score >= 2.5 THEN 'It was okay'
    ELSE 'Did not like it'
  END AS score_category,
  watch_minutes,
  ROUND(watch_minutes / 60.0, 2) AS watch_hours
FROM ratings
ORDER BY rating_id
LIMIT 20;