#===============================================================================

            #  gscp_13_write_marxan_control_file_and_run_marxan.R

#===============================================================================
    
    #  TODO:

    #  NOTE:  Many of the entries below have to do with reading marxan output 
    #         and loading it into this program and doing something with it.
    #         I should build functions for doing those things and add them to 
    #         the marxan package.  Should talk to Ascelin about this too and 
    #         see if there is any overlap with what he's doing.

#===============================================================================
    
    #  Build structures holding:
        #  Make a function to automatically do these subtotalling actions 
        #  since I need to do it all the time.
            #  May want one version for doing these give a table or dataframe 
            #  and another for doing them given a list or list of lists 
            #  since those are the most common things I do (e.g, in 
            #  distSppOverPatches()).
        #  Species richness for each patch.
        #  Number of patches for each spp.
        #  Correct solution.
        #  Things in dist spp over patches?
            #  Patch list for each species.
            #  Species list for each patch.
    #  Are some of these already built for the plotting code above?

    #  *** Maybe this should be done using sqlite instead of lists of lists and 
    #  tables and data frames?


    #  http://stackoverflow.com/questions/1660124/how-to-group-columns-by-sum-in-r
    #  Is this counting up the number of species on each patch?
# x2  <-  by (spp_PU_amount_table$amount, spp_PU_amount_table$pu, sum)
# do.call(rbind,as.list(x2))
# 
# cat ("\n\nx2 =\n")
# print (x2)

#===============================================================================

    #  Aside:  The mention of distSppOverPatches() above reminds me that I 
    #           found something the other day saying that copulas were 
    #           a way to generate distributions with specified marginal 
    #           distributions.  I think that I saved a screen grab and 
    #           named the image using copula in the title somehow...

#===============================================================================

timepoints_df = 
    timepoint (timepoints_df, "gscp_13", 
               "Starting gscp_13_write_marxan_control_file_and_run_marxan.R")

#===============================================================================

    #  Set the marxan executable name to default to the mac, 
    #  but check for linux as well.
    #  I don't know the name for Windows, so I'll just 
    #  let the system command crash on Windows for the moment since I'm 
    #  not doing anything at all with Windows right now and 
    #  can look that up later if necessary.
marxan_executable_name = "MarOpt_v243_Mac64"
if (current_os == "linux-gnu")
    marxan_executable_name = "MarOpt_v243_Linux64"    

#===============================================================================

    #  Run marxan.
        #  Should include this in the marxan package.

run_marxan = function (marxan_dir, marxan_executable_name)
    {
#    marxan_dir = "/Users/bill/D/Marxan/"    #  replaced in yaml file
    
    original_dir = getwd()
    cat ("\n\noriginal_dir =", original_dir)
    
    cat ("\n\nImmediately before calling marxan, marxan_dir = ", marxan_dir)
    setwd (marxan_dir)
    
    cat("\n =====> The current wd is", getwd() )
    
        #  The -s deals with the problem of Marxan waiting for you to hit 
        #  return at the end of the run when you're running in the background.  
        #  Without it, the system() command never comes back.
        #       (From p. 24 of marxan.net tutorial:
        #        http://marxan.net/tutorial/Marxan_net_user_guide_rev2.1.pdf
        #        I'm not sure if it's even in the normal user's manual or 
        #        best practices manual for marxan.)
    
        #  BTL - 2015 03 27 
        #  Marxan mailing list recently pointed to some new marxan materials 
        #  on github and one of them has an example of some R code that 
        #  calls marxan with what looks like a specification of the location 
        #  of the input.dat file.  So, it looks like I can just add the 
        #  filespec of the input.dat file as an argument after the "-s" 
        #  argument without having any kind of other dash option specifying 
        #  that you're giving the path to the input.dat file.  

    system.command.run.marxan = paste0 ("./", marxan_executable_name, " -s")   
    cat( "\n\n>>>>>  The system command to run marxan will be:\n'", 
         system.command.run.marxan, "'\n>>>>>\n\n", sep='')
    
    retval = system (system.command.run.marxan)    #  , wait=FALSE)
    cat ("\n\nmarxan retval = '", retval, "'.\n\n", sep='')        
    
    setwd (original_dir)
    cat ("\n\nAfter setwd (original_dir), sitting in:", getwd(), "\n\n")
    
    return (retval)
    }

#===============================================================================
#                       General Marxan Parameters
#===============================================================================

    #  Set default marxan values here, but allow for overrides below if  
    #  the marxan_use_default_input_parameters flag is turned off in the 
    #  parameters set.

marxan_BLM = 1
marxan_PROP  = 0.5

    #*******
    #  NOTE:  Random seed is set to -1 in the cplan input.dat.
    #           I think that means to use a different seed each time.
    #           I probably need to change this to any positive number, 
    #           at least in the default input.dat that I'm using now 
    #           so that I get reproducible results.
    #*******

marxan_RANDSEED  = seed    #  Default to same seed as the R code.
marxan_NUMREPS  = 10

    #  Annealing Parameters
        #  It looks like Marxan chokes if input.dat has the number of 
        #  iterations expressed in scientific notation (e.g., 1e+06). 
        #  Somewhere along the path between here and writing the value 
        #  out to the input.dat file, values around 1 million do get 
        #  converted to scientific notation, so I'm putting them in 
        #  quotes so that they are written out to marxan's liking.
marxan_NUMITNS  = "1000000"
marxan_STARTTEMP  = -1
marxan_NUMTEMP  = 10000

    #  Cost Threshold
marxan_COSTTHRESH   = "0.00000000000000E+0000"
marxan_THRESHPEN1   = "1.40000000000000E+0001"
marxan_THRESHPEN2   = "1.00000000000000E+0000"

    #  Input Files
marxan_INPUTDIR  = marxan_input_dir    #  "input"
marxan_PUNAME  = "pu.dat"
marxan_SPECNAME  = "spec.dat"
marxan_PUVSPRNAME  = "puvspr.dat"

    #  Save Files
marxan_SCENNAME  = "output"
marxan_SAVERUN  = 3
marxan_SAVEBEST  = 3
marxan_SAVESUMMARY  = 3
marxan_SAVESCEN  = 3
marxan_SAVETARGMET  = 3
marxan_SAVESUMSOLN  = 3
marxan_SAVEPENALTY  = 3
marxan_SAVELOG  = 2
marxan_OUTPUTDIR  = marxan_output_dir    #  "output"

    #  Program control

    #  From Marxan user's manual v. 1.8.10, pp. 25-6
    #  3.2.1.2.1 Run Options
    #  Variable – ‘RUNMODE’ Required: Yes
    #  Description: This is an essential variable that defines the method Marxan
    #  will use to locate good reserve solutions . As discussed in the introduction,
    #  the real strength of Marxan lies in its use of Simulated Annealing to find
    #  solutions to the reserve selection problem. Marxan, however, is also capable
    #  of using simpler, but more rapid, methods to locate potential solutions ,
    #  such as heuristic rules and iterative improvement (see Appendix B -2.2 for
    #  more details on these methods). Because heuristic rules can be applied
    #  extremely quickly and produce reasonable results they are included for use on
    #  extremely large data sets. Modern computers are now so powerful that
    #  heuristics are less necessary as a time saving device, a lthough they are
    #  still useful as research tools. Running Iterative Improvement on itsown gives
    #  very poor solutions. As well as using any of these three methods on their
    #  own, Marxan can also use them in concert with each. If more than one are
    #  selected they will be applied in the following order: Simulated Annealing,
    #  Heuristic, Iterative Improvement. This means that there are seven different
    #  run options:    
    #     0  Apply Simulated Annealing followed by a Heuristic
    #     1  Apply Simulated Annealing followed by Iterative Improvement
    #     2  Apply Simulated Annealing followed by a Heuristic, followed by
    #        Iterative Improvement
    #     3  Use only a Heuristic
    #     4  Use only Iterative Improvement
    #     5  Use a Heuristic followed by Iterative Improvement
    #     6  Use only Simulated Annealing
    #  ... each of the above running combinations can be set with a single
    #  number in the ‘input.dat’ file ...
marxan_RUNMODE  = 1

    #  From Marxan user's manual v. 1.8.10, p. 27
    #  3.2.1.2.3 Heuristic
    #  Variable – ‘HEURTYPE’ Required: No
    #  Description: If you are using a n optional heuristic to find reserve
    #  solutions, this variable defines what type of heuristic algorithm will be
    #  applied. Details of the different Heuristics listed below are given in
    #  Appendix B-2 .3.
    #   0  Richness
    #   1  Greedy
    #   2  Max Rarity
    #   3  Best Rarity
    #   4  Average Rarity
    #   5  Sum Rarity
    #   6  Product Irreplaceability
    #   7  Summation Irreplaceability
marxan_HEURTYPE  = -1

marxan_MISSLEVEL  = 1
marxan_ITIMPTYPE  = 0
marxan_CLUMPTYPE  = 0
marxan_VERBOSITY  = 3

marxan_SAVESOLUTIONSMATRIX  = 3

#-------------------

#  Need to pull the random seed out of this and always set it myself.
#  A good default would be to use the same random seed as my R code is using 
#  here.  

if (! is.null (parameters$marxan_seed))  
    { marxan_RANDSEED  = parameters$marxan_seed }    

    #  If not using default input parameters, use any values that are 
    #  specified in the yaml file for the following variables. 
    #  Anything that's not in the yaml file, just fall back to the defaults.
    #  The way to know whether the yaml file has specified a value is that 
    #  asking for its slot in the parameters list will return NULL if it 
    #  was not specified.

if (! parameters$marxan_use_default_input_parameters)
    {
    if (! is.null (parameters$marxan_prop))  
        { marxan_PROP  = parameters$marxan_prop } 
    
    if (! is.null (parameters$marxan_num_reps))  
        { marxan_NUMREPS  = parameters$marxan_num_reps } 
    
    if (! is.null (parameters$marxan_num_iterations))  
        { marxan_NUMITNS  = parameters$marxan_num_iterations } 
    
    if (! is.null (parameters$marxan_runmode))  
        { marxan_RUNMODE  = parameters$marxan_runmode } 

    if (! is.null (parameters$marxan_heurtype))  
        { marxan_HEURTYPE  = parameters$marxan_heurtype } 
    }

#browser()

#-------------------

#marxan_input_parameters_file_name = "/Users/bill/D/Marxan/input.dat"
#####marxan_input_parameters_file_name = parameters$marxan_input_parameters_file_name
# marxan_input_parameters_file_name = 
#     paste0 (marxan_input_dir, .Platform$file.sep, 
#             parameters$marxan_input_parameters_file_name)
marxan_input_parameters_file_name = parameters$marxan_input_parameters_file_name

cat ("\n\n>>>>>  IN 13, marxan_input_dir = ", marxan_input_dir)
cat ("\n>>>>>  parameters$marxan_input_parameters_file_name = ", parameters$marxan_input_parameters_file_name)
cat ("\n>>>>>  marxan_input_parameters_file_name = ", marxan_input_parameters_file_name, "\n")
#stop ("is it inputinput?")
#####rm_cmd = paste ("rm", marxan_input_parameters_file_name)
#####system (rm_cmd)

#marxan_input_file_conn = file (marxan_input_parameters_file_name)
marxan_input_file_conn = marxan_input_parameters_file_name
    
#cat ("Marxan input file", file=marxan_input_file_conn, append=TRUE)
cat ("Marxan input file", file=marxan_input_file_conn)

cat ("\n\nGeneral Parameters", file=marxan_input_file_conn, append=TRUE)

cat ("\nBLM", marxan_BLM, file=marxan_input_file_conn, append=TRUE)
cat ("\nPROP", marxan_PROP, file=marxan_input_file_conn, append=TRUE)
cat ("\nRANDSEED", marxan_RANDSEED, file=marxan_input_file_conn, append=TRUE)
cat ("\nNUMREPS", marxan_NUMREPS, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nAnnealing Parameters", file=marxan_input_file_conn, append=TRUE)
cat ("\nNUMITNS", marxan_NUMITNS, file=marxan_input_file_conn, append=TRUE)
cat ("\nSTARTTEMP", marxan_STARTTEMP, file=marxan_input_file_conn, append=TRUE)
cat ("\nNUMTEMP", marxan_NUMTEMP, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nCost Threshold", file=marxan_input_file_conn, append=TRUE)
cat ("\nCOSTTHRESH", marxan_COSTTHRESH, file=marxan_input_file_conn, append=TRUE)
cat ("\nTHRESHPEN1", marxan_THRESHPEN1, file=marxan_input_file_conn, append=TRUE)
cat ("\nTHRESHPEN2", marxan_THRESHPEN2, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nInput Files", file=marxan_input_file_conn, append=TRUE)
cat ("\nINPUTDIR", marxan_INPUTDIR, file=marxan_input_file_conn, append=TRUE)
cat ("\nPUNAME", marxan_PUNAME, file=marxan_input_file_conn, append=TRUE)
cat ("\nSPECNAME", marxan_SPECNAME, file=marxan_input_file_conn, append=TRUE)
cat ("\nPUVSPRNAME", marxan_PUVSPRNAME, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nSave Files", file=marxan_input_file_conn, append=TRUE)
cat ("\nSCENNAME", marxan_SCENNAME, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVERUN", marxan_SAVERUN, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVEBEST", marxan_SAVEBEST, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVESUMMARY", marxan_SAVESUMMARY, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVESCEN", marxan_SAVESCEN, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVETARGMET", marxan_SAVETARGMET, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVESUMSOLN", marxan_SAVESUMSOLN, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVEPENALTY", marxan_SAVEPENALTY, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVELOG", marxan_SAVELOG, file=marxan_input_file_conn, append=TRUE)
cat ("\nOUTPUTDIR", marxan_OUTPUTDIR, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nProgram control.", file=marxan_input_file_conn, append=TRUE)
cat ("\nRUNMODE", marxan_RUNMODE, file=marxan_input_file_conn, append=TRUE)
cat ("\nMISSLEVEL", marxan_MISSLEVEL, file=marxan_input_file_conn, append=TRUE)
cat ("\nITIMPTYPE", marxan_ITIMPTYPE, file=marxan_input_file_conn, append=TRUE)
cat ("\nHEURTYPE", marxan_HEURTYPE, file=marxan_input_file_conn, append=TRUE)
cat ("\nCLUMPTYPE", marxan_CLUMPTYPE, file=marxan_input_file_conn, append=TRUE)
cat ("\nVERBOSITY", marxan_VERBOSITY, file=marxan_input_file_conn, append=TRUE)

cat ("\nSAVESOLUTIONSMATRIX", marxan_SAVESOLUTIONSMATRIX, file=marxan_input_file_conn, append=TRUE)

    #  When I turn this on, I get the following error message:
    #       Error in UseMethod("close") :  
    #       no applicable method for 'close' applied to an object of class "character" 
    #  Not sure what I should be handing to the close() function...
#close (marxan_input_file_conn)

input_dat_cp_cmd = paste0 ("cp ", marxan_input_parameters_file_name, " ", marxan_IO_dir)
cat ("\n\ninput_dat_cp_cmd = ", input_dat_cp_cmd, "\n")
system (input_dat_cp_cmd)

#browser()

#===============================================================================

system (paste0 ("chmod +x ", parameters$marxan_dir, marxan_executable_name))

#stop("Testing - just finished marxan input file writing...")

run_marxan (parameters$marxan_dir, marxan_executable_name)

#===============================================================================

