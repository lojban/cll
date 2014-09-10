
$converters[:info_converters] = {
  :title => {
    :before => '\vspace*{0.3\textheight}
{ \huge \bfseries ',
    :after => '\\\\[0.4cm] }',
  },
  :author => {
    :before => 'by { \large ',
    :post_proc => join_text,
    :after => '}',
  },
  :publisher => {
    :before => '\vfill

\includegraphics[width=0.15\textwidth]{./logo}~\\\\[1cm]

% Bottom of the page
{\large ',
    :post_proc => join_text,
    :after => '}',
  },
  :DEFAULT => {
  },
  :TEXT => {
  },
}

$converters[:indexterm_portion_converters] = {
  :primary => {
  },
  :secondary => {
    :before => "!",
  },
  :tertiary => {
    :before => "!",
  },
  :TEXT => {
  },
}

$converters[:indexterm_converter] =  {
  :post_proc => templated( '\index[<%= type %>]{<%= text %>}' ),
  :new_converters => $converters[:indexterm_portion_converters],
}

$converters[:section_converters] = {
  :title => {
    :before => '\section{',
    :post_proc => join_text,
    :after => '}',
  },
  :indexterm => $converters[:indexterm_converter],
  :DEFAULT => {
  },
  :TEXT => {
  },
}

$converters[:chapter_converters] = {
  :title => {
    :before => '\chapter{',
    :post_proc => join_text,
    :after => '}',
  },
  :section => {
    :new_converters => $converters[:section_converters],
  },
  :indexterm => $converters[:indexterm_converter],
  :DEFAULT => {
  },
  :TEXT => {
  },
}

$converters[:initial_coverters] = {
  :para => {
    :post_proc => strip_leading_whitespace,
  },
  :chapter => {
    :new_converters => $converters[:chapter_converters],
  },
  :indexterm => $converters[:indexterm_converter],
  :DEFAULT => {
  },
  :TEXT => {
  },
}

#*****************************
#
# Particularly verbose bits go here
#
#*****************************
$converters[:initial_coverters][:book] = {
    :before => %q{
\documentclass[letterpaper,10pt,twoside,openright]{book}
\usepackage{fontspec}
\usepackage{xltxtra}
\setmainfont{DejaVu Serif}
\setsansfont{DejaVu Sans}
\setmonofont{DejaVu Sans Mono}
\usepackage{fancybox}
% \usepackage{makeidx}
% http://tex.stackexchange.com/questions/39810/multiple-indexes-in-latex
\usepackage{imakeidx}
\usepackage[hyperlink]{cll}
\setcounter{tocdepth}{5}
\setcounter{secnumdepth}{5}
% \def\DBKcopyright{\noindent Copyright \textnormal{\copyright} Test Copyright Year 2014 Test Copyright Holder}
% \def\DBKsubtitle{Test Subtitle}

},
    :after => %q{
\printindex[general-imported]
\printindex[example]

\end{document}
},
}

$converters[:initial_coverters][:info] = {
    :new_converters => $converters[:info_converters],
    :before => <<'EOF',
%% FIXME: fill this by pulling from the <info> part of the tree
%%
%% \hypersetup{%
%% pdfcreator={DBLaTeX-0.3.4},%
%% pdftitle={The Complete Lojban Language},%
%% pdfauthor={AuthorFirstName AuthorSurName}%
%% }
% \renewcommand{\DBKindexation}{}
\makeindex[name=general-imported,title=General Index]
\makeindex[name=example,title=Index Of Examples]
\makeglossary
\begin{document}
\lstsetup
\frontmatter


%% One titlepage design, from http://en.wikibooks.org/wiki/LaTeX/Title_Creation

\begin{titlepage}
\begin{center}

% Upper part of the page. The '~' is needed because \\
% only works if a paragraph has started.
EOF

    :after => <<'EOF',

%% \textsc{\LARGE University of Beer}\\[1.5cm]

% \textsc{\Large Final year project}\\[0.5cm]

% Title
% \HRule \\[0.4cm]
% { \huge \bfseries Lager brewing techniques \\[0.4cm] }

% \HRule \\[1.5cm]

% Author and supervisor
%\begin{minipage}{0.4\textwidth}
%\begin{flushleft} \large
%\emph{Author:}\\
%John \textsc{Smith}
%\end{flushleft}
%\end{minipage}
%\begin{minipage}{0.4\textwidth}
%\begin{flushright} \large
%\emph{Supervisor:} \\
%Dr.~Mark \textsc{Brown}
%\end{flushright}
%\end{minipage}

%\vfill
%
%% Bottom of the page
%{\large \today}

\end{center}
\end{titlepage}

\tableofcontents
\mainmatter
EOF
}
