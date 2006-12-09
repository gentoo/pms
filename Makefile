all : pms.pdf

check : pms.pdf
	xpdf pms.pdf

clean :
	rm *~ *.pdf *.dvi *.log *.aux || true

LATEXFILES = \
	pms.tex \
	introduction.tex \
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

pms.dvi: $(LATEXFILES)
	latex pms.tex

.default: pms.pdf

.phony: clean

