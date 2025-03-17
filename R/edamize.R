#' simple utility to process output of edamize into data.frame
#' @import rjsoncons
#' @rawNamespace import(jsonlite, except=validate)
#' @param x a list as produced by edamize
#' @export
mkdf = function (x) 
{
    lkj = jsonlite::toJSON(x)
    uri = fromJSON(rjsoncons::j_query(lkj, "$..uri"))
    tm = fromJSON(rjsoncons::j_query(lkj, "$..term"))
    data.frame(uri, tm)
}


# mods to Anh Vu's code in github.com/anngvu/bioc-curation
# aim is to run the code in R

#' use Anh Vu's OpenAI prompting to develop structured metadata about
#' Bioconductor packages, targeting EDAM ontology and bio.tools schema
#' @param content_for_edam character(1) a URL for doc originating from the developer
#' @param temp numeric(1) temperature setting for openAI chat, see `https://gptcache.readthedocs.io/en/latest/bootcamp/temperature/chat.html`, defaults to 0.0
#' @note This function is not deterministic.  For the provided example, the input to the function
#' is a fixed text, but the output at the end can be NULL, a data frame with 12 rows, or a data frame with 14 rows.
#' More work is needed to achieve greater predictability.
#' @return two python dicts, base_final and edam_processed
#' @examples
#' if (interactive()) {
#'   key = Sys.getenv("OPENAI_API_KEY")
#'   if (nchar(key)==0) stop("need to have OPENAI_API_KEY set")
#'   # avoid repetitious reprocessing of tximeta vignette
#'   # content = vig2data("https://bioconductor.org/packages/release/bioc/vignettes/tximeta/inst/doc/tximeta.html")
#'   content = readRDS(system.file("rds/tximetaFocused.rds", package="biocEDAM"))
#'   str(content)
#'   lk = edamize(content$focus)
#'   if (is.null(lk)) lk = edamize(content$focus)  # sometimes a second try is needed
#'   print(mkdf(lk))
#'   # try content derived from a pdf vignette
#'   # content2 = vig2data("https://bioconductor.org/packages/release/bioc/vignettes/IRanges/inst/doc/IRangesOverview.pdf")
#'   content2 = readRDS(system.file("rds/IRangesOVdata.rds", package="biocEDAM"))
#'   lk2 = edamize(content2$focus)
#'   mkdf(lk2)
#' }
#' @export
edamize = function(
     content_for_edam,
     temp = 0.0) {
   requireNamespace("reticulate")
   os = reticulate::import("os")
   requests = reticulate::import("requests", convert=FALSE)
   
   file.copy(system.file("curbioc", package="biocEDAM"), tempdir(), recursive=TRUE)
   curbioc = reticulate::import_from_path("curbioc.curbioc", path=tempdir(), convert=FALSE)
   oai = reticulate::import("openai", convert=FALSE)
   json = reticulate::import("json", convert=FALSE)
   
   OPENAI_API_KEY = os$getenv('OPENAI_API_KEY')
   MODEL="gpt-4o"
   client = oai$OpenAI(api_key=OPENAI_API_KEY)
   
   #edam_content = curbioc$get_text_from_url(devurl, trim=TRUE)
   #content_for_edam
   
   #
   ## Retrieve schemas
   #

   # EDAM

   edam_schema = curbioc$get_text_from_url("https://raw.githubusercontent.com/anngvu/bioc-curation/refs/heads/main/edammap.json")
   edam_validation = json$loads(edam_schema)
   #
   
   #
   ## EDAM schema completion
   #
   edam_completion = curbioc$schema_completion(content_for_edam, edam_schema, temp=temp)
   edam_json = edam_completion$choices[0]$message$content
   edam_final = curbioc$validate_json_with_retries(edam_json, edam_validation)
   
   edam_processed = curbioc$transform_terms(edam_final)
   reticulate::py_to_r(edam_processed)
}
   
