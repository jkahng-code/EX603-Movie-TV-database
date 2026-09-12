# Schema Definition

This document defines the five relation schemas for the Movie/TV Ratings platform: their attributes, domains, and primary keys.

---

## users (actor)

| Attribute | Domain |
|---|---|
| `user_id` | INTEGER |
| `display_name` | VARCHAR(100) |
| `email` | VARCHAR(255), UNIQUE, NOT NULL |
| `join_date` | DATE |
| `is_active` | BOOLEAN |

**Primary key:** `user_id`

---

## movies (producer)

| Attribute | Domain |
|---|---|
| `movie_id` | INTEGER |
| `title` | VARCHAR(255) |
| `release_year` | INTEGER |
| `is_active` | BOOLEAN |
| `runtime_minutes` | INTEGER |

**Primary key:** `movie_id`

---

## ratings (event)

| Attribute | Domain |
|---|---|
| `rating_id` | INTEGER |
| `user_id` | INTEGER, FOREIGN KEY → users(user_id) |
| `movie_id` | INTEGER, FOREIGN KEY → movies(movie_id) |
| `score` | DECIMAL(3,1), range 1.0–10.0 |
| `rated_at` | TIMESTAMP |

**Primary key:** `rating_id`

**Note:** `rated_at` reflects the most recent update to a rating, not necessarily its original creation time, since a user may change their rating for a movie after submitting it.

---

## genres (catalog)

| Attribute | Domain |
|---|---|
| `genre_id` | INTEGER |
| `genre_name` | VARCHAR(50) |

**Primary key:** `genre_id`

---

## movie_genres (junction)

| Attribute | Domain |
|---|---|
| `movie_id` | INTEGER, FOREIGN KEY → movies(movie_id) |
| `genre_id` | INTEGER, FOREIGN KEY → genres(genre_id) |

**Primary key:** composite (`movie_id`, `genre_id`)