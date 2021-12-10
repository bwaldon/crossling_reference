# VISUALIZATION FUNCTIONS FROM DEGEN ET AL. (2020)

# cbbPalette <- c("#000000", "#009E73", "#e79f00", "#9ad0f3", "#0072B2", "#D55E00", "#CC79A7", "#F0E442")

visualize_sceneVariation = function(d) {
  agr <- d %>%
           select(redundant,RedundantProperty,NumDistractors,SceneVariation) %>%
           gather(Utterance,Mentioned,-RedundantProperty,-NumDistractors,-SceneVariation) %>%
           group_by(Utterance,RedundantProperty,NumDistractors,SceneVariation) %>%
           summarise(Probability=mean(Mentioned),ci.low=ci.low(Mentioned),ci.high=ci.high(Mentioned)) %>%
           ungroup() %>%
           mutate(YMin = Probability - ci.low, YMax = Probability + ci.high, Distractors=as.factor(NumDistractors))
  ggplot(agr, aes(x=SceneVariation,y=Probability,shape=Distractors,group=1)) +
    geom_point() +
    geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
    xlab("Scene variation") +
    ylab("Probability of redundant modifier") +
    scale_shape_discrete(name = "Number of\ndistractors") +
    facet_wrap(~RedundantProperty) 
}

visualize_byDyad = function(d) {
  agr_dyad = d %>%
    select(redundant,RedundantProperty,gameid) %>%
    gather(Utterance,Mentioned,-RedundantProperty,-gameid) %>%
    group_by(Utterance,RedundantProperty,gameid) %>%
    summarise(Probability=mean(Mentioned),ci.low=ci.low(Mentioned),ci.high=ci.high(Mentioned)) %>%
    ungroup() %>%
    mutate(YMin = Probability - ci.low, YMax = Probability + ci.high,dyad = fct_reorder(as.factor(gameid),Probability))
  
  ggplot(agr_dyad, aes(x=dyad,y=Probability,color=RedundantProperty)) +
    geom_point() +
    geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
    xlab("Dyad") +
    theme(axis.text.x = element_blank()) +
    ylab("Probability of redundant modifier")
}

visualize_byDyadHalf <- function(d) {
  agr_dyad = d %>%
    mutate(Half = ifelse(Trial < 37,"first","second")) %>%
    select(redundant,RedundantProperty,gameid,Half) %>%
    gather(Utterance,Mentioned,-RedundantProperty,-gameid,-Half) %>%
    group_by(Utterance,RedundantProperty,gameid,Half) %>%
    summarise(Probability=mean(Mentioned)) %>%
    ungroup() %>%
    select(gameid,Utterance,RedundantProperty,Half,Probability) %>%
    spread(Half,Probability) %>%
    mutate(Diff=second-first,dyad = fct_reorder(as.factor(gameid),Diff))
  
  ggplot(agr_dyad, aes(x=Diff,fill=RedundantProperty)) +
    geom_histogram(binwidth=.1) +
    xlab("second half minus first half overmodification proportion") +
    facet_wrap(~RedundantProperty)
}


myCenter <- function(x) {
  if (is.numeric(x)) { return(x - mean(x)) }
  if (is.factor(x)) {
    x <- as.numeric(x)
    return(x - mean(x))
  }
  if (is.data.frame(x) || is.matrix(x)) {
    m <- matrix(nrow=nrow(x), ncol=ncol(x))
    colnames(m) <- paste("c", colnames(x), sep="")
    for (i in 1:ncol(x)) {
      if (is.factor(x[,i])) {
        y <- as.numeric(x[,i])
        m[,i] <- y - mean(y, na.rm=T)
      }
      if (is.numeric(x[,i])) {
        m[,i] <- x[,i] - mean(x[,i], na.rm=T)
      }
    }
    return(as.data.frame(m))
  }
}


## for bootstrapping 95% confidence intervals
library(bootstrap)
theta <- function(x,xdata,na.rm=T) {mean(xdata[x],na.rm=na.rm)}
ci.low <- function(x,na.rm=T) {
  mean(x,na.rm=na.rm) - quantile(bootstrap(1:length(x),1000,theta,x,na.rm=na.rm)$thetastar,.025,na.rm=na.rm)}
ci.high <- function(x,na.rm=T) {
  quantile(bootstrap(1:length(x),1000,theta,x,na.rm=na.rm)$thetastar,.975,na.rm=na.rm) - mean(x,na.rm=na.rm)}