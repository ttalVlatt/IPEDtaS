library(tidyverse)

data <- read_rds("data/gr2022_pell_ssl.Rds")
data_hd <- read_rds("data/hd2022.Rds")

data |>
  count(psgrtype)

data <- data |> 
  mutate(psgrtype_f = as_factor(psgrtype),
         .after = psgrtype)

data_ret <- read_rds("data/ef2022d.Rds")

ggplot(data_hd) +
  geom_bar(aes(y = as_factor(c21ugprf)))

ggplot(data_hd) +
  geom_bar(aes(y = factor(c21ugprf)))

