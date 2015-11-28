pikkuwiki - Minimal personal wiki tool
======================================

Pikkuwiki is a tool for managing a personal wiki.
It's goal is to be simple, minimal, and portable.


Features
========

* All the pages are '.txt' files in the file system.
  Hierarchy is achieved using directories.

* Pages can refer to other pages to using a link syntax.
  See section "link syntax" below.

* There is NO other markup, NO servers, and NO build processes involved.
  What you see is what you get!

* Command line utility to assist at finding pages.

* Vim plugin for you Vim hackers out there!


Installing pikkuwiki
====================

Copy or link the "pikkuwiki.sh" script to anywhere in your shell's path. E.g.:

  ln -s /path/to/pikkuwiki/pikkuwiki.sh /usr/local/bin/pikkuwiki

Make sure that the script is executable:

  chmod +x /path/where/pikkuwiki/is/installed/pikkuwiki

By default, all the pages will be placed to "pikkuwiki" directory in your home
directory. If you want to customize this, set the $PIKKUWIKI_DIR to something
else.

Continue by initializing the pikkuwiki directory:

  pikkuwiki init

You're now set up! You can start adding new pages by creating new txt files in
the pikkuwiki directory.


Installing pikkuwiki Vim plugin
===============================

The easiest set up can be achieved using one of the Vim plugin managers:
  * vim-plug: https://github.com/junegunn/vim-plug
  * Vundle: https://github.com/VundleVim/Vundle.vim

For vim-plug, add the following line to your plugin list:

  Plug 'Lepovirta/pikkuwiki'

For Vundle, add the following line to your plugin list:

  Plugin 'Lepovirta/pikkuwiki'


Using the command line tool
===========================

pikkuwiki <command> [arguments]

Commands:

  init        Initialize pikkuwiki. Creates the pikkuwiki directory.

  o, open     Open a given link using EDITOR. If link is empty,
              PW_DEFAULT_PAGE or "index" is opened instead.

  v, view     Open a given link using PAGER. If link is empty,
              PW_DEFAULT_PAGE or "index" is opened instead.

  f, find     Find pages using the given pattern. Outputs the filenames of
              found links unless alternative formatting is provided.

  s, show     Show links from given page. Outputs the filenames of the found
              links unless alternative formatting is provded.

  r, resolve  Resolve filename for given filename and link combination

  h, help     Print full help text

Find arguments:

  -p          RegEx pattern to use for filtering pages.
  -F          Use alternative formatting.

Show arguments:

  -l          link or file to search links from.
  -p          RegEx pattern to use for filtering pages
  -F          Use alternative formatting. See the available formatters below.

Formatters:

  header    first line of the page
  file      file path of the page (default)
  link      link to the page from root
  pretty    the link and the header
  space     links separated by spaces (useful for bash completion list)

Examples
========

Open a page in editor:
  pikkuwiki open '~America/Canada'
  pikkuwiki o Europe/Germany

Find pages:
  pikkuwiki find 'code'
  pikkuwiki f 'eng'

Show all links in a page:
  pikkuwiki show -l Europe/Germany
  pikkuwiki s -l Europe

Show matching links:
  pikkuwiki s -l Europe/Germany -p 'Ber'

Resolve link:
  pikkuwiki resolve Europe Germany
  pikkuwiki r $PIKKUWIKI_DIR/Europe/Germany.txt Berlin


Configuring pikkuwiki
=====================

Pikkuwiki can be configured through environment variables.

  PIKKUWIKI_DIR         The directory where pages are located.
                        Default: $HOME/pikkuwiki

  EDITOR                The editor that the open command launches.
                        Default: vi

  PAGER                 The viewer that is view command launches.
                        Default: cat

  PW_DEFAULT_PAGE       The default page that is opened if no link
                        is provided for open command.
                        Default: index


Link syntax
===========

All links to other pages start with tilde (~).
All pages point to a .txt file (case sensitive).
The page which the link refers to depends on where the page that is linking.

Absolute links:
  ~/Europe            => $PIKKUWIKI_DIR/Europe.txt
  ~/Europe/Germany    => $PIKKUWIKI_DIR/Europe/Germany.txt

Relative links in '~/Europe' page:
  ~America            => $PIKKUWIKI_DIR/America.txt
  ~America/Canada     => $PIKKUWIKI_DIR/America/Canada.txt

Relative links in '~/Europe/Germany' page:
  ~Berlin             => $PIKKUWIKI_DIR/Europe/Germany/Berlin.txt
  ~Munich             => $PIKKUWIKI_DIR/Europe/Germany/Munich.txt


Using Vim plugin
================

Vim plugin provides syntax highlighting and commands for pikkuwiki pages.

The following commands are available:

  :PWOpen     Used for opening links under the cursor.
              An optional link can be supplied as a parameter to jump to an
              arbitrary page.

  :PWFind     Used for finding pages in the pikkuwiki directory.
              Filter parameter can be supplied to filter the pages.

  :PWShow     Used for finding links in the current page.
              Only available in pikkuwiki pages.
              Filter parameter can be supplied to filter links.

The following key bindings are available in pikkuwiki pages:

  gl          Opens the link under the cursor.

The following key bindings are available in pikkuwiki search window:

  <Return>    Opens the link under the cursor.


Bash auto completion
====================

In Bash, auto completion for pikkuwiki can be added by loading the
"bash_completion.sh" script. Either add the contents of the script to your
"~.bashrc" script or add the following line:

  source /path/to/pikkuwiki/bash_completion.sh


Contributing
============

All of the code for the command line tools should be included in the
"pikkuwiki.sh" script. The script should remain POSIX compatible, and should
not use any tools that are uncommon in Linux or Unix systems.

Tests can be added to "tests.sh" script.
Bash can be used in the tests script if necessary.

The Vim plugin is laid out in pathogen compatible manner:
  https://github.com/tpope/vim-pathogen

No dependencies allowed in the Vim plugin.


License
=======

(The MIT license)

Copyright (c) 2015 Jaakko Pallari


Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:


The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

