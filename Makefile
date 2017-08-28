NAME=report
CONTENT=content
BUILD=build

TARGET=$(BUILD)/$(NAME)

# User-created content in the $(CONTENT) folder
SRC_RMD=$(wildcard $(CONTENT)/*.Rmd)
SRC_MD=$(wildcard $(CONTENT)/*.md)
SRC_TEX=$(wildcard $(CONTENT)/*.tex)
SRC_BIB=$(CONTENT)/refs.bib

# User-created content copied to the build foder
RMD=$(patsubst $(CONTENT)/%, $(BUILD)/%, $(SRC_RMD))
MD=$(patsubst $(CONTENT)/%, $(BUILD)/%, $(SRC_MD))
TEX=$(patsubst $(CONTENT)/%, $(BUILD)/%, $(SRC_TEX))
BIB=$(patsubst $(CONTENT)/%, $(BUILD)/%, $(SRC_BIB))

# Rmd converted to md
RMD_MD=$(patsubst %.Rmd, %.md, $(RMD))
RMD2MD=Rscript -e \
	'library(rmarkdown); \
	 fn <- commandArgs(trailingOnly=T)[1]; \
	 render(fn, run_pandoc=F, clean=F, output_format="md_document")'


ALL_MD_FILES=$(MD) $(RMD_MD)

.PHONY:

all: $(BUILD) $(TARGET).pdf

$(TARGET).tex: $(BUILD)/template.tex $(ALL_MD_FILES) $(BIB)
	pandoc $(sort $(ALL_MD_FILES)) --template $< --to latex \
	 --from markdown+tex_math_dollars \
	 --natbib --listings \
	 -o $@

$(TARGET).pdf: $(TARGET).tex
	cd $(BUILD) ; pwd; latexmk -bibtex -pdf $(NAME).tex ; latexmk -c $(NAME).tex

# Copy original source files to build dir
$(RMD): $(SRC_RMD)
	cp -f $^ $(BUILD)
$(MD): $(SRC_MD)
	cp -f $^ $(BUILD)
$(TEX): $(SRC_TEX)
	cp -f $^ $(BUILD)
$(BIB): $(SRC_BIB)
	cp -f $^ $(BUILD)
$(BUILD)/template.tex: template.tex
	cp -f $^ $(BUILD)
$(BUILD)/_output.yaml: $(CONTENT)/_output.yaml
	cp -f $^ $(BUILD)


# Convert RMarkdown to markdown and images
%.md : %.Rmd $(BUILD)/_output.yaml
	$(RMD2MD) $<
	rm $(patsubst %.Rmd, %.knit.md, $<)
	mv $(patsubst %.Rmd, %.utf8.md, $<) $@


clean:
	rm -rf $(BUILD)


$(BUILD):
	mkdir -p $(BUILD)
	cd $(BUILD) && ln -sf ../imgs imgs
