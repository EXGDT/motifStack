#' plot sequence logo stacks with a radial phylogenic tree and multiple color
#' rings
#' 
#' plot sequence logo stacks with a radial phylogenic tree and multiple color
#' rings. The difference from plotMotifStackWithRadialPhylog is that it has
#' more color setting and one more group of pfms.
#' 
#' 
#' @param phylog an object of class phylog
#' @param pfms a list of objects of class pfm
#' @param pfms2 a list of objects of class pfm
#' @param R radius of canvas
#' @param r.tree half width of the tree
#' @param col.tree.bg a vector of colors for tree background
#' @param col.tree.bg.alpha a alpha value [0, 1] of colors for tree background
#' @param cnodes a character size for plotting the points that represent the
#' nodes, used with par("cex")*cnodes. If zero, no points are drawn
#' @param labels.nodes a vector of strings of characters for the nodes labels
#' @param clabel.nodes a character size for the nodes labels, used with
#' par("cex")*clabel.nodes. If zero, no nodes labels are drawn
#' @param r.leaves width of the leaves
#' @param cleaves a character size for plotting the points that represent the
#' leaves, used with par("cex")*cleaves. If zero, no points are drawn
#' @param labels.leaves a vector of strings of characters for the leaves labels
#' @param clabel.leaves a character size for the leaves labels, used with
#' par("cex")*clavel.leaves
#' @param col.leaves a vector of colors for leaves labels
#' @param col.leaves.bg a vector of colors for background of leaves labels
#' @param col.leaves.bg.alpha alpha value [0, 1] for the colors of backgroud of
#' leaves labels
#' @param r.pfms width of the pfms
#' @param r.pfms2 width of the pfms2
#' @param r.rings a vector of width of color rings
#' @param col.rings a list of color rings
#' @param col.inner.label.circle a vector of colors for inner cirlce of pfms
#' @param inner.label.circle.width width for inner circle of pfms
#' @param col.outer.label.circle a vector of colors for outer circle of pfms
#' @param outer.label.circle.width width for outer circle of pfms
#' @param draw.box if TRUE draws a box around the current plot with the
#' function box()
#' @param clockwise a logical value indicating if slices are drawn clockwise or
#' counter clockwise
#' @param init.angle number specifying the starting angle (in degrees) for the
#' slices. Defaults to 0 (i.e., `3 o'clock`) unless clockwise is true where
#' init.angle defaults to 90 (degrees), (i.e., `12 o'clock`)
#' @param angle number specifying the angle (in degrees) for phylogenic tree.
#' Defaults 360
#' @param pfmNameSpliter spliter when name of pfms/pfms2 contain multiple node
#' of labels.leaves
#' @param rcpostfix the postfix for reverse complements
#' @param motifScale the scale of logo size
#' @param ic.scale logical. If TRUE, the height of each column is proportional
#' to its information content. Otherwise, all columns have the same height.
#' @param plotIndex logical. If TRUE, will plot index number in the motifLogo
#' which can help user to describe the motifLogo
#' @param IndexCol The color of the index number when plotIndex is TRUE.
#' @param IndexCex The cex of the index number when plotIndex is TRUE.
#' @param groupDistance show groupDistance on the draw
#' @param groupDistanceLineCol groupDistance line color, default: red
#' @param plotAxis logical. If TRUE, will plot distance axis.
#' @return none
#' @author Jianhong Ou
#' @seealso \code{\link{plotMotifStackWithRadialPhylog}}
#' @keywords misc
#' @export
#' @importFrom graphics par plot.default strwidth polygon text segments
#' points lines symbols box
#' @importFrom grDevices grey dev.size
#' @importFrom stats median
#' @importFrom grid pushViewport viewport popViewport grid.text gpar grid.xaxis
#' @examples
#' 
#' if(interactive() || Sys.getenv("USER")=="jianhongou"){
#'     library("MotifDb")
#'     matrix.fly <- query(MotifDb, "Dmelanogaster")
#'     motifs <- as.list(matrix.fly)
#'     motifs <- motifs[grepl("Dmelanogaster-FlyFactorSurvey-", 
#'                             names(motifs), fixed=TRUE)]
#'     names(motifs) <- gsub("Dmelanogaster_FlyFactorSurvey_", "", 
#'                 gsub("_FBgn[0-9]+$", "", 
#'                   gsub("[^a-zA-Z0-9]","_", 
#'                      gsub("(_[0-9]+)+$", "", names(motifs)))))
#'     motifs <- motifs[unique(names(motifs))]
#'     pfms <- sample(motifs, 50)
#'     hc <- clusterMotifs(pfms)
#'     library(ade4)
#'     phylog <- ade4::hclust2phylog(hc)
#'     leaves <- names(phylog$leaves)
#'     pfms <- pfms[leaves]
#'     pfms <- mapply(pfms, names(pfms), FUN=function(.ele, .name){
#'                  new("pfm",mat=.ele, name=.name)})
#'     pfms <- DNAmotifAlignment(pfms, minimalConsensus=3)
#'     library(RColorBrewer)
#'     color <- brewer.pal(12, "Set3")
#'     motifCircos(phylog, pfms, cleaves = 0.5, clabel.leaves = 0.7, 
#'                      col.tree.bg=rep(color, each=5), 
#'                      col.leaves=rep(color, each=5),
#'                       r.rings=c(0.02, 0.03, 0.04), 
#'                       col.rings=list(sample(colors(), 50), 
#'                                      sample(colors(), 50), 
#'                                      sample(colors(), 50)))
#'   }
#' 
motifCircos <- function (phylog, pfms=NULL, pfms2=NULL, R=2.5,
                         r.tree=1, col.tree.bg=NULL, col.tree.bg.alpha=1,
                         cnodes=0, labels.nodes=names(phylog$nodes), 
                         clabel.nodes=0,
                         r.leaves=NA,
                         cleaves=1, labels.leaves=names(phylog$leaves), 
                         clabel.leaves=1,
                         col.leaves=rep("black", length(labels.leaves)),
                         col.leaves.bg=NULL, col.leaves.bg.alpha=1,
                         r.pfms=NA, r.pfms2=NA,
                         r.rings=0, col.rings=list(),
                         col.inner.label.circle=NULL,
                         inner.label.circle.width=0.02,
                         col.outer.label.circle=NULL, 
                         outer.label.circle.width=0.02,
                         draw.box=FALSE,
                         clockwise =FALSE, init.angle=if(clockwise) 90 else 0,
                         angle=360, pfmNameSpliter=";", rcpostfix="(RC)", 
                         motifScale=c("linear","logarithmic","none"),
                         ic.scale=TRUE,
                         plotIndex=FALSE, IndexCol="black", IndexCex=.8,
                         groupDistance=NA, groupDistanceLineCol="red", 
                         plotAxis=FALSE)
{#TODO: change all graphics function to grid function
    if (!inherits(phylog, "phylog"))
        stop("Non convenient data")
    leaves.number <- length(phylog$leaves)
    checkLength <- function(tobechecked){
        !((length(tobechecked)>=leaves.number)||is.null(tobechecked))
    }
    checkNA <- function(tobechecked){
        if(is.null(tobechecked)) return(FALSE)
        return(any(is.na(tobechecked)))
    }
    for(tobechecked in c("col.leaves", "col.leaves.bg", "col.tree.bg", 
                         "col.inner.label.circle", "col.outer.label.circle")){
        if(checkLength(eval(as.symbol(tobechecked)))) {
            stop(paste("the length of", tobechecked, 
                       "should be same as the length of leaves"))
            }
        if(checkNA(eval(as.symbol(tobechecked)))) {
            stop(paste("contain NA in", tobechecked))
            }
    }
    if(length(r.rings)>length(col.rings)){
        if(r.rings!=0 & length(r.rings)!=1){
            stop("length of col.rings must be same as r.rings you input")
        }
    }
    if(length(col.rings)>0){
        if(!is(col.rings, "list")) stop("col.rings must be a object of list")
        for(i in 1:length(col.rings)){
            if(checkLength(col.rings[[i]])) {
                stop(paste("the length of col.rings[[", i,
                           "]]should be same as the length of leaves"))
            }
            if(checkNA(col.rings[[i]])) {
                stop(paste("contain NA in col.rings[[", i, "]]"))
            }
        }
    }
    motifScale <- match.arg(motifScale)
    leaves.names <- names(phylog$leaves)
    nodes.number <- length(phylog$nodes)
    nodes.names <- names(phylog$nodes)
    if (length(labels.leaves) != leaves.number)
        labels.leaves <- names(phylog$leaves)
    if (length(labels.nodes) != nodes.number)
        labels.nodes <- names(phylog$nodes)
    if (r.tree < 0)
        stop("'r.tree': non convenient value")
    leaves.car <- gsub("[_]", " ", labels.leaves)
    nodes.car <- gsub("[_]", " ", labels.nodes)
    opar <- par(mar = par("mar"), srt = par("srt"))
    on.exit(par(opar))
    par(mar = c(0.1, 0.1, 0.1, 0.1), mfrow=c(1,1))
    dis <- phylog$droot
    max_Dis <- max(dis)
    axis_pos <- r.tree
    if(!is.na(groupDistance)){
        groupDistance <- (max_Dis - groupDistance) * r.tree / max_Dis
    }
    dis <- dis/max_Dis
    dis <- dis * r.tree
    dist.leaves <- dis[leaves.names]
    dist.nodes <- dis[nodes.names]
    asp <- c(1, 1)
    pin <- dev.size("in")
    if (pin[1L] > pin[2L]){
        asp <- c(pin[2L]/pin[1L], 1)
    }else{
        asp <- c(1, pin[1L]/pin[2L])
    }
    plot.default(0, 0, type = "n", asp=1, xlab = "", ylab = "",
                 xaxt = "n", yaxt = "n", xlim = c(-1*R, R), ylim = c(-1*R, R),
                 xaxs = "i", yaxs = "i", frame.plot = FALSE)
    r.rayon <- r.tree/(nodes.number - 1)
    twopi <- if (clockwise) -2 * pi else 2 * pi
    alpha <-
        twopi * angle * (1:leaves.number)/leaves.number/360 + 
        init.angle * pi/180
    names(alpha) <- leaves.names
    x <- dist.leaves * cos(alpha)
    y <- dist.leaves * sin(alpha)
    xcar <- (r.tree + r.rayon) * cos(alpha)
    ycar <- (r.tree + r.rayon) * sin(alpha)
    
    r.rings.tot <- sum(r.rings)
    if(!inherits(r.leaves, c("numeric", "integer"))) 
        r.leaves <- max(unlist(lapply(leaves.names, strwidth, units="user",
                                      cex=clabel.leaves)))
    ##for logos position
    w.pfms <- r.tree + r.rayon + r.leaves + r.rings.tot + 
        inner.label.circle.width
    twoR <- 2*R
    beta <- alpha * 180 / pi
    if(!is.null(pfms)){
        vpheight <- 2 * pi * angle * w.pfms / 360 / leaves.number / twoR
        vpheight <- vpheight * asp[2L]
        xm <- w.pfms * cos(alpha) * asp[1L] / twoR + 0.5
        ym <- w.pfms * sin(alpha) * asp[2L] / twoR + 0.5
        if(!inherits(r.pfms, c("numeric", "integer"))){
            r.pfms <- 0
            pfmNamesLen <- sapply(pfms, function(.ele) 
                length(strsplit(.ele@name, pfmNameSpliter)[[1]]))
            if(motifScale=="linear"){
                vph <- R*vpheight*pfmNamesLen
            }else {
              if(motifScale=="logarithmic"){
                vph <- R*vpheight*(1+log2(pfmNamesLen+0.0001))
              }else{
                vph <- rep(R*vpheight, length(pfmNamesLen))
              }
            }
            r.pfms <- 
                max(mapply(function(.ele, f) ncol(.ele@mat)*f, pfms, vph))
        }
    }
    if(!inherits(r.pfms, c("numeric", "integer"))) r.pfms <- 0
    
    w.pfms2 <- w.pfms + r.pfms + outer.label.circle.width
    if(!is.null(pfms2)){
        vpheight2 <- 2 * pi * angle * w.pfms2 / 360 / leaves.number / twoR
        vpheight2 <- vpheight2 * asp[2L]
        xm2 <- w.pfms2 * cos(alpha) * asp[1L] / twoR + 0.5
        ym2 <- w.pfms2 * sin(alpha) * asp[2L] / twoR + 0.5
        if(!inherits(r.pfms2, c("numeric", "integer"))){
            r.pfms2 <- 0
            pfmNamesLen <- sapply(pfms2, function(.ele) 
                length(strsplit(.ele@name, pfmNameSpliter)[[1]]))
            if(motifScale=="linear"){
              vph <- R*vpheight2*pfmNamesLen
            }else{
              if(motifScale=="logarithmic"){
                vph <- R*vpheight2*(1+log2(pfmNamesLen+0.0001))
              }else{
                vph <- rep(R*vpheight2, length(pfmNamesLen))
              }
            } 
            r.pfms2 <- 
                max(mapply(function(.ele, f) ncol(.ele@mat)*f, pfms2, vph))
        }
    }
    if(!inherits(r.pfms2, c("numeric", "integer"))) r.pfms2 <- 0
    
    ratio <- R/(w.pfms2+r.pfms2)
    
    if(ratio < 1){
        x <- x * ratio
        y <- y * ratio
        xcar <- xcar * ratio
        ycar <- ycar * ratio
        dis <- dis * ratio
        groupDistance <- groupDistance * ratio
        if(!is.null(pfms)) {
            xm <- (xm-.5) * ratio + .5
            ym <- (ym-.5) * ratio + .5
            vpheight <- vpheight * ratio
        }
        if(!is.null(pfms2)) {
            xm2 <- (xm2-.5) * ratio + .5
            ym2 <- (ym2-.5) * ratio + .5
            vpheight2 <- vpheight2 * ratio
        }
        axis_pos <- axis_pos * ratio
        r.rings <- r.rings * ratio
        r.tree <- r.tree * ratio
        r.rayon <- r.rayon * ratio
        r.leaves <- r.leaves * ratio
        inner.label.circle.width <- inner.label.circle.width * ratio
        outer.label.circle.width <- outer.label.circle.width * ratio
        w.pfms <- w.pfms * ratio
        w.pfms2 <- w.pfms2 * ratio
        cleaves <- cleaves * ratio
        clabel.leaves <- clabel.leaves * ratio
        cnodes <- cnodes * ratio
        clabel.nodes <- clabel.nodes * ratio
        dist.leaves <- dist.leaves * ratio
        IndexCex <- IndexCex * ratio
    }else{
        ratio <- 1
    }
    ##for plot background
    gamma <- 
        twopi * angle * ((1:(leaves.number+1))-0.5)/leaves.number/360 +
        init.angle * pi/180
    n <- max(2, floor(200*360/leaves.number))
    plotBgArc <- function(r,bgcol,inr=0){
        t2xy <- function(rx, t, rx2=0) list(x=c(rx*cos(t), rx2*cos(rev(t))),
                                    y=c(rx*sin(t), rx2*sin(rev(t))))
        oldcol <- bgcol[1]
        start <- 1
        icnt <- 1
        for(i in 1:leaves.number){
            oldcol <- bgcol[i]
            if(i==leaves.number || bgcol[i+1]!=oldcol){
                P <- t2xy(r, seq.int(gamma[start], gamma[start+icnt], 
                                     length.out=n*icnt), inr)
                polygon(P$x, P$y, border=bgcol[i], col=bgcol[i])
                start <- i+1
                icnt <- 1
            } else {
                icnt <- icnt + 1
            }
        }
    }
    if(!is.null(col.outer.label.circle)) ##plot outer.label.circle
        plotBgArc(w.pfms2, col.outer.label.circle, 
                  w.pfms2-outer.label.circle.width)
    if(!is.null(col.inner.label.circle)) #plot inner.label.circle
        plotBgArc(w.pfms, col.inner.label.circle, 
                  w.pfms-inner.label.circle.width)
    if(!is.null(col.tree.bg)) col.tree.bg <- 
        highlightCol(col.tree.bg, col.tree.bg.alpha)
    if(!is.null(col.leaves.bg)) col.leaves.bg <-
        highlightCol(col.leaves.bg, col.leaves.bg.alpha)
    if(!is.null(col.tree.bg)) ##plot center bg
        plotBgArc(ifelse(mean(dist.leaves)/max(dis) > .9,
                         mean(dist.leaves), max(dis)-r.rayon), 
                  col.tree.bg, 0)
    if(!is.null(col.leaves.bg)) ##plot leaves bg
        plotBgArc(r.tree + r.rayon + r.leaves, col.leaves.bg, r.tree + r.rayon)
    if(r.rings.tot>0){
        r.rings.diff <- c(0, 0, cumsum(r.rings[-length(r.rings)]))
        r.rings <- r.tree + r.rayon + r.leaves + c(0, r.rings) + r.rings.diff
        for(i in 2:length(r.rings)){
            plotBgArc(r.rings[i], col.rings[[i-1]], r.rings[i-1])
        }
    }
    #axis(1, pos=0)
    #axis(2, pos=0)
    if (clabel.leaves > 0) {
        for(i in 1:leaves.number) {
            par(srt = alpha[i] * 180/pi)
            text(xcar[i], ycar[i], leaves.car[i], adj = 0,
                 col=col.leaves[i], cex = par("cex") *
                     clabel.leaves)
            segments(xcar[i], ycar[i], x[i], y[i], col = grey(0.7))
        }
        
        assign("tmp_motifStack_symbolsCache", list(), envir=.globals)
        for(metaChar in c("\\","$","*","+",".","?",
                          "[","]","^","{","}","|","(",")"))
        {
            rcpostfix <- gsub(metaChar,paste("\\",metaChar,sep=""),
                              rcpostfix,fixed=TRUE)
        }
        drawPFMcir <- function(pfms, xm, ym, vpheight, .plotIndex){
            ##extract names
            pfmNames <- lapply(pfms, function(.ele) .ele@name)
            for(i in 1:length(pfmNames)){
                pfmname <- unlist(strsplit(pfmNames[[i]], pfmNameSpliter))
                pfmname <- gsub(paste(rcpostfix,"$",sep=""),"",pfmname)
                pfmIdx <- which(makeLeaveNames(labels.leaves) %in% 
                                    makeLeaveNames(pfmname))
                if(length(pfmIdx)==0) 
                    pfmIdx <- which(makeLeaveNames(names(phylog$leaves)) 
                                    %in% makeLeaveNames(pfmname))
                if(length(pfmIdx)>0){
                    vph <- ifelse(motifScale=="linear",
                                  vpheight*length(pfmname),
                                  ifelse(motifScale=="logarithmic", 
                                         vpheight*(1+log2(length(pfmname))),
                                         vpheight))
                    vpw <- vph * ncol(pfms[[i]]@mat) / 2
                    vpd <- sqrt(vph*vph+vpw*vpw) / 2
                    angle <- median(beta[pfmIdx])
                    if(length(pfmIdx)%%2==1){
                        this.pfmIdx <- which(beta[pfmIdx] == angle)[1]
                        vpx <- xm[pfmIdx[this.pfmIdx]] + 
                            vpd * cos(alpha[pfmIdx[this.pfmIdx]]) * asp[1L]
                        vpy <- ym[pfmIdx[this.pfmIdx]] + 
                            vpd * sin(alpha[pfmIdx[this.pfmIdx]]) * asp[2L]
                        vpx1 <- xm[pfmIdx[this.pfmIdx]] - 
                            inner.label.circle.width * 
                            cos(alpha[pfmIdx[this.pfmIdx]]) * 
                            asp[1L] *1.1/twoR
                        vpy1 <- ym[pfmIdx[this.pfmIdx]] - 
                            inner.label.circle.width * 
                            sin(alpha[pfmIdx[this.pfmIdx]]) * 
                            asp[2L] *1.1/twoR
                    }else{
                        this.pfmIdx <- order(abs(beta[pfmIdx] - angle))[1:2]
                        vpx <- median(xm[pfmIdx[this.pfmIdx]]) + 
                            vpd * cos(median(alpha[pfmIdx[this.pfmIdx]])) * 
                            asp[1L]
                        vpy <- median(ym[pfmIdx[this.pfmIdx]]) + 
                            vpd * sin(median(alpha[pfmIdx[this.pfmIdx]])) *
                            asp[2L]
                        vpx1 <- median(xm[pfmIdx[this.pfmIdx]]) - 
                            inner.label.circle.width * 
                            cos(median(alpha[pfmIdx[this.pfmIdx]])) * 
                            asp[1L] *1.1/twoR
                        vpy1 <- median(ym[pfmIdx[this.pfmIdx]]) - 
                            inner.label.circle.width * 
                            sin(median(alpha[pfmIdx[this.pfmIdx]])) * 
                            asp[2L] *1.1/twoR
                    }
                    pushViewport(viewport(x=vpx, y=vpy, width=vpw, 
                                          height=vph, angle=angle))
                    plotMotifLogoA(pfms[[i]], ic.scale=ic.scale)
                    popViewport()
                    if(.plotIndex) {
                        grid.text(label=i, x=vpx1, 
                                  y=vpy1, 
                                  gp=gpar(col=IndexCol, cex=IndexCex), 
                                  rot=angle, just="right")
                    }
                }else{
                    warning(paste("No leave named as ",
                                  paste(pfmname, collapse=", ")), 
                            sep="")
                }
            }
        }
        if(!is.null(pfms)){
            drawPFMcir(pfms, xm, ym, vpheight, plotIndex[1])
        }
        if(!is.null(pfms2)){
            if(length(plotIndex)<2) plotIndex[2] <- plotIndex[1]
            drawPFMcir(pfms2, xm2, ym2, vpheight2, plotIndex[2])
        }
        
        rm(list="tmp_motifStack_symbolsCache", envir=.globals)
    }
    if (cleaves > 0) {
        for (i in 1:leaves.number) points(x[i], y[i], pch = 21,
                                          col=col.leaves[i],
                                          bg = col.leaves[i], 
                                          cex = par("cex") * cleaves)
    }
    ang <- rep(0, length(dist.nodes))
    names(ang) <- names(dist.nodes)
    ang <- c(alpha, ang)
    for (i in 1:length(phylog$parts)) {
        w <- phylog$parts[[i]]
        but <- names(phylog$parts)[i]
        ang[but] <- mean(ang[w])
        b <- range(ang[w])
        a.seq <- c(seq(b[1], b[2], by = pi/180), b[2])
        lines(dis[but] * cos(a.seq), dis[but] * sin(a.seq), 
              col="#222222", lwd=par("cex") * clabel.leaves)
        x1 <- dis[w] * cos(ang[w])
        y1 <- dis[w] * sin(ang[w])
        x2 <- dis[but] * cos(ang[w])
        y2 <- dis[but] * sin(ang[w])
        segments(x1, y1, x2, y2, col="#222222", lwd=par("cex") * clabel.leaves)
    } 
    if(!is.na(groupDistance)){
        if(length(groupDistanceLineCol)!=length(groupDistance)){
            groupDistanceLineCol <- 
                rep(groupDistanceLineCol, 
                    ceiling(length(groupDistance)/
                                length(groupDistanceLineCol
                                       )))[seq_along(groupDistance)]
        }
        for(i in 1:length(groupDistance)){
            if(groupDistance[i] > 0)
                symbols(x=0, y=0, circles=groupDistance[i],
                        fg=groupDistanceLineCol[i], lty=2, 
                        inches=FALSE, add=TRUE)
        }
    }
    if (cnodes > 0) {
        for (i in 1:length(phylog$parts)) {
            w <- phylog$parts[[i]]
            but <- names(phylog$parts)[i]
            ang[but] <- mean(ang[w])
            points(dis[but] * cos(ang[but]), dis[but] * sin(ang[but]),
                   pch = 21, bg = "white", cex = par("cex") * cnodes)
        }
    }
    
    ## draw distance indix  
    if(plotAxis){
        wd <- twoR
        if(clockwise){
            vp <- viewport(x=0.5, y=0.5, width=axis_pos/wd, height=.1, 
                           xscale=c(0, max_Dis), angle=init.angle, just=c(0, 0))
            pushViewport(vp)
            grid.xaxis(gp=gpar(cex = par("cex") * clabel.leaves, 
                               col="lightgray"),
                       main=TRUE)
            popViewport()
        }else{
            vp <- viewport(x=0.5, y=0.5, width=axis_pos/wd, height=.1, 
                           xscale=c(0, max_Dis), angle=init.angle, just=c(0, 1))
            pushViewport(vp)
            grid.xaxis(gp=gpar(cex = par("cex") * clabel.leaves, 
                               col="lightgray"),
                       main=FALSE)
            popViewport()
        }
    }
    
    points(0, 0, pch = 21, cex = par("cex") * 2 * ratio * clabel.leaves, 
           bg = "red")
    if (clabel.nodes > 0) {
        delta <- strwidth(as.character(length(dist.nodes)), cex = par("cex") *
                              clabel.nodes)
        for (j in 1:length(dist.nodes)) {
            i <- names(dist.nodes)[j]
            par(srt = (ang[i] * 360/2/pi + 90))
            x1 <- dis[i] * cos(ang[i])
            y1 <- dis[i] * sin(ang[i])
            symbols(x1, y1, delta, bg = "white", add = TRUE,
                    inches = FALSE)
            text(x1, y1, nodes.car[j], adj = 0.5, cex = par("cex") *
                     clabel.nodes)
        }
    }
    
    if (draw.box)
        box()
    return(invisible())
}
