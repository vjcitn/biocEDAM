<div id="main" class="col-md-9" role="main">

# Map biological or medical concepts to ontology terms via OLS4

<div class="ref-description section level2">

Uses a two-stage approach to avoid LLM hallucination under tool-call
overload:

1.  **Concept extraction** — a plain LLM call (no tools) identifies all
    concepts in `query` and returns them as a character vector.

2.  **Per-concept lookup** — each concept gets its own fresh single-turn
    chat so conversation history never accumulates across concepts. The
    LLM calls an OLS4 tool and returns only a term label; R code
    resolves the label to a canonical IRI via OLS4 REST.

Results are validated against the EBI OLS4 REST API via `ols4_enrich`,
which adds `validated` and `definition` columns.

</div>

<div class="section level2">

## Usage

<div class="sourceCode">

``` r
map_concepts(
  query,
  provider = "anthropic",
  model = "claude-sonnet-4-5",
  temperature = 0,
  extract_prompt = read_prompt("extract_concepts.txt"),
  lookup_prompt = read_prompt("lookup_concept.txt"),
  confirm = interactive(),
  max_concepts = Inf,
  deduplicate = TRUE,
  definition = FALSE,
  label_match = TRUE,
  ontology_filter = NULL,
  tools = ols4_mcp_tools(),
  extractor = llm_chat(provider = provider, model = model, api_args = list(temperature =
    temperature))
)
```

</div>

</div>

<div class="section level2">

## Arguments

-   query:

    character(1) free-text input containing one or more biological or
    medical concepts.

-   provider:

    character(1) LLM provider; see `llm_env_var`. Defaults to
    `"anthropic"`.

-   model:

    character(1) model identifier for the chosen provider. Defaults to
    `"claude-sonnet-4-5"`.

-   temperature:

    numeric(1) sampling temperature; defaults to `0` for deterministic
    output.

-   extract\_prompt:

    character(1) prompt for Stage 1 (concept extraction). Defaults to
    `inst/prompts/extract_concepts.txt`.

-   lookup\_prompt:

    character(1) prompt for Stage 2 (per-concept OLS4 lookup). Defaults
    to `inst/prompts/lookup_concept.txt`.

-   confirm:

    logical(1) if `TRUE` (the default in interactive sessions), Stage 1
    concepts are printed and the user is prompted to confirm before
    Stage 2 begins. Entering nothing or `y` proceeds; anything else
    aborts and returns `NULL` invisibly. Set to `FALSE` to skip the
    prompt in scripts and non-interactive contexts.

-   max\_concepts:

    integer(1) maximum number of concepts to look up in Stage 2. The
    first `max_concepts` items from Stage 1 are used; the rest are
    silently dropped. `Inf` (default) processes all concepts.

-   deduplicate:

    logical(1) if `TRUE` (default), rows with duplicate `term_iri`
    values are collapsed into one row; the `input_text` field of the
    surviving row lists all source concepts separated by `"; "`.

-   definition:

    logical(1) if `FALSE` (default), the `definition` column is set to
    `NA` and no extra OLS4 REST calls are made. Set to `TRUE` to fetch
    authoritative definitions via `ols4_enrich`, at the cost of one
    additional REST call per term.

-   label\_match:

    logical(1) if `TRUE` (default), adds `llm_label` and `label_match`
    columns, where `label_match = FALSE` flags rows where the LLM-chosen
    label and the OLS4 canonical label share no content words — a
    reliable signal of a spurious mapping. Filter with
    `result[result$label_match, ]` to retain only plausible rows.
    Implies `definition = TRUE` since it requires `ols4_enrich`.

-   ontology\_filter:

    character(1) or `NULL`. When supplied, overrides the ontology
    returned by the LLM and forces the OLS4 REST label search to search
    within that ontology only (e.g. `"edam"`). `NULL` (default) uses
    whatever ontology the LLM selects.

-   tools:

    list of ellmer `ToolDef` objects as returned by `ols4_mcp_tools`.
    Loaded once per `map_concepts` call; each per-concept lookup creates
    a fresh chat that registers these tools, preventing context
    accumulation across concepts. Supply a pre-loaded tools object to
    avoid restarting the MCP bridge on repeated calls.

-   extractor:

    an ellmer `Chat` object *without* tools, used for Stage 1 concept
    extraction. Defaults to a plain `llm_chat` with the same provider,
    model, and temperature.

</div>

<div class="section level2">

## Value

a data.frame with columns `input_text`, `term_label`, `term_iri`,
`obo_id`, `ontology`, `rationale`, `validated`, `definition`,
`llm_label`, and `label_match`, one row per concept-term pair. **Outputs
require human curation.** Filter on `result[result$label_match, ]` to
discard the most obvious spurious mappings, then review remaining rows
before treating results as authoritative.

</div>

<div class="section level2">

## Examples

<div class="sourceCode">

``` r
if (interactive()) {
    map_concepts("atrial fibrillation and whole genome sequencing",
                 max_concepts = 10)

    # pre-load tools to avoid restarting the MCP bridge on repeated calls
    tls <- ols4_mcp_tools()
    map_concepts("atrial fibrillation", tools = tls)
    map_concepts("whole genome sequencing", tools = tls)
}
```

</div>

</div>

</div>
