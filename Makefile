all : pms.pdf

check : pms.pdf
	xpdf pms.pdf

clean :
	rm *~ *.pdf *.dvi *.log *.aux *.bbl *.blg *.toc || true

LATEXFILES = \
	pms.tex \
	introduction.tex \
	names.tex \
	tree-layout.tex \
	profiles.tex \
	version-specs.tex \
	base-system.tex \
	ebuild-format.tex \
	ebuild-vars.tex \
	ebuild-functions.tex \
	ebuild-environment.tex \
	ebuild-env-vars.tex \
	ebuild-env-commands.tex

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

