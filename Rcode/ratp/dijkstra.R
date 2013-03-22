## modified dijkstra algo, taking into account
# - transformation between geographic distance and time (GEO TO TIME)
# - stopping time when train at a stop (STOP TIME)
# - time to make a connection (CONNECTION TIME)
dijkstra <- function(edges, from, to, output,
                     GEOTOTIME=100,
                     STOPTIME=1,
                     CONNECTIONTIME=5) {
  # setup dijkstra algo
  edges[edges==0] <- Inf
  dists <- rep(Inf, ncol(edges))
  names(dists) <- colnames(edges)  
  previous <- rep(NA, ncol(edges))
  names(previous) <- colnames(edges)  
  
  dists[from] <- 0
  Q <- colnames(edges)  

  # typical loop to explore the graph
  while(length(Q)>0) {    
    u <- names(which.min(dists[Q]))[1]
    # when we reached destination, stop
    if(u==to)
      break()
    Q <- Q[Q!=u]
    
    v <- names(which(edges[u,]==1))
    # add cost whenever you stop
    add.cost <- STOPTIME
    if(u!=from)
      # also add cost whenever you hit a connection
      add.cost <- add.cost + sapply(v, function(s) {
        sum(strsplit(edges.l[u,s], "[|]")[[1]] %in% strsplit(edges.l[previous[u], u], "[|]")[[1]])==0
        })*CONNECTIONTIME
    previous[v] <- ifelse(dists[u] + edges.w[u,v]*GEOTOTIME + add.cost < dists[v], u, previous[v])
    dists[v] <- ifelse(dists[u] + edges.w[u,v]*GEOTOTIME + add.cost < dists[v], dists[u] + edges.w[u,v]*GEOTOTIME + add.cost, dists[v])
  }
  
  # various output: ever the distance (to find closest) or path
  if(output=="dist")
    return(as.numeric(dists[to]))
  if(output=="path") {
    u <- to
    path <- NULL
    while(!is.na(previous[u])) {
      path <- c(as.character(u), path)
      u <- previous[u]
    }
    return(c(as.character(from),path))
  }
    
}

# helper function to "decode" a station name
gsubv <- function(patterns, replacements, x) {
  for(i in 1:length(patterns))
    x <- gsub(patterns[i], replacements[i], x)
  return(x)
}