

# mods to Anh Vu's code in github.com/anngvu/bioc-curation
# aim is to run the code in R

#' use Anh Vu's OpenAI prompting to develop structured metadata about
#' Bioconductor packages, targeting EDAM ontology and bio.tools schema
#' @param packageName character(1) a Bioconductor software package name, its release landing page will be scraped
#' @param devurl character(1) a URL for doc originating from the developer
#' @return two python dicts, base_final and edam_processed
#' @examples
#' if (interactive()) {
#'   key = Sys.getenv("OPENAI_API_KEY")
#'   if (nchar(key)==0) stop("need to have OPENAI_API_KEY set")
#'   lk = curate_bioc()
#'   str(lk)
#' }
#' @export
curate_bioc = function(packageName="chromVAR",
     devurl = "https://raw.githubusercontent.com/GreenleafLab/chromVAR/refs/heads/master/README.md") {
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
   
   # Retrieve text from example sources for the package chromVAR
   # Sources to curate from can be Bioconductor homepage, READMEs, vignettes, paper (if acccessible), function docs, ...
   
   # Change urls to use selected material for different packages
   baseurl = sprintf("https://bioconductor.org/packages/release/bioc/html/%s.html", packageName)
   base_content = curbioc$get_text_from_url(baseurl)
   
   edam_content = curbioc$get_text_from_url(devurl, trim=TRUE)
   
   #
   ## Retrieve schemas
   #
   ## Base

   base_schema = curbioc$get_text_from_url("https://raw.githubusercontent.com/anngvu/bioc-curation/refs/heads/main/base.json")
   base_validation = json$loads(base_schema)
   #

   # EDAM

   edam_schema = curbioc$get_text_from_url("https://raw.githubusercontent.com/anngvu/bioc-curation/refs/heads/main/edammap.json")
   edam_validation = json$loads(edam_schema)
   #
   ## Original -- not used until last step
   biotools_original = curbioc$get_text_from_url("https://raw.githubusercontent.com/bio-tools/biotoolsSchema/refs/heads/main/jsonschema/biotoolsj.json")
   biotools_original_validation = json$loads(biotools_original) 

   #
   ## Base schema completion
   #
   
   base_completion = curbioc$schema_completion(base_content, base_schema)
   base_json = base_completion$choices[0]$message$content   # convert = FALSE -> [0] is OK
   base_final = curbioc$validate_json_with_retries(base_json, base_validation)
   
   #
   ## EDAM schema completion
   #
   edam_completion = curbioc$schema_completion(edam_content, edam_schema)
   edam_json = edam_completion$choices[0]$message$content
   edam_final = curbioc$validate_json_with_retries(edam_json, edam_validation)
   
   edam_processed = curbioc$transform_terms(edam_final)
   edam_processed

 list(base_final = base_final, edam_processed = edam_processed )
}
   
   #
   ## One manual fix
   #
   ## final_fix = validate_json_with_retries(str(ai_curated), biotools_original_validation)
   #ai_curated[0]['credit'][0]['email'] = "aschep@gmail.com"
   #validate(ai_curated, biotools_original_validation)
   #
   #with open('ai_curated_1.json', 'w') as f:
   #    json.dump(ai_curated, f, indent=4)
   #
