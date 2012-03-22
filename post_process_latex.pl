#!/usr/bin/perl -n -l -a -i


if( m{^\\makeindex$} ) {
  # Fix spacing in the ToC
  print q(
  % BEGIN Added by post_process_latex.pl
% More space for the numbers in the ToC (table of contents)
\usepackage{savesym}
\savesymbol{c@lofdepth}   % tocloft conflicts with subfigure.sty
\savesymbol{c@lotdepth}   % tocloft conflicts with subfigure.sty
\usepackage{tocloft}
\addtolength{\cftsecnumwidth}{2em}
\addtolength{\cftchapnumwidth}{0.5em}
% Two-column glossaries and other such things
\usepackage{multicol}
\usepackage{etoolbox}
\BeforeBeginEnvironment{description}{\begin{multicols}{2}}\AfterEndEnvironment{description}{\end{multicols}}
\usepackage{fullpage}
  % END Added by post_process_latex.pl
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
