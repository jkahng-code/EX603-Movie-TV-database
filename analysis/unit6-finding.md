# Memo: Is the Spam Problem Getting Better, and What Comes Next

**To:** Leadership Team
**From:** Trust and Data Team
**Subject:** The spam trend across 2023 and our recommendations for next quarter

Four weeks ago, the dashboard reported that about half of all ratings were
spam. We showed that the real rate was 6%, identified which movies
contributed most, and found movies that had never been rated at all. This
memo answers the last question: is the problem getting better or worse, and
what should the team do next quarter?

**The short answer: spam is slowly getting better.**

Looking at each quarter of 2023, the share of ratings withdrawn as spam fell
every quarter: 7.5% in the first quarter, 6.3% in the second, 5.9% in the
third, and 4.2% in the fourth. Over the full year, the rate was 6%, or 12
spam ratings out of 200.

This trend is encouraging, but it should be read carefully. It rests on
only 12 spam ratings, and individual months are too small to judge on their
own. A single spam rating can move a month's rate by several points, which
is why March jumped to 18% and April fell back to 0%. The quarterly view is
the more reliable signal.

Activity itself was steady. The platform collected about 50 ratings each
quarter, reaching that target in two quarters and missing it by just two
ratings in the other two. The improvement in spam is not because the
platform got quieter.

**Spam is still concentrated in a few movies.** Movies 2 and 3 had the
highest spam rates on the platform, at 18.8% and 15.4%, about three times
the overall rate. We checked whether their genre or country explained this,
and it didn't: other movies with the same genre or from the same country had
little or no spam. The issue appears to be the rating activity around these
two movies, not the movies themselves.

**Two movies have still never been rated.** Movies 14 and 15 are in the
catalog but have not received a single rating. This is a different problem
from spam and needs a different response.

**Our recommendations for next quarter**

1. **Keep monitoring spam, and strengthen detection gradually.** The trend
   is moving in the right direction, so we don't recommend major changes
   based on any single month. Instead, track the spam rate each quarter and
   investigate right away if it rises above the platform's 6% average.

2. **Keep reviewing movies 2 and 3.** These remain the biggest sources of
   spam. The team should continue watching new ratings on both movies and
   investigate accounts showing suspicious or repeated behavior.

3. **Check the visibility of movies 14 and 15.** Confirm that both movies
   are available and easy to find. If they are, promote them to encourage
   viewers to watch and rate them.

4. **Start tracking views, not just ratings.** Right now we only know when
   someone submits a rating. We can't tell whether people are ignoring a
   movie, not finding it, or watching it without rating it. Tracking views,
   unique viewers, and the share of viewers who leave a rating would show
   where engagement drops off.

**In short:** keep the current monitoring in place, focus extra attention on
movies 2 and 3, and improve how we measure engagement before making any
larger platform-wide changes.

---

**Where these numbers come from**

| Finding | Query |
|---|---|
| Overall spam rate of 6% (12 of 200) | `queries/unit4/q4_2.sql`, 4.2A and 4.2B |
| Quarterly spam rate: 7.5%, 6.3%, 5.9%, 4.2% | `queries/unit6/q6_3.sql`, 6.3B (monthly results added by quarter) |
| Monthly spam rate swings (March 18.2%, April 0%) | `queries/unit6/q6_3.sql`, 6.3B |
| About 50 ratings per quarter; target met in 2 of 4 quarters | `queries/unit6/q6_2.sql`, 6.2B |
| Movies 2 and 3 at 18.8% and 15.4% | `queries/unit4/q4_2.sql`, 4.2A and 4.2C |
| Genre and country don't explain movies 2 and 3 | `queries/unit5/q5_1.sql`, 5.1-2b and 5.1-3 |
| Movies 14 and 15 have no ratings | `queries/unit5/q5_2.sql`, 5.2A through 5.2C |