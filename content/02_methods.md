# How it works

The document is built up from `Rmd` and `md` documents stored in the folder
`content`. All of them get converted into \LaTeX{} and inserted together into
the body of a \LaTeX{} template file called `latex.template`. The template file
determines the final look and feel of the report, so feel free to adjust it to
fit your needs.

## Under the hood

To get started, place your content into the (`r`)`markdown` files in the
`content` folder. You can conveniently edit `rmarkdown` files using `RStudio`.
When done, call `make`. This will run all `R` code chunks and convert
`rmarkdown`→`markdown`, then all markdown files are fed to `pandoc` that generates a single \LaTeX{} file from them using the template file. Finally, the generated \LaTeX{} report file is translated to PDF, calling `bibtex` if necessary. The order of the included files is determined by their names.

`GNU Make` automatically determines which files have been update since last run
and processes only what has to be processed.

## How to use

If you want to include images into your document, feel free to do it using the
normal `markdown` syntax, like this `![caption](imgs/path_to_image)`. For more
control, the image width can be specified along with a \LaTeX{} label, which
allows to reference this image later (see Figure \ref{fig:statue}). Here is an
example how to do this:

```
![\label{fig:statue}Statue of Nero, a Flemish comic, Hoeilaart (Flemish Brabant, Belgium)](imgs/Hoeilaart_station_Nero_beeld.JPG){ width=25% }
```

![\label{fig:statue}Statue of Nero, a Flemish comic, Hoeilaart (Flemish Brabant, Belgium)](imgs/Hoeilaart_station_Nero_beeld.JPG){ width=25% }


\begin{wrapfigure}[4]{r}{25mm}
  \hfill\includegraphics[width=17mm]
    {imgs/Hoeilaart_station_Nero_beeld.JPG}
\end{wrapfigure}

For even more control, you can always embed \LaTeX{} code directly into your
`markdown` files. This means, you can use `figure` environment to make floating
figures like this:

```
\begin{wrapfigure}[4]{r}{25mm}
  \hfill\includegraphics[width=17mm]
    {imgs/Hoeilaart_station_Nero_beeld.JPG}
\end{wrapfigure}
```

**Citations** are simple: `[@paper1]` or `@paper2` produce [@paper1] and @paper2.

