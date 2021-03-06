#===============================================================================

#  source ("initializeG2options.R")

#===============================================================================

#  History

#  2014 02 01 - BTL - Created.

#  2014 02 16 - BTL - Converting to use yaml file variables from tzar.

#  2014 03 28 - BTL
#      - fullPathToZonationFilesDir was being set individually for each OS, 
#        but in the yaml file, each of the 3 different OS variants had the 
#        the same value so I've reduced it all down to a single variable 
#        here and in the yaml file.

#===============================================================================

#  Most (if not all) of these will come from the yaml file eventually...

#===============================================================================

# tzarOutputdataRootWithSlash = "/Users/Bill/tzar/outputdata/g2/default_runset/"
# ##dir.slash = "/"    #  This is already dealt with at start of g2
#                      #  in an OS-specific way.
# #curExpOutputDirName = "401_Scen_1"
#
# createFullTzarExpOutputDirRoot = function (curExpOutputDirName,
#                                            tzarOutputdataRootWithSlash,
#                                            dir.slash = "/")
#     {
#     curFullTzarExpOutputDirRootWithSlash =
#         paste0 (tzarOutputdataRootWithSlash,
#                 curExpOutputDirName, dir.slash)
#
#     cat ("\n\ncurFullTzarExpOutputDirRootWithSlash = ",
#          curFullTzarExpOutputDirRootWithSlash, "\n\n", sep='')
#
#     if (file.exists (curFullTzarExpOutputDirRootWithSlash))
#         {
#         errMsg = paste0 ("\n\n*** curFullTzarExpOutputDirRootWithSlash = \n***     ",
#                          curFullTzarExpOutputDirRootWithSlash,
#                          "\n*** already exists.  ",
#                          "\n*** Need to change curExpOutputDirName in ",
#                          "initializeG2options.R\n\n")
#         stop (errMsg)
#
#         } else
#         {
#         cat ("\n\ncurFullTzarExpOutputDirRootWithSlash DOES NOT exist.  ",
#              "Creating it.\n\n", sep='')
#         dir.create (curFullTzarExpOutputDirRootWithSlash,
#                     showWarnings = TRUE,
#                     recursive = TRUE, #  Not sure about this, but it's convenient.
#                     mode = "0777")    #  Not sure if this is what we want for mode.
#         }
#     return (curFullTzarExpOutputDirRootWithSlash)
#     }
#
# curFullTzarExpOutputDirRootWithSlash =
#     createFullTzarExpOutputDirRoot (curExpOutputDirName,
#                                     tzarOutputdataRootWithSlash, dir.slash)

curFullTzarExpOutputDirRootWithSlash =
#    parameters$fullTzarExpOutputDirRootWithSlash
    gsub ("Documents and Settings", "DOCUME~1", 
          parameters$fullTzarExpOutputDirRootWithSlash)

cat ("\n\ncurFullTzarExpOutputDirRootWithSlash = ",
     curFullTzarExpOutputDirRootWithSlash, "\n\n", sep='')

#===============================================================================

                                #----------------
                                #  user options
                                #----------------

#===============================================================================

#------------------------------------------------------------------------
#  Some options that relate to path names need to be dealt with in
#  different ways that depend on the OS you're currently running under,
#  so handle all of those here in one place.
#------------------------------------------------------------------------

if (current.os == "mingw32")
    {
                    #  -- WINDOWS --

    envLayersSrcDir = parameters$envLayersSrcDir.windows.vmware
    clusterFilePath = parameters$clusterFilePath.windows.vmware
    maxentFullPathName = parameters$maxentFullPathName.windows.vmware
    fullPathToZonationExe = parameters$fullPathToZonationExe.windows.vmware
    fullPathToZonationParameterFile = parameters$fullPathToZonationParameterFile.windows.vmware
#    fullPathToZonationFilesDir = parameters$fullPathToZonationFilesDir.windows.vmware

    } else if (regexpr ("darwin*", current.os) != -1)
    {
                    #  -- MAC --

    envLayersSrcDir = parameters$envLayersSrcDir.mac
    clusterFilePath = parameters$clusterFilePath.mac
    maxentFullPathName = parameters$maxentFullPathName.mac
    fullPathToZonationExe = parameters$fullPathToZonationExe.mac
    fullPathToZonationParameterFile = parameters$fullPathToZonationParameterFile.mac
#    fullPathToZonationFilesDir = parameters$fullPathToZonationFilesDir.mac

    } else    #  Assume linux...
    {
                    #  -- LINUX --

    envLayersSrcDir = parameters$envLayersSrcDir.linux
    clusterFilePath = parameters$clusterFilePath.linux
sppLibDir = parameters$sppLibPath.linux
    maxentFullPathName = parameters$maxentFullPathName.linux
    fullPathToZonationExe = parameters$fullPathToZonationExe.linux
    fullPathToZonationParameterFile = parameters$fullPathToZonationParameterFile.linux
#    fullPathToZonationFilesDir = parameters$fullPathToZonationFilesDir.linux


#Sys.setenv (NOAWT=TRUE)

    }

    #  BTL - 2014 03 28 
    #  Replacing the individualization of the zonation files dir to OS 
    #  with a single initialization since they all seemed to be the same.
fullPathToZonationFilesDir = parameters$fullPathToZonationFilesDir
cat ("\nfullPathToZonationFilesDir = '", fullPathToZonationFilesDir, "'", sep='')

#===============================================================================

#  For getEnvLayers()

#  This used to be called envLayersDir.
#  Trying to make names differentiate between the source of information
#  before the experiment is run and the working copy of information that
#  is copied into the tzar output area as part of the experiment.
#envLayersSrcDir          = "/Users/Bill/D/Data/MattsVicTestLandscape/MtBuffaloEnvVars_Originals/"
#envLayersSrcDir = file.path (userPath, parameters$envLayersSrcDir)

#####  Using libraries now, so may not need to do this anymore...
#####  BTL - 2014 03 28
#####envLayersSrcDir = paste0 (userPath, dir.slash, envLayersSrcDir)

#  This used to be called curFullMaxentEnvLayersDirName.
#  I'm trying to get rid of references to maxent in cases where things
#  are not specific just to maxent.
#
##envLayersWorkingDir = "/Users/Bill/tzar/outputdata/g2/default_runset/400_Scen_1/InputEnvLayers"
#envLayersWorkingDirName = "InputEnvLayers"

envLayersWorkingDirName = parameters$envLayersWorkingDirName

cat ("\n\nenvLayersWorkingDirName = '",
     envLayersWorkingDirName, "'\n\n", sep='')

envLayersWorkingDir = paste0 (curFullTzarExpOutputDirRootWithSlash,
                              envLayersWorkingDirName)

envLayersWorkingDirWithSlash = paste0 (envLayersWorkingDir, dir.slash)

cat ("\n\nenvLayersWorkingDirWithSlash = '",
     envLayersWorkingDirWithSlash, "'\n\n", sep='')

#===============================================================================

#smoothSuitabilitiesWithGaussian  = TRUE
smoothSuitabilitiesWithGaussian  = parameters$smoothSuitabilitiesWithGaussian

#gaussianSuitabilitySmoothingMean = 0
gaussianSuitabilitySmoothingMean = parameters$gaussianSuitabilitySmoothingMean

#gaussianSuitabilitySmoothingSD   = 1
gaussianSuitabilitySmoothingSD   = parameters$gaussianSuitabilitySmoothingSD

#scaleInputs           = TRUE  #  DO NOT CHANGE THIS VALUE FOR NOW.  SEE COMMENT in original code.
scaleInputs           = parameters$scaleInputs  #  DO NOT CHANGE THIS VALUE FOR NOW.  SEE COMMENT in original code.

#dataSrc               = "mattData"    #  Should become a guppy option...
dataSrc               = parameters$dataSrc    #  Should become a guppy option...

#numSpp                        = NA
numSpp                        = parameters$numSpp

#  Matt's suggested weights are recorded at end of following lines...
#  Not using those weights yet.
asciiImgFileNameRoots = parameters$asciiImgFileNameRoots
# asciiImgFileNameRoots = c("aniso_heat",      #  0-1
#                           "evap_jan",  #  0.5
#                           "evap_jul",  #  0.5
#                           "insolation",      #  0-1
#                           "max_temp",  #  0.5
#                           "min_temp",  #  0.5
#                           "modis_evi",  #  0.5
#                           "modis_mir",  #  0.5
#                           "ndmi",  #  0.5
#                           "pottassium",      #  0-1
#                           "raindays_jan",  #  0.5
#                           "raindays_jul",  #  0.5
#                           "rainfall_jan",  #  0.5
#                           "rainfall_jul",  #  0.5
#                           "thorium",      #  0-1
#                           "twi_topocrop",      #  0-1
#                           "vert_major",      #  0-1
#                           "vert_minor",      #  0-1
#                           "vert_saline",      #  0-1
#                           "vis_sky"      #  0-1
#                         )

cat ("\n\nasciiImgFileNameRoots = ")
print (asciiImgFileNameRoots)
cat ("\n\n")

envLayerWeights = parameters$envLayerWeights
cat ("\n\nenvLayerWeights = \n")
print (envLayerWeights)
cat ("\n\nlength (envLayerWeights = ", length (envLayerWeights))
#cat ("\n\nenvLayerWeights[[2]] = \n")
#print (envLayerWeights[[2]])
cat ("\n\n")

    #--------------------------------------------------------------------
    #  Get layer header information.
    #
    #  SAVE BOTH STRING AND NUMERIC VERSIONS OF ASCII FILE HEADER
    #  SO THAT YOU CAN WRITE OUT THE LLCORNER VALUES WITH ALL THE
    #  DECIMAL PLACES THAT WERE ORIGINALLY THERE BUT GET LOST WHEN
    #  TRYING TO WRITE THE FORMATTED NUMBER OUT.  THE STRING IS EASIER.
    #--------------------------------------------------------------------

ascFileHeaderAsNumAndStr =
#    getAscFileHeaderAsNamedList (paste0 (envLayersSrcDir,
    getAscFileHeaderAsNamedList (paste0 (envLayersSrcDir, dir.slash,
                                         asciiImgFileNameRoots [arrayIdxBase],
                                         ".asc"))

cat ("\n\nascFileHeaderAsNumAndStr = \n")
print (ascFileHeaderAsNumAndStr)

ascFileHeaderAsNumVals = ascFileHeaderAsNumAndStr$numValues
ascFileHeaderAsStrVals = ascFileHeaderAsNumAndStr$strValues

    #  Command for formatting the display of a decimal number taken from:
    #  http://stackoverflow.com/questions/3443687/formatting-decimal-places-in-r
cat ("\n\nDisplaying corner values with decimal places:",
    "\n    xllCorner as num = ", format (round (ascFileHeaderAsNumVals$xllCorner, 5), nsmall = 5),
    "\n    yllCorner as num = ", format (round (ascFileHeaderAsNumVals$yllCorner, 5), nsmall = 5),
    "\n    xllCorner as str = ", ascFileHeaderAsStrVals$xllCorner,
    "\n    yllCorner as str = ", ascFileHeaderAsStrVals$yllCorner,
    "\n\n"
    )

#  ***  Need to derive this from the images rather than set it.  ***
numImgRows  = ascFileHeaderAsNumVals$numRows     #  512
numImgCols  = ascFileHeaderAsNumVals$numCols    #  512
numImgCells = numImgRows * numImgCols

cat ("\n\nnumImgRows = ", numImgRows)
cat ("\nnumImgCols = ", numImgCols)
cat ("\nnumImgCells = ", numImgCells)

#-------------------------------------------------------------------------------

#  Values for setting values in .asc headers.
#  These were passed in from Pyper before.
#  Hard coding for now.
#  Need to read them from one of the env files or something.
#  yaml file shows:
# PAR.ascFileNcols: 512
# PAR.ascFileNrows: 512
# PAR.ascFileXllcorner: 2618380.652817
# PAR.ascFileYllcorner: 2529528.47684
# PAR.ascFileCellsize: 75.0
# PAR.ascFileNodataValue: -9999

#llcorner = c (2618380.65282, 2529528.47684)
llcorner = c (ascFileHeaderAsNumVals$xllCorner,
              ascFileHeaderAsNumVals$yllCorner)
cat ("\n\nllcorner = ", llcorner)

#cellsize = 75.0
cellsize = ascFileHeaderAsNumVals$cellSize
cat ("\ncellsize = ", cellsize)

#nodataValue = -9999
nodataValue = ascFileHeaderAsNumVals$noDataValue
cat ("\nnodataValue = ", nodataValue)

#-------------------------------------------------------------------------------

cat ("\n\n")
#stop("\n***  PURPOSELY ENDING TEST PREMATURELY HERE WITH A STOP() CALL.  ***\n\n")


#imgFileType = "asc"
imgFileType = parameters$imgFileType

#numNonEnvDataCols = 0
numNonEnvDataCols = parameters$numNonEnvDataCols

#----------

#envClustersFileNameWithPath= "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/env_clusters.asc"
#clusterFileNameStem = "env_clusters"
clusterFileNameStem = parameters$clusterFileNameStem

##clusterFilePath = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/"
#clusterFilePath = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/"

#clusterFilePath = "/Users/Bill/D/Data/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/"
#clusterFilePath = file.path (userPath, parameters$clusterFilePath)
#####  Using libraries now, so may not need to do this anymore...
#####  BTL - 2014 03 28
#####clusterFilePath = paste0 (userPath, dir.slash, clusterFilePath)

#clusterFilePath = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/LowerLeft/"
#clusterFileNameWithPath = envClustersFileNameWithPath

#----------

#trueProbDistSppFilenameBase = "true.prob.dist.spp."
trueProbDistSppFilenameBase = parameters$trueProbDistSppFilenameBase

#===============================================================================

sppGenOutputDirWithSlash = paste0 (curFullTzarExpOutputDirRootWithSlash,
                                   "SppGenOutputs", dir.slash)

if (file.exists (sppGenOutputDirWithSlash))
    {
    errMsg = paste0 ("\n\n*** In initializeG2options.R: ",
                     "\n*** sppGenOutputDirWithSlash = \n***     ",
                     sppGenOutputDirWithSlash,
                     "\n*** already exists.  ",
                     "\n*** Need to change sppGenOutputDirWithSlash in ",
                     "initializeG2options.R\n\n")
    stop (errMsg)

    } else
    {
    cat ("\n\nsppGenOutputDirWithSlash DOES NOT exist.  ",
         "Creating it.\n\n", sep='')
    dir.create (sppGenOutputDirWithSlash,
                showWarnings = TRUE,
                recursive = TRUE, #  Not sure about this, but it's convenient.
                mode = "0777")    #  Not sure if this is what we want for mode.
    }

#===============================================================================

#  This used to be called curFullMaxentSamplesDirName.
#  I'm trying to get rid of references to maxent in cases where things
#  are not specific just to maxent.
#
#  From Guppy.py initializations and yaml
# self.curFullMaxentSamplesDirName = \
# PARcurrentRunDirectory + self.variables['PAR.maxent.samples.base.name']
# PAR.maxent.samples.base.name:  "MaxentSamples"

fullSppSamplesDirWithSlash = paste0 (curFullTzarExpOutputDirRootWithSlash,
                                     "MaxentSamples", dir.slash)

if (file.exists (fullSppSamplesDirWithSlash))
    {
    errMsg = paste0 ("\n\n*** fullSppSamplesDirWithSlash = \n***     ",
                     fullSppSamplesDirWithSlash,
                     "\n*** already exists.  ",
                     "\n*** Need to change fullSppSamplesDirWithSlash in ",
                     "initializeG2options.R\n\n")
    stop (errMsg)

    } else
    {
    cat ("\n\nfullSppSamplesDirWithSlash DOES NOT exist.  ",
         "Creating it.\n\n", sep='')
    dir.create (fullSppSamplesDirWithSlash,
                showWarnings = TRUE,
                recursive = TRUE, #  Not sure about this, but it's convenient.
                mode = "0777")    #  Not sure if this is what we want for mode.
    }


#self.trueProbDistFilePrefix = self.variables["PAR.trueProbDistFilePrefix"]
#PAR.trueProbDistFilePrefix: "true.prob.dist"
trueProbDistFilePrefix = parameters$trueProbDistFilePrefix

combinedTruePresFilename = paste0 (fullSppSamplesDirWithSlash,    #  cur.full.maxent.samples.dir.name, "/",
                                   "spp.truePres.combined.csv")

combinedSampledPresFilename = paste0 (fullSppSamplesDirWithSlash,
                                      'spp.sampledPres.combined.csv')

#===============================================================================

#useRandomNumTruePresForEachSpp = TRUE    #  variables$PAR.use.random.num.true.presences
useRandomNumTruePresForEachSpp = parameters$useRandomNumTruePresForEachSpp    #  variables$PAR.use.random.num.true.presences

#  self.numSppToCreate = self.variables['PAR.num.spp.to.create']
#numSpp = 28    #  variables$PAR.num.spp.to.create
numSpp = 28    #  variables$PAR.num.spp.to.create

#minTruePresFracOfLandscape = 0.0002    #  0.002    #  variables$PAR.min.true.presence.fraction.of.landscape
minTruePresFracOfLandscape = parameters$minTruePresFracOfLandscape    #  0.002    #  variables$PAR.min.true.presence.fraction.of.landscape

#maxTruePresFracOfLandscape = 0.002     #  0.2      # variables$PAR.max.true.presence.fraction.of.landscape
maxTruePresFracOfLandscape = parameters$maxTruePresFracOfLandscape     #  0.2      # variables$PAR.max.true.presence.fraction.of.landscape

#numTruePresForEachSpp_string = "50,100,75"    #  variables$PAR.num.true.presences
numTruePresForEachSpp_string = parameters$numTruePresForEachSpp_string    #  variables$PAR.num.true.presences

#===============================================================================

#  self.PARuseAllSamples = self.variables['PAR.use.all.samples']
#PARuseAllSamples = FALSE
PARuseAllSamples = parameters$PARuseAllSamples

#===============================================================================

maxentSamplesFileName = combinedSampledPresFilename

    #--------------------
# In guppy.py:
# self.maxentOutputDir = self.qualifiedParams['PAR.maxent.output.dir.name']
# self.maxentOutputDirWithSlash = self.maxentOutputDir + CONST.dirSlash
#
# print "\nself.maxentOutputDir = '" + self.maxentOutputDir + "'"
# createDirIfDoesntExist(self.maxentOutputDir)
# In yaml file:
#         PAR.maxent.output.dir.name: "MaxentOutputs"

#maxentOutputDir = "MaxentOutputs"
fullMaxentOutputDirWithSlash  = paste0 (curFullTzarExpOutputDirRootWithSlash,
                                     "MaxentOutputs", dir.slash)

if (file.exists ( fullMaxentOutputDirWithSlash ))
{
    errMsg = paste0 ("\n\n***  fullMaxentOutputDirWithSlash  = \n***     ",
                      fullMaxentOutputDirWithSlash ,
                     "\n*** already exists.  ",
                     "\n*** Need to change  fullMaxentOutputDirWithSlash  in ",
                     "initializeG2options.R\n\n")
    stop (errMsg)

} else
{
    cat ("\n\n fullMaxentOutputDirWithSlash  DOES NOT exist.  ",
         "Creating it.\n\n", sep='')
    dir.create ( fullMaxentOutputDirWithSlash ,
                showWarnings = TRUE,
                recursive = TRUE, #  Not sure about this, but it's convenient.
                mode = "0777")    #  Not sure if this is what we want for mode.
}

    #--------------------

#  In guppy.py:
# self.doMaxentReplicates = self.variables['PAR.do.maxent.replicates']
# self.numMaxentReplicates = self.variables['PAR.num.maxent.replicates']
# self.maxentReplicateType = self.variables['PAR.maxent.replicateType']

#  In yaml file:
# #        PAR.do.maxent.replicates: TRUE
# PAR.do.maxent.replicates: FALSE
# #        PAR.num.maxent.replicates: 10
# #        PAR.num.maxent.replicates: 3
# PAR.num.maxent.replicates: 5
# #        PAR.maxent.replicateType: bootstrap
# PAR.maxent.replicateType: crossvalidate

#doMaxentReplicates = FALSE
doMaxentReplicates = parameters$doMaxentReplicates

#maxentReplicateType = "crossvalidate"
maxentReplicateType = parameters$maxentReplicateType

#numMaxentReplicates = 5
numMaxentReplicates = parameters$numMaxentReplicates

#===============================================================================

#---------------------------------------------------
#  default value for number of processors in the
#  current machine.
#  maxent can use this value to speed up some
#  of its operations by creating more threads.
#  It's not a necessary thing to set for any other
#  reason.
#---------------------------------------------------

#  self.numProcessors = self.variables['PAR.num.processors']
#numProcessors = 1
numProcessors = parameters$numProcessors

#--------------------

#  self.verboseMaxent = self.variables['PAR.verbose.maxent']
#verboseMaxent = TRUE
verboseMaxent = parameters$verboseMaxent

#===============================================================================

#  In guppy.py:
#  PARpathToMaxent = self.variables['PAR.path.to.maxent']
#        self.maxentFullPathName = self.PARrdvDirectory + CONST.dirSlash + PARpathToMaxent + CONST.dirSlash + 'maxent.jar'
#  self.maxentFullPathName = self.startingDir + "/../.." + CONST.dirSlash + PARpathToMaxent + CONST.dirSlash + 'maxent.jar'

#  In yaml file:
# ###        PAR.path.to.maxent:  "/Users/Bill/D/rdv-framework/lib/maxent"
# #            Assuming you're sitting in rdv-framework/projects/guppy/
# PAR.path.to.maxent:  "lib/maxent"

#maxentFullPathName = "/Users/Bill/D/rdv-framework/lib/maxent/maxent.jar"
#maxentFullPathName = file.path (userPath, parameters$maxentFullPathName)
    #  Changing to get rid of userPath lead-in now that I'm using the 
    #  libraries command in the project.yaml file and it creates a copy 
    #  of maxent.jar in a separate place.
    #  BTL - 2014 03 05.
#####maxentFullPathName = paste0 (userPath, dir.slash, maxentFullPathName)
maxentFullPathName = gsub ("Documents and Settings", "DOCUME~1", maxentFullPathName)

    #--------------------

# ###        curFullMaxentEnvLayersDirName = PARcurrentRunDirectory + self.variables ['PAR.maxent.env.layers.base.name']
# ###        print "\ncurFullMaxentEnvLayersDirName = '" + curFullMaxentEnvLayersDirName + "'"
# ###        createDirIfDoesntExist (curFullMaxentEnvLayersDirName)
#
# #-----------------------------------
#
# #  NOTE the difference between the mac path in R and in python.
# #       In R, you need the backslash in front of the spaces, but in python,
# print "\nvariables ['PAR.useRemoteEnvDir'] = " + str(self.variables['PAR.useRemoteEnvDir'])
# print "variables ['PAR.remoteEnvDir'] = " + self.variables['PAR.remoteEnvDir']
# print "variables ['PAR.localEnvDirMac'] = " + self.variables['PAR.localEnvDirMac']
# print "variables ['PAR.localEnvDirWin'] = " + self.variables['PAR.localEnvDirWin']
#
# #-----------------------------------
#
# ###        if (self.variables ['PAR.useRemoteEnvDir']):
# print "***  self.useRemoteEnvDir = " + str(self.useRemoteEnvDir)
# print "***  self.curOS = " + self.curOS
# if (self.useRemoteEnvDir):
#     self.envLayersDir = self.variables['PAR.remoteEnvDir']
# print "in branch 1"
# elif (self.curOS == CONST.windowsOSname):
#     self.envLayersDir = self.variables['PAR.localEnvDirWin']
# print "in branch 2"
# else:
#     self.envLayersDir = self.variables['PAR.localEnvDirMac']
# print "in branch 3"
# print "\nenvLayersDir = '" + self.envLayersDir + "'"
#
# #-----------------------------------
#
curFullMaxentEnvLayersDirName = envLayersWorkingDirWithSlash

#===============================================================================

#  In guppy.py:
# self.showRawErrorInDist = self.variables['PAR.show.raw.error.in.dist']
# self.showAbsErrorInDist = self.variables['PAR.show.abs.error.in.dist']
# self.showPercentErrorInDist = self.variables['PAR.show.percent.error.in.dist']
# self.showAbsPercentErrorInDist = self.variables['PAR.show.abs.percent.error.in.dist']
# self.showTruncatedPercentErrImg = self.variables['PAR.truncated.percent.err.img']
# self.showHeatmap = self.variables['PAR.show.heatmap']
#  In yaml file:
# PAR.show.abs.error.in.dist: TRUE
# #        PAR.show.percent.error.in.dist: FALSE
# PAR.show.percent.error.in.dist: TRUE
# PAR.show.abs.percent.error.in.dist: TRUE
# #        PAR.truncated.percent.err.img: FALSE
# PAR.truncated.percent.err.img: TRUE
# PAR.show.heatmap: FALSE
# #        PAR.show.heatmap: TRUE
# #        PAR.show.raw.error.in.dist: FALSE
# PAR.show.raw.error.in.dist: TRUE
# PAR.use.all.samples: FALSE

#showRawErrorInDist = TRUE
showRawErrorInDist = parameters$showRawErrorInDist

#showAbsErrorInDist =  TRUE
showAbsErrorInDist =  parameters$showAbsErrorInDist

#showPercentErrorInDist =  TRUE
showPercentErrorInDist =  parameters$showPercentErrorInDist

#showAbsPercentErrorInDist =  TRUE
showAbsPercentErrorInDist =  parameters$showAbsPercentErrorInDist

#showTruncatedPercentErrImg =  TRUE
showTruncatedPercentErrImg =  parameters$showTruncatedPercentErrImg

#showHeatmap = FALSE
showHeatmap = parameters$showHeatmap

#--------------------

#  In guppy.py:
# self.analysisDirWithSlash = PARcurrentRunDirectory + self.variables['PAR.analysis.dir.name'] + CONST.dirSlash
# print "\nself.analysisDirWithSlash = '" + self.analysisDirWithSlash + "'"
# createDirIfDoesntExist(self.analysisDirWithSlash)
#  In yaml file:
# PAR.analysis.dir.name: "ResultsAnalysis"

fullAnalysisDirWithSlash  = paste0 (curFullTzarExpOutputDirRootWithSlash,
                                        "ResultsAnalysis", dir.slash)

if (file.exists ( fullAnalysisDirWithSlash ))
    {
    errMsg = paste0 ("\n\n***  fullAnalysisDirWithSlash  = \n***     ",
                     fullAnalysisDirWithSlash ,
                     "\n*** already exists.  ",
                     "\n*** Need to change  fullAnalysisDirWithSlash  in ",
                     "initializeG2options.R\n\n")
    stop (errMsg)

    } else
    {
    cat ("\n\n fullAnalysisDirWithSlash  DOES NOT exist.  ",
         "Creating it.\n\n", sep='')
    dir.create ( fullAnalysisDirWithSlash ,
                 showWarnings = TRUE,
                 recursive = TRUE, #  Not sure about this, but it's convenient.
                 mode = "0777")    #  Not sure if this is what we want for mode.
    }

#--------------------

#  In guppy.py:
#  self.PARuseOldMaxentOutputForInput = self.variables['PAR.use.old.maxent.output.for.input']
#UseOldMaxentOutputForInput = PARuseOldMaxentOutputForInput
#  In yaml file:
#     PAR.use.old.maxent.output.for.input: FALSE
# ##        PAR.old.maxent.output.dir: "/Users/bill/tzar/outputdata/Guppy_Scen_1_4/MaxentOutputs/"
#useOldMaxentOutputForInput = FALSE
useOldMaxentOutputForInput = parameters$useOldMaxentOutputForInput

#  In yaml file:
# PAR.write.to.file: FALSE
# PAR.use.draw.image: FALSE
#writeToFile = FALSE
writeToFile = parameters$writeToFile

#useDrawImage = FALSE
useDrawImage = parameters$useDrawImage

#===============================================================================

    #  Zonation options.

runZonation = parameters$runZonation

if (runZonation)
    {
#     if (regexpr ("darwin*", current.os) != -1)
#         {
#         stop (paste0 ("\n\n=====>  Can't run zonation on Mac yet since wine doesn't work properly yet.",
#                       "\n=====>  Quitting now.\n\n"))
#         }

###    zonationFilesDir = parameters$zonationFilesDirName
#    zonationFilesDirWithSlash = paste0 (zonationFilesDir, "/")

        #  Kluge to deal with lots of Windows problems running zonation
        #  using file names with embedded spaces.
        #  So far, they're all due to the "Documents and Settings" directory,
        #  so I'll deal with that.  In the Windows terminal window you can
        #  ask Windows for a no-spaces version of the name of a directory
        #  by using the -x option on dir, e.g., sitting above the
        #  "Documents and Settings" in C: and giving the command "dir /x", will
        #  list the shortened names of all the files and directories there,
        #  including "DOCUME~1 for "Documents and Settings".
        #  I think that these problems may primarily be coming from the use of
        #  the Windows environment variable called HOMEPATH to determine
        #  where to hang the temporary output directories.  I suspect that
        #  is what tzar is doing.  If we could get tzar to fix it up right
        #  when it's created, then none of this would be necessary here.
        #  Note, I found HOMEPATH by running the SET command with no arguments
        #  to see all declared variables in the environment, because a web site
        #  had mentioned that the similarly troublesome directory called
        #  "Program Files" has a name stored in the environment that you can
        #  use to avoid these space-based problems.

    fullPathToZonationFilesDir = gsub ("Documents and Settings", "DOCUME~1", fullPathToZonationFilesDir)

    cat ("\nfullPathToZonationFilesDir = '", fullPathToZonationFilesDir, "'", sep='')    
    
    if ( !file.exists (fullPathToZonationFilesDir))  dir.create (fullPathToZonationFilesDir)

        #  2014 02 19 - NOT SURE IF THIS SHOULD BE SET TO fullMaxentOutputDirWithSlash
        #               OR SOMETHING ELSE.  NEED TO SEE WHERE IT'S USED AND SEE IF
        #               SOMETHING IS BUILDING OFF SOMETHING LESS THAN THE FULL PATH.
        #       This may be a problem if you want to use something other than the
        #       maxent output as the zonation input !!!
    zonationAppInputMapsDir = fullMaxentOutputDirWithSlash
    zonationCorInputMapsDir = sppGenOutputDirWithSlash

        #  2014 02 19 - THIS NEEDS TO LINK UP WITH THE RESULTS OF COMPUTING THE
        #               NUMBER OF SPECIES BASED ON THE NUMBER OF CLUSTERS.
        #               PROBABLY MEANS THAT IT HAS TO BE SET JUST BEFORE ZONATION
        #               RUNNING SECTION IN G2, i.e., num.spp.in.reserve = numSpp...
        #               Should have the leading path?
    numSppInReserveSelection = parameters$numSppInReserveSelection
    sppUsedInReserveSelectionVector = 1:numSppInReserveSelection

    zonationAppSppListFilename = parameters$zonationAppSppListFilename
    zonationAppOutputFilename = parameters$zonationAppOutputFilename

    zonationCorSppListFilename = parameters$zonationCorSppListFilename
    zonationCorOutputFilename = parameters$zonationCorOutputFilename

#    fullPathToZonationParameterFile = file.path (userPath, parameters$fullPathToZonationParameterFile)
    #  Changing to get rid of userPath lead-in now that I'm using the 
    #  libraries command in the project.yaml file and it creates a copy 
    #  of zonation parameters file in a separate place.
    #  BTL - 2014 03 05.
    #####fullPathToZonationParameterFile = paste0 (userPath, dir.slash, fullPathToZonationParameterFile)
    fullPathToZonationParameterFile = gsub ("Documents and Settings", "DOCUME~1", fullPathToZonationParameterFile)


#    fullPathToZonationExe = file.path (userPath, parameters$fullPathToZonationExe)
    #  Changing to get rid of userPath lead-in now that I'm using the 
    #  libraries command in the project.yaml file and it creates a copy 
    #  of zonation parameters file in a separate place.
    #  BTL - 2014 03 05.
    #####fullPathToZonationExe = paste0 (userPath, dir.slash, fullPathToZonationExe)
    fullPathToZonationExe = gsub ("Documents and Settings", "DOCUME~1", fullPathToZonationExe)

    closeZonationWindowOnCompletion = parameters$closeZonationWindowOnCompletion

    sppFilePrefix = parameters$sppFilePrefix
    }

#stop ("\n***  END TEST SETUP  ***\n\n")

#===============================================================================

