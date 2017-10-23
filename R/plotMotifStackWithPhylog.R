###############################################################################
######## phylog style stack
######## 
###############################################################################

plotMotifStackWithPhylog <- function(phylog, pfms=NULL,
                                     f.phylog = 0.3, f.logo = NULL, cleaves =1, cnodes =0,
                                     labels.leaves = names(phylog$leaves), clabel.leaves=1,
                                     labels.nodes = names(phylog$nodes), clabel.nodes = 0, 
                                     font="Helvetica-Bold", ic.scale=TRUE, fontsize=12
){
  if(!inherits(phylog, "phylog")) stop("phylog must be an object of phylog")
  n<-length(pfms)
  lapply(pfms,function(.ele){
    if(inherits(.ele, c("pfm", "psam"))) stop("pfms must be a list of class pfm or psam")
  })
  leaves.number <- length(phylog$leaves)
  leaves.names<- names(phylog$leaves)
  nodes.number <- length(phylog$nodes)
  nodes.names <- names(phylog$nodes)
  if (length(labels.leaves) != leaves.number) labels.leaves <- names(phylog$leaves)
  if (length(labels.nodes) != nodes.number) labels.nodes <- names(phylog$nodes)
  leaves.car <- gsub("[_]"," ",labels.leaves)
  nodes.car <- gsub("[_]"," ",labels.nodes)
  opar <- par(mar = c(0, 0, 0, 0))
  on.exit(par(opar))
  
  if (f.phylog < 0.05) f.phylog <- 0.05 
  if (f.phylog > 0.75) f.phylog <- 0.75
  
  maxx <- max(phylog$droot)
  plot.default(0, 0, type = "n", xlab = "", ylab = "", xaxt = "n", 
               yaxt = "n", xlim = c(-maxx*0.15, maxx/f.phylog), ylim = c(-0, 1), xaxs = "i", 
               yaxs = "i", frame.plot = FALSE)
  
  x.leaves <- phylog$droot[leaves.names]
  x.nodes <- phylog$droot[nodes.names]
  
  y <- (leaves.number:1)/(leaves.number + 1)
  names(y) <- leaves.names
  
  xcar <- maxx*1.05
  xx <- c(x.leaves, x.nodes)
  
  assign("tmp_motifStack_symbolsCache", list(), pos=".GlobalEnv")
  vpheight <- y[length(y)] * .95
  if(is.null(f.logo)){
    f.logo <- max(unlist(lapply(leaves.names, strwidth, units="figure", cex=clabel.leaves)))
    if(!is.null(pfms)){
      pfms.width <- max(sapply(pfms, function(x) ncol(x@mat)))
      pfms.width <- strwidth(paste(rep("M", pfms.width), collapse=""), units="figure")
      f.logo <- max(f.logo, pfms.width)
    }
    if(clabel.leaves>0) f.logo <- f.phylog+f.logo+.01
    else f.logo <- f.phylog+.05
  }else{
    if (f.logo > 0.85) f.logo <- 0.85
    if (f.logo < f.phylog) f.logo <- f.phylog+.05 
  }
  for (i in 1:leaves.number) {
    if(clabel.leaves>0) 
      text(xcar, y[i], leaves.car[i], adj = 0, cex = par("cex") * 
             clabel.leaves)
    segments(xcar, y[i], xx[i], y[i], col = grey(0.7))
    if(!is.null(pfms)){
      vpwidth <- vpheight * ncol(pfms[[i]]@mat) / 2
      pushViewport(viewport(x=f.logo, y=y[i], width=vpwidth, height=vpheight, just=c(0, .5)))
      if(!is.null(pfms[[i]])) 
        if(class(pfms[[i]])!="psam"){
          plotMotifLogoA(pfms[[i]], font=font, ic.scale=ic.scale, fontsize=fontsize)
        }else{
          plotAffinityLogo(pfms[[i]], font=font, fontsize=fontsize, newpage=FALSE)
        }
      popViewport()
    }
  }
  rm(list="tmp_motifStack_symbolsCache", pos=".GlobalEnv")
  
  yleaves <- y[1:leaves.number]
  xleaves <- xx[1:leaves.number]
  if (cleaves > 0) {
    for (i in 1:leaves.number) {
      points(xx[i], y[i], pch = 21, bg=1, cex = par("cex") * cleaves)
    }
  }
  yn <- rep(0, nodes.number)
  names(yn) <- nodes.names
  y <- c(y, yn)
  for (i in 1:length(phylog$parts)) {
    w <- phylog$parts[[i]]
    but <- names(phylog$parts)[i]
    y[but] <- mean(y[w])
    b <- range(y[w])
    segments(xx[but], b[1], xx[but], b[2])
    x1 <- xx[w]
    y1 <- y[w]
    x2 <- rep(xx[but], length(w))
    segments(x1, y1, x2, y1)
  }
  if (cnodes > 0) {
    for (i in nodes.names) {
      points(xx[i], y[i], pch = 21, bg="white", cex = cnodes)
    }
  }
  if (clabel.nodes > 0) {
    scatterutil.eti(xx[names(x.nodes)], y[names(x.nodes)], nodes.car, 
                    clabel.nodes)
  }
  if (cleaves > 0) points(xleaves, yleaves, pch = 21, bg=1, cex = par("cex") * cleaves)
  return(invisible())
}
