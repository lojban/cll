
Run scripts/diff_official ; confirm that nothing has changed except
what you want to change.

Put the files in official/

Update the symlinks there

On the main lojban webserver:

mkdir /srv/lojban/static/publications/cll/cll_v1.1_2016-04-13
cd /srv/lojban/static/publications/cll/
ln -sf cll_v1.1_2016-04-13 cll_v1.1

Copy the files there.
