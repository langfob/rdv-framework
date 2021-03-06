#===============================================================================

#                         evaluateZonationResults.R

#===============================================================================

#  History
#
#  2014 02 19 - BTL - Created.
#
#  Have split this out of the old guppy and even older Austin ESA code that  
#  was in runZonation.R.
#    - The history comments in setUpAndRunZonation.R have some details of 
#      what I've done to that old runZonation.R code to incorporate it into g2.
#    - The plotting and evaluation of zonation results that made up the last 
#      part of runZonation.R has now been moved into here and turned into a 
#      function called evaluationZonationResults.R.  That function is now 
#      called in the g2 mainline just after the two calls to setUp...().

#===============================================================================

evaluateZonationResults = function (zonation.files.dir.with.slash, 
                                    analysis.dir.with.slash, 
                                    write.to.file
                                    )
    {    
    zonation.app.rank =
        read.asc.file.to.matrix ("zonation_app_output.rank",
                                 zonation.files.dir.with.slash)
    #"/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/Zonation/")
    
    zonation.cor.rank =
        read.asc.file.to.matrix ("zonation_cor_output.rank",
                                 zonation.files.dir.with.slash)
    #"/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/Zonation/")
    
    #--------------------
    
        #  Compute the difference between the correct and zonation probabilities
        #  and save it to a file for display.
    err.between.app.and.zonation.ranks <- zonation.app.rank - zonation.cor.rank
    
    num.img.rows <- dim (err.between.app.and.zonation.ranks) [1]
    num.img.cols <- dim (err.between.app.and.zonation.ranks) [2]
    
    write.pgm.file (err.between.app.and.zonation.ranks,
                    paste (zonation.files.dir.with.slash,
                           "raw.error.in.zonation.ranks", sep=''),
                    num.img.rows, num.img.cols)
    
    #-------------------------------------------------------------------------
    #  Plot that pattern.
    #  Compute non-spatial statistics that compare the two distributions.
    #    - rank correlation
    #    - correlation
    #    - KS test  (is KS the test that compares two distributions?)
    #  One question: are there any computer arithmetic issues with all these
    #  small numbers in these distributions?
    #-------------------------------------------------------------------------
    
    #--------------------------------------------------------------------
    #  IMPORTANT
    #  NOTE:  May want to do these tests using several different views
    #         that reflect something like a cost-sensitive view.
    #         For example, what is most important in a Madagascar-style
    #         use of maxent + zonation is how the true top 10% of the
    #         distribution performs.
    #         So, you may want to use which() to pull out certain
    #         subsets of locations to analyze.
    #         More importantly, probably want to do a which() that
    #         selects the top 10% or so of locations in the true
    #         distribution and the true Zonation ranking.  Then,
    #         do various statistics on just those locations in the
    #         Maxent data to get an idea of how well it does on those.
    #         One more thing - percent error may not be the right
    #         error to look at in a probability distribution.
    #         May want to look at the absolute error instead.
    #         Not sure...
    #--------------------------------------------------------------------
    
    err.magnitudes <- abs (err.between.app.and.zonation.ranks)
    # write.asc.file (err.magnitudes,
    # 				paste (analysis.dir, "abs.error.in.dist.", spp.name, sep=''),
    #             	num.img.rows, num.img.cols
    #             	, xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
    #                 , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
    #                                       #  is not actually on the map.  It's just off the lower
    #                                       #  left corner.
    #                 , no.data.value = -9999
    #                 , cellsize = 1
    #                 )
    write.pgm.file (err.magnitudes,
                    paste (analysis.dir.with.slash,
                           "abs.error.in.zonation.ranks", sep=''),
                    num.img.rows, num.img.cols)
    
    
    tot.err.magnitude <- sum (err.magnitudes)
    max.err.magnitude <- max (err.magnitudes)
    
    ####  PROBLEM: norm.prob.matrix not defined?  zonation.norm.prob.dist not defined?
    
    ########  Should these be cor and app instead?
    ########  I.e., npm.vec ----> norm.prob.cor.vec and
    ########       mnpd.vec ----> norm.prob.app.vec ???
    ########  BTL - 2013.05.06
    
    ########  Also, is it really necessary to convert these to vectors?
    ########  Doesn't R already treat them as vectors except when you apply
    ########  matrix operations to them?
    
    
    #npm.vec <- as.vector (norm.prob.matrix)
    npm.vec <- as.vector (zonation.app.rank)
    #mnpd.vec <- as.vector (zonation.norm.prob.dist)
    mnpd.vec <- as.vector (zonation.cor.rank)
    
    pearson.cor <- cor (npm.vec, mnpd.vec,
                        method = "pearson"
                        )
    spearman.rank.cor <- cor (npm.vec, mnpd.vec,
                              method = "spearman"
                              )
    
    #  this one hung R every time I used it...
    ##kendall.cor <- cor (npm.vec, mnpd.vec,
    ##     			    method = "kendall"
    ##     			   )
    
    ##par (mfrow=c(4,2))    #  4 rows, 2 cols
    par (mfrow=c(2,2))    #  2 rows, 2 cols
    
    percent.err.magnitudes <- (err.magnitudes / zonation.cor.rank) * 100
    hist (percent.err.magnitudes [percent.err.magnitudes <= 100])
    
    write.pgm.file (percent.err.magnitudes,
                    paste (analysis.dir.with.slash,
                           "percent.error.in.zonation.ranks", sep=''),
                    num.img.rows, num.img.cols)
    
    abs.percent.err.magnitudes <- abs (percent.err.magnitudes)
    write.pgm.file (abs.percent.err.magnitudes,
                    paste (analysis.dir.with.slash,
                           "abs.percent.error.in.zonation.ranks", sep=''),
                    num.img.rows, num.img.cols)
    
    
    ##    #  Reset the largest errors to one fairly large value so that
    ##    #  you can reduce the dynamic range of the image and make it
    ##    #  easier to differentiate among smaller values.
    
    truncated.err.img <- abs.percent.err.magnitudes
    truncated.err.img [percent.err.magnitudes >= 50] <- 50
    write.pgm.file (truncated.err.img,
                    paste0 (analysis.dir.with.slash,
                            "truncated.zonation.rank.percent.err.img"),
                    num.img.rows, num.img.cols)
    
    
    if (write.to.file)  
        tiff (paste0 (analysis.dir.with.slash, "percent.error.zonation.rank.map.tiff"))
    #    plot.main.title <- "Percent error in Zonation rank"
    #    plot.key.title <- "Error\n(percent)"
    #    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
    contour.levels.to.draw <- c (20)
    draw.contours = TRUE
    draw.filled.contour.img (truncated.err.img,
                             "Truncated percent error in Zonation rank",
                             "Error\n(percent)",
                             terrain.colors, "red",
                             draw.contours,
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()
    
    if (write.to.file)  
        tiff (paste0 (analysis.dir.with.slash, 
                      "raw.error.zonation.rank.map.tiff"))
    #    plot.main.title <- "Percent error in Zonation rank"
    #    plot.key.title <- "Error\n(percent)"
    #    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
    contour.levels.to.draw <- c (-0.50, 0.0)
    draw.contours = TRUE
    draw.filled.contour.img (err.between.app.and.zonation.ranks,
                             "Raw error in Zonation rank",
                             "Error\n(raw)",
                             terrain.colors, "red",
                             draw.contours,
                             contour.levels.to.draw
                            )
    if (write.to.file)  dev.off()
    
    #  Not sure what's going on here.  Trying to put a contour around the top
    #  10% or so of zonation ranks, but it doesn't seem to agree with the .jpg
    #  files that zonation writes out (bright red, etc.).
    #     if (write.to.file)  tiff (paste (analysis.dir, "zonation.app.rank.map.tiff", sep=''))
    #     contour.levels.to.draw <- c (0.10)
    #     draw.contours = TRUE
    #     draw.filled.contour.img (zonation.app.rank,
    #                              "Zonation Apparent rank",
    #                              "Rank",
    #                              terrain.colors, "red",
    #                              draw.contours,
    #                              contour.levels.to.draw
    #                              )
    #     if (write.to.file)  dev.off()
    #
    #     if (write.to.file)  tiff (paste (analysis.dir, "zonation.cor.rank.map.tiff", sep=''))
    #     contour.levels.to.draw <- c (0.10)
    #     draw.contours = TRUE
    #     draw.filled.contour.img (zonation.cor.rank,
    #                              "Zonation Correct rank",
    #                              "Rank",
    #                              terrain.colors, "red",
    #                              draw.contours,
    #                              contour.levels.to.draw
    #                              )
    #     if (write.to.file)  dev.off()
    
    }  #  end - function
    
#===============================================================================

