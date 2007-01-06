all : pms.pdf

check : pms.pdf
	xpdf pms.pdf

clean :
	rm *~ *.pdf *.dvi *.log *.aux *.bbl *.blg *.toc *.lol *.loa || true

LATEXFILES = $(shell ls *.tex)

pms.pdf: pms.dvi
	dvipdf $<

pms.bbl: pms.bib pms.tex
	latex pms
	bibtex pms

pms.dvi: $(LATEXFILES) pms.bbl
	latex pms
	latex pms

.default: pms.pdf

.phony: clean

