# biocEDAM
preliminary investigation of biocViews in relation to EDAM ontology

## Installation issues

- the curate.Rmd vignette requires that the requests, json, jsonschema and openai python modules can be imported using reticulate
    - check `reticulate::py_config()` to see where to run pip to install these
- use `BiocManager::install('vjcitn/biocEDAM')` to install this package

## Purpose

[biocViews](https://bioconductor.org/packages/biocViews) is an ad hoc vocabulary in
the form of a graphNEL instance with over 400 terms.  [EDAM](https://edamontology.org)
is an OWL model of a vocabulary devoted to concepts of data analysis and data management
in the biosciences.  This package unites these two resources with the objective of
permitting exploration that will lead to formal ontological tagging of all Bioconductor
software and data packages and workflows.

## Tools

### bvbrowse

This function starts a shiny app that presents term-filtered sets of packages
and their views annotation.

![](https://github.com/vjcitn/biocEDAM/blob/main/BrowseGeneSig.png?raw=true)

### allmap

The `allmap` data.frame is the output of [text2term](https://pypi.org/text2term)
applied to biocViews terms for evaluation of similarity to terms
in the EDAM ontology.

```
> head(allmap)
                              Source Term ID    Source Term
0 http://ccb.hms.harvard.edu/t2t/RFzhTje9ucG      BiocViews
1 http://ccb.hms.harvard.edu/t2t/RFzhTje9ucG      BiocViews
2 http://ccb.hms.harvard.edu/t2t/R3hqXkeJtkt       Software
3 http://ccb.hms.harvard.edu/t2t/R4dWXrwrX3W AnnotationData
4 http://ccb.hms.harvard.edu/t2t/R4dWXrwrX3W AnnotationData
5 http://ccb.hms.harvard.edu/t2t/R4dWXrwrX3W AnnotationData
     Mapped Term Label   Mapped Term CURIE
0     GenomeReviews ID      EDAM.DATA:2751
1                 BioC    EDAM.FORMAT:3782
2 Software engineering     EDAM.TOPIC:3372
3           Annotation      EDAM.DATA:2018
4           Annotation EDAM.OPERATION:0226
5          Gene report      EDAM.DATA:0916
                         Mapped Term IRI Mapping Score Tags
0      http://edamontology.org/data_2751         0.459 None
1    http://edamontology.org/format_3782         0.380 None
2     http://edamontology.org/topic_3372         0.721 None
3      http://edamontology.org/data_2018         0.805 None
4 http://edamontology.org/operation_0226         0.805 None
5      http://edamontology.org/data_0916         0.703 None
```
