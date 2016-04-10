#' Get INSPIRE HEP publications
#'
#' Search INSPIRE HEP, an open digital library for literature and data in the 
#' field of high energy physics. 
#' 
#' @param p search pattern (character vector). INSPIRE HEP supports different 
#' search syntaxes, including the SPIRES-style. See 
#' \url{https://inspirehep.net/info/hep/search-tips} for a comprehensive 
#' overview and examples on how to search HEP literature.
#' @param jrec Navigate to a record in the search results. By default, retrieval
#' starts with 1.
#' @param batch_size number of records to be returned for each result page. By 
#' default, groups 10 records for each page. The maximum number is 250.
#' @param limit Maximum number of records (default is 100). Since the API is 
#' still under development, be respectful and avoid expensive queries. INSPIRE
#' allows bulk downloads via its OAI-PMH interface 
#' (\url{https://inspirehep.net/oai2d?verb=Identify}) or through a periodically 
#' updated json dump (\url{https://inspirehep.net/hep_records.json.gz}).
#'
#' @return The result is a data.frame with key metadata. If you wish to retrieve
#'   more details for each record see.
#'   
#' The \code{data.frame} has the following columns.
#' \tabular{rll}{
#'  [,1] \tab id               \tab INSPIRE HEP ID \cr
#'  [,2] \tab title            \tab title of work \cr
#'  [,3] \tab author           \tab first author \cr
#'  [,4] \tab affiliation      \tab first author affiliation (collapsed ";") \cr
#'  [,5] \tab doi              \tab Digital Object Identifier (DOI) \cr
#'  [,6] \tab report_number    \tab eprint id from the arXiv (collapsed ";") \cr
#'  [,7] \tab date_reported    \tab date of initial appearance of preprint \cr
#'  [,8] \tab journal          \tab journal title \cr
#'  [,9] \tab volume           \tab journal volume \cr
#' [,10] \tab issue            \tab journal issue \cr
#' [,11] \tab keywords         \tab controlled keywords (collapsed ";") \cr
#' [,12] \tab collection       \tab collection information (collapsed ";") \cr
#' [,13] \tab license_url      \tab re-use terms for full texts (e.g. CC) \cr
#' }
#'
#' @seealso \url{https://inspirehep.net/info/hep/search-tips}
#' 
#' @examples 
#' \dontrun{
#' # Taken from the INSPIRE search guide 
#' # (https://inspirehep.net/info/hep/search-tips)
#'  
#' # keywords
#' hep_search('witten black hole', limit = 5)
#' 
#' # work by exact author
#' hep_search('exactauthor:D.J.Schwarz.1', limit = 5)
#' 
#' #Full text search available for arXiv eprints
#' hep_search('find ft "faster than light', limit = 5)
#' 
#' # Find caption
#' hep_search('find caption "Diagram for the fermion flow violating process"')
#' 
#' # Find eprints
#' hep_search('find eprint arxiv:0711.2908 or arxiv:0705.4298')
#' 
#' # Navigating the search results
#' # Get record positions 20 - 29
#' hep_search('witten black hole', jrec = 20, limit = 10)
#' }
#' 
#' @export

hep_search <- function(p = NULL, jrec = 1, batch_size = 10, limit = 100) {
 
  # input validation --------------------------------------------------------
  valid_input <- function(p, jrec, limit, batch_size)
  
  # get number of records to be parsed and inform user about the next steps ----
  req <- hep_GET("search", query = 
                   build_query(p = p, jrec = jrec, batch_size = batch_size))
  results_number <- results_total(httr::content(req, encoding = "UTF-8"))
  if(length(results_number) == 0)
    stop("Nothing found, please check your query")
  if(jrec > results_number)
    stop(paste0("Cannot jump to record number ", jrec, ". Only", 
                results_number, " records found!"))
  msg_lim <- ifelse(results_number > limit, limit, results_number)
  message(paste0(results_number, " records found, retrieving ", msg_lim))
  
  # prepare pageing in accordance with parameters ---------------------------
  pages <- counter(jrec = jrec, limit = limit, 
                   batch_size = batch_size, results_number = results_number)
  last_batch <- last_page_batch(start = jrec, limit, pages)
  
  # loop over pages ---------------------------------------------------------
  if(length(pages) > 1) {
  results <- NULL
  for (i in  pages[-length(pages)]) {
    tmp <- hep_search_(path, p, jrec = i, batch_size, 
                       limit)
    results <- rbind(results, tmp)
  }
  tmp <- hep_search_(path, p = p, jrec = pages[length(pages)], 
                     batch_size = last_batch)
  results <- rbind(results, tmp)
  return(results) 
  } else {
  hep_search_("search" , p = p, jrec = jrec, batch_size = limit)
  }
}



# search and parse result page
hep_search_ <- function(path, p, jrec, batch_size, limit) {
  req <- hep_GET(path = path, query = 
                   build_query(p, jrec = jrec, batch_size = batch_size))
  out_childs <- hep_parse(req)
  works <- sapply(marc_paths, function(x) {
    marc_parse(xpaths = x, out_childs = out_childs)})
  as.data.frame(works, stringsAsFactors = FALSE)
}

# create query for httr::GET
build_query <- function(p = p, jrec = jrec, batch_size = batch_size){
  q <- list()
  q$p <- p
  q$of <- "xm"
  q$rg <- batch_size
  q$jrec <- jrec
  q
}

# parse marc xml and return vector
marc_parse <- function(out_childs, xpaths) {
  tt <- lapply(out_childs, function(x) 
    xml2::xml_text(
      xml2::xml_find_all(x, xpaths, 
                         ns = c(d1 = "http://www.loc.gov/MARC21/slim"))
      )
    )
  tt.df <- lapply(tt, function(x)  
    if (length(x) == 0) x <- NA  else x <- x)
  tt.df <- lapply(tt.df, function(x) 
    if(length(x)>1) paste(x, collapse=";") else x <- x)
  # return vector
  unlist(tt.df)
}

# marc cml field to be parsed
marc_paths <- list(
  id = ".//d1:controlfield[@tag='001']",
  title = ".//d1:datafield[@tag='245']//d1:subfield[@code='a']",
  author = ".//d1:datafield[@tag='100']//d1:subfield[@code='a']",
  affiliation =  ".//d1:datafield[@tag='100']//d1:subfield[@code='u']",
  doi = "(.//d1:datafield[@tag='024']//d1:subfield[@code='a'])[1]",
  report_number	 = ".//d1:datafield[@tag='037']//d1:subfield[@code='a']",
  date_reported = ".//d1:datafield[@tag='269']//d1:subfield[@code='c']",
  journal = ".//d1:datafield[@tag='773']//d1:subfield[@code='p']",
  volume = ".//d1:datafield[@tag='773']//d1:subfield[@code='v']",
  issue = ".//d1:datafield[@tag='773']//d1:subfield[@code='n']",
  keywords = ".//d1:datafield[@tag='695']//d1:subfield[@code='a']",
  collection = ".//d1:datafield[@tag='980']//d1:subfield[@code='a']",
  scoap_ftxt = ".//d1:datafield[@tag='856']//d1:subfield[@code='u'][contains(text(), 'scoap')]",
  arxiv_ftxt = ".//d1:datafield[@tag='856']//d1:subfield[@code='u'][contains(text(), 'arXiv')]",
  licence_url = ".//d1:datafield[@tag='540']//d1:subfield[@code='u']")

# fetch total number of records
results_total <- function(x) {
  if(!is(x, c("xml_document", "xml_nodeset")))
    stop("no xml_document")
  string <- xml2::xml_text(xml2::xml_find_all(x, "/comment()"))
  as.numeric(gsub("[^\\d]+", "", string, perl=TRUE))
}

# get pages 
counter <- function(jrec = jrec, limit = limit, 
                    batch_size = batch_size, results_number = results_number) {
  x <- ifelse(results_number < limit, results_number, limit)
  if(jrec > x)
    x <- jrec
  seq(jrec, x, by = batch_size)
}

# get size of last page  
last_page_batch <- function(start, limit, pages) {
  ifelse(!limit < start, limit - tail(pages, n =1) + 1, limit)
}