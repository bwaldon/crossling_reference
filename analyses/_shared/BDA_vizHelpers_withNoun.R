graphCostPosteriors_withNoun <- function(posteriors) {
  posteriors <- posteriors %>% filter(Parameter %in% c("colorCost","sizeCost","nounCost"))
  posteriors$Parameter <- relevel(posteriors$Parameter, ref = "colorCost")
  labels = c(colorCost = "color", sizeCost = "size", nounCost = "noun")
  scale_value=1
  return(ggplot(posteriors, aes(x = value)) +
           geom_histogram(aes(y=..density..),
                          data=subset(posteriors, Parameter == "colorCost"),
                          binwidth = .02, colour="black", fill="white") +
           geom_histogram(aes(y=..density..),
                          data =subset(posteriors, Parameter == "sizeCost" ),
                          binwidth = .02, colour="black", fill="white") +
           geom_histogram(aes(y=..density..),
                          data =subset(posteriors, Parameter == "nounCost" ),
                          binwidth = .02, colour="black", fill="white") +
           geom_density(aes(y=..density..), alpha=.5,
                        data=subset(posteriors, Parameter == "colorCost"),
                        adjust = 1, fill="#FF6666")+
           geom_density(aes(y=..density..), alpha=.5,
                        data=subset(posteriors, Parameter == "sizeCost"),
                        adjust = 1, fill="#FF6666")+
           geom_density(aes(y=..density..), alpha=.5,
                        data=subset(posteriors, Parameter == "nounCost"),
                        adjust = 1, fill="#FF6666")+
           theme_bw() +
           ylab("Density") +
           xlab("Cost") +
           xlim(0,2) +
           facet_grid(Parameter ~. , scales = 'free', labeller=labeller(Parameter = labels)) +
           theme(panel.border = element_rect(size=.2),
                 plot.margin = unit(x = c(0.05, 0.02, 0.05, 0.05), units = "in"),
                 panel.grid = element_line(size = .4),
                 axis.line        = element_line(colour = "black", size = .2),
                 axis.ticks       = element_line(colour = "black", size = .2),
                 axis.ticks.length = unit(2, "pt"),
                 axis.text.x        = element_text(size = 6 * scale_value, colour = "black",vjust=2),
                 axis.text.y        = element_text(size = 6 * scale_value, colour = "black",margin = margin(r = 0.3)),#,hjust=-5),
                 axis.title.x       = element_text(size = 6 * scale_value, margin = margin(t = .5)),
                 axis.title.y       = element_text(size = 6 * scale_value, margin = margin(r = .5)),
                 strip.text      = element_text(size = 6 * scale_value,margin=margin(t=4,r=4,b=4,l=4,unit="pt")))) 
}

graphNoisePosteriors_withNoun <- function(posteriors) {
  posteriors <- posteriors %>% filter(Parameter %in% c("colorNoiseVal","sizeNoiseVal","typeNoiseVal"))
  posteriors$Parameter <- relevel(posteriors$Parameter, ref = "colorNoiseVal")
  labels <- c(colorNoiseVal = "color", sizeNoiseVal = "size", typeNoiseVal = "type")
  scale_value=1
  return(ggplot(posteriors, aes(x = value)) +
           geom_histogram(aes(y=..density..),
                          data=subset(posteriors, Parameter == "colorNoiseVal"),
                          binwidth = .005, colour="black", fill="white") +
           geom_histogram(aes(y=..density..),
                          data =subset(posteriors, Parameter == "sizeNoiseVal" ),
                          binwidth = .005, colour="black", fill="white") +
           geom_histogram(aes(y=..density..),
                          data =subset(posteriors, Parameter == "typeNoiseVal" ),
                          binwidth = .005, colour="black", fill="white") +
           geom_density(aes(y=..density..), alpha=.5,
                        data=subset(posteriors, Parameter == "colorNoiseVal"),
                        adjust = 2, fill="#FF6666") +
           geom_density(aes(y=..density..), alpha=.5,
                        data=subset(posteriors, Parameter == "sizeNoiseVal"),
                        adjust = 2, fill="#FF6666") + 
           geom_density(aes(y=..density..), alpha=.5,
                        data=subset(posteriors, Parameter == "typeNoiseVal"),
                        adjust = 2, fill="#FF6666") + 
           theme_bw() +
           ylab("Density") +
           xlab("Semantic Value") +
           xlim(0,1) +
           facet_grid(Parameter ~. , scales = 'free', labeller=labeller(Parameter = labels)) +
           theme(panel.border = element_rect(size=.2),
                 plot.margin = unit(x = c(0.05, 0.02, 0.05, 0.05), units = "in"),
                 panel.grid = element_line(size = .4),
                 axis.line        = element_line(colour = "black", size = .2),
                 axis.ticks       = element_line(colour = "black", size = .2),
                 axis.ticks.length = unit(2, "pt"),
                 axis.text.x        = element_text(size = 6 * scale_value, colour = "black",vjust=2),
                 axis.text.y        = element_text(size = 6 * scale_value, colour = "black",margin = margin(r = 0.3)),#,hjust=-5),
                 axis.title.x       = element_text(size = 6 * scale_value, margin = margin(t = .5)),
                 axis.title.y       = element_text(size = 6 * scale_value, margin = margin(r = .5)),
                 strip.text      = element_text(size = 6 * scale_value,margin=margin(t=4,r=4,b=4,l=4,unit="pt")))) 
}

graphAlpha <- function(posteriors) {
  posteriors <- posteriors %>% filter(Parameter %in% c("alpha"))
  scale_value=1
  return(ggplot(posteriors, aes(x = value)) +
           geom_histogram(aes(y=..density..),
                          data=subset(posteriors, Parameter == "alpha"),
                          binwidth = .005, colour="black", fill="white") +
           geom_density(aes(y=..density..), alpha=.5,
                        data=subset(posteriors, Parameter == "alpha"),
                        adjust = 2, fill="#FF6666") +
           theme_bw() +
           ylab("Density") +
           xlab("Alpha") +
           xlim(0,max(posteriors$value)) +
           facet_grid(Parameter ~. , scales = 'free', labeller=labeller(Parameter = labels)) +
           theme(panel.border = element_rect(size=.2),
                 plot.margin = unit(x = c(0.05, 0.02, 0.05, 0.05), units = "in"),
                 panel.grid = element_line(size = .4),
                 axis.line        = element_line(colour = "black", size = .2),
                 axis.ticks       = element_line(colour = "black", size = .2),
                 axis.ticks.length = unit(2, "pt"),
                 axis.text.x        = element_text(size = 6 * scale_value, colour = "black",vjust=2),
                 axis.text.y        = element_text(size = 6 * scale_value, colour = "black",margin = margin(r = 0.3)),#,hjust=-5),
                 axis.title.x       = element_text(size = 6 * scale_value, margin = margin(t = .5)),
                 axis.title.y       = element_text(size = 6 * scale_value, margin = margin(r = .5)),
                 strip.text      = element_text(size = 6 * scale_value,margin=margin(t=4,r=4,b=4,l=4,unit="pt")))) 
}
