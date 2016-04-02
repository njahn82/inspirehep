
# inspirehep - facilitating access to high-energy physics literature with R



[![Travis-CI Build Status](https://travis-ci.org/njahn82/inspirehep.svg?branch=master)](https://travis-ci.org/njahn82/inspirehep)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/njahn82/inspirehep?branch=master&svg=true)](https://ci.appveyor.com/project/njahn82/inspirehep)
[![Coverage Status](https://img.shields.io/codecov/c/github/njahn82/inspirehep/master.svg)](https://codecov.io/github/njahn82/inspirehep?branch=master)

This package gives access to [INSPIRE HEP](https://inspirehep.net/), a 
comprehensive source for High-Energy Physics Literature. 

API Documentation: <https://inspirehep.net/info/hep/api>

No API registration needed, no limits in place.

If you need to gather many records or in case you have many queries, please be
nice and consider the following options for bulk downloads:

- [OAI-PMH](https://inspirehep.net/oai2d?verb=Identify)
- [JSON Dump](https://inspirehep.net/hep_records.json.gz)


## Installation

Get the development version from GitHub


```r
install.packages("devtools")
devtools::install_github("njahn82/inspirehep")
```

Load `inspirehep`


```r
library('inspirehep')
```

## Basic usage

Use  `hep_search` to search INSPIRE HEP, and `hep_details` to get detailed
information on the record-level.

### Searching INSPIRE HEP

If you are familiar with the INSPIRE HEP web search, discovering literature
with `hep_search` is easy because the API supports all well-known search
features. Through the SPIRES syntax not only searching metadata is possible,
but also structured full-text queries are supported.

The INSPIRE HEP team gives search tips with a particular focus on the SPIRES
syntax: <https://inspirehep.net/info/hep/search-tips>

`hep_search` parses the resulting MARC XML and returns key metadata as 
`data.frame` with the following columns:


| Variable        | Description
|:----------------|:-----------------------------------------|
|id               |INSPIRE HEP ID                            |
|title            |title of work                             |
|author           |first author                              |
|affiliation      |first author affiliation (collapsed ";")  |
|doi              |Digital Object Identifier (DOI)           |
|report_number    |eprint id from the arXiv (collapsed ";")  |
|date_reported    |date of initial appearance of preprint    |
|journal          |journal title                             |
|volume           |journal volume                            |
|issue            |journal issue                             |
|keywords         |controlled keywords (collapsed ";")       |
|collection       |collection information (collapsed ";")    |
|license_url      |re-use terms for full texts (e.g. CC)     |


#### Keyword search


```r
library(dplyr) # for pipes and tbl_df class
hep_search("witten black hole", limit = 5) %>%
  tbl_df()
#> Source: local data frame [5 x 13]
#> 
#>        id
#>     (chr)
#> 1 1436342
#> 2 1424377
#> 3 1418506
#> 4 1414220
#> 5 1409133
#> Variables not shown: title (chr), author (chr), affiliation (chr), doi
#>   (chr), report_number (chr), date_reported (chr), journal (chr), volume
#>   (chr), issue (chr), keywords (chr), collection (chr), licence_url (chr)
```

#### Exact Author search

INSPIRE HEP disambiguates author names. To search for an exact author, e.g.
[Dominik Schwarz](http://inspirehep.net/author/profile/D.J.Schwarz.1) and get
the most frequent journals:


```r
hep_search('exactauthor:D.J.Schwarz.1', limit = 250) %>%
  group_by(journal) %>% 
  group_by(journal) %>% 
  summarise(counts = n()) %>% 
  arrange(desc(counts))
#> Source: local data frame [39 x 2]
#> 
#>                    journal counts
#>                      (chr)  (int)
#> 1                Phys.Rev.     32
#> 2                       NA     27
#> 3        Astron.Astrophys.     13
#> 4  Mon.Not.Roy.Astron.Soc.     11
#> 5                      PoS     11
#> 6                     JCAP      8
#> 7           Phys.Rev.Lett.      6
#> 8          Astropart.Phys.      3
#> 9               Phys.Lett.      3
#> 10          AIP Conf.Proc.      2
#> ..                     ...    ...
```

#### Full-text search

Search in arXiv eprints:


```r
hep_search('find ft "faster than light"', limit = 5) %>%
  tbl_df()
#> Source: local data frame [5 x 13]
#> 
#>        id
#>     (chr)
#> 1 1434969
#> 2 1432686
#> 3 1426682
#> 4 1426148
#> 5 1426037
#> Variables not shown: title (chr), author (chr), affiliation (chr), doi
#>   (chr), report_number (chr), date_reported (chr), journal (chr), volume
#>   (chr), issue (chr), keywords (chr), collection (chr), licence_url (chr)
```

#### Navigate through the search results

By default, 100 records are returned for each query. The parameter `limit` can
be used to controll the number of records that you wish to retrieve.

To jump to a record, use the `jrec` parameter. For example, you want records 20 
to 29, tell `hep_search` that you would like to start from record 20 and limit 
your search results to 10 records.


```r
hep_search('witten black hole', jrec = 20, limit = 10) %>%
  tbl_df()
#> Source: local data frame [10 x 13]
#> 
#>         id
#>      (chr)
#> 1  1275695
#> 2  1261044
#> 3  1245231
#> 4  1243469
#> 5  1243443
#> 6  1242042
#> 7  1221741
#> 8  1221609
#> 9  1191210
#> 10 1115450
#> Variables not shown: title (chr), author (chr), affiliation (chr), doi
#>   (chr), report_number (chr), date_reported (chr), journal (chr), volume
#>   (chr), issue (chr), keywords (chr), collection (chr), licence_url (chr)
```

Last but not least, you can use `batch_size` to control the size of your
result pages. By default, `batch_size` groups 10 records into a single page.
The maximum number is 250. Please note that large values per page could cause
longer response times. Consider the bulk download options via OAI-PMH or the
json data dump if you need to get to work with a large set of INSPIRE records.

### Get record details

to be added

## Meta

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

Licence: MIT (c) Najko Jahn

For bug reports or feature requests please use the issue tracker.

