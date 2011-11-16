chapters = chapters/{1..21}.xml

.PHONY: all
all: html_web epub_web pdf_web

.PHONY: clean
clean:
	-rm -rf cll.xml cll_processed.xml cll_preglossary.xml html/ jbovlaste.xml jbovlaste2.xml
	-rm -rf cll_test.xml cll_processed_test.xml html_test/

.PHONY: html_web
html_web: html
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

#*******
# PDF
#*******
pdf: cll_processed.xml
	dblatex cll_processed.xml 2>&1 | grep -v 'default template used in programlisting or screen'

pdf_web: pdf
	cp cll_processed.pdf ~/www/media/public/tmp/docbook-cll-test-dblatex.pdf

#*******
# EPUB
#*******
epub_web: html_web
	ebook-convert ~/www/media/public/tmp/docbook-cll-test/index.html ~/www/media/public/tmp/docbook-cll-test-chunks-ebook-convert.epub

#*********************
# Faster testing versions go here; lots of copy and paste; lame
#*********************

.PHONY: test
test: chapters = -t chapters/1.xml chapters/2.xml chapters/10.xml chapters/21.xml
test: html_web pdf_web epub_web

.PHONY: html_web_test
html_web_test: chapters = -t chapters/1.xml chapters/2.xml chapters/10.xml chapters/21.xml
html_web_test: html_web

.PHONY: pdf_web_test
pdf_web_test: chapters = -t chapters/1.xml chapters/2.xml chapters/10.xml chapters/21.xml
pdf_web_test: pdf_web

.PHONY: epub_web_test
epub_web_test: chapters = -t chapters/1.xml chapters/2.xml chapters/10.xml chapters/21.xml
epub_web_test: epub_web
