#===============================================================================

                    #  gscp_14_read_marxan_output_files.R

#===============================================================================

timepoints_df = 
    timepoint (timepoints_df, "gscp_14", 
               "Starting gscp_14_read_marxan_output_files.R")

#===============================================================================

    #  For each step in order by Marxan summed solution PU ID:
    #  Want the fraction of all species who have met or exceeded their target 
    #  when all PUs with the same number of votes or more are included in the 
    #  solution.

plot_incremental_marxan_summed_solution_representations = 
    function (marxan_ssoln_df, 
              PU_costs, 
              optimum_cost, 
              bpm, 
              cor_app_prefix_string, 
              num_spp, 
              plot_output_dir, 
              DEBUG_LEVEL
              ) 
    {
    
    marxan_ssoln_PUs_ranked_by_votes_df = arrange (marxan_ssoln_df, desc (number))
    
    total_landscape_cost = sum (PU_costs)
    correct_optimum_landscape_frac_cost = optimum_cost / total_landscape_cost
    
    rle_lengths_and_values = rle (marxan_ssoln_PUs_ranked_by_votes_df [, "number"])
    num_runs = length (rle_lengths_and_values$values)
    
    cur_run_start_idx = 1
    cur_run_index = 0
    cur_solution_PUs = c()
    frac_of_all_spp_meeting_their_target = rep (0.0, num_runs)
    cost = rep (0, num_runs)
    landscape_frac_cost = rep (0, num_runs)
    optimal_frac_cost = rep (0, num_runs)
    frac_rep_met_over_optimal_frac_cost = rep (0, num_runs)
    thresh_found = FALSE
    cost_thresh_for_all_spp_meeting_targets = total_landscape_cost
    landscape_frac_cost_thresh_for_all_spp_meeting_targets = 1.0
    optimal_frac_cost_thresh_for_all_spp_meeting_targets = 
        total_landscape_cost / optimum_cost
    
    for (cur_run_length in rle_lengths_and_values$lengths)
        {
        cur_run_index = cur_run_index + 1
        
        cur_run_end_idx_in_PU_IDs = cur_run_start_idx + cur_run_length - 1
        cur_run_indices = cur_run_start_idx : cur_run_end_idx_in_PU_IDs
        
        cur_solution_PUs = 
        c(cur_solution_PUs, 
        marxan_ssoln_PUs_ranked_by_votes_df [cur_run_indices, "planning_unit"])
        
        cur_rep_fractions = compute_rep_fraction (bpm, 
                                        cur_solution_PUs, 
                                        DEBUG_LEVEL, 
                                        rep (1, num_spp))
        cur_num_spp_meeting_their_target = sum (cur_rep_fractions >= 1.0)  #  How best to give a tolerance here?
        cur_frac_of_all_spp_meeting_their_target = 
            cur_num_spp_meeting_their_target / num_spp
        frac_of_all_spp_meeting_their_target [cur_run_index] = 
            cur_frac_of_all_spp_meeting_their_target
        
        #--------------------
        
        cur_cost = compute_solution_cost (cur_solution_PUs, PU_costs)
        cost [cur_run_index] = cur_cost
        
        cur_landscape_frac_cost = cur_cost / total_landscape_cost
        landscape_frac_cost [cur_run_index] = cur_landscape_frac_cost
        
        cur_optimal_frac_cost = cur_cost / optimum_cost
        optimal_frac_cost [cur_run_index] = cur_optimal_frac_cost
        
        #--------------------
        
        cur_frac_rep_met_over_optimal_frac_cost = 
            cur_frac_of_all_spp_meeting_their_target / cur_optimal_frac_cost
        frac_rep_met_over_optimal_frac_cost [cur_run_index] = 
            cur_frac_rep_met_over_optimal_frac_cost
        
        #--------------------
        
        if (!thresh_found)
            {
            if (cur_frac_of_all_spp_meeting_their_target >= 1.0)
                {
                thresh_found = TRUE
                
                cost_thresh_for_all_spp_meeting_targets = cur_cost
                landscape_frac_cost_thresh_for_all_spp_meeting_targets = 
                    cur_landscape_frac_cost
                optimal_frac_cost_thresh_for_all_spp_meeting_targets = 
                    cur_optimal_frac_cost
                
                cat ("\n\n>>>>> For marxan summed solution:")
                cat ("\n", cor_app_prefix_string, "_", "cost_thresh_for_all_spp_meeting_targets = ", 
                   cost_thresh_for_all_spp_meeting_targets, sep='')
                cat ("\n", cor_app_prefix_string, "_", "landscape_frac_cost_thresh_for_all_spp_meeting_targets = ", 
                   landscape_frac_cost_thresh_for_all_spp_meeting_targets, sep='')
                cat ("\n", cor_app_prefix_string, "_", "optimal_frac_cost_thresh_for_all_spp_meeting_targets = ", 
                   optimal_frac_cost_thresh_for_all_spp_meeting_targets, sep='')
                
                }  #  end if - all targets met
            }  #  end if - no threshold found yet
        
        #--------------------
        
        if (DEBUG_LEVEL > 0)
            {
            cat ("\n---------------------\n", cur_run_index, ":", sep='')
            print (cur_run_indices)
            cat ("cur_solution_PUs = ")
            print (cur_solution_PUs)
            cat ("\n", cor_app_prefix_string, "_", "cur_frac_of_all_spp_meeting_their_target = ", 
            cur_frac_of_all_spp_meeting_their_target)
            cat ("\n", cor_app_prefix_string, "_", "cur_cost = ", cur_cost)
            cat ("\n", cor_app_prefix_string, "_", "cur_landscape_frac_cost = ", cur_landscape_frac_cost)
            cat ("\n", cor_app_prefix_string, "_", "cur_optimal_frac_cost = ", cur_optimal_frac_cost)
            cat ("\n", cor_app_prefix_string, "_", "cur_frac_rep_met_over_optimal_frac_cost = ", cur_frac_rep_met_over_optimal_frac_cost)
            
            }  #  end if - debugging
        
        cat ("\n")
        
        #--------------------
        
        cur_run_start_idx = cur_run_end_idx_in_PU_IDs + 1
        }
    
    #-------------------------------------------
    #-------------------------------------------
    
###  2015 05 14 - BTL
###  Try converting this to "natural" spline instead of using loess().
###  It may be better-behaved.
###  See the code I saved in running notes file today for an example.

# splined_data <- stats::splinefun (cost, frac_of_all_spp_meeting_their_target,  
#                                     method="natural")

# curve (splined_data, 0.5, 5, 
#         lwd=6, 
#         col="darkblue", 
#         xlab="Experience",
#         ylab="Perceived difficulty",
#          axes=FALSE, 
#         xlim=c(0.4,5)
#         )

    #--------------------

        #  2015 04 10 - BTL
        #  NOTE:  In the following code, the call to loess() is used to make 
        #         a smoother looking approximation to the curve.  
        #         It occasionally generates a 
        #         warning and that causes everything to fail when I have options(warn=2)
        #         set to turn all warnings into errors.
        #         Since this is unimportant code that is only aimed at giving a bit 
        #         more visualization of the results, I'm going to wrap all of the 
        #         loess() calls in suppressWarnings() to keep things from failing.
        
        #  See http://www.statmethods.net/advgraphs/axes.html and 
        #  http://www.statmethods.net/advgraphs/parameters.html 
        #  for help on plot labelling if I need to modify these plots.
    
    pdf (file.path (plot_output_dir, paste0 (cor_app_prefix_string, "_", "marxan_ssoln_frac_rep_vs_raw_cost.pdf")))
    plot (cost, frac_of_all_spp_meeting_their_target, 
          main="Marxan summed solutions\nFraction of spp meeting targets vs. Raw costs", 
          xlab="Solution cost", 
          ylab="Fraction of spp meeting target")

    lines (suppressWarnings (loess (frac_of_all_spp_meeting_their_target ~ cost)))    #  good fit
    #lines (lowess (cost, frac_of_all_spp_meeting_their_target))    #  terrible fit

# splined_data <- stats::splinefun (cost, frac_of_all_spp_meeting_their_target,  
#                                   method="natural")
# curve (splined_data, #0.5, 5, 
#         lwd=6, 
#         col="darkblue" 
# #        xlab="Experience",
# #        ylab="Perceived difficulty",
# #         axes=FALSE, 
# #        xlim=c(0.4,5)
#         )

    abline (v=optimum_cost, lty=2)
    abline (h=1.0, lty=2)
    dev.off()
    
    pdf (file.path (plot_output_dir, paste0 (cor_app_prefix_string, "_", "marxan_ssoln_frac_rep_vs_normalized_cost.pdf")))
    plot (landscape_frac_cost, frac_of_all_spp_meeting_their_target, 
          main="Marxan summed solutions\nFraction of spp meeting targets vs. Normalized costs", 
          xlab="Solution cost as fraction of total landscape cost", 
          ylab="Fraction of spp meeting target")
    lines (suppressWarnings (loess (frac_of_all_spp_meeting_their_target ~ landscape_frac_cost)))    #  good fit
    abline (v=correct_optimum_landscape_frac_cost, lty=4)
    abline (h=1.0, lty=4)
    dev.off()
    
    #--------------------
    
        #  These two seemed like they should be useful, but don't seem to tell 
        #  much.  They just say that you're always getting less bang for your 
        #  buck as you add more planning units.
        #  The plots above seem to tell more about that in that you can see the 
        #  inflection point where the plot starts to bend.
        #  I'll leave them in for now, but could probably chuck them.
    
    pdf (file.path (plot_output_dir, paste0 (cor_app_prefix_string, "_", "marxan_ssoln_frac_rep_vs_frac_optimal_cost.pdf")))
    plot (optimal_frac_cost, frac_of_all_spp_meeting_their_target, 
          main="Marxan summed solutions\nFraction of spp meeting targets vs. Fraction of optimal cost", 
          xlab="Solution cost as fraction of optimal cost", 
          ylab="Fraction of spp meeting target")
    lines (suppressWarnings (loess (frac_of_all_spp_meeting_their_target ~ optimal_frac_cost)))    #  good fit
    abline (v=1, lty=5)
    abline (h=1.0, lty=5)
    dev.off()
    
    pdf (file.path (plot_output_dir, paste0 (cor_app_prefix_string, "_", "marxan_ssoln_frac_rep_over_frac_optimal_cost.pdf")))
    plot (optimal_frac_cost, frac_rep_met_over_optimal_frac_cost, 
          main="Marxan summed solutions\nRatio: sppFrac/optCostFrac vs. optCostFrac", 
          xlab="Solution cost as fraction of optimal cost", 
          ylab="Fraction of spp meeting target / fraction of optimal cost")
    #lines (suppressWarnings (loess (frac_of_all_spp_meeting_their_target ~ optimal_frac_cost)))    #  good fit
    abline (v=1, lty=6)
    abline (h=1.0, lty=6)
    dev.off()
    }

#===============================================================================

    #  Read various marxan outputs into this program.
        #  Should include these in the marxan package.
        #  Marxan's best solution.
        #  Marxan's votes for including each planning unit.
    
        #  Marxan output files to read from the Marxan output directory 
        #  (need to look these file names up in the manual):

            #  output_best.csv
            #  output_mvbest.csv

            #  output_ssoln.csv
            #  output_solutionsmatrix.csv
            #  output_sum.csv

            #  output_penalty_planning_units.csv
            #  output_penalty.csv

            #  output_sen.dat

#marxan_output_dir_path = parameters$marxan_output_dir    #  "/Users/bill/D/Marxan/output/"  #  replaced in yaml file
marxan_output_dir_path = paste0 (marxan_output_dir, .Platform$file.sep)

marxan_output_best_file_name = "output_best.csv"
marxan_output_ssoln_file_name = "output_ssoln.csv"
marxan_output_mvbest_file_name = "output_mvbest.csv"
output_solutionsmatrix_file_name = "output_solutionsmatrix.csv"

    #  Make sure both are sorted in increasing order of planning unit ID.
    #  "arrange()" syntax taken from Wickham comment in:
    #  http://stackoverflow.com/questions/1296646/how-to-sort-a-dataframe-by-columns-in-r

library (plyr)      #  for arrange()

#---------------------------------

    #  2015 05 15 - BTL 
    #  The marxan mailing list digest has had some entries in the last few 
    #  days saying that the *nix version of marxan does not always return 
    #  its best vector in the vector it has labelled as the best.  
    #  So, I need to change this to go through all of the vectors marxan 
    #  generates and figure out which one is the best myself.

marxan_best_df_unsorted_without_missing_rows = 
    read.csv (paste (marxan_output_dir_path, marxan_output_best_file_name, sep=''), 
              header=TRUE)

marxan_best_df_unsorted = 
    add_missing_PUs_to_marxan_solutions (marxan_best_df_unsorted_without_missing_rows,
                                         all_correct_node_IDs, 
                                         "PUID", "SOLUTION")

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nAfter loading output_best.csv")
    cat ("\nmarxan_best_df_unsorted_without_missing_rows =")
    print (marxan_best_df_unsorted_without_missing_rows)
    cat ("\nmarxan_best_df_unsorted =")
    print (marxan_best_df_unsorted)
    }

marxan_best_df_sorted = arrange (marxan_best_df_unsorted, PUID)
marxan_best_df_sorted_as_vector = as.vector (t(marxan_best_df_sorted [,"SOLUTION"]))

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nAfter sorting, marxan_best_df_sorted = \n")
    print (marxan_best_df_sorted)
    cat ("\n\nAfter sorting, marxan_best_df_sorted_as_vector = \n")
    print (marxan_best_df_sorted_as_vector)
    cat ("\n\n-------------------")
    }

app_optimum_cost = sum (marxan_best_df_sorted$SOLUTION)

#---------------------------------

marxan_mvbest_df = 
    read.csv (paste (marxan_output_dir_path, marxan_output_mvbest_file_name, sep=''), 
              header=TRUE)

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nAfter loading output_mvbest.csv, marxan_mvbest_df =")
    print (marxan_mvbest_df)
    }

    #  The call to "arrange()" below gives a weird error when run on the 
    #  data frame because the column names have spaces in them (e.g., 
    #  "Conservation Feature").  Renaming them seems to fix the problem
names (marxan_mvbest_df) = 
    c ("ConservationFeature", 
       "FeatureName",
       "Target",
       "AmountHeld",
       "OccurrenceTarget",
       "OccurrencesHeld",
       "SeparationTarget",
       "SeparationAchieved",
       "TargetMet",
       "MPM"  
       )

marxan_mvbest_df = arrange (marxan_mvbest_df, ConservationFeature)

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nAfter sorting, marxan_mvbest_df = \n")
    print (marxan_mvbest_df)
    cat ("\n\n-------------------")
    }

#---------------------------------
#---------------------------------
#---------------------------------

#===============================================================================
#                          Find best marxan solutions.
#
#  Added 2015 06 18 - BTL.
#===============================================================================

library (plyr)    #  For arrange()
library (stringr)

convert_name_str_to_ID_num = function (str, lead_str="P")
    {
    return (as.numeric (str_replace (str, lead_str, "")))
    }

dist_between_marxan_solutions = function (solution_1, solution_2)
    {
    return (sum (abs (solution_1 - solution_2)))
    }

#---------------------------------

    #  Load output_solutionsmatrix.csv

marxan_output_solutionsmatrix_df_unsorted_without_missing_rows = 
    read.csv (paste (marxan_output_dir_path, output_solutionsmatrix_file_name, sep=''), as.is=TRUE, 
              header=TRUE)

    #  Get the planning unit names as they appear as solution column headings.
PU_names = names (marxan_output_solutionsmatrix_df_unsorted_without_missing_rows)
PU_names = PU_names [-1]  #  Get rid of first column's label, i.e., "solutionsmatrix"

num_marxan_solutions = dim (marxan_output_solutionsmatrix_df_unsorted_without_missing_rows)[1]

largest_PU_ID = num_PUs
marxan_solutions_matrix = matrix (0, nrow = num_marxan_solutions,
                                  ncol = largest_PU_ID,
                                  byrow=TRUE)

for (cur_PU_name in PU_names)
    {
    cur_PU_ID = convert_name_str_to_ID_num (cur_PU_name, "P")
    cat ("\ncur_PU_ID = ", cur_PU_ID)

    marxan_solutions_matrix [,cur_PU_ID] = 
        marxan_output_solutionsmatrix_df_unsorted_without_missing_rows [,cur_PU_name] 
    }

    #  Ready now to go through the matrix and compute the representation and 
    #  cost values for each solution row.

cor_marxan_solution_scores = data.frame (solution_num=1:num_marxan_solutions,
                                        representation=0,
                                        cost=0)
app_marxan_solution_scores = cor_marxan_solution_scores

targets = rep (1, num_spp)
PU_costs = rep (1, num_PUs)
total_landscape_cost = sum (PU_costs)

compute_marxan_solution_scores <- function (spp_rows_by_PU_cols_matrix_of_spp_cts_per_PU, 
                                            marxan_solution_PU_IDs,
                                            DEBUG_LEVEL, 
                                            targets, 
                                            num_spp, 
                                            marxan_solutions_matrix, 
                                            cur_solution_num, 
                                            marxan_solution_scores, 
                                            PU_costs, 
                                            total_landscape_cost
                                            )
    {
    cur_rep_fractions = 
        compute_rep_fraction (spp_rows_by_PU_cols_matrix_of_spp_cts_per_PU, 
                              marxan_solution_PU_IDs,
                              DEBUG_LEVEL, 
                              targets)
    cur_frac_of_all_spp_meeting_their_target = sum (cur_rep_fractions >= 1.0) / num_spp    #  How best to give a tolerance here?
    marxan_solution_scores [cur_solution_num, "representation"] = cur_frac_of_all_spp_meeting_their_target
    
    cur_solution_PUs = which (marxan_solutions_matrix [cur_solution_num,] > 0)
    cur_cost = compute_solution_cost (cur_solution_PUs, PU_costs)
    marxan_solution_scores [cur_solution_num, "cost"] = cur_cost / total_landscape_cost
    
    return (marxan_solution_scores)
    }


for (cur_solution_num in 1:num_marxan_solutions)
    {
    cor_marxan_solution_scores [cur_solution_num, "solution_num"] = cur_solution_num
    app_marxan_solution_scores [cur_solution_num, "solution_num"] = cur_solution_num
        
    cur_marxan_solution_PU_IDs = which (marxan_solutions_matrix [cur_solution_num,] > 0)
    if (DEBUG_LEVEL > 0)
        cat ("\n\ncur_marxan_solution_PU_IDs = ", cur_marxan_solution_PU_IDs)

    cor_marxan_solution_scores = compute_marxan_solution_scores (cor_bpm, 
                                                                 cur_marxan_solution_PU_IDs,
                                                                 DEBUG_LEVEL, 
                                                                 targets, 
                                                                 num_spp, 
                                                                 marxan_solutions_matrix, 
                                                                 cur_solution_num, 
                                                                 cor_marxan_solution_scores, 
                                                                 PU_costs,
                                                                 total_landscape_cost)
    
    app_marxan_solution_scores = compute_marxan_solution_scores (bpm, 
                                                                 cur_marxan_solution_PU_IDs,
                                                                 DEBUG_LEVEL, 
                                                                 targets, 
                                                                 num_spp, 
                                                                 marxan_solutions_matrix, 
                                                                 cur_solution_num, 
                                                                 app_marxan_solution_scores, 
                                                                 PU_costs,
                                                                 total_landscape_cost)
    }

cor_sorted_marxan_solution_scores = arrange (cor_marxan_solution_scores, -representation, -cost)
app_sorted_marxan_solution_scores = arrange (app_marxan_solution_scores, -representation, -cost)

distances_between_marxan_solutions = matrix (0, nrow=num_marxan_solutions, 
                                             ncol=num_marxan_solutions, byrow=TRUE)

IDs_of_vectors_matching_marxan_best_solution_choice = c()
for (cur_row in 1:num_marxan_solutions)
    {
    cur_dist_from_marxan_best_df_sorted_as_vector = 
#        distances_between_marxan_solutions [cur_row, cur_col] = 
            dist_between_marxan_solutions (marxan_solutions_matrix [cur_row, ],
                                           marxan_best_df_sorted_as_vector)
    
    if (cur_dist_from_marxan_best_df_sorted_as_vector == 0)
        IDs_of_vectors_matching_marxan_best_solution_choice = 
            c (IDs_of_vectors_matching_marxan_best_solution_choice, cur_row)
    
    for (cur_col in 1:num_marxan_solutions)
        {
        distances_between_marxan_solutions [cur_row, cur_col] = 
            dist_between_marxan_solutions (marxan_solutions_matrix [cur_row, ],
                                           marxan_solutions_matrix [cur_col, ])
        }
    }

short_range = min (num_marxan_solutions, 5)
cat ("\n\ndistances_between_marxan_solutions [1:short_range,1:short_range] = \n")
print (distances_between_marxan_solutions [1:short_range,1:short_range])

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\ndistances_between_marxan_solutions = \n")
    print (distances_between_marxan_solutions)
    }

cat ("\n\nIDs_of_vectors_matching_marxan_best_solution_choice = ", 
     IDs_of_vectors_matching_marxan_best_solution_choice)
cat ("\nnumber of vectors matching marxan best solution choice = ", 
     length (IDs_of_vectors_matching_marxan_best_solution_choice))

    #  Marxan returns a best solution, but I have not been able to find 
    #  anyplace where it tells you what solution number it was.  
    #  Since you can have multiple identical solutions, there may be 
    #  multiple solution IDs that could be identified as the best solution.  
    #  I need any one of them to use to get the corresponding solution vector. 
    #  I will arbitrarily choose the first one in the list of vectors that 
    #  selected the same PUs as the vector that marxan returned.  
best_solution_ID_according_to_marxan = 
    IDs_of_vectors_matching_marxan_best_solution_choice [1]

cor_app_prefix_string = "cor"
pdf (file.path (plot_output_dir, paste0 (cor_app_prefix_string, "_", "marxan_all_solutions_frac_rep_vs_raw_cost.pdf")))
plot (cor_marxan_solution_scores [, "cost"], 
      cor_marxan_solution_scores [, "representation"], 
      main="Marxan solutions\nCORRECT - Fraction of spp meeting targets vs. costs", 
      xlab="Solution cost", 
      ylab="Fraction of spp meeting target", 
      col= "blue", pch = 19, cex = 1, lty = "solid", lwd = 2
      )

text(cor_marxan_solution_scores [, "cost"], 
     cor_marxan_solution_scores [, "representation"], 
     labels = cor_marxan_solution_scores [, "solution_num"], 
     cex= 0.7, pos=4)

    #  Color marxan's chosen solution red.
points (cor_marxan_solution_scores [best_solution_ID_according_to_marxan, "cost"], 
        cor_marxan_solution_scores [best_solution_ID_according_to_marxan, "representation"], 
        col= "red", pch = 19, cex = 1, lty = "solid", lwd = 2) 
dev.off()

cor_app_prefix_string = "app"
pdf (file.path (plot_output_dir, paste0 (cor_app_prefix_string, "_", "marxan_all_solutions_frac_rep_vs_raw_cost.pdf")))
plot (app_marxan_solution_scores [, "cost"], 
      app_marxan_solution_scores [, "representation"], 
      main="Marxan solutions\nAPPARENT - Fraction of spp meeting targets vs. costs", 
      xlab="Solution cost", 
      ylab="Fraction of spp meeting target", 
      col= "blue", pch = 19, cex = 1, lty = "solid", lwd = 2
      )

text(app_marxan_solution_scores [, "cost"], 
     app_marxan_solution_scores [, "representation"], 
     labels = cor_marxan_solution_scores [, "solution_num"], 
     cex= 0.7, pos=4)

    #  Color marxan's chosen solution red.
points (app_marxan_solution_scores [best_solution_ID_according_to_marxan, "cost"], 
        app_marxan_solution_scores [best_solution_ID_according_to_marxan, "representation"], 
        col= "red", pch = 19, cex = 1, lty = "solid", lwd = 2) 
dev.off()
#browser()    

#--------------------

get_marxan_solution_choice_string = function (marxan_best_cost, 
                                              marxan_best_rep, 
                                              sorted_best_cost, 
                                              sorted_best_rep)
    {
    solution_choice_string = "OK_marxan_solution_IS_apparent_best"
    if (marxan_best_cost > sorted_best_cost)
        {
            #  marxan's chosen best is NOT the best cost
        if (marxan_best_rep < sorted_best_rep)
            {
                #  marxan's chosen best is also NOT the best representation
            solution_choice_string = "BAD_marxan_solution_NEITHER_best"
            } else
            {
                #  marxan's chosen best is not best score but is best representation
            solution_choice_string = "BAD_HALF_marxan_solution_NOT_apparent_best_cost_and_IS_apparent_best_rep"
            }
        } else if (marxan_best_rep < sorted_best_rep)
        {
            #  marxan's chosen best is best score but is NOT best representation
        solution_choice_string = "BAD_HALF_marxan_solution_IS_apparent_best_cost_and_NOT_apparent_best_rep"
        }
    
    return (solution_choice_string)
    }

if (FALSE)     #  a quick test
    {
    get_marxan_solution_choice_string (10, 1, 10, 1)    #  OK_marxan_solution_IS_apparent_best
    get_marxan_solution_choice_string (20, 1, 10, 1)    #  BAD_HALF_marxan_solution_NOT_apparent_best_cost_and_IS_apparent_best_rep
    get_marxan_solution_choice_string (10, 0.8, 10, 1)  #  BAD_HALF_marxan_solution_IS_apparent_best_cost_and_NOT_apparent_best_rep
    get_marxan_solution_choice_string (11, 0.5, 10, 1)  #  BAD_marxan_solution_NEITHER_best
    }

marxan_best_cost = app_marxan_solution_scores [best_solution_ID_according_to_marxan, "cost"]
marxan_best_rep  = app_marxan_solution_scores [best_solution_ID_according_to_marxan, "representation"]
sorted_best_cost = app_marxan_solution_scores [1, "cost"]
sorted_best_rep  = app_marxan_solution_scores [1, "representation"]

marxan_solution_choice_check_string = 
    get_marxan_solution_choice_string (marxan_best_cost, marxan_best_rep, 
                                       sorted_best_cost, sorted_best_rep)
cat ("\n\n=====>  ", marxan_solution_choice_check_string, "     <=====\n", sep='')

    #  Write an empty file whose name indicates whether marxan really did 
    #  return its best guess.  
    #  This will make it easy to quickly search a bunch of runs to see 
    #  whether any of them had a bad marxan choice for best run by 
    #  just looking for the existance of any files whose names begin 
    #  with "BAD_".
flag_file_name = paste0 (parameters$fullOutputDirWithSlash, 
                         marxan_solution_choice_check_string)
system (paste ("touch", flag_file_name), wait=FALSE)

#--------------------

#===============================================================================
#                       end - Find best marxan solutions.
#===============================================================================

#---------------------------------
#---------------------------------
#---------------------------------

    #  Load the summed solutions vector.
    #  For each PU ID, it shows the number of solution vectors that 
    #  included that PU in the solution.

marxan_ssoln_df_unsorted_without_missing_rows = 
    read.csv (paste (marxan_output_dir_path, marxan_output_ssoln_file_name, sep=''),
              header=TRUE)

marxan_ssoln_df_unsorted = 
    add_missing_PUs_to_marxan_solutions (marxan_ssoln_df_unsorted_without_missing_rows,
                                         all_correct_node_IDs, 
                                         "planning_unit", "number")
    
if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nAfter loading output_best.csv")
    cat ("\nmarxan_ssoln_df_without_missing_rows =")
    print (marxan_ssoln_df_without_missing_rows)
    cat ("\nmarxan_ssoln_df_unsorted =")
    print (marxan_ssoln_df_unsorted)
    }

marxan_ssoln_df = arrange (marxan_ssoln_df_unsorted, planning_unit)

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nAfter sorting, marxan_ssoln_df = \n")
    print (marxan_ssoln_df)
    cat ("\n\n-------------------")
    }

#---------------------------------

    #  Evaluate apparent summed solutions as a function of the correct 
    #  problem structure and the apparent problem structure, i.e.,
    #  how marxan is really doing vs. how marxan thinks it's doing.

    #  Using correct scores...
plot_incremental_marxan_summed_solution_representations (marxan_ssoln_df, 
                                                          PU_costs, 
                                                    cor_optimum_cost, 
                                                    cor_bpm, 
                                                    "cor", 
                                                          num_spp, 
                                                          plot_output_dir, 
                                                          DEBUG_LEVEL) 

    #  Using apparent scores...
plot_incremental_marxan_summed_solution_representations (marxan_ssoln_df, 
                                                          PU_costs, 
                                                    app_optimum_cost, 
                                                    bpm, 
                                                    "app", 
                                                          num_spp, 
                                                          plot_output_dir, 
                                                          DEBUG_LEVEL) 

#===============================================================================

