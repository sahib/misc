// Get Polylux from the official package repository
#import "@preview/polylux:0.4.0": *
#import "@preview/cetz:0.3.2"

#enable-handout-mode(false)

// Toggle a notes-included build with:
//   typst compile --input notes=true slides.typ slides-with-notes.pdf
// Default (no input) produces the normal presentation PDF.
#let with-notes = sys.inputs.at("notes", default: "false") == "true"

// Per-slide note text. `comment(...)` stashes the current slide's note here;
// the `slide` wrapper below reads it after the slide body and emits a
// matching notes page.
#let _slide-note = state("slide-note", none)

// Can be used to embed speaker notes.
// We define this locally instead of using `toolbox.pdfpc.speaker-note`
// because polylux 0.4.0 still does `type(x) == "string"` checks, which
// silently broke when typst 0.12+ changed `type()` to return type objects.
#let comment(body) = {
  let txt = if type(body) == str {
    body
  } else if type(body) == content and body.func() == raw {
    body.text.trim()
  } else {
    panic("comment(): expected a string or a raw block")
  }
  [ #metadata((t: "Note", v: txt)) <pdfpc> ]
  _slide-note.update(txt)
}

// Wrap polylux's `slide` so that, in notes mode, every slide is followed by
// a page rendering its speaker note. Outside notes mode this is a transparent
// pass-through, so the presentation PDF is unchanged.
#let _polylux-slide = slide

#let slide(body) = {
  _slide-note.update(none)
  _polylux-slide(body)
  if with-notes {
    context {
      let txt = _slide-note.get()
      if txt != none {
        pagebreak(weak: true)
        v(0.5em)
        text(size: 11pt, fill: gray, weight: "bold")[Speaker notes — preceding slide]
        v(0.6em)
        block(width: 100%, breakable: true, [
          #set text(size: 13pt)
          #raw(block: true, lang: none, txt)
        ])
      }
    }
  }
}

// Rainbow-colour each codepoint of a string. Inherits font size/weight
// from the surrounding text() so it composes cleanly inside headlines.
#let rainbow(s) = {
  let colors = (
    rgb("#e74c3c"), // red
    rgb("#e67e22"), // orange
    rgb("#f39c12"), // amber
    rgb("#27ae60"), // green
    rgb("#2980b9"), // blue
    rgb("#8e44ad"), // purple
  )
  for (i, c) in s.codepoints().enumerate() {
    text(fill: colors.at(calc.rem(i, colors.len())))[#c]
  }
}

#show link: set text(blue)
#set text(font: "TT2020 Style E", size: 20pt)


// Make the paper dimensions fit for a presentation and the text larger
#set page(
  paper: "presentation-16-9",
  footer: [
    #set text(fill: gray, size: .8em)
    #set align(horizon)

    Chris Pahl, 2026 #h(1fr) #toolbox.slide-number
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

#slide[
  #comment(```md
- This is more of a opinion talk, but I tried to back it up with numbers.
- I felt the need to give my opinion because I worked now quite a bit
  with Claude (also on open source projects) and it's impressive - both positively and negatively.
- Did you get the zauberlehrling-reference in the title slide?
```)

  // Title slide layout: full-slide-height illustration anchored to the
  // right; title text in the remaining space on the left. The image is
  // portrait (~9:10) on a 16:9 slide, so it occupies roughly the right
  // half and leaves room for the title without covering the figure.
  // Margin is zeroed so the image truly bleeds to the slide edges.
  #set page(footer: none, header: none, margin: 0pt)

  #place(right + horizon, image("images/zauberlehrling.png", height: 100%))

  #place(left + horizon, box(width: 50%, inset: 2em)[
    #text(size: 2.2em, weight: "bold")[The #rainbow("vibes")\ that I summoned...]

    #v(1em)
    #text(size: .95em, fill: gray)[
      Convenience and skill\
      when working with AI agents.
    ]

    #v(2.5em)
    #text(size: .85em)[Chris Pahl · 2026]
  ])
]


#slide[
  #comment(```md
- I spend sometimes unreasonable amount of time on Reddit
- There are tons like sub-reddits that can be roughly placed on the
  spectrum. r/BetterOffline (left) or r/singularity (right) and many between.
- Words like "AI slop" or "cope" is thrown around like confetti.
- I just sit there in between and think, how so often in life,
  that both extremes are pretty weird.
- The consensus is though, at least when it comes to software development,
  that there is a tradeoff between control and productivity.
```)

  = The Spectrum (on Reddit)

  #v(1.5em)
  #align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      let bar-w = 18
      let bar-h = 0.6

      // gradient bar: green (control / quality) → red (loss of control)
      rect(
        (0, -bar-h/2), (bar-w, bar-h/2),
        fill: gradient.linear(
          blue, green, red,
        ),
        stroke: 1pt + black,
      )

      // tick marks
      for x in (0,  bar-w) {
        line((x, -bar-h/2 - 0.15), (x, bar-h/2 + 0.15), stroke: 1.5pt + black)
      }

      // sweet-spot marker (slightly left of centre — bias toward control)
      let mx = bar-w * 0.42

      // endpoint labels
      content((0, -1.2), [*Full manual*])
      content((0, -1.8), text(size: .75em, fill: gray)[every keystroke yours])
      content((bar-w, -1.2), [*Full vibecode*])
      content((bar-w, -1.8), text(size: .75em, fill: gray)[just make it work])

      // bottom axis annotations
      content(
        (bar-w/2, -3.0),
        text(size: .85em, fill: gray)[
          #v(1cm)
          ⟵ more control · more understanding | more productivity · more delegation ⟶
        ],
      )
    })
  ]

  #v(.5em)
  #align(center)[
    #v(1cm)
    #text(fill: gray)[General tendency:]

    Using GenAI is a tradeoff between control and productivity.
  ]
]

#slide[
  #comment(```md
What's wrong with the prompt?

Why is there another duck? I didn't choose the background.
Why is it so creepy? Apparently the model made a lot of assumptions
to fill out the blanks I did not specify.

Code generated by AI can be seen a bit like generated images - lots of
assumptions are made and you might not even be aware of it. Exercising
precise control is hard if you like a very specific result.

Or: You can do 80% of the result in sceonds, but the 20% left for a good result
require 80% of the skill.
  ```)
  
  #place(left + horizon, box(width: 40%, inset: 0em)[
    #text(fill: gray)[Prompt:] \
    "Imagine Donald Duck as regular, realistic human. No sailor suite."
  ])


  #align(right+horizon)[
    #image("images/aifail.jpg")
  ]
]

#slide[
  #comment(```md
Which brings me to the core of my own take:

- Quality: starts middling (humans are flawed too!), rises with judicious AI assistance, then falls off a cliff when nobody is reading the diff. - Productivity: low on full manual, climbs through the middle, peaks just right of centre — and then *falls again* as quality issues create rework. (METR 2025: experienced devs were 19% SLOWER with AI on their own mature OSS repos, while predicting +24% speed-up.)
- Confidence: High on manual (you wrote it, you know it), dips in the middle (you're humble, you verify), spikes on the right where it *decouples from reality*. (Perry et al. 2023: devs using AI assistants wrote less secure code AND were more confident the code was correct.)
- The widening gap between confidence (green) and quality (blue) on the right is the most important thing on this slide. That's the Dunning-Kruger zone. More on that later.

Core takeaways: 
- AI can be used to get more productive and even increase quality.
- There is a wide gap between perceived confidence and earned confidence.
- 60 years of software engineering don't get irrelevant because of a new tool.
- The story of AI vendors will claim otherwise because of marketing.
- Most important things is to not loose touch with the actual tech.
```)

  = My take: Quality vs Productivity

  #v(.5em)
  #align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      let w = 14
      let h = 6

      // Danger-zone tint: the right 25% of the chart (Dunning-Kruger territory).
      let danger-x = w * 0.75
      let danger-red = rgb("#d9542b")
      rect(
        (danger-x, 0),
        (w, h),
        fill: danger-red.transparentize(82%),
        stroke: none,
      )

      // axes
      line((0, 0), (w + 0.4, 0), stroke: 1pt + black, mark: (end: ">"))
      line((0, 0), (0, h + 0.4), stroke: 1pt + black, mark: (end: ">"))

      // x labels
      content((0, -0.5), [manual])
      content((w, -0.5), [vibecode])
      content((w/2, -1.1), text(fill: gray, size: .8em)[← how much you delegate to the model →])

      // y label
      content((-0.4, h + 0.3), text(size: .8em, fill: gray)[high], anchor: "east")
      content((-0.4, 0.3), text(size: .8em, fill: gray)[low], anchor: "east")

      // Quality curve: starts mid, peaks in middle, drops at right
      let q-color = rgb("#1f77b4")
      hobby(
        (0, 3.0),
        (3, 4.0),
        (6, 5.2),
        (9, 4.6),
        (12, 2.6),
        (w, 1.2),
        stroke: 2.5pt + q-color,
      )

      // Productivity curve: low → peaks just right of centre → falls again
      // (rework from quality issues eats the perceived gains)
      let p-color = rgb("#d9542b")
      hobby(
        (0, 0.8),
        (3, 2.0),
        (6, 4.0),
        (9, 5.0),
        (12, 4.0),
        (w, 1.8),
        stroke: 2.5pt + p-color,
      )

      // Confidence curve: high on manual (calibrated), humble in the middle,
      // *falsely* ultra-high on the vibecode side (Dunning–Kruger zone)
      let c-color = rgb("#3a8f4a")
      hobby(
        (0, 4.0),
        (3, 3.5),
        (6, 3.2),
        (9, 4.0),
        (12, 5.2),
        (w, 6.0),
        stroke: 2.5pt + c-color,
      )

      // inline curve labels (no legend — cleaner)
      content((2.3, 4.6), text(weight: "bold", fill: q-color)[Quality])
      content((9.7, 5.5), text(weight: "bold", fill: p-color)[Productivity])
      content((7.0, 2.8), text(weight: "bold", fill: c-color)[Confidence])

      // sweet-spot marker at the apex of the Quality curve
      let sx = 6.0
      let sy = 5.18
      circle((sx, sy), radius: 0.14, fill: black)
      line((sx, sy + 0.15), (sx, sy + 0.9), stroke: 0.7pt + gray)
      content((sx, sy + 1.2), text(size: .85em, fill: gray, style: "italic")[sweet spot])

      // gap annotation on the right edge: confidence (6.0) vs quality (1.2)
      // a thin bracket showing the dangerous divergence
      let gx = w - 0.3

      // Dotted red separator at the danger-zone boundary, drawn last so it
      // stays visible on top of the curves.
      line(
        (danger-x, 0),
        (danger-x, h + 0.2),
        stroke: (paint: danger-red, dash: "dotted", thickness: 1.4pt),
      )
    })
  ]

  #v(.3em)
  #align(center)[
    #text(size: .85em, fill: gray)[
      #text(fill: rgb(220, 80, 0))[Danger Zone:] Dunning-Kruger
    ]
  ]
]

#slide[
  #comment(```md
  -19% (METR, 2025). Randomised controlled trial. 16 experienced OSS devs, 246 real tasks in their OWN mature repos, ~5 yr experience each. With Cursor + Claude 3.5/3.7 they were 19% slower. They PREDICTED +24% faster beforehand; even afterward they still BELIEVED they'd been ~20% faster. The perception-reality gap is the real finding.

  ~40% (NYU, 2021 — "Asleep at the Keyboard?"). Tested Copilot on 89 scenarios in security-relevant settings. ~40% of generated programs contained exploitable bugs. The original alarm bell; replicated since.

  8x (GitClear, 2024). Analysis of 211M changed lines, 2020-2024. Duplicated code blocks rose ~8x. Refactored ("moved") lines fell from 24% → 10%. Churn (lines rewritten within 2 weeks) rose 5.5% → 7.9%. Translation: AI nudges devs to copy-paste instead of refactor.

  -7.2% (DORA / Google Cloud, 2024). State-of-DevOps survey. AI adoption correlated with 1.5% throughput drop AND 7.2% stability drop. 39% of respondents reported little-to-no trust in AI-generated code. This is the broadest dataset we have.

  29.5% (Fu et al., ACM TOSEM 2025). Empirical study: 29.5% of AI-generated Python snippets and 24.2% of JavaScript snippets contained known CWEs (Common Weakness Enumeration entries). Replicates and quantifies the NYU finding.

  ↓ critical thinking (Lee et al., CHI 2025, Microsoft + CMU). 319 knowledge workers, 936 first-hand examples. Finding: higher confidence in GenAI is associated with LESS critical thinking. Higher self-confidence is associated with MORE. Ties directly to the cog-biases slide.
```)

  = But there's already data:

  #v(.6em)

  // Stat-card helper. Glanceable — audience feels the volume, doesn't read.
  #let card(stat, headline, body, source, color: rgb("#c0392b")) = box(
    width: 100%,
    inset: (left: .8em, right: .6em, y: .35em),
    stroke: (left: 4pt + color),
    [
      #text(size: 1.6em, weight: "bold", fill: color)[#stat]
      #v(-.4em)
      #text(size: .85em, weight: "bold")[#headline] \
      #text(size: .6em, fill: gray)[#body] \
      #v(.1em)
      #text(size: .55em, fill: gray, style: "italic")[#source]
    ]
  )

  #grid(
    columns: (1fr, 1fr, 1fr),
    rows: (1fr, 1fr),
    column-gutter: .8em,
    row-gutter: .8em,

    card(
      [−19%],
      [slower with AI],
      [experienced devs · own mature repos · predicted +24%],
      [METR · RCT · 2025],
    ),
    card(
      [∼40%],
      [insecure programs],
      [Copilot output across 89 security-relevant scenarios],
      [NYU CCS · 2021],
    ),
    card(
      [8×],
      [more duplicated code],
      [block-level clones up · refactoring 24% → 10%],
      [GitClear · 211M LoC · 2024],
    ),

    card(
      [−7.2%],
      [delivery stability],
      [drop with AI adoption · 39% distrust AI code],
      [DORA / Google · 2024],
      color: rgb("#444444"),
    ),
    card(
      [29.5%],
      [Python with CWEs],
      [AI-generated code in real GitHub repos · 43 CWE categories],
      [Fu et al. · ACM TOSEM · 2025],
    ),
    card(
      [↓],
      [trust = less scrutiny],
      [more trust in GenAI ⇒ less critical thinking applied],
      [Lee et al. · Microsoft + CMU · CHI 2025],
      color: rgb("#444444"),
    ),
  )
]

// Tag helper: a single keyword, given a size, rotation, and colour.
// Flowing layout (not absolute placement) so adding/removing tags
// re-wraps cleanly. Heaviest risks get colour + bold.
#let tag(sz, body, color: black, angle: 0deg, weight: "regular") = box(
  inset: (x: .35em, y: .25em),
  rotate(angle, text(size: sz, fill: color, weight: weight)[#body]),
)

#set par(leading: .9em, justify: false)

#slide[
  #comment(```md
A lot of scorched earth in the field of science until now. Still, it feels a lot more useful than that - I think it's possible that the studies will catch up. After all there are some useful use cases for using something like Claude!

The core idea is that most of those use cases manage risk - it's not full vibecode-ing like "take the wheel" but a tandem of human and machine. We can use models to get better developers and generate away boilerplate things that are just stealing time we can use to focus on more important things.
```)

  = Use-cases that could make us better devs

  #let green = rgb("#3a8f4a")
  #let mid = rgb("#444444")
  #let pale = rgb("#888888")

  #align(center + horizon)[
    #tag(1.6em, [rubber-ducking], color: green, angle: -2deg, weight: "bold")
    #tag(.9em, [ideation], color: pale, angle: -3deg)
    #tag(1.5em, [explain unfamiliar code], color: green, angle: +2deg, weight: "bold")
    #tag(1.0em, [test generation], color: mid, angle: -1deg)
    #tag(1.4em, [pair programming], color: green, angle: +1deg, weight: "bold")
    #tag(.9em, [boilerplate], color: pale, angle: +2deg)
    #tag(1.15em, [refactoring assist], color: mid, angle: -2deg)
    #tag(1.45em, [learning accelerator], color: green, angle: -3deg, weight: "bold")
    #tag(1.0em, [prototyping], color: mid, angle: +3deg)
    #tag(.9em, [naming things], color: pale, angle: +1deg)
    #tag(1.05em, [summarisation], color: mid, angle: -1deg)
    #tag(.85em, [regex / SQL crafting], color: pale, angle: +2deg)
    #tag(1.3em, [edge-case brainstorming], color: green, angle: -1deg, weight: "bold")
    #tag(.9em, [translation], color: pale, angle: +3deg)
    #tag(1.1em, [code review companion], color: mid, angle: -2deg)
    #tag(.85em, [mock data / fixtures], color: pale, angle: +2deg)
    #tag(.95em, [error decoding], color: pale, angle: -1deg)
    #tag(1.1em, [search engine], color: mid, angle: +1deg)
    #tag(.9em, [log analysis], color: pale, angle: -3deg)
    #tag(.85em, [proofreading], color: pale, angle: +2deg)
    #tag(1.0em, [automation], color: mid, angle: -2deg)
  ]
]

#slide[
  #comment(```md
It's just very important to see AI as  high-risk tech. Mostly, discussion is around how we can use it and not about the whole side effect of the technology as a whole.
```)

  = Risks for all

  #let red = rgb("#c0392b")
  #let mid = rgb("#444444")
  #let pale = rgb("#888888")

  #align(center + horizon)[
    #tag(.85em, [ecological cost], color: pale, angle: -3deg)
    #tag(1.7em, [Convincing hallucinations], color: red, angle: -2deg, weight: "bold")
    #tag(.8em, [education], color: pale, angle: +3deg)
    #tag(1.1em, [licensing], color: mid, angle: -2deg)
    #tag(1.55em, [Atrophy], color: black, angle: +2deg, weight: "bold")
    #tag(.85em, [concentration], color: pale, angle: +1deg)
    #tag(1.15em, [misinformation at scale], color: mid, angle: -1deg)
    #tag(1.15em, [silent corruption], color: mid, angle: -1deg)
    #tag(1.45em, [Prompt injection & MCP], color: red, angle: +3deg, weight: "bold")
    #tag(.9em, [content degradation], color: pale, angle: -2deg)
    #tag(1.6em, [No juniors hired], color: black, angle: -1deg, weight: "bold")
    #tag(1.0em, [hardware crisis], color: mid, angle: +2deg)
    #tag(1.1em, [operator bias], color: mid, angle: -3deg)
    #tag(1.2em, [recursive collapse], color: mid, angle: +1deg)
    #tag(.85em, [rich getting richer], color: pale, angle: -2deg)
    #tag(1.25em, [data privacy], color: red, angle: +2deg)
    #tag(1.05em, [cyberattack automation], color: mid, angle: -1deg)
    #tag(.85em, [communities thinning out], color: pale, angle: +3deg)
    #tag(1.45em, [erosion of trust], color: red, angle: +3deg, weight: "bold")
  ]
]

#slide[
  #comment(```md
Not all risks are important for a company. I took the libery to highlight the ones that are actually an issue for us. Still a lot. Not the focus of this talk though, but I felt that I should at least mention that.
```)
  = Risks for us
  #let mid = rgb("#444444")
  #let pale = rgb("#888888")
  #let red = blue

  #align(center + horizon)[
    #tag(.85em, [ecological cost], color: pale, angle: -3deg)
    #tag(1.7em, [Convincing hallucinations], color: blue, angle: -2deg, weight: "bold")
    #tag(.8em, [education], color: blue, angle: +3deg)
    #tag(1.1em, [licensing], color: blue, angle: -2deg)
    #tag(1.55em, [Atrophy], color: blue, angle: +2deg, weight: "bold")
    #tag(.85em, [concentration], color: blue, angle: +1deg)
    #tag(1.15em, [misinformation at scale], color: blue, angle: -1deg)
    #tag(1.15em, [silent corruption], color: mid, angle: -1deg)
    #tag(1.45em, [Prompt injection & MCP], color: blue, angle: +3deg, weight: "bold")
    #tag(.9em, [content degradation], color: pale, angle: -2deg)
    #tag(1.6em, [No juniors hired], color: blue, angle: -1deg, weight: "bold")
    #tag(1.0em, [hardware crisis], color: blue, angle: +2deg)
    #tag(1.1em, [operator bias], color: mid, angle: -3deg)
    #tag(1.2em, [recursive collapse], color: mid, angle: +1deg)
    #tag(.85em, [rich getting richer], color: pale, angle: -2deg)
    #tag(1.25em, [data privacy], color: blue, angle: +2deg)
    #tag(1.05em, [cyberattack automation], color: blue, angle: -1deg)
    #tag(.85em, [communities thinning out], color: blue, angle: +3deg)
    #tag(1.45em, [erosion of trust], color: mid, angle: +3deg, weight: "bold")
  ]
]

#slide[
  #comment(```md
Not hypotheticals — all happened in 2025-2026.
- Railway: Cursor/Opus agent autonomously deleted production data in a live system. No confirmation prompt.
- Replit: AI agent wiped a production database affecting 1,200+ companies. 
- git reset --hard: Claude Code silently overwrote eight hours of work. No warning, no prompt.
- 29M secrets: GitGuardian 2026 — AI agents ingesting .env files drove a surge in leaked credentials to GitHub.
- Doc corruption: Microsoft study, 19 models, 52 documents, 100 interactions. 25% content degradation, no plateau. Only Python code survived — compilers verify it. If design docs become the source of truth, this matters.
  ```)

  = The security risks are real

  #let inc(what, impact, source, url, color: rgb("#c0392b")) = box(
    width: 100%,
    inset: (left: .65em, right: .45em, y: .13em),
    stroke: (left: 4pt + color),
    [
      #text(size: .75em, weight: "bold")[#what]
      #v(-.4em)
      #text(size: .55em, fill: gray)[#impact] \
      #link(url)[#text(size: .46em, style: "italic")[#source]]
    ]
  )

  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: .6em,
    row-gutter: .3em,

    inc(
      [Railway: production data deleted],
      [Cursor/Opus agent destroyed a live system. No confirmation prompt.],
      [The Register · April 2026],
      "https://www.theregister.com/2026/04/27/cursoropus_agent_snuffs_out_pocketos/",
    ),
    inc(
      [Replit: database wiped, 1,200+ companies],
      [AI agent wiped a production database. CEO called it "catastrophic failure."],
      [Fortune · July 2025],
      "https://fortune.com/2025/07/23/ai-coding-tool-replit-wiped-database-called-it-a-catastrophic-failure/",
    ),
    inc(
      [`git reset --hard` · 8 h of work gone],
      [Hard reset executed without warning. No prompt, no undo.],
      [cekrem.github.io · 2026],
      "https://cekrem.github.io/posts/if-you-re-running-claude-code-run-it-in-a-box/",
    ),
    inc(
      [29 million secrets leaked (2025)],
      [AI agents ingesting `.env` files drove a credential-leak surge to GitHub.],
      [GitGuardian via HelpNetSecurity · 2026],
      "https://www.helpnetsecurity.com/2026/04/14/gitguardian-ai-agents-credentials-leak/",
    ),
    inc(
      [Document corruption: 25 % degradation],
      [19 models · 52 docs · 100 edits. Monotonic decline, no plateau.],
      [Microsoft Research via cekrem.github.io],
      "https://cekrem.github.io/posts/llms-corrupt-your-documents",
      color: rgb("#7d3c98"),
    ),
    inc(
      [Samsung: source code leaked via ChatGPT],
      [Engineers pasted proprietary chip code into ChatGPT. Three leaks in one month.],
      [TechCrunch · May 2023],
      "https://techcrunch.com/2023/05/02/samsung-bans-use-of-generative-ai-tools-like-chatgpt-after-april-internal-data-leak/",
    ),
  )
]

#slide[
  #comment(```md
Practical answer to the previous slide. Sandboxing is not about distrusting the model — it is about removing the blast radius so Claude and you can operate more freely inside.

- sbx is Docker's sandbox CLI.
- Credentials on the host are not visible inside the box.
- Writes are scoped to the project directory.
- You can safely run --dangerously-skip-permissions inside — the "danger" is now contained.
- If the model goes rogue: blast radius = current project, not your machine, credentials, or production.
  ```)



  #align(center+horizon)[
    = One practical fix: sandboxing
  #v(1.8em)
    #block(
      inset: (x: 2.5em, y: 1em),
      radius: 6pt,
      stroke: black,
    )[
      #text(fill: blue, size: 1.4em)[\$ ]#text(fill: black, size: 1.4em)[sbx run claude]
    ]

    #text(fill:gray)[(or /sandbox, for smaller tasks)]
  ]
]


#slide[
  #comment(```md
  Bastani et al. Wharton/Penn field experiment, ~1000 Turkish high-school
  maths students. The cleanest piece of evidence we have on tutor-vs-solver.

  Three groups:
  - Control:    no AI, do the work yourself.
  - AI solver:  asks ChatGPT, gets the answer.
  - AI tutor:   asks a tutor-prompted ChatGPT, gets a hint.

  During practice (with the tool available):
  - Solver group ≈ +48% over control.
  - Tutor group  ≈ +127% over control.
  - Both look like they're crushing it.

  On the unaided exam (no AI):
  - Solver group ≈ -17% vs control. They got WORSE than students who never
    used AI at all. They had learned to operate the tool, not the maths.
  - Tutor group  ≈ ±0% vs control — at least no harm.

  The kicker: same model, same students, same maths. The only thing that
  changed was *what they used the AI for*. Hint-mode preserved learning;
  answer-mode actively damaged it.

  Talking points:
  - "Practice performance" is what most of us optimise for in our day-to-day
    AI usage — code that ships, tickets closed. That's the tall light bars.
  - "Unaided exam" is what happens when the AI is down, or when you switch
    teams, or when the problem is genuinely novel. That's the dark bars.
  - For developers the parallel is direct: if you use AI to solve, you'll
    pass code review while it's available. The day it isn't, the gap shows.

  Backup source: Lee et al., CHI 2025 (Microsoft + CMU) — surveyed knowledge
  workers; the more they trusted GenAI, the less critical thinking they
  reported applying.
```)

  = Study: AI in school lessons

  #v(1cm)

  #align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      let baseline = 2.2

      // 3 groups × (practice-height, exam-height, group colour, label)
      let groups = (
        (2.2, 2.2, gray, [No AI\ #text(size: .7em, fill: gray)[control]]),
        (3.25, 1.53, rgb("#c0392b"), [AI as #strong[solver]\ #text(size: .7em, fill: gray)[gives the answer]]),
        (5.0, 2.3, rgb("#1f77b4"), [AI as #strong[tutor]\ #text(size: .7em, fill: gray)[gives a hint]]),
      )

      let w = 18
      let h = 5.6
      let bw = 0.9
      let gap = 0.15
      let group-gap = w / 3
      let x0 = group-gap / 2

      // y-axis
      line((0, 0), (0, h), stroke: 1pt + black, mark: (end: ">"))
      content((-0.4, h - 0.2), text(size: .75em, fill: gray)[score], anchor: "east")

      // control baseline (drawn before bars so they overlap it)
      line((0, baseline), (w, baseline), stroke: (dash: "dashed", paint: gray, thickness: 0.8pt))
      line((0, 0), (w, 0), stroke: 1pt + black, mark: (end: ">"))

      //content((w - 0.1, baseline - 0.4), anchor: "east",
      //        text(size: .7em, fill: gray)[control baseline])

      // bars
      for (i, g) in groups.enumerate() {
        let (p-h, e-h, color, label) = g
        let xc = x0 + i * group-gap

        rect((xc - bw - gap/2, 0), (xc - gap/2, p-h),
             fill: color.lighten(70%), stroke: 1pt + color)
        rect((xc + gap/2, 0), (xc + bw + gap/2, e-h),
             fill: color, stroke: 1pt + color)

        content((xc, -1), label)
      }

      // legend (upper-left interior, in the empty space before the first group)
      let lx = 0.6
      let ly = h - 0.3
      rect((lx, ly - 0.4), (lx + 0.45, ly - 0.05),
           fill: gray.lighten(70%), stroke: 1pt + gray)
      content((lx + 0.6, ly - 0.225), anchor: "west", text(size: .7em)[during practice])
      rect((lx, ly - 1.0), (lx + 0.45, ly - 0.65),
           fill: gray, stroke: 1pt + gray)
      content((lx + 0.6, ly - 0.825), anchor: "west", text(size: .7em)[on unaided exam])
    })
  ]

  #v(.3em)
  #align(center)[
    #text(size: .65em, fill: gray)[
      Bastani et al., _Generative AI Can Harm Learning_, SSRN 2024 
    ]

    #text(size: .65em, fill: gray)[
      Pupils did prefer to be in the solver group though...  :-(
    ]
  ]
]


#slide[
  #set page(footer: none)
  #v(4cm)
  #align(center)[
    #text(size: 1.9em)[Are #emph[you] team tutor or team solver?]
  ]
]

#slide[
  #comment(```md
- To be fair: High suggestion rate might be flawed by the fact that you often let Claude do it's stuff and then use it to revert it. Still frightenly high.
- If we correlate that with the number of lines generated you can do some basic math that make it unlikely that every line was actually checked.
- Goal is not too blame everyone, but at some devleopers would have to spend
  8 hours a day for a proper review in that speed.

Assumption: Careful review of 100-200 lines takes an hour.
(Cohen, *Best Kept Secrets of Peer Code Review*; Google's internal guidance is in the same ballpark).

Actual review time might of course be faster, but I'm also counting time to test the solution in there. Even if it's off by a factor 2x it's the same result.

Why is that? Are some devs just sloppy? I don't think so, it boils down to how our brain works.
```)

  = Keeping up with Claude

  #v(.2em)
  #align(center)[
    #text(size: .85em, fill: gray)[Our team's Claude Code account · April 2026]
  ]

  #v(.6em)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    align: horizon,

    box(
      width: 100%,
      inset: (left: 1.2em, right: 1em, y: .5em),
      stroke: (left: 6pt + rgb("#c0392b")),
      [
        #text(size: 3.6em, weight: "bold", fill: rgb("#c0392b"))[98.7%]
        #v(-.5em)
        #text(size: .9em, weight: "bold")[suggestions accepted as-is] \
        #text(size: .6em, fill: gray)[1.3% rejected.]
      ]
    ),
    box(
      width: 100%,
      inset: (left: 1.2em, right: 1em, y: .5em),
      stroke: (left: 6pt + black),
      [
        #text(size: 3.6em, weight: "bold")[27,757]
        #v(-.5em)
        #text(size: .9em, weight: "bold")[lines accepted last month] \
        #text(size: .6em, fill: gray)[≈ 925 LoC/day \
          careful review ≈ 100–200 LoC/hour]
      ]
    ),
  )

  #v(.6em)
  #align(center)[
    #text(size: .85em)[
      Reviewing 27,757 lines carefully ≈ *138 h*.
    ]
  ]
]

// Bias-card helper used on both bias slides. Same visual rhythm as the
// stat cards on the Studies slide, with three fields: name (the "stat"),
// short definition, and an italic LLM-specific cue underneath.
#let bias-card(name, defn, hook, color) = box(
  width: 100%,
  inset: (left: .8em, right: .6em, y: .25em),
  stroke: (left: 4pt + color),
  [
    #text(size: 1.05em, weight: "bold", fill: color)[#name]
    #v(-.3em)
    #text(size: .7em)[#defn] \
    #v(.05em)
    #text(size: .6em, fill: gray, style: "italic")[#hook]
  ]
)

#slide[
  #comment(```md
Those are not new, just on crack now with Claude. Card-by-card:

- Automation bias. We accept machine suggestions more readily than human ones. GitHub reports ~30% of Copilot suggestions accepted as-is (VERIFY). Combine that with how often we even read the diff.
- Anchoring. The first suggestion shapes the solution space. LLMs suggest fast, so they almost always get to anchor first — your "thinking" then becomes refining their idea rather than generating your own.
- Confirmation bias. The prompt we type already contains the answer we want. Phrasing alone often determines what comes back.
- Authority bias. Eloquent + fast + confident reads as expert. LLMs are eloquent, fast, AND confident — even when wrong. We're not wired to discount fluency.
- Dunning–Kruger, remixed. Users mistake the model's competence for their own. Dangerous for seniors and juniors alike. The senior thinks "this is what I'd have written"; the junior thinks "I now understand this codebase".
- Illusion of explanatory depth. We think we understand something until asked to explain it. Maths teachers know. AI-generated code we've reviewed but not WRITTEN is similar to a math problem where you nod along during school but fail completely when being called to the whiteboard.

Not on the slide but worth mentioning: Atrophy. Not a bias - the *cumulative effect* of the others over months. Skills decay quietly. Plug: full talk on cognitive biases incoming next time I'm in Augsburg.
```)

  = Human cognitive biases

  #v(.4em)

  #let hb = rgb("#7d3c98")  // human-bias accent (violet)

  #grid(
    columns: (1fr, 1fr, 1fr),
    rows: (1fr, 1fr),
    column-gutter: .8em,
    row-gutter: .8em,

    bias-card(
      [Automation bias],
      [We accept machine suggestions more readily than human ones.],
      [click accept · review later · maybe],
      hb,
    ),
    bias-card(
      [Anchoring],
      [The first suggestion shapes the solution space — even when it's wrong.],
      [the model frames the problem before you do],
      hb,
    ),
    bias-card(
      [Confirmation bias],
      [We hear what we already believe.],
      [the prompt contains the answer we want],
      hb,
    ),

    bias-card(
      [Authority bias],
      [Eloquent + fast + confident = reads as expert.],
      [fluency ≠ correctness],
      hb,
    ),
    bias-card(
      [Dunning–Kruger],
      [We mistake competence we observe for competence we have.],
      ["this is what I would have written"],
      hb,
    ),
    bias-card(
      [Illusion of explanatory depth],
      [We think we understand — until asked to explain.],
      [Reading diffs is not enough!],
      hb,
    ),
  )
]


#slide[
  #comment(```md
Flip side: the model has its *own* biases, baked in statistically by
the training process. Different shape from human biases, same outcome:
the answer you get is not the answer you'd derive from first principles.

- Sycophancy. It's easy to talk the model out of a correct answer. Push back hard and it caves, even when right. RLHF training rewards apparent helpfulness, which correlates with agreement. Echo chambers but for code: ask twice the way you wanted, get the answer you wanted.
- Historical / representation bias. Trained on the open web — overwhelmingly modern, English-speaking, Western. Defaults are weighted toward what's most COMMON, not what's most correct for YOUR codebase.
- Attention bias. The first and last things you say dominate. The middle of a long context evaporates. Long system prompts + long files = unpredictable adherence to the rules buried in the middle.
- Omission bias. Rare and novel answers are statistically suppressed by common ones in training data. The model is bad at being weird. If your problem requires an unusual answer, the model gravitates to the safe-but-wrong one.

Tying it back: the human biases and the model biases compound. We trust the fluent-sounding output (authority + automation); it tends toward the common answer (omission + historical); we don't push back (confirmation + the model's sycophancy completing the loop).
```)

  = Statistical model biases

  #v(.4em)

  #let mb = rgb("#117a65")  // model-bias accent (teal)

  #grid(
    columns: (1fr, 1fr),
    rows: (1fr, 1fr),
    column-gutter: .8em,
    row-gutter: .8em,

    bias-card(
      [Sycophancy],
      [It's easy to talk the model out of a correct answer.],
      [echo chambers — but for code],
      mb,
    ),
    bias-card(
      [Historical / representation bias],
      [Trained on the web — heavily modern, English, Western.],
      [defaults track what's common, not what's right],
      mb,
    ),
    bias-card(
      [Attention bias],
      [First and last things dominate; the middle evaporates.],
      [rules buried in long context get ignored],
      mb,
    ),
    bias-card(
      [Omission bias],
      [Rare and novel answers get suppressed by common ones.],
      [the model is bad at creative solutions],
      mb,
    ),
  )
]

#slide[
  #comment(```md
Those are the kind of questions I have to ask myself as someone with directs.

The last question is derived from a saying my juniors should know:
"You have to learn the rules before you break them."

Rules are meant in the sense of best practices.
```)

  = Hen & Egg questions

  #v(1em)
  #set text(size: 1.1em)

  1. If you don't know what good software looks like — \
    #text(fill: gray)[#emph[how do you write the right prompt?]]
  2. If you can't understand what the model just generated — \
    #text(fill: gray)[#emph[how do you verify it?]]
  3. If you can't code (anymore) — \
    #text(fill: gray)[#emph[how can you understand the diffs?]]
  4. If you do not know what you build inside-out — \
     #text(fill: gray)[#emph[how do you learn new designs?]]
  5. If you don't notice broken best practices — \
     #text(fill: gray)[#emph[how can you master them?]]
]

#slide[
  #comment(```mo
Question is also aimed at: How do people review? I have asked that
question to a couple devs and, honestly, I found the answers kind of lacking.
Most just say "I look at the diff". We should know by now this is not enough.

Turned out I couldn't proerly answer it myself though.
```)
  #align(center+horizon)[
    #text(size: 2em)[How do #emph[you] keep up with Claude?]
  ]
]

#slide[
  #comment(```md
Now we come to the LinkedIn-y part of the presentation. ;-)

Those are derived from watching myself while using claude.
I do not claim those to be novel, although I don't see them represented
that train of thought online very often. Maybe looking wrong though.
```)

  = Five habits that helped me

  #v(.8em)

  #let green = rgb("#3a8f4a")

  #let habit(num, body, color: green) = box(
    width: 100%,
    inset: (left: 1em, right: .8em, y: .7em),
    stroke: (left: 4pt + color),
    grid(
      columns: (auto, 1fr),
      column-gutter: 1em,
      align: horizon,
      text(size: 2em, weight: "bold", fill: color)[#num],
      text(size: 1.0em, weight: "bold")[#body],
    ),
  )

  #stack(
    spacing: .7em,
    habit([1], [Sketch first, generate then.]),
    habit([2], [Split the work - keep some of it manual.]),
    habit([3], [Have a real verification strategy.]),
    habit([4], [Don't make yourself replaceable.]),
    habit([5], [Treat the AI like a colleague.]),
  )
]

#slide[
  #comment(```md
- My favourite worked example is SQL. Sketch the query yourself,
  *then* ask the model to review and optimise. You stay in the loop;
  the model adds value without anchoring you.
- Same for code: function signature + docstring first, body second.

This rule is also there to make sure you don't use LLMs for pure laziness.
Use it to be more productive and to achieve higher quality, not to quickly
set your task to done.
```)

  = 1. Sketch first, generate then\
  #text(size: .8em, fill: gray)[You set the anchor, you stay in the loop.]

  #v(.5em)

  - Sketch the SQL query yourself, \
    #text(fill: gray)[Then ask the model to review and optimise.]
  - Write the function signature and the docstring. \
    #text(fill:gray)[Then let the model fill the body.]
  - Put `TODO` comments in your code. \
    #text(fill: gray)[Then let Claude work on them.]

  #v(0.5cm)

    #align(center)[
      #cetz.canvas(length: 1cm, {
        import cetz.draw: *

        // Lemniscate of Bernoulli, with vertical stretch for legibility:
        //   x(t) = a · cos(t) / (1 + sin²(t))
        //   y(t) = s · a · sin(t)·cos(t) / (1 + sin²(t))
        let a = 4.2
        let s = 1.1
        let pt(t) = {
          let c = calc.cos(t * 1rad)
          let n = calc.sin(t * 1rad)
          let d = 1 + n * n
          (a * c / d, s * a * n * c / d)
        }

        let manual-color = rgb("#1f77b4") // quality blue — "you"
        let gen-color    = rgb("#d9542b") // productivity orange — "model"

        // Eight phases over t ∈ [0, 2π]. Manual (short) anchors the
        // tips and the centre crossing; gen (longer) is the expansion
        // arc between anchors. Pattern: M-G-M-G-M-G-M-G.
        let TAU = 2 * calc.pi
        let phases = (
          (0.0000 * TAU, 0.0625 * TAU, "manual"),
          (0.0625 * TAU, 0.2500 * TAU, "gen"),
          (0.2500 * TAU, 0.3125 * TAU, "manual"),
          (0.3125 * TAU, 0.5000 * TAU, "gen"),
          (0.5000 * TAU, 0.5625 * TAU, "manual"),
          (0.5625 * TAU, 0.7500 * TAU, "gen"),
          (0.7500 * TAU, 0.8125 * TAU, "manual"),
          (0.8125 * TAU, 1.0000 * TAU, "gen"),
        )

        for (t0, t1, kind) in phases {
          let color = if kind == "manual" { manual-color } else { gen-color }
          let weight = if kind == "manual" { 6.5pt } else { 4.5pt }
          let n = 28
          let pts = ()
          let i = 0
          while i <= n {
            let t = t0 + (t1 - t0) * i / n
            pts.push(pt(t))
            i = i + 1
          }
          line(..pts, stroke: weight + color, mark: (end: ">", fill: color))
        }

        // Labels at the two tips.
        content(
          (-a - 0.3, 0),
          text(size: .8em, fill: manual-color, weight: "bold")[you sketch],
          anchor: "east",
        )
        content(
          (a + 0.3, 0),
          text(size: .8em, fill: gen-color, weight: "bold")[model expands],
          anchor: "west",
        )
      })
    ]
]

#slide[
  #comment(```md
- Deliberately keep some work manual. Not for purity - for skill
  maintenance, and because the parts you do manually are the parts
  you actually understand later.
- Small scopes also help the model: long, vague prompts get long,
  vague code back. Garbage in, garbage out. Split, then prompt each piece.
  - Don't say "I coded this" when it was Claude. Basic decency.
```)

  = 2. Split the work, do some manual
  #text(size: .8em, fill: gray)[The parts you write are the parts you understand.]

  #v(.5em)

  #grid(
    columns: (1fr, auto),
    column-gutter: 2em,
    align: horizon,
    [
      - Claude does not perform well in too big scopes.  \
        #text(fill: gray)[Split tasks up and prompt them individually.]
      - Claude can help you split up work. \
        #text(fill: gray)[It just tends to work on the task right away.]
      - It is easy to lose understanding without noticing. \
        #text(fill: gray)[Keep doing important things manually!]
      - Large diffs make it easy to get lost. \
        #text(fill: gray)[Commit often so diffs stay reviewable.]
      - If something was 100% generated, then note it down. \
        #text(fill: gray)[Be honest with your colleagues.]
    ],
    align(center + horizon)[
      #cetz.canvas(length: 1cm, {
        import cetz.draw: *

        // Three-level tree: 1 big root → 3 sub-tasks → 6 leaves.
        // Each sub-tree gets its own colour (red / green / blue) so the
        // split is visually traceable. Nodes are rounded rects with
        // little white "title bars" inside so they read as task cards.

        let red     = rgb("#d9542b")
        let green   = rgb("#3a8f4a")
        let blue    = rgb("#1f77b4")
        let neutral = rgb("#444444")
        let subtree = (red, green, blue)

        // task-card: rounded rect with 1 or 2 white "title" lines inside.
        let card(cx, cy, w, h, fill, lines: 1) = {
          rect(
            (cx - w / 2, cy - h / 2),
            (cx + w / 2, cy + h / 2),
            fill: fill,
            stroke: none,
            radius: 0.06,
          )
          let pad = 0.1
          let inner = w - 2 * pad
          if lines == 1 {
            line(
              (cx - inner / 2, cy),
              (cx + inner / 2 - 0.04, cy),
              stroke: 1.3pt + white,
            )
          } else {
            let dy = 0.09
            line(
              (cx - inner / 2, cy + dy),
              (cx + inner / 2, cy + dy),
              stroke: 1.6pt + white,
            )
            line(
              (cx - inner / 2, cy - dy),
              (cx - inner / 2 + inner * 0.6, cy - dy),
              stroke: 1.6pt + white,
            )
          }
        }

        // Coordinates — taller than before: root at y=9, leaves at y=1.5.
        let root   = (1.5, 9.0)
        let mids   = ((0.4, 5.3), (1.5, 5.3), (2.6, 5.3))
        let leaves = (
          (0.1, 1.5), (0.7, 1.5),
          (1.2, 1.5), (1.8, 1.5),
          (2.3, 1.5), (2.9, 1.5),
        )
        let leaf-parent = (0, 0, 1, 1, 2, 2)

        let edge = rgb("#bbbbbb")

        // Connectors first so cards cap them.
        for m in mids {
          line(root, m, stroke: 1.3pt + edge)
        }
        for (i, l) in leaves.enumerate() {
          line(mids.at(leaf-parent.at(i)), l, stroke: 1pt + edge)
        }

        // Root: dark, two lines (a "big" task with multiple parts).
        card(root.at(0), root.at(1), 1.3, 0.6, neutral, lines: 2)

        // Mids: one card per subtree colour.
        for (i, m) in mids.enumerate() {
          card(m.at(0), m.at(1), 0.95, 0.45, subtree.at(i))
        }

        // Leaves: lighter shade of the parent subtree colour.
        for (i, l) in leaves.enumerate() {
          let c = subtree.at(leaf-parent.at(i)).lighten(35%)
          card(l.at(0), l.at(1), 0.5, 0.32, c)
        }
      })
    ],
  )
]

#slide[
  #comment(```md
Example: Noise for Dart.

- Dart had no proper library we could use for communication between device and App.
- Noise was the right tech choice still. It helped us a lot.
- I asked Claude to generate one, even though I don't speak Dart - isn't that a violation of this rule?
- No, because I knew that Noise implementations have test vectors.
- Those allow you to verify the output of your implemention bit-by-bit with another reference implementation. Claude could do that when prompted like that.
- Was that all? No, the implementation was minimal (as asked) but did not protect
  against DoS attacks like sending in big chunks. Claude did not fix that.
- Here is where experience with security protocols came into play.
- If you let Claude write tests: Immediately run the coverage viewer over it and check what it did miss. Ideally you add more tests then.

Not all software has test suites of course, but most can be tested.

Short: If you can't say how you'd notice the bug, you don't have a verification strategy - you just have hope.
```)

  = 3. Verify strategy before code
  #text(size: .8em, fill: gray)[There are no shortcuts to quality.]
  #v(.3em)

  Before you accept a generated change, \
  #text(fill: gray)[Name the signal that would tell you it's wrong.]

  #v(.8em)

  #let green = rgb("#3a8f4a")
  #let grey  = rgb("#888888")

  #let verify-card(body, color: green) = box(
    width: 100%,
    inset: (left: .8em, right: .6em, y: .5em),
    stroke: (left: 4pt + color),
    text(size: .9em, weight: "bold")[#body],
  )

  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: .8em,
    row-gutter: .7em,
    verify-card([Comparison against a reference implementation]),
    verify-card([Property-based tests, fuzzing, coverage, ...]),
    verify-card([Type checkers, linters, static analysers]),
    verify-card([`/review` and manual review by colleagues]),
    verify-card([Replay against real production data]),
    verify-card([Work actively on the code for some time]),
  )

  #text(fill: gray)[#emph[Example]: Noise library for Dart — I don't speak Dart.]
]


#slide[
  #comment(```md
- Code was hard to write and maintain, so it was the authority on questions about how a system behaves.
- Now it's easy to find the diff between a written design document and the code.
- We should see our job therefore not as someone who just writes code - that was never the task of a software engineer anyways.
- Claude can do many things faster than us - as long as we risk manage it.
- Even juniors need to step up now and learn design decisions.
- What does not change: You are responsible. I don't want to hear "But Claude said..."

Also, I know that LLMs are nice to wordsmith your stuff. But I saw people on reddit exclusively using LLMs to communicate. That feels like talking to a machine. Personall, I prefer human interaction, even if you don't use the perfect words all the time. If you use LLMs for writing in Slack
or documentation then I never know how much of that was the machine and how much of that was you.
```)

  = 4. Don't make yourself replaceable.
  #text(size: .8em, fill: gray)[You only get replaced if you make yourself replaceable.]

  - Code was the source of truth before, that's changing. \
    #text(fill: gray)[Now it is moving to context given via design documents.]
  - Spend the time Claude saves you on the parts it's bad at. \
    #text(fill:gray)[Namely: decisions, judgement, context, design, #text(fill: rgb(0, 100, 0))[responsibility!]]
  - Reading code is much more important now than writing code. \
    #text(fill: gray)[Keep your tools sharp. Be able to work without Claude.]

  #v(.5em)

  #align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      // Stack of "engineering work" bands. Bottom = AI's turf
      // (greyed). Top = yours (green). The visual story: the value
      // gradient has moved up the stack — go stand where it is now.

      let bar-w = 14.0
      let bar-h = 0.55
      let gap = 0.12

      // Bottom → top.
      let bands = (
        ([Syntax · typing · trivial lookups],         rgb("#e8e8e8"), black, [AI]),
        ([Boilerplate · scaffolding · glue],          rgb("#cdcdcd"), black, [AI]),
        ([Refactors · idioms · routine logic],        rgb("#a8a8a8"), black, [both]),
        ([Reading · understanding · review],          rgb("#5fa370"), white, [you]),
        ([Design · judgement · context · decisions],  rgb("#3a8f4a"), white, [you]),
      )

      for (i, band) in bands.enumerate() {
        let (label, fill-color, text-color, tag) = band
        let y0 = i * (bar-h + gap)
        rect(
          (0, y0),
          (bar-w, y0 + bar-h),
          fill: fill-color,
          stroke: none,
          radius: 0.08,
        )
        // Work label, left-aligned inside the band.
        content(
          (0.3, y0 + bar-h / 2),
          text(size: .75em, weight: "bold", fill: text-color)[#label],
          anchor: "west",
        )
        // Owner tag, right-aligned inside the band.
        content(
          (bar-w - 0.3, y0 + bar-h / 2),
          text(size: .7em, fill: text-color, style: "italic")[#tag],
          anchor: "east",
        )
      }

      // Upward "value" arrow alongside the stack.
      let n = bands.len()
      let stack-top = n * bar-h + (n - 1) * gap
      let arrow-x = bar-w + 0.45
      line(
        (arrow-x, 0.1),
        (arrow-x, stack-top - 0.1),
        stroke: 2pt + rgb("#3a8f4a"),
        mark: (end: ">", fill: rgb("#3a8f4a")),
      )
    })
  ]
]

#slide[
  #comment(```md
- Don't treat it as oracle doing your work. You're not like the guy in a big plant just watching and only getting active when something does not work. - You have to actively work with Claude to reach a good solution. You need to undestand the problem space and design it with Claude. Help Claude to understand the design, use Claude to understand how to design.
- It is basically pair programming but with machines.

Also: be polite :-P Not to please our machine overlords, but just so you
don't forget to when talking to an actual human. And Claude does weird things
when you insult it too much.
```)

  = 5. Treat Claude like a colleague\
  #text(size: .8em, fill: gray)[Talk to it like your seat neighbor.]

  #v(.5em)

  #let blue = rgb("#1f77b4")
  #let orange = rgb("#d9542b")
  #let border = rgb("#dddddd")

  // PR-review-style comment card: avatar (initial in coloured disc),
  // bold name + grey "commented", and the comment body underneath.
  #let pr-comment(initial, name, color, body) = box(
    width: 100%,
    inset: (x: .7em, y: .55em),
    stroke: (
      left: 3pt + color,
      top: 0.4pt + border,
      right: 0.4pt + border,
      bottom: 0.4pt + border,
    ),
    radius: 4pt,
    [
      #grid(
        columns: (auto, 1fr),
        column-gutter: .55em,
        align: horizon + left,
        box(
          width: 1.5em,
          height: 1.5em,
          fill: color,
          radius: 100%,
          inset: 0pt,
          align(
            center + horizon,
            text(size: .7em, fill: white, weight: "bold")[#initial],
          ),
        ),
        text(size: .65em)[
          #text(weight: "bold", fill: color)[#name]
          #text(fill: gray)[ commented]
        ],
      )
      #v(.15em)
      #text(size: .65em)[#body]
    ],
  )

  #grid(
    columns: (1.55fr, 1fr),
    column-gutter: 1em,
    align: horizon,
    [
      - Explain the tasks at hand like you would to a junior colleague. \
        #text(fill: gray)[A very eager, junior colleague with seemingly infinite capacity.]
      - Push back. Ask for alternatives. Let it explain. Disagree. \
        #text(fill: gray)[If you'd reject a colleague's PR for that reasoning, reject the model's.]
    ],[
      #v(-1cm)
      #stack(
      spacing: .55em,
      pr-comment("y", "you",    blue,   [Why a map here and not a for-loop?]),
      pr-comment("C", "claude", orange, [Map is more idiomatic — happy to switch if perf matters.]),
      pr-comment("y", "you",    blue,   [Show me the benchmark first.]),
    )
    ]
  )
]

#slide[
  #comment(```md
- Peter Naur, 1985, "Programming as Theory Building". 
- Already at that time he figured out that code is not the imortant part.
- Punchline: the code is the *artefact*. The thing that's actually
  being built is the team's shared mental model of the problem.
- This is why handovers fail. Documentation captures the artefact,
  not the theory.
```)

  = Bonus: Programming as Theory Building
  #text(size: .8em, fill: gray)[Peter Naur, 1985]

  #v(.5em)
  #grid(
    columns: (1fr, auto),
    column-gutter: 1.5em,
    align: (left + top, right + top),
    [
      - The code is a *by-product*. What you're really building is the *theory* — your team's shared mental model of the problem.
      - Documentation captures the artefact, not the theory. The bugs, the dead ends, the "why not this?" decisions live in people's heads.
      - This is why handovers fail. The theory doesn't transfer cleanly.
    ],
    [
      #image("images/naur_bw.jpg", height: 8cm)
      #v(-.7em)
      #align(center)[
        #text(size: .55em, fill: gray)[
          Peter Naur, 1928–2016\
          Photo: Wikimedia Commons
        ]
      ]
    ],
  )
]

#slide[
  #comment(```md
- The implication for AI is direct and uncomfortable: Claude has no
  theory. It has a snapshot of the artefact, and whatever context
  you put in front of it.
- "Write tests for this file" will make it freeze the current behaviour
  into tests, including the bugs. Because it has no theory of what
  the code *should* do.
- Your job hasn't been automated. Your job is the theory.
- A design doc / decision log is more useful than CLAUDE.md, because
  CLAUDE.md is size-limited. CLAUDE.md gets the headline; the design
  doc gets the reasoning.
```)

  = Bonus: What that means for Claude

  #v(.9em)

  #grid(
    columns: (4fr, 2fr),
    column-gutter: 1em,
    align: horizon,
    [
      - The model has no theory — it sees the artefact and fills the rest in. \
        #text(fill: gray)[Confidently. It won't tell you which is which.]
      - Bad prompt: "Write tests for this file" \
        #text(fill: gray)[It freezes today's behaviour, *bugs included*. Again, no mention.]
      - Your job is still to build the theory. \
        #text(fill: gray)[The AI helps you write the code that follows from it.]
    ],
    align(center + horizon)[
      #cetz.canvas(length: 1cm, {
        import cetz.draw: *

        // Venn: all context (the theory) vs what Claude sees.
        // Region labels live OUTSIDE the circles with thin leader lines
        // pointing into each region — keeps the circles uncluttered.

        let blue   = rgb("#1f77b4")
        let orange = rgb("#d9542b")
        let green  = rgb("#2ca02c")
        let dim    = rgb("#444444")
        let leader = rgb("#999999")

        let theory-c = (0, 0)
        let theory-r = 2.4
        let claude-c = (2.4, 0)
        let claude-r = 1.4

        circle(
          theory-c,
          radius: theory-r,
          fill: blue.transparentize(85%),
          stroke: 1.4pt + blue,
        )
        circle(
          claude-c,
          radius: claude-r,
          fill: orange.transparentize(78%),
          stroke: 1.4pt + orange,
        )

        // Green-tinted intersection lens, drawn over the muddy overlap.
        let ix-x = 1.99167
        let ix-y = 1.33913
        merge-path(close: true, fill: green.transparentize(60%), stroke: none, {
          arc-through(
            (ix-x, -ix-y),
            (theory-r, 0),
            (ix-x, ix-y),
          )
          arc-through(
            (ix-x, ix-y),
            (2.4 - claude-r, 0),
            (ix-x, -ix-y),
          )
        })

        // Circle titles, outside above each circle.
        content(
          (theory-c.at(0) - 0.7, theory-r + 0.35),
          text(size: .8em, weight: "bold", fill: blue)[All context],
          anchor: "south",
        )
        content(
          (claude-c.at(0) + 0.3, claude-r + 0.35),
          text(size: .8em, weight: "bold", fill: orange)[~~~~~Claude sees],
          anchor: "south",
        )

        // Callout helper: thin leader line + width-constrained label box,
        // so the three labels can't bleed into each other.
        let callout(anchor-pt, label-pt, title, body, title-color, width: 2.4cm) = {
          line(anchor-pt, label-pt, stroke: 0.7pt + leader)
          content(
            label-pt,
            anchor: "north",
            box(width: width)[
              #set text(size: .6em)
              #set par(leading: .4em)
              #align(center)[
                #text(weight: "bold", fill: title-color)[#title] \
                #text(fill: dim)[#body]
              ]
            ],
          )
        }

        // Left crescent: the unwritten theory Claude can't see.
        // Pushed further left to clear the centre callout.
        callout(
          (-1.3, -1.4),
          (-2.8, -2.4),
          [unwritten theory],
          [design decisions \ why-nots · retros \ team intuition],
          blue,
        )

        // Overlap: the artefact (what does get written down).
        // Pushed lower so it staggers below the two side callouts.
        callout(
          (1.55, -1.0),
          (1.55, -3.0),
          [the artefact],
          [code · docs \ `CLAUDE.md` · prompts],
          green,
        )

        // Right sliver: Claude's priors / guesses.
        // Pushed further right to clear the centre callout.
        callout(
          (3.3, -0.5),
          (4.9, -1.9),
          [training data],
          [average software / \ hallucinations],
          orange,
        )
      })
    ],
  )
]

#slide[
  #comment(```md
That image is AI generated by the way. It depcits the end of the zauberlehrling
where he is overwhelmed from what we summoned. His old master has to help him.
  ```)

  #set align(center + horizon)
  #set page(footer: none)

  #place(left + horizon)[

  #v(2em)
  #text(size: 1.2em, fill: gray)[Feedback?]

  #text(size: 1.2em, fill: gray)[Questions or Disagreements?]
  #v(1em)
  #emph[Homework]:
  #v(1em)
  PROGRAMMING AS THEORY BUILDING.
  ]

  #place(right + horizon, image("images/master.jpg", height: 110%))
]

#slide[
  = Backup: More on skill atrophy & cognition

  #let card(stat, headline, body, source, color: rgb("#c0392b")) = box(
    width: 100%,
    inset: (left: .8em, right: .6em, y: .4em),
    stroke: (left: 4pt + color),
    [
      #text(size: 1.4em, weight: "bold", fill: color)[#stat]
      #v(-.4em)
      #text(size: .85em, weight: "bold")[#headline] \
      #text(size: .6em, fill: gray)[#body] \
      #v(.1em)
      #text(size: .55em, fill: gray, style: "italic")[#source]
    ],
  )

  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: .8em,

    card(
      [28→22%],
      [endoscopists deskilled],
      [adenoma detection rate dropped from 28% to 22% when working without AI, after months of AI exposure · skill atrophy beyond software],
      [Lancet Gastro & Hepatology · 2025],
    ),
    card(
      [−17%],
      [the vendor measures the cost],
      [junior devs scored 17% lower on a concept quiz after building with AI · code-reading and debugging impaired],
      [Shen & Tamkin · Anthropic · 2026],
    ),
    card(
      [83%],
      [your brain on LLMs],
      [LLM users couldn't quote their own essays · EEG showed weakest neural connectivity of the three groups],
      [Kosmyna et al. · MIT Media Lab · arXiv:2506.08872 · 2025],
    ),
  )
]

#slide[
  #set page(footer: none, header: none)

  = Backup: Positive AI studies

  #let card(stat, headline, body, source, color: rgb("#3a8f4a")) = box(
    width: 100%,
    inset: (left: .8em, right: .6em, y: .35em),
    stroke: (left: 4pt + color),
    [
      #text(size: 1.4em, weight: "bold", fill: color)[#stat]
      #v(-.4em)
      #text(size: .85em, weight: "bold")[#headline] \
      #text(size: .6em, fill: gray)[#body] \
      #v(.1em)
      #text(size: .55em, fill: gray, style: "italic")[#source]
    ],
  )

  #grid(
    columns: (1fr, 1fr, 1fr),
    rows: (1fr, 1fr),
    column-gutter: .8em,
    row-gutter: .8em,

    card(
      [+55%],
      [Copilot task speed],
      [sandbox RCT · optimistic ceiling],
      [Peng et al. · GitHub · 2023],
    ),
    card(
      [+14%],
      [call-center output],
      [novices gain most · METR in reverse],
      [Brynjolfsson, Li & Raymond · NBER w31161 · 2023],
    ),
    card(
      [~40%],
      [faster writing],
      [time saved, quality up · cheap verification],
      [Noy & Zhang · Science · 2023],
    ),
    [],
  )
]

#slide[
  = Backup: Further reading — \
    Programming as Theory Building

  #v(.8em)

  #let reading(title, subtitle, url) = box(
    width: 100%,
    inset: (left: .8em, right: .6em, y: .5em),
    stroke: (left: 4pt + rgb("#444444")),
    [
      #link(url)[#text(size: .9em, weight: "bold")[#title]]
      #v(-.25em)
      #text(size: .7em, fill: gray)[#subtitle]
    ]
  )

  #stack(
    spacing: .6em,
    reading(
      [Peter Naur — "Programming as Theory Building" (1985, PDF)],
      [The original paper.],
      "https://pages.cs.wisc.edu/~remzi/Naur.pdf",
    ),
    reading(
      [Christian Ekrem — "Programming as Theory Building"],
      [Modern take: LLM-generated code belongs to nobody's theory. Good entry point to the original.],
      "https://cekrem.github.io/posts/programming-as-theory-building-naur",
    ),
    reading(
      [Christian Ekrem — "Architecture by Autocomplete"],
      [Concrete example: AI defaults to primitive types because training data is full of them.],
      "https://cekrem.github.io/posts/architecture-by-autocomplete",
    ),
    reading(
      [Christian Ekrem — "LLMs Corrupt Your Documents"],
      ["The theory dies twice." Design docs as source of truth silently degrade under AI edits.],
      "https://cekrem.github.io/posts/llms-corrupt-your-documents",
    ),
  )
]
