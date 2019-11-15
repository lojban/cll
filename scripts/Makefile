chapters = $(if $(chapters), $(chapters), chapters/01.xml chapters/02.xml chapters/03.xml chapters/04.xml chapters/05.xml chapters/06.xml chapters/07.xml chapters/08.xml chapters/09.xml chapters/10.xml chapters/11.xml chapters/12.xml chapters/13.xml chapters/14.xml chapters/15.xml chapters/16.xml chapters/17.xml chapters/18.xml chapters/19.xml chapters/20.xml chapters/21.xml)
builddir = $(if $(builddir), $(builddir), $(PWD)/build)
xsl_base = xml/docbook-xsl-1.78.1

SHELL=/bin/bash -o pipefail

.PHONY: all
all: xhtml_chapters xhtml_sections xhtml_nochunks pdf epub mobi

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

$(builddir)/cll.xml: $(chapters) xml/iso-pub.ent xml/identity.xsl xml/docbook2html_config_common.xsl scripts/update_jbovlaste_xml.sh scripts/generate_glossary.rb scripts/merge.sh
	rm -rf $(builddir)/xml $(builddir)/dtd
	cp -pr $(PWD)/xml $(builddir)/
	cp -pr $(PWD)/dtd $(builddir)/
	scripts/merge.sh -b "$(builddir)" $(test) $(chapters)

$(builddir)/cll_processed_xhtml.xml: $(builddir)/cll.xml scripts/xml_preprocess.rb
	ruby scripts/xml_preprocess.rb $(builddir)/cll.xml >$(builddir)/cll_processed_xhtml.xml 2>$(builddir)/xml_preprocess.out || (tail $(builddir)/xml_preprocess.out && false)

#*******
# XHTML, with various chunk sizes
#*******
# Name the various chunking targets
.PHONY: xhtml_chapters xhtml_sections xhtml_nochunks
xhtml_chapters: $(builddir)/xhtml_chapter_chunks.done
xhtml_chapters: xsl_file = $(xsl_base)/xhtml/chunk.xsl

xhtml_sections: $(builddir)/xhtml_section_chunks.done
xhtml_sections: xsl_file = $(xsl_base)/xhtml/chunk.xsl

xhtml_nochunks: nochunks = -nochunks
xhtml_nochunks: xsl_file = $(xsl_base)/xhtml/docbook.xsl
xhtml_nochunks: $(builddir)/xhtml_no_chunks.done

# Do the actual chunking work
$(builddir)/xhtml_%_chunks.done: xml/docbook2html_config_%_chunks.xsl $(builddir)/cll_processed_xhtml.xml xml/docbook2html_config_xhtml.xsl scripts/master.css scripts/xhtml_postprocess_appcache.sh scripts/xhtml_postprocess_cleanup.sh scripts/xhtml_postprocess_cleanup_file.rb
	rm -rf $(builddir)/xhtml_$*_chunks
	mkdir -p $(builddir)/xhtml_$*_chunks
	cp -pr $(PWD)/dtd $(builddir)/xhtml_$*_chunks/
	xmlto -m xml/docbook2html_config_$*_chunks.xsl -x $(xsl_file) -o $(builddir)/xhtml_$*_chunks/ xhtml$(nochunks) $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists'
	# We run tidy on the no-chunk version, because it's all in
	# one place so it's easy
	test -f $(builddir)/xhtml_$*_chunks/index.html || cat $(builddir)/xhtml_$*_chunks/cll_processed_xhtml.html | scripts/tidy -e - 2>&1 | grep -v '<table> lacks "summary" attribute'
# Handle the no-chunk case; can't figure out how to set the
# name of the output file, so move it to index.html
	test -f $(builddir)/xhtml_$*_chunks/index.html || mv $(builddir)/xhtml_$*_chunks/cll_processed_xhtml.html $(builddir)/xhtml_$*_chunks/index.html
	cp $(PWD)/scripts/master.css $(builddir)/xhtml_$*_chunks/final.css
	cp -pr $(PWD)/media $(builddir)/xhtml_$*_chunks/
	scripts/xhtml_postprocess_cleanup.sh $(builddir)/xhtml_$*_chunks/
	scripts/xhtml_postprocess_appcache.sh $(builddir)/xhtml_$*_chunks/
	touch $(builddir)/xhtml_$*_chunks.done
ifdef copydir
	mkdir -p $(copydir)
	rm -rf $(copydir)/cll-xhtml_$*_chunks
	cp -pr $(builddir)/xhtml_$*_chunks $(copydir)/cll-xhtml_$*_chunks
	# The appcache is supremely unhelpful when testing
	find $(copydir) -name cll.appcache | xargs rm
endif

#*******
# Prince PDF
#*******
.PHONY: pdf
pdf: $(builddir)/pdf.done
$(builddir)/pdf.done: $(builddir)/cll_processed_xhtml.xml xml/docbook2html_config_prince.xsl scripts/master.css scripts/xhtml_postprocess_cleanup.sh scripts/xhtml_postprocess_cleanup_file.rb
	rm -rf $(builddir)/pdf
	mkdir -p $(builddir)/pdf
	cp -pr $(PWD)/scripts/master.css $(builddir)/pdf/final.css
	cp -pr $(PWD)/media $(builddir)/pdf/
	cp -pr $(PWD)/dtd $(builddir)/pdf/
	
	xmlto -m xml/docbook2html_config_prince.xsl -o $(builddir)/pdf/ -x $(xsl_base)/xhtml/docbook.xsl xhtml-nochunks $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists'
	scripts/xhtml_postprocess_cleanup.sh $(builddir)/pdf/
	ruby scripts/xml_prince_postprocess.rb $(builddir)/pdf/cll_processed_xhtml.html >$(builddir)/pdf/cll_processed_xhtml_pdf.html 2>$(builddir)/xml_prince_postprocess.out
	
	prince -vvv --script=scripts/prince_check_margins.js --script=scripts/prince_shave_index.js $(builddir)/pdf/cll_processed_xhtml_pdf.html -o $(builddir)/cll.pdf
	touch $(builddir)/pdf.done
ifdef copydir
	mkdir -p $(copydir)
	cp $(builddir)/cll.pdf $(copydir)/cll.pdf
endif

#*******
# EPUB ; also generates .MOBI
#*******
.PHONY: epub
.PHONY: mobi
mobi: $(builddir)/cll.epub
epub: $(builddir)/cll.epub

$(builddir)/cll.epub: $(builddir)/epub-xhtml/index.html scripts/build_epub.sh epub/mimetype epub/* epub/META-INF/container.xml
	scripts/build_epub.sh $(PWD)
	mv $(builddir)/cll.epub $(builddir)/cll.tmp.epub
	java -jar $(PWD)/epub/epubcheck-4.0.1/epubcheck.jar $(builddir)/cll.tmp.epub 2>&1 | grep -v "should have the extension '.xhtml'"
# This both checks for Kindle support *and* generates the .mobi
	$(PWD)/epub/kindlegen/kindlegen $(builddir)/cll.tmp.epub -o cll.mobi
# It checks out; move it into place
	mv $(builddir)/cll.tmp.epub $(builddir)/cll.epub
ifdef copydir
	mkdir -p $(copydir)
	cp $(builddir)/cll.epub $(copydir)/cll.epub
	cp $(builddir)/cll.mobi $(copydir)/cll.mobi
endif

# Note that the epub doesn't rely on the PDF, but rather on the HTML
# that is used to build the PDF, but it amounts to the same thing
# for requirements here.
$(builddir)/epub-xhtml/index.html: $(builddir)/cll_processed_xhtml.xml xml/docbook2html_config_common.xsl xml/docbook2html_config_epub.xsl $(PWD)/scripts/master.css $(PWD)/media/* scripts/xhtml_postprocess_cleanup.sh scripts/xhtml_postprocess_cleanup_file.rb
	rm -rf $(builddir)/epub-xhtml/
	mkdir -p $(builddir)/epub-xhtml/
	cp -pr $(PWD)/dtd $(builddir)/epub-xhtml/
	xmlto -m xml/docbook2html_config_epub.xsl -o $(builddir)/epub-xhtml/ -x $(xsl_base)/xhtml/chunk.xsl xhtml $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists'
	cp $(PWD)/scripts/master.css $(builddir)/epub-xhtml/final.css
	cp -pr $(PWD)/media $(builddir)/epub-xhtml/
	scripts/xhtml_postprocess_cleanup.sh $(builddir)/epub-xhtml/

#*******
# Testing
#*******
coverage: clean xhtml_nochunks pdf
ifneq ($(covcopydir),)
	mkdir -p $(covcopydir)
	cp $(builddir)/cll.pdf $(covcopydir)/cll.pdf
	rm -rf $(covcopydir)/cll-xhtml_no_chunks
	cp -pr $(builddir)/xhtml_no_chunks $(covcopydir)/cll-xhtml_no_chunks
	# The appcache is supremely unhelpful when testing
	find $(covcopydir) -name cll.appcache | xargs rm
endif
