# https://github.com/research-software-ecosystem/content.git is cloned
#' data folder is analyzed, cd there
library(jsonlite)
alld = dir(full=TRUE, recursive=TRUE)
hasbtj = grep("biotools.json", alld, value=TRUE)
allcolid = lapply(hasbtj, function(x) { j = fromJSON(x); j$collectionID })
isbioc = sapply(allcolid, function(x) "BioConductor" %in% x)
kp = which(unlist(isbioc))
pks = hasbtj[kp]
pkj=basename(pks)
#bioc_with_biotools = gsub(".biotools.json", "", pkj)
reads = lapply(pks, fromJSON)
make_bt_df = function(x) { data.frame(package=x$name, btid=x$biotoolsID, edam_term=x$topic$term, edam_uri=x$topic$uri, last_update=x$lastUpdate) }
allr = lapply(reads[-1503], function(x) try(make_bt_df(x)))
allr_df = do.call(rbind, allr)
biotools_bioc = allr_df
#save(biotools_bioc, file="biotools_bioc.rda")

