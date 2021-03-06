#===============================================================================

                        #  biodivprobgen_utilities.R

#===============================================================================

#  2015 04 27 - BTL
#       Created by extracting functions from generateSetCoverProblem.R.

#===============================================================================

    #  2015 04 08 - BTL
    #  I just got bitten very badly by the incredibly annoying behavior of R's 
    #  sample() function, so here is a replacement function that I need to 
    #  use everywhere now.
    #  When I called sample with a vector that sometimes had length n=1, 
    #  it sampled from 1:n instead of returning the single value.  
    #  This majorly screwed all kinds of things in a very subtle, very hard 
    #  to find way.

safe_sample = function (x,...) { if (length (x) == 1) x else sample (x,...) } 

#===============================================================================

    #  This function is used two different ways.
    #  It's called when the program quits because there are too many species 
    #  or it's called when the program runs successfully.  
    #  It's declared here because you don't know which path the program 
    #  will take.
    #  It should go in a file of misc utilities, but it might be the only 
    #  thing in that file at the moment.

write_results_to_files = function (results_df, parameters)
    {    
        #  Write the results out to 2 separate and nearly identical files.
        #  The only difference between the two files is that the run ID in 
        #  one of them is always set to 0 and in the other, it's the correct 
        #  current run ID.  This is done to make it easier to automatically 
        #  compare the output csv files of different runs when the only thing 
        #  that should be different between the two runs is the run ID.  
        #  Having different run IDs causes diff or any similar comparison to 
        #  think that the run outputs don't match.  If they both have 0 run ID, 
        #  then diff's output will correctly flag whether there are differences 
        #  in the outputs.
    
    results_df$run_ID [cur_result_row] = 0
    write.csv (results_df, file = parameters$summary_without_run_id_filename, row.names = FALSE)
    
    results_df$run_ID [cur_result_row] = parameters$run_id
    write.csv (results_df, file = parameters$summary_filename, row.names = FALSE)
    }

#===============================================================================

get_PU_costs = function (num_PUs) { return (rep (1, num_PUs)) }

#===============================================================================

    #  Note that you can only uniquely decode an edge list from an occurrence 
    #  matrix if the species only occurs on 2 patches, i.e., the underlying 
    #  assumption in the Xu problem generator.  
    #  However, the only reason I'm building this routine now is to run it 
    #  on the Xu benchmark problems to see if those allow any duplicate 
    #  edges, i.e., more than one species occurring on the same pair of 
    #  patches.

see_if_there_are_any_duplicate_links = function (occ_matrix, num_spp)
    {
    num_PU_spp_pairs = sum (occ_matrix)
    
    edge_list = matrix (0, 
                        nrow = num_spp, 
                        ncol = 2, 
                        byrow = TRUE)
    
    colnames (edge_list) = c("from_node", "to_node")

    num_spp_warnings = 0
    num_spp_on_no_patches = 0
    rows_to_delete = list()
    
    for (cur_spp_row in 1:num_spp)
        {
        cur_spp_occurs_on_patches = which (occ_matrix [cur_spp_row,] == 1)
        num_patches_for_cur_spp = length (cur_spp_occurs_on_patches)
        
        if ((num_patches_for_cur_spp != 2) & (num_patches_for_cur_spp != 0))
            {
            num_spp_warnings = num_spp_warnings + 1
            cat ("\nWARNING ", num_spp_warnings, ": spp ", cur_spp_row, " is on ", 
                 num_patches_for_cur_spp, " patches, PU_IDs ", sep='')
            print (cur_spp_occurs_on_patches)
            rows_to_delete [[length (rows_to_delete) + 1]] = cur_spp_row
            
            } else
            {
            if (num_patches_for_cur_spp == 0)
                {
                num_spp_on_no_patches = num_spp_on_no_patches + 1
                rows_to_delete [[length (rows_to_delete) + 1]] = cur_spp_row
                
                } else
                {            
                edge_list [cur_spp_row, "from_node"] = cur_spp_occurs_on_patches [1]
                edge_list [cur_spp_row, "to_node"] = cur_spp_occurs_on_patches [2]
                
                }  #  end else - spp is on exactly 2 patches                 
            }  #  end else - spp is on either 0 or 2 patches        
        }  #  end for - all spp rows

    if (num_spp_warnings > 0)
        cat ("\n----->  num_spp_warnings = ", num_spp_warnings, sep='')
    
    if (num_spp_on_no_patches > 0)
        {
        cat ("\n----->  num_spp_on_no_patches = ", num_spp_on_no_patches, sep='')
        }
    
    if (length (rows_to_delete) > 0)
        {
        rows_to_delete = unlist (rows_to_delete)
        cat ("\n----->  rows_to_delete = ", sep='')
        print (rows_to_delete)
        
        edge_list = edge_list [- rows_to_delete,,drop=FALSE]
        }
    
    row_nums_of_duplicates = which (duplicated (edge_list))
    num_duplicates = length (row_nums_of_duplicates)
    cat ("\n\nindices (duplicates) = ", row_nums_of_duplicates, "\n")
    cat ("\nduplicates = \n")
    print (edge_list[row_nums_of_duplicates,,drop=FALSE])
    cat ("\n\nnumber of duplicates = ", num_duplicates, "\n", sep='')
    
    if (num_duplicates > 0)
        {
        cat ("\n\nERROR: ", num_duplicates, 
             " duplicate species in the Xu benchmark file.\n\n")
        
        quit (save="no", ERROR_STATUS_duplicate_spp_in_Xu_input_file)
        }
    
    return (edge_list)
    }

#-------------------------------------------------------------------------------

test_see_if_there_are_any_duplicate_links = function ()
    {
    num_PUs = 4
    num_spp = 11

    #--------------------
        
        #  Test the kind of matrix you expect to see, i.e., 
        #  all lines legal in the matrix...
#     spp_occ_matrix = matrix (c(0,1,1,0,
#                     0,1,0,1, 
#                     1,1,0,0), nrow=num_spp, ncol=num_PUs, byrow=TRUE)

    #-------
    
        #  Test generation of warnings.
        #  One bad line (too many 1s) and one line with no occupancy.
    spp_occ_matrix = matrix (c(0,1,1,1,  #  more than 2 patches occupied
                    0,1,0,1,  #  dup 1 
                    0,0,0,0,  #  no patches occupied 
                    1,0,0,1,
                    1,1,0,0,  #  dup 2
                    0,1,0,1,  #  dup 1
                    0,1,0,1,  #  dup 1
                    0,1,1,0,
                    0,0,1,1,
                    1,0,1,0,
                    1,1,0,0   #  dup 2                    
                    ), nrow=num_spp, ncol=num_PUs, byrow=TRUE)

    #--------------------
    
    cat ("\n\nIn test_build_edge_list_from_occ_matrix() before start of test.")
    cat ("\nspp_occ_matrix = \n")
    print (spp_occ_matrix)
   
    #--------------------
    
    edge_list = build_edge_list_from_occ_matrix (spp_occ_matrix, num_spp)
    
    cat ("\n\nedge_list from spp_occ_matrix = \n")
    print (edge_list)

    unique_edge_list = unique (edge_list)
    cat ("\n\nunique_edge_list = \n")
    print (unique_edge_list)
    cat ("\n")
    }

if (TESTING) test_build_edge_list_from_occ_matrix ()

#===============================================================================

build_PU_spp_pair_indices_from_occ_matrix = function (occ_matrix, 
                                                      num_PUs, num_spp)
    {
    num_PU_spp_pairs = sum (occ_matrix)
    
        #****************************************************************
        #  Why is PU_spp_pair_indices a data frame instead of a matrix?
        #****************************************************************
    
    PU_spp_pair_indices = data.frame (PU_ID = rep (NA, num_PU_spp_pairs),
                                      spp_ID = rep (NA, num_PU_spp_pairs))

    cur_PU_spp_row_idx = 0

    for (cur_spp_row in 1:num_spp)
        {
        for (cur_PU_col in 1:num_PUs)
            {
            if (occ_matrix [cur_spp_row, cur_PU_col])
                {
                cur_PU_spp_row_idx = cur_PU_spp_row_idx + 1
                
                PU_spp_pair_indices [cur_PU_spp_row_idx, "PU_ID"] = cur_PU_col
                PU_spp_pair_indices [cur_PU_spp_row_idx, "spp_ID"] = cur_spp_row
                
                }  #  end if - cur spp occupies cur PU
            }  #  end for - all PU cols
        }  #  end for - all soo rows

    return (PU_spp_pair_indices)
    }

#-------------------------------------------------------------------------------

test_build_PU_spp_pair_indices_from_occ_matrix = function ()
    {
    num_PUs = 3
    num_spp = 2

    #--------------------
        
    spp_occ_matrix = matrix (c(0,1,1,
                    0,1,0), nrow=num_spp, ncol=num_PUs, byrow=TRUE)
    cat ("\n\nIn test_build_PU_spp_pair_indices_from_occ_matrix() before start of test.")
    cat ("\nspp_occ_matrix = \n")
    print (spp_occ_matrix)
    
    #--------------------
    
    PU_spp_pair_indices = 
            build_PU_spp_pair_indices_from_occ_matrix (spp_occ_matrix, num_PUs, num_spp)
    
    cat ("\n\nPU_spp_pair_indices from spp_occ_matrix = \n")
    print (PU_spp_pair_indices)
    cat ("\n\nShould look like:\n\t1      2\n\t1      3\n\t2      2\n")
    }

if (TESTING) test_build_PU_spp_pair_indices_from_occ_matrix ()

#===============================================================================
#     Compute what fraction of species meet their representation targets.
#===============================================================================

find_indices_of_spp_with_unmet_rep = function (spp_occ_matrix, 
                                               candidate_solution_PU_IDs, 
                                               num_spp, 
                                               DEBUG_LEVEL, 
                                               spp_rep_targets
                                               ) 
    {
    spp_rep_fracs = compute_rep_fraction (spp_occ_matrix, 
                                          candidate_solution_PU_IDs, 
                                          DEBUG_LEVEL, 
                                          spp_rep_targets
                                          )
    
    return (which (spp_rep_fracs < 1))
    }

#-------------------------------------------------------------------------------

compute_frac_spp_covered = 
        function (spp_occ_matrix, 
                  candidate_solution_PU_IDs, 
                  num_spp, 
                  spp_rep_targets
                  ) 
    {
    indices_of_spp_with_unmet_rep = 
        find_indices_of_spp_with_unmet_rep (spp_occ_matrix, 
                                            candidate_solution_PU_IDs, 
                                            num_spp, 
                                            DEBUG_LEVEL, 
                                            spp_rep_targets
                                            ) 

    return (1 - (length (indices_of_spp_with_unmet_rep) / num_spp))
    }

#===============================================================================

    #  When error is added to the input data, it sometimes results in 
    #  planning units who appear to have no species on them.  
    #  When the pu_spp_pair_indices are written out in marxan's input 
    #  format, there is no record of the empty planning units in those 
    #  pairs since each pair is a planning unit ID followed by the ID 
    #  of a species on that planning unit. 
    #  Consequently, marxan's output solutions will have fewer planning 
    #  units than the problem generator generated and you will get size
    #  warnings (that should be errors) when comparing them to things 
    #  like nodes$dependent_set_member.
    #  For example, here is the error that showed this was happening:
    #
    #       Error in marxan_best_df_sorted$SOLUTION - nodes$dependent_set_member : 
    #       (converted from warning) longer object length is not a multiple of shorter object length
    #
    #  To fix this, you need to add entries for each of the missing PUs.
    
add_missing_PUs_to_marxan_solutions = function (marxan_solution,
                                                all_correct_node_IDs, 
                                                PU_col_name,
                                                presences_col_name)
    {
        #  Marxan solutions are data frames with one row for each planning unit.
        #  They have 2 columns, one for the planning unit IDs and the other 
        #  for the count or indicator of presence/absence.
        #  The second column usually contains 0 or 1 to indicate presence 
        #  or absence of that PU in the marxan solution.
        #  However, in the case of marxan's summed solution, the second  
        #  column contains the number of iterations (restarts) where that  
        #  planning unit appeared in marxan's solution.
        #
        #  Search for the missing planning unit IDs, then add one line 
        #  to the table for each missing planning unit ID.
        #  Set the presences field for each of those lines to be 0.
    
    missing_PU_IDs = setdiff (all_correct_node_IDs, marxan_solution [ , PU_col_name])
    num_missing_PU_IDs = length (missing_PU_IDs)
    
    if (num_missing_PU_IDs > 0)
        {
        missing_rows = matrix (c(missing_PU_IDs, rep(0,num_missing_PU_IDs)), 
                               nrow=num_missing_PU_IDs,
                               ncol=2,
                               dimnames=list(NULL,c(PU_col_name,presences_col_name)))
        
        marxan_solution = rbind (marxan_solution, missing_rows)
        }
                                           
    return (marxan_solution)                  
    }

#===============================================================================

