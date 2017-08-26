LATEXFILES := $(filter-out vc.tex,$(wildcard *.tex)) pms.cls
SOURCES = $(LATEXFILES) pms.bib vc vc-git.awk Makefile

TWOSIDE =

# latex chokes on aux files produced by tex4ht, so remove them
aux-clean = if grep -q rEfLiNK pms.aux 2>/dev/null; then rm -f *.aux; fi

all: pms.pdf

html: pms.html

pms.pdf eapi-cheatsheet.pdf: $(LATEXFILES) pms.bbl vc.tex
	$(aux-clean)
	set -e; \
	while true; do \
	  pdflatex eapi-cheatsheet; \
	  if test -z '$(TWOSIDE)'; then \
	    pdflatex pms; \
	  else \
	    pdflatex '\PassOptionsToClass{twoside}{pms}\input{pms}'; \
	  fi; \
	  grep -q 'Warning.*Rerun' eapi-cheatsheet.log pms.log || break; \
	done

eapi-cheatsheet-nocombine.pdf: pms.pdf
	@# cheat sheet with separate pages, for proofreading
	set -e; \
	while true; do \
	  pdflatex -jobname eapi-cheatsheet-nocombine \
	    '\PassOptionsToClass{nocombine}{leaflet}\input{eapi-cheatsheet}'; \
	  grep -q 'Warning.*Rerun' eapi-cheatsheet-nocombine.log || break; \
	done

pms.dvi: $(LATEXFILES) pms.bbl vc.tex
	$(aux-clean)
	set -e; \
	while true; do \
	  latex pms; \
	  grep -q 'Warning.*Rerun' pms.log || break; \
	done

pms.html: $(LATEXFILES) pms.bbl vc.tex
	set -e; sum=''; \
	while true; do \
	  mk4ht xhlatex pms xhtml,fn-in; \
	  oldsum=$${sum}; sum=$$(cksum $@); \
	  test "$${sum}" != "$${oldsum}" || break; \
	done
	@# some www servers ignore meta tags, resulting in a wrong charset.
	@# therefore recode the very few non-ascii characters
	recode -d l1..h3 $@
	@# declare encoding as utf-8, although it is pure ascii
	LC_ALL=C sed -i -e '/<?xml\|<meta/s/iso-8859-1/utf-8/' $@
	@# work around irregularity in how links to longtables are
	@# formatted in the List of Tables
	LC_ALL=C sed -i -e '/<span class="lotToc" >&#x00A0;/{N;N;s/\(&#x00A0;<a \nhref="[^"]\+">\)\([0-9A-Z.]\+\)[ \n]\+/\2\1/}' $@
	@# remove redundant span elements
	LC_ALL=C sed -i -e ':x;/<span\(\s\+[^>]*\)\?$$/{N;bx;};:y;s/\(<span\s\+[^>]*>\)\([^<]*\)<\/span>\1/\1\2/;ty' $@

pms.bbl: pms.bib $(LATEXFILES) vc.tex
	$(aux-clean)
	latex pms
	bibtex pms

vc.tex: $(SOURCES)
	/bin/sh ./vc -m

dist: $(SOURCES) vc.tex pms.pdf pms.html
	PV='$(PV)'; \
	if test -z "$${PV}"; then \
	  current_eapi=$$(sed -n 's/.*CurrentEAPIIs{\(.*\)}.*/\1/p' pms.tex); \
	  vc_date=$$(sed -n \
	    's/.*VCDateISO{\([0-9]*\)-\([0-9]*\)-\([0-9]*\)}.*/\1\2\3/p' \
	    vc.tex); \
	  PV=$${current_eapi}_p$${vc_date}; \
	fi; \
	echo "PV = $${PV}"; \
	tar -cJf pms-"$${PV}".tar.xz --transform="s%^%pms-$${PV}/%" \
	  $(SOURCES) vc.tex && \
	tar -cJf pms-"$${PV}"-prebuilt.tar.xz --transform="s%^%pms-$${PV}/%" \
	  pms.pdf eapi-cheatsheet.pdf pms*.html pms.css

upload: pms.pdf pms.html
	scp pms.pdf eapi-cheatsheet.pdf pms*.html pms.css \
	  dev.gentoo.org:public_html/pms/head/

clean:
	rm -f *~ *.pdf *.dvi *.log *.aux *.bbl *.blg *.toc *.lol *.loa *.lox \
	  *.lot *.out *.html *.css *.png *.4ct *.4tc *.idv *.lg *.tmp *.xref

maintainer-clean: clean
	rm -f vc.tex

.PHONY: all html dist upload clean maintainer-clean

.DELETE_ON_ERROR:
.NOTPARALLEL:
