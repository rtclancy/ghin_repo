TCL code for calculating golf handicap per WHS

1) clone repo
2) add you course data to tcl/courses/courses.tcl

e.g.
set courses(Alling\ Middle)         {69.0 127 72}

3) add a scores file for yourself (tcl/user_scores/your_name_scores.tcl  and input your scores

e.g.
set golfer_id "Sandbagger Bob";

set scores {
    {2023/04/15 "Shennecosset"          89 }
}

4) run calculator as follows from tcl folder

./ghin_calculator/ghin.tcl user_scores/deans_scores.tcl txt > ../user_ghin/deans_ghin.txt
