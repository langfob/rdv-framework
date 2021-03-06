# Does all the file copying then
# Runs zonation 

# source( 'scp-collab.run.zonation.R' )

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------


rm( list = ls( all=TRUE ))

source( 'variables.R'     )

cat( '\n----------------------------------' )
cat( '\n  run.zonation.scp-collab.R       ' )
cat( '\n----------------------------------' )

# First get the OS
#   for linux this returns linux-gnu
#   for mac this returns darwin9.8.0
#   for windos this returns mingw32

current.os <- sessionInfo()$R.version$os

spp.used.in.reserve.selection.vector <- 1:PAR.num.spp.in.reserve.selection

source.dir <- getwd()

cat( "\n The path to the run dir is", PAR.current.run.directory )
cat( "\n The path back to the source tree is ", source.dir)

    #--------------------------------------------
    # Copy the Zonation data file to the output dir
    #--------------------------------------------

copy.single.zonation.settings.files <- function( from.filename ) {

  # This function copies the default zonation settings file from its
  # location in the rdv-framework sourcecode to the output directory
  # for use with running zonation.

  # Full path to file in the rdv-framework sourcecode
  full.from.filename <- paste( PAR.path.to.zonation, '/', from.filename, sep = '' )

  # Full path to desitnation 
  Z.settings.file.full.path <- paste(  PAR.current.run.directory, '/',  from.filename, sep = '' )

  # Copy the file
  if( !file.copy( full.from.filename, Z.settings.file.full.path, overwrite = TRUE ) ) {
    cat( '\nCould not copy',from.filename, 'to', Z.settings.file.full.path, '\n' )
    stop( '\nAborted due to error.', call. = FALSE )
  }

  # Return the fullpath to the file
  return( Z.settings.file.full.path )
}

Z.settings.file.full.path <- copy.single.zonation.settings.files( PAR.zonation.parameter.filename )


    #--------------------------------------------
    # Generate the species list file for zonation 
    #--------------------------------------------

zonation.spp.list.full.filename <- paste( PAR.current.run.directory, '/',
                                         PAR.zonation.spp.list.filename, sep ='' )
# delete old one if already there
if(file.exists(zonation.spp.list.full.filename)) file.remove( zonation.spp.list.full.filename ) 

zonation.spp.list.full.filename

downloaded.input.data.dir <- paste( PAR.current.run.directory, '/', PAR.path.to.spp.hab.map.files.downloaded, sep='')
# file.list <- dir( PAR.path.to.spp.hab.map.files, pattern="^m" ) # old - used for local copy
file.list <- dir( downloaded.input.data.dir, pattern="^m" )
# The pattern="^m" is regex for files starting with m. This is needed
# as all spp maps start with "m", and want to exclude the admin map
# which starts with "a"

# Now dynamicly create the Zonation file: zonation_spp_list.dat
for( cur.spp.id in spp.used.in.reserve.selection.vector ) {

  # path.to.file <- paste( source.dir, '/', PAR.path.to.spp.hab.map.files, sep='') # old - used for local copy
  path.to.file <- PAR.path.to.spp.hab.map.files.downloaded
  # If runnig on a windows system, replace the "/" with "\" (need to test that this wrokd as expected!!)
  if( current.os == 'mingw32' ) path.to.file <- gsub("/", "\\\\", path.to.file )
  
  line.of.text <- paste( "1.0 1.0 1 1 1 ", paste(path.to.file, file.list[cur.spp.id],sep=''), "\n", sep='' )
  cat( line.of.text, file = zonation.spp.list.full.filename, append = TRUE )
  
}


    #--------------------------------------------
    # If using admin units, generate the admin input files
    #--------------------------------------------

if( PAR.use.administrative.units ){


  # If we have permuted the admin units to form coalitions, then use
  # this new admin units map for zontation
  if( PAR.permute.admin.regions )
    admin.regions.map <- paste(PAR.remapped.admin.regions.map.filename.base,'.asc', sep='')
  else
    # admin.regions.map <- PAR.admin.regions.map
    admin.regions.map <- PAR.admin.regions.map.downloaded
  
  # Administrative units description file
  cat ( '#ID    G_A    beta_A    name\n' , file = PAR.zonation.admu.desc.file, append = TRUE );
  for( i in 1:PAR.num.admin.units ) {
    line.of.text2 <- paste ( i, '    1    1    ',  'R', i, '\n', sep='' )
    cat( line.of.text2, file = PAR.zonation.admu.desc.file, append = TRUE );
  }

  # Administrative units weights matrix file
  for( i in 1:PAR.num.spp.in.reserve.selection) {
    cat( rep( 1, PAR.num.admin.units), '\n', file = PAR.zonation.admu.weights.matrix.file, append = TRUE )
  }
  
  # Add the extra admin units settings to the Zonation parameter file

  string <- paste( 
                  '[Administrative units]', '\n',
                  'use ADMUs = 1', '\n',
                  'ADMU descriptions file = ADMU_desc.txt', '\n',
                  'ADMU layer file = ', admin.regions.map, '\n',
                  'ADMU weight matrix = ADMU_weights_matrix.txt', '\n', 
                  'calculate local weights from condition = 1', '\n',
                  'ADMU mode = 2', '\n',
                  'Mode 2 global weight = ', PAR.admin.units.global.weight, '\n', sep=''
                  )
  
  cat( string, file = Z.settings.file.full.path, append = TRUE )

}


    #--------------------------------------------
    # Now try and run zonation
    #--------------------------------------------

full.path.to.zonation.exe <- paste( source.dir, '/', PAR.path.to.zonation,  '/',
                                   PAR.zonation.exe.filename, sep = '')

cat( '\n\n full.path.to.zonation.exe=', full.path.to.zonation.exe )


setwd( PAR.current.run.directory )

if( current.os == 'mingw32' ) {  
  system.specific.cmd <- ''
} else {
  system.specific.cmd <- 'wine'
}

system.command.run.zonation <- paste( system.specific.cmd, full.path.to.zonation.exe, '-r',
                                     PAR.zonation.parameter.filename,
                                     PAR.zonation.spp.list.filename,
                                     PAR.Z.output.prefix,
                                     "0.0 0 1.0 1" ) 

system.command <- paste( system.specific.cmd )
system.command.arguments <- paste( full.path.to.zonation.exe, '-r',
                                   PAR.zonation.parameter.filename,
                                   PAR.zonation.spp.list.filename,
                                   PAR.Z.output.prefix,
                                   "0.0 0 1.0 1" ) 


cat( '\n\nThe system command to run zonation (1st time) is',  system.command.run.zonation )

#system( system.command.run.zonation )      
system2( system.command, args=system.command.arguments, env="DISPLAY=:1" )      

cat( '\nFinsihed running Zonation the first time' )

    #--------------------------------------------
    # If running with Administrative units run zonation again to
    # loading previously calculated solution based on
    # ADMU.redistributed.rank.asc solution. The *.curves.txt file when
    # running with admin units is not based on this file (see p 136 of Z
    # manual v3.1)
    #--------------------------------------------

if( PAR.use.administrative.units ){

  # The second copy of the settings files is needed for reloading the
  # admin units solution. There is a bug in zonation where where you need
  # to set "Edge removal" to zero when reloading a solution otherwise it
  # crashes http://consplan.it.helsinki.fi/software/issues/27
  setwd(source.dir)
  copy.single.zonation.settings.files( PAR.zonation.reload.parameter.filename )
  setwd( PAR.current.run.directory )
  
  
  reload.output.name <- paste( PAR.Z.output.prefix, PAR.Z.reloaded.output.suffix, sep = '')
  
  system.command.run.zonation2 <- paste( system.specific.cmd,
                                    full.path.to.zonation.exe,
                                    paste( '-l',PAR.Z.output.prefix,'.ADMU.redistributed.rank.asc', sep=''),
                                    #'-lz_output.ADMU.redistributed.rank.asc',
                                    PAR.zonation.reload.parameter.filename,
                                    PAR.zonation.spp.list.filename,
                                    reload.output.name,
                                    "0.0 0 1.0 1" )
  
  system.command <- paste( system.specific.cmd)
  system.command.arguments <-  paste( full.path.to.zonation.exe,
                                    paste( '-l',PAR.Z.output.prefix,'.ADMU.redistributed.rank.asc', sep=''),
                                    #'-lz_output.ADMU.redistributed.rank.asc',
                                    PAR.zonation.reload.parameter.filename,
                                    PAR.zonation.spp.list.filename,
                                    reload.output.name,
                                    "0.0 0 1.0 1" )

  cat( '\nThe system command to run zonation (2nd time) is',  system.command.run.zonation2 )
  #system( system.command.run.zonation2 )
  system2( system.command, args=system.command.arguments, env="DISPLAY=:1" )
  cat( '\nFinsihed running Zonation the second time' )
  
  # as admin units were used, want to copy the curves file from
  # reloading the redistributed.rank.asc to be the final .curves.txt
  # file.

  file.copy( paste(reload.output.name,'.curves.txt', sep=''), PAR.final.Z.curves.filename )
  
} else {

  # in this case no admin units were used so copy the .curves.txt file
  # to be the final output curves file.
  file.copy( paste(PAR.Z.output.prefix,'.curves.txt', sep=''), PAR.final.Z.curves.filename )

}

cat( '\n\n ==> Finished running Zonation' ) 
