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