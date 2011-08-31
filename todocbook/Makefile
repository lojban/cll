
web: html/index.html
	cp docbook2html.css html/
	mkdir -p ~/www/media/public/tmp
	rm -rf ~/www/media/public/tmp/docbook-cll-test
	cp -pr html ~/www/media/public/tmp/docbook-cll-test

#web-nochunks: html-nochunks/index.html
#	cp docbook2html.css html-nochunks/
#	mkdir -p ~/www/media/public/tmp
#	rm -rf ~/www/media/public/tmp/docbook-cll-test-nochunks
#	cp -pr html ~/www/media/public/tmp/docbook-cll-test-nochunks

html/index.html: cll_processed.xml
	mkdir -p html
	xmlto -m docbook2html_config.xsl -o html/ xhtml cll_processed.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'

#html-nochunks/index.html: cll_processed.xml
#	mkdir -p html-nochunks
#	xmlto -m docbook2html_config.xsl -o html/ xhtml-nochunks cll_processed.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'

cll_processed.xml: cll.xml
	xsltproc --nonet --path . --novalid docbook2html_preprocess.xsl cll.xml > cll_processed.xml

cll.xml: 1.xml 2.xml 3.xml 4.xml 5.xml 6.xml 7.xml 8.xml 9.xml 10.xml 11.xml 12.xml 13.xml 14.xml 15.xml 16.xml 17.xml 18.xml 19.xml 20.xml 21.xml merge.sh
	./merge.sh [0-9].xml 1[0-9].xml 2[0-9].xml

clean:
	rm -rf cll.xml cll_processed.xml cll_preglossary.xml jbovlaste.xml jbovlaste2.xml html/
