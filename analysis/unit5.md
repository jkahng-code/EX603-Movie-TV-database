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

(to be filled in)

## Reflection

(to be filled in)