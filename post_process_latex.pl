#!/usr/bin/perl -n -l -a -i


if( m{^\\makeindex$} ) {
  # Fix spacing in the ToC
  print q(
\usepackage{savesym}
\savesymbol{c@lofdepth}   % tocloft conflicts with subfigure.sty
\savesymbol{c@lotdepth}   % tocloft conflicts with subfigure.sty
\usepackage{tocloft}
\addtolength{\cftsecnumwidth}{2em}
\addtolength{\cftchapnumwidth}{0.5em}
  );
  print;
  # These two covered by options
#} elsif( m{^\\frontmatter$} ) {
#  # do nothing
#} elsif( m{^\\listof.example..List of Examples.$} ) {
#  # do nothing
} else {
  print;
}
