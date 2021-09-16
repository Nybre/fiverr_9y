traffic_light_UI <- function(id) {
  ns <- NS(id)
  tagList(  
    sidebarLayout( 
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                    draggable = TRUE, top = 250, left = "auto", right = 17, bottom = "auto",
                    width = 330, height = "auto",
                    h2(strong("Navigation Menu")),   
                             helpText(strong("Dashboard checks if a group ID exists in the example
                                             table and flags yellow if it does and green if otherwise"))    
      ),
      mainPanel(
        column(width = 12, 
               column(width = 12,
                      gradientBox(
                        title = strong(" "),status="info",
                        solidHeader = T,closable = F,width = 12, icon = "fa fa-search", 
                        withSpinner(rHandsontableOutput(ns('ip_checker'),height =  "65vh" )) 
                        
                      ))) 
        ,width = 12), 
      position = c("right") )
  )
}

trafic_light <- function(input, output, session, pool) { 
  example_data = reactive({  
    results<- read_excel("SHSGMetrics4Dash.xlsx", sheet = "example")
    return(results)
  })
  
  traffic_data = reactive({  
    results<- read_excel("SHSGMetrics4Dash.xlsx", sheet = "TrafficLight")
    return(results)
  })
   
  
  
  output$ip_checker<-renderRHandsontable({ 
    
    traffic_data = traffic_data()
    example_data = example_data()
    
    group_id = example_data$GROUP_ID[example_data$GROUP_ID %in% traffic_data$`Group ID`]
    
    ip_out = example_data$IP[example_data$GROUP_ID %in% traffic_data$`Group ID`]
    ips_i = unique(data.frame(group_id,ip_out))
    
    d_out = dcast(ips_i, group_id~ ip_out)
    
    rename <- function(df, column, new){
      x <- names(df)                                
      if (is.numeric(column)) column <- x[column]   
      names(df)[x %in% column] <- new              
      return(df)
    }
    
    d_out = rename(d_out, 'group_id', 'Group ID') 
    
    df_sync = natural_join(d_out, traffic_data, 
                           by = "Group ID",
                           jointype = "FULL")
    
    df_final = df_sync[names(traffic_data)]
    df_final[is.na(df_final)] <- ""
    
    rhandsontable(df_final,readOnly = TRUE,search = TRUE)%>%
      hot_cols(columnSorting = TRUE,highlightCol = TRUE, highlightRow = TRUE,
               manualColumnResize = T)%>%
      hot_cols(fixedColumnsLeft = 1) %>%
      hot_cols(renderer = " 
      function (instance, td, row, col, prop, value, cellProperties) {
        Handsontable.renderers.TextRenderer.apply(this, arguments);  
        if(isNaN(value)  && col==4) {
        td.style.background = 'lightyellow';
        }else if(!isNaN(value)  && col==4){
           td.style.background = 'lightgreen';
        } 
        if((isNaN(value)  && col==5)) {
        td.style.background = 'lightyellow';
        }else if (!isNaN(value)  && col==5){
             td.style.background = 'lightgreen';
        } 
        if(isNaN(value)  && col==6) {
        td.style.background = 'lightyellow';
        }else if (!isNaN(value)  && col==6){
          td.style.background = 'lightgreen';
        } 
        if(isNaN(value)  && col==7) {
        td.style.background = 'lightyellow';
        }else if(!isNaN(value)  && col==7){
         td.style.background = 'lightgreen';
        } 
        if(isNaN(value)  && col==8) {
        td.style.background = 'lightyellow';
        }else if (!isNaN(value)  && col==8){
           td.style.background = 'lightgreen';
        } 
        if(isNaN(value)  && col==9) {
        td.style.background = 'lightyellow';
        }else if (!isNaN(value)  && col==9){
              td.style.background = 'lightgreen';
        } 
        }")%>%  
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