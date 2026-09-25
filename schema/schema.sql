-- =================================================================
-- EX 603 Assignment 2 — schema.sql
-- Theme: Movie/TV Ratings Platform
-- Author: Jordan Kahng
-- Target: PostgreSQL 14+
-- =================================================================

-- -----------------------------------------------------------------
-- Reset. Reverse creation order, so no dependency blocks a drop.
-- Creation order is: users, movies, genres, movie_genres, ratings
-- -----------------------------------------------------------------
DROP TABLE IF EXISTS ratings       CASCADE;
DROP TABLE IF EXISTS movie_genres  CASCADE;
DROP TABLE IF EXISTS genres        CASCADE;
DROP TABLE IF EXISTS movies        CASCADE;
DROP TABLE IF EXISTS users         CASCADE;

-- ----------------------------------------------------------------
-- 1. users — first, references nothing.
-- ----------------------------------------------------------------
CREATE TABLE users (
    user_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    email        VARCHAR(255) NOT NULL,
    join_date    DATE         NOT NULL DEFAULT CURRENT_DATE,
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_users_email UNIQUE (email)
);

-- ----------------------------------------------------------------
-- 2. movies — references nothing.
-- ----------------------------------------------------------------
CREATE TABLE movies (
    movie_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title           VARCHAR(255) NOT NULL,
    release_year    INTEGER,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    runtime_minutes INTEGER,
    CONSTRAINT chk_movies_runtime_positive
        CHECK (runtime_minutes IS NULL OR runtime_minutes > 0)
);

-- ----------------------------------------------------------------
-- 3. genres — references nothing.
-- ----------------------------------------------------------------
CREATE TABLE genres (
    genre_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL,
    CONSTRAINT uq_genres_genre_name UNIQUE (genre_name)
);

-- ----------------------------------------------------------------
-- 4. movie_genres — resolves the M:N between movies and genres.
--    The primary key is the pair of foreign keys, not a new id.
-- ----------------------------------------------------------------
CREATE TABLE movie_genres (
    movie_id INTEGER NOT NULL,
    genre_id INTEGER NOT NULL,
    CONSTRAINT pk_movie_genres PRIMARY KEY (movie_id, genre_id),
    CONSTRAINT fk_movie_genres_movie
        FOREIGN KEY (movie_id) REFERENCES movies (movie_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_movie_genres_genre
        FOREIGN KEY (genre_id) REFERENCES genres (genre_id)
        ON DELETE CASCADE
);

-- ----------------------------------------------------------------
-- 5. ratings — references users and movies.
--    Surrogate PK (rating_id); UNIQUE(user_id, movie_id) enforces
--    "one rating per user per movie" and makes a changed rating
--    an UPDATE, not a new INSERT.
-- ----------------------------------------------------------------
CREATE TABLE ratings (
    rating_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id   INTEGER      NOT NULL,
    movie_id  INTEGER      NOT NULL,
    score     NUMERIC(3,1) NOT NULL,
    rated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_ratings_user_movie UNIQUE (user_id, movie_id),
    CONSTRAINT fk_ratings_user
        FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ratings_movie
        FOREIGN KEY (movie_id) REFERENCES movies (movie_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_ratings_score_range
        CHECK (score BETWEEN 1.0 AND 10.0)
);