#===============================================================================

                #  gscp_10b_compute_solution_rep_levels_and_costs.R

#===============================================================================

#  History:

#  2015 02 18 - BTL - Created.

#===============================================================================

    #  Compute representation match (shortfall or overrep) given a spp rows by 
    #  PU columns adjacency matrix.

compute_rep_fraction = 
    function (spp_rows_by_PU_cols_matrix_of_spp_cts_per_PU, 
              PU_set_to_test,
              DEBUG_LEVEL, 
              spp_rep_targets = 1   #  replace with vector if not all 1s
              )
    {
        #  Reduce the spp/PU adjacency matrix to only include PUs that 
        #  are in the set to test (e.g., in the proposed reserve set).
        #  Once that's done, summing each spp row will tell you how much 
        #  representation each spp achieves in the proposed solution.
        
    selected_PUs_matrix_of_spp_cts_per_PU = 
        spp_rows_by_PU_cols_matrix_of_spp_cts_per_PU [ , PU_set_to_test, drop=FALSE]
    spp_rep_cts = apply (selected_PUs_matrix_of_spp_cts_per_PU, 1, sum)
    
            #  2015 04 28 - BTL
            #  Moved this statement out of the debug if statement below.  
            #  It looks like it was a bug to have it in there instead of 
            #  here before the spp_rep_fracs computation.  
            #  I only noticed this today when I started getting the 
            #  following warning/error message:
            #       Error in spp_rep_cts - spp_rep_targets : 
            #       (converted from warning) longer object length is not 
            #       a multiple of shorter object length

#     if (length (spp_rep_targets) == 1)
#         spp_rep_targets = rep (spp_rep_targets, 
#                                dim (selected_PUs_matrix_of_spp_cts_per_PU) [1])

    spp_rep_fracs = 1 + ((spp_rep_cts - spp_rep_targets) / spp_rep_targets)
    
    if (DEBUG_LEVEL)
        {
        if (length (spp_rep_targets) == 1)
            spp_rep_targets = rep (spp_rep_targets, 
                                   dim (selected_PUs_matrix_of_spp_cts_per_PU) [1])
        display_matrix = 
            cbind (selected_PUs_matrix_of_spp_cts_per_PU, spp_rep_cts, spp_rep_targets, spp_rep_fracs)
        cat ("\nIn compute_rep_fraction():\nselected_PUs_matrix_of_spp_cts_per_PU with cts, targets, and fracs appended = \n")
        print (display_matrix)
        }

    return (spp_rep_fracs)
    }

#===============================================================================

    #  Compute cost of given solution vector of PUs to include.

compute_solution_cost = 
    function (PU_set_to_test, PU_costs)
    {
    return (sum (PU_costs [PU_set_to_test]))
    }

#===============================================================================
#===============================================================================

test_compute_rep_fraction = function (DEBUG_LEVEL)
    {
    
        #  Create a solution set to test that includes 2 PUs out of 4.
    num_PUs = 4
    solution_set = c (1, 3)
    
        #  Create a set of target levels for each of 5 spp.
    num_spp = 5
    spp_target_levels = c (20, 10, 30, 10, 0)
    
        #  Create adjacency matrix with 5 spp rows and 4 PU columns.
    matrix_of_spp_cts_per_PU = 
        matrix (c ( 1, 2, 3, 4,
                    5, 6, 7, 8, 
                    9, 10, 11, 12,
                    13, 14, 15, 16, 
                    17, 18, 19, 20), 
                nrow=num_spp, ncol=num_PUs, byrow=TRUE
                )
    
        #  Test with default targets of all 1s.
    if (DEBUG_LEVEL)  cat ("\n\nCASE:  default targets all 1s.")
    correct_answer = c (4, 12, 20, 28, 36)
    answer = compute_rep_fraction (matrix_of_spp_cts_per_PU, 
                                   solution_set, 
                                   DEBUG_LEVEL, 
                                   1)
    if (isTRUE (all.equal (correct_answer, answer))) cat (".") else cat ("F")
    if (DEBUG_LEVEL)
        {
        cat ("\ncorrect answer = ", correct_answer)
        cat ("\nanswer         = ", answer, "\n")
        }
    
        #  Test with targets of all 20s.
    if (DEBUG_LEVEL)  cat ("\n\nCASE:  default targets all 20s.")
    correct_answer = c (0.2, 0.6, 1.0, 1.4, 1.8)
    answer = compute_rep_fraction (matrix_of_spp_cts_per_PU, 
                                   solution_set, 
                                   DEBUG_LEVEL, 
                                   20)
    if (isTRUE (all.equal (correct_answer, answer))) cat (".") else cat ("F")
    if (DEBUG_LEVEL)
        {
        cat ("\ncorrect answer = ", correct_answer)
        cat ("\nanswer         = ", answer, "\n")
        }
    
        #  Test with spp_target_levels = c (20, 10, 30, 10, 0)
    if (DEBUG_LEVEL)  cat ("\n\nCASE:  spp_target_levels = c (20, 10, 30, 10, 0).")
    correct_answer = c (0.2, 1.2, 0.6666667, 2.8, Inf)
    answer = compute_rep_fraction (matrix_of_spp_cts_per_PU, 
                                   solution_set, 
                                   DEBUG_LEVEL, 
                                   spp_target_levels)
    if (isTRUE (all.equal (correct_answer, answer, tolerance = 1e-6))) cat (".") else cat ("F")
    if (DEBUG_LEVEL)
        {
        cat ("\ncorrect answer = ", correct_answer)
        cat ("\nanswer         = ", answer, "\n")
        all.equal_result = all.equal (correct_answer, answer, tolerance = 1e-6)
        cat ("\nall.equal_result = ", all.equal_result)
        
        #  http://www.johnmyleswhite.com/notebook/2012/04/13/floating-point-arithmetic-and-the-descent-into-madness/
        #  From one of the comments:
        #  Harlan 4.14.2012 at 11:45 am | Permalink
        #  Ack! As it turns out, there isn’t an approx_eq() in base Julia! 
        #     It is defined, however, in extras/test.jl. Now that I think about it, 
        #     I’m going to submit a pull request to put that function in base. 
        #     I’m also going to redefine it so that the tolerance is, by default, 
        #     twice the max uncertainty of the numbers being compared: 
        #         2 * max(eps(a), eps(b)), using the handy eps() function 
        #     that _is_ defined in base. 
        #       [BTL:  No equivalent in R for eps(), or is that .Machine$double.eps?]
        #     I’d previously borrowed R’s fixed 1e-6, which is probably not a great idea.
        
        #  R FAQ
        #  http://cran.r-project.org/doc/FAQ/R-FAQ.html#Why-doesn_0027t-R-think-these-numbers-are-equal_003f
        # 7.31 Why doesn’t R think these numbers are equal?
        # 
        # The only numbers that can be represented exactly in R’s numeric type are integers and fractions whose denominator is a power of 2. Other numbers have to be rounded to (typically) 53 binary digits accuracy. As a result, two floating point numbers will not reliably be equal unless they have been computed by the same algorithm, and not always even then. For example
        # 
        # R> a <- sqrt(2)
        # R> a * a == 2
        # [1] FALSE
        # R> a * a - 2
        # [1] 4.440892e-16
        # 
        # The function all.equal() compares two objects using a numeric tolerance of .Machine$double.eps ^ 0.5. 
        # If you want much greater accuracy than this you will need to consider error propagation carefully.
        # 
        # For more information, see e.g. David Goldberg (1991), “What Every Computer Scientist Should Know About Floating-Point Arithmetic”, ACM Computing Surveys, 23/1, 5–48, also available via http://www.validlab.com/goldberg/paper.pdf.
        # 
        # To quote from “The Elements of Programming Style” by Kernighan and Plauger:
        # 
        #     10.0 times 0.1 is hardly ever 1.0. 
        
        #  Bizarreness continues...
        #  all.equal() has a tolerance argument whose default is:  .Machine$double.eps ^ 0.5
        #  On my mac, that evaluates to:  1.490116e-08
        #  The difference between correct_answer and answer evaluates to:
        #  c_a - a =  5.551115e-17,  0,  3.333333e-08,  0,  NaN 
        #  
        
        cat ("\ncorrect_answer - answer = ", (correct_answer - answer), "\n")
        for (iii in 1:length(correct_answer))
            {
            kkk = all.equal (correct_answer[iii], answer[iii], tolerance = 1e-6)
            cat ("\niii = ", iii, 
                 ":  all.equal", kkk, 
                     ":  ==", (correct_answer[iii] == answer[iii]), 
                 ":  correct_answer = ", correct_answer[iii], 
                 "  answer = ", answer[iii])
            }
        cat ("\n")
        }
    }

#-------------------------------------------------------------------------------

test_compute_solution_cost = function ()
    {
    num_PUs = 4
    PU_set_to_test = c (1, 3)

    sc = compute_solution_cost (PU_set_to_test, rep (1, num_PUs))
    if (isTRUE (all.equal 
        (3, 
         sc,    #compute_solution_cost (PU_set_to_test, rep (1, num_PUs)), 
         tolerance = 1e-6)
        )) cat (".") else cat ("F")
    if (isTRUE (all.equal (20, compute_solution_cost (PU_set_to_test, rep (10, num_PUs)), tolerance = 1e-6))) cat (".") else cat ("F")
    if (isTRUE (all.equal (4, compute_solution_cost (PU_set_to_test, c (1, 2, 3, 4)), tolerance = 1e-6))) cat (".") else cat ("F")
    }

#-------------------------------------------------------------------------------

TESTING = FALSE
if (TESTING) test_compute_rep_fraction (DEBUG_LEVEL)
if (TESTING) test_compute_solution_cost()

#===============================================================================

