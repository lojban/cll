chapters = $(if $(CHAPTERS), $(CHAPTERS), chapters/{1..21}.xml)
nochunks =

.PHONY: all
all: xhtml_web xhtml_nochunks_web pdf_web epub_web mobi_web

.PHONY: clean
clean:
	-rm -rf cll.xml cll_processed.xml cll_preglossary.xml xhtml/ jbovlaste.xml jbovlaste2.xml

#*******
# Basic prep
#*******

cll.xml:
	scripts/merge.sh $(chapters)

cll_processed.xml: cll.xml
	xsltproc --nonet --path . --novalid xml/docbook2html_preprocess.xsl cll.xml > cll_processed.xml

#*******
# Many xhtml files
#*******
.PHONY: xhtml_web
xhtml_web: xhtml
	mkdir -p ~/www/media/public/tmp
	rm -rf ~/www/media/public/tmp/docbook-cll-test
	cp -pr xhtml$(nochunks) ~/www/media/public/tmp/docbook-cll-test

.PHONY: xhtml
xhtml: cll_processed.xml
	mkdir -p xhtml
	ln -fs $(PWD)/docbook2html.css html
	xmlto -m xml/docbook2html_config.xsl -o xhtml$(nochunks)/ xhtml$(nochunks) cll_processed.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'

#*******
# One XHTML file
#*******
.PHONY: xhtml_nochunks
xhtml_nochunks: nochunks = "-nochunks"
xhtml_nochunks: xhtml

.PHONY: xhtml_nochunks_web
xhtml_nochunks_web: nochunks = "-nochunks"
xhtml_nochunks_web: xhtml
	mkdir -p ~/www/media/public/tmp
	cp xhtml-nochunks/cll_processed.html ~/www/media/public/tmp/docbook-cll-test-nochunks.html

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
epub_web: xhtml_web
	xvfb-run ebook-convert ~/www/media/public/tmp/docbook-cll-test/index.html ~/www/media/public/tmp/docbook-cll-test-chunks-ebook-convert.epub

#*******
# MOBI
#*******
mobi_web: xhtml_web
	xvfb-run ebook-convert ~/www/media/public/tmp/docbook-cll-test/index.html ~/www/media/public/tmp/docbook-cll-test-chunks-ebook-convert.mobi

#*********************
# Faster testing versions go here; lots of copy and paste; lame
#*********************

.PHONY: test
test: chapters = -t chapters/1.xml chapters/2.xml chapters/10.xml chapters/21.xml
test: xhtml_web pdf_web epub_web mobi_web

.PHONY: xhtml_web_test
xhtml_web_test: chapters = -t chapters/1.xml chapters/2.xml chapters/10.xml chapters/21.xml
xhtml_web_test: xhtml_web

.PHONY: pdf_web_test
pdf_web_test: chapters = -t chapters/1.xml chapters/2.xml chapters/10.xml chapters/21.xml
pdf_web_test: pdf_web

.PHONY: epub_web_test
epub_web_test: chapters = -t chapters/1.xml chapters/2.xml chapters/10.xml chapters/21.xml
epub_web_test: epub_web

.PHONY: mobi_web_test
mobi_web_test: chapters = -t chapters/1.xml chapters/2.xml chapters/10.xml chapters/21.xml
mobi_web_test: mobi_web

.PHONY: xhtml_nochunks_web_test
mobi_web_test: chapters = -t chapters/1.xml chapters/2.xml chapters/10.xml chapters/21.xml
mobi_web_test: mobi_web
