# Unit 2: Constraints and Schema Reasoning

## Foreign Key Constraints

| Foreign Key | ON DELETE | Reason |
|---|---|---|
| `ratings.user_id → users.user_id` | CASCADE | A rating can't exist without the user who made it, so if a user is permanently deleted, their ratings should go too. |
| `ratings.movie_id → movies.movie_id` | RESTRICT | Movies aren't supposed to be permanently deleted (that's what `is_active` is for), so if someone tries anyway, the database should stop them until the ratings are dealt with. |
| `movie_genres.movie_id → movies.movie_id` | CASCADE | A genre tag doesn't mean anything once the movie it's attached to is gone. |
| `movie_genres.genre_id → genres.genre_id` | CASCADE | Same idea — the link doesn't mean anything once the genre it's attached to is gone. |

### `ratings.user_id → users.user_id`: ON DELETE CASCADE

This only matters for an actual permanent delete of a user, like if someone requested their data to be erased. Normal account closure doesn't touch this at all, that's handled by flipping `users.is_active` to false, and the ratings stay exactly as they are.

But if a user row really does get deleted, every rating they made gets deleted along with it. That makes sense because a rating without a user attached to it doesn't really mean anything. You can't have a rating that nobody made. I thought about using RESTRICT instead, but that would just mean someone has to go delete all of that user's ratings by hand before they could even delete the user, which felt like extra work for no real benefit, since those ratings aren't useful to keep once the person who made them is gone for good.

### `ratings.movie_id → movies.movie_id`: ON DELETE RESTRICT

This one is about permanently deleting a movie, which again should be rare because normally a movie just gets marked inactive instead. So this only kicks in if someone tries to hard-delete a movie that still has ratings on it.

I went with RESTRICT here because I didn't want that delete to be able to happen quietly. If I used CASCADE, deleting one movie row could wipe out a ton of rating history without any warning. If I used SET NULL, the ratings would stick around but point at a movie that doesn't exist anymore, which seems even more confusing than just blocking the delete. RESTRICT basically forces whoever's doing the deleting to stop and deal with the ratings first, instead of losing data by accident.

### `movie_genres.movie_id → movies.movie_id` and `movie_genres.genre_id → genres.genre_id`: ON DELETE CASCADE

This table only exists to connect a movie to a genre, so a row in it doesn't mean anything by itself. If the movie gets deleted, or the genre gets deleted, that link should just go away automatically. There's no reason to keep a row around that's pointing at something that no longer exists.

I used CASCADE on both sides for this one because there's nothing really being lost. `movie_genres` doesn't store any extra info of its own, like a timestamp or a note. It's just the connection, so there's no downside to letting it disappear along with whichever side it was connected to.

## CHECK Constraints

### `chk_ratings_score_range`

```sql
CHECK (score BETWEEN 1.0 AND 10.0)
```

This stops a rating from being saved with a score outside 1.0–10.0, like a 0 or an 11. Without it, something like a bug in the front end, someone hitting the API directly instead of going through the app, or a messy data import could let a bad score slip through. Putting the check in the database itself means it gets caught no matter how the bad data was trying to get in, instead of relying on the app to always catch it first.

### `chk_movies_runtime_positive`

```sql
CHECK (runtime_minutes IS NULL OR runtime_minutes > 0)
```

This stops a movie from being saved with a runtime of 0 or a negative number, but it still lets `runtime_minutes` be left blank if we just don't have that info yet. A negative or zero runtime doesn't make sense in real life, and it would probably only happen from a typo or an import script defaulting missing values to 0 instead of just leaving them empty. I wanted to keep "we don't know the runtime yet" and "the runtime is wrong" as two different things, so `NULL` is still allowed but 0 and negative numbers aren't.