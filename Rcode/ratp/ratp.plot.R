require(ggplot2)
require(reshape)

## plot functions for ratp network and metro meeting point

cols <- c(rgb(222, 235, 247, max=255),
          rgb(158, 202, 225, max=255),
          rgb(49, 130, 189, max=255))

stations <- with(subset(arret_positions, ID %in% rownames(edges.l)), data.frame(ID=ID, X=X, Y=Y))

# build data frames for lines
lignes <- melt(edges.l)
lignes <- subset(lignes, value!=0)
trajets <- do.call(rbind, lapply(1:nrow(lignes), function(r) {
  data.frame(x=subset(arret_positions, ID==lignes[r,1])$X,
             y=subset(arret_positions, ID==lignes[r,1])$Y,
             xend=subset(arret_positions, ID==lignes[r,2])$X,
             yend=subset(arret_positions, ID==lignes[r,2])$Y,
             col=lignes[r,3])
}))
trajets$col <- u.lignes[as.numeric(sapply(strsplit(as.character(trajets$col), "[|]"), head,1))]

# build the base plot, with lines, unless faded where lines are all the same color
plotBase <- function(faded=F) {
  ggplot(data=stations) + 
    geom_segment(data=trajets, mapping=aes(x=x, xend=xend, y=y, yend=yend, col=col), alpha=ifelse(faded, 0.3, 1), size=ifelse(faded, 0.5, 1)) +
    geom_point(aes(x=X, y=Y)) +    
    theme_bw() + scale_colour_manual(name="Ligne", values=rainbow(length(u.lignes)), guide="none") +
    scale_x_continuous(name="", labels=NULL, breaks=NULL) +
    scale_y_continuous(name="", labels=NULL, breaks=NULL) +
    coord_fixed()
}

# show the path between friends and the source
plotPath <- function(base, friends) {  
  # find the target
  target <- findTarget(friends, "minmax")
  # build the dataframe for the path between friends and target
  df <- do.call(rbind, lapply(friends, function(f) {
    p <- dijkstra(edges, from=f, to=target, output="path")
    do.call(rbind, lapply(2:length(p), function(i)
      data.frame(x=subset(arret_positions, ID==p[i-1])$X,
                 xend=subset(arret_positions, ID==p[i])$X,
                 y=subset(arret_positions, ID==p[i-1])$Y,
                 yend=subset(arret_positions, ID==p[i])$Y)
    ))
  }))
  # add geoms on top of base
  base + geom_segment(data=df, mapping=aes(x=x, xend=xend, y=y, yend=yend), col=cols[1], size=2) +
    geom_point(data=subset(stations, ID %in% friends), mapping=aes(x=X, y=Y), col=cols[3], size=5) +
    geom_point(data=subset(stations, ID %in% target), mapping=aes(x=X, y=Y), col=cols[2], size=5)
    
}
