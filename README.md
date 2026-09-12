# EX603-Movie-TV-database
# Movie / TV Ratings & Analytics Platform

A relational database system designed and implemented in PostgreSQL 18 to model, store, and analyze user engagement, movie catalog metadata, and viewer ratings.

## Author
* **Course:** EX 603 - Relational Databases
* **Theme:** Movie / TV

## System Overview & Domain
This database platform models a streaming/media discovery environment where users discover content, explore categorical genres, and submit numerical ratings for films and television shows. The system tracks user participation, rich media metadata, and high-volume rating events to provide actionable analytics for content managers and recommendation algorithms.

The platform answers critical business questions such as:
* Which movies and genres generate the highest average user engagement and ratings?
* How do individual user rating distributions shift over time across different content categories?
* What are the top-performing titles within specific genre combinations?

## Database Schema (5-Role Architecture)
* **Actor (`users`):** The primary user accounts interacting with the system.
* **Producer (`movies`):** The catalog of media titles being evaluated, containing metadata and activity flags.
* **Event (`ratings`):** The high-volume fact table capturing each individual rating score, user reference, and timestamp.
* **Catalog (`genres`):** Descriptive classification dimensions for media content.
* **Junction (`movie_genres`):** Resolves the many-to-many relationship linking movies to multiple genres.

## Project Structure
```text
ex603-movie-tv-database/
├── README.md
├── schema/          # DDL scripts, ERD diagrams, and constraint documentation
├── queries/         # SQL query scripts organized by unit (unit3, unit4, unit5, unit6)
├── analysis/        # Markdown reflections and analytical writeups
└── screenshots/     # Execution evidence and verification output