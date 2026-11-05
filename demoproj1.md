<style>
.nav-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin: 20px 0;
}

.nav-buttons a {
  display: inline-block;
  padding: 10px 16px;
  background-color: #006699;
  color: white;
  text-decoration: none;
  border-radius: 6px;
  font-weight: bold;
}

.nav-buttons a:hover {
  background-color: #004d73;
}
</style>

<div class="nav-buttons">
  <a href="/HOSS-LiU/">Home</a>
</div>

---
layout: default
title: Analysing the Swedish Political Party-Program Documents
---
<p align="center"><img src="https://hoss-liu.github.io/HOSS-LiU/assets/images/demoproj1_poster.png"></p> 

# Analyses and results  
[Here](https://github.com/HOSS-LiU/HOSS-LiU/blob/main/assets/code/natural_language_processing_demo.R) you will find the code used for the analyses below. You can check if you get the same results or apply the code in your own analyses.  
## Text Preparation and Sentiment Analysis   
Two Swedish political party-program documents, one from the Social Democratic Party and one from the Moderate Party, were downloaded and translated from Swedish into English using Microsoft Word's automatic document translation function. The translated documents were imported into R and segmented into sentences using the tokenizers package. For text preprocessing, sentences were converted to lowercase, punctuation and numerical characters were removed, and excess whitespace was eliminated.
Sentiment was assessed at the sentence level using the sentimentr package. Each sentence received a continuous sentiment score (ave_sentiment), with higher values indicating more positive sentiment and lower values indicating more negative sentiment. For descriptive comparison, sentences were classified as positive (score > 0.10), neutral (−0.10 to 0.10), or negative (score < −0.10). These thresholds were specified by the researchers for the present demonstration.
To examine whether the distribution of sentiment classifications differed between the two documents, a Pearson chi-square test of independence was conducted. The strength of the association was quantified using Cramér's V.

### Results
The Social Democratic document contained 753 sentences, of which 445 (59.1%) were classified as positive, 151 (20.1%) as neutral, and 157 (20.8%) as negative. The Moderate document contained 651 sentences, with 408 (62.7%) classified as positive, 145 (22.3%) as neutral, and 98 (15.1%) as negative.
The distribution of sentiment classifications differed significantly between the two documents, χ²(2, N = 1,404) = 8.01, p = .018, Cramér's V = .076. Examination of the standardized residuals indicated that the largest contribution to this association concerned negative sentences, which occurred more frequently than expected in the Social Democratic document (z = 2.81) and less frequently than expected in the Moderate document (z = −2.81). The small Cramér's V indicates that the overall association between document and sentiment classification was modest.

## Structural Topic Modeling
To examine differences in thematic content between the two political documents, a structural topic model (STM) was estimated using the stm package in R. Sentences from the Social Democratic and Moderate documents were treated as individual textual units and combined into a single corpus. Text preprocessing and vocabulary preparation were performed using textProcessor() and prepDocuments().
Candidate models containing 3 to 10 topics were evaluated. For each number of topics (K), 20 models were estimated with party document included as a prevalence covariate. Model solutions were compared using semantic coherence and exclusivity, with both indices standardized to facilitate comparison across values of K. Based on these diagnostics and substantive interpretability, a six-topic solution was selected. The six-topic model was subsequently estimated across 50 runs, and one solution was retained for interpretation.`
**Figure 1.** Standardized semantic coherence and exclusivity across models containing 3-10 topics.

<p align="center"><img src="https://hoss-liu.github.io/HOSS-LiU/assets/images/demoproj1_figure1.png"></p> 

Topics were interpreted using the highest-probability, FREX, lift, and score words, together with sentences receiving high estimated topic proportions. The six topics were labeled: (1) Security and Safety Through Labour Market and Crime Policy, (2) Liberal Values, Individual Rights, and Institutional Pluralism, (3) Welfare State and Social Provision, (4) Individual Responsibility With Political Support, (5) Historical Prosperity and Development in the Face of New Challenges, and (6) Democracy, Equality, and Social Justice. Differences in topic prevalence between the two documents were estimated using estimateEffect(), with document as the predictor and global uncertainty estimation.

#### Results
Topic prevalence differed systematically between the two documents. Because the Moderate document served as the reference category, positive coefficients indicate greater topic prevalence in the Social Democratic document and negative coefficients indicate greater prevalence in the Moderate document.
The Social Democratic document showed greater prevalence of Security and Safety Through Labour Market and Crime Policy, b = 0.117, SE = 0.010, t = 12.19, p < .001; Welfare State and Social Provision, b = 0.090, SE = 0.009, t = 10.04, p < .001; and Democracy, Equality, and Social Justice, b = 0.194, SE = 0.010, t = 19.00, p < .001.
In contrast, the Moderate document showed greater prevalence of Liberal Values, Individual Rights, and Institutional Pluralism, b = −0.269, SE = 0.010, t = −27.15, p < .001, and Individual Responsibility With Political Support, b = −0.157, SE = 0.008, t = −20.25, p < .001.

The difference for Historical Prosperity and Development in the Face of New Challenges was considerably smaller, although statistically significant, with slightly greater prevalence in the Social Democratic document, b = 0.024, SE = 0.009, t = 2.55, p = .011.
