<div id="main" class="col-md-9" role="main">

# Map concepts to EDAM ontology terms via OLS4

<div class="ref-description section level2">

A focused wrapper around `map_concepts` that restricts all ontology
lookups to the EDAM ontology. The LLM is instructed to search within
EDAM only and to identify which EDAM sub-tree applies (topic, operation,
data, or format); the OLS4 REST label search is also constrained to EDAM
regardless of the LLM's response.

</div>

<div class="section level2">

## Usage

<div class="sourceCode">

``` r
map_concepts_edam(query, ...)
```

</div>

</div>

<div class="section level2">

## Arguments

-   query:

    character(1) free-text input containing one or more biological or
    medical concepts.

-   ...:

    additional arguments passed to `map_concepts`, e.g. `max_concepts`,
    `deduplicate`, `definition`.

</div>

<div class="section level2">

## Value

a data.frame as returned by `map_concepts`, with all rows from the EDAM
ontology.

</div>

<div class="section level2">

## Details

**Scope and curation.** EDAM covers bioinformatics operations, data
types, file formats, and computational biology topics. Concepts outside
this scope — including spatial statistics, clinical phenotypes, chemical
entities, and general study designs — have little or no EDAM coverage.
When the input text contains such concepts the LLM may return a spurious
EDAM term rather than admitting no match exists. *All outputs should be
reviewed by a domain expert before use*: check that each `term_label` is
semantically appropriate for its `input_text`, and discard rows where
the mapping is implausible. The `map_concepts` function (unrestricted
ontology) may give better coverage for mixed or clinically-oriented
texts.

</div>

<div class="section level2">

## Examples

<div class="sourceCode">

``` r
if (interactive()) {
    map_concepts_edam("RNA-Seq workflow with variant calling and primer trimming",
                      max_concepts = 8)
}
```

</div>

</div>

</div>
