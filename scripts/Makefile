test = 
chapters = $(if $(CHAPTERS), $(CHAPTERS), chapters/1.xml chapters/2.xml chapters/3.xml chapters/4.xml chapters/5.xml chapters/6.xml chapters/7.xml chapters/8.xml chapters/9.xml chapters/10.xml chapters/11.xml chapters/12.xml chapters/13.xml chapters/14.xml chapters/15.xml chapters/16.xml chapters/17.xml chapters/18.xml chapters/19.xml chapters/20.xml chapters/21.xml)
builddir = $(if $(BUILDDIR), $(BUILDDIR), $(PWD)/build)

.PHONY: all
all: xhtml_web xhtml_sections_web xhtml_nochunks_web pdf_web epub_web mobi_web

.PHONY: clean
clean:
	find $(builddir)/ \! -name 'jbovlaste*.xml' -type f | xargs rm -f

.PHONY: realclean
realclean: clean
	-rm -rf $(builddir)/*

#*******
# Basic prep
#*******

builddir:
	mkdir -p $(builddir)
$(builddir)/cll.xml: $(chapters) builddir
	rm -f $(builddir)/xml $(builddir)/dtd
	ln -sf $(PWD)/xml $(builddir)/xml
	ln -sf $(PWD)/dtd $(builddir)/dtd
	scripts/merge.sh -b "$(builddir)" $(test) $(chapters)

$(builddir)/cll_processed_xhtml.xml: $(builddir)/cll.xml xml/docbook2html_preprocess.xsl
	xsltproc --stringparam format xhtml --nonet --path . --novalid xml/docbook2html_preprocess.xsl $(builddir)/cll.xml > $(builddir)/cll_processed_xhtml.xml

$(builddir)/cll_processed_pdf.xml: $(builddir)/cll_processed_xhtml.xml xml/latex_preprocess.xsl
	xsltproc --nonet --path . --novalid xml/latex_preprocess.xsl $(builddir)/cll_processed_xhtml.xml > $(builddir)/cll_processed_pdf.xml

#*******
# Many xhtml files
#*******
.PHONY: xhtml_web
xhtml_web: $(builddir)/xhtml.done
	mkdir -p ~/public_html/media/public/cll_build
	rm -rf ~/public_html/media/public/cll_build/cll-xhtml
	cp -pr $(builddir)/xhtml ~/public_html/media/public/cll_build/cll-xhtml
	cp $(PWD)/scripts/docbook2html.css  ~/public_html/media/public/cll_build/cll-xhtml/docbook2html.css
	cp -pr $(PWD)/media ~/public_html/media/public/cll_build/cll-xhtml/

.PHONY: xhtml
xhtml: $(builddir)/xhtml.done
$(builddir)/xhtml.done: $(builddir)/cll_processed_xhtml.xml xml/docbook2html_config.xsl
	rm -rf $(builddir)/xhtml
	mkdir $(builddir)/xhtml
	# FIXME: Consider doing something like this: -x /usr/share/sgml/docbook/xsl-ns-stylesheets-1.76.1/fo/docbook.xsl
	# So we know exactly what stylesheets we're getting
	xmlto -m xml/docbook2html_config_no-sections.xsl -o $(builddir)/xhtml/ xhtml $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	touch $(builddir)/xhtml.done

#*******
# Section xhtml files
#*******
.PHONY: xhtml_sections_web
xhtml_sections_web: $(builddir)/xhtml_sections.done
	mkdir -p ~/public_html/media/public/cll_build
	rm -rf ~/public_html/media/public/cll_build/cll-xhtml-sections
	cp -pr $(builddir)/xhtml_sections ~/public_html/media/public/cll_build/cll-xhtml-sections
	cp $(PWD)/scripts/docbook2html.css  ~/public_html/media/public/cll_build/cll-xhtml-sections/docbook2html.css
	cp -pr $(PWD)/media ~/public_html/media/public/cll_build/cll-xhtml-sections/media

.PHONY: xhtml_sections
xhtml_sections: $(builddir)/xhtml_sections.done
$(builddir)/xhtml_sections.done: $(builddir)/cll_processed_xhtml.xml xml/docbook2html_config.xsl
	rm -rf $(builddir)/xhtml_sections
	mkdir $(builddir)/xhtml_sections
	# FIXME: Consider doing something like this: -x /usr/share/sgml/docbook/xsl-ns-stylesheets-1.76.1/fo/docbook.xsl
	# So we know exactly what stylesheets we're getting
	xmlto -m xml/docbook2html_config_sections.xsl -o $(builddir)/xhtml_sections/ --stringparam chunk.section.depth=1 --stringparam chunk.first.sections=1 xhtml $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	touch $(builddir)/xhtml_sections.done

#*******
# One XHTML file
#*******
.PHONY: xhtml_nochunks_web
xhtml_nochunks_web: $(builddir)/xhtml-nochunks.done
	mkdir -p ~/public_html/media/public/cll_build/media
	cp $(PWD)/scripts/docbook2html.css  ~/public_html/media/public/cll_build/docbook2html.css
	cp $(builddir)/xhtml-nochunks/cll_processed_xhtml.html ~/public_html/media/public/cll_build/cll-xhtml-nochunks.html
	cp -pr $(PWD)/media ~/public_html/media/public/cll_build/

.PHONY: xhtml_nochunks
xhtml_nochunks: $(builddir)/xhtml-nochunks.done
$(builddir)/xhtml-nochunks.done: $(builddir)/cll_processed_xhtml.xml xml/docbook2html_config.xsl
	rm -rf $(builddir)/xhtml-nochunks
	mkdir $(builddir)/xhtml-nochunks
	ln -fs $(PWD)/scripts/docbook2html.css $(builddir)/xhtml-nochunks/
	# FIXME: Consider doing something like this: -x /usr/share/sgml/docbook/xsl-ns-stylesheets-1.76.1/fo/docbook.xsl
	# So we know exactly what stylesheets we're getting
	xmlto -m xml/docbook2html_config.xsl -o $(builddir)/xhtml-nochunks/ xhtml-nochunks $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	touch $(builddir)/xhtml-nochunks.done

#*******
# EPUB
#*******
.PHONY: epub
epub: $(builddir)/cll.epub
$(builddir)/cll.epub: $(builddir)/xhtml.done
	xvfb-run ebook-convert $(builddir)/xhtml/index.html $(builddir)/cll.epub

.PHONY: epub_web
epub_web: epub
	cp $(builddir)/cll.epub ~/public_html/media/public/cll_build/cll.epub

#*******
# MOBI
#*******
.PHONY: mobi
mobi: $(builddir)/cll.mobi
$(builddir)/cll.mobi: $(builddir)/xhtml.done
	xvfb-run ebook-convert $(builddir)/xhtml/index.html $(builddir)/cll.mobi

.PHONY: mobi_web
mobi_web: mobi
	cp $(builddir)/cll.mobi ~/public_html/media/public/cll_build/cll.mobi

#*******
# PDF
#
# We actually do need xetex (aka xalatex) here, for the IPA and
# other utf-8 issues
#*******
.PHONY: pdf
pdf: $(builddir)/cll.pdf
$(builddir)/cll.pdf: $(builddir)/cll_processed_pdf.xml xml/dblatex_config.xsl
	dblatex -V -T latex/cll -o $(builddir)/cll.tex -t tex -b xetex -p xml/dblatex_config.xsl $(builddir)/cll_processed_pdf.xml 2>&1 | grep -v 'default template used in programlisting or screen'
	dblatex -V -T latex/cll -o $(builddir)/cll.pdf -b xetex -p xml/dblatex_config.xsl $(builddir)/cll_processed_pdf.xml 2>&1 | grep -v 'default template used in programlisting or screen'

.PHONY: pdf_web
pdf_web: pdf
	cp $(builddir)/cll.pdf ~/public_html/media/public/cll_build/cll.pdf

#*******
# Testing
#*******
coverage: clean builddir xhtml_nochunks pdf
	mkdir -p ~/public_html/media/public/cll_coverage/
	cp $(builddir)/cll.pdf ~/public_html/media/public/cll_coverage/cll.pdf
	cp $(PWD)/scripts/docbook2html.css  ~/public_html/media/public/cll_coverage/docbook2html.css
	cp $(builddir)/xhtml-nochunks/cll_processed_xhtml.html ~/public_html/media/public/cll_coverage/cll-xhtml-nochunks.html
	cp -pr $(PWD)/media ~/public_html/media/public/cll_coverage/
