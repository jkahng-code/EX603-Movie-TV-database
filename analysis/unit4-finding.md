# Memo: The Real Spam Rate and Where It Comes From

**To:** Leadership Team
**From:** Trust and Data Team
**Subject:** Actual spam failure rate, how it varies by movie, and which movies to investigate

After our last review corrected the dashboard, leadership asked two
follow-up questions: what the actual failure rate is, and which movies
contribute the most to it. We count a rating as a failure when it was
withdrawn as spam, the same definition used in our last memo.

**The true failure rate is 6%.** Out of 200 ratings across the platform,
12 were withdrawn as spam. For the 12 movies with enough ratings to judge
fairly (at least 10 each), the typical movie's spam rate is about the same,
6.1%.

**Spam is concentrated in a few movies, not spread across the platform.**
Four movies had no spam at all, and five had just one spam rating each.
Most of the problem comes from two movies. By region, Vietnam has the
highest rate at 10.8%, but that is mostly one movie: movie 2 accounts for 3
of Vietnam's 4 spam ratings.

**We recommend investigating these movies:**

- **Movie 2:** 3 spam ratings out of 16 (18.8%), about three times the
  platform rate and the highest of any movie with enough ratings to judge.
  It is also the main reason Vietnam's regional rate looks high.
- **Movie 3:** 2 spam ratings out of 13 (15.4%), about two and a half
  times the platform rate. It is the only other movie with more than one
  spam rating.
- **Movie 4 (watch, don't act yet):** its rate looks high at 16.7%, but
  that comes from a single spam rating out of only 6. One more normal
  rating would change the picture a lot, so we suggest monitoring it as
  it gets more ratings rather than drawing conclusions now.

We also noticed that every withdrawn rating carries a placeholder score of
0.5, which pulls some movies' average scores down. Low average scores
should not be read as viewers disliking a movie until those placeholders
are removed from the calculation.