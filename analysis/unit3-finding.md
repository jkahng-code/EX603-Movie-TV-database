# Memo: Review of the Spam Withdrawal Dashboard

**To:** Dashboard Team
**From:** Trust and Data Team
**Subject:** The "half of all ratings are spam" result is not supported by the data

The dashboard reported that about half of all ratings end up
withdrawn as spam, and based on that number, reviewer payouts were frozen. We
went back to the underlying data to check this, and the real number is much
lower. Out of 200 ratings, only 12 were withdrawn as spam, which is 6%. Even if
you count every rating that was withdrawn for any reason, including duplicates,
policy violations, and users removing their own ratings, the total is 34, or
17%. We also found that 10 ratings are marked "flagged," which means they are
under review but still live on the site. These are not failures and should not
be counted as one.

The most likely source of the error is how the dashboard handled ratings that
have no withdrawal reason. A reason is only recorded when a rating is
withdrawn, so 166 of the 200 ratings have that field left empty. When we tested
a check that was meant to count every rating that was "not withdrawn as spam,"
it skipped all 166 of those ratings without showing any error. Instead of 188
ratings, it only counted 22. If the dashboard compared the 12 spam ratings
against that much smaller group, the result would come out to roughly half,
which matches what it reported. Because nothing failed or looked broken, the
mistake was easy to miss.

We recommend lifting the freeze on reviewer payouts, since the spam rate the
decision was based on is much higher than what the data actually
shows. We also recommend fixing the dashboard so it includes ratings with no
withdrawal reason, and only counts ratings withdrawn specifically for spam as
failures. Going forward, any number that is used to make a decision like this
should be checked against the raw data before action is taken.