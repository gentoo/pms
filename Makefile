all : pms.pdf
html : pms.html

clean :
	rm -f *~ *.pdf *.dvi *.log *.aux *.bbl *.blg *.toc *.lol *.loa *.lox \
	    *.lot *.out *.html *.css *.png *.4ct *.4tc *.idv *.lg *.tmp *.xref

maintainer-clean: clean
	rm -f vc.tex

LATEXFILES := $(filter-out vc.tex,$(wildcard *.tex)) pms.cls

pms.pdf: $(LATEXFILES) pms.bbl vc.tex eapi-cheatsheet.pdf
	@# latex chokes on aux files produced by tex4ht, so remove them
	if grep -q rEfLiNK pms.aux 2>/dev/null; then rm -f *.aux; fi
	pdflatex pms
	pdflatex pms
	pdflatex eapi-cheatsheet
	pdflatex pms

pms.html: $(LATEXFILES) pms.bbl vc.tex
	@# need to do it twice to make the big env var table work
	mk4ht xhlatex pms xhtml,fn-in
	mk4ht xhlatex pms xhtml,fn-in
	@# some www servers ignore meta tags, resulting in a wrong charset.
	@# therefore recode the very few non-ascii characters
	recode -d l1..h3 pms.html
	@# declare encoding as utf-8, although it is pure ascii
	LC_ALL=C sed -i -e '/<?xml\|<meta/s/iso-8859-1/utf-8/' pms.html
	@# work around irregularity in how links to longtables are
	@# formatted in the List of Tables
	LC_ALL=C sed -i -e '/<span class="lotToc" >&#x00A0;/{N;N;s/\(&#x00A0;<a \nhref="[^"]\+">\)\([0-9A-Z.]\+\)[ \n]/\2\1/}' pms.html
	@# fix xhtml syntax in longtable captions
	LC_ALL=C sed -i -e 's%</td>\( *<div class="multicolumn"\)%\1%;tx;b;:x;s%</tr>%</td>&%;t;n;bx' pms.html
	@# indent algorithms properly, and avoid adding extra vertical
	@# space in Konqueror
	LC_ALL=C sed -i -e 's/span style="width:/span style="display:-moz-inline-box;display:inline-block;height:1px;width:/' pms.html
	@# align algorithm line numbers properly
	LC_ALL=C sed -i -e '/<span class="ALCitem">/{N;s/\n\(class="[^"]\+">\)\([0-9]:<\/span>\)/\1\&#x2007;\2/}' pms.html
	@# fix broken span on title page
	LC_ALL=C sed -i -e '/<\/span><span $$/{N;s/<\/span><span [^>]*>\(&[a-z]uml;\)/\1/}' pms.html

pms.bbl: pms.bib pms.tex vc.tex eapi-cheatsheet.pdf
	latex pms
	bibtex pms

eapi-cheatsheet.pdf: vc.tex
	pdflatex eapi-cheatsheet

eapi-cheatsheet-nocombine.pdf: vc.tex
	@# cheat sheet with separate pages, for proofreading
	pdflatex -jobname eapi-cheatsheet-nocombine \
	  '\PassOptionsToClass{nocombine}{leaflet}\input{eapi-cheatsheet.tex}'

vc.tex: $(LATEXFILES) vc-git.awk
	/bin/sh ./vc

pms.dvi: $(LATEXFILES) pms.bbl vc.tex
	latex pms
	latex pms
	latex pms

dist: $(LATEXFILES) pms.bib vc vc-git.awk vc.tex Makefile
	@if test -z $(PV); then \
	  echo "Usage: $(MAKE) $@ PV=<version>"; false; \
	fi
	tar -cJf pms-$(PV).tar.xz --transform='s%^%pms-$(PV)/%' $^

upload:
	scp pms.pdf eapi-cheatsheet.pdf pms*.html pms.css \
	  dev.gentoo.org:public_html/pms/head/

.default: all

.phony: clean maintainer-clean dist upload
