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
\PassOptionsToPackage{scaled=0.92}{helvet}
\PassOptionsToPackage{orig,english}{isodate}
% Dimensions of the text area. Define a narrow left margin to make
% room for margin notes in the right (outer) margin
\PassOptionsToPackage{textwidth=400pt,textheight=684pt,
    left=20mm,marginparsep=10pt,marginparwidth=40mm,
    vmarginratio=1:2,includehead}{geometry}
% Enable UTF-8 input encoding
\PassOptionsToPackage{utf8}{inputenc}
\PassOptionsToPackage{quiet}{marginnote}
\PassOptionsToPackage{nohyphen}{underscore}
\PassOptionsToPackage{hang,flushmargin}{footmisc}
\PassOptionsToPackage{nottoc,notlot,notlof}{tocbibind}
\PassOptionsToPackage{hyphens}{url} % url.sty implicitly loaded by hyperref
\PassOptionsToPackage{hyperfootnotes=false}{hyperref} % footmisc compatibility
\PassOptionsToPackage{local}{gitinfo2}
\PassOptionsToPackage{chapter}{algorithm}
% algorithmic and algorithm to be loaded last to avoid failures
\RequirePackage{%
    fontenc,    % Load extended font sets
    isodate,    % Date formatting and conversions
    geometry,   % Set page layout
    inputenc,   % Allow input methods apart from ASCII
    booktabs,   % Nicer formatting of tables
    ifthen,     % Comfortable conditional routines
    calc,       % Infix notation arithmetic
    longtable,  % Extend tables over more than one page
    array,      % Extended tabular environments
    lscape,     % Rotating pages
    marginnote, % Typeset a paragraph in the page margin
    paralist,   % Additional list environments
    parskip,    % Space between paragraphs instead of indentation
    underscore, % Allow simple _ instead of \_
    footmisc,   % Customise footnotes
    chngcntr,   % Redefinition of counters
    tocbibind,  % Add bibliography to table of contents
    float,      % More control over float environments
    gitinfo2    % Metadata from git
}

% Make processing with TeX4HT possible
\newboolean{TEX4HT-HACKS}
\ifx\HCode\undefined
    \RequirePackage{%
        mathptmx,       % Use Postscript fonts: Times ...
        helvet,         % ... and Helvetica
        pdfpages        % Insert whole PDF documents as separate pages
    }
    \setboolean{TEX4HT-HACKS}{false}
\else
    \setboolean{TEX4HT-HACKS}{true}
\fi

% tex4ht workaround: hyperref needs to be loaded /after/ tex4ht injects itself
\g@addto@macro\@documentclasshook{
    \RequirePackage{%
        hyperref,       % Support for hyperlinks
        algorithm,      %
        algorithmic     % Set algorithms
    }
}

\ClassInfo{pms}{LaTeX class for the Package Manager Specification,
    loaded baseclass: \ClassToLoad\MessageBreak}

% Define own label and reference commands, that display the label in
% the page margin.
\ifthenelse{\boolean{TEX4HT-HACKS}}{%
    \newcommand{\featureref}[1]{\hyperref[feat:#1]{\textsc{#1}}}
    \newcommand{\compactfeatureref}[1]{\featureref{#1}}
    \newcommand{\featurelabel}[1]{\leavevmode\label{feat:#1}%
        % tex4ht does not support marginnote
        \framebox{\textsc{#1}}}
}{%
    \newcommand{\featureref}[1]{\textsc{#1} on page~\pageref{feat:#1}}
    \newcommand{\compactfeatureref}[1]{p.\,\pageref{feat:#1}}
    \newcommand{\featurelabel}[1]{\leavevmode\label{feat:#1}%
        \marginnote{\framebox{\textsc{#1}}}\ignorespaces}
}
% Change marginnote test to pretend that landscape pages are odd numbered
\g@addto@macro\@mn@margintest{%
    \ifdim\columnwidth>\textheight\@tempswatrue\fi
}

% Support url fields in bibliography entries
\bibliographystyle{unsrturl}

% Redefine the titlepage environment not to reset the page number
\renewenvironment{titlepage}{\newpage\thispagestyle{empty}}{\newpage}

% Enumerate subsubsections and include them in the toc
\setcounter{secnumdepth}{3}
\setcounter{tocdepth}{3}

% Don't reset the footnote counter for each chapter
\counterwithout{footnote}{chapter}

% Some shorthands for the lazy ones.
% tex4ht workaround: this needs to happen after loading hyperref
\g@addto@macro\@documentclasshook{
    \renewcommand{\i}[1]{\textit{#1}}
    \renewcommand{\t}[1]{\texttt{#1}}
}
\newcommand{\note}[1]{\begin{trivlist}\item\textbf{Note:} #1\end{trivlist}}

% Because we are lazy, we define a table environment to fulfil our needs
\newenvironment{centertable}[1]%
{
  \begin{table}
    \centering
    \caption{#1}
  }{
  \end{table}
}

% Define a new column type P for tables, like p but with ragged-right text
\newcolumntype{P}[1]{>{\setlength\rightskip{0pt plus 1fil}}p{#1}}

% Redefine headings for list of tables/figures/algorithms
\renewcommand{\listtablename}{Tables}
\renewcommand{\listfigurename}{Figures}
\g@addto@macro\@documentclasshook{
    \renewcommand{\listalgorithmname}{Algorithms}
}

% Define a float environment for listings
\floatstyle{ruled}
\newfloat{listing}{tbp}{lol}[chapter]
\floatname{listing}{Listing}
\newcommand{\listoflistings}{\listof{listing}{Listings}}

% Prevent page break before a list
\newcommand{\nobreakpar}{\par\nobreak\@afterheading}

% Silence hyperref messages (see hint 11.3 in the hyperref manual)
\providecommand*{\toclevel@algorithm}{0}
\providecommand*{\toclevel@listing}{0}

% We always place captions above floats, so redefine vertical spacings
% Don't use the "caption" package because it interferes with TeX4ht
\setlength\belowcaptionskip{\abovecaptionskip}
\setlength\abovecaptionskip{0pt}

% Prevent numbers in list of tables from overrunning into the table captions
\renewcommand*{\l@figure}{\@dottedtocline{1}{1.5em}{2.8em}} % was 2.3em
\let\l@table\l@figure

% Be more tolerant when formatting paragraphs, to avoid overfull boxes
\tolerance=400                   % was 200
\setlength\hfuzz{0.2pt}          % was 0.1pt
\setlength\emergencystretch{1em} % was 0

% Don't add extra vertical space, to avoid underfull boxes. Only affects
% two-sided layout, for one-sided it is already the default
\raggedbottom

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
\ifthenelse{\equal{\gitCommitterDate}{(None)}}{%
    \date{Generated on: \today}
    \newcommand{\commitinfo}{}
}{%
    \date{\printdate{\gitCommitterDate}}
    \newcommand{\commitinfo}{%
        This version corresponds to commit \gitAbbrevHash
        \ifthenelse{\equal{\gitBranch}{\detokenize{master}}}{}
        { on branch \gitBranch}%
        \ifthenelse{\equal{\gitDirty}{}}{}{ with local changes}.%
    }%
}

% Set page title
\pagestyle{headings}

% To find everywhere that needs updating when we add an EAPI
\newcommand{\CurrentEAPIIs}[1]{\def\TheCurrentEAPI{#1}}
\newcommand{\ChangeWhenAddingAnEAPI}[1]{%
    \ifthenelse{\equal{\TheCurrentEAPI}{#1}}{}{%
        \errmessage{This needs to be updated for EAPI \TheCurrentEAPI}%
    }%
}

% vim: set filetype=tex fileencoding=utf8 et tw=80 spell spelllang=en :

%%% Local Variables:
%%% mode: latex
%%% TeX-master: "pms"
%%% LaTeX-indent-level: 4
%%% LaTeX-item-indent: 0
%%% TeX-brace-indent-level: 4
%%% fill-column: 80
%%% End:
