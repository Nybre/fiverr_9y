
options(digits.secs = 3)  

shinyServer(
  function(input, output,session){
 
    callModule(trafic_light, "trafic_light-module", pool)  
    callModule(example, "example-module", pool)  
    }
)
 