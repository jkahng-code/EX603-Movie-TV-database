-- 3.3-1 FORM 1: users who wrote at least one rating withdrawn as spam.
--       Requirement: subquery with IN.
--       Finding: 10 users wrote at least one rating withdrawn as spam. The
--       inner query I wrote originally returns 12 rows because it includes
--       duplicates: users 1 and 21 each have two spam ratings. IN only checks
--       whether each user is in the list, not how many times they appear on
--       the list, which is why we get 10.
SELECT user_id, user_name
FROM users
WHERE user_id IN (
    SELECT user_id
    FROM ratings
    WHERE withdrawn_reason = 'Spam detected'
)
ORDER BY user_id;

-- 3.3-2 FORM 2: users who wrote at least one rating withdrawn as spam.
--       Requirement: Common Table Expression (WITH).--
--       Finding: In this query, the CTE (spam_ratings) handles Step 1 by
--       finding who wrote spam ratings, and the outer query handles Step 2
--       by looking up those users. Using a CTE is helpful because it is
--       easier to read and you can run the CTE on its own to check it. I
--       found that Form 2 returns the same 10 users as Form 1.
WITH spam_ratings AS (
    SELECT user_id
    FROM ratings
    WHERE withdrawn_reason = 'Spam detected'
)
SELECT user_id, user_name
FROM users
WHERE user_id IN (SELECT user_id FROM spam_ratings)
ORDER BY user_id;

-- 3.3-3 FORM 3: users who wrote at least one rating withdrawn as spam.
--       Requirement: correlated subquery with EXISTS.
--       Finding: It turns out Form 3 returns the same 10 users as Forms 1
--       and 2, but it gets there differently: EXISTS checks each user
--       individually to see if they have any spam ratings. Since
--       r.user_id = u.user_id ties the inner subquery back to the outer
--       table, it acts as a correlated subquery. It doesn't construct a full
--       list of IDs, but instead tests whether a matching record exists.
SELECT u.user_id, u.user_name
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM ratings r
    WHERE r.user_id = u.user_id
      AND r.withdrawn_reason = 'Spam detected'
)
ORDER BY u.user_id;

-- 3.3-4 PROOF SUMMARY
--      Finding: All four checks returned 0 rows. Checking both directions
--      matters because A EXCEPT B only finds rows missing from B; B EXCEPT A
--      catches anything extra. Since Form 1 matches Form 3 and Form 2 matches
--      Form 1 in both directions, Form 1 (IN subquery), Form 2 (CTE with
--      WITH), and Form 3 (EXISTS subquery) return the exact same 10 users on
--      this dataset.
-- 3.3-4a PROOF: rows in Form 1 that are NOT in Form 3 (expect 0 rows).
--        Requirement: show the rows themselves match.
SELECT user_id, user_name
FROM users
WHERE user_id IN (
    SELECT user_id
    FROM ratings
    WHERE withdrawn_reason = 'Spam detected'
)
EXCEPT
SELECT u.user_id, u.user_name
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM ratings r
    WHERE r.user_id = u.user_id
      AND r.withdrawn_reason = 'Spam detected'
);

-- 3.3-4b PROOF: rows in Form 3 that are NOT in Form 1 (expect 0 rows).
--        Requirement: show the rows themselves match.
SELECT u.user_id, u.user_name
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM ratings r
    WHERE r.user_id = u.user_id
      AND r.withdrawn_reason = 'Spam detected'
)
EXCEPT
SELECT user_id, user_name
FROM users
WHERE user_id IN (SELECT user_id
                  FROM ratings
                  WHERE withdrawn_reason = 'Spam detected');

-- 3.3-4c PROOF: rows in Form 2 that are NOT in Form 1 (expect 0 rows).
--        Requirement: show the rows themselves match.
WITH spam_ratings AS (
    SELECT user_id
    FROM ratings
    WHERE withdrawn_reason = 'Spam detected'
)
SELECT user_id, user_name
FROM users
WHERE user_id IN (SELECT user_id FROM spam_ratings)
EXCEPT
SELECT user_id, user_name
FROM users
WHERE user_id IN (SELECT user_id
                  FROM ratings
                  WHERE withdrawn_reason = 'Spam detected');

-- 3.3-4d PROOF: rows in Form 1 that are NOT in Form 2 (expect 0 rows).
--        Requirement: show the rows themselves match.
WITH spam_ratings AS (
    SELECT user_id
    FROM ratings
    WHERE withdrawn_reason = 'Spam detected'
)
SELECT user_id, user_name
FROM users
WHERE user_id IN (SELECT user_id
                  FROM ratings
                  WHERE withdrawn_reason = 'Spam detected')
EXCEPT
SELECT user_id, user_name
FROM users
WHERE user_id IN (SELECT user_id FROM spam_ratings);

-- 3.3-5 WHEN THE FORMS WOULD NOT BE EQUIVALENT
--       The three forms would not always give the same result if there were
--       NULL values in a NOT IN subquery. For example, if the question was
--       changed to ask for users who have never had a spam rating, Form 1
--       would use NOT IN while Form 3 would use NOT EXISTS. If a spam rating
--       had a NULL user_id, NOT IN would return no rows, because comparing
--       something to NULL results in UNKNOWN. Since the WHERE clause only
--       keeps results that are TRUE, every user would be excluded. NOT EXISTS
--       would still work correctly because a NULL user_id would not match any
--       user. This does not happen with the current data because
--       ratings.user_id is defined as NOT NULL, which is why all three forms
--       give the same result right now.