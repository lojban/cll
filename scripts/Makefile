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
# Chapter xhtml files
#*******
.PHONY: xhtml_chapters_web
xhtml_chapters_web: $(builddir)/xhtml_chapters.done
	mkdir -p ~/public_html/media/public/cll_build
	rm -rf ~/public_html/media/public/cll_build/cll-xhtml-chapters
	cp -pr $(builddir)/xhtml-chapters ~/public_html/media/public/cll_build/cll-xhtml-chapters
	cp $(PWD)/scripts/docbook2html.css  ~/public_html/media/public/cll_build/cll-xhtml-chapters/docbook2html.css
	cp $(PWD)/scripts/display.css  ~/public_html/media/public/cll_build/cll-xhtml-chapters/display.css
	ln -sf display.css ~/public_html/media/public/cll_build/cll-xhtml-chapters/final.css
	cp -pr $(PWD)/media ~/public_html/media/public/cll_build/cll-xhtml-chapters/

.PHONY: xhtml_chapters
xhtml_chapters: $(builddir)/xhtml_chapters.done
$(builddir)/xhtml_chapters.done: $(builddir)/cll_processed_xhtml.xml xml/docbook2html_config_chapter-chunks.xsl
	rm -rf $(builddir)/xhtml-chapters
	mkdir $(builddir)/xhtml-chapters
	# FIXME: Consider doing something like this: -x /usr/share/sgml/docbook/xsl-ns-stylesheets-1.76.1/fo/docbook.xsl
	# So we know exactly what stylesheets we're getting
	xmlto -m xml/docbook2html_config_chapter-chunks.xsl -o $(builddir)/xhtml-chapters/ xhtml $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	touch $(builddir)/xhtml_chapters.done

#*******
# Section xhtml files
#*******
.PHONY: xhtml_sections_web
xhtml_sections_web: $(builddir)/xhtml_sections.done
	mkdir -p ~/public_html/media/public/cll_build
	rm -rf ~/public_html/media/public/cll_build/cll-xhtml-sections
	cp -pr $(builddir)/xhtml_sections ~/public_html/media/public/cll_build/cll-xhtml-sections
	cp $(PWD)/scripts/docbook2html.css  ~/public_html/media/public/cll_build/cll-xhtml-sections/docbook2html.css
	cp $(PWD)/scripts/display.css  ~/public_html/media/public/cll_build/cll-xhtml-sections/display.css
	ln -sf display.css ~/public_html/media/public/cll_build/cll-xhtml-sections/final.css
	cp -pr $(PWD)/media ~/public_html/media/public/cll_build/cll-xhtml-sections/media

.PHONY: xhtml_sections
xhtml_sections: $(builddir)/xhtml_sections.done
$(builddir)/xhtml_sections.done: $(builddir)/cll_processed_xhtml.xml xml/docbook2html_config_section-chunks.xsl
	rm -rf $(builddir)/xhtml_sections
	mkdir $(builddir)/xhtml_sections
	# FIXME: Consider doing something like this: -x /usr/share/sgml/docbook/xsl-ns-stylesheets-1.76.1/fo/docbook.xsl
	# So we know exactly what stylesheets we're getting
	xmlto -m xml/docbook2html_config_section-chunks.xsl -o $(builddir)/xhtml_sections/ --stringparam chunk.section.depth=1 --stringparam chunk.first.sections=1 xhtml $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	touch $(builddir)/xhtml_sections.done

#*******
# One XHTML file
#*******
.PHONY: xhtml_nochunks_web
xhtml_nochunks_web: $(builddir)/xhtml-nochunks.done
	rm -rf ~/public_html/media/public/cll_build/cll-xhtml-nochunks/
	mkdir -p ~/public_html/media/public/cll_build/cll-xhtml-nochunks/
	cp $(PWD)/scripts/docbook2html.css  ~/public_html/media/public/cll_build/cll-xhtml-nochunks/docbook2html.css
	cp $(PWD)/scripts/display.css  ~/public_html/media/public/cll_build/cll-xhtml-nochunks/display.css
	ln -sf display.css ~/public_html/media/public/cll_build/cll-xhtml-nochunks/final.css
	cp $(builddir)/xhtml-nochunks/cll_processed_xhtml.html ~/public_html/media/public/cll_build/cll-xhtml-nochunks/cll-xhtml-nochunks.html
	cp -pr $(PWD)/media ~/public_html/media/public/cll_build/cll-xhtml-nochunks/

.PHONY: xhtml_nochunks
xhtml_nochunks: $(builddir)/xhtml-nochunks.done
$(builddir)/xhtml-nochunks.done: $(builddir)/cll_processed_xhtml.xml xml/docbook2html_config_no-chunks.xsl
	rm -rf $(builddir)/xhtml-nochunks
	mkdir $(builddir)/xhtml-nochunks
	# FIXME: Consider doing something like this: -x /usr/share/sgml/docbook/xsl-ns-stylesheets-1.76.1/fo/docbook.xsl
	# So we know exactly what stylesheets we're getting
	xmlto -m xml/docbook2html_config_no-chunks.xsl -o $(builddir)/xhtml-nochunks/ xhtml-nochunks $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
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
# Prince PDF
#*******
.PHONY: prince_pdf
prince_pdf: $(builddir)/prince_pdf.done
$(builddir)/prince_pdf.done: $(builddir)/cll_processed_xhtml.xml xml/docbook2html_config_prince.xsl
	rm -rf $(builddir)/prince_pdf
	mkdir $(builddir)/prince_pdf
	ln -sf $(PWD)/scripts/docbook2html.css $(builddir)/prince_pdf/
	ln -sf $(PWD)/scripts/paged.css $(builddir)/prince_pdf/
	ln -sf paged.css $(builddir)/prince_pdf/final.css
	ln -sf $(PWD)/media $(builddir)/prince_pdf/
	# FIXME: Consider doing something like this: -x /usr/share/sgml/docbook/xsl-ns-stylesheets-1.76.1/fo/docbook.xsl
	# So we know exactly what stylesheets we're getting
	xmlto -m xml/docbook2html_config_prince.xsl -o $(builddir)/prince_pdf/ xhtml-nochunks $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	cd $(builddir)/prince_pdf/
	#********************************
	# FIXME:
	#
	# These sed statements are horrible hacks.  Do some nokogiri
	# or something FFS.
	#
	# They're pretty self-explanatory except the CHAPBR ones,
	# which puts a <br/> tag into chapter titles; it works with
	# the xml/docbook2html_config_prince.xsl customization
	#********************************
	cat $(builddir)/prince_pdf/cll_processed_xhtml.html | \
	sed 's;<a id="\([^"]*\)"></a><p class="title">;<p class="title"><a id="\1"></a>;' | \
	sed 's;<div class="index"><div class="titlepage">;<div class="whole-index"><div class="titlepage">;' | \
	sed 's;href="docbook2html.css";href="prince.css";' | \
	sed -r 's;title="Chapter [0-9]+--CHAPBR--;title=";g' | \
	sed 's;--CHAPBR--;<br/>;g' >$(builddir)/prince_pdf/cll_processed_xhtml_prince.html
	prince -vvv $(builddir)/prince_pdf/cll_processed_xhtml_prince.html $(builddir)/cll_prince.pdf
	touch $(builddir)/prince_pdf.done

.PHONY: prince_pdf_web
prince_pdf_web: prince_pdf
	cp $(builddir)/cll_prince.pdf ~/public_html/media/public/cll_build/cll_prince.pdf

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
# coverage: clean builddir xhtml_nochunks # pdf
coverage: clean builddir xhtml_nochunks prince_pdf
	mkdir -p ~/public_html/media/public/cll_coverage/cll-xhtml-nochunks/
	cp $(builddir)/cll_prince.pdf ~/public_html/media/public/cll_coverage/cll_prince.pdf
	cp $(PWD)/scripts/docbook2html.css  ~/public_html/media/public/cll_coverage/cll-xhtml-nochunks/docbook2html.css
	cp $(PWD)/scripts/display.css  ~/public_html/media/public/cll_coverage/cll-xhtml-nochunks/display.css
	ln -sf display.css ~/public_html/media/public/cll_coverage/cll-xhtml-nochunks/final.css
	cp $(builddir)/xhtml-nochunks/cll_processed_xhtml.html ~/public_html/media/public/cll_coverage/cll-xhtml-nochunks/cll-xhtml-nochunks.html
	cp -pr $(PWD)/media ~/public_html/media/public/cll_coverage/cll-xhtml-nochunks/
