hep_GET <- function(path, ...) {
  req <- httr::GET("https://inspirehep.net/", path = path, encoding = "UTF-8",
                   ...)
  hep_check(req)
  req
}

hep_check <- function(req) {
  if (req$status_code < 400) 
    return(invisible())
  message <- hep_parse(req)$message
  stop("HTTP failure: ", req$status_code, "\n", message, call. = FALSE)
}

hep_parse <- function(req) {
  text <- httr::content(req, encoding = "UTF-8")
  if (identical(text, "")) 
    stop("No output to parse", call. = FALSE)
  xml2::xml_children(text)
}
