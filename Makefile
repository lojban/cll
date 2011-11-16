chapters = chapters/{1..21}.xml

.PHONY: all
all: web

.PHONY: clean
clean:
	-rm -rf cll.xml cll_processed.xml cll_preglossary.xml html/ jbovlaste.xml jbovlaste2.xml
	-rm -rf cll_test.xml cll_processed_test.xml html_test/

.PHONY: web
web: html
	mkdir -p ~/www/media/public/tmp
	rm -rf ~/www/media/public/tmp/docbook-cll-test
	cp -pr html ~/www/media/public/tmp/docbook-cll-test

html: cll_processed.xml
	mkdir -p html
	ln -fs $(PWD)/docbook2html.css html
	xmlto -m xml/docbook2html_config.xsl -o html/ xhtml cll_processed.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'

cll_processed.xml: cll.xml
	xsltproc --nonet --path . --novalid xml/docbook2html_preprocess.xsl cll.xml > cll_processed.xml

cll.xml:
	scripts/merge.sh $(chapters)

.PHONY: test
test: html_test
	mkdir -p ~/www/media/public/tmp
	rm -rf ~/www/media/public/tmp/docbook-cll-test
	cp -pr html_test ~/www/media/public/tmp/docbook-cll-test

html_test: cll_processed_test.xml
	mkdir -p html_test
	ln -fs $(PWD)/docbook2html.css html_test
	xmlto -m xml/docbook2html_config.xsl -o html_test/ xhtml cll_processed_test.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'

cll_processed_test.xml: cll_test.xml
	xsltproc --nonet --path . --novalid xml/docbook2html_preprocess.xsl cll_test.xml > cll_processed_test.xml

cll_test.xml:
	scripts/merge.sh -t $(chapters)
	mv cll.xml cll_test.xml
