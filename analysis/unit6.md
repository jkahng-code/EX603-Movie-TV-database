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

(to be filled in)

## Task 6.3: Build the reporting patterns

(to be filled in)

## Reflection

(to be filled in)