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

(to be filled in)

## Task 5.3: Join performance and execution plans

(to be filled in)

## Reflection

(to be filled in)