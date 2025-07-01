# Results slides scripts

These scripts process, aggregate and present back results from the The Health Foundation elicitation exercise held on July 2nd 2025.

## Instructions for Gabriel

Before the day make sure you have the following files

- `lookup.csv` (mapping hashed emails to teams)
- `post_round1.qmd`
- `post_round2.qmd`
- `post_tech.qmd`
- `functions.R`

I've created dummy results files that you can use to check you can generate the HTMLs. These are

- `round1.csv`
- `round2.csv`
- `tech.csv`

On the day, these will be downloaded from the shiny app and need to be renamed.

You can download the non-tech scenario from [connect.strategyunitwm.nhs.uk/elicitation_productivity/?results](https://connect.strategyunitwm.nhs.uk/elicitation_productivity/?results/)and the tech scenario from [connect.strategyunitwm.nhs.uk/elicitation_productivity_tech/?results](https://connect.strategyunitwm.nhs.uk/elicitation_productivity_tech/?results).

You will need

- Quarto
- R and required R packages
- The [SU Quarto theme](https://github.com/The-Strategy-Unit/su-theme)*

*Note that although it's not best practice, we have commited the `_extensions` folder here due to installation issues.
