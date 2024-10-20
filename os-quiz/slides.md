---
marp: true
style: |
  /* Make sure the font is there */
  @import url('https://fonts.googleapis.com/css2?family=Roboto+Slab:wght@100..900&display=swap');
  @import url('https://fonts.googleapis.com/css2?family=Kalam:wght@300;400;700&display=swap');

  .columns {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
  h1 {
      font-family: Roboto Slab;
      color: #1870A2;
  }
  p {
      font-family: Roboto Slab;
  }
  #author, .small {
    font-size: 20px;
  }
  #author {
    margin-top: 4.5cm;
  }
  .handwritten {
    font-family: "Kalam", cursive;
    font-weight: 600;
    font-style: normal;
  }

  #strikethrough  {
    color: #cc0030;
    text-decoration: line-through;
    text-decoration-thickness: 0.1cm;
  }
  #strikethrough-inner  {
    color: #455a64;
  }
  #easy {
    position: relative;
    bottom: -0.75cm;
    margin-left: -2cm;
    font-size: 35px;
    color: #455a64;
  }
  .spice {
    position: fixed;
    left: 1cm;
    bottom: 1cm;
  }

theme: gaia
title: Linux Quiz
author: Chris Pahl
class:
  - uncover
---

<link rel="icon" type="image/x-icon" href="./favicon.ico">

<!-- _class: lead -->

# An esoteric (but useful) Linux quiz

----

<!-- paginate: true --->

# Rules

<!--
TODO: Idea: Get to know some less known features, although no guarantee on being completed.
-->

- There are **25** questions.
- Every correct answer gets **one** point.
- Each question is discussed **after** being answered by everyone.
- Please **raise your hand** when you decided on an answer.
- You have **~30 seconds** at most for each question.
- The questions are getting more and more difficult.
- Don't take yourself too serious.

----

# How to remember `tar` commands?

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
tar $X archive.tar.bz2
```

![width:500px](images/xckd_tar.png)

</div>
<div>

**What are the correct options for `$X`?**

1. `xf`
1. `xfv`
1. `xfvz`

</div>

----

# Variable Expansion I

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
sh -c 'A=1; echo $A'
```

</div>
<div>

**What does it print?**

1. `1`
1. Just a newline.
1. `$A`

</div>

----

# Variable Expansion II

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
A=1 sh -c 'echo $A'
```

</div>
<div>

**What does it print?**

1. `1`
1. Just a newline.
1. `$A`

</div>

----

# Variable Expansion III

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
B= C=1 echo "${A:-${B:-C}}"
```

</div>
<div>

**What does it print?**

- (empty)
- `1`
- `C`

</div>

----

# Redirections

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
cat < /dev/zero > /dev/null
```

</div>
<div>

**What will happen?**

1. Slowly filling up your memory.
1. Just blocks forever, grinding one CPU core.
1. Just blocks forever, consuming no CPU.
1. Exits immediately.

</div>

----

# Multiprocessing

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
for i in $(seq 0 10); do
  {
    sleep $i
    echo "$i"
  } &
done
wait
```

</div>
<div>

**What will happen?**

1. Prints the numbers 0-10 in order & delayed.
1. Prints the numbers 0-10 in no particular order instantly.
1. Prints 0 (sometimes) and exits.

</div>

----

# cgroups

<p class="spice">🌶</p>

**What are `cgroups`?**

1. They allow setting resource limits for users and processes.
1. They allow grouping connections into firewall chains.
1. They are self-help groups for C programmers.

----

# What happens if you do this?

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
cd /..
```

</div>
<div>

1. Errors out.
1. You change directory to `/`
1. System crash.
1. Easter egg message.

</div>

----

# What should be in every script?

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
set -eu            # 1.
set -euo pipefail  # 2.
set -x             # 3.
#!/bin/bash        # 4.
set -n             # 5.
```

</div>
<div>

- 1 & 4
- 2 & 4
- 2, 3 & 4
- 1, 3 & 4
- 1, 2, 3 & 4

</div>

----

# Exit codes

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
[ 1 -gt 2 ] || { echo 'hi' } && { echo 'ih' }
```

</div>
<div>

**What will it print?**

1. `hi`
1. `ih`
1. `hi` & `ih`

</div>

----

# Quotation

<!-- What happens when "$PREFIX" is empty or has a space in it? -->

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
rm -rf "$PREFIX/usr/bin" # 1.
rm -rf '$PREFIX/usr/bin' # 2.
rm -fr  $PREFIX/usr/bin  # 3.
```

</div>
<div>

**What option is the safest?**

1. 1
1. 2
1. 1 & 3 are both fine.
1. All are equally safe.

</div>

----

# Imaginary Oneliner

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
# Imagine you write a oneliner to recursively
# delete all empty directories in your home directory.
# 
# There are several ways to do it, but only one
# answer here is correct.
```

</div>
<div>

**What commands could you use to do that?**

1. `find`, `rmdir`
1. `find`, `rm`, `grep`, `xargs`
1. `ls`, `rm`
1. `ls`, `grep`, `rmdir`

</div>

<!--
find ~ -type d -empty -exec rmdir {} \;
-->

<!--
TODO: Not good enough probably.
----

# Which one of the following directories actually have physically files in them? 🌶

- /var
- /dev
- /tmp
- /proc
-->

----

# Built-in Redis?

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
touch file
setfattr -n user.gbs.key -v 'value' file
getfattr -n user.gbs.key file
```

</div>
<div>

**What is printed?**

1. `value`
1. Permission denied.
1. You just made this stuff up.

</div>

----

# Knife, Fork, Light

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
# Tip: Don't know? Try it out!
:(){ :|:& };:
```

</div>
<div>

**What is printed?**

- Nothing
- `:` infinitely.
- `:` just once.

</div>

----

# Wildcards

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
mkdir a b c; cp -r {a,b,c}
```

</div><div>

**What will happen?**

1. Copy directories a, b into c
1. Error: Cannot copy `c` into itself
1. Error: Missing destination

</div>

----

# Permissions I

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
chmod 0432 file
```

</div>
<div>

**What permissions does `file` have now?**

1. `-wx-r--r-x`
1. `r---wx-w-`
1. `rwx-rw--r--`

</div>

----

# Permissions II

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
mkdir dir
chmod -x dir
cd dir
```

</div>
<div>

**What happens?**

1. Working dir is changed to `dir`.
1. `Permission denied`
1. You need to use `sudo cd`.

</div>

----

# Logins

<!---
TODO: Maybe rather do the sudo 3-times entered reset trick?
-->

<p class="spice">🌶</p>

**Where are Linux logins stored?**

1. `/etc/shadow`
1. `/etc/passwd`
1. `/etc/group`

----

# Mario hates pipes

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
sleep 5 | echo "It's a me, Mario\!"
```

</div>
<div>

**Will this print immediately?**

1. Yes.
1. No.
1. Ha, it never will.

</div>

----

# What does this print?

<p class="spice">🌶🌶</p>

<div class="columns">
<div>

```bash
# Hint: the `unshare` util
# starts programs in a new namespace.
unshare --user whoami
```

</div>
<div>

**What will this print?**

- `nobody`
- `root`
- Your current user.

</div>

----

# HUP Guessing

<p class="spice">🌶🌶</p>

<div class="columns">
<div>

```bash
nohup \
  sh -c 'sleep 5 && echo hi > /tmp/greetings' &
exit
```

</div>
<div>

**What will happen?**

1. The file gets created always.
1. The file gets created sometimes.
1. The file does not get created.

</div>

----

# What is this?

<p class="spice">🌶🌶</p>

<div class="columns">
<div>

```bash
cat <(yes)
```

</div>
<div>

**What will happen?**

1. Errors out (Syntax error)
1. Errors out (No such file)
1. Just one `y`
1. Infinite `y`

</div>

----

# Brains and Bits

<p class="spice">🌶🌶</p>

<div class="columns">
<div>

![width:250px](images/zombie.png)

</div>
<div>

**Zombie processes...**

1. ...hang in a system call and cannot be killed.
1. ...children processes that have finished executing, but have not been cleaned up yet.
1. ...have exited before but still continue to run because some threads are not finished.

<!--
NOTE: Unkillable processes are usually in D (Uninterruptable sleep), usually when 
the process called into the kernel and e.g. a driver does not return a result.
-->

</div>

----

# `bash` Pointers

<p class="spice">🌶🌶</p>

<div class="columns">
<div>

```bash
var=USER
echo "${!var}"
  ```

</div>
<div>

**What will this print?**

1. Prints an empty string.
1. Prints your login user name.
1. Prints `!var`

</div>

----

# The `setuid` bit

<p class="spice">🌶🌶</p>

<div class="columns">
<div>

```bash
chmod u+s ./some/binary
  ```

</div>
<div>

**What is the `setuid` bit doing?**

1. It executes the binary with the rights of the owner.
1. It runs the binary always as root.
1. Only the owner may use this binary.

</div>

----

# Symlinks I

<p class="spice">🌶🌶</p>

<div class="columns">
<div>

```bash
ln -s a b
ln -s b a
cat a
```

</div>
<div>

**What error will this get you?**

- `No such file or directory`
- `Too many levels of symbolic links`
- `b is a directory`

</div>

----

# Symlinks II

<p class="spice">🌶🌶🌶</p>

<div class="columns">
<div>

```bash
mkdir -p Na; cd Na
ln -s .. Na
cd Na; cd Na; cd Na
touch batman
realpath batman
```

</div>
<div>

**What does this print?**

1. `/tmp/Na/batman`
1. `/tmp/Na/Na/Na/Na/batman`
1. `/tmp/batman`

</div>

----

# Segmentation fault

<p class="spice">🌶🌶🌶</p>

<div class="columns">
<div>

![width:400px](images/sigsegv.png)

</div>
<div>

**What happens when a program ignores a SIGSEGV?**

1. It gets killed anyways.
1. It gets killed on receciving the second one.
1. It continues to run. (actually this one)

</div>

----

# Mystique `chattr`

<p class="spice">🌶🌶🌶</p>

<div class="columns">
<div>

```bash
chattr +i ./file
```

</div>
<div>

**What effect does this have?**

1. It makes `file` immutable. *Not even* root can change it.
1. It makes `file` immutable. *Only* root can change it.
1. You just made this up.

</div>
