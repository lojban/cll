
So you've made changes that you want to push to the world.
Congratulations!

There are three basic steps to taking what you've done and making it
into an actual official CLL release:

1.  Make everything correct in your own tree, and in particular
    under official/
2.  Make everything correct on github
3.  Releasing the results to the public

Step 1: Finishing Up Your Changes
=================================

The goal here is to finalize everything.  Most of the actual work
here is in the various chunks of the official/ directory, as
explained below.

It is also *VERY IMPORTANT* that you update the CHANGELOG!

DO THAT FIRST!

Updating XHTML official/
------------------------

Run scripts/diff_official (but see the next paragraph first!);
confirm that nothing has changed except what you want to change.

(Note that when the build asks "Would you like to diff the new
output against the last official/ build?", it is running
scripts/diff_official; so if you've already done that, you've done
this step.

scripts/diff_official makes copies of both the relevant build/ dir
and the relevant official/ dir, and massages them to make the output
easier to review.  In particular, it removes all build-time ID
numbers, that otherwise would lead to hundreds of thousands of
apparent changes.

If you have made a complicated change that is hard for a human to
review, but you can simplify the review process with a script, put
that script at scripts/diff_official-special ; if that script
exists, it will be run against every file on *both* sides of the
diff.

As an example, this mini-script finds anything that looks like a
navgiation header and removes any newlines inside it; I used this
when I changed all the nav headers so that each file had ~5 lines of
changes (easy to review) vs. ~30 lines (not so much).

    ruby -e 'puts ARGF.read.encode("UTF-8", "binary", invalid: :replace, undef: :replace, replace: "").gsub(%r{<div[^>]*(navheader|navfooter|toc-link|back-to-info-link).*?</div>}m) { |x| x.gsub(%r{\s+}," ") }' "$@"

When you're satisfied that the changes you made are the changes you
want, put the changes you want is official/ with something like
this:

    $ cp -r build/xhtml_section_chunks official/cll_v1.1_xhtml-section-chunks_2016-05-25
    $ cd official
    $ rm cll_v1.1_xhtml-section-chunks
    $ ln -s cll_v1.1_xhtml-section-chunks_2016-05-25 cll_v1.1_xhtml-section-chunks

(Obviously, update that if we're not on version 1.1 anymore!)

The goal here is to make it so that every currently-relevant
file/directory has a symlink to it, and that that symlink's name
only changes when we change CLL versions.

NOTE: The - and _ in the build/ dir do not match what's in the
official/ dir.  Sorry about that.

Updating EPUB & MOBI official/
------------------------------

We check the EPUB's format with both epubchecker and kindlegen.
Since it's generated from the same xhtml as everything else (more or
less), if it passes all those tests it's probably fine.

However, it's now part of diff_official, too, since it's just a zip.

When done, copy and update symlinks as with XHTML.

Copy and update the MOBI as well; it's generated directly from the
EPUB via kindlegen.

Updating PDF official/
----------------------

Get a PDF diff viewer for your OS and compare them visually.  I'm
using https://github.com/vslavik/diff-pdf on Windows.

When done, copy and update symlinks as with XHTML.

Step 2: Updating github
=======================

The forever home of this data is the docbook-prince branch of https://github.com/lojban/cll/

Before you push, though, there are some things to do.

Make *certain* that everything is done completely (all the work
above, the CHANGELOG, etc).  Commit your changes (ideally in a very
few, very semantically distinct commits).  Rebase from the
docbook-prince branch of https://github.com/lojban/cll/ .  In other
words, get all the usual git ducks in a row.

Then you *MUST* tag your release!

The following is the complete list of tags to make, assuming you
have updated everything and intend to push the result everywhere;
modify as appropriate:

    $ git tag v1.1-[date]-mobi
    $ git tag v1.1-[date]-pdf
    $ git tag v1.1-[date]-html
    $ git tag v1.1-[date]-epub
    $ git tag v1.1-[date]-print

where "date" is the release date, i.e. something like "2017-07-13".
Obviously you can increment the release number too if appropriate.

You will then need to run:

    $ git push --all
    $ git push --tags

and confirm that it worked at https://github.com/lojban/cll/releases
and https://github.com/lojban/cll/commits/docbook-prince

Step 3: Releasing To The World
==============================

Pushing official/ To www.lojban.org
-----------------------------------

In your git directory after you've made official/ look how you want,
the following script will look for any symlinks under official/ and
tar up the symlinks and their referents:

    $ scripts/tar_official

Then check it:

    $ tar -tvf official_cll.tar | less

Then copy it over:

    $ scp official_cll.tar jukni:/tmp/

Then on the webserver (currently (Jun 2016) this is jukni):

    $ sudo -u apache mv /srv/lojban/static/publications/cll /srv/lojban/static/publications/cll.before-$(date +%Y%m%d)
    $ sudo -u apache mkdir /srv/lojban/static/publications/cll
    $ sudo -u apache tar -xvf /tmp/official_cll.tar -C /srv/lojban/static/publications/cll/
    $ ls -lZd /srv/lojban/static/publications/cll
    drwxr-xr-x. 5 apache apache staff_u:object_r:httpd_user_content_t:s0 4096 Aug 27 01:09 /srv/lojban/static/publications/cll/
    $ ls -lZ /srv/lojban/static/publications/cll
    total 16444
    -rw-r--r--. 1 apache apache staff_u:object_r:httpd_user_content_t:s0    3173 Aug 27 01:08 CHANGELOG
    lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      24 Aug 27 00:47 cll_v1.1.epub -> cll_v1.1_2016-08-26.epub
    lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      24 Aug 27 00:54 cll_v1.1.mobi -> cll_v1.1_2016-08-26.mobi
    -rw-r--r--. 1 apache apache staff_u:object_r:httpd_user_content_t:s0  491834 Apr 19 01:12 cll_v1.1_2016-04-13_cover.pdf
    -rw-r--r--. 1 apache apache staff_u:object_r:httpd_user_content_t:s0  369822 Jun 14 01:48 cll_v1.1_2016-06-12_epub-cover.jpg
    -rw-r--r--. 1 apache apache staff_u:object_r:httpd_user_content_t:s0 1661232 Aug 26 19:37 cll_v1.1_2016-08-26.epub
    -rw-r--r--. 1 apache apache staff_u:object_r:httpd_user_content_t:s0 7990646 Aug 26 19:37 cll_v1.1_2016-08-26.mobi
    -rw-r--r--. 1 apache apache staff_u:object_r:httpd_user_content_t:s0 6282332 Aug 26 19:23 cll_v1.1_2016-08-26.pdf
    lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      23 Aug 27 00:53 cll_v1.1_book.pdf -> cll_v1.1_2016-08-26.pdf
    lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      29 May 19 23:52 cll_v1.1_cover.pdf -> cll_v1.1_2016-04-13_cover.pdf
    lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      34 Jun 14 06:12 cll_v1.1_epub-cover.jpg -> cll_v1.1_2016-06-12_epub-cover.jpg
    lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      40 Aug 27 00:49 cll_v1.1_xhtml-chapter-chunks -> cll_v1.1_xhtml-chapter-chunks_2016-08-26/
    drwxr-xr-x. 3 apache apache staff_u:object_r:httpd_user_content_t:s0    4096 Aug 26 18:53 cll_v1.1_xhtml-chapter-chunks_2016-08-26/
    lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      35 Aug 27 00:25 cll_v1.1_xhtml-no-chunks -> cll_v1.1_xhtml-no-chunks_2016-08-26/
    drwxr-xr-x. 3 apache apache staff_u:object_r:httpd_user_content_t:s0    4096 Aug 26 19:11 cll_v1.1_xhtml-no-chunks_2016-08-26/
    lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      40 Aug 27 00:52 cll_v1.1_xhtml-section-chunks -> cll_v1.1_xhtml-section-chunks_2016-08-26/
    drwxr-xr-x. 3 apache apache staff_u:object_r:httpd_user_content_t:s0   20480 Aug 26 19:04 cll_v1.1_xhtml-section-chunks_2016-08-26/

Note that the selinux stuff there is important.

Then confirm that all of the following addresses work:

http://lojban.org/publications/cll/cll_v1.1.epub
http://lojban.org/publications/cll/cll_v1.1_epub-cover.jpg
http://lojban.org/publications/cll/cll_v1.1.mobi
http://lojban.org/publications/cll/cll_v1.1_book.pdf
http://lojban.org/publications/cll/cll_v1.1_cover.pdf
http://lojban.org/publications/cll/cll_v1.1_xhtml-chapter-chunks/
http://lojban.org/publications/cll/cll_v1.1_xhtml-no-chunks/
http://lojban.org/publications/cll/cll_v1.1_xhtml-section-chunks/

(Obviously, update that if we're not on version 1.1 anymore!)

Pushing official/ To Dead Tree Books
------------------------------------

Go to https://myaccount.ingramspark.com/Titles/TitleInfo/CSS1956560
using the LLG's account (Riley or Robin or Bob should have access).

Click "Upload New Files".  Upload the files.

Errors about transparency and color profiles that say "The good news
is that we can correct the file error(s) for you at no charge." can
be ignored (i.e. you should ask Ingram to fix them) (although if you
can figure out how to make the automation *not* cause those errors,
you should totally do that).

When the fixes are done and the version is approved and so on, go
back to the Title Details (same link as above) and update the
Edition Description.

Pushing official/ To Kindle Direct Publishing E-Books
-----------------------------------------------------
Note that this is the *MORE* important of the two e-book
destinations.

Go to https://kdp.amazon.com/en_US/title-setup/kindle/A31M4HTHVJGEWW/details
using the LLG's account (Riley or Robin or Bob should have access).

Update the Edition Number and anything else that seems relevant;
click Save And Continue.

Upload the new files; click Save And Continue.

Update pricing info if needed; click Publish.

Pushing official/ To Ingram Spark E-Books
-----------------------------------------

Note that this is the *LESS* important of the two e-book
destinations.

Go to https://myaccount.ingramspark.com/Titles/TitleInfo/CSS2977442
using the LLG's account (Riley or Robin or Bob should have access).

Click "Upload New Files".  Upload the files.

When the fixes are done and the version is approved and so on, go
back to the Title Details (same link as above) and update the
Edition Description.
