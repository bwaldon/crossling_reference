# title: "Vietnamese_RSA_Noun_Norming"
# output: pdf_document
# #rmarkdown::github_document
# #output:
# #html_document: default
# #pdf_document: default
# ---
#   #knitr::opts_chunk$set(warning= FALSE, message = FALSE, echo = TRUE)
  
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
theme_set(theme_bw())
#source("../../../shared/analysis.R")

runAnalysis <- function(dataframe) {
  df = dataframe
  
  responsesFiltered = df %>%
    #filter(status == "native") %>%
    group_by(object,response) %>%
    summarize(count=n()) %>%
    mutate(utt = str_split(object, "_")[[1]][2])
  
  df_split <- split(responsesFiltered, responsesFiltered$utt)
  
  return(df_split)
}

# plot_df_subset = function(df_subset, utt){
#   ggplot(df_subset,aes(x=reorder(response, -count), y=count))+
#     geom_bar(stat="identity", fill="steelblue")+
#     facet_wrap(~object, scales="free") +
#     labs(title = utt) +
#     theme(axis.text.x=element_text(angle = 60, size=8, hjust = 1), plot.title = element_text(face="bold", hjust = 0.5, size=20),axis.title.x=element_blank())
#   
# }

df = read.csv("vietnamese_noun_norming-merged.csv", header = TRUE)

subjectCleanUp <- df %>%
  select(workerid, subject_information.VietPrimaryLanguageSchool, subject_information.firstLanguage) %>%
  unique()

#view(subjectCleanUp)

# get rid of participants who answered with English

df <- df %>%
  filter(workerid != 29 & workerid != 39)


df %>%
  select(workerid) %>%
  unique() %>%
  nrow()

df$response = str_to_lower(str_replace_all(df$response, "\n", ""))
df$response = str_replace_all(df$response, "à", "a")
df$response = str_replace_all(df$response,"í|ị|ĩ|ì", "i")
df$response = str_replace_all(df$response,"ỏ", "o")
df$response = str_replace_all(df$response,"ắ", "a")
df$response = str_replace_all(df$response,"ờ", "o")
df$response = str_replace_all(df$response, "đ", "d")
df$response = str_replace_all(df$response,"ỏ", "o")
df$response = str_replace_all(df$response,"á|ầ|ả|ẩ|ậ", "a")
df$response = str_replace_all(df$response,"ạ", "a")
df$response = str_replace_all(df$response,"â", "a")
df$response = str_replace_all(df$response,"ấ", "a")
df$response = str_replace_all(df$response,"ẫ", "a")
df$response = str_replace_all(df$response,"ă", "a")
df$response = str_replace_all(df$response,"ư|ù|ú|ủ|ự|ụ|ứ|ử|ũ|ừ|ữ", "u")
df$response = str_replace_all(df$response,"ớ|ộ|ổ|ợ|ô|ò|ỗ|ó|ố|ỡ|ọ|ở", "o")
df$response = str_replace_all(df$response,"ồ", "o")
df$response = str_replace_all(df$response,"ể|ế|è|ẻ|ệ|ề|é|ê|ẹ|ễ", "e")
df$response = str_replace_all(df$response,"ơ", "o")
df$response = str_replace_all(df$response,"ý", "y")
df$response = sub(',.*', '', df$response)
df$response = sub('mau.*', '', df$response)


df$response = str_to_lower(str_replace_all(df$response, "ghi-ta", "ghi ta"))
d$response = str_to_lower(str_replace_all(df$response, "guitar", "ghi ta"))
df$response = str_to_lower(str_replace_all(df$response, "cat-set", "cat set"))
df$response = str_to_lower(str_replace_all(df$response, "bi-a", "bida"))
df$response = str_to_lower(str_replace_all(df$response, "tivi", "ti vi"))
df$response = str_to_lower(str_replace_all(df$response, "tv", "ti vi"))
df$response = str_to_lower(str_replace_all(df$response, "vali", "va li"))
df$response = str_to_lower(str_replace_all(df$response, "boday cot", "bo"))
df$response = str_to_lower(str_replace_all(df$response, "pi-a-no", "piano"))
df$response = str_to_lower(str_replace_all(df$response, "tshirt", ''))
df$response = str_to_lower(str_replace_all(df$response, "mai", ''))
df$response = str_to_lower(str_replace_all(df$response, "robo ", "ro bo"))
df$response = str_to_lower(str_replace_all(df$response, "ro bot", "ro bo"))
df$response = str_to_lower(str_replace_all(df$response, "cai ", ''))
df$response = str_to_lower(str_replace_all(df$response, "cay ", ''))
df$response = str_to_lower(str_replace_all(df$response, "con ", ''))
df$response = str_replace_all(df$response,"viang", "vang")

df$response = str_replace_all(df$response,"cayt", "cay")
df$response = str_replace_all(df$response,"chan", "trang")
df$response = str_replace_all(df$response,"xan", "xanh")
df$response = str_replace_all(df$response,"cahn", "trang")
df$response = str_replace_all(df$response,"trrang", "trang")
df$response = str_replace_all(df$response,"dao", "do")
df$response = str_replace_all(df$response,"dan", "den")
df$response = str_replace_all(df$response,"thiem", "tim")
df$response = str_replace_all(df$response,"cya", "cay")
df$response = str_replace_all(df$response,"den'", "den")
df$response = str_replace_all(df$response,"xanh ls", "xanh la")
df$response = str_replace_all(df$response,"xanhh", "xanh")
df$response = str_replace_all(df$response,"-", " ")
df$response = str_trim(df$response)

# switch item fix
df$response = str_replace_all(df$response, "cong tac den", "cong tac")
df$response = str_replace_all(df$response, "cong tac den dien vang", "cong tac")
df$response = str_replace_all(df$response, "cong tac dien", "cong tac")
df$response = str_replace_all(df$response, "cong tac vang", "cong tac")
# ring item fix
df$response = str_replace_all(df$response,"chiec nhan", "nhan")
# candy item fix
df$response = str_replace_all(df$response, "cuc keo", "keo")
df$response = str_replace_all(df$response, "keo den", "keo")
df$response = str_replace_all(df$response, "vien keo", "keo")
# piano item fix
df$response = str_replace_all(df$response, "den piano", "piano")
df$response = str_replace_all(df$response, "ban piano", "piano")
df$response = str_replace_all(df$response, "den pi a no", "piano")
# bucket item fix
df$response = str_replace_all(df$response, "xo nhua", "xo")
df$response = str_replace_all(df$response, "xo nuoc", "xo")
df$response = str_replace_all(df$response, "xo xanh nuoc bien", "xo")
# lipstick item fix
df$response = str_replace_all(df$response, "son boi moi cam", "son")
df$response = str_replace_all(df$response, "son moi", "son")
df$response = str_replace_all(df$response, "thoi son", "son")
# lap item fix
df$response = str_replace_all(df$response, "bong den", "den")
df$response = str_replace_all(df$response, "den ban", "den")
df$response = str_replace_all(df$response, "den de ban", "den")
df$response = str_replace_all(df$response, "bong ngu", "den")
df$response = str_replace_all(df$response, "den trang", "den")
# flower item fix
df$response = str_replace_all(df$response, "bong hoa", "hoa")
df$response = str_replace_all(df$response, "doa hoa", "hoa")
df$response = str_replace_all(df$response, "hoa ram but", "hoa")
# clock item fix
df$response = str_replace_all(df$response, "dong ho bao thuc", "dong ho")
# ruler item fix
df$response = str_replace_all(df$response, "thuoc ke", "thuoc")
df$response = str_replace_all(df$response, "thuoc ke trang", "thuoc")
# guitar item fix
df$response = str_replace_all(df$response, "den ghi ta", "ghi ta")
df$response = str_replace_all(df$response, "den ghita", "ghi ta")
df$response = str_replace_all(df$response, "den gui ta dien", "ghi ta")
df$response = str_replace_all(df$response, "den guitar", "ghi ta")
df$response = str_replace_all(df$response, "den ghita dien", "ghi ta")
df$response = str_replace_all(df$response, "den guitar dien", "ghi ta")
df$response = str_replace_all(df$response, "ghi ta dien", "ghi ta")
df$response = str_replace_all(df$response, "guita", "ghi ta")
df$response = str_replace_all(df$response, "guitar dien", "ghi ta")
df$response = str_replace_all(df$response, "guitar dien trang", "ghi ta")
# phone item fix
df$response = str_replace_all(df$response, "dien thoai ban", "dien thoai")
# lock item fix
df$response = str_replace_all(df$response, "o khoa", "khoa")
# shoe item fix
df$response = str_replace_all(df$response, "chiec day", "giay")
df$response = str_replace_all(df$response, "chiec giay", "giay")
df$response = str_replace_all(df$response, "giay nu", "giay")
df$response = str_replace_all(df$response, "giay cao got", "giay")
# armchair item fix
df$response = str_replace_all(df$response, "ghe banh", "ghe")
df$response = str_replace_all(df$response, "ghe dau", "ghe")
df$response = str_replace_all(df$response, "ghe so pha", "ghe")
df$response = str_replace_all(df$response, "ghe sofa", "ghe")
# balloon item fix
df$response = str_replace_all(df$response, "bong bay", "bong bong")
df$response = str_replace_all(df$response, "bong bong bay", "bong bong")
df$response = str_replace_all(df$response, "bong bong trang", "bong bong")
# dresser item fix
df$response = str_replace_all(df$response, "tu ke", "tu")
df$response = str_replace_all(df$response, "tu keo", "tu")
df$response = str_replace_all(df$response, "tu quan ao", "tu")
# coathanger item fix
df$response = str_replace_all(df$response, "do moc quan ao", "moc")
df$response = str_replace_all(df$response, "mic ao", "moc")
df$response = str_replace_all(df$response, "moc ao", "moc")
df$response = str_replace_all(df$response, "moc quan ao", "moc")
df$response = str_replace_all(df$response, "mic do", "moc")
df$response = str_replace_all(df$response, "moc ao trang", "moc")
df$response = str_replace_all(df$response, "moc treo do", "moc")
df$response = str_replace_all(df$response, "moc treo quan ao", "moc")
# rope item fix
df$response = str_replace_all(df$response, "cong day", "day")
df$response = str_replace_all(df$response, "day len", "day")
df$response = str_replace_all(df$response, "day xanh", "day")
df$response = str_replace_all(df$response, "day thung", "day")
df$response = str_replace_all(df$response, "so day", "day")
df$response = str_replace_all(df$response, "soi day", "day")
# calculator item fix
df$response = str_replace_all(df$response, "may tinh bo tui", "may tinh")
df$response = str_replace_all(df$response, "may tinh cam tay", "may tinh")
# calculator item fix
df$response = str_replace_all(df$response, "khung anh", "khung")
df$response = str_replace_all(df$response, "khung hinh", "khung")
df$response = str_replace_all(df$response, "khung tranh", "khung")
# robot item fix
df$response = str_replace_all(df$response, "robot", "ro bo")
df$response = str_replace_all(df$response, "ro bo day cot", "ro bo")
df$response = str_replace_all(df$response, "ro bo do choi", "ro bo")
df$response = str_replace_all(df$response, "ro bot", "ro bo")
# die item fix
df$response = str_replace_all(df$response, "xuc xac xanh", "xuc xac")
df$response = str_replace_all(df$response, "xuc sac", "xuc xac")
df$response = str_replace_all(df$response, "suc sac", "xuc xac")
df$response = str_replace_all(df$response, "vien xuc xac", "xuc xac")
# shell item fix
df$response = str_replace_all(df$response, "vo so", "so")
df$response = str_replace_all(df$response, "xo", "so")
df$response = str_replace_all(df$response, "vo oc", "so")
# cake item fix
df$response = str_replace_all(df$response, "banh ga to", "banh")
df$response = str_replace_all(df$response, "banh gato", "banh")
df$response = str_replace_all(df$response, "banh kem", "banh")
# rug item fix
df$response = str_replace_all(df$response, "tam tham", "tham")
df$response = str_replace_all(df$response, "tham chui trang", "tham")
df$response = str_replace_all(df$response, "tham trai trang", "tham")
# vase item fix
df$response = str_replace_all(df$response, "binh bong", "binh")
df$response = str_replace_all(df$response, "binh cam hoa", "binh")
df$response = str_replace_all(df$response, "binh hoa", "binh")
df$response = str_replace_all(df$response, "binh xanh la cay", "binh")
# purse item fix
df$response = str_replace_all(df$response, "tui xach", "tui")
df$response = str_replace_all(df$response, "tui nu", "tui")
# razor item fix
df$response = str_replace_all(df$response, "cao rau", "cao")
df$response = str_replace_all(df$response, "do cao", "cao")
df$response = str_replace_all(df$response, "do cao rau", "cao")
df$response = str_replace_all(df$response, "do cao rau/long", "cao")
df$response = str_replace_all(df$response, "do cau rau", "cao")
# mouse item fix
df$response = str_replace_all(df$response, "chuot  may tinh", "chuot")
df$response = str_replace_all(df$response, "chuot may tinh", "chuot")
df$response = str_replace_all(df$response, "chuot vi tinh", "chuot")
df$response = str_replace_all(df$response, "cuot", "chuot")
# napkin item fix
df$response = str_replace_all(df$response, "khan an", "khan")
df$response = str_replace_all(df$response, "khan ban", "khan")
df$response = str_replace_all(df$response, "khan chuoi mieng", "khan")
df$response = str_replace_all(df$response, "khan tay", "khan")
# ornament item fix
df$response = str_replace_all(df$response, "bong trang tri", "trang tri")
df$response = str_replace_all(df$response, "bong trang tri noel", "trang tri")
df$response = str_replace_all(df$response, "bong trang tri thong noel", "trang tri")
df$response = str_replace_all(df$response, "do trang tri thong", "trang tri")
df$response = str_replace_all(df$response, "do trang tri no en", "trang tri")
df$response = str_replace_all(df$response, "do trang chi thong", "trang tri")
df$response = str_replace_all(df$response, "qua cau trang tri", "trang tri")
df$response = str_replace_all(df$response, "trang suc", "trang tri")
df$response = str_replace_all(df$response, "trang tri", "trang tri")
df$response = str_replace_all(df$response, "vat trang ti", "trang tri")
df$response = str_replace_all(df$response, "do trang tri", "trang tri")
df$response = str_replace_all(df$response, "den tri", "trang tri")
df$response = str_replace_all(df$response, "trang tri noel", "trang tri")
df$response = str_replace_all(df$response, "trang tri thong noel", "trang tri")
# scarf item fix
df$response = str_replace_all(df$response, "khan choang", "khan")
df$response = str_replace_all(df$response, "khan choang co", "khan")
df$response = str_replace_all(df$response, "khan quan", "khan")
df$response = str_replace_all(df$response, "khan quang", "khan")
df$response = str_replace_all(df$response, "khan quang co", "khan")
df$response = str_replace_all(df$response, "khan quang co do", "khan")
df$response = str_replace_all(df$response, "khoan choang", "khan")
df$response = str_replace_all(df$response, "khan co", "khan")
df$response = str_replace_all(df$response, "khang co", "khan")
# remote item fix
df$response = str_replace_all(df$response, "dieu khien ti vi", "dieu khien")
df$response = str_replace_all(df$response, "dieu khien ti vi tu xa", "dieu khien")
df$response = str_replace_all(df$response, "dieu khien tu xa", "dieu khien")
df$response = str_replace_all(df$response, "dieu khien vo tuyen", "dieu khien")
df$response = str_replace_all(df$response, "do dieu khien", "dieu khien")
df$response = str_replace_all(df$response, "remote", "dieu khien")
df$response = str_replace_all(df$response, "remote ti vi", "dieu khien")
df$response = str_replace_all(df$response, "ri mot", "dieu khien")
# belt item fix, two main answers
df$response = str_replace_all(df$response, "day nit", "nit")
df$response = str_replace_all(df$response, "day trang", "nit")
df$response = str_replace_all(df$response, "day lung", "nit")
df$response = str_replace_all(df$response, "that lung", "nit")
# candle item fix, two main answers
df$response = str_replace_all(df$response, "nen trang", "nen")
df$response = str_replace_all(df$response, "den cay", "nen")
# cap item fix, two main answers
df$response = str_replace_all(df$response, "non ket", "non")
df$response = str_replace_all(df$response, "nong", "non")
df$response = str_replace_all(df$response, "mu luoi trai", "non")
df$response = str_replace_all(df$response, "mu luoi chai", "non")
# mug item fix, two main answers
df$response = str_replace_all(df$response, "coc trang", "coc")
df$response = str_replace_all(df$response, "li", "coc")
df$response = str_replace_all(df$response, "ly", "coc")
# spoon item fix, two main answers
df$response = str_replace_all(df$response, "thia", "muong")
# sock item fix, two main answers
df$response = str_replace_all(df$response, "chiec tat", "tat")
df$response = str_replace_all(df$response, "chiec vo", "tat")
df$response = str_replace_all(df$response, "chiec v", "tat")
df$response = str_replace_all(df$response, "tat den", "tat")
df$response = str_replace_all(df$response, "tat trang", "tat")
df$response = str_replace_all(df$response, "tat xanh", "tat")
df$response = str_replace_all(df$response, "vo", "tat")
# dress item fix, two main answers
df$response = str_replace_all(df$response, "dam", "vay")
df$response = str_replace_all(df$response, "ao dam", "vay")
df$response = str_replace_all(df$response, "vay trang mua he", "vay")



view(df)

df_split <- runAnalysis(df)

getPercent <- function(objectName) {
  
  tib <- df_split[[objectName]]
  totalSum <- tib$count %>%
    sum()
  
  maxCount <- tib %>%
    group_by(response) %>%
    summarise(n = sum(count))
  maxNum <- maxCount[which.max(maxCount$n),]$n
  return(maxNum/totalSum)
}

getLabel <- function(objectName) {
  
  tib <- df_split[[objectName]]
  maxCount <- tib %>%
    group_by(response) %>%
    summarise(n = sum(count))
  return(maxCount[which.max(maxCount$n),][[1]])
}

allNames <- names(df_split)
# create dataframe with most common responses 
# and percent of people that responded with them
df_percent <- data.frame(Item = allNames,
                         label = unlist(lapply(allNames, getLabel)),
                         percent = unlist(lapply(allNames, getPercent)))

df_accept <- df_percent %>%
  filter(percent >= 0.7) %>%
  arrange(percent)

df_deny <- df_percent %>%
  filter(percent < 0.7) %>%
  arrange(percent)

df %>%
  filter(utterance == "stapler") %>%
  group_by(response) %>%
  count()


df_french = read.csv("french_noun_final.csv", header = TRUE)


df_1 <- subset(df_french, select = -c(X, Gender, common))

df_2 <- subset(df_accept, select = -c(label))

df_all <- rbind(df_1, df_2)

n_occur <- data.frame(table(df_all$Item)) %>%
  filter(Freq == 1)

vec1 <- df_accept$Item

view(vec1)

write_csv(n_occur, "similar_nouns.csv")








