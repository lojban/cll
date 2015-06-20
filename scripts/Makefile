test = 
chapters = $(if $(CHAPTERS), $(CHAPTERS), chapters/01.xml chapters/02.xml chapters/03.xml chapters/04.xml chapters/05.xml chapters/06.xml chapters/07.xml chapters/08.xml chapters/09.xml chapters/10.xml chapters/11.xml chapters/12.xml chapters/13.xml chapters/14.xml chapters/15.xml chapters/16.xml chapters/17.xml chapters/18.xml chapters/19.xml chapters/20.xml chapters/21.xml)
builddir = $(if $(BUILDDIR), $(BUILDDIR), $(PWD)/build)

.PHONY: all
all: xhtml_chapters_web xhtml_sections_web xhtml_nochunks_web prince_pdf_web epub_web mobi_web

.PHONY: clean
clean:
	find $(PWD)/build/ $(PWD)/coverage/build/ $(builddir)/ \! -name 'jbovlaste*.xml' -type f | xargs -n 1 rm -f

.PHONY: realclean
realclean: clean
	find $(PWD)/build/ $(PWD)/coverage/build/ $(builddir)/ -type f | xargs -n 1 rm -f
	find $(PWD)/build/ $(PWD)/coverage/build/ $(builddir)/ -depth -type d -empty -exec rmdir {} \;

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

$(builddir)/cll_processed_xhtml.xml: $(builddir)/cll.xml scripts/xml_preprocess.rb
	ruby scripts/xml_preprocess.rb $(builddir)/cll.xml >$(builddir)/cll_processed_xhtml.xml 2>/tmp/xml_preprocess.out

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
	mkdir -p $(builddir)/xhtml-chapters
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
	mkdir -p $(builddir)/xhtml_sections
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
	mkdir -p $(builddir)/xhtml-nochunks
	xmlto -m xml/docbook2html_config_no-chunks.xsl -o $(builddir)/xhtml-nochunks/ xhtml-nochunks $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	touch $(builddir)/xhtml-nochunks.done

#*******
# EPUB
#*******
.PHONY: epub
epub: $(builddir)/cll.epub
$(builddir)/cll.epub: $(builddir)/xhtml.done
	xvfb-run -a ebook-convert $(builddir)/xhtml/index.html $(builddir)/cll.epub

.PHONY: epub_web
epub_web: epub
	cp $(builddir)/cll.epub ~/public_html/media/public/cll_build/cll.epub

#*******
# MOBI
#*******
.PHONY: mobi
mobi: $(builddir)/cll.mobi
$(builddir)/cll.mobi: $(builddir)/xhtml.done
	xvfb-run -a ebook-convert $(builddir)/xhtml/index.html $(builddir)/cll.mobi

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
	mkdir -p $(builddir)/prince_pdf
	ln -sf $(PWD)/scripts/docbook2html.css $(builddir)/prince_pdf/
	ln -sf $(PWD)/scripts/paged.css $(builddir)/prince_pdf/
	ln -sf paged.css $(builddir)/prince_pdf/final.css
	ln -sf $(PWD)/media $(builddir)/prince_pdf/
	
	xmlto -m xml/docbook2html_config_prince.xsl -o $(builddir)/prince_pdf/ xhtml-nochunks $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists for "jbo" or "". Using default "en".'
	ruby scripts/xml_prince_postprocess.rb $(builddir)/prince_pdf/cll_processed_xhtml.html >$(builddir)/prince_pdf/cll_processed_xhtml_prince.html 2>/tmp/xml_prince_postprocess.out
	
	prince -vvv --script=scripts/prince_check_margins.js $(builddir)/prince_pdf/cll_processed_xhtml_prince.html $(builddir)/cll_prince.pdf
	touch $(builddir)/prince_pdf.done

.PHONY: prince_pdf_web
prince_pdf_web: prince_pdf
	cp $(builddir)/cll_prince.pdf ~/public_html/media/public/cll_build/cll_prince.pdf

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
