#' use BiocPkgTools to acquire metadata on a specified Bioconductor package
#' @param pkgname character(1)
#' @return a 1-line tibble with all the fields defined in BiocPkgTools::biocPkgList output
#' @export
bioc_line = function(pkgname = "tximeta") {
  allpk = BiocPkgTools::biocPkgList()
  line = allpk |> dplyr::filter(Package==pkgname)
  stopifnot(nrow(line) == 1)
  line
}

#' full workflow to tag a bioconductor package and selected representative content with
#' EDAM terms
#' @param pkgname character(1)
#' @param url URL for representative content, in html or pdf
#' @return a data.frame with biocViews and EDAM suggestions
#' @examples
#' if (interactive() & nchar(Sys.getenv("OPENAI_API_KEY")>0)) {
#' ti = tag_bioc()
#' bs = tag_bioc(pkg="Biostrings", 
#'   url="https://bioconductor.org/packages/release/bioc/vignettes/Biostrings/inst/doc/Biostrings2Classes.pdf")
#' library(DT)
#' ndf = rbind(ti, bs)
#' datatable(ndf)
#' }
#' @export
tag_bioc = function(pkgname = "tximeta", url = 
     "https://bioconductor.org/packages/release/bioc/vignettes/tximeta/inst/doc/tximeta.html") {
  line = bioc_line(pkgname = pkgname)
  viewstr = paste(unlist(line$biocViews), collapse=", ")
  dat = vig2data(url)
  ed = edamize(dat$focused)
  if (is.null(ed)) stop("edamize failed")
  eddf = biocEDAM::mkdf(ed)
  edline = toline(eddf)
  data.frame(pkg=pkgname, views=viewstr, edline)
}

#' process the output of edamize followed by mkdf to create a data frame with components topic, operation, data, format,
#' reflecting main elements of EDAM
#' @param x output of mkdf
#' @return a data.frame
#' @export
toline = function(x) {
  dr = which(duplicated(x$uri))
  if (length(dr)>0) x = x[-dr,]
  newu = gsub("http://edamontology.org/", "", x$uri)
  edcodes = sapply(strsplit(newu, "_"), "[", 2)
  edtype = sapply(strsplit(newu, "_"), "[", 1)
  newtm = sprintf("%s (%s)", x$tm, edcodes)
  bytop = split(newtm, edtype)
  bytop = lapply(bytop, paste, collapse=", ")
  bytop
  targs = c("topic", "operation", "data", "format")
  data.frame(bytop[targs])
}

#ti = tag_bioc()
#bs = tag_bioc(pkg="Biostrings", 
#  url="https://bioconductor.org/packages/release/bioc/vignettes/Biostrings/inst/doc/Biostrings2Classes.pdf")
#library(DT)
#ndf = rbind(ti, bs)
#datatable(ndf)
#
#mi = tag_bioc(pkg="minfi", 
#  url="https://bioconductor.org/packages/release/bioc/vignettes/minfi/inst/doc/minfi.html")
#DT::datatable(mi)
