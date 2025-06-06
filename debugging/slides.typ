// Get Polylux from the official package repository
#import "@preview/polylux:0.4.0": *

#enable-handout-mode(false)

// Can be used to embed speaker notes:
#let comment = toolbox.pdfpc.speaker-note

#show link: set text(blue)
#set text(font: "TT2020 Style E", size: 20pt)
// #show raw: set text(font: "Fantasque Sans Mono")

#set heading(numbering: "I.")


// Make the paper dimensions fit for a presentation and the text larger
#set page(
  paper: "presentation-16-9",
  footer: [
    #set text(fill: gray, size: .8em)
    #set align(horizon)

    Chris Pahl, 2025 #h(1fr) #toolbox.slide-number
  ],
  header: box(inset: 8pt)[
    #set align(horizon)
    #set text(size: .6em)

    #show link: it => {
      set text(fill: black)
      strong(it.body)
    }
    #set text(fill: gray)

    #toolbox.progress-ratio(ratio => [
      #let progress = calc.round(ratio * 100)
      #if progress > 0 [
        #progress%
      ]
    ])
    #h(1fr)
  ]
)

// TODO: Add intro. (?)
// TODO: Add commentary and war stories.

#slide[
  #comment(```md
```)

  #align(center)[
    #image("images/title.png", height:80%)
    #set text(size: 30pt)
    The 10 Debugging commandments
  ]

  #set page(footer: none, header: none)
]

#slide[
  #comment(```md
```)

  #align(center)[
    #outline(title: "Thou shalt...")
  ]
  #set page(footer: none, header: none)
]

#slide[
  #comment(```md
  Debugging as a science, not as an art.
  Or more like a craft.

  His book only has 9 rules, I added one. Tell me at the end which one
  was the one I added.

  The rules are very generic and can be applied to outside of software.
  Many feel obvious, but when debugging we often forget them.
```)

  #align(center)[
    #set text(size: 30pt)
    *The prophet and his bible*
  ]

  #toolbox.side-by-side[
    #align(right)[
      #image("images/polaroid/prophet.png", height: 80%)
    ]
  ][
    #align(left)[
      #image("images/polaroid/bible.png", height: 80%)
    ]
  ]
]

#let commandment = (commandmentText) => {
  align(center)[
    #set text(size: 30pt)
    #v(5cm)
    #heading(level: 1, commandmentText)
  ]
  toolbox.register-section(commandmentText)
}

#slide[
  #comment(
    ```md
  Basically RTFM

  War-Story:
    - SIM Card issue in Taiwan: How the fuck does this even work.
    - UI-bug: Took ages to know where it came from. (That did not solve it)
    ```
  )
  #commandment("Understand the system")
]

#slide[
  #comment(
    ```md
    ```
  )

  #v(4cm)
  - Read everything, cover to cover
  - Know what to expect and what is reasonable
  - Know your tools
  - Lookup the details
]

//////////////////////////////

#slide[
  #comment(
    ```md
  Stories of a bug withoug a way of re-tracing are not very useful.
  It is even annoying since you do not exactly know if there is a bug and
  you do not have a way to fix it.

  War-Story: Also UI-bug: To get a hint at what is causing it we had to go at great lengths
  trying to make it happen.

    ```
  )
#commandment("Make it fail")
]

#slide[
  #comment(
    ```md
    - Do it again: To best understand it, you have to make the steps yourself. Learning by doing.
    - Reproduce it yourself: Sometimes reports from others are kinda confused and hard to understand. It's importat for understanding to see it yourself.
    - Stimulate, not simulate: Use real hardware, real timing. If you do that you might notice more bugs.
    - Don't just wait for it too happen again: Don't wait for the storm, use a hose to waterproof your house.
    - Control the condition to find intermittent bugs: Some bugs only show on load e.g. - remember this.
    - Never throw away a debugging tool: During failing your probably had some ideas to make the system more introspectable. Use that.
    ```
  )

  #v(4cm)
  - Expect that the report is valid
  - Reproduce it yourself
  - Stimulate, not simulate
  - Don't just wait for it too happen again
  - Control the condition to find intermittent bugs
  - Never throw away a debugging tool
]

//////////////////////////////

#slide[
  #comment(
    ```md
    Do not theorize before you have some data.

    You probably can imagine a thousand ways, but that time is lost
    for gathering proper proof.
    ```
  )
#commandment("Quit Thinking and Look")

]

#slide[
  #comment(
    ```md
  - Order the symptoms

    - What symptoms does the system have?
    - Which of those are related to the bug?
    - Which are a cause of others?
    - What are the components we have to look into
    - Can we find hypothesis that explain those symptoms?

  - Only guess to focus the search

    - When you have several parts of the system you have to investigate
      then it's fine to guess. Just don't trick yourself into thinking this was the only option.
    - Do not guess otherwise though.

  - Find a hypothesis explaining all symptoms

    - If it does't, it might not be the real explanation...
    - ...or you have several problems.

  - Apply Occam's Razor

    - "When faced with two equally good hypothesis, always choose the simpler"
    - Of course, radiation from space can flip bits, but is it really
      the simplest explanation?

  - Instrument the system

    - Gather proof to your hypothesis
    - Add logs, profiling, specialized code, whatever.
    ```
  )

  #v(4cm)

  - Order the symptoms
  - Only guess to focus the search
  - Find a hypothesis explaining all symptoms
  - Apply Occam's Razor generously
  - Instrument the system
  - Use the 5-Why method


  #place(
    bottom + right,
    image("images/polaroid/occam.png", height: 65%)
  )
]

//////////////////////////////

#slide[
  #comment(
    ```md

  War story: git bisect?
    ```
  )
#commandment("Divide and Conquer")

]

#slide[
  #comment(
    ```md
    - Use binary search:

        - Divide the system in half and check in which half the failure is.
        - Take away more and more, producing a minimally reproducible example

    - Automate the bug checking

        - Sometimes binary searches lead to a dead end (especially for heisenbugs or communication issues)
        - In this case you have to extend the range.
        - If you automated, it makes things like git bisect possible at all

    - Start with the bad:

      - The number of working parts is higher than the bad ones.
      - Start with it failing part until it does not fail any longer.

    - Fix the issues you know about first: Reduce noise, and fix bugs that might hide other bugs.
      Complex issues are quite often a chain of unlikely bugs going hand in hand.


    ```
  )

  #v(4cm)
  - Use binary search
  - Automate the bug checking
  - Start with the bad and work to the good
  - Fix the issues you know about first

]

//////////////////////////////

#slide[
  #comment(
    ```md


    ```
  )
#commandment("Change one Thing at a Time")

#slide[
  #comment(
    ```md
  - Grab the brass bars: In nuclear plants there is a brass bar. When there is a failure
    engineers have to grab this bar and are only allowed to let loose once they understand the
    situation.

    https://www.iwm.org.uk/collections/item/object/205260813 (see the bars below)

  - Compare with a known good state: What changed? 
      - Use git diff
      - diff debug logs (good vs bad)
      - Use coverage based differential debugging: <https://research.swtch.com/diffcover>
      - monitoring like grafana curves
    ```
  )
  #v(4cm)
  - Use a rifle, not a shotgun
  - Remove the things that had no effect
  - Grab the brass bars with both hands
  - Compare with a known good state

  #place(
    bottom + right,
    image("images/polaroid/brass_bars.png", height: 80%)
  )
]

//////////////////////////////

]

#slide[
  #comment(
    ```md
    War story: fsck fuckup.

    We wanted to save some time by trying several things at once.
    Triggering the bug was very hard. Sometimes it did not happen, but we did not know
    which measure fixed it. Sometimes it still happened, but we did not know if the fixes
    cancelled out for some reasons.
    ```
  )
#commandment("Keep an Audit Trail")

]

#slide[
  #comment(
    ```md
  - Write down what you did, in what order and what happened:

      - The flannel shirt that broke the video recorder compression
      - Writing it down makes you think, like documentation validates your design.

  - The devil is in the details.

      - Understand any detail, as it could be the important one.
      - You need the audit log when looking back.

  - Correlate events:

      - "It made a noise for four seconds starting at 21:04:54" is better than "it made a noise"

  - Let others read your log.

      - They might have new ideas or just plainly say "nah, that's bullshit"

  - Write regression tests.

      - When you fixed it, make sure it stays fixed. Happens way too often that different people debug the same problem.
    ```
  )

  #v(4cm)
  - Write down what you did, in what order and what happened.
  - The devil is in the details.
  - Correlate events, find patterns.
  - Regression tests are a form of logging.
  - Let others read your log.
  - Write regression tests.

]

//////////////////////////////

#slide[
  #comment(
    ```md
    Quite often we miss the obvious. Things that make us say "How could this ever work?",
    but still we get lost in the details somehow.

    Check if it's plugged in, check the obvious.
    ```
  ) 
#commandment("Check the Plug")

]

#slide[
  #comment(
    ```md
  - Question your assumptions: Use the audit log to see how you got here.
  - Start at the beginning: Is the memory initialized? Is it turned on?
  - Test the tool: Do your debugging tools work? Are you running the right compiler? The right code?
    ```
  ) 

  #v(4cm)

  - Question your assumptions.
  - Start at the beginning.
  - Test the tool.
]


//////////////////////////////

#slide[
  #comment(
    ```md
    Sometimes you're stuck on your own, well then you need somebody else to debug your brain.
    Experts would be nice, but sometimes a duck can do as well.
    ```
  ) 
#commandment("Get a Fresh View")
]

#slide[
  #comment(
    ```md

  - Don't be proud, ask for help: Asking for a help is a sign for someone being solution oriented. Don't be a try-hard.
    Take pride in getting rid of them, not in getting rid of them by yourself.
  - Ask the experts, if any: If you have them, you should also listem to them, even if you don't agree.
  - Report symptoms, not theories: Tell the other guy (or the duck) the symptoms and not your conclusions so far. Otherwise you will prime him.
  - Do Rubber Duck Debugging: Vocalizing alone helps.
    ```
  ) 

  #v(4cm)
  - Don't be proud, ask for help.
  - Ask the experts, if any.
  - Report symptoms, not theories.
  - Do Rubber Duck Debugging.

  #place(
    top + right,
    image("images/polaroid/duck.png", height: 85%)
  )
]

//////////////////////////////

#slide[
  #comment(
    ```md
I too often saw people apply some fix they thought fixed it and close the ticket.
    ```
  ) 
#commandment("If you didn't fix it, it ain't fixed")
]

#slide[
  #comment(
    ```md
  - Revert the fix, test, revert the revert & test: Only then you will be sure that you fixed it.
  - It never just goes away by itself: Don't be satisfied just because it did not happen anymore.
  - Make sure you fix the root cause: Question whether you have a workaround or a proper fix. 
  - Fix whatever led to the bug: Are there processes missing? Bad qualtiy control?
  - Prevent similar bugs from happening: Add regression tests. Can the weird crash happen by anything else?
    ```
  ) 

  #v(4cm)
  - Revert the fix, test, revert the revert & test.
  - It never just goes away by itself.
  - Make sure you fix the root cause.
  - Fix the process that caused the bug.
  - Prevent similar bugs from happening.
]

//////////////////////////////

#slide[
  #comment(
    ```md
    Sometimes you're not there. Sometimes somebody else needs to debug your system.

    Example: Dani can work with the Pi a lot to debug the control system. There are many
    tools that are only accessible by ssh'ing to the device and their sole purpose
    is to provide introspection. Tools like those are as important as having automated tests!
    ```
  )
#commandment("Make it easy to debug")
]

#slide[
  #comment(
    ```md
  - Mind the cognitive load: Writing code is easier than debugging it. If you have complex code it will even more complex debugging it.
  - Make your design inspectable: Have clear interfaces between components. Spaghetti is hard to untangle.
  - Include debugging utilities: Things like tiproxy stream, pprof, messpunkte.
  - Keep your log hygiene: Most of our logs are spammy and hard to parse. People tend to see them as source
    for a data lake and not for human consumption.
  - Train your colleagues: Nobody will use a debugging utility that nobody knows of. Do Pair debugging.
    ```
  )

  #v(4cm)
  - Mind your cognitive load.
  - Make your design introspectable.
  - Include debugging utilities.
  - Keep your log hygiene.
  - Train your colleagues.
]

//////////////////////////////

#slide[
  #comment(
    ```md
    Questions?
    ```
  )

  #v(5cm)
  #align(center)[
    #set text(size: 50pt)
    *The End*
  ]
]

// * Additional thoughts:
//
//   * Debuggers can be useful, but if you require them you probably have created a complexity beast. Debuggers are not good in finding race conditions and timing issues.
//   * Debuggers have some many restrictions: No timing issues, hard to do in embedded, containers and often slower than good ol' debugging for me.
//   * printf debug is surprisingly effective if done right, as it turns out.
//   * Ask for help. Rubber Duck programming is a thing and so is Rubber Duck Debugging.
//   * System wide debugging: perf / eBFF
//   * Learn strace
//   * coverage density: How often is a piece of code ran?
//   * Don't always trust reports -> Eliminate conflicting statements.
//   * Distinguish between symptoms and causes.


// Done:
//   * Add Quality Debugging Tools to your application - builtin!
//   * Diff logs. One worked, one did not.
//   * Make a MRE (minimal reproducible example).
//   * Make your code easy to debug. Invest time in logging, modularity, tracing, monitoring, alerting, linting, test setups.
//   * 5 Why Methode: Drill down to the actual reasons.
//
// Cool bugs (own):
//
// - UI crash due to SIGILL (still open)
// - UI just crashes randomly with certain drawing operations (and GPU locks up)
// - Pi Freeze (PiTSD)
//    -> "Fix" lead to stuttering Audio and UART transmission issues.
// - ostree bootloop for Crays (that killed some Crays)
// - fsck fuckup (that killed some Apogees).
// - Ack of Death - re-sending too fast just increases your load.
// - Data gaps due to firmware load
// - HTML data in networkstatistics_publicipaddr
