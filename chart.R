#!/usr/bin/env Rscript
library(ggplot2)
library(readr)
library(dplyr)

data <- read_csv("y.csv", col_names = c("command", "mean", "stddev", "median", "user", "system", "min", "max"))

p <- ggplot(data, aes(x = 1:nrow(data))) +
  geom_line(aes(y = mean, color = "Mean", group = 1), linewidth = 0.8) +
  geom_errorbar(aes(ymin = mean - stddev, ymax = mean + stddev, color = "Mean ± StdDev"),
                width = 0.2, alpha = 0.7) +
  geom_line(aes(y = min, color = "Min", group = 1), linewidth = 0.6) +

  labs(
    x = "Commit",
    y = "Time (seconds)",
    color = "Metric"
  ) +
  scale_color_manual(values = c("Mean" = "blue", "Mean ± StdDev" = "blue",
                               "Min" = "green", "Max" = "red")) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("benchmark_plot.png", p, width = 10, height = 6, dpi = 300)
