NAME=report
CONTENT=content
BUILD=build

TARGET=$(BUILD)/$(NAME)

# User-created content in the $(CONTENT) folder
SRC_RMD=$(wildcard $(CONTENT)/*.Rmd)
SRC_MD=$(wildcard $(CONTENT)/*.md)
#SRC_TEX=$(wildcard $(CONTENT)/*.tex)
SRC_BIB=$(CONTENT)/refs.bib

# User-created content copied to the build foder
RMD=$(patsubst $(CONTENT)/%, $(BUILD)/%, $(SRC_RMD))
MD=$(patsubst $(CONTENT)/%, $(BUILD)/%, $(SRC_MD))
#TEX=$(patsubst $(CONTENT)/%, $(BUILD)/%, $(SRC_TEX))
BIB=$(patsubst $(CONTENT)/%, $(BUILD)/%, $(SRC_BIB))

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

.PHONY: build_dir

all: build_dir $(TARGET).pdf

$(TARGET).tex: $(BUILD)/template.tex $(ALL_MD_FILES) $(BIB)
	pandoc $(sort $(ALL_MD_FILES)) --template $< --to latex \
	 --from markdown+tex_math_dollars \
	 --natbib --listings \
	 -o $@

$(TARGET).pdf: $(TARGET).tex $(RMD_FIGS)
	cd $(BUILD) ; pwd; latexmk -bibtex -pdf $(NAME).tex ; latexmk -c $(NAME).tex

# Copy original source files to build dir
#$(RMD): $(SRC_RMD)
#	cp -f $^ $(BUILD)
#$(MD): $(SRC_MD) # this rule makes some problems
#	cp -f $^ $(BUILD)
#$(TEX): $(SRC_TEX)
#	cp -f $^ $(BUILD)
#$(BIB): $(SRC_BIB)
#	cp -f $^ $(BUILD)
$(BUILD)/template.tex: template.tex
	cp -f $^ $(BUILD)


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


build_dir:
	mkdir -p $(BUILD)
	cp -d content/* $(BUILD)/
	#cd $(BUILD) && ln -sf ../imgs imgs
