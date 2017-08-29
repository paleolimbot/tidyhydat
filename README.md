<a rel="Exploration" href="https://github.com/BCDevExchange/docs/blob/master/discussion/projectstates.md"><img alt="Being designed and built, but in the lab. May change, disappear, or be buggy." style="border-width:0" src="https://assets.bcdevexchange.org/images/badges/exploration.svg" title="Being designed and built, but in the lab. May change, disappear, or be buggy." /></a>

[![Travis-CI Build Status](https://travis-ci.org/bcgov/tidyhydat.svg?branch=master)](https://travis-ci.org/bcgov/tidyhydat)

<!-- README.md is generated from README.Rmd. Please edit that file -->
tidyhydat
=========

Here is a list of what tidyhydat does:

-   Perform a number of common queries on the HYDAT database and returns tidy data
-   Keep functions are low-level as possible. For example, for daily flows, the `DLY_FLOWS()` function queries the database, *tidies* the data and returns the data.

A more thorough vignette outlining the full functionality of `tidyhydat` is outlined [here](https://github.com/bcgov/tidyhydat/blob/master/vignettes/tidyhydat.md)

Installation
------------

To install the `tidyhydat` package, you need to install the `devtools` package then the `tidyhydat` package

``` r
install.packages("devtools")
devtools::install_github("bcgov/tidyhydat")
```

Then to load the package you need to using the `library` function. When you install `tidyhydat`, several other packages will be installed as well. One of those packages, `dplyr`, is useful for data manipulations and is used regularly here. Even though `dplyr` is installed alongside `tidyhydat`, it is helpful to load it by itself as there are many useful functions contained within `dplyr`. A helpful `dplyr` tutorial can be found [here](https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html).

``` r
library(tidyhydat)
library(dplyr)
```

HYDAT download
--------------

To use most of the `tidyhydat` package you will need the most recent version of the HYDAT database. The sqlite3 version can be downloaded here:

-   <http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/>

`tidyhydat` also provides a convenience function to download hydat (be patient though this takes a long time!):

``` r
download_hydat(hydat_path = "H:/")
```

You will need to download that file, unzip it and put it somewhere on local storage. The path to the sqlite3 must be specified within each function that uses HYDAT. If the path is very long it may be useful to store it as an object with a smaller name like this:

``` r
hydat_loc = "A very long path that points to the HYDAT sqlite3 database"
```

It will quickly get tiring manually entering `hydat_path`. R provides a means setting a hydat path once in the `.Renviron` file which is then automatically called by each HYDAT function. In RStudio you can open up `.Renviron` like this:

``` r
file.edit("~/.Renviron")
```

This opens your `.Renviron` file which is most likely blank. Add this line:

``` r
hydat = "YOUR HYDAT PATH"
```

It is important that you name the variable `hydat` as that is name of the variable that the functions are looking for.

Usage
-----

### HYDAT

This is a basic example of `tidyhydat` usage. All functions that interact with HYDAT are capitalized (e.g. `STATIONS`). These functions follow a common argument structure which can be illustrated with the `DLY_FLOWS()` function. If you would like to extract only station `08LA001` you can supply the `STATION_NUMBER`. The `hydat_path` argument is supplied here as a local path the database. Yours will be different or missing altogether if you set the variable in your `.Renviron` file which is highly recommend.

``` r
DLY_FLOWS(hydat_path = "H:/Hydat.sqlite3", STATION_NUMBER = "08LA001")
#> No start and end dates specified. All dates available will be returned.
#> All station successfully retrieved
#> # A tibble: 28,794 x 5
#>    STATION_NUMBER       Date Parameter Value Symbol
#>             <chr>     <date>     <chr> <dbl>  <chr>
#>  1        08LA001 1914-01-01      FLOW   144   <NA>
#>  2        08LA001 1914-01-02      FLOW   144   <NA>
#>  3        08LA001 1914-01-03      FLOW   144   <NA>
#>  4        08LA001 1914-01-04      FLOW   140   <NA>
#>  5        08LA001 1914-01-05      FLOW   140   <NA>
#>  6        08LA001 1914-01-06      FLOW   136   <NA>
#>  7        08LA001 1914-01-07      FLOW   136   <NA>
#>  8        08LA001 1914-01-08      FLOW   140   <NA>
#>  9        08LA001 1914-01-09      FLOW   140   <NA>
#> 10        08LA001 1914-01-10      FLOW   140   <NA>
#> # ... with 28,784 more rows
```

If you would instead prefer all stations from a province, you can use the `PROV_TERR_STATE_LOC` argument and omit the `STATION_NUMBER` argument:

``` r
DLY_FLOWS(hydat_path = "H:/Hydat.sqlite3", PROV_TERR_STATE_LOC = "PE")
#> No start and end dates specified. All dates available will be returned.
#> The following station(s) were not retrieved: 01CB011
#> Check station number typos or if it is a valid station in the network
#> # A tibble: 186,858 x 5
#>    STATION_NUMBER       Date Parameter Value Symbol
#>             <chr>     <date>     <chr> <dbl>  <chr>
#>  1        01CC001 1919-07-01      FLOW    NA   <NA>
#>  2        01CE001 1919-07-01      FLOW    NA   <NA>
#>  3        01CE002 1919-07-01      FLOW    NA   <NA>
#>  4        01CC001 1919-07-02      FLOW    NA   <NA>
#>  5        01CE001 1919-07-02      FLOW    NA   <NA>
#>  6        01CE002 1919-07-02      FLOW    NA   <NA>
#>  7        01CC001 1919-07-03      FLOW    NA   <NA>
#>  8        01CE001 1919-07-03      FLOW    NA   <NA>
#>  9        01CE002 1919-07-03      FLOW    NA   <NA>
#> 10        01CC001 1919-07-04      FLOW    NA   <NA>
#> # ... with 186,848 more rows
```

You can also make use of auxiliary function in `tidyhdyat` called `search_name` to look for matches when you know part of a name of a station. For example:

``` r
search_name("liard")
#> # A tibble: 3 x 2
#>   STATION_NUMBER                    STATION_NAME
#>            <chr>                           <chr>
#> 1        10BE001   LIARD RIVER AT LOWER CROSSING
#> 2        10BE005  LIARD RIVER ABOVE BEAVER RIVER
#> 3        10BE006 LIARD RIVER ABOVE KECHIKA RIVER
```

### Real-time

To download real-time data using the datamart we can use approximately the same conventions discussed above. Using `download_realtime_dd()` we can easily select specific stations by supplying a station of interest:

``` r
download_realtime_dd(STATION_NUMBER = "08LG006")
#> # A tibble: 17,508 x 8
#>    STATION_NUMBER PROV_TERR_STATE_LOC                Date Parameter Value
#>             <chr>               <chr>              <dttm>     <chr> <dbl>
#>  1        08LG006                  BC 2017-07-30 08:00:00      FLOW  7.41
#>  2        08LG006                  BC 2017-07-30 08:05:00      FLOW  7.41
#>  3        08LG006                  BC 2017-07-30 08:10:00      FLOW  7.41
#>  4        08LG006                  BC 2017-07-30 08:15:00      FLOW  7.38
#>  5        08LG006                  BC 2017-07-30 08:20:00      FLOW  7.38
#>  6        08LG006                  BC 2017-07-30 08:25:00      FLOW  7.38
#>  7        08LG006                  BC 2017-07-30 08:30:00      FLOW  7.38
#>  8        08LG006                  BC 2017-07-30 08:35:00      FLOW  7.38
#>  9        08LG006                  BC 2017-07-30 08:40:00      FLOW  7.38
#> 10        08LG006                  BC 2017-07-30 08:45:00      FLOW  7.38
#> # ... with 17,498 more rows, and 3 more variables: Grade <chr>,
#> #   Symbol <chr>, Code <chr>
```

Another option is to provide simply the province as an argument and download all stations from that province:

``` r
download_realtime_dd(PROV_TERR_STATE_LOC = "PE")
#> # A tibble: 77,824 x 8
#>    STATION_NUMBER PROV_TERR_STATE_LOC                Date Parameter Value
#>             <chr>               <chr>              <dttm>     <chr> <dbl>
#>  1        01CD005                  PE 2017-07-30 04:00:00      FLOW    NA
#>  2        01CD005                  PE 2017-07-30 04:05:00      FLOW    NA
#>  3        01CD005                  PE 2017-07-30 04:10:00      FLOW    NA
#>  4        01CD005                  PE 2017-07-30 04:15:00      FLOW    NA
#>  5        01CD005                  PE 2017-07-30 04:20:00      FLOW    NA
#>  6        01CD005                  PE 2017-07-30 04:25:00      FLOW    NA
#>  7        01CD005                  PE 2017-07-30 04:30:00      FLOW    NA
#>  8        01CD005                  PE 2017-07-30 04:35:00      FLOW    NA
#>  9        01CD005                  PE 2017-07-30 04:40:00      FLOW    NA
#> 10        01CD005                  PE 2017-07-30 04:45:00      FLOW    NA
#> # ... with 77,814 more rows, and 3 more variables: Grade <chr>,
#> #   Symbol <chr>, Code <chr>
```

Additionally `download_realtime_ws()` provides another means of acquiring real time data.

Project Status
--------------

This package is under continual development.

Getting Help or Reporting an Issue
----------------------------------

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/tidyhydat/issues/).

These are very welcome!

How to Contribute
-----------------

If you would like to contribute to the package, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

License
-------

    Copyright 2017 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at 

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
