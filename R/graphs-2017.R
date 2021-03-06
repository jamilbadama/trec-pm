#setwd("~/git/bst-mug/trec2017/paper/provisional-results")
setwd("../docs/final-results")

library(dplyr)
library(ggplot2)
library(gridExtra)

tug_red <- "#ff0a6e"
tug_blue <- "#4f82bd"
tug_green <- "#9cba59"
tug_magenta <- "#8063a3"
tug_orange <- "#f79645"

# Scientific Abstracts
# run_ids <- c('mugpubboost', 'mugpubshould', 'mugpubbase', 'mugpubdiseas', 'mugpubgene')
# folder <- "."
# task_name <- "scientific_abstracts"
# metrics <- c("infNDCG", "P10", "R-prec")
# # Best, median and worst are averages over all topics
# # TODO calculate automatically from the "_trec_trec26_tables_pm-final-abstracts" file.
# metrics_best <- c(0.5856, 0.8600, 0.3950)
# metrics_median <- c(0.2766, 0.3733, 0.1761)
# metrics_worst <- c(0.0012, 0.0033, 0.0002)
# ## best <- 0.5856
# file_extension <- ".trec_eval"
# tug_colors <- c(mugpubboost=tug_red, mugpubshould=tug_blue, mugpubbase=tug_green, mugpubdiseas=tug_magenta, mugpubgene=tug_orange)


# Clinical Trials
run_ids <- c('mugctboost', 'mugctdisease', 'mugctbase', 'mugctgene', 'mugctmust')
folder <- "."
task_name <- "clinical_trials"
metrics <- c("P5", "P10", "P15")
metrics_best <- c(0.7724, 0.6759, 0.5908)
metrics_median <- c(0.2897, 0.2517, 0.2253)
metrics_worst <- c(0.0000, 0.0000, 0.0000)
file_extension <- ""
tug_colors <- c(mugctboost=tug_red, mugctdisease=tug_blue, mugctbase=tug_green, mugctgene=tug_magenta, mugctmust=tug_orange)


# TODO create empty data.frame and iterate only?
results <- read.table(paste(folder, "/", run_ids[1], file_extension, sep=""), header = FALSE)
results <- results %>% mutate(run=run_ids[1])
names(results) <- c('measure', 'topic', 'value', 'run')

sample_file <- paste(folder, "/", run_ids[1], ".sampleval", sep="")
if (file.exists(sample_file)) {
  tmp <- read.table(sample_file, header = FALSE)
  tmp <- tmp %>% mutate(run_ids[1])
  names(tmp) <- c('measure', 'topic', 'value', 'run')
  results <- results %>% bind_rows(tmp)
  remove(tmp)
}



for(run_id in run_ids[seq(2, length(run_ids))]) {
    tmp <- read.table(paste(folder, "/", run_id, file_extension, sep=""), header = FALSE)
    tmp <- tmp %>% mutate(run_id) 
    names(tmp) <- c('measure', 'topic', 'value', 'run')
    results <- results %>%  bind_rows(tmp)
    remove(tmp)
    
    sample_file <- paste(folder, "/", run_ids, ".sampleval", sep="")
    if (file.exists(sample_file)) {
      tmp <- read.table(paste(folder, "/", run_id, ".sampleval", sep=""), header = FALSE)
      tmp <- tmp %>% mutate(run_id) 
      names(tmp) <- c('measure', 'topic', 'value', 'run')
      results <- results %>%  bind_rows(tmp)
      remove(tmp)
    }
}

# Fix as factors for printing correctly
results$run <- factor(results$run, levels=run_ids)

#mug_green <- "#007A25"
extra_color <- "darkred"

plots <- list()
for (i in seq(1, length(metrics))) {
  target <- metrics[i]
  best <- metrics_best[i]
  median <- metrics_median[i]
  worst <- metrics_worst[i]
    
  test <- results %>% filter(measure==target,topic!='all')

  means <- aggregate(value ~ run, test, mean)
  
  g <- ggplot(test, aes(x=run, y=value, fill=run)) +
      geom_boxplot(alpha=0.8) + 
      scale_fill_manual(values=tug_colors) +
      xlab("") +
      ylab(target) + 
      theme_linedraw() +
      theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        plot.background = element_blank(),
        panel.background = element_blank()) +
    
      stat_summary(fun.y=mean, color=extra_color, geom="point", shape=18, size=2,show.legend = FALSE) + 
      #geom_text(data = means, aes(label = round(value,4), y = value + 0.04)) +
      guides(fill=FALSE) + scale_y_continuous(breaks=seq(0,1,0.1), limits=c(0,1))
  
  g <- g + geom_hline(yintercept=best, linetype="dashed", color = extra_color)
      # + geom_text(aes(0.6,best,label="best", vjust = 1), color=extra_color)
  
  g <- g + geom_hline(yintercept=median, linetype="dashed", color = extra_color)
    # + geom_text(aes(0.7,median,label="median", vjust = 1), color=extra_color)
  
  # g <- g + geom_hline(yintercept=worst, linetype="dashed", color = extra_color)
    # + geom_text(aes(0.7,median,label="median", vjust = 1), color=extra_color)
  
  plots <- append(plots, list(g))
  #g
}

pdf(file = paste(task_name, ".pdf", sep=""), width = 7, height = 3.5)
grid.arrange(grobs = plots, nrow = 1, ncol = 3)
dev.off()
