## run manually the code here to recalculate everything, otherwise the Rdata is loaded
if(F) {
  # load data
  arret_ligne <- read.csv("ratp_arret_ligne.csv", header=F, sep="#",
                          col.names=c("ID","Ligne","Type"),
                          stringsAsFactors=F)
  
  arret_positions <- read.csv("ratp_arret_graphique.csv", header=F, sep="#",
                              col.names=c("ID","X","Y","Nom","Ville","Type"),
                              stringsAsFactors=F)

  # simple transformation from ID to station name and vice versa
  getStationFromID <- function(stations) {
  sapply(stations, function(s) subset(arret_positions, ID==s)$Nom)
}
  getIDFromStation <- function(stations) {
    sapply(stations, function(s) subset(subset(arret_positions, Type=="metro"), 
                                        gsubv(c("â","'","è","ô","é"), c("a", " ", "e", "o","e"), Nom)==gsubv(c("â","'","è","ô","é"), c("a", " ", "e", "o","e"), s))$ID)
  }

  # keep lines from metro / u stands for unique
  u.lignes <- sort(unique(as.character(subset(arret_ligne,Type=="metro")$Ligne)))
  # remove Montmartre & Orlyval => not connex
  u.lignes <- u.lignes[!(u.lignes %in% c("FUN (Gare haute/Gare basse)","ORV (Orly-Sud/Antony)"))]
  u.stations <- unique(subset(arret_ligne,Ligne%in%u.lignes)$ID)
  u.stations.name <- as.character(getStationFromID(u.stations))
  # dealing here with encoding which can cause problem
  u.stations.name.enc <- gsubv(c("â","'","è","ô","é"), c("a", " ", "e", "o","e"), u.stations.name)
  
  # make simple graph to create the network
  getEdges <- function() {
    vertices <- u.stations
    edges <- matrix(0,nrow=length(vertices),ncol=length(vertices),
                    dimnames=list(vertices, vertices))
    # roll on lines to make connections
    for(l in u.lignes) {
      # check all stations and retrieve coordinates
      stations <- subset(arret_ligne, Ligne==l)$ID
      P <- with(subset(arret_positions,ID %in% stations), cbind(ID,X,Y))  
      # roll on stations to find next and previous
      for(s in stations) {
        sID <- which(P[,1]==s)
        sRanks <- rank(rowSums((P[-sID,-1] - matrix(P[sID,-1],ncol=2,nrow=(nrow(P)-1),byrow=T))^2))
        closest <- P[-sID,1][which(sRanks==1)]
        edges[as.character(s),as.character(closest)] <- edges[as.character(closest),as.character(s)] <- 1
        secondClosest <- P[-sID,1][which(sRanks==2)]
        # check if second is closer to s than to first => case of terminus
        if(sum(((P[P[,1]==s,-1]-P[P[,1]==secondClosest,-1]))^2) <
            sum(((P[P[,1]==closest,-1]-P[P[,1]==secondClosest,-1]))^2))
          edges[as.character(s),as.character(secondClosest)] <- edges[as.character(secondClosest),as.character(s)] <- 1
      }
    }  
    return(edges)
  }
  edges <- getEdges()
  
  # manually adjust
  manuallyAdjustEdges <- function(edges) {
    connecRemove <- function(edges, from, to) {
      edges[as.character(from), as.character(to)] <- edges[as.character(to), as.character(from)] <- 0
      return(edges)
    }
    connecAdd <- function(edges, from, to, l) {
      edges[as.character(from), as.character(to)] <- edges[as.character(to), as.character(from)] <- 1
      return(edges)
    }
    # 10
    edges <- connecRemove(edges, from=1717, to=1837)
    edges <- connecRemove(edges, from=1717, to=1836)
    edges <- connecRemove(edges, from=1950, to=1836)
    edges <- connecRemove(edges, from=1950, to=1911)
    edges <- connecRemove(edges, from=1746, to=1911)
    edges <- connecAdd(edges, from=2018, to=1837, l=1)
    edges <- connecAdd(edges, from=1950, to=1837, l=1)
    edges <- connecAdd(edges, from=1717, to=1836, l=1)
    edges <- connecAdd(edges, from=1911, to=1836, l=1)
    edges <- connecAdd(edges, from=1950, to=1746, l=1)
    edges <- connecAdd(edges, from=1911, to=1862, l=1)
    # 12 (saint georges + montparnasse)
    edges <- connecRemove(edges, from=1638, to=1686)
    edges <- connecAdd(edges, from=1638, to=1767, l=3)
    # 14 (chatelet/Gare de lyon + bercy)
    edges <- connecRemove(edges, from=51020,to=2005)
    edges <- connecAdd(edges, from=51020,to=50055, l=5)
    edges <- connecAdd(edges, from=1964,to=1839, l=5)
    # 3 (république/parmentier)
    edges <- connecAdd(edges, from=1679, to=1779, l=9)
    # 4 (montparnasse/vavin)
    edges <- connecRemove(edges, from=1697, to=1646)
    edges <- connecAdd(edges, from=1751, to=1646, l=10)
    #   5 (gare du nord/stalingrad)
    edges <- connecRemove(edges, from=1627, to=1841)
    edges <- connecAdd(edges, from=1842, to=1627, l=11)
    # 7b (danube/place des fetes)
    edges <- connecRemove(edges, from=1900, to=1792)
    edges <- connecAdd(edges, from=1900, to=1737, l=13)
    edges <- connecAdd(edges, from=1792, to=2016, l=13)
    # 7 (sully-morland + embranchement)
    edges <- connecRemove(edges, from=1711, to=1866)
    edges <- connecAdd(edges, from=1630, to=1866, l=14)
    edges <- connecRemove(edges, from=1718, to=1793)
    edges <- connecAdd(edges, from=1820, to=1793, l=14)
    # 8 (porte dorée/porte charenton)
    edges <- connecRemove(edges, from=1723, to=1835)
    edges <- connecRemove(edges, from=1803, to=1715)
    edges <- connecAdd(edges, from=1803, to=1723, l=15)
    edges <- connecAdd(edges, from=1723, to=1715, l=15)
    return(edges)
  }
  edges <- manuallyAdjustEdges(edges)
  
  # get lines
  getEdgesLines <- function() {
    edges.l <- matrix(0,nrow=length(vertices),ncol=length(vertices),
                      dimnames=list(vertices, vertices))
    for(i in colnames(edges.l))
      for(j in names(which(edges[i,]!=0)))      
        edges.l[i,j] <- paste(which(u.lignes %in% names(which(table(as.character(subset(arret_ligne, ID %in% c(i,j))$Ligne))==2))), collapse="|")
    return(edges.l)
  }
  edges.l <- getEdgesLines()
  
  # manually adjust lines
  manuallyAdjustLines <- function(edges.l) {
    # adjust
    edges.l["1836","1837"] <- edges.l["1837","1836"] <- "16" # 10 Michel-Ange Auteuil et Michel-Ange Molitor
    edges.l["1781","1751"] <- edges.l["1751","1781"] <- "12" # 12 Pasteur et Montparnasse
    edges.l["1964","1839"] <- edges.l["1839","1964"] <- "5" # 1 Chatelet et Gare de Lyon
    edges.l["1679","1988"] <- edges.l["1988","1679"] <- "2" # 3 Arts et Métiers et République
    # check if everything ok
    for(l in 1:length(u.lignes)) {
      sapply(colnames(edges.l), function(s) {
        if(sum(do.call(c, strsplit(edges.l[s,], "[|]"))==as.character(l))>2) {
          if(!(s %in% c('1862', '2018', '1872', '2016', '1820'))) # 10, 13 7b 7
            stop("Station ", getStationFromID(s), " (", s, ") has more than 2 connections on ", u.lignes[l], " (", l, ")")
        }
      })
    }
    return(edges.l)
  }
  edges.l <- manuallyAdjustLines(edges.l)
  
  # make geographical distances as edges
  getGeoDist <- function() {
    edges.w <- matrix(0,nrow=length(vertices),ncol=length(vertices),
                      dimnames=list(vertices, vertices))
    for(i in colnames(edges))
      for(j in names(which(edges[i,]!=0)))
        edges.w[i, j] <- with(subset(arret_positions, ID %in% c(i,j)), sqrt(diff(X)*diff(X)+diff(Y)*diff(Y)))
    return(edges.w)  
  }
  edges.w <- getGeoDist()
  
  # compute distance matrix / this takes time
  require(multicore)
  message(Sys.time(), ' > starting')  
  allDists <- do.call(rbind, mclapply(u.stations, function(s1) {
    do.call(rbind, lapply(u.stations, function(s2) {
      data.frame(s1=as.character(s1), 
                 s2=as.character(s2), 
                 d=dijkstra(edges, as.character(s1), as.character(s2), output="dist",
                            GEOTOTIME=100, CONNECTIONTIME=5, STOPTIME=1),
                 stringsAsFactors=F)
      }))
    }))
  distmat <- as.matrix(cast(allDists, s1 ~ s2, value="d"))
  message(Sys.time(), ' > ending')  
  
  # find a target based on friends
  findTarget <- function(friends, method) {
    if(method=="centroid") {
      target <- names(which.min(sapply(colnames(distmat), function(s) {
        sum((distmat[friends,s]-kmeans(as.dist(distmat[friends, friends]),
                                       centers=1)$centers)^2)
      })))      
    }
    if(method=="minmax") {
      target <- names(which.min(apply(distmat[,friends], 1, max)))
    }
    return(target)
  }
  
  # saving image
  save.image("ratp.Rdata")
  } else {
  load("ratp.Rdata")
}
