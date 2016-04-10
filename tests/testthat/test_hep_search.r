context("testing hep_search")

test_that("hep_search returns", {
  skip_on_cran()
  a <- hep_search("witten black hole", limit = 5)
  b <- hep_search('exactauthor:D.J.Schwarz.1', limit = 5)
  c <- hep_search('find ft "faster than light"', limit = 5)
  d <- hep_search('find caption "Diagram for the fermion flow violating process"')
  e <- hep_search('witten "black hole"', jrec = 20, limit = 10)
  
  #correct class
  expect_output(str(a), "data.frame")
  expect_output(str(b), "data.frame")
  expect_output(str(c), "data.frame")
  expect_output(str(d), "data.frame")
  expect_output(str(e), "data.frame")
  
  #are diminsions correct?
  expect_equal(nrow(a), 5)
  expect_equal(ncol(a), 15)
  expect_equal(nrow(b), 5)
  expect_equal(ncol(b), 15)
  expect_equal(nrow(c), 5)
  expect_equal(ncol(c), 15)
  expect_equal(ncol(e), 15)
  expect_equal(nrow(e), 10)
  
  # fails correctly
  expect_error(hep_search(), "Please provide a search. The INSPIRE search syntax can be found in 
         the online help https://inspirehep.net/info/hep/search-tips")
  expect_error(hep_search("najko"), "Nothing found, please check your query")
})
