#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

globalVariables(
  c(
    "data", "geo_code", "geo_name", "map_level", "map_source", "new_adm", "nhs_region",
    "org_code", "p", "p_geo", "p_trust", "trust_code", "trust_name", "value", "var", "var_name"
  )
)
