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
% algorithmic and algorithm to be loaded last to avoid failures
\RequirePackage{%
    fontenc,	% Load extended font sets
    isodate,	% Date formatting and conversions
    typearea,	% Set page layout
    inputenc,	% Allow input methods apart from ASCII
    booktabs,	% Nicer formatting of tables
    color,	% Support more than black&white
    enumitem,
    fullpage,
    graphicx,	% Image support
    ifthen,	% Comfortable conditional routines
    longtable,	% Extend tables over more than one page
    lscape,	% Rotating pages
    marginnote, % Typeset a paragraph in the page margin
    paralist,	% Additional list environments
    parskip,	% Space between paragraps instead of intendation
    pdfpages,	% Insert whole PDF documents as separate pages
    verbatim	% Extend the print-as-is functionality
}

% tex4ht workaround: hyperref needs to be loaded /after/ tex4ht injects itself
\g@addto@macro\@documentclasshook{
    \RequirePackage{
        caption,	% Extended float environment formatting
        float,		% More control over float environments
        hyperref,	% Support for hyperlinks
        algorithm,	%
        algorithmic 	% Set algorithms
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
    \RequirePackage{mathptmx,
      courier
    }
    \RequirePackage[scaled=.90]{helvet}
    \setboolean{TEX4HT-HACKS}{false}
\else
    \setboolean{TEX4HT-HACKS}{true}
\fi

% tex4ht workaround: these need to happen after loading the float package
\g@addto@macro\@documentclasshook{
    \floatstyle{plaintop}
    \newfloat{listing}{tbp}{lol}[chapter]
    \floatname{listing}{Listing}
}
\newcommand{\listoflistings}{\listof{listing}{Listings}}
% Define own label and reference commands, that display the label in
% the page margin.
\newcommand{\featureref}[1]{\textsc{#1} on page~\pageref{feat:#1}}
\newcommand{\compactfeatureref}[1]{#1~p\pageref{feat:#1}}
\newcommand{\featurelabel}[1]{\marginnote{%
        \framebox{\textsc{#1}}}\label{feat:#1}
}
\bibliographystyle{plainurl}

% Some shorthands for the lazy ones.
\renewcommand{\t}[1]{\texttt{#1}}
% tex4ht workaround: this needs to happen after loading hyperref
\g@addto@macro\@documentclasshook{
    \renewcommand{\i}[1]{\textit{#1}}
}
\newcommand{\e}[1]{\emph{#1}}
\renewcommand{\b}[1]{\textbf{#1}}
\newcommand{\note}[1]{\paragraph{Note:} #1}

% Because we are lazy, we define a table environment to fullfil our
% needs
\newenvironment{centertable}[1]%
{
  \begin{table}
    \ifx\mycolour\undefined\else\mycolour\fi
    \centering
    \caption{#1}
  }{
  \end{table}
}

% Define some PDF meta-data.
% tex4ht workaround: this needs to happen after loading hyperref
\g@addto@macro\@documentclasshook{
    \hypersetup{%
        urlcolor=black,
        colorlinks=true,
        citecolor=black,
        linkcolor=black,
        pdftitle={Package Manager Specification},
        pdfauthor={Stephen P. Bennett, Ciaran McCreesh},
        pdfcreator={pdfLaTeX and hyperref},
        pdfsubject={Defining a feature set for package managers in the
            Gentoo world},
        pdflang={en},
        pdfkeywords={Gentoo, package manager, specification},
        pdfproducer={pdfLaTeX and hyperref},
    }
}
% Some metadata needed for the title page generation
\title{Package Manager Specification}
\author{Stephen P. Bennett \\
    \href{mailto:spb@exherbo.org}{spb@exherbo.org} \and Ciaran
    McCreesh \\
    \href{mailto:ciaran.mccreesh@googlemail.com}{ciaran.mccreesh@googlemail.com}}
% Reads the last commit date from the Git repository and even succeeds
% when none is available
\ifthenelse{\equal{\VCDateISO}{}}
{
    \date{Generated on: \today}
}{
    \date{\printdate{\VCDateISO}}
}

% Set page title
\pagestyle{myheadings}
\markboth{\scshape Package Manager Specification}{\scshape Package
    Manager Specification}
% This is some kind of hack.  We set the proportions of the text area
% and then move it 30mm to the left to increase the right (outer)
% margin.
\areaset[-30mm]{400pt}{700pt}

% vim: set filetype=tex fileencoding=utf8 et tw=100 spell spelllang=en :

%%% Local Variables:
%%% mode: latex
%%% TeX-master: "pms"
%%% LaTeX-indent-level: 4
%%% LaTeX-item-indent: 0
%%% TeX-brace-indent-level: 4
%%% End:
