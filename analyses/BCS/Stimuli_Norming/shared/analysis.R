# Shared analysis file for noun and color norming studies for BCS RSA
# Add more of a prelude here

library(tidyverse)
theme_set(theme_bw())

###############
# Take in data frame and count utterances for each color_object pairing
#
# Filtering participants by their status as a {native, heritage, 
# Macedonian/Slovenian, or foreign} speaker of BCS can be done in this script
# (e.g. see line commented out line #44), but I recommend doing it in the 
# individual analysis script, because making the change here will change it for 
# all analyses that rely on this script
#
## INPUT:
# dataframe: dataframe ending in -merged.csv 
#
## OUTPUT:
# df_split: a list of tibbles
# Each tibble contains all the color_object pairings for a given object
#   along with all responses given to each of those color_object pairings
#   and how many times participants gave each response
# Each tibble is called by the object it is counting (e.g. "book")
# 
# For example:
# df_split["book"]
# # A tibble: 3 × 4
# Groups:   object [2]
# object       cresponse count utt  
# <fct>        <chr>     <int> <chr>
# 1 blue_book  kniga         1 book 
# 2 blue_book  knjiga        2 book 
# 3 white_book knjiga        1 book 
#
#

runAnalysis <- function(dataframe) {
  df = dataframe
  
  df$cresponse = str_to_lower(gsub(" ", "", df$response))
  df$cresponse = str_to_lower(gsub("\n", "", df$cresponse))
  df$cresponse = gsub("č", "c", df$cresponse)
  df$cresponse = gsub("ć", "c", df$cresponse)
  df$cresponse = gsub("š", "s", df$cresponse)
  df$cresponse = gsub("ž", "z", df$cresponse)
  df$cresponse = gsub("đ", "dj", df$cresponse)
  
  responsesNative = df %>%
    #filter(status == "native") %>%
    group_by(object,cresponse) %>%
    summarize(count=n()) %>%
    mutate(utt = str_split(object, "_")[[1]][2])
  
  df_split <- split(responsesNative, responsesNative$utt)

  return(df_split)
}



plot_df_subset = function(df_subset, utt){
  ggplot(df_subset,aes(x=reorder(cresponse, -count), y=count))+
    geom_bar(stat="identity", fill="steelblue")+
    facet_wrap(~object, scales="free") +
    labs(title = utt) +
    theme(axis.text.x=element_text(angle = 60, size=8, hjust = 1), plot.title = element_text(face="bold", hjust = 0.5, size=20),axis.title.x=element_blank())

}
