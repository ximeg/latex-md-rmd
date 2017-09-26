#################### DEFINITIONS #######################
NAME := report
LATEX_ENGINE := xelatex  # Options are  pdflatex | lualatex | xelatex
CONTENT := content
BUILD := build

TARGET := $(BUILD)/$(NAME)

all: exclude $(NAME).pdf

exclude:
		echo "# Remove preceding '+' to exclude particular file from the build process" > exclude
		find $(CONTENT) -iname "*.Rmd" -or -iname "*.md" | sed s/^/+/g >> exclude

# User-created content in the $(CONTENT) folder
EXCLUDE := $(shell cat exclude)
SRC := $(filter %.Rmd %.md %.tex %.yaml %.bib, $(wildcard $(CONTENT)/*))
SRC := $(filter-out $(EXCLUDE), $(SRC))
BLD_SRC := $(patsubst $(CONTENT)/%, $(BUILD)/%, $(SRC))

# User-created content copied to the build foder
RMD := $(filter %.Rmd, $(BLD_SRC))
MD := $(filter  %.md, $(BLD_SRC))
TEX := $(filter %.tex, $(BLD_SRC))
BIB := $(filter %.bib, $(BLD_SRC))

# Rmd converted to md
RMD_MD := $(RMD:.Rmd=.md)
RMD2MD := Rscript -e \
	'library(rmarkdown); \
	 fn <- commandArgs(trailingOnly=T)[1]; \
	 render(fn, run_pandoc=F, clean=F, output_format="md_document")'
ALL_MD_FILES := $(sort $(MD) $(RMD_MD))

#################### RULES #######################
all: $(NAME).pdf

$(NAME).pdf : $(TARGET).pdf
	cp -fl $< $@

# prep build directory
$(BUILD)/imgs : $(BUILD) imgs
	cd $(BUILD) && ln -sfv ../imgs imgs -T

$(BUILD):
	mkdir -p $(BUILD)

# final goal - compile pdf with LaTeX
$(TARGET).pdf: $(BUILD) $(BUILD)/imgs $(TARGET).tex $(BIB)
	cd $(BUILD) ; latexmk -bibtex -pdf -$(LATEX_ENGINE) $(NAME).tex

# create the main tex file
$(TARGET).tex: $(BUILD)/template.tex $(ALL_MD_FILES) $(TEX)
	pandoc $(ALL_MD_FILES) --template $< --to latex \
	 --from markdown+tex_math_dollars \
	 --natbib --listings \
	 --latexmathml \
	 -o $@

# Copy original source files to build dir (makes HARDLINKS)
$(BLD_SRC): $(BUILD) $(SRC) copy2build
copy2build:
	cp -lf $(SRC) $(BUILD)/

# copy latex template to the build dir
$(BUILD)/template.tex : $(BUILD) template.tex
	cp -lf template.tex $(BUILD)/

# Process Rmd: knit them and convert them to md
%.md: %.Rmd $(BUILD)/_output.yaml
	$(RMD2MD) $<
	rm $(patsubst %.Rmd, %.knit.md, $<)
	mv $(patsubst %.Rmd, %.utf8.md, $<) $@


# Remove LaTeX output, except for PDF
clean:
	cd $(BUILD) ; latexmk -verbose -c $(NAME).tex -f
	rm -f $(BUILD)/$(NAME).tex
	rm -f $(filter %.bbl %.log %.aux, $(wildcard $(BUILD)/$(NAME).*))

# Remove the whole build directory
distclean:
	rm -rf $(BUILD)
	rm -f exclude
