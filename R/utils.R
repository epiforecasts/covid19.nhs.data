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
    "admissions", "data", "ltla_code", "org_code", "p", "p_trust", "p_utla",
    "trust_code", "trust_ltla_mapping", "trust_name", "trust_names",
    "trust_utla_mapping", "type1_acute", "utla_code", "utla_name", "utla_names",
    "utla_uk_shape", "value"
  )
)