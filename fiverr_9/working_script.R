library(readxl)
example_data <- read_excel("SHSGMetrics4Dash.xlsx", 
                               sheet = "example")
 
example_data
subset(example_data, example_data$GROUP_ID =="AT2ABC") 
sample_space <-c("AT0000036792685") 
example_data[example_data$GROUP_ID  %in% sample_space,]

traffic_data <- read_excel("SHSGMetrics4Dash.xlsx", 
                               sheet = "TrafficLight")
 
traffic_data$`Group ID` %in% example_data$GROUP_ID

group_id = example_data$GROUP_ID[example_data$GROUP_ID %in% traffic_data$`Group ID`]

ip_out = example_data$IP[example_data$GROUP_ID %in% traffic_data$`Group ID`]
ips_i = unique(data.frame(group_id,ip_out))
 
library(reshape2)
d_out = dcast(ips_i, group_id~ ip_out)

rename <- function(df, column, new){
  x <- names(df)                               #Did this to avoid typing twice
  if (is.numeric(column)) column <- x[column]  #Take numeric input by indexing
  names(df)[x %in% column] <- new              #What you're interested in
  return(df)
}

 
d_out = rename(d_out, 'group_id', 'Group ID') 
 
 
library("rqdatatable")

df_sync = natural_join(d_out, traffic_data, 
                      by = "Group ID",
                      jointype = "FULL")
#resort
df_final = df_sync[names(traffic_data)]
df_final[is.na(df_final)] <- ""

library(rhandsontable)

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

