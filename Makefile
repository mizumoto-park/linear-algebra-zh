# Makefile -- top-level workflow for the Linear Algebra sources.
#
# The upstream per-project Makefile is src/Makefile (book / answers /
# slides / videos / lab).  This file only adds convenient entry points;
# use `make help` to list them.
#
#   make book        build src/book.pdf (English; also builds all
#                    MetaPost/Asymptote figures; takes several minutes)
#   make answers     build src/jhanswer.pdf (answer book; needs book.pdf)
#   make slides      build the beamer slide decks (long!)
#   make zh-test     build src/zh/test-zh.pdf (Chinese font/compile test,
#                    XeLaTeX; fast)
#   make zh-view     open the Chinese test PDF
#   make clean       remove ignored build artifacts under src/ (aux files,
#                    generated figures, book.pdf/jhanswer.pdf; uses
#                    `git clean -Xd`, so tracked files are never touched)
#   make clean-zh    remove Chinese test auxiliary files (keep the PDF)

SRC      := src
SRC_ABS  := $(abspath $(SRC))
LATEX    ?= pdflatex -interaction=nonstopmode

.PHONY: help book answers slides zh-test zh-view clean clean-zh

help:
	@echo "Linear Algebra -- build workflows"
	@echo "  make book       English book      -> $(SRC)/book.pdf"
	@echo "  make answers    answer book       -> $(SRC)/jhanswer.pdf"
	@echo "  make slides     beamer slide decks (long)"
	@echo "  make zh-test    Chinese test      -> $(SRC)/zh/test-zh.pdf (XeLaTeX)"
	@echo "  make zh-view    open the Chinese test PDF"
	@echo "  make clean      git clean -Xd $(SRC)/  (removes ignored artifacts only)"
	@echo "  make clean-zh   remove Chinese test aux files"

book:
	$(MAKE) -C $(SRC) LATEX="$(LATEX)" book.pdf

answers:
	$(MAKE) -C $(SRC) LATEX="$(LATEX)" answers

slides:
	$(MAKE) -C $(SRC) LATEX="$(LATEX)" slides

zh-test:
	cd $(SRC)/zh && TEXINPUTS="$(SRC_ABS)//:" xelatex -interaction=nonstopmode test-zh.tex
	cd $(SRC)/zh && TEXINPUTS="$(SRC_ABS)//:" xelatex -interaction=nonstopmode test-zh.tex
	@echo "Built $(SRC)/zh/test-zh.pdf"

zh-view:
	open $(SRC)/zh/test-zh.pdf

clean:
	git clean -Xd $(SRC)

clean-zh:
	rm -f $(SRC)/zh/test-zh.aux $(SRC)/zh/test-zh.log $(SRC)/zh/test-zh.out $(SRC)/zh/bookans.tex
