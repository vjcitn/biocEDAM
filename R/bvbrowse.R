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

 server = function(input, output) {
  output$desc = renderPrint({
   packageDescription("biocEDAM")
  })
  setupDF = reactive({
  # build a mapping from views to package names
   pl = BiocPkgTools::biocPkgList(repo=input$type)  # tibble, biocViews field is a list
   pl$tags = sapply(pl$biocViews, paste, collapse=":")
   vl = pl$biocViews
   vls = vapply(vl, length, numeric(1))
   ps = rep(pl$Package, vls)
   vdf = data.frame(view = unlist(vl), pkg = ps)
   list(vdf=vdf, pl=pl)
   })
  output$selbut = renderUI({
   validate(need(length(input$type)>0, "waiting"))
   radioButtons("top", "RepoCategory", nv[el[[toptags[input$type]]]$edges])
   })

  output$sub1 = DT::renderDataTable({
  validate(need(length(input$lev2)>0, "preparing data table"))
  vdfpl = setupDF()
  vdf = vdfpl$vdf
  pks = unique(vdf[which(vdf$view %in% input$lev2),]$pkg)
  pl = vdfpl$pl
  ans = pl[which(pl$Package %in%  pks),]
  validate(need(nrow(ans)>0, "no packages, pick another category"))
  as.data.frame(ans[, c("Package", "Version", "dependencyCount", "tags")])
  })
#  output$lev2 = renderUI({
#   radioButtons("lev2", "lev2", nv[el[[ input$top ]]$edges])
#  })
  output$lev3 = renderUI({
   validate(need(length(input$top)>0, "waiting"))
   tmp = nv[el[[ input$top ]]$edges]
   validate(need(length(tmp)>0, "select another category, no packages"))
   checkboxGroupInput("lev2", input$top, tmp,
     inline=TRUE, selected = tmp[seq_len(min(c(length(tmp),4)))])
  })
}

runApp(list(ui=ui, server=server))
}
  
   
