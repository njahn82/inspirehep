hep_search <- function(p = NULL) {
  if(is.null(p))
    stop("Please provide a search. The INSPIRE search syntax can be found in 
         the online help https://inspirehep.net/info/hep/search-tips")
  path = "search"
  q <- list()
  q$p <- p
  q$of <- "xm"
  q$rg <- 250
  req <- hep_GET(path = path, query = q)
  out_childs <- hep_parse(req)
  works <- sapply(marc_paths, 
                  function(x) try_parse(xpaths = x, out_childs = out_childs))
  data.frame(works, stringsAsFactors = FALSE)
}

try_parse <- function(out_childs, xpaths) {
  tt <- lapply(out_childs, function(x) 
    xml_text(xml_find_all(x, xpaths, ns = c(d1 = "http://www.loc.gov/MARC21/slim"))))
  tt.df <- lapply(tt, function(x)  if (length(x) == 0) x <- NA  else x <- x)
  tt.df <- lapply(tt.df, function(x) if(length(x)>1) paste(x, collapse=";") else x <- x)
  # return vector
  unlist(tt.df)
}

marc_paths <- list(
  id = ".//d1:controlfield[@tag='001']",
  type = ".//d1:datafield[@tag='980']//d1:subfield[@code='a']",
  title = ".//d1:datafield[@tag='245']//d1:subfield[@code='a']",
  author = ".//d1:datafield[@tag='100']//d1:subfield[@code='a']",
  affiliation =  ".//d1:datafield[@tag='100']//d1:subfield[@code='u']",
  doi = "(.//d1:datafield[@tag='024']//d1:subfield[@code='a'])[1]",
  primary_report_number	 = ".//d1:datafield[@tag='037']//d1:subfield[@code='a']",
  journal_names = ".//d1:datafield[@tag='773']//d1:subfield[@code='p']",
  volume = ".//d1:datafield[@tag='773']//d1:subfield[@code='v']",
  issue = ".//d1:datafield[@tag='773']//d1:subfield[@code='n']",
  keywords = ".//d1:datafield[@tag='695']//d1:subfield[@code='a']",
  licence_url = ".//d1:datafield[@tag='540']//d1:subfield[@code='u']")