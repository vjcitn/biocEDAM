<div id="main" class="col-md-9" role="main">

# Curation of Bioconductor package metadata, targeting EDAM ontology and ELIXIR bio.tools metadata schemas

<div class="section level2">

## Introduction

This vignette is derived almost entirely from collaborative code
supplied by Anh Nguyet Vu of Sage Bionetworks. The purpose is to
illustrate usage of LLM-based transformation to provide systematic
organization and tagging of content available for Bioconductor packages.

Code in this vignette requires that `ANTHROPIC_API_KEY` be defined.

</div>

<div class="section level2">

## Example 1: tximeta

We start with the transformation of vignette content, which may be in
HTML or PDF, based on the structured data extraction code examples given
in a vignette for the ellmer package on CRAN. We prompt Claude to
produce a concise and objective summary of at most 450 words, which is
placed in the `focus` component of the returned data.

<div id="cb1" class="sourceCode">

``` r
if (nchar(Sys.getenv("ANTHROPIC_API_KEY"))>0) {
library(biocEDAM)
content = vig2data("https://bioconductor.org/packages/release/bioc/vignettes/tximeta/inst/doc/tximeta.html")
str(content)
nchar(content$focus)
}
```

</div>

    ## List of 5
    ##  $ author    : chr [1:4] "Michael I. Love" "Charlotte Soneson" "Peter F. Hickey" "Rob Patro"
    ##  $ topics    : chr [1:33] "RNA-seq" "transcript quantification" "salmon" "oarfish" ...
    ##  $ focused   : chr "The tximeta package extends tximport functionality by automating annotation and metadata attachment during RNA-"| __truncated__
    ##  $ coherence : int 88
    ##  $ persuasion: num 0.75

    ## [1] 3033

We then use LLM-based inference to produce associated EDAM tags; see the
`edamize` function for details.

<div id="cb4" class="sourceCode">

``` r
if (nchar(Sys.getenv("ANTHROPIC_API_KEY"))>0) {
substr(content$focus,1,250)
ans = edamize(content$focus, retrieve_k=NULL)
DT::datatable(mkdf(ans))
}
```

</div>

    ## Connected to SemanticSQL database: /Users/vincentcarey/Library/Caches/org.R-project.R/R/BiocFileCache/16883554f1d39_edam.db

    ## Primary ontology prefix: EDAM

<div id="htmlwidget-ac96cb3ee4656e2e9ec3"
class="datatables html-widget html-fill-item"
style="width:100%;height:auto;">

</div>

</div>

<div class="section level2">

## Example 2: MSnbase

<div id="cb7" class="sourceCode">

``` r
if (nchar(Sys.getenv("ANTHROPIC_API_KEY"))>0) {
mm = vig2data("https://bioconductor.org/packages/release/bioc/vignettes/MSnbase/inst/doc/v05-MSnbase-development.html")
uu = edamize(mm$focus, retrieve_k=NULL)
if (is.null(uu)) uu = edamize(mm$focus, retrieve_k=NULL)  # second try
DT::datatable(mkdf(uu))
}
```

</div>

    ## Connected to SemanticSQL database: /Users/vincentcarey/Library/Caches/org.R-project.R/R/BiocFileCache/16883554f1d39_edam.db

    ## Primary ontology prefix: EDAM

<div id="htmlwidget-e5c8c404fe174e4c81bd"
class="datatables html-widget html-fill-item"
style="width:100%;height:auto;">

</div>

</div>

<div class="section level2">

## Caveats

Sometimes there is no result. This pertains to indeterminacy in the LLM
response. Often a second try will get a result. If you have persistent
trouble, please file an issue.

</div>

</div>
