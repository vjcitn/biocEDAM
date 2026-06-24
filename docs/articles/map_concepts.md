<div id="main" class="col-md-9" role="main">

# Mapping free text to ontology terms with map\_concepts

<div class="section level2">

## Introduction

`map_concepts()` and `map_concepts_edam()` translate free text — such as
a dataset description, abstract, or workflow summary — into structured
ontology term mappings using a two-stage LLM pipeline backed by the [EBI
OLS4](https://www.ebi.ac.uk/ols4) ontology search service.

**Stage 1** extracts a list of biological, medical, or computational
concepts from the input text using a plain LLM call (no external tools).

**Stage 2** looks up each concept individually in OLS4 via a fresh LLM
conversation, returning a term label. R code then resolves that label to
a canonical IRI via the OLS4 REST API, keeping the LLM out of IRI
assignment entirely. Each concept receives its own fresh conversation so
that context never accumulates across concepts — a key safeguard against
the hallucinated IRIs that arise when a single long conversation handles
many tool calls.

</div>

<div class="section level2">

## Requirements

Two external dependencies are needed for live use. When either is absent
the code in this vignette falls back automatically to stored mock
results so the vignette still builds and displays representative output.

**1. Anthropic API key** — set before calling any `map_concepts`
function:

<div id="cb1" class="sourceCode">

``` r
Sys.setenv(ANTHROPIC_API_KEY = "your-key-here")
```

</div>

**2. OLS4 MCP bridge** — `npx` and `mcp-remote` must be on the system
PATH. Install once with:

<div id="cb2" class="sourceCode">

``` bash
npm install -g mcp-remote
```

</div>

</div>

<div class="section level2">

## map\_concepts: multi-ontology mapping

<div class="section level3">

### A bioinformatics workflow description

`map_concepts()` searches across all ontologies available in OLS4,
selecting the most appropriate one for each concept. The `max_concepts`
parameter caps the number of OLS4 lookups, which is useful for long
texts.

<div id="cb3" class="sourceCode">

``` r
wf_text <- paste(
    "The workflow for Illumina-sequenced ARTIC data builds on the RNASeq",
    "workflow for paired-end data using the same steps for mapping and variant",
    "calling, but adds extra logic for trimming ARTIC primer sequences off",
    "reads with the ivar package."
)
```

</div>

When an API key and MCP bridge are available, run live:

<div id="cb4" class="sourceCode">

``` r
if (interactive())
    wf <- map_concepts(wf_text, max_concepts = 8)
```

</div>

The vignette uses a pre-computed result:

<div id="cb5" class="sourceCode">

``` r
wf <- readRDS(system.file("extdata", "mock_wf_map_concepts.rds",
                           package = "biocEDAM"))
as.data.frame(wf)[, c("input_text", "term_label", "obo_id", "ontology")]
```

</div>

    ##                      input_text                 term_label              obo_id
    ## 1           Illumina sequencing    Illumina dye sequencing             MI:2322
    ## 2               RNASeq workflow                    RNA-Seq     EDAM:topic_3170
    ## 3                mapping; reads             Sequence trace      EDAM:data_0924
    ## 4 variant calling; ivar package            Variant calling EDAM:operation_3227
    ## 5               primer trimming          Sequence trimming EDAM:operation_3192
    ## 6        ARTIC primer sequences amplicon pcr primer scheme     GENEPIO:0001456
    ##   ontology
    ## 1       MI
    ## 2     EDAM
    ## 3     EDAM
    ## 4     EDAM
    ## 5     EDAM
    ## 6  GENEPIO

Note that `deduplicate = TRUE` (the default) collapses rows that resolve
to the same IRI, recording all source concepts in the `input_text` field
separated by `"; "`.

</div>

<div class="section level3">

### A cardiovascular genomics abstract

For a longer, more heterogeneous text `map_concepts()` spans multiple
ontologies — MONDO for diseases, EFO for study designs, EDAM for
computational methods:

<div id="cb7" class="sourceCode">

``` r
cvd_text <- paste(
    "The Cardiovascular Disease working group considered early-onset coronary",
    "artery disease, stroke, atrial fibrillation, congestive heart failure and",
    "type 2 diabetes. Genome-wide association studies provide a powerful tool",
    "to identify common variants. Comprehensive molecular phenotyping is",
    "performed using genomic, transcriptomic, proteomics, and metabolomic",
    "approaches."
)
```

</div>

<div id="cb8" class="sourceCode">

``` r
if (interactive())
    cvd <- map_concepts(cvd_text, max_concepts = 12)
```

</div>

<div id="cb9" class="sourceCode">

``` r
cvd <- readRDS(system.file("extdata", "mock_cvd_map_concepts.rds",
                            package = "biocEDAM"))
as.data.frame(cvd)[, c("input_text", "term_label", "obo_id", "ontology")]
```

</div>

    ##                         input_text                    term_label
    ## 1          coronary artery disease      coronary artery disorder
    ## 2                           stroke               stroke disorder
    ## 3              atrial fibrillation           Atrial fibrillation
    ## 4         congestive heart failure      congestive heart failure
    ## 5                  type 2 diabetes      type 2 diabetes mellitus
    ## 6  genome-wide association studies genome-wide association study
    ## 7                         genomics                      Genomics
    ## 8                  transcriptomics               Transcriptomics
    ## 9                       proteomics                    Proteomics
    ## 10                    metabolomics                  Metabolomics
    ##             obo_id ontology
    ## 1    MONDO:0005010    MONDO
    ## 2    MONDO:0005098    MONDO
    ## 3       HP:0005110       HP
    ## 4    MONDO:0005009    MONDO
    ## 5    MONDO:0005148    MONDO
    ## 6      EFO:0001360      EFO
    ## 7  EDAM:topic_0622     EDAM
    ## 8  EDAM:topic_3308     EDAM
    ## 9  EDAM:topic_0121     EDAM
    ## 10 EDAM:topic_3172     EDAM

</div>

</div>

<div class="section level2">

## map\_concepts\_edam: EDAM-only mapping

`map_concepts_edam()` restricts both the LLM search and the OLS4 REST
label resolution to the EDAM ontology. EDAM has four sub-trees:

| Sub-tree    | Scope                                      |
|-------------|--------------------------------------------|
| `topic`     | Research areas and scientific domains      |
| `operation` | Computational steps and analytical methods |
| `data`      | Data types and information entities        |
| `format`    | File formats and data exchange standards   |

<div id="cb11" class="sourceCode">

``` r
if (interactive())
    wf_edam <- map_concepts_edam(wf_text, max_concepts = 8)
```

</div>

<div id="cb12" class="sourceCode">

``` r
wf_edam <- readRDS(system.file("extdata", "mock_wf_map_concepts_edam.rds",
                                package = "biocEDAM"))
as.data.frame(wf_edam)[, c("input_text", "term_label", "obo_id")]
```

</div>

    ##            input_text         term_label              obo_id
    ## 1 Illumina sequencing     DNA sequencing EDAM:operation_3218
    ## 2     RNASeq workflow            RNA-Seq     EDAM:topic_3170
    ## 3             mapping Sequence alignment EDAM:operation_0292
    ## 4     variant calling    Variant calling EDAM:operation_3227
    ## 5     primer trimming  Sequence trimming EDAM:operation_3192

<div class="section level3">

### Scope limitations

EDAM does not cover clinical phenotypes, diseases, spatial statistics,
or general study designs. For the cardiovascular text above,
`map_concepts_edam()` would return very few rows — only the omics method
concepts (genomics, transcriptomics, proteomics) have good EDAM
coverage. Use `map_concepts()` for mixed or clinically-oriented texts.

</div>

</div>

<div class="section level2">

## Parameters

| Parameter         | Default            | Purpose                                               |
|-------------------|--------------------|-------------------------------------------------------|
| `max_concepts`    | `Inf`              | Cap Stage 2 lookups; use 8–15 for long texts          |
| `deduplicate`     | `TRUE`             | Collapse rows with identical IRIs                     |
| `definition`      | `FALSE`            | Fetch OLS4 definitions (one extra REST call per term) |
| `label_match`     | `FALSE`            | Add `llm_label`/`label_match` diagnostic columns      |
| `ontology_filter` | `NULL`             | Force REST search to a specific ontology              |
| `tools`           | `ols4_mcp_tools()` | Pre-loaded MCP tools; reuse to avoid bridge restarts  |

Pre-loading the MCP tools is useful when calling `map_concepts`
repeatedly:

<div id="cb14" class="sourceCode">

``` r
if (interactive()) {
    tls <- ols4_mcp_tools()
    r1  <- map_concepts(text1, tools = tls)
    r2  <- map_concepts(text2, tools = tls)
}
```

</div>

</div>

<div class="section level2">

## Curation

All outputs require human review before use. Common failure modes
include:

-   A plausible term label that resolves to an unrelated IRI via OLS4
    search
-   A concept mapped to an ontology whose scope does not match (e.g. a
    disease concept mapped to a GO biological process)
-   A spurious EDAM term returned for a concept outside EDAM’s scope

Setting `definition = TRUE` adds authoritative OLS4 definitions, which
makes it easier to judge whether a mapping is appropriate:

<div id="cb15" class="sourceCode">

``` r
if (interactive()) {
    wf_def <- map_concepts_edam(wf_text, max_concepts = 8, definition = TRUE)
    print(wf_def[, c("term_label", "definition")])
}
```

</div>

Inspect `term_label` against `input_text` for each row and discard
implausible mappings before treating results as authoritative.

</div>

<div class="section level2">

## Inspecting prompts

All prompts used internally can be inspected and customised via
`read_prompt()`:

<div id="cb16" class="sourceCode">

``` r
cat(read_prompt("extract_concepts.txt"))
```

</div>

    ## Identify the most important biological, medical, and technical concepts in the input text.
    ## Return each as a short phrase (2–5 words) that names a well-known concept likely to have
    ## an entry in a biomedical or computational ontology.
    ## 
    ## Diversity rules — apply these strictly:
    ## - Cluster related phrases first. If several phrases describe variations of the same idea
    ##   (e.g. "spatial analysis", "spatial data analysis", "spatial single-cell analysis"),
    ##   keep only the single most informative representative of that cluster.
    ## - Cover distinct facets of the text. Choose concepts that span different categories such
    ##   as: biology domain, cell or tissue type, experimental assay or technology, data type,
    ##   and computational method. Do not return five concepts from the same facet.
    ## - Aim for 5–10 well-separated concepts total.
    ## 
    ## Prefer broader, established concept names over narrow or implementation-specific ones.
    ## For example, prefer "spatial transcriptomics" over "SpatialFeatureExperiment S4 object".
    ## 
    ## Exclude:
    ## - Package names, software class names, and implementation details
    ##   (e.g. "SpatialFeatureExperiment", "S4 class", "ggplot2", "Seurat object")
    ## - Author names, institution names, URLs, and numeric values
    ## - Generic words with no standalone ontology meaning (e.g. "patients", "study",
    ##   "analysis", "individuals", "data", "approach", "method")
    ## - Vague relational or descriptive phrases that describe properties or relationships
    ##   rather than named entities (e.g. "rare risk variants", "protective variants",
    ##   "common variants", "genetic factors", "risk factors", "disease phenotypes")
    ## 
    ## When in doubt, prefer to omit rather than include a borderline phrase.

<div id="cb18" class="sourceCode">

``` r
cat(read_prompt("lookup_edam_concept.txt"))
```

</div>

    ## Use the OLS search tools to find the best matching term in the EDAM ontology for the concept below.
    ## You MUST restrict your search to the EDAM ontology by passing ontology=edam to the search tool.
    ## 
    ## EDAM has four sub-trees — use the most appropriate one:
    ## - topic:     a research area, scientific domain, or field of study
    ##              (e.g. Genomics, Transcriptomics, Sequence analysis)
    ## - operation: a computational step, algorithm, or analytical method
    ##              (e.g. Sequence alignment, Variant calling, RNA-Seq quantification)
    ## - data:      a type of data, dataset, or information entity
    ##              (e.g. DNA sequence, Gene expression profile, Sequence reads)
    ## - format:    a file format or data exchange standard
    ##              (e.g. FASTQ, VCF, BAM, BED)
    ## 
    ## After searching with ontology=edam, reply with exactly:
    ## LABEL: <the exact term label as it appears in the EDAM search results>
    ## ONTOLOGY: EDAM
    ## RATIONALE: <one sentence explaining which EDAM sub-tree applies and why this term matches>
    ## 
    ## If no EDAM term is a reasonable match, reply with:
    ## LABEL: none
    ## ONTOLOGY: EDAM
    ## RATIONALE: <why no EDAM term fits>

</div>

<div class="section level2">

## Session information

<div id="cb20" class="sourceCode">

``` r
sessionInfo()
```

</div>

    ## R version 4.6.0 (2026-04-24)
    ## Platform: aarch64-apple-darwin23
    ## Running under: macOS Sequoia 15.7.7
    ## 
    ## Matrix products: default
    ## BLAS:   /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRblas.0.dylib 
    ## LAPACK: /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1
    ## 
    ## locale:
    ## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    ## 
    ## time zone: America/New_York
    ## tzcode source: internal
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] biocEDAM_0.2.23  biocViews_1.80.0 BiocStyle_2.40.0
    ## 
    ## loaded via a namespace (and not attached):
    ##   [1] DBI_1.3.0            bitops_1.0-9         RBGL_1.88.0         
    ##   [4] httr2_1.2.3          rlang_1.2.0          magrittr_2.0.5      
    ##   [7] otel_0.2.0           compiler_4.6.0       RSQLite_3.53.2      
    ##  [10] png_0.1-9            systemfonts_1.3.2    vctrs_0.7.3         
    ##  [13] rvest_1.0.5          stringr_1.6.0        pkgconfig_2.0.3     
    ##  [16] crayon_1.5.3         fastmap_1.2.0        XVector_0.52.0      
    ##  [19] dbplyr_2.6.0         promises_1.5.0       rmarkdown_2.31      
    ##  [22] tzdb_0.5.0           graph_1.90.0         ragg_1.5.2          
    ##  [25] purrr_1.2.2          bit_4.6.0            xfun_0.59           
    ##  [28] cachem_1.1.0         jsonlite_2.0.0       blob_1.3.0          
    ##  [31] later_1.4.8          R6_2.6.1             bslib_0.11.0        
    ##  [34] stringi_1.8.7        reticulate_1.46.0    brio_1.1.5          
    ##  [37] lubridate_1.9.5      jquerylib_0.1.4      Seqinfo_1.2.0       
    ##  [40] Rcpp_1.1.1-1.1       bookdown_0.47        knitr_1.51          
    ##  [43] readr_2.2.0          IRanges_2.46.0       Matrix_1.7-5        
    ##  [46] httpuv_1.6.17        igraph_2.3.2         timechange_0.4.0    
    ##  [49] tidyselect_1.2.1     yaml_2.3.12          websocket_1.4.4     
    ##  [52] RUnit_0.4.33.1       curl_7.1.0           processx_3.9.0      
    ##  [55] rjsoncons_1.3.3      qpdf_1.4.1           lattice_0.22-9      
    ##  [58] tibble_3.3.1         Biobase_2.72.0       shiny_1.14.0        
    ##  [61] withr_3.0.3          KEGGREST_1.52.0      S7_0.2.2            
    ##  [64] askpass_1.2.1        evaluate_1.0.5       desc_1.4.3          
    ##  [67] BiocFileCache_3.2.0  xml2_1.6.0           Biostrings_2.80.1   
    ##  [70] pillar_1.11.1        BiocManager_1.30.27  filelock_1.0.3      
    ##  [73] DT_0.34.0            stats4_4.6.0         generics_0.1.4      
    ##  [76] RCurl_1.98-1.19      chromote_0.5.1       BiocVersion_3.23.1  
    ##  [79] hms_1.1.4            S4Vectors_0.50.1     coro_1.1.0          
    ##  [82] xtable_1.8-8         glue_1.8.1           tools_4.6.0         
    ##  [85] AnnotationHub_4.2.0  ellmer_0.4.1         pdftools_3.9.0      
    ##  [88] fs_2.1.0             XML_3.99-0.23        grid_4.6.0          
    ##  [91] tidyr_1.3.2          gh_1.6.0             AnnotationDbi_1.74.0
    ##  [94] btw_1.2.1            cli_3.6.6            rappdirs_0.3.4      
    ##  [97] textshaping_1.0.5    dplyr_1.2.1          sass_0.4.10         
    ## [100] digest_0.6.39        BiocGenerics_0.58.1  htmlwidgets_1.6.4   
    ## [103] BiocPkgTools_1.30.0  memoise_2.0.1        htmltools_0.5.9     
    ## [106] pkgdown_2.2.0        lifecycle_1.0.5      httr_1.4.8          
    ## [109] mime_0.13            bit64_4.8.2

</div>

</div>
