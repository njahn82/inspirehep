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

# input validations

valid_input <- function(p, jrec, limit, batch_size) {
  if(is.null(p))
    stop("Please provide a search. The INSPIRE search syntax can be found in 
         the online help https://inspirehep.net/info/hep/search-tips")
  check_batch_size(batch_size)
  check_num(jrec)
  check_num(limit)
}

check_batch_size <- function(x) {
  if (!is.null(x)) {
    if (x > 250) {
      stop("batch_size must be 250 or less",
           call. = FALSE)
    }
  }
}

check_num <- function(x) {
  if (!is.null(x)){
    if(!is.numeric(x))
      stop("jrec must be an integer")
  }
}