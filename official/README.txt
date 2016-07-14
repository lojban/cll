Updating XHTML official/
------------------------

So you've made changes that you want to push to the world.
Congratulations!

Start with:

$ cp CHANGELOG official/

Run scripts/diff_official ; confirm that nothing has changed except
what you want to change.

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

Updating PDF official/
----------------------

Get a PDF diff viewer for your OS and compare them visually.  I'm
using https://github.com/vslavik/diff-pdf on Windows.

When done, copy and update symlinks as with XHTML.

Updating EPUB official/
-----------------------

Uh.

I guess if the PDF and XHTML are correct, the EPUB probably is too?
Review it for obvious errors maybe?

When done, copy and update symlinks as with XHTML.

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
drwxr-xr-x. 5 apache apache staff_u:object_r:httpd_user_content_t:s0 4096 Jun  2 17:06 /srv/lojban/static/publications/cll/
$ ls -lZ /srv/lojban/static/publications/cll
total 7972
lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      24 May 19 23:51 cll_v1.1.epub -> cll_v1.1_2016-04-13.epub
-rw-r--r--. 1 apache apache staff_u:object_r:httpd_user_content_t:s0 1356591 Apr 13 00:10 cll_v1.1_2016-04-13.epub
-rw-r--r--. 1 apache apache staff_u:object_r:httpd_user_content_t:s0 6276968 Apr 12 23:47 cll_v1.1_2016-04-13_book.pdf
-rw-r--r--. 1 apache apache staff_u:object_r:httpd_user_content_t:s0  491834 Apr 19 01:12 cll_v1.1_2016-04-13_cover.pdf
lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      28 May 19 23:52 cll_v1.1_book.pdf -> cll_v1.1_2016-04-13_book.pdf
lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      29 May 19 23:52 cll_v1.1_cover.pdf -> cll_v1.1_2016-04-13_cover.pdf
lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      40 May 28 22:28 cll_v1.1_xhtml-chapter-chunks -> cll_v1.1_xhtml-chapter-chunks_2016-05-25/
drwxr-xr-x. 3 apache apache staff_u:object_r:httpd_user_content_t:s0    4096 May 25 23:47 cll_v1.1_xhtml-chapter-chunks_2016-05-25/
lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      35 May 28 16:27 cll_v1.1_xhtml-no-chunks -> cll_v1.1_xhtml-no-chunks_2016-05-25/
drwxr-xr-x. 3 apache apache staff_u:object_r:httpd_user_content_t:s0    4096 May 26 00:04 cll_v1.1_xhtml-no-chunks_2016-05-25/
lrwxrwxrwx. 1 apache apache staff_u:object_r:httpd_user_content_t:s0      40 May 31 18:52 cll_v1.1_xhtml-section-chunks -> cll_v1.1_xhtml-section-chunks_2016-05-25/
drwxr-xr-x. 3 apache apache staff_u:object_r:httpd_user_content_t:s0   20480 May 31 16:13 cll_v1.1_xhtml-section-chunks_2016-05-25/

Note that the selinux stuff there is important.

Then confirm that all of the following addresses work:

http://lojban.org/publications/cll/cll_v1.1.epub
http://lojban.org/publications/cll/cll_v1.1_epub-cover.jpg
http://lojban.org/publications/cll/cll_v1.1_book.pdf
http://lojban.org/publications/cll/cll_v1.1_cover.pdf
http://lojban.org/publications/cll/cll_v1.1_xhtml-chapter-chunks/
http://lojban.org/publications/cll/cll_v1.1_xhtml-no-chunks/
http://lojban.org/publications/cll/cll_v1.1_xhtml-section-chunks/

(Obviously, update that if we're not on version 1.1 anymore!)

Pushing official/ To Dead Tree Books
------------------------------------

This is UNTESTED because we *just* switched to Ingram Spark.

Go to https://myaccount.ingramspark.com/Titles/TitleInfo/CSS1956560
using the LLG's account (Riley or Robin or Bob should have access).

Click "Upload New Files".  Do the obvious.

Maybe update some of the metadata (such as publication date?) at the
main book page.

Step 3: Profit?

Pushing official/ To E-Books
----------------------------

Go to https://myaccount.ingramspark.com/Titles/TitleInfo/CSS1956560
using the LLG's account (Riley or Robin or Bob should have access).
