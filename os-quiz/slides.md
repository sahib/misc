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

# An <span id="strikethrough"><span id="strikethrough-inner">&hairsp;useful&hairsp;</span></span></span><span id="easy" class="handwritten">obscure</span> Linux quiz

<p id="author">🄯 <a href="https://sahib.github.io">Chris Pahl</a> 2024 (<a href="https://github.com/sahib/misc/tree/master/os-quiz">source</a>)</p>

![bg right width:750px](./images/tux.jpeg)

----

<!-- paginate: true --->

# Rules

<!--
Idea this time:
Get to know some less known features, although no guarantee on being completed.
-->

- There are **25** questions.
- Every correct answer gets **one** point.
- Each question is discussed **after** being answered by everyone.
- Please **raise your hand** when you decided on an answer.
- You have **~30 seconds** at most for each question.
- The questions are getting more and more difficult.
- Don't take yourself too serious.
- Solution are in the presenter notes.

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

1. `xfJ`
1. `xfv`
1. `xfvz`

</div>

<!--
Answer 2. It let's tar decide which compression to use.
All other answers force either gzip or xz. Don't even specify it.
-->

----

# Passwords

<p class="spice">🌶</p>

<div class="columns">
<div>

```
1. export CP_BASIC_AUTH="rrX_$uY%s"
2. task dev
3. # trying to log-in with that password - it doesn't work!
```

</div>
<div>

**What might have happened?**

1. Application does not handle all passwords.
1. Application did not receive the right password.
1. The wrong password was copied to the browser.

</div>

<!--
Answer 2. Since we had double quotes and the password had a $u it was replaced before passing it
to the application.
-->

----

# Variable Expansion II

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

<!--
Answer 1. The expansion works normally. The single quotes don't have an effect here,
as the variable definition is inside of the shell.
-->

----

# Variable Expansion II

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
A=1 sh -c "echo $A"
```

</div>
<div>

**What does it print?**

1. `1`
1. Just a newline.
1. `$A`

</div>

<!--
Answer 2. Due to the double quotes the variable gets expanded immediately, not in the subprocess.
The `A=1` prefix just passes the variable to the subprocess, but it is not defined in the bash process
therefore not being available during expansion.
-->

----

# Variable Expansion III

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
B= C=4 echo "${A:-${B:-C}}"
```

</div>
<div>

**What does it print?**

- (empty)
- `4`
- `C`

</div>

<!--
Answer 3.
The `:-` is the default syntax. If the first variable is empty or non-existing, it tries the expansion after the dash.
Since A does not exist and B is empty we go through to C. We don't have a $ here, so it's just prints the literal `C`.
-->

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

<!--
Answer 2.
/dev/zero produces an endless stream of zero bytes. It redirects those to /dev/null which behaves like a black hole.
`cat` will however grind some CPU because it is still copying those bytes for no particular reason.
Since just a single buffer is used, the memory usage doe not increase.

This is useful if you have a program that just processes data streams and you want to measure how quick it is.
This depends on memory speed only, no filesystem involved.
-->

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

<!--
Answer 1. The {} syntax allows us to put several commands in a process group. The & will send this group to the background.
The order of execution is not guaranteed, but since there's a sleep in the code it is very likely that the order is correct.
The wait at the end waits all background jobs are done.
-->

----

# cgroups

<p class="spice">🌶</p>

**What are `cgroups`?**

1. They allow setting resource limits for users and processes.
1. They allow grouping connections into firewall chains.
1. They are self-help groups for C programmers.

<!--
Answer 1. Docker uses this a lot.
-->

----

# To root and beyond

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
cd /..
```

</div>
<div>

**What happens?**

1. Errors out.
1. You change directory to `/`
1. System crash.
1. Easter egg message.

</div>

<!--
Answer 2. The `..` reference is actually the very same inode as /.
This is implemented in the VFS layer of linux.
-->

----

# Guidelines

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
set -eua           # 1.
set -euo pipefail  # 2.
set -x             # 3.
#!/bin/bash        # 4.
set -n             # 5.
```

</div>
<div>

**What should be in every script?**

- 1 & 4
- 2 & 4
- 2, 3 & 4
- 1, 3 & 4
- 1, 2, 3 & 4

</div>

<!--
Answer 2 (2 & 4).

I hope most of you know already. ;-)

-e: Exit on errors (exit code != 0)
-u: Exit when variable is undefined (otherwise just evals to empty string)
-o pipefail: Like -e, but does not mask errors in a pipe.

The shebang is for executing the script directly and making sure that we had bash in mind when developing.
-->

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

<!--
Answer 3 (both).

The first command has a negative exit code, therefore we execute `hi`.
The `&&` does not behave like a `else` but executes when the first echo was executed right - which is the case.
-->

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

<!--
Answer 1.

People had installer scripts where the prefix container spaces. This made `rm` delete all of `/usr` which sucked a lot.
-->

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
Answer 1.

The most straightforward way:
find ~ -type d -empty -exec rmdir {} \;

If somebody finds a way with the other commands: That gets one point too.
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

<!--
Answer 1.

xattr are (in theory) a useful feature, as they allow embeding metadata directly in the file itself.
This would make implementing an object store with only a filesystem very easy and also with decent performance.

The tricky part is just that the info usually gets lost when transfering files to other filesystems (e.g. using rsync)
Also, they do not work on all filesystems. Still a good feature to remember for embedded use cases.
-->

----

# Knife, Fork, Scissor & Light

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

<!--
Answer 1.

Well, it's a fork bomb.
It does not print anything, it just destroys your computer.
If you executed it: Well, that's how you learn.
-->

----

# Wildcards

<p class="spice">🌶</p>

<div class="columns">
<div>

```bash
mkdir a b c
cp -r {a,b,c}
```

</div><div>

**What will happen?**

1. Copy directories a, b into c
1. Error: Cannot copy `c` into itself
1. Error: Missing destination

</div>

<!--
Answer 1.
That just evaluates to `cp -r a b c`. No tricks here.
-->

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

<!--
Answer 2.

Bit 3 = 4: read
Bit 2 = 2: write
Bit 1 = 1: exec

4 = read
3 = write + exec
2 = write
-->

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

1. Working directory is changed to `dir`.
1. `Permission denied`
1. You need to use `sudo cd`.

</div>

<!--
Answer 2.

For directories the permission flag means "you shall not pass".
-->

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

<!--
Answer 1.

echo does nothing with stdin, it cannot block on it therefore.
The string is printed immediately.
-->

----

<!-- # What does this print? -->
<!---->
<!-- <p class="spice">🌶🌶🌶</p> -->
<!---->
<!-- <div class="columns"> -->
<!-- <div> -->
<!---->
<!-- ```bash -->
<!-- # Hint: the `unshare` util -->
<!-- # starts programs in a new namespace. -->
<!-- unshare --user whoami -->
<!-- ``` -->
<!---->
<!-- </div> -->
<!-- <div> -->
<!---->
<!-- **What will this print?** -->
<!---->
<!-- - `nobody` -->
<!-- - `root` -->
<!-- - Your current user. -->
<!---->
<!-- </div> -->
<!---->
<!-- <!-- -->
<!-- Answer 1, surprisingly. -->
<!---->
<!-- A newly created namespace has no users, not even root. -->
<!-- We first to create a new user before we can continue -->
<!-- --> -->
<!---->
<!-- ---- -->

# Orphanage

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

<!--
Answer 1.
nohup lets the cmd passed as its input ignore the SIGHUP signal.
This signal is send to a process if it's parent has died. If we ignore it, we just continue to live.
Since our parent process  died we get reparanted to be a child of PID 1 (which is usually systemd).
-->

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

<!--
Answer 4

This trick is called process subsitution. It is *very* powerful.
With normal piping (|) you can connect one process to another. If you want to
do the same with several processes (e.g. have a command that takes in the output of 5 other programs)
then you either have to rely on tricks like `tee` or this syntax here.

https://tldp.org/LDP/abs/html/process-sub.html
-->

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
Answer 2.

Despite the name, they are usually not dangerous and do not need to be killed.
Killing them might even trigger bugs, as the process that created them might still
want to retrieve the result of this child.

They get created when a parent process creates a child, let it run and exit but does
not wait() on it's result. Only when this is done the kernel can be sure that the result
of this process is not required anymore.

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

<!--
Answer 2.

The ! part allows indirection in reading variables, effectively behaving like pointers.
Not really like C, but still allows dynamic referencing.
-->

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

<!--
Answer 1.

This is a terrible relict from old times, but it is still good to know it exists.
On my system there are ~50 of them still:

sudo find /usr /bin /sbin -perm -4000

Most of them are processes that require to be run with elevated right,
even if they are executed as regular users. (`su` for example).

If you think you need this: You probably don't.
-->

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

1. `No such file or directory`
1. `Too many levels of symbolic links`
1. `b is a directory`

</div>

<!--
Answer 2.

Since they point to each other they build a loop.
Most syscalls that deal with symlinks have a protection for this,
but this can happen in user space as well. If you handle symbolic links
you should always prepared to have edge cases where you managed to have loops.

This kind of bug can easily bring servers down.
-->

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

<!--
Answer 3.

That's a weird one. There are two entries with the name `Na`: `/tmp/Na` and `/tmp/Na/Na` (which is pointing to `/tmp/`). If we enter `/tmp/Na/Na` we get back to `/tmp/` - like in a portal. If we
repeat that we go into `/tmp/Na` and doing it another time it's `/tmp/` again.
The file is therefore created in `/tmp`.

What might be misleading: You probably though it would have worked like `ln -s . Na`
-->

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
1. It gets killed on receiving the second one.
1. It continues to run, but defunct.
1. It continues to run normally.

</div>

<!--
Answer 3.

The handler can ignore the signal, but after running the signal handler you're
just thrown back to where you came before. This means that the signal is emitted again
as the same instruction will crash again. Even trying to fix the crash reason in the
handler does not seem to work as seen in sigsegv.c
-->

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

<!--
Answer 1.

Technically, root can change it, but one has to run `chmod -i ./file` first.
-->

----

# Sleep & Suspend

<p class="spice">🌶🌶🌶</p>

<div class="columns">
<div>

```go
  // Assume this runs on a system with
  // a real time clock.
  now := time.Now()
  time.Sleep(time.Minute)
  // immediately `systemctl suspend` for 1m
  fmt.Println(time.Since(now))
```

</div>
<div>

**What time is printed?**

1. Roughly 2m.
1. Roughly 1m.
1. A negative value.
1. It is undefined.

</div>

<!--
Answer 1.

When resuming from suspend the rtc is read, informing us about the correct time.
However, sleep does not know about this and works by checking how many cpu cycles
have passed (i.e. a monotonic clock see man 2 nanosleep)

Therefore, the sleep is only active... while not being asleep.
-->

----

<!-- _class: lead -->

![bg right width:450px](./images/ninja-tux.png)

That's all I have.

<p class="small handwritten">Hope you feel a bit more ninja now.</p>
