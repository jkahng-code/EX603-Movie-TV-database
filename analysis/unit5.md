# Unit 5 Analysis: Joins

## Task 5.1: Connect producers to their data

**What feature could use the three-table join?**
A user's rating history. It could show the username, movie title, and date
each rating was submitted. This would be useful for users who want to review
their past activity, and for admins who need to look up rating records
without having to work with ID numbers.

**Why is the junction table important for Question 2?**
One movie can have multiple genres, and each genre can belong to multiple
movies. For example, movie 10 has four genres, and the `movie_genres` table
connects it to all four without repeating movie information or adding
separate genre columns. Without the junction table, storing multiple genres
would be harder to query and update. If movies had columns like `genre1`
through `genre4`, finding every Comedy movie would mean checking all four
columns, and a movie with a fifth genre would need a new column. With the
junction table, it's a single filter on the genre name, which is what my
5.1-2b query does. It also keeps the database organized by separating movie
information from genre relationships.

## Task 5.2: Find records that joins may exclude

**Which producers were excluded by the inner join?**
Movies 14 and 15. The LEFT JOIN returned all 15 movies, while the INNER JOIN
returned only 13, so 2 movies were excluded. Both have no matching ratings.

**What does it mean when a producer has no events?**
It means the movie exists in the `movies` table but has never received a
rating. Possible explanations include the movie being recently added,
marked unavailable, difficult for users to find, or simply not attracting
interest. The movies table has `added_on`, `release_year`, and
`is_available` columns that could help narrow this down, but we can't
assume a movie is new or hidden without checking.

**How could a report based only on an inner join give leadership an incomplete picture?**
An INNER JOIN silently removes movies without ratings. Leadership would see
13 movies instead of the full catalog of 15, which makes the platform look
more active than it is, because the movies with zero engagement never appear.
There is no error or warning, so nobody would know anything was missing.
My Unit 4 per-movie query had exactly this gap.

**Why might leadership want to identify producers who have never been active?**
To understand why certain movies receive no engagement and to evaluate
content visibility, availability, and user interest. It also separates two
very different problems: movies that are active but performing poorly (like
movies 2 and 3, with high spam rates) and movies with no activity at all.

**What action could leadership take?**
Investigate movies 14 and 15 to find out why they have no ratings, starting
with whether they are available and visible to users. If they are available
but hard to discover, leadership could improve their placement or promotion,
then monitor whether ratings start coming in.

**What the data shows vs. what needs further investigation**
The data confirms that movies 14 and 15 have zero ratings. The LEFT JOIN,
FULL OUTER JOIN, NOT EXISTS, and EXCEPT queries all agree. The foreign key
also confirms that every existing rating points to a real movie, so there
are no orphaned ratings. What the data doesn't show is *why* these movies
have no ratings. Their availability, release timing, visibility, and user
interest would need further investigation.

## Task 5.3: Join performance and execution plans

**When could a Cartesian product be useful on this platform?**
A Cartesian product could be useful for building a region-by-month reporting
grid. Combining every region with every month creates a row for each
possible combination, even when a region had no ratings in a particular
month, which makes gaps in activity easy to spot instead of leaving those
combinations out. I would not use a CROSS JOIN to find actual movie genres,
though, because the junction table already stores those relationships: the
CROSS JOIN produced all 75 possible movie-genre pairs, while `movie_genres`
holds only the 25 that actually exist.

**Which join algorithms did PostgreSQL choose?**
Two: a **Hash Join** to combine `ratings` with `users`, and a **Nested Loop**
to combine that result with `movies`.

**What information in the plan helps explain those choices?**
For the Hash Join, the plan shows both tables were read with a Seq Scan
(200 ratings and 30 users) and a hash was built from the smaller `users`
table. Since every rating needed its user, building one small lookup table
was cheaper than 200 separate lookups. For the Nested Loop, the plan shows
an `Index Scan using movies_pkey` underneath a `Memoize` step with 13
misses and 187 hits. Only 13 different movies have ratings, so PostgreSQL
did just 13 real index lookups and reused the cached result for the rest.
The plan also shows the planner estimated 100 users but found 30, so its
statistics were slightly out of date, though at this size it made no
difference.

**Why is it useful to understand the selected join algorithms?**
It helps developers and database administrators see how PostgreSQL
retrieves and combines data. As the platform grows, this helps them spot
expensive operations, judge whether an index would improve performance,
and notice when a query plan changes. It also explains why a query that
runs in 0.3 ms on a small dataset might become much slower as more ratings,
users, and movies are added.

**What changes might make another join algorithm more appropriate?**
- **Many more ratings:** the Seq Scan and Sort on `ratings` would grow with
  the table. An index on `rated_at` could let PostgreSQL read the earliest
  ratings directly instead of scanning and sorting everything.
- **Many more users:** the hash built from `users` uses 10 kB of memory
  now. If it outgrew available memory, it would have to be split into
  batches on disk, and other strategies might become cheaper.
- **Many more distinct movies being rated:** Memoize works well because
  only 13 movies repeat. With thousands of different movies, the cache
  would help less, and a Hash Join on movies might become cheaper than
  thousands of individual index lookups.
- **An index on `ratings.user_id`:** this could make a Nested Loop with
  index lookups competitive for the users join, especially when only a
  few users' ratings are needed.
- **Both sides large and already sorted:** if both tables were large and
  sorted or indexed on the join column, a Merge Join could become the best
  choice.

## Reflection

The most surprising thing I learned from the execution plan is that having
an index does not mean PostgreSQL will use it. Both `users` and `movies`
have primary-key indexes, but PostgreSQL only used the index for `movies`.
For `users`, every one of the 200 ratings needed a match, so building one
small hash table was cheaper than doing 200 separate index lookups. That
showed me that the number of records being matched matters as much as
whether an index exists.

I also thought Memoize was interesting. Because only 13 movies have
ratings, PostgreSQL cached each movie lookup and reused it 187 times. If
the platform grew to thousands of different movies being rated, that cache
would help much less, and a Hash Join on `movies` might become the cheaper
option.

The biggest change would come from the ratings table growing. Right now
PostgreSQL reads all 200 ratings and sorts them to find the earliest 20,
which takes a fraction of a millisecond. With millions of ratings, that
scan and sort would become the slowest part of the query. Adding an index
on `rated_at` could let PostgreSQL read the earliest ratings directly
instead. Overall, the planner chooses based on the data it has at the
moment, so as table sizes, indexes, and matching records change, the best
plan can change too.