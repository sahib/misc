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
    
    // TODO: Do not show for title / agenda
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
    #outline()
  ]
  #set page(footer: none, header: none)
]

#slide[
  #comment(```md
  Debugging as a science, not as an art.
  Or more like a craft.

  His book only has 9 rules, I added one at the end.

  The rules are very generic and can be applied to outside of software.
  Many feel obvious, but when debugging we often forget them.
```)

  #align(center)[
    #set text(size: 30pt)
    *The prophet and his bible*
  ]

  #toolbox.side-by-side[
    #align(right)[
      #image("images/prophet.jpg", height: 80%)
    ]
  ][
    #align(left)[
      #image("images/bible.jpg", height: 80%)
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
    ```
  ) 
  #commandment("Understand the system")
]


#slide[
  #comment(
    ```md
    ```
  ) 
#commandment("Make it fail")

]

#slide[
  #comment(
    ```md
    ```
  ) 
#commandment("Quit Thinking and Look")

]

#slide[
  #comment(
    ```md
    ```
  ) 
#commandment("Divide and Conquer")

]

#slide[
  #comment(
    ```md
    ```
  ) 
#commandment("Change one Thing at a Time")

]

#slide[
  #comment(
    ```md
    ```
  ) 
#commandment("Keep an Audit Trail")

]

#slide[
  #comment(
    ```md
    ```
  ) 
#commandment("Check the Plug")

]

#slide[
  #comment(
    ```md
    ```
  ) 
#commandment("If you didn't fix it, it ain't fixed")
]

#slide[
  #comment(
    ```md
    ```
  ) 
#commandment("Get a Fresh View")
]

#slide[
  #comment(
    ```md
    ```
  ) 
#commandment("Make it easy to debug")
]

#slide[
  #comment(
    ```md
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
//   * Make your code easy to debug. Invest time in logging, modularity, tracing, monitoring, alerting, linting, test setups.
//   * Mind the cognitive load: Writing code is easier than debugging it. If you have complex code it will even more complex debugging it.
//   * Debuggers can be useful, but if you require them you probably have created a complexity beast. Debuggers are not good in finding race conditions and timing issues.
//   * Debuggers have some many restrictions: No timing issues, hard to do in embedded, containers and often slower than good ol' debugging for me.
//   * printf debug is surprisingly effective if done right, as it turns out.
//   * Writing specialized code for finding issues is underrated. Make sure to automate things.
//   * Leverage git! Find the last working version to find the diff that caused the bug.
//   * Make a MRE (minimal reproducible example).
//   * Try to obtain logs or core dumps.
//   * Ask for help. Rubber Duck programming is a thing and so is Rubber Duck Debugging.
//   * Use coverage based differential debugging: <https://research.swtch.com/diffcover>
//     * System wide debugging: perf / eBFF
//   * Learn strace
//   * coverage density: How often is a piece of code ran?
//   * Never throw away a debugging too. You always gonna need it at some point.
//   * Diff logs. One worked, one did not.
//   * Add Quality Debugging Tools to your application - builtin!
