#!/usr/bin/tclsh
set user_list {
    bobs
    deans
    brians
    wards
    mikeb
}
foreach user $user_list {
    puts "Updating $user";
    exec ghin_calculator/ghin.tcl user_scores/$user\_scores.tcl txt > ../user_ghin/$user\_ghin.txt
}
