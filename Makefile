LATEXFILES = pms.tex introduction.tex eapis.tex names.tex tree-layout.tex \
	profiles.tex profile-variables.tex ebuild-format.tex ebuild-vars.tex \
	dependencies.tex ebuild-functions.tex eclasses.tex \
	ebuild-environment.tex ebuild-env-vars.tex commands.tex \
	pkg-mgr-commands.tex merge.tex metadata-cache.tex glossary.tex \
	appendices.tex eapi-differences.tex desk-reference.tex \
	eapi-cheatsheet.tex pms.cls
SOURCES = $(LATEXFILES) pms.bib Makefile
COMMITINFO = gitHeadLocal.gin

TWOSIDE =

# latex chokes on aux files produced by tex4ht, so remove them
aux-clean = if grep -q rEfLiNK pms.aux 2>/dev/null; then rm -f *.aux; fi

all: pms.pdf

html: pms.html

pms.pdf eapi-cheatsheet.pdf: $(LATEXFILES) pms.bbl $(COMMITINFO)
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

pms.dvi: $(LATEXFILES) pms.bbl $(COMMITINFO)
	$(aux-clean)
	set -e; \
	while true; do \
	  latex pms; \
	  grep -q 'Warning.*Rerun' pms.log || break; \
	done

pms.html: $(LATEXFILES) pms.bbl $(COMMITINFO)
	set -e; sum=''; \
	while true; do \
	  mk4ht xhlatex pms 'xhtml,fn-in,charset=utf-8' ' -cunihtf -utf8'; \
	  oldsum=$${sum}; sum=$$(cksum $@); \
	  test "$${sum}" != "$${oldsum}" || break; \
	done
	@# replace ligatures by their component letters
	LC_ALL=C sed -i "$$(printf 's/\\xef\\xac\\x8%s/%s/g;' \
	  0 ff 1 fi 2 fl 3 ffi 4 ffl)" $@
	@# remove redundant span elements
	LC_ALL=C sed -Ei ':x;/<span(\s+[^>]*)?$$/{N;bx;};'\
	':y;s,(<span\s+[^>]*>)([^<]*)</span>\1,\1\2,;ty' $@
	@# guessable names for sections
	LC_ALL=C sed -Ei \
	  -e 's/("#?)x1-[0-9]*00+([1-9][0-9]?")/\1chapter-\2/g' \
	  -e 's/("#?)x1-[0-9]*00+([1-9][0-9]?(\.[0-9]+)+")/\1section-\2/g' \
	  -e 's/("#?)x1-[0-9]*00+([A-Z](\.[0-9]+)*")/\1appendix-\2/g' $@

pms.bbl: pms.bib $(LATEXFILES) $(COMMITINFO)
	$(aux-clean)
	latex pms
	bibtex pms

$(COMMITINFO): $(SOURCES)
	@# see gitinfo2 documentation
	reltag=$$(git describe --tags --long --always --dirty='-*' \
	  --match='eapi-*-approved*' 2>/dev/null); \
	if test -n "$${reltag}"; then \
	  TZ=UTC git log -1 --date=short-local --decorate=short \
	    --pretty="format:\usepackage[%%%n  shash={%h},%n\
	  lhash={%H},%n  authname={%an},%n  authemail={%ae},%n\
	  authsdate={%ad},%n  authidate={%ai},%n  authudate={%at},%n\
	  commname={%cn},%n  commemail={%ce},%n  commsdate={%cd},%n\
	  commidate={%ci},%n  commudate={%ct},%n  refnames={%d},%n\
	  reltag={$${reltag}}%n]{gitexinfo}%n" > $@; \
	fi

dist: $(SOURCES) $(COMMITINFO) pms.pdf pms.html
	PV='$(PV)'; \
	if test -z "$${PV}"; then \
	  current_eapi=$$(sed -n 's/.*CurrentEAPIIs{\(.*\)}.*/\1/p' pms.tex); \
	  commit_date=$$(sed -n \
	    's/.*commsdate={\([0-9]*\)-\([0-9]*\)-\([0-9]*\)}.*/\1\2\3/p' \
	    $(COMMITINFO)); \
	  PV=$${current_eapi}_p$${commit_date}; \
	fi; \
	echo "PV = $${PV}"; \
	tar -cJf pms-"$${PV}".tar.xz --transform="s%^%pms-$${PV}/%" \
	  $(SOURCES) $(COMMITINFO) && \
	tar -cJf pms-"$${PV}"-prebuilt.tar.xz --transform="s%^%pms-$${PV}/%" \
	  pms.pdf eapi-cheatsheet.pdf pms*.html pms.css

upload: pms.pdf pms.html
	scp pms.pdf eapi-cheatsheet.pdf pms*.html pms.css \
	  dev.gentoo.org:public_html/pms/head/

clean:
	rm -f *~ *.pdf *.dvi *.log *.aux *.bbl *.blg *.toc *.lol *.loa *.lox \
	  *.lot *.out *.html *.css *.png *.4ct *.4tc *.idv *.lg *.tmp *.xref

maintainer-clean: clean
	rm -f $(COMMITINFO)

.PHONY: all html dist upload clean maintainer-clean

.DELETE_ON_ERROR:
.NOTPARALLEL:
