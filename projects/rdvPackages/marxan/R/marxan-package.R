#' Build input files for Marxan reserve selection software.
#'
#' The \pkg{marxan} package is intended to make it easier to build input files 
#' for Marxan when you're using simulated data.  
#' 
#' At the moment, the only 
#' functions in this package are the ones to write 
#' the pu.dat, spec.dat, and puvspr.dat files.  
#' These are the only input files 
#' that Marxan must have to run, except for the input.dat file which contains 
#' the overall control variables for a Marxan run.  This package does not 
#' yet generate that file since you can copy it from the Marxan distribution 
#' and easily edit it with a text editor.  
#' 
#' There are four main functions you're likely to need from this package. 
#'  
#' First, there are the three 
#' that write each of the Marxan input files individually:
#' 
#' \code{\link{write_marxan_pu.dat_input_file}}, 
#' \code{\link{write_marxan_spec.dat_input_file}}, 
#' \code{\link{write_marxan_puvspr.dat_input_file}},
#' 
#' Last, is the convenience function that calls the other three all at once:
#' 
#' \code{\link{write_all_marxan_input_files}}.
#' 
#' Unless you specify otherwise in the input.dat file, 
#' Marxan expects the 3 input files generated by the \pkg{marxan} package  
#' to be in a subdirectory of the same directory where the Marxan executable is 
#' located.  The subdirectory is to be called "input".  
#' 
#' Note that there also needs to be a corresponding subdirectory called 
#' "output" at the same level as the input subdirectory.  
#' It's generally empty, but I think that if there is something 
#' already in it (e.g., the output of a previous run), then Marxan will just 
#' write over it.  
#' 
#' When you run any of the input file generation functions in \pkg{marxan}, 
#' they will write their output to whatever directory you are sitting in.  
#' If this is not the Marxan directory, you will need to copy the files to the 
#' input directory that Marxan expects before you can run Marxan.  (Note that 
#' any previous versions of the input files in the current directory will be 
#' overwritten by the \pkg{marxan} package functions.)
#'
#' Marxan expects the input.dat control file to be sitting in the same 
#' directory as Marxan.  For now, you can just use the copy that comes with 
#' the Marxan distribution once you have deleted the line that references 
#' the bound.dat file (unless you have a bound.dat file to give it).
#' 
#' @docType package
#' @name marxan
NULL
