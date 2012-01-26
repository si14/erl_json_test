library(ggplot2)
library(plyr)

data <- read.csv("results.csv", stringsAsFactors=FALSE)
data$Test <- factor(data$Test, levels=unique(data$Test))

transformer.lm <- function(df) {
  transform(df,
            LinearEnc=predict(lm(ResultEnc ~ TestSize, df)),
            LinearDec=predict(lm(ResultDec ~ TestSize, df)))
}
data.fitted <- ddply(data, .(Parser), transformer.lm)

transformer.reshape <- function(df) {
  rbind(data.frame(Type="Encode", Result=df$ResultEnc, Linear=df$LinearEnc),
        data.frame(Type="Decode", Result=df$ResultDec, Linear=df$LinearDec))
}
data.reshaped <- ddply(data.fitted, .(Parser, Test, TestSize),
                       transformer.reshape)

my.theme <- function(base_size = 12){
  modifyList(theme_gray(base_size, base_family="Ubuntu"),
             list(axis.ticks.length = unit(0.1,"line"),
                  plot.background=theme_rect(fill="#3F3F3F"),
                  legend.text=theme_text(colour="#DCDCCC"),
                  legend.title=theme_text(colour="#DCDCCC",
                    face="bold", hjust=0),
                  legend.background=theme_rect(colour=NA),
                  legend.key=theme_rect(fill="#4F4F4F", colour=NA),
                  axis.title.x=theme_text(colour="#DCDCCC",
                    vjust=0.5, face="bold", size=base_size*1.15),
                  axis.title.y=theme_text(colour="#DCDCCC",
                    vjust=0.5, face="bold", size=base_size*1.15, angle=90),
                  axis.text.x=theme_text(colour="#7F7F7F", size=base_size*0.7),
                  axis.text.y=theme_text(colour="#7F7F7F", size=base_size*0.7),
                  panel.background=theme_rect(fill="#4F4F4F", colour=NA),
                  panel.grid.major=theme_line(colour="#6F6F6F"),
                  panel.grid.minor=theme_line(colour="#5F5F5F"),
                  strip.background=theme_rect(fill="#6F6F6F", colour=NA),
                  strip.text.x=theme_text(colour="#DCDCCC", face="bold",
                    size=base_size*0.85)))
}

my.colours <- c("#7FC97F", "#BEAED4", "#FDC086", "#FFFF99", "#386CB0")

ggplot(data.reshaped, log="y",
       aes(x=Test, y=Result, group=Parser, color=Parser)) +
  geom_line(size=1.1) +
  geom_point(size=2) +
  geom_line(aes(x=Test, y=Linear, group=Parser, color=Parser,
                linetype=2, alpha=".4")) +
  labs(x="Test size", y="Time") +
  facet_grid(.~Type) +
  my.theme() +
  scale_y_continuous(formatter=function(x) paste(x / 1000, "s", sep="")) +
  scale_colour_manual(values=my.colours)
