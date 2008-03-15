all : pms.pdf

clean :
	rm -f *~ *.pdf *.dvi *.log *.aux *.bbl *.blg *.toc *.lol *.loa *.lox \
	    *.lot *.out || true

LATEXFILES = $(shell ls *.tex)

pms.pdf: $(LATEXFILES) pms.bbl
	pdflatex pms
	pdflatex pms
	pdflatex pms

pms.bbl: pms.bib pms.tex
	latex pms
	bibtex pms

pms.dvi: $(LATEXFILES) pms.bbl
	latex pms
	latex pms
	latex pms

upload: pms.pdf
	scp pms.pdf dev.gentoo.org:public_html

.default: all

.phony: clean upload

