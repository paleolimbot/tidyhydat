# Copyright 2017 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.



#' Extract station regulation from the HYDAT database
#'
#' Provides wrapper to turn the hy_stn_regulation table in HYDAT into a tidy data frame of station regulation. 
#' \code{station_number} and \code{prov_terr_state_loc} can both be supplied. If both are omitted all values 
#' from the \code{hy_stations} table are returned.
#'
#' @inheritParams hy_stations
#'
#' @return A tibble of stations, years of regulation and the regulation status
#' 
#' @format A tibble with 4 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{YEAR_FROM}{First year of use}
#'   \item{YEAR_TO}{Last year of use}
#'   \item{REGULATED}{logical}
#' }
#'
#' @examples
#' \dontrun{
#' ## Multiple stations province not specified
#' hy_stn_regulation(station_number = c("08NM083","08NE102"))
#'
#' ## Multiple province, station number not specified
#' hy_stn_regulation(prov_terr_state_loc = c("AB","YT"))
#' }
#'

#' @family HYDAT functions
#' @source HYDAT
#' @export

hy_stn_regulation <- function(station_number = NULL, 
                           hydat_path = NULL, 
                           prov_terr_state_loc = NULL) {
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con))
  }

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)

  ## data manipulations to make it "tidy"
  dplyr::tbl(hydat_con, "STN_REGULATION") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect() %>%
    dplyr::mutate(REGULATED = REGULATED == 1)


}
