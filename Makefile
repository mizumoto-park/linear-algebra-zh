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
#   make zh-book     build src/zh/book-zh.pdf (Chinese edition; translated
#                    chapters fall back to English until translated)
#   make zh-answers  build src/zh/jhanswer-zh.pdf (Chinese answer book;
#                    needs a prior `make zh-book` which writes bookans.tex)
#   make zh-progress show per-file translation progress
#   make zh-view     open the Chinese test PDF
#   make clean       remove ignored build artifacts under src/ (aux files,
#                    generated figures, book.pdf/jhanswer.pdf; uses
#                    `git clean -Xd`, so tracked files are never touched)
#   make clean-zh    remove Chinese test build artifacts

SRC      := src
SRC_ABS  := $(abspath $(SRC))
LATEX    ?= pdflatex -interaction=nonstopmode

# Files to translate (mirror of book.tex \include list, minus bib/bib
# which stays English in phase 1, plus the cover).
ZH_FILES := cover/covernew pref/pref \
	gr/gr1 gr/gr2 gr/gr3 gr/cas gr/leontief gr/ppivot gr/network \
	vs/vs1 vs/vs2 vs/vs3 vs/fields vs/crystal vs/voting vs/dimen \
	map/map1 map/map2 map/map3 map/map4 map/map5 map/map6 \
	map/lstsqs map/homogeom map/magicsqs map/markov map/erlang \
	det/det1 det/det2 det/det3 det/cramer det/detspeed det/chio \
	det/projplane det/compgraphics \
	jc/jc1 jc/jc2 jc/jc3 jc/jc4 jc/powers jc/pops jc/search jc/recur \
	jc/wilber jc/innerproduct appen/appen

.PHONY: help book answers slides zh-test zh-book zh-answers zh-progress zh-view clean clean-zh

help:
	@echo "Linear Algebra -- build workflows"
	@echo "  make book        English book      -> $(SRC)/book.pdf"
	@echo "  make answers     answer book       -> $(SRC)/jhanswer.pdf"
	@echo "  make slides      beamer slide decks (long)"
	@echo "  make zh-test     Chinese test      -> $(SRC)/zh/test-zh.pdf (XeLaTeX)"
	@echo "  make zh-book     Chinese edition   -> $(SRC)/zh/book-zh.pdf (XeLaTeX)"
	@echo "  make zh-answers  Chinese answers   -> $(SRC)/zh/jhanswer-zh.pdf (XeLaTeX)"
	@echo "  make zh-progress translation progress checklist"
	@echo "  make zh-view     open the Chinese test PDF"
	@echo "  make clean       git clean -Xd $(SRC)/  (removes ignored artifacts only)"
	@echo "  make clean-zh    remove Chinese test aux files"

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

zh-book:
	cd $(SRC)/zh && TEXINPUTS="$(SRC_ABS)//:" xelatex -interaction=nonstopmode book-zh.tex
	cd $(SRC)/zh && makeindex -s $(SRC_ABS)/sty/book.isty book-zh.idx
	cd $(SRC)/zh && TEXINPUTS="$(SRC_ABS)//:" xelatex -interaction=nonstopmode book-zh.tex
	cd $(SRC)/zh && TEXINPUTS="$(SRC_ABS)//:" xelatex -interaction=nonstopmode book-zh.tex
	@echo "Built $(SRC)/zh/book-zh.pdf"

# 答案书中文版：前置条件是先跑过 make zh-book（其写出中文答案 bookans.tex）。
# bookans.tex 中节标题前缀 "Section I:" 为 bookans.sty 写出时烘焙的英文，
# 这里在生成 bookans-zh.tex 时一并汉化为 "第 I 节："。
zh-answers:
	cd $(SRC)/zh && sed -e 's/section {Section I: /section {第 I 节：/' \
	  -e 's/section {Section II: /section {第 II 节：/' \
	  -e 's/section {Section III: /section {第 III 节：/' \
	  -e 's/section {Section IV: /section {第 IV 节：/' \
	  -e 's/section {Section V: /section {第 V 节：/' \
	  -e 's/section {Section VI: /section {第 VI 节：/' \
	  bookans.tex > bookans-zh.tex
	cd $(SRC)/zh && TEXINPUTS="$(SRC_ABS)//:" xelatex -interaction=nonstopmode jhanswer-zh.tex
	cd $(SRC)/zh && TEXINPUTS="$(SRC_ABS)//:" xelatex -interaction=nonstopmode jhanswer-zh.tex
	@echo "Built $(SRC)/zh/jhanswer-zh.pdf"

zh-progress:
	@total=0; done=0; partial=0; \
	for f in $(ZH_FILES); do \
	  total=$$((total+1)); \
	  if [ -f "$(SRC)/zh/$$f.tex" ]; then \
	    if grep -q '^% TRANSLATION-PARTIAL:' "$(SRC)/zh/$$f.tex"; then \
	      partial=$$((partial+1)); printf "  [~] %s (部分初译)\n" "$$f"; \
	    else \
	      done=$$((done+1)); printf "  [x] %s\n" "$$f"; \
	    fi; \
	  else \
	    printf "  [ ] %s\n" "$$f"; \
	  fi; \
	done; \
	printf "进度: %s / %s；部分初译: %s\n" "$$done" "$$total" "$$partial"

zh-view:
	open $(SRC)/zh/test-zh.pdf

clean:
	git clean -Xd $(SRC)

clean-zh:
	rm -f $(SRC)/zh/test-zh.aux $(SRC)/zh/test-zh.log $(SRC)/zh/test-zh.out $(SRC)/zh/bookans.tex
