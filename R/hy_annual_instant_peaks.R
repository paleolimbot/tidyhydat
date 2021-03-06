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


#' Extract annual max/min instantaneous flows and water levels from HYDAT database
#'
#' Provides wrapper to turn the ANNUAL_INSTANT_PEAKS table in HYDAT into a tidy data frame of instantaneous flows and water levels. 
#' \code{station_number} and \code{prov_terr_state_loc} can both be supplied. 
#' 
#' @inheritParams hy_stations
#' @param start_year First year of the returned record
#' @param end_year Last year of the returned record
#'
#' @return A tibble of hy_annual_instant_peaks
#' 
#'
#' @examples
#' \dontrun{
#' ## Multiple stations province not specified
#' hy_annual_instant_peaks(station_number = c("08NM083","08NE102"))
#'
#' ## Multiple province, station number not specified
#' hy_annual_instant_peaks(prov_terr_state_loc = c("AB","YT"))
#' }
#' 
#' @family HYDAT functions
#' @source HYDAT
#' @export
#'
hy_annual_instant_peaks <- function(station_number = NULL, 
                                 hydat_path = NULL, 
                                 prov_terr_state_loc = NULL,
                                 start_year = "ALL", end_year = "ALL") {
  

  if (!is.null(station_number) && station_number == "ALL") {
    stop("Deprecated behaviour.Omit the station_number = 
         \"ALL\" argument. See ?hy_annual_stats for examples.")
  }
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con))
  }

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)

  ## Data manipulations
  aip <- dplyr::tbl(hydat_con, "ANNUAL_INSTANT_PEAKS") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect()

  ## Add in english data type
  aip <- dplyr::left_join(aip, tidyhydat::hy_data_types, by = c("DATA_TYPE"))

  ## Add in Symbol
  aip <- dplyr::left_join(aip, tidyhydat::hy_data_symbols, by = c("SYMBOL" = "SYMBOL_ID"))

  ## If a yearis supplied...
  if (start_year != "ALL" | end_year != "ALL") {
    aip <- dplyr::filter(aip, YEAR >= start_year & YEAR <= end_year)
  }

  ## Parse PEAK_CODE manually - there are only 2
  aip <- dplyr::mutate(aip, PEAK_CODE = ifelse(PEAK_CODE == "H", "MAX", "MIN"))

  ## Parse PRECISION_CODE manually - there are only 2
  aip <- dplyr::mutate(aip, PRECISION_CODE = ifelse(PRECISION_CODE == 8, "in m (to mm)", "in m (to cm)"))

  ## TODO: Convert to dttm
  aip <- dplyr::mutate(aip, Date = lubridate::ymd(paste0(YEAR,"-",MONTH,"-",DAY)))

  ## Clean up and select only columns we need
  aip <- dplyr::select(aip, STATION_NUMBER, Date, HOUR, MINUTE, TIME_ZONE, PEAK, DATA_TYPE_EN, PEAK_CODE, PRECISION_CODE, SYMBOL_EN) %>%
    dplyr::rename(Parameter = DATA_TYPE_EN, Symbol = SYMBOL_EN, Value = PEAK)

  ## What stations were missed?
  differ_msg(unique(stns), unique(aip$STATION_NUMBER))

  
  aip
}
