#' interactive exploration of biocViews in relation to packages
#' @import shiny
#' @import graph
#' @import BiocPkgTools
#' @export
bvbrowse = function() {
# will only work for software in this state
# library(biocViews)
# library(shiny)
# library(graph)
# library(BiocPkgTools)

#

 data("biocViewsVocab", package="biocViews")
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
    tabPanel("About",
     helpText("This package is in an early developmental stage."),
     verbatimTextOutput("desc")
     )
    )
   )
  )
 )


runApp(list(ui=ui, server=bvserver))
}
  
   

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





bvserver = function(input, output) {
 data("biocViewsVocab", package="biocViews")
 bv = biocViewsVocab
 el = graph::edgeL(bv)
 nv = graph::nodes(bv)

 toptags = c(BioCsoft = "Software", 
   BioCann = "AnnotationData", BioCexp = "ExperimentData", 
   BioCworkflows = "Workflow")

  output$desc = renderPrint({
   packageDescription("biocEDAM")
  })
  setupDF = reactive({
  # build a mapping from views to package names
   #pl = BiocPkgTools::biocPkgList(repo=input$type)  # tibble, biocViews field is a list
   data("vlist", package="biocEDAM")  # FIXME later generalize to pksByViews
   pl = vlist[[ input$type ]]
   pl$tags = sapply(pl$biocViews, paste, collapse=":")
   vl = pl$biocViews
   vls = vapply(vl, length, numeric(1))
   ps = rep(pl$Package, vls)
   vdf = data.frame(view = unlist(vl), pkg = ps)
   list(vdf=vdf, pl=pl)
   })

  output$selbut = renderUI({
   validate(need(length(input$type)>0, "waiting"))
   radioButtons("subtype", "RepoCategory", nv[el[[toptags[input$type]]]$edges])
   })

  output$sub1 = DT::renderDataTable({
  validate(need(length(input$type)>0, "preparing data table"))
  vdfpl = setupDF()
  vdf = vdfpl$vdf
  validate(need(length(input$subtype)>0, "waiting"))
  if (length(input$lev2) == 0)
     pks = unique(vdf[which(vdf$view %in% input$subtype),]$pkg)
    else pks = unique(vdf[which(vdf$view %in% input$lev2),]$pkg)
  pl = vdfpl$pl
  ans = pl[which(pl$Package %in%  pks),]
  validate(need(nrow(ans)>0, "no packages, pick another category"))
  as.data.frame(ans[, c("Package", "Version", "dependencyCount", "tags")])
  })

  output$lev3 = renderUI({
   validate(need(length(input$subtype)>0, "waiting"))
   tmp = nv[el[[ input$subtype ]]$edges]  # subviews of RepoCategory
   checkboxGroupInput("lev2", input$subtype, tmp,
     inline=TRUE, selected = tmp[seq_len(min(c(length(tmp),4)))])
  })
  observeEvent(input$stopit, {
    stopApp(NULL)
  })
}

