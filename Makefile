chapters = $(if $(CHAPTERS), $(CHAPTERS), chapters/1.xml chapters/2.xml chapters/3.xml chapters/4.xml chapters/5.xml chapters/6.xml chapters/7.xml chapters/8.xml chapters/9.xml chapters/10.xml chapters/11.xml chapters/12.xml chapters/13.xml chapters/14.xml chapters/15.xml chapters/16.xml chapters/17.xml chapters/18.xml chapters/19.xml chapters/20.xml chapters/21.xml)
format = "xhtml"

.PHONY: all
all: xhtml_web xhtml_nochunks_web pdf_web epub_web mobi_web

.PHONY: clean
clean:
	-rm -rf cll.xml cll_processed.xml cll_preglossary.xml xhtml/ xhtml-nochunks/

.PHONY: realclean
realclean: clean
	-rm -rf jbovlaste.xml jbovlaste2.xml

#*******
# Basic prep
#*******

cll.xml:
	scripts/merge.sh $(chapters)

cll_processed.xml: cll.xml xml/docbook2html_preprocess.xsl
	xsltproc --stringparam format $(format) --nonet --path . --novalid xml/docbook2html_preprocess.xsl cll.xml > cll_processed.xml

#*******
# Many xhtml files
#*******
.PHONY: xhtml_web
xhtml_web: xhtml.done
	mkdir -p ~/www/media/public/tmp
	rm -rf ~/www/media/public/tmp/docbook-cll-test
	cp -pr xhtml ~/www/media/public/tmp/docbook-cll-test

xhtml.done: cll_processed.xml
	rm -rf xhtml
	mkdir xhtml
	ln -fs $(PWD)/docbook2html.css xhtml/
	# FIXME: Consider doing something like this: -x /usr/share/sgml/docbook/xsl-ns-stylesheets-1.76.1/fo/docbook.xsl
	# So we know exactly what stylesheets we're getting
	xmlto -m xml/docbook2html_config.xsl -o xhtml/ xhtml cll_processed.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	touch xhtml.done

#*******
# One XHTML file
#*******
.PHONY: xhtml_nochunks_web
xhtml_nochunks_web: xhtml-nochunks.done
	mkdir -p ~/www/media/public/tmp
	cp $(PWD)/docbook2html.css  ~/www/media/public/tmp/docbook2html.css
	cp $(PWD)/xhtml-nochunks/cll_processed.html ~/www/media/public/tmp/docbook-cll-test-nochunks.html

xhtml-nochunks.done: cll_processed.xml
	rm -rf xhtml-nochunks
	mkdir xhtml-nochunks
	ln -fs $(PWD)/docbook2html.css xhtml-nochunks/
	# FIXME: Consider doing something like this: -x /usr/share/sgml/docbook/xsl-ns-stylesheets-1.76.1/fo/docbook.xsl
	# So we know exactly what stylesheets we're getting
	xmlto -m xml/docbook2html_config.xsl -o xhtml-nochunks/ xhtml-nochunks cll_processed.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	touch xhtml-nochunks.done

#*******
# PDF
#
# We actually do need xetex (aka xalatex) here, for the IPA and
# other utf-8 issues
#*******
pdf: format = "pdf"
pdf: cll_processed.xml
	dblatex -b xetex -p xml/dblatex_config.xsl cll_processed.xml 2>&1 | grep -v 'default template used in programlisting or screen'

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
test: xhtml_web xhtml_nochunks_web pdf_web epub_web mobi_web

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
xhtml_nochunks_web_test: chapters = -t chapters/1.xml chapters/2.xml chapters/10.xml chapters/21.xml
xhtml_nochunks_web_test: xhtml_nochunks_web
