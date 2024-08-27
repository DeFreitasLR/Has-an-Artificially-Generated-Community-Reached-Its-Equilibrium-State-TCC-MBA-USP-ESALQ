
mbaresults<-read.csv(here::here("data","inputs","mbaresults.csv"), header = T,row.names = 1)

results<-cbind((mbaresults[,4]-mbaresults[3]),mbaresults[,2])
results<-as.data.frame(results)


# Assuming 'results' is your data frame
# The first column is Delta AIC and the second column is Generational Time

# Load necessary libraries
# install.packages("ggplot2") # Uncomment this line if ggplot2 is not installed
# install.packages("gridExtra") # Uncomment this line if gridExtra is not installed
library(ggplot2)
library(gridExtra)

# Create the boxplot
boxplot <- ggplot(results, aes(x = factor(results[,2]), y = results[,1])) +
  geom_boxplot(outlier.shape = NA, fill = "lightgray", color = "black") +  # Boxplot with custom colors
  scale_x_discrete(breaks = c("0", "25", "50", "75", "100")) +  # Show only 0, 25, 50, 75, and 100 on the x-axis
  geom_hline(yintercept = -2, color = "red", linetype = "dashed", size = 1) +  # Red dashed line at y = -2
  geom_hline(yintercept = 2, color = "red", linetype = "dashed", size = 1) +  # Red dashed line at y = 2
  labs(x = "Generational Time", y = "Delta AIC", 
       title = "b) Boxplot: Delta AIC vs Generational Time") +
  theme_classic() +  # Use a classic theme for a clean look
  theme(
    axis.title = element_text(size = 14, face = "bold"),  # Bold axis titles
    axis.text = element_text(size = 12),  # Larger axis text
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),  # Centered, bold title
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    axis.line = element_line(size = 0.5),  # Thinner axis lines
    axis.ticks = element_line(size = 0.5)  # Thinner axis ticks
  ) +
  coord_cartesian(ylim = range(results[,1], na.rm = TRUE))  # Ensure the y-axis covers the data range

# Create the scatter plot
scatterplot <- ggplot(results, aes(x = results[,2], y = results[,1])) +
  geom_point(color = "gray", size = 3) +  # Scatter plot points in gray
  geom_hline(yintercept = -2, color = "red", linetype = "dashed", size = 1) +  # Red dashed line at y = -2
  geom_hline(yintercept = 2, color = "red", linetype = "dashed", size = 1) +  # Red dashed line at y = 2
  scale_x_continuous(breaks = c(0, 25, 50, 75, 100)) +  # Show only 0, 25, 50, 75, and 100 on the x-axis
  labs(x = "Generational Time", y = "Delta AIC", 
       title = "a) Scatterplot: Delta AIC vs Generational Time") +
  theme_classic() +  # Use a classic theme for a clean look
  theme(
    axis.title = element_text(size = 14, face = "bold"),  # Bold axis titles
    axis.text = element_text(size = 12),  # Larger axis text
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),  # Centered, bold title
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    axis.line = element_line(size = 0.5),  # Thinner axis lines
    axis.ticks = element_line(size = 0.5)  # Thinner axis ticks
  ) +
  coord_cartesian(ylim = range(results[,1], na.rm = TRUE))  # Ensure the y-axis covers the data range

# Arrange the two plots one on top of the other
combined_plot <- grid.arrange(scatterplot,boxplot, ncol = 2)

# Print the combined plot
print(combined_plot)
