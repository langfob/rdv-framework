#===============================================================================

                        #  biodivprobgen_initialization.R

#===============================================================================

#  2015 04 27 - BTL
#       Created by extracting code from generateSetCoverProblem.R.

#===============================================================================

cat ("\n\nSTARTING at ", date(), "\n\n")

#===============================================================================

    #  debugging level: 0 means don't output debugging write statements.
    #  Having this as an integer instead of binary so that I can have 
    #  multiple levels of detail if I want to.
DEBUG_LEVEL = 0

    #  Default to not running any test code.
TESTING = FALSE

    #  Turn all R warnings into errors.
options (warn=2)

    #  Values to return from the program when quit() is called on a serious
    #  error.
ERROR_STATUS_num_inside_or_within_group_links_less_than_one = 1001
ERROR_STATUS_optimal_solution_is_not_optimal = 1002
ERROR_STATUS_num_nodes_per_group_must_be_at_least_2 = 1003
ERROR_STATUS_duplicate_spp_in_Xu_input_file = 1004
ERROR_STATUS_unknown_spp_occ_FP_error_type = 1005
ERROR_STATUS_unknown_spp_occ_FN_error_type = 1006

#===============================================================================

    #  2014 12 29 - BTL
    #  At this point, this flag will probably almost never change again 
    #  because my code is relying on the parameters list that tzar builds 
    #  and it would be too big of a pain in the ass to build the parameters 
    #  structure myself, as would be required if NOT running under tzar or 
    #  tzar emulation.  However, I have made it possible to do that using 
    #  the function called local_build_parameters_list() in 
    #  gscp_3_get_parameters.R.  That is mostly aimed at later use though, 
    #  e.g., if the source code is distributed to someone else and they 
    #  don't want to use tzar or tzar emulation.

running_tzar_or_tzar_emulator = TRUE

    #  Need to set emulation flag every time you swap between emulating 
    #  and not emulating.  
    #  This is the only variable you should need to set for that.
    #  Make the change in the file called emulatingTzarFlag.R so that 
    #  every file that needs to know the value of this flag is using 
    #  the synchronized to the same value.

        #  2014 12 29 - BTL 
        #  Moving this to the top level code so that it's easier to see and 
        #  control.

source (paste0 (sourceCodeLocationWithSlash, "emulatingTzarFlag.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_2_tzar_emulation.R"))

#===============================================================================

library (plyr)    #  For count() and arrange()
library (marxan)

#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "biodivprobgen_utilities.R"))
        
#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "gscp_3_get_parameters.R"))

#===============================================================================

    #  The rest of this code has to come after tzar or someone else has 
    #  created the "parameters" object.

#===============================================================================

seed = parameters$seed
set.seed (seed)

#---------------------------------------------------------------    
    #  Determine the OS so you can assign the correct name for 
    #  the marxan executable, etc.
    #   - for linux this returns linux-gnu
    #   - for mac this currently returns os = 'darwin13.4.0'
    #   - for windows this returns mingw32

current_os <- sessionInfo()$R.version$os
cat ("\n\nos = '", current_os, "'\n", sep='')

#---------------------------------------------------------------    

cat ("\n\n", parameters$runset_description, "\n\n")

#---------------------------------------------------------------    

plot_output_dir = paste0 (parameters$fullOutputDirWithSlash, "Plots")
dir.create (plot_output_dir, 
            showWarnings = TRUE, 
            recursive = FALSE)

network_output_dir = paste0 (parameters$fullOutputDirWithSlash, "Networks")
dir.create (network_output_dir, 
            showWarnings = TRUE, 
            recursive = FALSE)

# result_tables_output_dir = paste0 (parameters$fullOutputDirWithSlash, "Results")
# dir.create (result_tables_output_dir, 
#             showWarnings = TRUE, 
#             recursive = FALSE)

marxan_IO_dir = paste0 (parameters$fullOutputDirWithSlash, "Marxan_IO")
dir.create (marxan_IO_dir, 
            showWarnings = TRUE, 
            recursive = FALSE)

marxan_input_dir = paste0 (marxan_IO_dir, .Platform$file.sep, "input")
dir.create (marxan_input_dir, 
            showWarnings = TRUE, 
            recursive = FALSE)

marxan_output_dir = paste0 (marxan_IO_dir, .Platform$file.sep, "output")
dir.create (marxan_output_dir, 
            showWarnings = TRUE, 
            recursive = FALSE)

#===============================================================================

default_integerize_string = "round"
integerize_string = default_integerize_string

integerize_string = parameters$integerize_string

#integerize_string = "round"
#integerize_string = "ceiling"
#integerize_string = "floor"

integerize = switch (integerize_string, 
                     round=round, 
                     ceiling=ceiling, 
                     floor=floor, 
                     round)    #  default to round()

# integerize = function (x) 
#     { 
#     round (x) 
# #    ceiling (x)
# #    floor (x)
#     }

#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "timepoints.R"))

#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "load_and_parse_Xu_set_cover_problem_file.R"))

#-------------------------------------------------------------------------------

#  Replaced 9b with the code below.
#source (paste0 (sourceCodeLocationWithSlash, "gscp_9b_convert_Xu_graph_to_spp_PU_problem.R"))

source (paste0 (sourceCodeLocationWithSlash, "gscp_6_create_data_structures.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_8_link_nodes_within_groups.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_9_link_nodes_between_groups.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_9a_create_Xu_graph.R"))

#-------------------------------------------------------------------------------

source (paste0 (sourceCodeLocationWithSlash, "gscp_10a_clean_up_completed_graph_structures.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_10b_compute_solution_rep_levels_and_costs.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_10c_build_adj_and_cooccurrence_matrices.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_11_summarize_and_plot_graph_structure_information.R"))

#-------------------------------------------------------------------------------

source (paste0 (sourceCodeLocationWithSlash, "add_error_to_spp_occupancy_data.R"))

#-------------------------------------------------------------------------------

source (paste0 (sourceCodeLocationWithSlash, "gscp_11aa_write_abbreviated_results_to_files.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_11a_network_measures_using_bipartite_package.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_12_write_network_to_marxan_files.R"))

#-------------------------------------------------------------------------------

source (paste0 (sourceCodeLocationWithSlash, "compute_solution_scores.R"))

#===============================================================================


