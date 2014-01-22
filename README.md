# NAME

ovid-vim - Ovid's Vim Setup

# SYNOPSIS

    git clone git@github.com:Ovid/ovid-vim.git

    ln -s ovid-vim/.vimrc ~/.vimrc
    ln -s ovid-vim/.vim ~/.vim
    # copy bin/ files to your path

# DESCRIPTION

People keep asking me for my vim setup, so I've cleaned it up a bit and am
posting it here. It's sort of old-school because I never switch to a package
manager. I also don't claim that it's a brilliant example of vim usage. It
just reflects how I used vim. Because I'm almost always hacking on Perl, it's
very Perl-specific in many ways.

I never documented this code properly because no one else was every using it.
I also **DO NOT CLAIM THIS IS SUITABLE FOR ANYONE ELSE**. You've been warned.
It's only here because people ask for it. Also, note that some things I've
told people about are not here because I need to clean up my code even more.

# FILES TO READ

You probably would be most interested in:

* `.vimrc`
* `.vim/filetype.vim`
* `.vim/ftplugin/perl.vim`

# MAPPINGS

I've set my leader to the comma. The comma is actually a command in vim:

    ,			Repeat latest f, t, F or T in opposite direction
	    		[count] times.

I don't use that command, so it works for me. Your mileage may vary. You can
change your leader by resetting it at the top of the `.vimrc` file.

## Basics

When in Perl, typing `K` when on a module name or keyword will attempt to
launch `perldoc` with the appropriate documentation.

Common commands I use:

Command | Description
--- | ---
,w        | Jump to the next window
,h        | Turn off highlighting
,pp       | Toggle paste mode
,ls       | List current directory contents
,la       | List current directory contents, including hidden files
tab       | (visual mode) indent selected lines
shift tab | (visual mode) unindent selected lines

## git

My embarrassing git integration is a legacy from years ago when I used CVS,
then switched to Subversion, and now use git. I should learn to use
[fugitive](https://github.com/tpope/vim-fugitive).

Command | Description
--- | ---
,ca  |  git annotate current file
,cl  |  git log current file
,cr  |  git review current file
,cd  |  git commit current file (you cannot commit without a review)
,c1  |  find first commit in repo with the current <cword>

The following are in the git section because they use git internally.

Command | Description
--- | ---
,g   | Prompt for a search term and search your `lib/` directory for it.
,G   | Same as `,g`, but also search your `t/` directory.
,f   | Same as `,g`, but search for whatever `<cword>` your cursor is on.

## Vim

When you edit yoru `.vimrc` file, we automatically pick up the changes with:

    au! BufWritePost .vimrc source %

Command | Description
--- | ---
,v  |  Source your `.vimrc`
,V  |  Edit your `.vimrc`

## Perl

The following non-core modules are required by some helper scripts:

* [App::Ack](https://metacpan.org/pod/App::Ack)
* [Data::Dumper::Simple](https://metacpan.org/pod/Data::Dumper::Simple)
* [IO::All](https://metacpan.org/pod/IO::All)
* [Modern::Perl](https://metacpan.org/pod/Modern::Perl)
* [Pod::Stripper](https://metacpan.org/pod/Pod::Stripper)
* [Test::Most](https://metacpan.org/pod/Test::Most)
* [Vi::QuickFix](https://metacpan.org/pod/Vi::QuickFix)
* [warnings::unused](https://metacpan.org/pod/warnings::unused)

The following core modules are required by some helper scripts:

* [File::Path](https://metacpan.org/pod/File::Path)
* [File::Spec::Functions](https://metacpan.org/pod/File::Spec::Functions)
* [File::Temp](https://metacpan.org/pod/File::Temp)
* [Getopt::Long](https://metacpan.org/pod/Getopt::Long)
* [Term::ANSIColor](https://metacpan.org/pod/Term::ANSIColor)

These are often miserable hacks, but they work for me. They assume that when
you are in a Perl project, you stay in the home directory of said project (in
other words, you don't `cd t` or `cd lib/My/Project`).

Also, often depends on your `@INC` being set up correctly.

Command | Description
--- | ---
,dd  |  Add a `Data::Dumper` debugging statement
,e   |  (visual mode) Extract subroutine
,pv  |  When your cursor is on a module, print the module version
,pd  |  Run `perldoc` on the current buffer
,pt  |  Run `perltidy` on current buffer
,pt  |  (visual mode) Run `perltidy` on selected lines
,d   |  Run the Perl debugger on the current buffer
,rr  |  Rebuild my current project (requires a bash script that needs to be updated)
,s   |  Print subroutines found in current buffer. Nasty hack.
,S   |  List unused subs in current buffer (hack)
,c   |  `perl -c` on current buffer (see \[1\])
,gg  |  GoGo to module's tests, or test's module (see \[2\])
,gc  |  Same as `,gg`, but uses the current module name under cursor
,gm  |  Jump to the module name under the cursor
,gp  |  Jump to pod for the module name under the cursor
,gs  |  Jumps to the sub definition (if found) of the sub name found under the cursor
,r   |  Run the code in the current buffer
,r   |  (visual mode) run selected lines and insert output after

1. Runs a modified `perl -c` on the current buffer. Uses `warnings::unused` and
`Vi::QuickFix`. See also [this blog
post](http://blogs.perl.org/users/ovid/2010/11/vims-quickfix-mode-and-perl.html).
2.  If in a module, jump to its tests ("GoGo"). If in the tests, jump to the
module. Requires some hacking on the `bin/get_corresponding` file. I need to
update that to allow per-project configuration.

## Perl Tests

If you're in a `*.t` file, we assume you're running tests.

Command | Description
--- | ---
,r  | Run the current test file in verbose mode
,t  | Run the current test file in verbose mode
,T  | Run the current test file and output the results into a new buffer
,fp | Turns all comments into explain() statements. Test must use Test::Most
,tb | Run all tests open in current buffers
