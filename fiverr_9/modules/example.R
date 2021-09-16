example_UI <- function(id) {
  ns <- NS(id)
  tagList(  
    sidebarLayout( 
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                    draggable = TRUE, top = 250, left = "auto", right = 17, bottom = "auto",
                    width = 330, height = "auto",
                    h2(strong("Navigation Menu")),   
                    helpText(strong("Source example data")),   
                    pickerInput(ns("group_id"),"Group ID", choices = NULL, options = list(`actions-box` = TRUE),multiple = T)
      ),
      mainPanel(
        column(width = 12, 
               column(width = 12,
                      gradientBox(
                        title = strong(" "),status="info",
                        solidHeader = T,closable = F,width = 12, icon = "fa fa-table", 
                        withSpinner(rHandsontableOutput(ns('ip_data'),height =  "65vh" )) 
                      ))) 
        ,width = 12), 
      position = c("right") )
  )
}

example <- function(input, output, session, pool) { 
  example_data = reactive({  
    results<- read_excel("SHSGMetrics4Dash.xlsx", sheet = "example")
    return(results)
  })
  
  traffic_data = reactive({  
    results<- read_excel("SHSGMetrics4Dash.xlsx", sheet = "TrafficLight")
    return(results)
  })
  
  observe({
    results<-example_data()
    updatePickerInput(session,"group_id","Group ID", choices = dput(as.character(paste(results$GROUP_ID))))
  })
  
  group_if_filter<-reactive({ input$group_id }) 
  
  output$ip_data<-renderRHandsontable({ 
    
    example_data = example_data()
   
    sample_space <-dput(as.character(paste(group_if_filter())))
    df_final = example_data[example_data$GROUP_ID  %in% sample_space,]
    print(df_final)
    
    rhandsontable(df_final,readOnly = TRUE,search = TRUE)%>%
      hot_cols(columnSorting = TRUE,highlightCol = TRUE, highlightRow = TRUE,
               manualColumnResize = T)%>%
      hot_cols(fixedColumnsLeft = 1) %>% 
      hot_context_menu(
        customOpts = list(
          search = list(name = "Search",
                        callback = htmlwidgets::JS(
                          "function (key, options) {
              var srch = prompt('Search criteria');
              this.search.query(srch);
              this.render();
              }"))))%>%hot_table(highlightCol = TRUE, highlightRow = TRUE)%>% 
      hot_context_menu(
        customOpts = list(
          csv = list(name = "Download to CSV",
                     callback = htmlwidgets::JS(
                       "function (key, options) {
             var csv = csvString(this, sep=',', dec='.');
             var link = document.createElement('a');
             link.setAttribute('href', 'data:text/plain;charset=utf-8,' +
             encodeURIComponent(csv));
             link.setAttribute('download', 'data.csv');
             document.body.appendChild(link);
             link.click();
             document.body.removeChild(link);}")))) %>%
      hot_cell(1, 3, "")   
    
  }) 
   
} 