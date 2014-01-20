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

# MAPPINGS

I've set my leader to the comma. The comma is actually a command in vim:

    ,			Repeat latest f, t, F or T in opposite direction
	    		[count] times.

I don't use that command, so it works for me. Your mileage may vary. You can
change your leader by resetting it at the top of the `.vimrc` file.

## Basics

Jump to the next window:

    ,w

Turn off highlighting:

    ,h

If you're in paste mode, switch to nopaste mode, and vice versa (e.g., toggle
past mode):

    ,pp  :set invpaste<cr>

List current directory:
    ,ls  :!ls $(dirname %)<cr>

List current directory file, including hidden items:

    ,la  :!ls -al $(dirname %)<cr>

Use visual mode to indent an unindent:

    tab: indent selected lines
    shift tab: unindent selected lines

## git

My embarrassing git integration is a legacy from years ago when I used CVS,
then switched to Subversion, and now use git. I should learn to use
[fugitive](https://github.com/tpope/vim-fugitive).

    ,ca: code annotate
    ,cl: code log
    ,cr: code review
    ,cd: code commit (you cannot commit without a review)
    ,c1: find first commit with the current <cword>

## Vim

When you edit yoru `.vimrc` file, we automatically pick up the changes with:

    au! BufWritePost .vimrc source %

Source your `.vimrc`:

    ,v

Edit your `.vimrc`:

    ,V

## Perl

The various tools require the following modules:

* Data::Dumper
* Data::Dumper::Simple
* File::Path
* File::Spec::Functions
* File::Temp
* Getopt::Long
* IO::All
* IO::All;
* Modern::Perl
* Pod::Stripper;
* Term::ANSIColor;
* Test::Most
* Vi::QuickFix
* warnings::unused

These are often miserable hacks, but they work for me. They assume that when
you are in a Perl project, you stay in the home directory of said project (in
other words, you don't `cd t` or `cd lib/My/Project`).

Also, often depends on your `@INC` being set up correctly.

Add a `Data::Dumper` debugging statement and put your cursor in `Dumper()`
parens in insert mode.

    ,dd 

In visual mode, prompt for a subroutine name and extract selected lines into
that subroutine. Pastes code directly where the selected lines were. Requires
some editing and could stand to be cleaned up quite a bit.

    ,e

When your cursor is on a module, print the module version.

    ,pv

Run `perldoc` on the current buffer.

    ,pd

Run `perltidy` on current buffer, or on selected lines if in visual mode:

    ,pt

Run the Perl debugger on the current buffer:

    ,d

Rebuild my current project (requires a bash script that needs to be updated):

    ,rr

Print subroutines found in current buffer. Nasty hack.

    ,s

Heuristic to determine unused subroutines in current buffer. Don't assume
they're really unused. Instead, you'll need to put on your programmer hat to
figure it out.

    ,S

Runs a modified `perl -c` on the current buffer. Uses `warnings::unused` and
`Vi::QuickFix`. See also [this blog
post](http://blogs.perl.org/users/ovid/2010/11/vims-quickfix-mode-and-perl.html).

    ,c

If in a module, jump to its tests ("GoGo"). If in the tests, jump to the
module. Requires some hacking on the `bin/get_corresponding` file. I need to
update that to allow per-project configuration.

    ,gg

Same as `,gg`, but uses the current module name under the cursor.

    ,gc

Jump to the module name under the cursor:

    ,gm

Jump to the pod for the module name under the cursor:

    ,gp

Jumps to the sub definition (if found) of the subroutine name found under the
cursor.

    ,gs

Run the Perl code in the current buffer or, if in visual mode, runs the
currently selected lines and inserts the output after them.

    ,r

## Perl Tests

If you're in a `*.t` file, we assume you're running tests.

Run the current test file in verbose mode:

    ,r or ,t

Run the current test file and output the results into a new buffer:

    ,T

Turns all comments into explain() statements. Requires Test::Most being used
in the current test file:

    ,fp

Run all tests open in current buffers:

    ,tb
