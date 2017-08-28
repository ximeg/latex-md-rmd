TARGET=report
CONTENT=content

# User-created content in the $(CONTENT) folder
SRC_RMD=$(wildcard $(CONTENT)/*.Rmd)
SRC_MD=$(wildcard $(CONTENT)/*.md)
#SRC_TEX=$(wildcard $(CONTENT)/*.tex)
SRC_BIB=$(CONTENT)/refs.bib

# User-created content copied to the build foder
RMD=$(patsubst $(CONTENT)/%, %, $(SRC_RMD))
MD=$(patsubst $(CONTENT)/%, %, $(SRC_MD))
#TEX=$(patsubst $(CONTENT)/%, %, $(SRC_TEX))
BIB=$(patsubst $(CONTENT)/%, %, $(SRC_BIB))

# Rmd converted to md
RMD_MD=$(patsubst %.Rmd, %.md, $(RMD))
RMD_FIGS=$(patsubst %.Rmd, %_files, $(RMD))
RMD2MD=Rscript -e \
	'library(rmarkdown); \
	 fn <- commandArgs(trailingOnly=T)[1]; \
	 render(fn, run_pandoc=F, clean=F, output_format="md_document")'

# All md are converted to tex
RMD_TEX=$(patsubst %.Rmd, %.tex, $(RMD))
#MD_TEX=$(patsubst %.md, %.tex, $(MD))
#MD2TEX=pandoc --from markdown --natbib --to latex --listings --parse-raw

ALL_MD_FILES=$(MD) $(RMD_MD)

.PHONY:

all: $(TARGET).pdf

$(TARGET).tex: template.tex $(ALL_MD_FILES) $(BIB)
	pandoc $(sort $(ALL_MD_FILES)) --template $< --to latex \
	 --from markdown+tex_math_dollars \
	 --natbib --listings \
	 -o $@

$(TARGET).pdf: $(TARGET).tex $(RMD_FIGS)
	latexmk -bibtex -pdf $(TARGET).tex
	latexmk -c $(TARGET).tex

# Copy original source files to build dir
$(RMD): $(SRC_RMD)
	cp -f $^ .
$(MD): $(SRC_MD) # this rule makes some problems
	cp -f $^ .
$(TEX): $(SRC_TEX)
	cp -f $^ .
$(BIB): $(SRC_BIB)
	cp -f $^ .


# Convert RMarkdown to markdown and images
%.md : %.Rmd
	$(RMD2MD) $^
	rm $(patsubst %.Rmd, %.knit.md, $^); echo "HEY"
	mv $(patsubst %.Rmd, %.utf8.md, $^) $@

## Convert Markdown to TeX
#%.tex : %.md
#	$(MD2TEX) $^ -o $@



clean:
	rm -f $(RMD) $(MD) $(BIB)
	rm -rf $(RMD_FIGS) $(RMD_MD)
	rm -f $(RMD_TEX) $(MD_TEX)
	rm -f $(TARGET).bbl $(TARGET).tex


#build_dir:
#	mkdir -p build
