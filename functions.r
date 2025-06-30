# Generate lookup
generate_lookup <- function() {
  readxl::read_excel("recruitment.xlsx") |>
    janitor::clean_names() |>
    dplyr::mutate(hash_email = purrr::map_chr(email, hash_email)) |>
    dplyr::select(hash_email, team)
}

make_dumbell <- function(results) {
  results |>
    dplyr::arrange(.data[["low_avg"]], .data[["high_avg"]]) |>
    dplyr::mutate(rn = dplyr::row_number()) |>
    ggplot2::ggplot(
      ggplot2::aes(
        y = .data[["rn"]],
        fill = .data[["team"]],
        colour = .data[["team"]]
      )
    ) +
    ggplot2::geom_point(
      ggplot2::aes(
        x = .data[["low_avg"]],
        text = .data[["comments_low"]]
      ),
      size = 3,
      show.legend = FALSE
    ) +
    ggplot2::geom_point(
      ggplot2::aes(
        x = .data[["high_avg"]],
        text = .data[["comments_high"]]
      ),
      size = 3,
      show.legend = FALSE
    ) +
    ggplot2::geom_segment(
      ggplot2::aes(
        x = .data[["low_avg"]],
        xend = .data[["high_avg"]],
        yend = .data[["rn"]]
      ),
      lwd = 1.5,
    ) +
    ggplot2::theme_minimal(base_size = 16) +
    ggplot2::theme(axis.text.y = ggplot2::element_blank()) +
    ggplot2::ylab("") +
    ggplot2::xlab("") +
    StrategyUnitTheme::scale_color_su()
}

make_table <- function(results) {
  results |>
    reactable::reactable(
      style = list(fontSize = "13px"),
      width = "100%",
      compact = TRUE,
      height = 700,
      defaultPageSize = nrow(results),
      columns = list(
        low_0_5 = reactable::colDef(name = "Low CAGR 0-5 years", width = 50),
        low_5_10 = reactable::colDef(name = "Low CAGR 5-10 years", width = 50),
        low_avg = reactable::colDef(
          name = "Low CAGR 0-10 years (derived)",
          style = list(fontWeight = "bold"),
          width = 50
        ),
        high_0_5 = reactable::colDef(name = "High CAGR 0-5 years", width = 50),
        high_5_10 = reactable::colDef(
          name = "High CAGR 5-10 years",
          width = 50
        ),
        high_avg = reactable::colDef(
          name = "High CAGR 0-10 years (derived)",
          style = list(fontWeight = "bold", width = 50)
        ),
        comments_low = reactable::colDef(name = "Low rationale", width = 300),
        comments_high = reactable::colDef(name = "High rationale", width = 300),
        team = reactable::colDef(name = "Team", width = 50)
      )
    )
}


get_mixtures <- function(trust_params) {
  trust_params |>
    dplyr::mutate(
      mu = (lower + upper) / 2,
      sigma = (upper - mu) / qnorm(p = 0.90, mean = 0, sd = 1)
    ) |>
    dplyr::mutate(sigma = dplyr::if_else(sigma == 0, 0.0001, sigma)) |>
    dplyr::mutate(
      dist = purrr::map2(
        mu,
        sigma,
        \(m, s) {
          distr::Norm(mean = m, sd = s)
        }
      )
    ) |>
    dplyr::group_by(strategy) |>
    dplyr::summarise(dist = list(dist)) |>
    dplyr::mutate(
      mixture = purrr::map(
        dist,
        \(x) distr::UnivarMixingDistribution(Dlist = x)
      )
    ) |>
    dplyr::mutate(
      p10 = purrr::map_dbl(mixture, \(m) m@q(p = 0.1)),
      p50 = purrr::map_dbl(mixture, \(m) m@q(p = 0.5)),
      p90 = purrr::map_dbl(mixture, \(m) m@q(p = 0.9)),
    )
}


make_summary_table <- function(df) {
  df |>
    dplyr::mutate(
      sentence = glue::glue("{round(p10, 1)}% to {round(p90, 1)}% (n = {n})")
    ) |>
    dplyr::mutate(col_title = glue::glue("Team {team}")) |>
    dplyr::select(scenario, col_title, sentence) |>
    tidyr::pivot_wider(names_from = "col_title", values_from = sentence)
}
