:title: Shell Programming introduction
:data-transition-duration: 1500
:css: hovercraft.css

.. note::

    i3 config:
    bindsym $mod+F5 exec mpv --fullscreen --length=2 ~/badumts.mp4
    https://www.youtube.com/watch?v=kLwmp1PXWsk

----

Welcome 👋
==========

Expectations:

.. code-block::

    * You know what a shell is.
    * You know what bash is specifically.
    * You know how to write shell scripts.
    * You won't be an expert in anything.
    * You don't expect this workshop is complete.
    * Some entertainment.

.. note::

    My expectations:

    * You ask immediately when you did not understand something.
    * You can try commands in parallel.
    * You will be tested at the end.
    * You will not need to understand everything, but
      it's good to have a mind map of things that are possible.

    Mythenmetzsche Ausschweifungen all day long.

    Also: First try of those slides. Could happen that I forgot
    something to explain that is obvious to me, but is not for you.
    Please tell me early. I need the feedback to get the knowledge across.

    Remember: Learning bash takes usually long and you just get the intro
    today with the lemur-condensed knowledge. You need to practice it.

    About 60 slides, so even if I do 1 slide per 2 minutes, we'll still end
    up with several hours.

----

What is a shell? 🐚
=======================

.. code-block:: python

    # The dumbest interpreter on earth:
    from shlex import split
    from sys import stdin, stdout
    from subprocess import call

    while True:
        # Draw prompt:
        stdout.write('> ')
        stdout.flush()

        # Start requested program,
        # print to stdout and stderr.
        call(split(stdin.readline()))

----

Why is the shell? 🦐
====================

.. image:: images/layer-model.svg
    :width: 75%
    :class: borderless-img

----

Terminology
===========

.. code-block::

    shell    := the intepreter.
    bash     := one specific shell.
    script   := list of shell commands.
    terminal := the »UI« of the shell.

----

History ⏳
===========

TODO: funny version of wikipedia

1970: Bourne Shell.
1987: Bash 1.
2004: Bash 4

Explain Basteligkeit. Was never intended as language,
got a bit out of control.

POSIX Standard.
Cygwin

----

bash > python?
==============

🤷

.. note::

    The "ba" in "bash" stands for "bastel" -> bastel shell.

----

The End 🏚
==========

Go learn Python.

Questions?

----

Bash is »duct tape«...
=======================

...and an interactive language!
--------------------------------

Several good high potential use-cases:

* Automation
* Administration
* Deployment
* Test suites
* Oneliners
* Text-based tasks

.. note::

    glue: not in the sense you can sniff it though.
    Not a programming languages, but rather easy way to integrate
    tools made in different languages.

    Examples in GBS:

    - melon
    - test suite
    - deployment scripts

----

Advantages
==========

* Shell integrates well with other tools.
* Interactive programming.
* Bash is everywhere where Linux is.
* Easy to debug.
* Well known.
* Shell is the only IDE you'll ever need.

I postulate:
------------

.. math::

    \frac{loc(python)}{10} > loc(bash)


.. note::

    And other tools include python for more complicated
    automation tasks.

----

Disadvantages
=============

- Slow.
- Only Data type are strings.
- Really bad at math.
- Plain awkward.
- Not every program integrates well.
- Not always portable.
- Sometimes dangerous.

.. note::

    * Slow -> Not relevant usually.
    * Math -> No floating point. That's annoying.
    * Plain awkward -> And sometimes annoying. Easy to make mistakes.
    * Integration -> Only for unix philosophy programs.

    Little lie: bash also supports integers... kind of.
    But we're not talking about this here and it does not really matter.

----

Wait, what? »Dangerous«?
========================

.. image:: images/bumblebee.png

----

Different Shells
================

* Microsoft cmd.exe™
* Windows PowerShell
* Dash: Minimal
* Fish: Feelgood-Shell.
* Zsh: What I use.
* Oil: Interesting.

.. note:: bash

    - Nicht immer kompatibel
    - Viele andere, viele die sich nicht verbreitet haben.

-----

Table of Contents
=================

.. note::

    Preface:

    Comments
    Scripts = line of commands.
    Shebang

1. Variables
------------

.. note::

    - declare command (vs env)

2. Processes
------------

3. Control
----------

4. Patterns
-----------

5. Files
--------

6. Misc
-------

.. note::

    blah

----

1. Vars: Basics
====================

.. code-block:: bash

    $ PRESCHL="kackvooochel"
    $ echo "Q: Tier des Jahres? A: Der ${PRESCHL}."
    Q: Tier des Jahres? A: Der kackvooochel

.. note::

    - Always key value.
    - You don't have to quote it, but you should.
    - You can write it lower case, but if it's
      used by other parts of a script, upper case is preferred
      to tell it apart it from commands.

----

1. Vars: Inheritance #1
============================

.. image:: images/env-inheritance.svg
    :class: borderless-img

.. note::

    - Processes build a tree.
    - Each process has a list of environment variables (and values)
    - New processes inherit the variables of the previous process.
    - But: Only exported variables get inherited (unexported vars exist only in the shell)


----

1. Vars: Inheritance #2
============================

Different types in a shell:

- Exported variables
- Local variables
- Global variables

.. code-block:: bash

    # Default: Global variables.
    $ A=1
    $ echo $A
    1
    $ sh -c 'echo $A'
    <empty>
    $ export A
    $ sh -c 'echo $A'

.. note::

    Explain export command here.

    Show that you can also prefix a command with a variable.

----

1. Vars: Substitutions
===========================

.. code-block::

    > V="preschl is a droddl"
    > echo "${V/droddl/kackvoochel}"
    > echo "${W:-default}"
    > echo "${W:-${V}}"

More info `here <https://tldp.org/LDP/abs/html/parameter-substitution.html>`_.

----


1. Vars: Special Characters
================================

.. todo: Is that slide really that relevant?

.. code-block:: bash

    $ | ; & ' " : {} \ > < * ? -- !

----

1. Vars: Quoting
=====================

.. code-block:: bash

    "Hello ${who}"  # Several strings belonging together.
    'Hello ${who}'  # Literal strings, no escaping needed.

.. note::

    Prefer single quotes to avoid surprises,
    use double quotes if you need to have

----

1. Vars: source
================

.. code-block:: bash

    $ echo "SOURCED_VARIABLE=kikeriki" > /tmp/my-vars
    $ cat /tmp/my-vars
    SOURCED_VARIABLE=kikeriki
    $ echo SOURCED_VARIABLE
    <empty>
    $ source /tmp/my-vars
    $ echo SOURCED_VARIABLE
    kikeriki

.. note::

    - Important technique!
    - Can also execute code.
    - Often used for configuration.

    Exercise: Name at least one file you source regularly!
    Also one GBS specific.

----

1. Vars: Pre-Existing
=====================

.. code-block:: bash

    $RANDOM
    $HOME
    $PWD
    $USER
    # ...

.. note::

    There are more, but those are the important ones.
    Also some are not listed here: $? $0 etc.

----

2. Processes
============

TODO: diagram with process.

.. code-block:: bash

    $ pstree


Oldest bash joke there is:

.. code-block:: bash

    unzip;strip;touch;finger;mount;fsck;
    more;yes;fsck;fsck;fsck;umount;sleep


.. note::

    Whenever you type in a command you start a new process.
    Again, processes form a big tree. But often you want
    to communicate and glue processes together to do something cool.

----

2. Processes: Parameters & Arguments
====================================

.

----

2. Processes: Streams
=====================

redirects; stdin + stdout + stderr

----

2. Processes: Pipes
====================

.

----

2. Processes: Composition
=========================

.. code-block:: bash

    true && echo 'Hey!'
    false || echo 'Ho'
    echo 'Ha!' ;; echo 'He!'

----

2. Processes: Jobs
==================

.. code-block:: bash

    (sleep 5 && echo 'im late!') &
    fg
    <Ctrl-Z>

----

2. Processes: Subshell
======================

.. code-block:: bash

    melon --token "$(melon login)" device list

----

3. Control: if
==============

.. code-block:: bash

    A=1
    if [ "${A}" -gt 0 ]; then
        echo "Wow."
    else
        echo "I can haz math?"
    fi

----

3. Control: while
=================

.. code-block:: bash

    while ! curl -s www.google.de > /tmp/blah; do
        echo 'retrying in 1s'
        sleep 1
    done

----

3. Control: for
===============

.. code-block:: bash

    for x in "$(seq 0 10)"; do
        echo "${x}"
    done

----

3. Control: case
================

.. code-block:: bash

    space=$RANDOM
    case $space in
    [1-6]*)
      echo "All good."
      ;;
    [7-8]*)
      echo "Start thinking about cleaning out some stuff."
      ;;
    9[1-9])
      echo "Better hurry with that new disk..."
      ;;
    *)
      echo "What is this?"
      ;;
    esac

.. note::

    More explanation on wildcards and regex follow later on.

----


3. Control: Functions
=====================

.. code-block:: bash

    #!/bin/bash

    greeting() {
        echo Hello "$1"
    }

    greeting kackvooochel

----


3. Control: Specials
====================

.. code-block:: bash

    timeout
    xargs

.. note::

    Interesting part of learning a new language is always
    seeing concepts that no other language has.

----

4. Patterns: Wildcards
======================

.. code-block:: bash

    ls /dev/sd?
    ls /dev/sd[a-z][1-9]
    cp report_{old,new}.pdf /tmp
    ls *.md
    ls **/README.md

.. note::

    bash feature, often sufficient.

----

4. Patterns: Regex
==================

anchors and blah

----

4. Patterns: grep
=================

crap

----

4. Patterns: sed
================

crap

----

4. Patterns: head, tail
=======================

logs

----

4. Patterns: sort, uniq, wc
===========================

TODO

----

5. Patterns: Directories
========================

explain directory structure

cd
ls
pwd
mkdir
find

du

TODO: split up in paths and directories

basename
dirname

----

5. Files: I/O
=============

cat, tac
redirects

cp, mv, rm
ln, touch
file

chmod, users etc. I leave that out for now.
Not because it's not important but because it's kinda boring.

----

6. Misc: bashrc
===============

``source``-able file that gets sourced automatically.

----

6. Misc: History
================

TODO: history

Ctrl-r

----

6. Misc: Math
=============

.. code-block:: bash

    $ echo $((1 + 1))
    2

----

6. Misc: jq
===========

.. code-block:: bash

    melon device list --json | \
        jq '.[] | select(.currentVersion|test("330.9.1-.*")) \
                | [.id, .serialNO, .customerID] \
                | @tsv
                '


----

6. Misc: Shortcuts
==================

.. code-block:: bash

    Ctrl-A = Go to ANFANG
    Ctrl-E = Go to ENDE
    Ctrl-W = Delete WORD
    Ctrl-C = Seng SIGINT to current process
    Ctrl-D = Close stdin (causing EOF)
    Ctrl-Z = Background current process
    Ctrl-L = Clear screen.

----

6. Misc: Stuff #1
=================

sleep
date
rg
fzf

sha1sum
mktemp

----

6. Misc: Stuff #2
=================


yes
tee
dd
od
df
watch

----

6. Misc: Stuff #3
=================


more and less (and most)

----

6. Misc: shellcheck
===================

.. note::

    Whenever you push a shell script or work on it
    I *expect* you to use shellcheck on it.

----

Exercises
=========

TODO: Check tlpd.org for examples

- Explain what X command does.
- Write oneliner for task X.

----

Last Words
==========

Things I left out:

* Arrays.
* User and rights.
* Networking commands.
* Argument Parsing.
* Version control related.
* Containers.
* Debugging / Performance.
* Man pages.
* ...

I trust you can now read the docs.
----------------------------------

..Questions?

----

References
==========

Bash Bible:
-----------

https://tldp.org/LDP/abs/html/index.html

Art of Unix Programming
-----------------------

http://www.catb.org/%7Eesr/writings/taoup/html/index.html

Manpages
--------

.. code-block:: bash

    whatis cp
    man cp

