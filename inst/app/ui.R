#' interactive exploration of biocViews in relation to packages
#' @import shiny
#' @import graph
#' @import BiocPkgTools
#' @export
#bvbrowse = function() {
# will only work for software in this state
# library(biocViews)
# library(shiny)
# library(graph)
# library(BiocPkgTools)

#

library(shiny)
library(biocEDAM)

 data("biocViewsVocab", package="biocViews")
 data("vlist", package="biocEDAM") # avoid web access
 bv = biocViewsVocab
 el = graph::edgeL(bv)
 nv = graph::nodes(bv)

toptags = c(BioCsoft = "Software", 
  BioCann = "AnnotationData", BioCexp = "ExperimentData", 
  BioCworkflows = "Workflow")


 ui = fluidPage(
 sidebarLayout(
  sidebarPanel(
   helpText("biocViews browser"),
   radioButtons("type", "Repo", c("BioCsoft", "BioCann",
     "BioCexp", "BioCworkflows"), selected="BioCsoft"),
   uiOutput("selbut"),
   actionButton("stopit", "Stop app"),
   width=2
   ),
  mainPanel(
   tabsetPanel(
    tabPanel("Packages", uiOutput("lev3"), DT::dataTableOutput("sub1")),
    tabPanel("views2EDAM", DT::dataTableOutput("edamtable")),
    tabPanel("About",
     helpText("This package is in an early developmental stage."),
     helpText("The Packages tab is built using output of
BiocPkgTools::biocPkgList along with biocViewsVocab from biocViews."),
     helpText("The views2EDAM tab is built using text2term by
Rafael Goncalves of Harvard Medical School."),
     verbatimTextOutput("desc")
     )
    )
   )
  )
 )

