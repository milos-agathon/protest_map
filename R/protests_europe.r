#TIMELAPSE MAP OF EUROPEAN PROTESTS BETWEEN APRIL 2020 AND APRIL 2021 
#Milos Popovic 05/01/2021
#BEGIN REPLICATION
#install package archive from github
devtools::install_github("jimhester/archive")

# protests in Europe
library(tweenr, quietly = T)
library(ggplot2, quietly=T) 
library(plyr, quietly=T) 
library(rmapshaper, quietly=T)
library(dplyr, quietly=T)
library(rgdal, quietly=T)
library(animation, quietly=T)
library(data.table, quietly=T)
library(zoo, quietly=T)
library(archive, quietly=T)

set.seed(05012021)

#download and unrar free Europe shapefile
tf <- tempfile() ; td <- tempdir()
file.path <- "https://tapiquen-sig.jimdofree.com/app/download/5502525659/Europe.rar?t=1455822996p"
download.file(file.path , tf , mode = "wb")
archive(tf)

#load shapefile
cntry <- readOGR(getwd(),
        "Europe", 
         verbose = TRUE, 
         stringsAsFactors = FALSE) %>%
    subset(!NAME%in%c("Armenia", "Azerbaijan", "Georgia", "Turkey"))  #filter only European countries
c <- fortify(cntry)

#read the ACLED dataset obtained through API at https://developer.acleddata.com/
urlfile<-'https://raw.githubusercontent.com/milos-agathon/protest_map/main/data/eur_protests.csv'
dat <- read.csv(urlfile) %>%
       filter(country!="Cyprus") %>% #exclude Cyprus
     select(event_date, location, latitude, longitude) # we only need the location, date and coordinates

df <- dat # copy of the dataset
df$date=as.Date(df$event_date, format = "%m/%d/%Y") #date format
df$months <- as.yearmon(df$date)

#aggregate by location
d <- ddply(df, c("location", "months"), summarise, 
  events=length(location), 
  lat=max(latitude), 
  long=max(longitude))

# fill in missing months for every location
date_range <- as.yearmon(seq(as.Date(min(d$months)), 
        as.Date(max(d$months)), by="month"))
dat_expanded <- expand.grid(date_range, d$location)
colnames(dat_expanded) <- c("months", "location")
f <- merge(d, dat_expanded, by=c("location", "months"), all.y = T)

#prepare data for animation
x <- split(f, f$months)
tw <- tween_states(x, tweenlength= 2, statelength=3, ease=rep('cubic-in-out',3), nframes=70)
tf <- tw
tf$months <- as.yearmon(tf$months)

# each frame .2 secs, extend last to 4 secs
times <- c(rep(0.2, max(tf$.frame)-1), 4)

#prepare min/max values to assure a consistent legend
vmin <- min(tf$events, na.rm=T)
vmax <- max(tf$events, na.rm=T)

# plot
saveGIF({
for(i in 1:max(tf$.frame)) {
  g <-
    tf %>% filter(.frame==i) %>%
    ggplot(aes(x=long, y=lat)) +
geom_map(data = c, map = c,
             aes(map_id = id),
             color = "white", 
             size = 0.001, 
             fill = "#010D1F") +
geom_point(aes(size=events), 
  fill="#FFB115", 
  alpha = .45,
  col="#FFB115", 
  stroke=.35) +
    scale_size(breaks=c(1, 2, 5, 10, 20, 55),
      range = c(1, 8),
      limits = c(vmin,vmax),
      name="Protests")+
guides(size = guide_legend(override.aes = list(alpha = 1),
            direction = "vertical",
            title.position = 'top',
            title.hjust = 0.5,
            label.hjust = 0,
            nrow = 6,
            byrow = T,
      #labels = labs,
            # also the guide needs to be reversed
            reverse = F,
            label.position = "right"
          )
  ) +
  coord_map(xlim=c(-10.6600,40.07), ylim=c(34.5000,70.0500), 
    projection="lambert", 
    parameters=c(10.44,52.775)) +
  labs(y="", x="",
         title="Protests in Europe (4/2020-4/2021)",
         subtitle=paste0(as.character(as.factor(tail(tf %>% filter(.frame==i),1)$months))),
         caption="©2021 Milos Popovic https://milosp.info\nData: Armed Conflict Location & Event Data Project (ACLED);www.acleddata.com\nShape downloaded from\nhttp://tapiquen-sig.jimdofree.com. Carlos Efraín Porto Tapiquén.\nGeografía, SIG y Cartografía Digital. Valencia, Spain, 2020")+
theme_minimal() +
theme(text = element_text(family = "georg"),
plot.background = element_rect(fill = "#010D1F", color = NA), 
panel.background = element_rect(fill = "#010D1F", color = NA), 
legend.background = element_rect(fill = "#010D1F", color = NA),
legend.position = c(.115, .65),
panel.border = element_blank(),
panel.grid.minor = element_blank(),
panel.grid.major = element_line(color = "#010D1F", size = 0),
plot.title = element_text(size=40, color="white", hjust=0.5, vjust=-10),
plot.subtitle = element_text(size=48, color="#FF0899", hjust=0.27, vjust=-20, face="bold"),
plot.caption = element_text(size=18, color="white", hjust=.5, vjust=3),
legend.text = element_text(size=20, color="white"),
legend.title = element_text(size=22, color="white"),
strip.text = element_text(size=12),
plot.margin=unit(c(t=0, r=-4,b=0,l=-2), "cm"),
axis.title.x = element_blank(),
axis.title.y = element_blank(),
axis.ticks = element_blank(),
axis.text.x = element_blank(),
axis.text.y = element_blank())

print(paste(i,"out of", max(tf$.frame)))
ani.pause()
print(g)
;}

},movie.name="eur_protests.gif",
interval = times, 
ani.width = 768, 
ani.height = 1100,
other.opts = " -framerate 10  -i image%03d.png -s:v 768x1100 -c:v libx264 -profile:v high -crf 20  -pix_fmt yuv420p")
#END REPLICATION