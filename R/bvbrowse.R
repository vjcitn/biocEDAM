#' interactive exploration of biocViews in relation to packages
#' @import shiny
#' @import graph
#' @import BiocPkgTools
#' @param \dots passed to biocPkgList
#' @export
bvbrowse = function(...) {
# will only work for software in this state
# library(biocViews)
# library(shiny)
# library(graph)
# library(BiocPkgTools)

# build a mapping from views to package names
 pl = biocPkgList(...)  # tibble, biocViews field is a list
 vl = pl$biocViews
 vls = vapply(vl, length, numeric(1))
 ps = rep(pl$Package, vls)
 vdf = data.frame(view = unlist(vl), pkg = ps)
#

 data(biocViewsVocab)
 bv = biocViewsVocab
 el = edgeL(bv)
 nv = nodes(bv)

 ui = fluidPage(
 sidebarLayout(
  sidebarPanel(
   helpText("biocViews browser"),
   radioButtons("top", "top", nv[el[[1]]$edges]), 
   uiOutput("lev2"),
   width=2
   ),
  mainPanel(
   tabsetPanel(
    tabPanel("sub", uiOutput("lev3"), DT::dataTableOutput("sub1"))
    )
   )
  )
 )

 server = function(input, output) {
  output$sub1 = DT::renderDataTable({
  pks = unique(vdf[which(vdf$view %in% input$lev3),]$pkg)
  ans = pl[which(pl$Package %in%  pks),]
  as.data.frame(ans[, c("Package", "Version", "dependencyCount")])
  })
  output$lev2 = renderUI({
   radioButtons("lev2", "lev2", nv[el[[ input$top ]]$edges])
  })
  output$lev3 = renderUI({
   checkboxGroupInput("lev3", "lev3", nv[el[[ input$lev2 ]]$edges], 
     inline=TRUE, selected = nv[el[[ input$lev2 ]]$edges][1:4])
  })
}

runApp(list(ui=ui, server=server))
}
  
   
