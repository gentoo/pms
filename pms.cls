\NeedsTeXFormat{LaTeX2e}%
\newcommand{\ClassToLoad}{report}
\ProvidesClass{pms}
% Accept all options given through the loading tex file
\DeclareOption*{%
    \PassOptionsToClass{\CurrentOption}{\ClassToLoad}
}
\PassOptionsToClass{a4paper}{\ClassToLoad}
% Let the base class process all give options, either from this class
% or user defined from an outside tex file.
\ProcessOptions\relax
\LoadClass{\ClassToLoad}
\PassOptionsToPackage{T1}{fontenc}
\PassOptionsToPackage{orig,english}{isodate}
% Position caption of float environments at the top
\PassOptionsToPackage{position=top}{caption}
% Enable UTF-8 input encoding
\PassOptionsToPackage{utf8}{inputenc}
\PassOptionsToPackage{quiet}{marginnote}
\PassOptionsToPackage{nottoc,notlot,notlof}{tocbibind}
\PassOptionsToPackage{chapter}{algorithm}
% algorithmic and algorithm to be loaded last to avoid failures
\RequirePackage{%
    fontenc,	% Load extended font sets
    isodate,	% Date formatting and conversions
    typearea,	% Set page layout
    inputenc,	% Allow input methods apart from ASCII
    booktabs,	% Nicer formatting of tables
    color,	% Support more than black&white
    ifthen,	% Comfortable conditional routines
    longtable,	% Extend tables over more than one page
    array,	% Extended tabular environments
    lscape,	% Rotating pages
    marginnote, % Typeset a paragraph in the page margin
    paralist,	% Additional list environments
    parskip,	% Space between paragraphs instead of indentation
    verbatim,	% Extend the print-as-is functionality
    chngcntr,	% Redefinition of counters
    tocbibind	% Add bibliography to table of contents
}

% tex4ht workaround: hyperref needs to be loaded /after/ tex4ht injects itself
\g@addto@macro\@documentclasshook{
    \RequirePackage{
        caption,	% Extended float environment formatting
        float,		% More control over float environments
        hyperref,	% Support for hyperlinks
        algorithm,	%
        algorithmic	% Set algorithms
    }
}
\ClassInfo{pms}{Capsulation of LaTeX stuff for the Package Manager
    Specification, loaded baseclass: \ClassToLoad\MessageBreak}
% Contains information over the source control system, generated
% through Makefile
\input{vc}

% Make processing with TeX4HT possible
\newboolean{TEX4HT-HACKS}
\ifx\HCode\undefined
    \RequirePackage{%
        mathptmx,
        pdfpages	% Insert whole PDF documents as separate pages
    }
    \RequirePackage[scaled=.90]{helvet}
    \setboolean{TEX4HT-HACKS}{false}
\else
    \setboolean{TEX4HT-HACKS}{true}
\fi

% tex4ht workaround: these need to happen after loading the float package
\g@addto@macro\@documentclasshook{
    \floatstyle{ruled}
    \newfloat{listing}{tbp}{lol}[chapter]
    \floatname{listing}{Listing}
}
\newcommand{\listoflistings}{\listof{listing}{List of Listings}}

% Define own label and reference commands, that display the label in
% the page margin.
\newcommand{\featureref}[1]{\textsc{#1} on page~\pageref{feat:#1}}
\newcommand{\compactfeatureref}[1]{#1~p\pageref{feat:#1}}
\newcommand{\featurelabel}[1]{\leavevmode\label{feat:#1}%
    \ifthenelse{\boolean{TEX4HT-HACKS}}{%
        % tex4ht does not support marginnote
        \framebox{\textsc{#1}}%
    }{%
        \marginnote{\framebox{\textsc{#1}}}\ignorespaces
    }%
}
\bibliographystyle{plainurl}

% Redefine the titlepage environment not to reset the page number
\renewenvironment{titlepage}{\newpage\thispagestyle{empty}}{\newpage}

% Enumerate subsubsections, but don't include them in the toc.
\setcounter{secnumdepth}{3}
\setcounter{tocdepth}{2}

% Don't reset the footnote counter for each chapter
\counterwithout{footnote}{chapter}

% Some shorthands for the lazy ones.
% tex4ht workaround: this needs to happen after loading hyperref
\g@addto@macro\@documentclasshook{
    \renewcommand{\b}[1]{\textbf{#1}}
    \renewcommand{\i}[1]{\textit{#1}}
    \renewcommand{\t}[1]{\texttt{#1}}
}
\newcommand{\e}[1]{\emph{#1}}
\newcommand{\note}[1]{\paragraph{Note:} #1}

% Allow line breaks after underscores (but with a large penalty)
\newcommand{\origunderscore}{}
\let\origunderscore\_
\renewcommand{\_}{\origunderscore\penalty500\hskip0pt}

% Because we are lazy, we define a table environment to fulfil our needs
\newenvironment{centertable}[1]%
{
  \begin{table}
    \ifx\mycolour\undefined\else\mycolour\fi
    \centering
    \caption{#1}
  }{
  \end{table}
}

% Define a new column type P for tables, like p but with ragged-right text
\newcolumntype{P}[1]{>{\setlength\rightskip{0pt plus 1fil}}p{#1}}

% Prevent numbers in list of tables from overrunning into the table captions
\renewcommand*{\l@figure}{\@dottedtocline{1}{1.5em}{2.8em}} % was 2.3em
\let\l@table\l@figure

% Be more tolerant when formatting paragraphs, to avoid overfull boxes
\tolerance=400                   % was 200
\setlength\hfuzz{0.2pt}          % was 0.1pt
\setlength\emergencystretch{1em} % was 0

% Define some PDF meta-data.
% tex4ht workaround: this needs to happen after loading hyperref
\g@addto@macro\@documentclasshook{
    \hypersetup{%
        urlcolor=black,
        colorlinks=true,
        citecolor=black,
        linkcolor=black,
        pdflang={en},
        pdfcreator={pdfLaTeX and hyperref},
        pdfproducer={pdfLaTeX and hyperref},
    }
}
% Reads the last commit date from the Git repository and even succeeds
% when none is available
\ifthenelse{\equal{\VCDateISO}{}}
{
    \date{Generated on: \today}
}{
    \date{\printdate{\VCDateISO}}
}

% Set page title
\pagestyle{headings}
% This is some kind of hack.  We set the proportions of the text area
% and then move it 30mm to the left to increase the right (outer)
% margin.
\areaset[-30mm]{400pt}{700pt}
\setlength{\marginparwidth}{40mm}

% To find everywhere that needs updating when we add an EAPI
\newcommand{\CurrentEAPIIs}[1]{\def\TheCurrentEAPI{#1}}
\newcommand{\ChangeWhenAddingAnEAPI}[1]{\ifthenelse{\equal{\TheCurrentEAPI}{#1}}{}{\errmessage{This
needs to be updated for EAPI \TheCurrentEAPI}}}

% vim: set filetype=tex fileencoding=utf8 et tw=100 spell spelllang=en :

%%% Local Variables:
%%% mode: latex
%%% TeX-master: "pms"
%%% LaTeX-indent-level: 4
%%% LaTeX-item-indent: 0
%%% TeX-brace-indent-level: 4
%%% fill-column: 100
%%% End:
