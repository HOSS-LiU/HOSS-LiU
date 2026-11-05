# HOSS-lab (Human Open Science Services)

# Demonstration project

#

# This script demonstrates the preparation and analysis of text documents

# using sentence-level sentiment analysis and Structural Topic Modeling (STM).

#

# The workflow includes:

# 1. Loading and preparing two Word documents

# 2. Splitting documents into sentences

# 3. Cleaning sentence-level text

# 4. Conducting sentence-level sentiment analysis

# 5. Comparing sentiment distributions between documents

# 6. Preparing text for Structural Topic Modeling

# 7. Comparing STM models with different numbers of topics

# 8. Selecting and examining a six-topic model

# 9. Estimating topic effects by document

#

# -------------------------------------------------------------------------

# SOURCE DOCUMENTS AND TRANSLATION

# -------------------------------------------------------------------------

#

# Before running this code:

#

# 1. The two source documents were downloaded.

# 2. The documents were translated from Swedish into English using

# Microsoft Word's automatic document translation.

#

# The analysis is therefore conducted on English-language versions of

# the original Swedish documents.

#

# -------------------------------------------------------------------------

# 1. LOAD REQUIRED PACKAGES

# -------------------------------------------------------------------------

{
  
  library("stm")
  library("topicmodels")
  library("slam")
  library(lsr)
  library(officer)
  library(dplyr)
  library(stringr)
  library(tidytext)
  library(sentimentr)
  library(ggplot2)
  library(tokenizers)
  library(tibble)
  library(writexl)
  
}

# -------------------------------------------------------------------------

# 2. LOAD AND PREPARE THE MODERATES DOCUMENT

# -------------------------------------------------------------------------

# Read the Moderates Word document.

mod_doc <- read_docx("engmod.docx")

# Extract text from the document and combine all non-missing text

# elements into a single character string.

mod_text_raw <- docx_summary(mod_doc)$text
mod_text_raw <- paste(mod_text_raw[!is.na(mod_text_raw)], collapse = " ")

# -------------------------------------------------------------------------

# 3. SPLIT MODERATES DOCUMENT INTO SENTENCES

# -------------------------------------------------------------------------

# Split the document into individual sentences.

mod_sentences <- tokenize_sentences(mod_text_raw)[[1]]

# Create a data frame containing one row per sentence.

mod_sent_df <- tibble(
  sentence_id = seq_along(mod_sentences),
  sentence = mod_sentences
)

# -------------------------------------------------------------------------

# 4. CLEAN MODERATES SENTENCES

# -------------------------------------------------------------------------

# Create a cleaned version of each sentence.

#

# The original sentence is retained in the 'sentence' column.

#

# Cleaning consists of:

# - converting text to lowercase

# - replacing punctuation with spaces

# - removing digits

# - removing excess whitespace

mod_sent_df <- mod_sent_df %>%
  mutate(sentence_clean = sentence %>%
           str_to_lower() %>%
           str_replace_all("[[:punct:]]", " ") %>%
           str_replace_all("[[:digit:]]", " ") %>%
           str_squish())

# Display the first 200 characters of the first cleaned sentence.

cat(substr(mod_sent_df$sentence_clean[1], 1, 200))

# -------------------------------------------------------------------------

# 5. LOAD AND PREPARE THE SOCIAL DEMOCRATS DOCUMENT

# -------------------------------------------------------------------------

# Read the Social Democrats Word document.

soc_doc <- read_docx("engsoc.docx")

# Extract text from the document and combine all non-missing text

# elements into a single character string.

soc_text_raw <- docx_summary(soc_doc)$text
soc_text_raw <- paste(soc_text_raw[!is.na(soc_text_raw)], collapse = " ")

# -------------------------------------------------------------------------

# 6. SPLIT SOCIAL DEMOCRATS DOCUMENT INTO SENTENCES

# -------------------------------------------------------------------------

# Split the document into individual sentences.

soc_sentences <- tokenize_sentences(soc_text_raw)[[1]]

# Create a data frame containing one row per sentence.

soc_sent_df <- tibble(
  sentence_id = seq_along(soc_sentences),
  sentence = soc_sentences
)

# -------------------------------------------------------------------------

# 7. CLEAN SOCIAL DEMOCRATS SENTENCES

# -------------------------------------------------------------------------

# Apply the same cleaning procedure used for the Moderates document.

soc_sent_df <- soc_sent_df %>%
  mutate(sentence_clean = sentence %>%
           str_to_lower() %>%
           str_replace_all("[[:punct:]]", " ") %>%
           str_replace_all("[[:digit:]]", " ") %>%
           str_squish())

# Display the first 200 characters of the first cleaned sentence.

cat(substr(soc_sent_df$sentence_clean[1], 1, 200))

# -------------------------------------------------------------------------

# 8. SENTENCE-LEVEL SENTIMENT: MODERATES

# -------------------------------------------------------------------------

# Estimate sentiment for each Moderates sentence.

mod_sentiment_results <- sentiment_by(mod_sentences) %>%
  as_tibble() %>%
  mutate(sentence_id = row_number()) %>%
  left_join(mod_sent_df, by = "sentence_id") %>%
  select(sentence_id, sentence, ave_sentiment, word_count)

print(mod_sentiment_results)

# -------------------------------------------------------------------------

# 9. SUMMARY STATISTICS: MODERATES

# -------------------------------------------------------------------------

# Calculate descriptive statistics for the Moderates sentiment scores.

mod_sentiment_summary <- mod_sentiment_results %>%
  summarise(
    n_sentences = n(),
    mean_sentiment = mean(ave_sentiment, na.rm = TRUE),
    median_sentiment = median(ave_sentiment, na.rm = TRUE),
    sd_sentiment = sd(ave_sentiment, na.rm = TRUE)
  )

print(mod_sentiment_summary)

# -------------------------------------------------------------------------

# 10. SENTIMENT CATEGORIES: MODERATES

# -------------------------------------------------------------------------

# Classify Moderates sentences according to their sentiment score.

#

# Scores above 0.1 are classified as positive.

# Scores below -0.1 are classified as negative.

# Scores between -0.1 and 0.1 are classified as neutral.

mod_sentiment_results <- mod_sentiment_results %>%
  mutate(
    sentiment_label = case_when(
      ave_sentiment > 0.1 ~ "positive",
      ave_sentiment < -0.1 ~ "negative",
      TRUE ~ "neutral"
    )
  )

print(table(mod_sentiment_results$sentiment_label))

# -------------------------------------------------------------------------

# 11. SAVE MODERATES SENTIMENT RESULTS

# -------------------------------------------------------------------------

# Save the Moderates sentence-level sentiment results.

write.csv(
  mod_sentiment_results,
  "mod_sentence_sentiment.csv",
  row.names = FALSE
)

# -------------------------------------------------------------------------

# 12. SENTENCE-LEVEL SENTIMENT: SOCIAL DEMOCRATS

# -------------------------------------------------------------------------

# Estimate sentiment for each Social Democrats sentence.

soc_sentiment_results <- sentiment_by(soc_sentences) %>%
  as_tibble() %>%
  mutate(sentence_id = row_number()) %>%
  left_join(soc_sent_df, by = "sentence_id") %>%
  select(sentence_id, sentence, ave_sentiment, word_count)

print(soc_sentiment_results)

# -------------------------------------------------------------------------

# 13. SUMMARY STATISTICS: SOCIAL DEMOCRATS

# -------------------------------------------------------------------------

# Calculate descriptive statistics for the Social Democrats

# sentiment scores.

soc_sentiment_summary <- soc_sentiment_results %>%
  summarise(
    n_sentences = n(),
    mean_sentiment = mean(ave_sentiment, na.rm = TRUE),
    median_sentiment = median(ave_sentiment, na.rm = TRUE),
    sd_sentiment = sd(ave_sentiment, na.rm = TRUE)
  )

print(soc_sentiment_summary)

# -------------------------------------------------------------------------

# 14. SENTIMENT CATEGORIES: SOCIAL DEMOCRATS

# -------------------------------------------------------------------------

# Classify Social Democrats sentences according to their sentiment score.

soc_sentiment_results <- soc_sentiment_results %>%
  mutate(
    sentiment_label = case_when(
      ave_sentiment > 0.1 ~ "positive",
      ave_sentiment < -0.1 ~ "negative",
      TRUE ~ "neutral"
    )
  )

print(table(soc_sentiment_results$sentiment_label))

# -------------------------------------------------------------------------

# 15. SAVE SOCIAL DEMOCRATS SENTIMENT RESULTS

# -------------------------------------------------------------------------

# Save the Social Democrats sentence-level sentiment results.

write.csv(
  soc_sentiment_results,
  "soc_sentence_sentiment.csv",
  row.names = FALSE
)

# -------------------------------------------------------------------------

# 16. CHI-SQUARE TEST OF SENTIMENT DISTRIBUTIONS

# -------------------------------------------------------------------------

# Create a contingency table containing the observed numbers of

# positive, neutral, and negative sentences for the two documents.
soc_counts <- table(soc_sentiment_results$sentiment_label)
mod_counts <- table(mod_sentiment_results$sentiment_label)

sentiment_observed_matrix <- rbind(
  SocialDemocrats = c(
    soc_counts["positive"],
    soc_counts["neutral"],
    soc_counts["negative"]
  ),
  Moderates = c(
    mod_counts["positive"],
    mod_counts["neutral"],
    mod_counts["negative"]
  )
)

sentiment_observed_matrix
# Perform a chi-square test to assess whether the distribution of

# sentiment categories differs between the two documents.

sentiment_chi_test <- chisq.test(sentiment_observed_matrix)

print(sentiment_chi_test)

# Expected frequencies under the null hypothesis of independence.

sentiment_chi_test$expected

# Standardized Pearson residuals.

#

# These indicate which cells contribute most strongly to the

# difference between observed and expected frequencies.

sentiment_chi_test$stdres



# -------------------------------------------------------------------------

# 17. COMBINE SENTIMENT DATA FOR STM

# -------------------------------------------------------------------------

# Load the saved sentiment results for both documents.

soc_sentiment_data <- read.csv("soc_sentence_sentiment.csv")
mod_sentiment_data <- read.csv("mod_sentence_sentiment.csv")

# Add a document identifier to each dataset.

soc_sentiment_data$doc <- "SocialDem"
mod_sentiment_data$doc <- "Moderates"

# Combine the two datasets into a single data frame.

combined_sentiment_data <- rbind(
  soc_sentiment_data,
  mod_sentiment_data
)

# -------------------------------------------------------------------------

# 18. PREPARE TEXT FOR STRUCTURAL TOPIC MODELING

# -------------------------------------------------------------------------

# Set a seed to make stochastic parts of the analysis reproducible.

set.seed(23456)

# Prepare the sentence-level text for STM.

#

# The sentence text is supplied as the document input, while the

# combined data frame is supplied as metadata.

stm_processed <- textProcessor(
  documents = combined_sentiment_data$sentence,
  metadata = combined_sentiment_data
)

# Prepare documents, vocabulary, and metadata for STM.

stm_prepared <- prepDocuments(
  documents = stm_processed$documents,
  vocab = stm_processed$vocab,
  meta = stm_processed$meta
)

# Store the processed STM components using explicit names.

stm_documents <- stm_prepared$documents
stm_vocab <- stm_prepared$vocab
stm_metadata <- stm_prepared$meta

# -------------------------------------------------------------------------

# 19. COMPARE MODELS WITH DIFFERENT NUMBERS OF TOPICS

# -------------------------------------------------------------------------

# Define the range of topic numbers to evaluate.

# Models with between 3 and 10 topics will be estimated.

stm_K_values <- 3:10

# Store model-selection results in a dedicated object.

stm_model_results <- list()

# Estimate multiple models for each value of K.

#

# For each K:

# - 20 model runs are estimated

# - document type is included as a prevalence covariate

# - a maximum of 75 EM iterations is used

# - a fixed seed is used for reproducibility

for (K in stm_K_values) {
  stm_model_results[[as.character(K)]] <- selectModel(
    stm_documents,
    stm_vocab,
    K = K,
    prevalence =~ doc,
    max.em.its = 75,
    data = stm_metadata,
    runs = 20,
    seed = 8458159
  )
}

# -------------------------------------------------------------------------

# 20. MODEL DIAGNOSTICS

# -------------------------------------------------------------------------

# Create dedicated objects for semantic coherence and exclusivity.

stm_semantic_coherence <- list()
stm_exclusivity <- list()

# Create a data frame for storing diagnostics for every model run.

stm_model_diagnostics <- data.frame()

# Extract semantic coherence and exclusivity for each model run.

for (K in names(stm_model_results)) {
  
  current_stm_model <- stm_model_results[[K]]
  
  # Number of runs for the current number of topics.
  
  current_number_of_runs <- length(current_stm_model$semcoh)
  
  # Extract diagnostic measures for each run.
  
  for (run in 1:current_number_of_runs) {
    
    stm_semantic_coherence[[length(stm_semantic_coherence) + 1]] <-
      current_stm_model$semcoh[[run]]
    
    stm_exclusivity[[length(stm_exclusivity) + 1]] <-
      current_stm_model$exclusivity[[run]]
    
    # Store model number, run number, semantic coherence,
    # and exclusivity.
    
    stm_model_diagnostics <- rbind(
      stm_model_diagnostics,
      data.frame(
        K = as.numeric(K),
        Run = run,
        SemCoh = current_stm_model$semcoh[[run]],
        Exclusivity = current_stm_model$exclusivity[[run]],
        stringsAsFactors = FALSE
      )
    )
    
  }
}

# -------------------------------------------------------------------------

# 21. AVERAGE MODEL DIAGNOSTICS

# -------------------------------------------------------------------------

# Calculate average semantic coherence and exclusivity

# for each number of topics.

stm_model_diagnostics_average <- stm_model_diagnostics %>%
  group_by(K) %>%
  summarise(
    Avg_SemCoh = mean(SemCoh, na.rm = TRUE),
    Avg_Exclusivity = mean(Exclusivity, na.rm = TRUE)
  )

# Standardize the two diagnostic measures so they can be

# displayed on a common scale.

stm_model_diagnostics_average$Std_SemCoh <-
  scale(stm_model_diagnostics_average$Avg_SemCoh)

stm_model_diagnostics_average$Std_Exclusivity <-
  scale(stm_model_diagnostics_average$Avg_Exclusivity)

# Convert the diagnostic data to long format for plotting.

#

# A separate object is used here so that the original averaged

# diagnostic data remain available.

stm_model_diagnostics_long <- tidyr::pivot_longer(
  stm_model_diagnostics_average,
  cols = c(Std_SemCoh, Std_Exclusivity),
  names_to = "Metric",
  values_to = "Value"
)

# -------------------------------------------------------------------------

# 22. PLOT MODEL DIAGNOSTICS

# -------------------------------------------------------------------------

# Plot standardized semantic coherence and exclusivity across

# different numbers of topics.

stm_model_diagnostics_plot <- ggplot(
  stm_model_diagnostics_long,
  aes(x = K, y = Value, color = Metric)
) +
  geom_line() +
  geom_point() +
  scale_x_continuous(
    breaks = seq(
      3,
      max(stm_model_diagnostics_long$K),
      by = 1
    ),
    limits = c(
      3,
      max(stm_model_diagnostics_long$K)
    )
  ) +
  scale_color_manual(
    values = c(
      "Std_SemCoh" = "blue",
      "Std_Exclusivity" = "red"
    ),
    labels = c(
      "Std_SemCoh" = "Semantic Coherence",
      "Std_Exclusivity" = "Exclusivity"
    )
  ) +
  labs(
    title = "",
    x = "Number of Topics",
    y = "Z Value",
    color = "Metric"
  ) +
  theme_classic() +
  geom_point(
    data = subset(
      stm_model_diagnostics_long,
      K == 6
    ),
    aes(x = K, y = Value),
    shape = 1,
    size = 5,
    stroke = 2,
    color = "black"
  )

# Display the model diagnostic plot.

print(stm_model_diagnostics_plot)

# -------------------------------------------------------------------------

# 23. SAVE MODEL DIAGNOSTIC PLOT

# -------------------------------------------------------------------------

# Save the diagnostic plot as a high-resolution PNG image.

ggsave(
  "Pref20_semantic_coherence_exclusivity.png",
  plot = stm_model_diagnostics_plot,
  dpi = 300,
  width = 10,
  height = 4,
  units = "in"
)

# -------------------------------------------------------------------------

# 24. ESTIMATE THE SIX-TOPIC MODEL

# -------------------------------------------------------------------------

# Estimate a six-topic STM model using 50 model runs.

#

# The model uses 'doc' as a document-level prevalence covariate.

k6_model <- selectModel(
  stm_documents,
  stm_vocab,
  K = 6,
  max.em.its = 300,
  data = stm_metadata,
  prevalence =~ doc,
  runs = 50,
  seed = 5926696
)

# Display model diagnostics for the six-topic model.

plotModels(k6_model)

# -------------------------------------------------------------------------

# 25. SELECT A MODEL RUN

# -------------------------------------------------------------------------

# Select the third run from the six-topic model results.

k6_selected_run <- k6_model$runout[[3]]

# Plot the selected six-topic model.

plot(k6_selected_run)

# -------------------------------------------------------------------------

# 26. EXPORT TOPIC PROPORTIONS

# -------------------------------------------------------------------------

# Load the package required for Excel output.



# Add theta1-theta6 to a dedicated copy of the STM metadata.

#

# This keeps the original stm_metadata object unchanged.

k6_metadata_with_theta <- stm_metadata

k6_metadata_with_theta[paste0("theta", 1:6)] <-
  as.data.frame(k6_selected_run$theta[, 1:6])

# Select the sentence, document identifier, and topic proportions.

k6_topic_weights <- k6_metadata_with_theta %>%
  select(sentence, doc, starts_with("theta"))

# Save the topic proportions as an Excel spreadsheet.

write_xlsx(
  k6_topic_weights,
  "weights_PrefK6.xlsx"
)

# -------------------------------------------------------------------------

# 27. ESTIMATE TOPIC EFFECTS

# -------------------------------------------------------------------------

# Determine the number of topics in the selected model.

k6_number_of_topics <- ncol(k6_selected_run$theta)

print(k6_number_of_topics)

# Set a random seed to make the estimation reproducible.

set.seed(1234)

# Estimate the relationship between document type and topic prevalence.

#

# The document variable ('doc') is used as the explanatory variable.

# The analysis estimates the effect of document type on each topic.

k6_topic_effects <- estimateEffect(
  1:k6_number_of_topics ~ doc,
  stmobj = k6_selected_run,
  metadata = k6_metadata_with_theta,
  uncertainty = "Global"
)

# Display a summary of the estimated topic effects.

summary(k6_topic_effects)

# -------------------------------------------------------------------------

# 28. EXAMINE TOPIC TERMS

# -------------------------------------------------------------------------

# Display the five most important terms associated with each topic

# in the selected six-topic model.

labelTopics(
  k6_selected_run,
  topics = NULL,
  n = 5
)
