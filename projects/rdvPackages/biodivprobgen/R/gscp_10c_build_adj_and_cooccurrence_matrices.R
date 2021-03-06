#===============================================================================

                #  gscp_10c_build_adj_and_cooccurrence_matrices.R

#===============================================================================

#  History:

#  2015 02 19 - BTL
#       Created by cutting creation of adj matrix out of 
#       gscp_11a_network_measures_using_bipartite_package.R.

#===============================================================================
#       Verify that the generated optimal solution really is a solution.
#===============================================================================

    #  Theoretically, this should not be necessary, but checking it here to 
    #  make sure that the implementation is working correctly.
    #  Correct solutions will have every species attaining a representation 
    #  fraction of their target of at least 1 (where 1 means exactly meeting 
    #  their target).

verify_that_generated_solution_really_is_a_solution = 
        function (bpm, 
                  dependent_node_IDs, 
                  num_spp, 
                  num_PUs, 
                  ERROR_STATUS_optimal_solution_is_not_optimal, 
                  emulatingTzar = FALSE
                  ) 
    {
    spp_rep_targets = rep (1, num_spp)
    spp_rep_fracs = compute_rep_fraction (bpm, 
                                            dependent_node_IDs, 
                                            DEBUG_LEVEL, 
                                            spp_rep_targets)
    
    unmet_spp_rep_frac_indices = which (spp_rep_fracs < 1)

    if (length (unmet_spp_rep_frac_indices) > 0)
        {
        cat ("\n\nSERIOUS ERROR: The generated optimal solution is not a solution.",
           "\n               Species at the following indices in spp_rep_fracs have representation < 1:\n", 
           "\n               ")
        print (spp_rep_fracs [unmet_spp_rep_frac_indices])
        cat ("\n\nAll spp rep fracs = \n")
        print (spp_rep_fracs)
        cat ("\n\ndependent_node_IDs = \n")
        print (dependent_node_IDs)
        cat ("\n\nbpm = \n")
        print (bpm)
        
        if (emulatingTzar)  browser ()
        quit (save="no", status=ERROR_STATUS_optimal_solution_is_not_optimal)
        }
    
    solution_cost = compute_solution_cost (dependent_node_IDs, rep (1, num_PUs))
    
        #  If an error message needs to be written too, then one of these 
        #  might be a more appropriate call.
        #assertError(expr, verbose = FALSE)
        #assertWarning(expr, verbose = FALSE)
        #assertCondition(expr, ..., .exprString = , verbose = FALSE)
        #warning(..., call. = TRUE, immediate. = FALSE, noBreaks. = FALSE,
        #        domain = NULL)
        #stop(..., call. = TRUE, domain = NULL)
    
    stopifnot (all.equal (solution_cost, length (dependent_node_IDs)))
    
    return (TRUE)
    }

#===============================================================================
#  Create a data frame using NAMES of the elements rather than their INDICES.  
#===============================================================================

    #  Though the two data frames carry identical information, it looks 
    #  like both of them are necessary because different network packages 
    #  expect different inputs.  The bipartite package creates an 
    #  adjacency matrix based on the indices, but the igraph package 
    #  creates a bipartite graph using either the indices or the vertex names.  

    #  However, if I later decide to use the vertex indices, I need to go 
    #  back and renumber either the spp vertices or the PU vertices so 
    #  that they don't overlap the other set.  That may end up being the 
    #  better strategy when graphs get big, but at the moment, giving them 
    #  names seems less likely to introduce some kind of indexing bug.
        
    #  Will create names for PU vertices by prepending the vertex ID with a "p".
    #  Similarly, spp vertices will be named by prepending with an "s".
    #  Note that we have to either uniquely name the vertices or we have to  
    #  renumber either the spp or the PUs.  This is because the numbering of 
    #  both sets of vertices starts at 1 and that means the vertex IDs are 
    #  not unique when the two sets are combined.  

create_PU_spp_pair_names = 
        function (num_PUs, 
                  num_spp, 
                  PU_spp_pair_indices, 
                  PU_col_name, 
                  spp_col_name
                  ) 
    {
    cat ("\n\nAbout to create PU_spp_pair_names...")
    
        #  First, create vectors of just then PU names and spp names alone.
        #  These are used later to build tables.
    
    PU_vertex_indices = 1:num_PUs
    PU_vertex_names = str_c ("p", PU_vertex_indices)
    
    spp_vertex_indices = 1:num_spp
    spp_vertex_names = str_c ("s", spp_vertex_indices)
    
        #  Now, create a near copy of the PU_spp_pair_indices table 
        #  but using the names of the PUs and species instead of their 
        #  indices.
    
    PU_spp_pair_names = 
        data.frame (PU_ID = str_c ("p", PU_spp_pair_indices [,PU_col_name]),
                    spp_ID = str_c ("s", PU_spp_pair_indices [,spp_col_name]), 
                    stringsAsFactors = FALSE)
    
    return (list (PU_spp_pair_names=PU_spp_pair_names, 
                  PU_vertex_names=PU_vertex_names, 
                  spp_vertex_names=spp_vertex_names))
    }

#===============================================================================
#               Build input matrix for bipartite package...
#===============================================================================

create_adj_matrix_with_spp_rows_vs_PU_cols = 
    function (num_spp, 
              num_PUs, 
## 2015 05 01 ##               spp_vertex_names, 
## 2015 05 01 ##               PU_vertex_names, 
              PU_spp_pair_indices, 
              edge_idx, 
              spp_col_name, 
              PU_col_name, 
              dependent_node_IDs, 
              correct_solution_vector_is_known, 
              ERROR_STATUS_optimal_solution_is_not_optimal, 
              emulatingTzar = FALSE
              ) 

    {
    cat ("\n\nAbout to create bpm matrix.")
    
        #  Create the adjacency matrix that will be viewed as a 
        #  bipartite matrix (bpm) by the bipartite network routines 
        #  with species as rows and planning units as columns.
    bpm = matrix (0, 
                  nrow=num_spp, 
                  ncol=num_PUs, 
                  byrow=TRUE
                  
                      #  Not sure whether to have dimnames or not.  
                      #  Doesn't seem to hurt anything at the moment...
## 2015 05 01 ##                   , 
## 2015 05 01 ##                   dimnames=list (spp_vertex_names, 
## 2015 05 01 ##                                  PU_vertex_names)
                  )
    
    cat ("\n\nAbout to fill in bpm matrix.")
    num_PU_spp_pairs = dim (PU_spp_pair_indices)[1]
    for (edge_idx in 1:num_PU_spp_pairs)
        {
        cur_row = PU_spp_pair_indices [edge_idx, spp_col_name]
        cur_col = PU_spp_pair_indices [edge_idx, PU_col_name]
        
            #  I'm making this be "1 + ..." instead of just "1", 
            #  in case at some point, I need to keep counts of 
            #  duplicates instead of just presence/absence.  
            #  With unique values, you get the same matrix 
            #  either way.
        bpm [cur_row, cur_col] = 1 + bpm [cur_row, cur_col]
        }
    
        #  If you've generated the problem, then you know the correct 
        #  solution vector and can verify that it does get the representation 
        #  that is required.
        #  However, if you've just read the Xu problem in from a file, 
        #  you probably don't know what is the correct solution, so 
        #  you can't verify it.
    
    if (correct_solution_vector_is_known)
        {
        verify_that_generated_solution_really_is_a_solution (bpm, 
                                                        dependent_node_IDs, 
                                                        num_spp, 
                                                        num_PUs, 
                    ERROR_STATUS_optimal_solution_is_not_optimal, 
                                                        emulatingTzar)
        }


    return (bpm)
    }

#===============================================================================

