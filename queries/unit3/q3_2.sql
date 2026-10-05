-- 3.2A-1 BROKEN: count every rating that was NOT withdrawn as spam.
--        Requirement: inequality predicate on a nullable column.
SELECT COUNT(*) AS not_spam_count
FROM ratings
WHERE withdrawn_reason <> 'Spam detected';

-- 3.2A-2 The opposite: count every rating that WAS withdrawn as spam.
--        Requirement: the complement of the first query.
SELECT COUNT(*) AS spam_count
FROM ratings
WHERE withdrawn_reason = 'Spam detected';

-- 3.2A-3 Both counts next to the table total, to show they do not add up.
--        Requirement: show the two counts do not sum to the table total.
--        Finding: I figured out through my queries that the counts don't
--        add up to 200 (22 + 12 = 34) because not_spam_count and spam_count
--        both silently drop the same 166 NULL rows. Comparing a NULL with
--        = or <> gives UNKNOWN instead of TRUE or FALSE, and WHERE only keeps
--        rows that are TRUE, so the NULL rows are thrown out of both queries.
SELECT
  (SELECT COUNT(*) FROM ratings WHERE withdrawn_reason <> 'Spam detected') AS not_spam_count,
  (SELECT COUNT(*) FROM ratings WHERE withdrawn_reason = 'Spam detected') AS spam_count,
  (SELECT COUNT(*) FROM ratings) AS table_total,
  (SELECT COUNT(*) FROM ratings WHERE withdrawn_reason IS NULL) AS silently_dropped;

-- 3.2A-4 REPAIR: count every rating that was NOT withdrawn as spam,
--        including ratings with no reason at all.
--        Requirement: fix with an explicit IS NULL condition.
--        Finding: To fix the query, I added a second condition to the WHERE
--        clause using OR. The first condition keeps ratings with a reason
--        that isn't spam (22), and OR withdrawn_reason IS NULL brings back
--        the 166 ratings with no reason. Together they return 188, which is
--        every rating except the 12 that were withdrawn as spam.
SELECT COUNT(*) AS not_spam_count_fixed
FROM ratings
WHERE withdrawn_reason <> 'Spam detected'
   OR withdrawn_reason IS NULL;

-- 3.2B-1 BROKEN (this query is supposed to fail): ratings where the
--        person watched more than 0.4 hours.
--        Requirement: alias defined in SELECT and referenced in WHERE.
--        Error (verbatim):
--          [42703] ERROR: column "watch_hours" does not exist
--          Position: 99
--        Finding:WHERE runs before SELECT, so when WHERE looks for watch_hours,
--        the alias hasn't been created yet. That's why PostgreSQL says the column
--        "does not exist."
SELECT rating_id, watch_minutes, ROUND(watch_minutes / 60.0, 2) AS watch_hours
FROM ratings
WHERE watch_hours > 0.4;

-- 3.2B-2 REWRITE 1: repeat the expression in WHERE instead of using the alias.
--        Requirement: fix by repeating the expression.
--        Finding: Because of the order the database runs in, WHERE can't use
--        the watch_hours alias, so I repeated ROUND(watch_minutes / 60.0, 2) in
--        WHERE. This works because it only uses watch_minutes, a real column
--        that exists before SELECT runs, so it doesn't create the error. The
--        query returns 21 ratings above 0.4 hours. The downside is that the
--        calculation is written twice.
SELECT rating_id, watch_minutes, ROUND(watch_minutes / 60.0, 2) AS watch_hours
FROM ratings
WHERE ROUND(watch_minutes / 60.0, 2) > 0.4;

-- 3.2B-3 REWRITE 2: calculate the alias inside a CTE first, so it is a
--        real column by the time the outer WHERE runs.
--        Requirement: fix with a CTE.
--        Finding: In this query, the CTE calculates watch_hours first and names
--        the result rating_hours. The outer query then selects from
--        rating_hours, so WHERE is able to use watch_hours because it's now a
--        real column. It returns the same 21 rows as Rewrite 1, but the
--        calculation is only written once, so there is nothing to keep in sync
--        if I change it later.
WITH rating_hours AS (
  SELECT rating_id, watch_minutes, ROUND(watch_minutes / 60.0, 2) AS watch_hours
  FROM ratings
)
SELECT rating_id, watch_minutes, watch_hours
FROM rating_hours
WHERE watch_hours > 0.4;
