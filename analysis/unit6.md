# Unit 6 Analysis: Window Functions

## Task 6.1: Compute across a window without collapsing

**A question that needs each row next to its group's average**
*Which individual ratings are unusually high or low compared with the
average for that same movie?*

A 0.5 rating stands out more on a movie that averages 3.5 than on one that
averages 2.0. In my query, a 0.5 on movie 5 sits 3.01 points below its
average, while the same score on movie 1 is only 2.25 below. Answering this
needs every individual rating kept, with its movie's average on the same
row, which a window function does. GROUP BY can't answer it, because it
collapses each movie's ratings into one summary row: the average survives,
but the individual ratings you'd compare against it are gone.

**A platform feature that would use the ranking**
A leaderboard of the most active movies, ranked by number of ratings. It
should use `RANK()`. Movies with the same number of ratings should share
the same position, so equally active movies appear as equals. `ROW_NUMBER()`
would place one of two tied movies lower for no reason (movie 7 would rank
5th behind movie 5, even though both have 18 ratings). `DENSE_RANK()`
avoids gaps, but it hides how many movies are actually ahead: it would show
movie 4 as 10th when 12 movies have more ratings. `RANK()` shows both the
tie and the true position.

## Task 6.2: Compare each row to its neighbors

**What would a large delta tell someone, and what should they do about it?**
A large delta means a rating was very different from the previous rating for
the same movie. Before assuming viewers' opinions changed, I would first check
whether either rating was a 0.5 placeholder. In my results, the biggest
changes for movie 2 (−2.9 and +2.8) both involved placeholder scores. If it
is a placeholder, the fix is to exclude withdrawn ratings before analyzing
trends, as I did in Part B. If the ratings are real, a sudden drop could
signal a burst of spam, so the next step would be to check the accounts
behind those ratings, or to look for an unusual event affecting the movie.

**Why does a running total answer a question that a plain SUM can't?**
A plain SUM only tells me the platform collected 200 ratings in total. The
running total shows how those ratings accumulated over time and when the
platform reached each milestone. Resetting it each quarter let me compare
every quarter against the target of 50 ratings: the platform reached the
target in Q1 (53) and Q3 (51) but missed it by two ratings in Q2 and Q4 (48
each). A single total can't show progress or pace.

**Why did I pick a 7-row moving-average window?**
Seven rows balances short-term changes against day-to-day noise. A 2-row
window would react to every individual rating and produce a jumpy line,
while a 50-row window would smooth so much that shorter trends, like the
dips in late March and early June, would disappear. Because ROWS counts
rows rather than days, and many days had no ratings, seven rows covered
about two to three weeks of calendar time in my data.

**What does a gap mean on this platform?**
The gaps most likely reflect a real lull in rating activity rather than a
data quality problem. The platform kept collecting about 50 ratings per
quarter throughout the year, so ratings were still being recorded overall
even while individual movies went quiet. Movies with fewer total ratings
were also more likely to have long gaps, which is what you would expect
when about 15 ratings are spread across a whole year. One limitation is how
events are recorded: the platform only records ratings, not views. A gap in
ratings doesn't prove nobody watched the movie, and the data can't show
whether a movie was unavailable during the gap or whether any attempted
ratings failed.

## Task 6.3: Build the reporting patterns

**What feature would top-N power, and why three?**
A "Top 3 Reviews" section on each movie's page. Three reviews give viewers
more than one opinion, so they get a better sense of how people feel about
the movie. One review might not represent the overall audience, while ten
would take up too much space and make the page harder to browse. Three is a
good balance between showing a range of opinions and keeping the page easy
to use. Using ROW_NUMBER guarantees the section always shows exactly three,
even when a popular movie has many ratings tied at 5.0.

**What would a large month-over-month change mean, and what should someone do?**
A large change could signal a real problem with rating activity or spam,
but the first step is to check the actual counts behind it. Because each
month has only 11-21 ratings and 0-2 spam failures, a single rating can
swing the numbers a lot, so a change is more convincing when it lasts more
than one month or also shows up at the quarterly level.

For March's 47.6% drop in ratings, I would check whether the platform had
fewer active users, a technical issue, or missing rating data. This drop
lasted two months (March and April both had 11 ratings), so it is more
likely to be real. If it is, the team could look at user engagement or
problems with submitting ratings.

For March's 18.2% spam rate, I would check the actual number of spam
failures first: it came from only 2 of 11 ratings, and the rate fell to 0%
in April, so it is more likely noise. If spam were genuinely rising, the
team should investigate the accounts involved and strengthen spam
detection. At the quarterly level, the spam rate fell from 7.5% in Q1 to
4.2% in Q4, which suggests spam was improving overall even though the
monthly numbers were inconsistent.

## Reflection

A reporting question that is easy with a window function but awkward with
GROUP BY alone is: "What are each movie's top three ratings?" This connects
directly to the Top 3 Reviews feature I designed in Task 6.3A, where the goal
is to find the three highest ratings for each movie while keeping the
individual rating records visible.

With only GROUP BY, I could calculate each movie's highest score using
MAX(score), but that collapses all of a movie's ratings into one row. It
only gives the top score, not the second or third, and it doesn't even show
which rating the score came from. Getting the three highest individual
ratings would require extra queries, joins back to the ratings table, or a
subquery that counts how many ratings rank above each one. Ties make it
harder still: for movie 5, MAX returns 5.0, but seven ratings share that
score, and GROUP BY has no way to choose three of them.

ROW_NUMBER() made this much simpler. It kept every rating's details,
numbered them within each movie, and let a CTE keep only the top three. This
mattered in my results because movies 5, 7, 8, and 10 had more than three
5.0 ratings, and I could see exactly which three were selected, using the
earliest rating as the tiebreaker.