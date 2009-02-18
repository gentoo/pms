all : pms.pdf
html : pms.html

clean :
	rm -f *~ *.pdf *.dvi *.log *.aux *.bbl *.blg *.toc *.lol *.loa *.lox \
	    *.lot *.out *.html *.css *.png *.4ct *.4tc *.idv *.lg *.tmp *.xref vc.tex || true

LATEXFILES = $(shell ls *.tex)
LISTINGFILES = $(shell ls *.listing)
SOURCEFILES = $(LATEXFILES) $(LISTINGFILES)

pms.pdf: $(SOURCEFILES) pms.bbl vc.tex
	pdflatex pms
	pdflatex pms
	pdflatex pms

pms.html: $(SOURCEFILES) pms.bbl
	@# need to do it twice to make the big env var table work
	xhlatex pms
	xhlatex pms
	@# work around irregularity in how links to longtables are
	@# formatted in the List of Tables
	sed -i -e '/<span class="lotToc" >&#x00A0;/{N;N;s/\(&#x00A0;<a \nhref="[^"]\+">\)\([0-9.]\+\)\n/\2\1/}' pms.html
	@# indent algorithms properly, and avoid adding extra vertical
	@# space in Konqueror
	sed -i -e 's/span style="width:/span style="display:-moz-inline-box;display:inline-block;height:1px;width:/' pms.html
	@# align algorithm line numbers properly
	sed -i -e '/<span class="ALCitem">/{N;s/\n\(class="[^"]\+">\)\([0-9]:\)<\/span>/\1\&#x2007;\2/}' pms.html

pms.bbl: pms.bib pms.tex vc.tex
	latex pms
	bibtex pms

vc.tex: pms.tex
	/bin/sh ./vc

pms.dvi: $(SOURCEFILES) pms.bbl
	latex pms
	latex pms
	latex pms

upload: pms.pdf
	scp pms.pdf dev.gentoo.org:public_html

.default: all

.phony: clean upload

