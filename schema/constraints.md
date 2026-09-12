# Integrity Constraints

This document lists the constraints enforced on the schema, including every foreign key's `ON DELETE` behavior and its justification.

---

## Primary Keys

- `users.user_id` — PRIMARY KEY
- `movies.movie_id` — PRIMARY KEY
- `ratings.rating_id` — PRIMARY KEY
- `genres.genre_id` — PRIMARY KEY
- `movie_genres (movie_id, genre_id)` — composite PRIMARY KEY

---

## Unique Constraints

**`users.email` — UNIQUE, NOT NULL**
Email is the account's login identifier, distinct from `user_id`. `user_id` is the system's internal reference used by foreign keys; `email` is the business rule enforcing that no two accounts can share a login. Both are unique, but they serve different purposes.

**`ratings (user_id, movie_id)` — UNIQUE**
Enforces that a user may only have one rating per movie. A user can still change their rating later — this is handled as an `UPDATE` to the existing row, not a new `INSERT` — since `rated_at` reflects the most recent update rather than original submission time.

---

## Foreign Keys and ON DELETE Behavior

**`ratings.user_id` → `users.user_id`, ON DELETE CASCADE**
A rating cannot exist without the account that created it — ratings require an account to submit in the first place. Note this only applies to a genuine hard delete of a user row, which is a rare, deliberate action (e.g., a data-erasure request). Normal account closure is handled as a soft delete via `users.is_active`, which leaves existing ratings untouched.

**`ratings.movie_id` → `movies.movie_id`, ON DELETE RESTRICT**
Movies are normally removed from the active catalog via the `is_active` flag (soft delete), not a hard delete. A hard delete of a movie is a rare, deliberate action (e.g., a title pulled for legal reasons or a duplicate catalog entry). `RESTRICT` prevents that hard delete from silently cascading (erasing rating history) or silently orphaning (leaving ratings with no valid movie reference) — it forces whoever performs the deletion to explicitly resolve the movie's existing ratings first.

**`movie_genres.movie_id` → `movies.movie_id`, ON DELETE CASCADE**
A `movie_genres` row has no independent meaning once its movie no longer exists, so it should be removed automatically.

**`movie_genres.genre_id` → `genres.genre_id`, ON DELETE CASCADE**
Same reasoning as above — a genre-movie link is meaningless without both sides present.

---

## Soft Delete Flags

**`users.is_active`** and **`movies.is_active`**
Both actor and producer roles use a soft-delete pattern for their normal removal path, kept consistent across the two roles. This preserves historical data (ratings, aggregates) for records that are deactivated rather than purged, and reserves hard deletion (with its CASCADE/RESTRICT behavior above) for exceptional cases.