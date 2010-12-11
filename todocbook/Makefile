
web: html/index.html
	cp docbook2html.css html
	rm -rf ~/www/public_media/docbook-cll-test
	cp -pr html ~/www/public_media/docbook-cll-test

html/index.html: cll.xml
	xsltproc --path . --novalid docbook2html_preprocess.xsl cll.xml > cll_postproc.xml
	xmlto -m docbook2html_config.xsl -o html/ html cll_postproc.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'

cll.xml: 1.xml 2.xml 3.xml 4.xml 5.xml 6.xml 7.xml 8.xml 9.xml 10.xml 11.xml 12.xml 13.xml 14.xml 15.xml 16.xml 17.xml 18.xml 19.xml 20.xml 21.xml
	merge.sh

webt: webt.touch
	cp docbook2html.css html
	rm -rf ~/www/public_media/docbook-cll-test
	cp -pr html ~/www/public_media/docbook-cll-test
	touch webt.touch

webt.touch: testing.xml
	xsltproc --path . --novalid docbook2html_preprocess.xsl testing.xml > testing2.xml
	xmlto -m docbook2html_config.xsl -o html/ html testing2.xml

me: testing.xml
	xsltproc --path . --novalid make_examples.xsl testing.xml | \
	  sed -e 's/\(<jbo>\)[0-9.]*)*\s*/\n\1/g' | \
	  sed -e 's/\(<en>\)[0-9.]*)*\s*/\n\1/g' | \
	  sed -e 's/\(<gloss>\)[0-9.]*)*\s*/\n\1/g' | \
	  perl -ple 'my $$rand=qx{makepasswd --chars=4}; chomp($$rand); s/RANDOM/$$rand/g;' | \
	  cat > testing2.xml
