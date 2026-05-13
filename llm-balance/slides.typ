// Get Polylux from the official package repository
#import "@preview/polylux:0.4.0": *
#import "@preview/cetz:0.3.2"

#enable-handout-mode(false)

// TODO: Taschenrechner + Navigation (google maps) mention
// TODO: Mention productivity decrease due to pro-longed quality control (review) and understanding gap?

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
}

#show link: set text(blue)
#set text(font: "TT2020 Style E", size: 20pt)
// #show raw: set text(font: "Fantasque Sans Mono")

// #set heading(numbering: "I.")


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
  - Welcome the audience. Briefly say what this is NOT: a dunk on AI.
  - It's about finding the right place on the spectrum and not handing
    over more control than we mean to.
  - ~30 min, plenty of room for discussion after.
```)

  // Title slide layout: full-slide-height illustration anchored to the
  // right; title text in the remaining space on the left. The image is
  // portrait (~9:10) on a 16:9 slide, so it occupies roughly the right
  // half and leaves room for the title without covering the figure.
  // Margin is zeroed so the image truly bleeds to the slide edges.
  #set page(footer: none, header: none, margin: 0pt)

  #place(right + horizon, image("images/zauberlehrling.png", height: 100%))

  #place(left + horizon, box(width: 50%, inset: 2em)[
    #text(size: 2.2em, weight: "bold")[The vibes\ that I summoned...]

    #v(1em)
    #text(size: .95em, fill: gray)[
      Thoughts on working\
      with AI agents.
    ]

    #v(2.5em)
    #text(size: .85em)[Chris Pahl · 2026]
  ])
]


#slide[
  #comment(```md
  - The conversation is almost never "AI or no AI" — it's "how much AI,
    where, for what."
  - Both ends are positions on the same spectrum. We can choose where to sit
    per task, per project, per person.
  - Using GenAI is *always* trading some control (and often quality) for
    productivity. There is no free lunch. The question is how big the trade
    is and whether you noticed making it.
```)

  = The Spectrum

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
          rgb("#3a8f4a"), rgb("#d9b53d"), rgb("#c0392b"),
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
    Using GenAI is a tradeoff between control and productivity.

    It's not black & white.
  ]
]

#slide[
  #comment(```md
  Three curves on the same X-axis (manual → vibecode).

  - Quality: starts middling (humans are flawed too!), rises with judicious
    AI assistance, then falls off a cliff when nobody is reading the diff.
  - Productivity: low on full manual, climbs through the middle, peaks
    just right of centre — and then *falls again* as quality issues create
    rework. (METR 2025: experienced devs were 19% SLOWER with AI on their
    own mature OSS repos, while predicting +24% speed-up.)
  - Confidence: the dangerous curve. High on manual (you wrote it, you
    know it), dips in the middle (you're humble, you verify), spikes on
    the right where it *decouples from reality*. (Perry et al. 2023:
    devs using AI assistants wrote less secure code AND were more
    confident the code was correct.)
  - The widening gap between confidence (green) and quality (blue) on
    the right is the most important thing on this slide. That's the
    Dunning-Kruger zone.
```)

  = My take: Quality vs Productivity

  #v(.5em)
  #align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      let w = 14
      let h = 6

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
      content((2.5, 4.6), text(weight: "bold", fill: q-color)[Quality])
      content((9.7, 5.5), text(weight: "bold", fill: p-color)[Productivity])
      content((13.0, 6.4), text(weight: "bold", fill: c-color)[Confidence])

      // sweet-spot marker at the apex of the Quality curve
      let sx = 6.0
      let sy = 5.18
      circle((sx, sy), radius: 0.14, fill: black)
      line((sx, sy + 0.15), (sx, sy + 0.9), stroke: 0.7pt + gray)
      content((sx, sy + 1.2), text(size: .85em, fill: gray, style: "italic")[sweet spot])

      // gap annotation on the right edge: confidence (6.0) vs quality (1.2)
      // a thin bracket showing the dangerous divergence
      let gx = w - 0.3
      line((gx, 1.2), (gx, 6.0), stroke: (paint: gray, dash: "dotted", thickness: 0.8pt))
    })
  ]

  #v(.3em)
  #align(center)[
    #text(size: .85em, fill: gray)[
      Quality peaks in the middle. Productivity follows it down.
      *Confidence diverges from both* — that's the dangerous zone.
    ]
  ]
]

#slide[
  #comment(```md
  Don't read every card — let the slide do the talking. Hit two or three,
  then move on. Audience just needs the impression "this isn't one person's
  hot take, there's a stack of independent measurements pointing the same way".

  Card-by-card detail:

  -19% (METR, 2025). Randomised controlled trial. 16 experienced OSS devs,
  246 real tasks in their OWN mature repos, ~5 yr experience each. With
  Cursor + Claude 3.5/3.7 they were 19% slower. They PREDICTED +24% faster
  beforehand; even afterward they still BELIEVED they'd been ~20% faster.
  The perception-reality gap is the real finding.

  ~40% (NYU, 2021 — "Asleep at the Keyboard?"). Tested Copilot on 89
  scenarios in security-relevant settings. ~40% of generated programs
  contained exploitable bugs. The original alarm bell; replicated since.

  8x (GitClear, 2024). Analysis of 211M changed lines, 2020-2024.
  Duplicated code blocks rose ~8x. Refactored ("moved") lines fell from
  24% → 10%. Churn (lines rewritten within 2 weeks) rose 5.5% → 7.9%.
  Translation: AI nudges devs to copy-paste instead of refactor.

  -7.2% (DORA / Google Cloud, 2024). State-of-DevOps survey. AI adoption
  correlated with 1.5% throughput drop AND 7.2% stability drop. 39% of
  respondents reported little-to-no trust in AI-generated code. This is
  the broadest dataset we have.

  29.5% (Fu et al., ACM TOSEM 2025). Empirical study: 29.5% of AI-generated
  Python snippets and 24.2% of JavaScript snippets contained known CWEs
  (Common Weakness Enumeration entries). Replicates and quantifies the
  NYU finding.

  ↓ critical thinking (Lee et al., CHI 2025, Microsoft + CMU). 319
  knowledge workers, 936 first-hand examples. Finding: higher confidence
  in GenAI is associated with LESS critical thinking. Higher self-confidence
  is associated with MORE. Ties directly to the cog-biases slide.

  Source URLs in the speaker notes file. VERIFY every figure before
  presenting — these came from a literature pull, not first-hand reading.
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
      [AI-generated snippets containing known vulnerabilities],
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
  Rapid-fire — don't dwell on any one. Goal: land the cumulative weight
  before pivoting to "but maybe it's how we use it".

  Societal & infrastructure:
  - Ecological cost: training and inference burn power and water.
  - Hardware crisis: GPU demand distorts supply for everyone.
  - Concentration: a handful of companies own the server farms.
  - Economic transfer: value flows from many small actors to a few large ones.

  Trust, legal, security:
  - Data privacy: "trust me, bro" is not a threat model.
  - Licensing: models can regurgitate GPLv3 / proprietary code verbatim.
  - Operator bias: models can be tuned to express the values of whoever runs them (Hi Grok!).
  - Prompt injection & MCP: a whole new attack class.
  - Cyberattack automation: phishing, social engineering, deepfakes at scale.

  Information ecosystem:
  - Misinformation at scale: generation cheaper than fact-checking.
  - Content degradation: the open web fills with AI slop.
  - Recursive collapse: tomorrow's models train on yesterday's slop.
  - Communities thinning out: SO, OSS Q&A, mailing lists — fewer humans.

  Workforce & cognition:
  - Fewer juniors hired: no juniors today → no seniors tomorrow.
  - Atrophy: skills you don't use, you lose.
  - Schools: AI can boost or bypass learning (more on this in a moment).
  - Convincing hallucinations: the failure mode that will eventually kill someone.
```)

  = Risks for all

  #let red = rgb("#c0392b")
  #let mid = rgb("#444444")
  #let pale = rgb("#888888")

  #align(center + horizon)[
    #tag(.85em, [ecological cost], color: pale, angle: -3deg)
    #tag(1.7em, [Convincing hallucinations], color: red, angle: -2deg, weight: "bold")
    #tag(.8em, [schools], color: pale, angle: +3deg)
    #tag(1.1em, [licensing], color: mid, angle: -2deg)
    #tag(1.55em, [Atrophy], color: black, angle: +2deg, weight: "bold")
    #tag(.85em, [concentration], color: pale, angle: +1deg)
    #tag(1.15em, [misinformation at scale], color: mid, angle: -1deg)
    #tag(1.45em, [Prompt injection & MCP], color: red, angle: +3deg, weight: "bold")
    #tag(.9em, [content degradation], color: pale, angle: -2deg)
    #tag(1.6em, [No juniors hired], color: black, angle: -1deg, weight: "bold")
    #tag(1.0em, [hardware crisis], color: mid, angle: +2deg)
    #tag(1.1em, [operator bias], color: mid, angle: -3deg)
    #tag(1.2em, [recursive collapse], color: mid, angle: +1deg)
    #tag(.85em, [economic transfer], color: pale, angle: -2deg)
    #tag(1.25em, [data privacy], color: red, angle: +2deg)
    #tag(1.05em, [cyberattack automation], color: mid, angle: -1deg)
    #tag(.85em, [communities thinning out], color: pale, angle: +3deg)
  ]
]

#slide[
  = Risks for us
  #let mid = rgb("#444444")
  #let pale = rgb("#888888")
  #let red = blue

  #align(center + horizon)[
    #tag(.85em, [ecological cost], color: pale, angle: -3deg)
    #tag(1.7em, [Convincing hallucinations], color: blue, angle: -2deg, weight: "bold")
    #tag(.8em, [schools], color: blue, angle: +3deg)
    #tag(1.1em, [licensing], color: blue, angle: -2deg)
    #tag(1.55em, [Atrophy], color: blue, angle: +2deg, weight: "bold")
    #tag(.85em, [concentration], color: blue, angle: +1deg)
    #tag(1.15em, [misinformation at scale], color: mid, angle: -1deg)
    #tag(1.45em, [Prompt injection & MCP], color: blue, angle: +3deg, weight: "bold")
    #tag(.9em, [content degradation], color: pale, angle: -2deg)
    #tag(1.6em, [No juniors hired], color: blue, angle: -1deg, weight: "bold")
    #tag(1.0em, [hardware crisis], color: blue, angle: +2deg)
    #tag(1.1em, [operator bias], color: mid, angle: -3deg)
    #tag(1.2em, [recursive collapse], color: mid, angle: +1deg)
    #tag(.85em, [economic transfer], color: pale, angle: -2deg)
    #tag(1.25em, [data privacy], color: blue, angle: +2deg)
    #tag(1.05em, [cyberattack automation], color: blue, angle: -1deg)
    #tag(.85em, [communities thinning out], color: blue, angle: +3deg)
  ]
]


// ─────────────────────────────────────────────────────────────────
// 8. PIVOT — "maybe it's not the tool, it's how we use it"
// ─────────────────────────────────────────────────────────────────
#slide[
  #comment(```md
  - Deliberately re-frame: we've just listed a lot of scary things, but
    most of them are about *how* AI is deployed, not whether it exists.
  - Schools are a clean case study because the same tool produces opposite
    outcomes depending on use.
```)

  #set align(center + horizon)

  #text(size: 1.5em)[Exhibit A: schools.]

  #v(2em)
  #text(size: 1.3em, style: "italic", fill: gray)[
    Maybe it's not so much about the tool —\
    but about how we use it?
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

  VERIFY exact numbers and SSRN ID before presenting.
```)

  = Same tool, opposite outcomes

  #v(1cm)

  #align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      // Bastani et al., ~1000 Turkish high-school maths students.
      // Practice gain over control: Solver ≈ +48%, Tutor ≈ +127%.
      // Unaided exam vs control:    Solver ≈ -17%, Tutor ≈ ±0%.
      // VERIFY exact numbers before presenting.
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
  ]
]


#slide[
  #set page(footer: none)
  #v(4cm)
  #align(center)[
    #text(size: 2em)[Are #emph[you] team tutor or team solver?]
  ]
]

#slide[
  #comment(```md
  This slide is *automation bias, with our own receipt*. It sets up the
  bias cards that follow.

  Two numbers, both from our team's Claude Code dashboard, April 2026:
  - 98.7% suggestion acceptance rate. If a junior's PRs landed at 98.7%
    accepted as-is, we'd be worried about whether the review was real.
  - 27,757 lines accepted in one month. ≈ 925 lines per working day.

  Reality check on review capacity:
  - Industry rule of thumb for *careful* code review: ~100–200 LoC/hour
    (Cohen, *Best Kept Secrets of Peer Code Review*; Google's internal
    guidance is in the same ballpark).
  - 27,757 lines would take ~138 hours of careful review.
  - A working month is ~176 hours. ~38 hours left for everything else
    — design, debugging, meetings, actually writing the code we're NOT
    accepting from Claude.
  - We did not spend 138 hours reviewing.

  Don't be defensive — it's not about our team being lazy. It's about
  what 98.7% *necessarily* means: most acceptances are not carefully
  reviewed acceptances. They can't be. There aren't enough hours in the
  month.

  Tee up the biases section: this is the data behind why automation
  bias matters in practice.
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
        #text(size: .6em, fill: gray)[1.3% rejected. Is that a review process?]
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
        #text(size: .6em, fill: gray)[≈ 925 LoC/day · careful review ≈ 100–200 LoC/hour]
      ]
    ),
  )

  #v(.6em)
  #align(center)[
    #text(size: .85em)[
      Reviewing 27,757 lines carefully ≈ *138 h*. A working month ≈ *176 h*.\
      #text(fill: gray, style: "italic")[
        Either we're 7× faster than the industry — or we didn't review.
      ]
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
  These are *our* biases — defaults wired into how humans process
  suggestions from an authoritative-sounding source. They aren't new;
  LLMs just hit each of them harder than almost any tool before.

  Card-by-card:

  - Automation bias. We accept machine suggestions more readily than human
    ones. GitHub reports ~30% of Copilot suggestions accepted as-is (VERIFY).
    Combine that with how often we even read the diff.

  - Anchoring. The first suggestion shapes the solution space. LLMs
    suggest fast, so they almost always get to anchor first — your
    "thinking" then becomes refining their idea rather than generating
    your own.

  - Confirmation bias. The prompt we type already contains the answer
    we want. Phrasing alone often determines what comes back.

  - Authority bias. Eloquent + fast + confident reads as expert. LLMs
    are eloquent, fast, AND confident — even when wrong. We're not
    wired to discount fluency.

  - Dunning–Kruger, remixed. Users mistake the model's competence
    for their own. Dangerous for seniors and juniors alike. The senior
    thinks "this is what I'd have written"; the junior thinks "I now
    understand this codebase".

  - Illusion of explanatory depth. We think we understand something
    until asked to explain it. Maths teachers know. AI-generated code
    we've reviewed but not WRITTEN sits squarely in this trap.

  Not on the slide but worth mentioning:
  - Atrophy. Not a bias — the *cumulative effect* of the others over
    months. Skills decay quietly.

  Plug: full talk on cognitive biases coming next time I'm in Augsburg.
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
      [Eloquent + fast + confident reads as expert.],
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
      ["yes, I read the diff" → bug],
      hb,
    ),
  )
]


#slide[
  #comment(```md
  Flip side: the model has its *own* biases, baked in statistically by
  the training process. Different shape from human biases, same outcome:
  the answer you get is not the answer you'd derive from first principles.

  Card-by-card:

  - Sycophancy. It's easy to talk the model out of a correct answer.
    Push back hard and it caves, even when right. RLHF training rewards
    apparent helpfulness, which correlates with agreement. Echo chambers
    but for code: ask twice the way you wanted, get the answer you wanted.

  - Historical / representation bias. Trained on the open web —
    overwhelmingly modern, English-speaking, Western. Defaults are
    weighted toward what's most COMMON, not what's most correct for
    YOUR codebase.

  - Attention bias. The first and last things you say dominate. The
    middle of a long context evaporates. Long system prompts + long
    files = unpredictable adherence to the rules buried in the middle.

  - Omission bias. Rare and novel answers are statistically suppressed
    by common ones in training data. The model is bad at being weird.
    If your problem requires an unusual answer, the model gravitates
    to the safe-but-wrong one.

  Tying it back: the human biases and the model biases compound. We
  trust the fluent-sounding output (authority + automation); it tends
  toward the common answer (omission + historical); we don't push
  back (confirmation + the model's sycophancy completing the loop).
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
      [the model is bad at being weird],
      mb,
    ),
  )
]

#slide[
  #comment(```md
  - This is the slide that should make the room uncomfortable for a
    second. The juniors-not-hired problem isn't just an economics
    problem — it's a *verification* problem.
  - If you don't know what good code looks like, you can't prompt for it.
  - If you don't understand the diff, you can't review it.
```)

  = Hen & Egg

  #v(1em)
  #set text(size: 1.1em)

  - If you don't know what good software looks like - \
    #emph[how do you write the right prompt?]

  #v(.6em)

  - If you can't understand what the model just generated - \
    #emph[how do you verify it?]

  - If you can't code (anymore) - \
    #emph[how can you understand the diffs?]

  #v(1em)
  #text(size: .9em, fill: gray)[Humans are still very much required.]
]

#slide[
  #v(4cm)
  #align(center)[
    #text(size: 2em)[How do #emph[you] keep up with Claude?]
  ]
]

#slide[
  #comment(```md
  - Frame the next few slides: not commandments, just a small set of
    habits that have worked for me and that survive contact with reality.
```)

  = Five habits that helped me

  #v(2cm)

  + Think first, generate then.
  + Split the work - keep some of it manual.
  + Have a real verification strategy.
  + You only get replaced if you make yourself replaceable.
  + Treat the AI as a colleague.
]

#slide[
  #comment(```md
  - Rule 1: my favourite worked example is SQL. Sketch the query yourself,
    *then* ask the model to review and optimise. You stay in the loop;
    the model adds value without anchoring you.
  - Rule 2: deliberately keep some work manual. Not for purity — for skill
    maintenance, and because the parts you do manually are the parts you
    actually understand later.
```)

  = 1. Think first, generate then\
  #text(size: .8em, fill: gray)[Don't let the model set the anchor.]

  #v(.3em)
  - Sketch the SQL query yourself,
  - Then ask the model to review and optimise.
  - Write the function signature and the docstring.
  - Then let the model fill the body.
  - You set the anchor; the model refines.

  #v(1em)
]

#slide[
  = 2. Split the work
  #text(size: .8em, fill: gray)[The parts you write are the parts you understand.]

  #v(.3em)
  - Leave the manual labor work to the model (e.g. build systems)
  - Keep doing at least some smaller tasks yourself.
  - I suggest: Do most of critical production code yourself.
  - Tests, Build system, scripts, boilerplate: Default to Claude.
]

#slide[
  #comment(```md
  - This is where most teams quietly skip a step.
  - The "noise for Dart" example from our work: when you can't read
    everything the model writes, lean on automated signals — fuzz inputs,
    property tests, regressions, smoke tests on real data.
  - The point isn't "more tests". The point is: *before* you accept a
    large generated change, name the signal that would tell you it's wrong.
```)

  = 3. Have a real verification strategy

  #v(.3em)
  - Before you accept a generated change, *name the signal* that would tell you it's wrong.
  - Find other ways if the diff is too big:
    - Property-based tests, fuzzing (e.g. _noise_ for Dart).
    - Type checkers, linters, static analysers.
    - Replay against real production data.
  - If you can't say how you'd notice the bug, you don't have a verification strategy - you have hope.



#text(fill: gray)[
  Example: Noise library for Dart. I don't speak Dart.
]

]


#slide[
  #comment(```md
  - Rule 4 sounds cynical but it's just practical. The replaceable parts
    of your job are the ones where you're acting as a slow autocomplete.
    Stop doing those parts that way.
  - Rule 5: collaborator, not oracle. You'd push back on a coworker. Push
    back on the model. You'd ignore a coworker who hallucinated. Same
    rule.
```)

  = 4. You only get replaced if you make yourself replaceable.
  #text(size: .8em, fill: gray)[You only get replaced if you make yourself replaceable.]

  #v(.3em)
  - The replaceable parts of your job are the parts where you're already a slow autocomplete.
  - Spend the time AI saves you on the parts no model can do: judgement, context, design.
  - Code was the source of truth before, that's changing.
  - Now you have more time to think about design and purpose.
  - If you just operate Claude you are replaceable.
]

#slide[
  = 5. Treat the AI as a colleague\
  #text(size: .8em, fill: gray)[Not an oracle, not a junior, not magic.]

  #v(.3em)
  - Push back. Ask for alternatives. Disagree.
  - It's a very eager, sometimes rather junior colleague with seemingly infinite power.
  - If you wouldn't accept a colleague's PR with the same reasoning, don't accept the model's.
]

#slide[
  #comment(```md
  - Peter Naur, 1985, "Programming as Theory Building". One of the most
    important short papers in the field.
  - Punchline: the code is the *artefact*. The thing that's actually
    being built is the team's shared mental model of the problem.
  - This is why handovers fail. Documentation captures the artefact,
    not the theory.
```)

  = Extra: Software as Theory Building
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
  - "Write tests for this file" → it freezes the current behaviour
    into tests, including the bugs. Because it has no theory of what
    the code *should* do.
  - Your job hasn't been automated. Your job is the theory.
  - A design doc / decision log is more useful than CLAUDE.md, because
    CLAUDE.md is size-limited. CLAUDE.md gets the headline; the design
    doc gets the reasoning.
```)

  = What that means for AI

  - The model has no theory. It has the artefact and the context you give it.
  - "Write tests for this file" → it freezes today's behaviour, *bugs included*.
  - Your job is still to build the theory. The AI helps you write the code that follows from it.

  #v(.5em)
  *Practical:*
  - Keep a design doc / decision log. The *why*, not just the *what*.
  - `CLAUDE.md` is size-limited — use it for headlines, link out for depth.
]

#slide[
  #comment(```md
  - One sentence summary. Then open it up.
  - If the room is quiet: start with "where on the spectrum do you sit
    today, and where would you like to be in six months?"
```)

  #set align(center + horizon)
  #set page(footer: none)

  #place(left + horizon)[

  #v(2em)
  #text(size: 1.2em, fill: gray)[Questions or Disagreements?]

  #emph[Homework]: \
  Read SOFTWARE AS THEORY BUILDING.
  ]

  #place(right + horizon, image("images/master.jpg", height: 110%))
]

// TODO: End with zauberlehrling end refernce?
