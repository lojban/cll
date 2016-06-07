test =
# Grab environment variables; not sure why this is necessary.
chapters = $(if $(CHAPTERS), $(CHAPTERS), chapters/01.xml chapters/02.xml chapters/03.xml chapters/04.xml chapters/05.xml chapters/06.xml chapters/07.xml chapters/08.xml chapters/09.xml chapters/10.xml chapters/11.xml chapters/12.xml chapters/13.xml chapters/14.xml chapters/15.xml chapters/16.xml chapters/17.xml chapters/18.xml chapters/19.xml chapters/20.xml chapters/21.xml)
builddir = $(if $(BUILDDIR), $(BUILDDIR), $(PWD)/build)
copydir = $(COPYDIR)
covcopydir = $(COVCOPYDIR)

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

$(builddir)/cll.xml: $(chapters) xml/iso-pub.ent xml/identity.xsl xml/docbook2html_config_common.xsl
	rm -f $(builddir)/xml $(builddir)/dtd
	ln -sf $(PWD)/xml $(builddir)/xml
	ln -sf $(PWD)/dtd $(builddir)/dtd
	scripts/merge.sh -b "$(builddir)" $(test) $(chapters)

$(builddir)/cll_processed_xhtml.xml: $(builddir)/cll.xml scripts/xml_preprocess.rb
	ruby scripts/xml_preprocess.rb $(builddir)/cll.xml >$(builddir)/cll_processed_xhtml.xml 2>$(builddir)/xml_preprocess.out || (tail $(builddir)/xml_preprocess.out && false)

#*******
# XHTML, with various chunk sizes
#*******
# Name the various chunking targets
.PHONY: xhtml_chapters xhtml_sections xhtml_nochunks
xhtml_chapters: $(builddir)/xhtml_chapter_chunks.done

xhtml_sections: $(builddir)/xhtml_section_chunks.done

xhtml_nochunks: nochunks = -nochunks
xhtml_nochunks: $(builddir)/xhtml_no_chunks.done

# Do the actual chunking work
$(builddir)/xhtml_%_chunks.done: xml/docbook2html_config_%_chunks.xsl $(builddir)/cll_processed_xhtml.xml xml/docbook2html_config_xhtml.xsl
	rm -rf $(builddir)/xhtml_$*_chunks
	mkdir -p $(builddir)/xhtml_$*_chunks
	xmlto -m xml/docbook2html_config_$*_chunks.xsl -o $(builddir)/xhtml_$*_chunks/ xhtml$(nochunks) $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists'
# Handle the no-chunk case; can't figure out how to set the
# name of the output file, so move it to index.html
	test -f $(builddir)/xhtml_$*_chunks/index.html || mv $(builddir)/xhtml_$*_chunks/cll_processed_xhtml.html $(builddir)/xhtml_$*_chunks/index.html
	cp $(PWD)/scripts/master.css $(builddir)/xhtml_$*_chunks/final.css
	cp -pr $(PWD)/media $(builddir)/xhtml_$*_chunks/
	scripts/xhtml_postprocess.sh $(builddir)/xhtml_$*_chunks
	touch $(builddir)/xhtml_$*_chunks.done
ifdef copydir
	mkdir -p $(copydir)
	rm -rf $(copydir)/cll-xhtml_$*_chunks
	cp -pr $(builddir)/xhtml_$*_chunks $(copydir)/cll-xhtml_$*_chunks
endif

#*******
# Prince PDF
#*******
.PHONY: pdf
pdf: $(builddir)/pdf.done
$(builddir)/pdf.done: $(builddir)/cll_processed_xhtml.xml xml/docbook2html_config_prince.xsl
	rm -rf $(builddir)/pdf
	mkdir -p $(builddir)/pdf
	ln -sf $(PWD)/scripts/master.css $(builddir)/pdf/final.css
	ln -sf $(PWD)/media $(builddir)/pdf/
	
	xmlto -m xml/docbook2html_config_prince.xsl -o $(builddir)/pdf/ xhtml-nochunks $(builddir)/cll_processed_xhtml.xml 2>&1 | grep -v 'No localization exists'
	ruby scripts/xml_prince_postprocess.rb $(builddir)/pdf/cll_processed_xhtml.html >$(builddir)/pdf/cll_processed_xhtml_pdf.html 2>$(builddir)/xml_prince_postprocess.out
	
	prince -vvv --script=scripts/prince_check_margins.js --script=scripts/prince_shave_index.js $(builddir)/pdf/cll_processed_xhtml_pdf.html $(builddir)/cll.pdf
	touch $(builddir)/pdf.done
ifdef copydir
	mkdir -p $(copydir)
	cp $(builddir)/cll.pdf $(copydir)/cll.pdf
endif

#*******
# EPUB
#*******
.PHONY: epub
epub: $(builddir)/cll.epub
# Note that the epub doesn't rely on the PDF, but rather on the HTML
# that is used to build the PDF, but it amounts to the same thing
# for requirements here.
$(builddir)/cll.epub: $(builddir)/pdf.done
	rm -rf $(builddir)/epub/
	mkdir -p $(builddir)/epub/
	cp $(builddir)/pdf/cll_processed_xhtml_pdf.html $(builddir)/epub/index.html
	cp $(PWD)/scripts/master.css $(builddir)/epub/final.css
	cp -pr $(PWD)/media $(builddir)/epub/
	zip -r $(builddir)/epub.zip $(builddir)/epub/
	ebook-convert $(builddir)/epub.zip $(builddir)/cll.epub
	ebook-meta $(builddir)/cll.epub --authors 'John Woldemar Cowan' --title='The Complete Lojban Language' --comments='$(shell grep -A1 '<p class="releaseinfo">' build/pdf/cll_processed_xhtml_pdf.html | tail -n 1)'  --publisher="The Logical Language Group" --isbn=978-0966028324
ifdef copydir
	mkdir -p $(copydir)
	cp $(builddir)/cll.epub $(copydir)/cll.epub
endif

#*******
# MOBI
#*******
.PHONY: mobi
mobi: $(builddir)/cll.mobi
$(builddir)/cll.mobi: $(builddir)/xhtml_no_chunks.done
	zip -r $(builddir)/xhtml_no_chunks.zip $(builddir)/xhtml_no_chunks/
	ebook-convert $(builddir)/xhtml_no_chunks.zip $(builddir)/cll.mobi
ifdef copydir
	mkdir -p $(copydir)
	cp $(builddir)/cll.mobi $(copydir)/cll.mobi
endif

#*******
# Testing
#*******
coverage: clean xhtml_nochunks pdf
ifneq ($(covcopydir),)
	mkdir -p $(covcopydir)
	cp $(builddir)/cll.pdf $(covcopydir)/cll.pdf
	rm -rf $(covcopydir)/cll-xhtml_no_chunks
	cp -pr $(builddir)/xhtml_no_chunks $(covcopydir)/cll-xhtml_no_chunks
endif
