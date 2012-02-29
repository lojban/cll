test = 
chapters = $(if $(CHAPTERS), $(CHAPTERS), chapters/1.xml chapters/2.xml chapters/3.xml chapters/4.xml chapters/5.xml chapters/6.xml chapters/7.xml chapters/8.xml chapters/9.xml chapters/10.xml chapters/11.xml chapters/12.xml chapters/13.xml chapters/14.xml chapters/15.xml chapters/16.xml chapters/17.xml chapters/18.xml chapters/19.xml chapters/20.xml chapters/21.xml)

.PHONY: all
all: xhtml_web xhtml_sections_web xhtml_nochunks_web pdf_web epub_web mobi_web

.PHONY: clean
clean:
	-rm -rf cll* xhtml/ xhtml.done xhtml-nochunks/ xhtml-nochunks.done

.PHONY: realclean
realclean: clean
	-rm -rf jbovlaste.xml jbovlaste2.xml

#*******
# Basic prep
#*******

cll.xml: $(chapters)
	scripts/merge.sh $(test) $(chapters)

cll_processed_pdf.xml: cll_processed_xhtml.xml xml/latex_preprocess.xsl
	xsltproc --nonet --path . --novalid xml/latex_preprocess.xsl cll_processed_xhtml.xml > cll_processed_pdf.xml

cll_processed_xhtml.xml: cll.xml xml/docbook2html_preprocess.xsl
	xsltproc --stringparam format xhtml --nonet --path . --novalid xml/docbook2html_preprocess.xsl cll.xml > cll_processed_xhtml.xml

#*******
# Many xhtml files
#*******
.PHONY: xhtml_web
xhtml_web: xhtml.done
	mkdir -p ~/www/media/public/tmp
	rm -rf ~/www/media/public/tmp/cll-xhtml
	cp -pr xhtml ~/www/media/public/tmp/cll-xhtml
	cp $(PWD)/docbook2html.css  ~/www/media/public/tmp/cll-xhtml/docbook2html.css

.PHONY: xhtml
xhtml: xhtml.done
xhtml.done: cll_processed_xhtml.xml xml/docbook2html_config.xsl
	rm -rf xhtml
	mkdir xhtml
	# FIXME: Consider doing something like this: -x /usr/share/sgml/docbook/xsl-ns-stylesheets-1.76.1/fo/docbook.xsl
	# So we know exactly what stylesheets we're getting
	xmlto -m xml/docbook2html_config.xsl -o xhtml/ xhtml cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	touch xhtml.done

#*******
# Section xhtml files
#*******
.PHONY: xhtml_sections_web
xhtml_sections_web: xhtml_sections.done
	mkdir -p ~/www/media/public/tmp
	rm -rf ~/www/media/public/tmp/cll-xhtml-sections
	cp -pr xhtml_sections ~/www/media/public/tmp/cll-xhtml-sections
	cp $(PWD)/docbook2html.css  ~/www/media/public/tmp/cll-xhtml-sections/docbook2html.css

.PHONY: xhtml_sections
xhtml_sections: xhtml_sections.done
xhtml_sections.done: cll_processed_xhtml.xml xml/docbook2html_config.xsl
	rm -rf xhtml_sections
	mkdir xhtml_sections
	# FIXME: Consider doing something like this: -x /usr/share/sgml/docbook/xsl-ns-stylesheets-1.76.1/fo/docbook.xsl
	# So we know exactly what stylesheets we're getting
	xmlto -m xml/docbook2html_config_sections.xsl -o xhtml_sections/ --stringparam chunk.section.depth=1 --stringparam chunk.first.sections=1 xhtml cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	touch xhtml_sections.done

#*******
# One XHTML file
#*******
.PHONY: xhtml_nochunks_web
xhtml_nochunks_web: xhtml-nochunks.done
	mkdir -p ~/www/media/public/tmp
	cp $(PWD)/docbook2html.css  ~/www/media/public/tmp/docbook2html.css
	cp $(PWD)/xhtml-nochunks/cll_processed_xhtml.html ~/www/media/public/tmp/cll-xhtml-nochunks.html

.PHONY: xhtml_nochunks
xhtml_nochunks: xhtml-nochunks.done
xhtml-nochunks.done: cll_processed_xhtml.xml xml/docbook2html_config.xsl
	rm -rf xhtml-nochunks
	mkdir xhtml-nochunks
	ln -fs $(PWD)/docbook2html.css xhtml-nochunks/
	# FIXME: Consider doing something like this: -x /usr/share/sgml/docbook/xsl-ns-stylesheets-1.76.1/fo/docbook.xsl
	# So we know exactly what stylesheets we're getting
	xmlto -m xml/docbook2html_config.xsl -o xhtml-nochunks/ xhtml-nochunks cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	touch xhtml-nochunks.done

#*******
# EPUB
#*******
.PHONY: epub
epub: cll.epub
cll.epub: xhtml.done
	xvfb-run ebook-convert xhtml/index.html cll.epub

.PHONY: epub_web
epub_web: epub
	cp cll.epub ~/www/media/public/tmp/cll.epub

#*******
# MOBI
#*******
.PHONY: mobi
mobi: cll.mobi
cll.mobi: xhtml.done
	xvfb-run ebook-convert xhtml/index.html cll.mobi

.PHONY: mobi_web
mobi_web: mobi
	cp cll.mobi ~/www/media/public/tmp/cll.mobi

#*******
# PDF
#
# We actually do need xetex (aka xalatex) here, for the IPA and
# other utf-8 issues
#*******
.PHONY: pdf
pdf: cll.pdf
cll.pdf: cll_processed_pdf.xml xml/dblatex_config.xsl
	dblatex -o cll.pdf -b xetex -p xml/dblatex_config.xsl -r post_process_latex.pl cll_processed_pdf.xml 2>&1 | grep -v 'default template used in programlisting or screen'

.PHONY: pdf_web
pdf_web: pdf
	cp cll.pdf ~/www/media/public/tmp/cll.pdf

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
