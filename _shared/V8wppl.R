library(V8)

# create a V8 instance
ct <- v8()
ct$eval("var windowVar = {};")
ct$source("http://cdn.webppl.org/webppl-v0.9.15.js")

evalWebPPL_V8 <- function(wppl_code) {
  # wppl_code <- gsub('\\', "\\", wppl_code, fixed = )
  wppl_code <- str_replace_all(wppl_code, "[\']+", '"')
  wppl_code <- str_replace_all(wppl_code, '[\\"]+', '\\\\"')
  # DANGER ZONE
  wppl_code <- str_replace_all(wppl_code, "[\\t]+", "\\\\t")
  wppl_code <- str_replace_all(wppl_code, "[\\n]+", "\\\\n")
  line0 <- sprintf("var wppl_code = '%s';", wppl_code)
  ct$eval(line0)
  line <- "webppl.run(wppl_code, function(a,b) { windowVar.o = b }, {debug: false}) ;windowVar.o"
  output <- ct$eval(line)
  return(output)
}



