{
  flake.homeModules.fsh =
    { limitedColors ? false, ... }:
    let
      c16 = if limitedColors then "4" else "16";
      c17 = if limitedColors then "5" else "17";
      c18 = if limitedColors then "6" else "18";
      c26 = if limitedColors then "2" else "26";
    in
    {
      xdg.configFile."fsh/base16.ini".text = ''
        [base]
        default          = none
        unknown-token    = 1,bold
        commandseparator = 2
        redirection      = 6
        here-string-tri  = 14
        here-string-text = bg:11
        here-string-var  = 1,bg:11
        exec-descriptor  = 14,bold
        comment          = 8
        correct-subtle   = 2
        incorrect-subtle = 1
        subtle-separator = 2
        subtle-bg        = bg:10
        secondary        = clean
        recursive-base   = ${c18}

        [command-point]
        reserved-word  = ${c17}
        subcommand     = ${c17}
        alias          = ${c26}
        suffix-alias   = ${c26}
        global-alias   = ${c26}
        builtin        = ${c16}
        function       = ${c26}
        command        = ${c16}
        precommand     = 2
        hashed-command = 4
        single-sq-bracket = 5
        double-sq-bracket = 5
        double-paren   = 5

        [paths]
        path          = 7
        pathseparator =
        path-to-dir   = 7
        globbing      = 2
        globbing-ext  = 2,bold

        [brackets]
        paired-bracket = bg:8
        bracket-level-1 = 3,bold
        bracket-level-2 = 6,bold
        bracket-level-3 = 2,bold

        [arguments]
        single-hyphen-option   = ${c18}
        double-hyphen-option   = ${c18}
        back-quoted-argument   = ${c17}
        single-quoted-argument = ${c17}
        double-quoted-argument = ${c17}
        dollar-quoted-argument = ${c17}

        [in-string]
        ; backslash in $'...'
        back-dollar-quoted-argument           = 2
        ; backslash or $... in "..."
        back-or-dollar-double-quoted-argument = 2

        [other]
        variable             = 2
        assign               = none
        assign-array-bracket = 5
        history-expansion    = 6,bold

        [math]
        mathvar = 1
        mathnum = 9
        matherr = 1,bold

        [for-loop]
        forvar = 1
        fornum = 9
        ; operator
        foroper = none
        ; separator
        forsep = none

        [case]
        case-input       = 1
        case-parentheses = 5
        case-condition   = bg:10
      '';
    };
}
