#==============================================================================

                #  load_and_parse_Xu_set_cover_problem_file.R  

#  This routine reads the given input file which is assumed to contain 
#  one of Xu's minimum set cover problems in the format specified on 
#  his related web page at:
#       http://www.nlsde.buaa.edu.cn/~kexu/benchmarks/set-benchmarks.htm

#  The file format has a 1 line header followed by 1 line for each vertex. 
#  Each vertex line lists all of the edges assigned to a given vertex.

#  Header line
#  The header line begins with "p set " and then gives the highest edge number 
#  in the file, followed by a space and then the number of vertices.  
#  For example:
#       p set 17827 450

#  Vertex lines
#  - No ID is given for the vertices, just the list of edge IDs, but 
#  - Each vertex line begins with "s".
#  - All entries on the line are 
#  separated by spaces.  Each line can be of any length, so they essentially 
#  make up a ragged array.  

#  Example of first few lines of a file (with R comment markers prepended as 
#  "#  " to allow these lines to appear in this R source file:
#  p set 174 3
#  s 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
#  s 1 81 82 83 84 85 86 87 88 89
#  s 2 81 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174

#-------------------------------------------------------------------------------

#  Quote from Xu's page cited above explaining the format:
#
#  As far as we know, there is no standard format to express the minimum set 
#  covering and maximum set packing problems. 
#  Based on the ASCII DIMACS graph format, we propose a format for these 
#  two problems as follows:
# 
#     There are 0 or more lines starting with c at the top of the file which 
#     are comment lines and can be ignored.
# 
#     Following the comment lines, there is a line with the form "p set U S"  
#     where U and S are respectively 
#       - the number of elements in the universe (denoted by natural numbers)
#           [BTL: these are the species IDs in biodivprobgen]
#       - and the number of subsets in the collection.
#           [BTL: these are the planning unit IDs in biodivprobgen]
# 
#     The remaining of the file is a list of lines starting with s which 
#     indicate the subsets in the collection (e.g. the line "s 1 2 4" 
#     indicates that there is a subset with three elements which are 1, 2 
#     and 4).

#-------------------------------------------------------------------------------

#  Here are the benchmarks and with their Minimum Set Cover sizes for the 
#  correct answer from the web page.  I've downloaded and unzipped all of these 
#  in /Users/bill/Desktop/Papers downloaded/Problem difficulty/Problem difficulty datasets/Xu - problem difficulty datasets:
#
#    frb30-15-msc.tar.gz (  419 KB):   450 subsets  - 5 instances, with the size of the MSC =   420 and the size of the MSP = 30
#    frb35-17-msc.tar.gz (  666 KB):   595 subsets  - 5 instances, with the size of the MSC =   560 and the size of the MSP = 35
#    frb40-19-msc.tar.gz (  990 KB):   760 subsets  - 5 instances, with the size of the MSC =   720 and the size of the MSP = 40
#    frb45-21-msc.tar.gz (1412 KB):   945 subsets  - 5 instances, with the size of the MSC =   900 and the size of the MSP = 45
#    frb50-23-msc.tar.gz (1943 KB): 1150 subsets  - 5 instances, with the size of the MSC = 1100 and the size of the MSP = 50
#    frb53-24-msc.tar.gz (2281 KB): 1272 subsets  - 5 instances, with the size of the MSC = 1219 and the size of the MSP = 53
#    frb56-25-msc.tar.gz (2677 KB): 1400 subsets  - 5 instances, with the size of the MSC = 1344 and the size of the MSP = 56
#    frb59-26-msc.tar.gz (3110 KB): 1534 subsets  - 5 instances, with the size of the MSC = 1475 and the size of the MSP = 59

#==============================================================================

#  History:

#  2015 04 26 - BTL
#  Cloned from /Users/bill/D/rdv-framework-old-sourceforge/framework/R/
#               scan.ragged.array.of.integers.from.file.R

#  8/23/07 - BTL
#  Created scan.ragged.array.of.integers.from.file.R
#      Basically just hacked around with a few lines of Daniel's code from 
#      calc.evaluation.functions.v5.0.R 

#==============================================================================

load_and_parse_Xu_set_cover_problem_file <- function (infile_name)
    {
    cat ("\n\nIn load_and_parse_Xu_set_cover_problem_file()",
         "\n\tinfile_name = '", infile_name, "'\n", sep='')

        #  I don't really get the "" argument here, but it works.
        #  It seems to be telling the scan routine that the data is
        #  character data.  I tried lots of other things like "integer",
        #  but nothing seemed to work right.  Daniel had "complex" in
        #  there and it worked, but for no apparent reason, i.e., the
        #  data is integer, not complex.  
    vector_of_input_line_strings <- scan ( infile_name, "", sep = "\n" );
    num_vertex_lines = length (vector_of_input_line_strings) - 1
    
    header_line_as_list_of_strings <-
        strsplit (vector_of_input_line_strings [1], " ") [[1]];
    
    cat ("\n\nXu input file header values = ")
    print (header_line_as_list_of_strings)
    
    max_edge_ID = as.integer (header_line_as_list_of_strings [3])
    num_vertices = as.integer (header_line_as_list_of_strings [4])
    
    if (num_vertex_lines != num_vertices)
        {
        cat ("\n\nERROR in load_and_parse_Xu_set_cover_problem_file():",
             "\n\tnum_vertex_lines=", num_vertex_lines, " must match ", 
             "num_vertices=", num_vertices, 
             "\n\n", sep='')
        stop ()
        }
    
    xu_list_of_vectors_of_edge_IDs <- vector ("list", num_vertices);
    
    for (i in 1:num_vertices)
        {
            #  Split out the various substrings of the current line.
            #  I tried to make it so that it could split on something
            #  other than spaces (e.g., space, tab, and comma), but
            #  I could only get it to work with a single thing, spaces.
            #  It looked like it should be able to take regular expressions
            #  instead of just " ", but I couldn't get it to work.
            #  I may have just been putting the expression in wrong though...
        cur_line_as_list_of_strings <-
            strsplit (vector_of_input_line_strings [i+1], " ")
        
            #  strsplit() returns a list with one element, i.e., 
            #  a vector of substrings making up the line.
            #  For example:
            #       [[1]]
            #        [1] "s"  "1"  "2"  "3"  "4" 
            #
            #  So, strip off the leading "s" and convert values to a vector 
            #  of integers instead of a single element list containing a 
            #  vector of strings.
        xu_list_of_vectors_of_edge_IDs [[i]] = 
            as.integer (cur_line_as_list_of_strings [[1]][-1])
        }
    
    return (list (xu_list_of_vectors_of_edge_IDs=xu_list_of_vectors_of_edge_IDs, 
                  num_PUs=num_vertices,
                  num_spp=max_edge_ID))
    }

#==============================================================================

load_Xu_problem_from_file_into_PU_spp_pair_indices = 
        function (xu_list_of_vectors_of_edge_IDs,
                  num_PUs)
    {
    lengths_of_vectors = lapply (xu_list_of_vectors_of_edge_IDs, length)
    num_PU_spp_pairs = sum (unlist (lengths_of_vectors))
    
    PU_spp_pair_indices = data.frame (PU_ID = rep (NA, num_PU_spp_pairs),
                                      spp_ID = rep (NA, num_PU_spp_pairs))
        
    cur_PU_spp_pair_ct = 0
    for (cur_vertex_ID in seq (1, num_PUs))
        {
        for (cur_edge_ID in xu_list_of_vectors_of_edge_IDs [[cur_vertex_ID]])
            {
            cur_PU_spp_pair_ct = cur_PU_spp_pair_ct + 1
            PU_spp_pair_indices [cur_PU_spp_pair_ct, ] = 
                                                c (cur_vertex_ID, cur_edge_ID)
            }
        }

    return (PU_spp_pair_indices)
    }

#==============================================================================

load_Xu_problem_from_file_into_PU_spp_pair_indices_sextet = 
        function (input_file_name, 
                  correct_solution_cost)
    {
    parsed_Xu_file_triple = 
        load_and_parse_Xu_set_cover_problem_file (infile_name)
    
    xu_list_of_vectors_of_edge_IDs = 
        parsed_Xu_file_triple$xu_list_of_vectors_of_edge_IDs
    num_PUs = parsed_Xu_file_triple$num_PUs
    num_spp = parsed_Xu_file_triple$num_spp
    
    PU_spp_pair_indices = 
        load_Xu_problem_from_file_into_PU_spp_pair_indices (xu_list_of_vectors_of_edge_IDs,
                                                            num_PUs)
    
    cat ("\n\nPU_spp_pair_indices = \n")
    print (head (PU_spp_pair_indices))
    cat ("\n...\n")
    
    cat ("\n")
    print (tail (PU_spp_pair_indices))
    
    PU_col_name = names (PU_spp_pair_indices)[1]
    spp_col_name = names (PU_spp_pair_indices)[2]
    
    return (list (PU_spp_pair_indices=PU_spp_pair_indices, 
                  PU_col_name=PU_col_name,
                  spp_col_name=spp_col_name, 
                  num_PUs=num_PUs,
                  num_spp=num_spp, 
                  correct_solution_cost = correct_solution_cost
                  ))
    }

#==============================================================================

test_load_and_parse_Xu_set_cover_problem_file = function (infile_name)
    {
    xu_triple = load_and_parse_Xu_set_cover_problem_file (infile_name)

    xu_list_of_vectors_of_edge_IDs = xu_triple$xu_list_of_vectors_of_edge_IDs 
    num_PUs = xu_triplenum_vertices
    num_spp = xu_triplemax_edge_ID

    cat ("\n\nXu file values = \n")
    print (xu_list_of_vectors_of_edge_IDs)
    cat ("\nnum_PUs = ", num_PUs, sep='')
    cat ("\nnum_spp = ", num_spp, sep='')
    }

if (TESTING) 
    {
#    infile_name = "/Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/test_xu_input.msc"
    infile_name = "/Users/bill/Desktop/Papers downloaded/Problem difficulty/Problem difficulty datasets/Xu - problem difficulty datasets/frb30-15-msc with MSC 420/frb30-15-1.msc"
    given_correct_solution_cost = 420
    
    PU_spp_pair_indices_sextet = 
        load_Xu_problem_from_file_into_PU_spp_pair_indices_sextet (infile_name,
                                                                   given_correct_solution_cost)

    
    PU_spp_pair_indices = PU_spp_pair_indices_sextet$PU_spp_pair_indices 
    cat ("\n")
    
    PU_col_name = PU_spp_pair_indices_sextet$PU_col_name
    cat ("\nPU_col_name = '", PU_col_name, "'", sep='')
    
    spp_col_name = PU_spp_pair_indices_sextet$spp_col_name
    cat ("\nspp_col_name = '", spp_col_name, "'", sep='')
    
    num_PUs = PU_spp_pair_indices_sextet$num_PUs
    cat ("\nnum_PUs = '", num_PUs, "'", sep='')
    
    num_spp = PU_spp_pair_indices_sextet$num_spp
    cat ("\nnum_spp = '", num_spp, "'", sep='')
    
    correct_solution_cost = PU_spp_pair_indices_sextet$correct_solution_cost
    cat ("\ncorrect_solution_cost = '", correct_solution_cost, "'", sep='')    
    }

#==============================================================================

