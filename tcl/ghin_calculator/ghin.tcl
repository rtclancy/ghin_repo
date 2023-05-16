#!/usr/bin/tclsh
if {$argc != 2} {
    puts "Usage:";
    puts "$argv0 scores_file \[html,txt\]"
    exit;
}

source [lindex $argv 0];
source courses/courses.tcl

set html [lindex $argv 1];
set file_string0 {};
set file_string1 {};
set file_string2 {};
set file_string3 {};

set multiplier 1.0;

#proc my_puts {stringin} {
#    regsub -all {\"} $stringin {} stringin;
#    if {$::html} {
#        lappend  ::file_string "$stringin<br>";
#    } else {
#        lappend ::file_string "$stringin";
#    }
#}
proc calc_ghin {last_20_list} {
    set ghin 0;
    set item_count 0;
    foreach aitem [lsort -index 0 $last_20_list] {
	if {$item_count < $::scores_to_use} {
	    my_puts $aitem 2;
	    set ghin [expr $ghin + [lindex $aitem 0]];
	}
	incr item_count;
    }
    
    
    set ghin [expr $ghin/$::scores_to_use * $::multiplier + $::adjustment];
    set ghin [expr round($ghin * 10)/10.0]
    return $ghin;
}
proc historical_ghin {} {
    puts "historical ghin";
    set ::file_string3 {};
    set discard_item -2;
    set ghin_date {};
    for {set iteration 0} {$iteration < [expr [array size ::diff_array] - 19]} {incr iteration} {
	incr discard_item;
	set item 0;
	set item_count 0;
	set last_20_list {}
	unset ghin_date;
	foreach aitem [lsort  -decreasing [array names ::diff_array]] { #sort by date
	    if {$item <= $discard_item} {
		incr item;
		continue;
	    }
	    incr item;

	    if {![info exists ghin_date]} {
		set ghin_date $aitem;
	    }
	    
	    if {$item_count == 20 && 0} {
		divider 3;
		#my_puts "Aged Out" 3;
		divider 3;
	    }
	    #my_puts "[format %3d [expr $item_count + 1]] $::diff_array($aitem)" 3;
	    
	    
	    if {$item_count < 20} {
		lappend last_20_list $::diff_array($aitem);
	    }
	    incr item_count;
	}
	set ghin($ghin_date) [calc_ghin $last_20_list]
    }

    foreach aitem [lsort  -increasing [array names ghin]] { #sort by date
	my_puts "$aitem $ghin($aitem)" 3;
    }
    foreach section {3} {
	foreach item [subst $[subst ::file_string$section]] {
	    puts $item;
	}
    }
}

proc my_puts {stringin section} {
    regsub -all {\"} $stringin {} stringin;
    if {$::html} {
        lappend  [subst ::file_string$section] "$stringin<br>";
    } else {
        lappend [subst ::file_string$section] $stringin;
    }
}    

if {$html == "html"} {
    set html 1;
    puts "<!DOCTYPE html><html><head><title>GHIN - Sandbagger Bob</title></head><body><p>"
    puts "<a href=\"https://drive.google.com/file/d/1IPscxoxQ7pnyUpjzAQmbeHmx6NO2e6B0/view?usp=sharing\">Bob's GHIN Link</a><br>"
    my_puts {} 1; #just adds an initial line feed
} else {
    set html 0;
}


set date_index  0;
set name_index  1;
set score_index 2;
#set cr_index    2;
#set slope_index 3;
#set par_index   5;


proc divider {{section 1}} {
    set string "********************";
    if {!$section} {
        my_puts $string $section;
    } else {
        my_puts $string $section;
    }
        
}
proc differential {cr slope score} {
    set diff [expr $score - $cr];
    set diff [expr round($diff * 113.0/$slope*10)]; #reduce to 1 decimal place
    set diff [expr $diff/10.0];
    return $diff;
}


set nscores [llength $scores];
divider 3;
my_puts "Total Scores Available: $nscores" 3;
divider 3;

#section 5.2a
set adjustment 0;
set scores_to_use 8;
if {$nscores < 4} {
    set scores_to_use 1
    set adjustment -2;
} elseif {$nscores < 5} {
    set scores_to_use 1
    set adjustment -1;
} elseif {$nscores < 6} {
    set scores_to_use 1
} elseif {$nscores < 7} {
    set scores_to_use 2
    set adjustment -1;
} elseif {$nscores < 9} {
    set scores_to_use 2
} elseif {$nscores < 12} {
    set scores_to_use 3
} elseif {$nscores < 15} {
    set scores_to_use 4
} elseif {$nscores < 19} {
    set scores_to_use 6
} elseif {$nscores < 20} {
    set scores_to_use 7
}
	  
if {$nscores < $scores_to_use} {
    set scores_to_use $nscores
}

foreach score_record $scores { #create array of courses
    set course_name [lindex $score_record $name_index];
    set course_array($course_name) $scores;
}

foreach score_record $scores {
    #my_puts $score;
   
    set cr    [lindex $courses([lindex $score_record $name_index]) $courses_cr_index];
    set slope [lindex $courses([lindex $score_record $name_index]) $courses_slope_index];
    set score [lindex $score_record $score_index];
    set date  [lindex $score_record $date_index] ;

    set diff [differential $cr $slope $score];

    set diff_array($date) "$diff $score_record";

    lappend score_list "$diff $score";
}

set item_count 0;
set last_20_list {}
foreach aitem [lsort  -decreasing [array names diff_array]] { #sort by date
    if {$item_count == 20} {
        divider 3;
        my_puts "Aged Out" 3;
        divider 3;
    }
    my_puts "[format %3d [expr $item_count + 1]] $diff_array($aitem)" 3;
    
        
    if {$item_count < 20} {
        lappend last_20_list $diff_array($aitem);
    }
    incr item_count;
}


divider 0;
my_puts "Golfer ID: $golfer_id" 0;

divider 2;
my_puts "Top $scores_to_use Differentials" 2
divider 2;
set ghin [calc_ghin $last_20_list];

#set ghin 0;
#foreach aitem [lsort -index 0 $last_20_list] {
#    if {$item_count < $scores_to_use} {
#        my_puts $aitem 2;
#        set ghin [expr $ghin + [lindex $aitem 0]];
#    }
#    incr item_count;
#}
#
#
#set ghin [expr $ghin/$scores_to_use * $multiplier];
#set ghin [expr round($ghin * 10)/10.0]

divider 0;
my_puts "WHS Handicap Index: $ghin" 0;

divider 2;
my_puts "Course Handicaps" 2;
divider 2;
foreach course [lsort -ascii [array names courses]] {
    set cr    [lindex $courses($course) $courses_cr_index];
    set slope [lindex $courses($course) $courses_slope_index];
    set par   [lindex $courses($course) $courses_par_index];
    set course_handicap [expr round($ghin * $slope/113.0 + ($cr - $par))];
    if {[string length $course] < 8} {
        my_puts "$course\t\t\t$course_handicap\t$cr\t$slope\t$par" 2;
    } elseif {[string length $course] < 16} {
        my_puts "$course\t\t$course_handicap\t$cr\t$slope\t$par" 2;
    } else { 
        my_puts "$course\t$course_handicap\t$cr\t$slope\t$par" 2;
    }
}

if {$html} {
    my_puts "<\p><\html>" 2
}
foreach section {0 1 2 3} {
    foreach item [subst $[subst ::file_string$section]] {
	puts $item;
    }
}
#foreach item $::file_string1 {
#    puts $item;
#}
#foreach item $::file_string2 {
#    puts $item;
#}
historical_ghin;
exit;

set scores_to_use 10;
set multiplier 0.96;
set item_count 0;
set ghin 0;
divider 2;
foreach aitem [lsort -index 0 $last_20_list] {
    if {$item_count < $scores_to_use} {
        my_puts $aitem 2;
        set ghin [expr $ghin + [lindex $aitem 0]];
    }
    incr item_count;
}

set ghin [expr $ghin/$scores_to_use * $multiplier];
set ghin [expr int($ghin * 10)/10.0]
#set ghin [expr round($ghin * 10)/10.0]
divider 2;
my_puts "OLD US Handicap INDEX: $ghin" 2;


my_puts "********Course Handicaps************************" 2;
foreach course [lsort -ascii [array names courses]] {
    set cr    [lindex $courses([lindex $score_record $name_index]) $courses_cr_index];
    set slope [lindex $courses([lindex $score_record $name_index]) $courses_slope_index];
    set par   [lindex $courses([lindex $score_record $name_index]) $courses_par_index];
    set course_handicap [expr round($ghin * $slope/113.0 + ($cr - $par))];
    my_puts "$course $course_handicap" 2;
}


