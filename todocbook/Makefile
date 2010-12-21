
web: html/index.html
	cp docbook2html.css html/
	rm -rf ~/www/public_media/docbook-cll-test
	cp -pr html ~/www/public_media/docbook-cll-test

html/index.html: cll.xml
	xsltproc --nonet --path . --novalid docbook2html_preprocess.xsl cll.xml > cll_processed.xml
	xmlto -m docbook2html_config.xsl -o html/ xhtml cll_processed.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'

cll.xml: 1.xml 2.xml 3.xml 4.xml 5.xml 6.xml 7.xml 8.xml 9.xml 10.xml 11.xml 12.xml 13.xml 14.xml 15.xml 16.xml 17.xml 18.xml 19.xml 20.xml 21.xml
	merge.sh [0-9]*.xml
