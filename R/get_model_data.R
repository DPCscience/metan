#' Easily get data from a model
#'
#' Easily get data from some objects generated in the \strong{metan} package
#' such as the WAASB and WAASBY indexes  (Olivoto et al., 2019a, 2019b) BLUPs,
#' variance components, and details of AMMI models.
#'
#'
#' @param x An object created with the functions \code{\link{gamem}},
#'   \code{\link{performs_ammi}}, \code{\link{waas}} or \code{\link{waasb}}.
#' @param what What should be captured from the model. See more in
#'   \strong{Details} section.
#' @param type Chose if the statistics must be show by genotype (\code{type =
#'   "GEN"}, default) or environment (\code{type = "ENV"}), when possible.
#' @return A tibble showing the values of the variable chosen in argument
#'   \code{what}.
#' @details
#'  \strong{The next options are allowed if the object is of class \code{performs_ammi}.}
#' * \code{"Y"} for raw means (Default) .
#' * \code{"ipca_ss"} Sum of square for each IPCA.
#' * \code{"ipca_ms"} Mean square for each IPCA.
#' * \code{"ipca_fval"} F value for each IPCA.
#' * \code{"ipca_pval"} P-value for for each IPCA.
#' * \code{"ipca_expl"}  Explained sum of square for each IPCA.
#' * \code{"ipca_accum"} Accumulated explained sum of square.
#'
#' \strong{The next options are valid in the argument \code{what} for both \code{waas} and \code{waasb} objects.}
#' * \code{"Y"} for raw means (Default) .
#' * \code{"PCn"} for the scores of the nth Interaction Principal Component Axis (IPCA) .
#'  where * \code{n} is the desired IPCA (e.g. \code{"PC3"}) .
#' * \code{"WAASB"}  The weighted average of the absolute scores .
#' * \code{"PctResp"} The rescaled values of the response variable .
#' * \code{"PctWAASB"} The rescaled values of the WAASB .
#' * \code{"wResp"} The weight for the response variable .
#' * \code{"wWAASB"} The weight for the stability .
#' * \code{"OrResp"} The ranking regarding the response variable .
#' * \code{"OrWAASB"} The ranking regarding the WAASB .
#' * \code{"OrPC1"} The ranking regarding the first principal component axix .
#' * \code{"WAASBY"} The superiority index WAASBY .
#' * \code{"OrWAASBY"} The ranking regarding the superiority index .
#'
#'  \strong{The next options are allowed if the object is of class \code{waasb}
#'  or \code{gamem}.}
#'
#' * \code{"blupg"} For genotype's predicted mean.
#' * \code{"blupge"} for genotype-vs-environment's predicted mean (only for
#' objects of class \code{waasb}).
#' * \code{"genpar"} Genetic parameters.
#' * \code{"lrt"} The statistic for the likelihood-ratio test for random effects.
#' * \code{"pval_lrt"}  The p-values for the likelihood-ratio test.
#' * \code{"vcomp"} The variance components for random effects.
#' @md
#' @importFrom dplyr starts_with matches case_when
#' @author Tiago Olivoto \email{tiagoolivoto@@gmail.com}
#' @export
#' @references
#' Olivoto, T., A.D.C. L{\'{u}}cio, J.A.G. da silva, V.S. Marchioro, V.Q. de
#' Souza, and E. Jost. 2019a. Mean performance and stability in
#' multi-environment trials I: Combining features of AMMI and BLUP techniques.
#' Agron. J.
#' \href{https://dl.sciencesocieties.org/publications/aj/abstracts/0/0/agronj2019.03.0220}{doi:10.2134/agronj2019.03.0220}
#'
#' Olivoto, T., A.D.C. L{\'{u}}cio, J.A.G. da silva, B.G. Sari, and M.I. Diel.
#' 2019b. Mean performance and stability in multi-environment trials II:
#' Selection based on multiple traits. Agron. J.
#' \href{https://dl.sciencesocieties.org/publications/aj/abstracts/0/0/agronj2019.03.0221}{doi:10.2134/agronj2019.03.0221}
#' @examples
#'
#' library(metan)
#' #################### AMMI model #####################
#' # Fit an AMMI model for 7 variables.
#' AMMI <- data_ge2 %>%
#'  performs_ammi(ENV, GEN, REP,
#'                resp = c(PH, ED, TKW, NKR, CD, CL, CW))
#'
#' # Sum of squares
#' get_model_data(AMMI, "ipca_ss")
#'
#' # Mean squares
#' get_model_data(AMMI, "ipca_ms")
#'
#' # Examine the significance (p-value) of the IPCAs
#' get_model_data(AMMI, "ipca_pval")
#'
#' # Explained sum of square for each IPCA
#' get_model_data(AMMI, "ipca_expl")
#'
#' # Accumulated sum of square
#' get_model_data(AMMI, "ipca_accum")
#'
#'
#' #################### WAASB model #####################
#' # Fitting the WAAS index
#' AMMI <- waas(data_ge2, ENV, GEN, REP,
#'              resp = c(PH, ED, TKW, NKR))
#'
#' # Getting the weighted average of absolute scores
#' get_model_data(AMMI, what = "WAASB")
#'
#' # And the rank for the WAASB inde.
#' get_model_data(AMMI, what = "OrWAASB")
#'
#'
#' #################### BLUP model #####################
#' # Fitting a mixed-effect model
#' blup <- waasb(data_ge2, ENV, GEN, REP,
#'               resp = c(PH, ED, TKW, NKR))
#'
#' # Getting p-values for likelihood-ratio test
#' get_model_data(blup, what = "pval_lrt")
#'
#' # Getting the variance components
#' get_model_data(blup, what = "vcomp")
#'
#' # Getting the genetic parameters
#' get_model_data(blup, what = "genpar")
#'
#'
get_model_data <- function(x, what = "Y", type = "GEN") {

  if (!class(x) %in% c("waasb", "waas", "gamem", "performs_ammi")) {
    stop("Invalid input in 'x' argument. It must be one object of class 'gamem', 'performs_ammi', 'waas' or 'waasb'")
  }
  if (substr(what, 1, 2) == "PC") {
    npc <- ncol(x[[1]][["model"]] %>%
      select(starts_with("PC")) %>%
      select(matches("PC\\d+")))
    npcwhat <- as.numeric(substr(what, 3, nchar(what)))
    if (npcwhat > npc) {
      stop("The number of principal components informed seems to be larger than those in the model informed in 'x'.")
    }
  }

  check <- c(
    "blupg", "blupge", "Y", "WAASB", "PctResp", "PctWAASB", "wRes", "wWAASB", "OrResp", "OrWAASB",
    "OrPC1", "WAASBY", "OrWAASBY", "vcomp", "lrt", "details", "genpar", "pval_lrt"
  )
  check2 <- paste("PC", 1:200, sep = "")
  check3 <- c("blupg", "blupge", "vcomp", "lrt", "genpar", "pval_lrt", "details")
  check4 <- c("Y", "WAASB", "PctResp", "PctWAASB", "wRes", "wWAASB",
              "OrResp", "OrWAASB", "OrPC1", "WAASBY", "OrWAASBY")
  ckeck4 <- c("ipca_ss", "ipca_ms", "ipca_fval", "ipca_pval", "ipca_expl", "ipca_accum")
  if (!what %in% c(check, check2, ckeck4)) {
    stop("The argument 'what' is invalid. Please, check the function help (?get_model_data) for more details.")
  }
  if (what %in% check3 && !class(x) %in% c("waasb", "gamem")) {
    stop("Invalid argument 'what'. It can only be used with an object of class 'waasb' or 'gamem'. Please, check and fix.")
  }
  if (!type %in% c("GEN", "ENV")) {
    stop("Argument 'type' invalid. It must be either 'GEN' or 'ENV'.")
  }

  if (class(x) == "performs_ammi") {
    if (!what %in% c("Y", check2, ckeck4)) {
      stop("Invalid value in 'what' for object of class 'performs_ammi'.")
    }
    if (what == "Y" | what %in% check2) {
      bind <- do.call(
        cbind,
        lapply(x, function(x) {
          x$model[[what]]
        })
      ) %>%
        as_tibble() %>%
        mutate(
          gen = x[[1]][["model"]][["Code"]],
          type = x[[1]][["model"]][["type"]]
        ) %>%
        dplyr::filter(type == {{type}}) %>%
        select(-type) %>%
        select(gen, everything())
    }
    if (what  %in% ckeck4) {
        what <- case_when(
          what == "ipca_ss" ~ "Sum Sq",
          what == "ipca_ms" ~ "Mean Sq",
          what == "ipca_fval" ~ "F value",
          what == "ipca_pval" ~ "Pr(>F)",
          what == "ipca_expl" ~ "Percent",
          what == "ipca_accum" ~ "Accumul"
        )

      bind <- do.call(cbind, lapply(x, function(x) {
        val <- x[["PCA"]][[what]]
      })) %>%
        as_tibble() %>%
        mutate(PC = x[[1]][["PCA"]][["PC"]],
               DF = x[[1]][["PCA"]][["Df"]]) %>%
        select(PC, DF, everything())
    }
  }

  if (class(x) == "waas") {
    if (what %in% c("WAASB", "PctWAASB", "wWAASB", "OrWAASB", "WAASBY", "OrWAASBY")) {
      what <- case_when(
        what == "WAASB" ~ "WAAS",
        what == "PctWAASB" ~ "PctWAAS",
        what == "wWAASB" ~ "wWAAS",
        what == "OrWAASB" ~ "OrWAAS",
        what == "WAASBY" ~ "WAASY",
        what == "OrWAASBY" ~ "OrWAASY"
      )
    }
    if (what %in% c("Y", "WAAS", "PctResp", "PctWAAS", "wRes", "wWAAS",
                    "OrResp", "OrWAAS", "OrPC1", "WAASY", "OrWAASY") | what  %in% check2) {
      bind <- do.call(
        cbind,
        lapply(x, function(x) {
          x$model[[what]]
        })
      ) %>%
        as_tibble() %>%
        mutate(
          gen = x[[1]][["model"]][["Code"]],
          type = x[[1]][["model"]][["type"]]
        ) %>%
        dplyr::filter(type == {
          {
            type
          }
        }) %>%
        select(-type) %>%
        select(gen, everything())
    }
    if (what == "details") {
      bind <- do.call(cbind, lapply(x, function(x) {
        val <- x[["Details"]][["Values"]] %>% as.character()
      })) %>%
        as_tibble() %>%
        mutate(Parameters = x[[1]][["Details"]][["Parameters"]]) %>%
        select(Parameters, everything())
    }
  }

  if (class(x)  %in% c("waasb", "gamem")) {
    if(class(x) == "gamem" & what == "Y"){
      message("setting the argument 'what' to 'blupg'.")
      what <- "blupg"
    }
    if(class(x) == "gamem" & !what %in% check3){
      stop("Invalid value in 'what' for an object of class 'gamem'")
    }
    if (class(x) == "waasb" & what %in% check4) {
      bind <- do.call(
        cbind,
        lapply(x, function(x) {
          x$model[[what]]
        })
      ) %>%
        as_tibble() %>%
        mutate(
          gen = x[[1]][["model"]][["Code"]],
          type = x[[1]][["model"]][["type"]]
        ) %>%
        dplyr::filter(type == {
          {
            type
          }
        }) %>%
        select(-type) %>%
        select(gen, everything())
    }
    if (what == "vcomp") {
      bind <- do.call(cbind, lapply(x, function(x) {
        val <- x[["random"]][["Variance"]]
      })) %>%
        as_tibble() %>%
        mutate(Group = x[[1]][["random"]][["Group"]]) %>%
        select(Group, everything())
    }
    if (what == "genpar") {
      bind <- do.call(cbind, lapply(x, function(x) {
        val <- x[["ESTIMATES"]][["Values"]]
      })) %>%
        as_tibble() %>%
        mutate(Parameters = x[[1]][["ESTIMATES"]][["Parameters"]]) %>%
        select(Parameters, everything())
    }
    if (what == "details") {
      bind <- do.call(cbind, lapply(x, function(x) {
        val <- x[["Details"]][["Values"]] %>% as.character()
      })) %>%
        as_tibble() %>%
        mutate(Parameters = x[[1]][["Details"]][["Parameters"]]) %>%
        select(Parameters, everything())
    }
    if (what == "pval_lrt") {
      bind <- do.call(cbind, lapply(x, function(x) {
        val <- x[["LRT"]][["Pr(>Chisq)"]]
      })) %>%
        as_tibble() %>%
        mutate(model = x[[1]][["LRT"]][["model"]]) %>%
        select(model, everything())
    }
    if (what == "lrt") {
      bind <- do.call(cbind, lapply(x, function(x) {
        val <- x[["LRT"]][["LRT"]]
      })) %>%
        as_tibble() %>%
        mutate(model = x[[1]][["LRT"]][["model"]]) %>%
        select(model, everything())
    }
    if (what %in% c("blupg", "blupge")) {
      if (what == "blupg") {
        datt <- x[[1]][["blupGEN"]]
        bind <- do.call(cbind, lapply(x, function(x) {
          val <- arrange(x[["blupGEN"]], GEN)$Predicted
        })) %>%
          as_tibble() %>%
          mutate(gen = datt %>% arrange(GEN) %>% pull(GEN)) %>%
          select(gen, everything())
      }
      if (what == "blupge") {
        bind <- do.call(cbind, lapply(x, function(x) {
          val <- x[["BLUPgge"]][["Predicted"]]
        })) %>%
          as_tibble() %>%
          mutate(
            ENV = x[[1]][["BLUPgge"]][["ENV"]],
            GEN = x[[1]][["BLUPgge"]][["GEN"]]
          ) %>%
          select(ENV, GEN, everything())
      }
    }
  }

return(bind)

}