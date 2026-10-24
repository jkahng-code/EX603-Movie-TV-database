# Unit 4 Analysis: Aggregation

## Task 4.1: Measure the platform

**Who would act on the per-producer breakdown?**
A content or platform operations manager. They would use the per-movie
results to spot movies with unusually low ratings or possible data-quality
problems, and decide which ones need further investigation.

**What the aggregate hides**
An average hides its distribution. Movie 11's average of 2.09 doesn't show
the individual ratings behind it. Some of those ratings may be withdrawn
ones carrying the 0.5 placeholder score rather than real viewer opinions,
which would pull the average down without anyone noticing.

A count hides who is counted. Movie 6's 21 ratings don't tell us how many
are valid and how many were withdrawn, why any were withdrawn (spam,
duplicate, or user request), or whether they came from many different
viewers or a few heavy users.

**What I would need to see next**
For each movie, the number of ratings withdrawn as spam (our definition of
a failure) next to its total rating count, with all withdrawals shown
separately for comparison. That would give each movie an accurate failure
rate and show which producers actually need investigation.


## Task 4.2: Build the breakdown

### Part A: Two numbers in one pass

The conditional aggregation answers two questions side by side, in one pass
over the ratings table:

1. How many ratings did each movie receive?
2. How many of those ratings were spam failures?

The spam rate can also be calculated alongside these counts, showing what
percentage of each movie's ratings were spam failures.

### Part B: Subtotals and a grand total

**Who needs subtotals rather than detail rows:** The regional director. They
are responsible for a whole region, not individual movies, so one summary row
per region shows how their region is doing without requiring them to add up
movie-level rows themselves.

**What decision the grand total supports:** The 6% platform-wide rate gives
leadership a benchmark to compare each region against, showing which regions
are above or below the overall rate. Vietnam is at 10.8%, while the UK is at
2.2%. This helps leadership decide whether to investigate specific regions or
consider a broader platform-wide response. Since the overall rate is only 6%
and failures are concentrated in a few places, a targeted investigation makes
more sense.

### Part C: A two-step pipeline

**The question the pipeline answers:** Among movies with at least 10 ratings,
what is the average spam failure rate across those movies? The answer, 6.1%,
is the baseline that each high-volume movie can be judged against. Movies 2
(18.8%) and 3 (15.4%) sit well above it.

## Reflection

In Part A, I used conditional aggregation to count each movie's total
ratings and spam failures in a single query. The alternative is two
separate filtered queries: one counting all ratings per movie, and another
using WHERE to count only the spam ratings. Conditional aggregation reads
the ratings table once, while the two-query approach reads it twice.

The two-query approach also creates extra work afterward. The results have
to be joined on movie_id to get both counts into one table. Because the
spam query only returns movies that have spam rows, the four movies with
zero spam would be missing from its results. If the join isn't handled
carefully, those movies drop out of the comparison or show up blank
instead of 0.

At a million rows, these differences matter more. Reading the table twice
means twice the I/O (input/output, the work of reading data from disk),
processing time, and server resources, and the cost grows with every
extra condition added. The two queries can also disagree: if new ratings
arrive between them, each query sees a slightly different version of the
data, so the totals and failure counts no longer match. Conditional
aggregation avoids both problems by computing every count from the same
pass over the same data, which makes it faster and more consistent.