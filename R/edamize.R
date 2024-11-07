

# mods to Anh Vu's code in github.com/anngvu/bioc-curation
# aim is to run the code in R

#' use Anh Vu's OpenAI prompting to develop structured metadata about
#' Bioconductor packages, targeting EDAM ontology and bio.tools schema
#' @param devurl character(1) a URL for doc originating from the developer
#' @param temp numeric(1) temperature setting for openAI chat, see `https://gptcache.readthedocs.io/en/latest/bootcamp/temperature/chat.html`, defaults to 0.0
#' @return two python dicts, base_final and edam_processed
#' @examples
#' if (interactive()) {
#'   key = Sys.getenv("OPENAI_API_KEY")
#'   if (nchar(key)==0) stop("need to have OPENAI_API_KEY set")
#'   lk = edamize()
#'   str(lk)
#' }
#' @export
edamize = function(
     devurl = "https://raw.githubusercontent.com/GreenleafLab/chromVAR/refs/heads/master/README.md",
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
   
   edam_content = curbioc$get_text_from_url(devurl, trim=TRUE)
   
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
   edam_completion = curbioc$schema_completion(edam_content, edam_schema, temp=temp)
   edam_json = edam_completion$choices[0]$message$content
   edam_final = curbioc$validate_json_with_retries(edam_json, edam_validation)
   
   edam_processed = curbioc$transform_terms(edam_final)
   reticulate::py_to_r(edam_processed)
}
   
