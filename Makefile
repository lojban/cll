chapters = chapters/*.xml


html: cll_processed.xml
	mkdir -p html
	ln -fs $(PWD)/docbook2html.css html
	xmlto -m docbook2html_config.xsl -o html/ xhtml cll_processed.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'


cll_processed.xml: cll.xml
	xsltproc --nonet --path . --novalid docbook2html_preprocess.xsl cll.xml > cll_processed.xml


cll.xml:
	scripts/merge.sh $(chapters)


.PHONY: web
web: html
	mkdir -p ~/www/media/public/tmp
	rm -rf ~/www/media/public/tmp/docbook-cll-test
	cp -pr html ~/www/media/public/tmp/docbook-cll-test


.PHONY: clean
clean:
	rm -rf cll.xml cll_processed.xml html/
