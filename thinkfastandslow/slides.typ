// Get Polylux from the official package repository
#import "@preview/polylux:0.4.0": *

#enable-handout-mode(false)

// Can be used to embed speaker notes:
#let comment = toolbox.pdfpc.speaker-note

#show link: set text(blue)
#set text(font: "Andika", size: 20pt)
#show raw: set text(font: "Fantasque Sans Mono")
#show heading: it => [
  #set align(center)
  #it.body
]

#let new-section-slide(title) = slide[
  #set page(footer: none, header: none)
  #set align(horizon)

  #let g = gradient.linear(
    color.rgb("#0067aa"),
    color.rgb("#dd6600"),
  )
  #let g2 = gradient.conic(
    color.rgb("#dd6600"),
    color.rgb("#0067aa"),
  )

  #place(dx: 00%, dy: 55%, image("images/logo.png"))
  #place(dx: 17%, dy: 56%, circle(fill: g2, stroke: black, radius: 0.3cm))
  #place(dx: 19.6%, dy: 49%, circle(fill: g2, stroke: black, radius: 0.4cm))
  #place(dx: 22%, dy: 40%, circle(fill: g2, stroke: black,radius: 0.5cm))

  #place(
    dx: 25%,
    dy: 20%,
    rect(
      radius: 1cm,
      inset: 1cm,
      fill: g,
      stroke: black,
    )[
      #set text(size: 1.5em)
      #set text(fill: white)
      #strong(title)
    ]
  )

  #toolbox.register-section(title)
]

// Make the paper dimensions fit for a presentation and the text larger
#set page(
  paper: "presentation-16-9",
  footer: [
    #set text(fill: gray, size: .6em)
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
    #let c = toolbox.all-sections( (sections, current) => {
      current
    })

    #set text(fill: gray)
    
    #toolbox.progress-ratio(ratio => [ #calc.round(ratio * 100)% ]) |
    #c
    #h(1fr)
    Psychology in software

  ]
)

#slide[
  #comment(```md
  # Welcome
  
  Today Im not going to talk about the hardware we run our software on,
  but about the hardware we are running software development on. Our brain.

  We start by insulting ourselves. I wrote a small poem to get us in the right mood.
```)

  #set page(footer: none, header: none)

  #v(2cm)
  #align(center)[
    #image("images/logo.png")
  ]

  #[
    #set text(size: 30pt, weight: 1200)

    #align(center)[
      Psychology in Software Development
    ]

    #set text(size: 10pt, weight: 200)

    #align(center)[
      Chris Pahl | 2025
    ]
  ]

]

#new-section-slide("Intro")

#slide[
  #comment(
    ```md
Written by that guy over there, who was a psychologist. I can recommend the read.

I want you to accept that our brain makes plenty mistakes all the time
and we cannot really trust ourselves. This hopefully does not come as news to most of you.
    ```
  ) 

= Intro Poem
  #toolbox.side-by-side[
    #item-by-item[
      - I have read a cool book.
      - And you should too!
      - It showed me: My brain is stupid.
      - And so are you!
    ]
  ][
    #uncover(5)[
      #image("images/kahnemann.png", width: 85%)
    ]
  ]
]

#slide[
= Cognitive biases 🪲
  
  #comment(
    ```md
There are a lot of bugs we make during thinking, and they have a name: Cognitive bias.

We usually do not notice, as our brain has some mechanism to cover up its faults.
Not all of them are covered. just those that lead to bad software. And even that list is probably not complete.
    ```
  ) 

    #item-by-item[
    - Our brain was not made to write software. // (but rather to find food and quickly notice the predators)
    - We tend to think of our brain as reliable logical processor. // ("We" is our brain and it is lying)
    - Our brain has bugs, which are called #emph("cognitive bias"). // (and there are thousands of them)
    - We focus on how our brain fails while writing good software.
    - I'm qualified for this talk because I do software and have a brain.
  ]
]

#slide[
  #comment(
    ```md
    Note: This slide is clickable!
    ```
  ) 

  #align(center)[
    #link("https://upload.wikimedia.org/wikipedia/commons/6/65/Cognitive_bias_codex_en.svg")[
      #image("images/cognitive_bias_map.png", height: 100%)
    ]
  ]
]

#slide[
  #comment(
    ```md
    Lets look at some of those bugs. I mean, you do not need to take my word for granted when calling myself stupid.

    Anything wrong in this picture?

    Our brain just inserted the info "there is a mouth, here are some eyes".
    It is used to reading faces, but not when they are up side down.
    It is like a big pattern matching machine.
    ```
  ) 
  #align(center)[
    = Don't believe me?

    #toolbox.side-by-side[
      #image("images/thatcher-faces-upsidedown.png", width: 85%) 
    ][
      #uncover("2-")[
        #image("images/thatcher-faces-turnedaround.png", width: 85%)
      ]
    ]
  ]
]

#slide[
  #comment(
    ```md
    Im going to show an image with two objects and it and I want you to tell me what it did with you.
    Watch your thoughts and emotions closely.

    Your brain invented a little story about bananas making you sick without being asked.
    Even thought there was no story. Take away: It links objects together, even if there is no link.

    Also: You are now more likely to avoid bananas for some time subconsciously. Congratulations!
    ```
  ) 
  #align(center)[*Watch your thoughts:*]
  #uncover("2-")[
    #align(center)[
      #image("images/banana-vomit.png", width: 70%)
    ]
  ]
]

#slide[
  #comment(
    ```md
    Many of you probably know this one. 
    Even if you know, you can't see it.
    
    This means: Our brain cannot be made fully aware of its mistakes. It just continues to fail.
    ```
  ) 
  == Which is the longest line?

  #only(1)[
    #align(center)[
      #image("images/müller-lyer.png", width: 60%)
    ]
  ]
  #only(2)[
    #align(center)[
      #image("images/müller-lyer-fixed.png", width: 60%)
    ]
  ]
]

#slide[
  #comment(
    ```md
    What is written there?
    
    THE CAT. But the H doubles as A. How many of you did not notice it?
    This is an example for our brain being flexible. It can interpret meaning
    even into incomplete data. We might not be notified that the data is incomplete.
    ```
  ) 
  #align(center)[
    #v(5cm)
    #image("images/the_cat.png", width: 30%)
  ]
]

#slide[
  #comment(
    ```md
    Until now you might argue: Eh, those were just optical illusions and other tricks.
    Nothing that influences us a lot. Well, not quite true. software development means 
    makings hundreds of small and big decisions every day.
    
    I will show an experiment, where most will choose the clearly worse choice reliably.

    Trial 1: 60s 14C cold water.
    Trial 2: 60s 14C cold water + 30s 15C cold water.
    
    Afterwards participants were asked which trial they would rather repeat.
    What did they choose? Mostly trial 2.
    
    This experiment shows that people choosing more pain than they needed to.
    It's not logical, but it's an example of the peak end rule. The slightly
    higher temperature at the end made the experience in the memory of the participants
    more favorable, as the end was slightly less painful.
    
    We do judge memories largely by how they felt at their peak (or most intense point)
    and at its end. We do not keep book whether it was an enjoyable experience in total,
    we remember the most joy or the most trauma and how we felt at the end. The rest is still
    there but is not really picked as first thing when we remember the event.
    
    This one example of where we are not capable of making informed decisions.
    ```
  ) 
  = Peak-End-Rule
  #align(center)[
    #image("images/peak-end-ice-water.png", width: 80%)
  ]
]

#slide[
  #comment(
    ```md
    As developers you probably asking yourself: How do those bugs happen?
    It has to do with the "architecture" of our brain.
    
    There are two systems: 1 and 2. Only one of them runs at a time.

    1 is automatic, fast, subconscious... and error prone.
    It does its work by pattern matching and heuristics. It is good for finding predators.
    If it cannot find a solution, 2 is triggered.

    2 is manual, slow, effortful but reliable. It is where our logic is.
    It is like a slow general purpose cpu. All kind of new problems can be processed here.
    It is what makes us humans so special.
    ```
  )
  #align(center)[
    #image("images/system1and2.jpg")
  ]
]

#slide[
  #comment(```md 
  Please do the following: Knock on the table in a constant frequency.
  I will show you some simple math problems.

  As you can see, System 1 can think fast, but is wrong often,
  while System2 is slow (and is more often right - eventually)
  ```)
  = Math
  #item-by-item[
    - $2+2$       // you did not have to think right? Plain pattern matching.
    - $21 dot 13$ // now you probably have to use system 2. Did the knocking stop?
    - $77+33$     // chances are you were wrong, sometimes system1 triggers because this feels familiar (7 + 3 + 10), for some system2 triggered.
    - $23 dot 42$
  ]
  // By the way: When you walk and see an equation you cannot solve immediately,
  // you probably just stop walking. Concurrency is also not build in.
]

#slide[
  #comment(```md 
  Homework: Read that second link: It's really helpful.
  ```)

  = Cognitive Load

  You can hold roughly *four*#footnote[Exact number does not matter: https://pubmed.ncbi.nlm.nih.gov/11515286/]
  different "chunks" you can keep in your mind. #footnote[Very good intro: https://minds.md/zakirullin/cognitive]

  #toolbox.side-by-side[
    #only("2-")[

```go
// 🧠+
if val > someConstant
    // 🧠+++, prev cond should be true,
    // one of c2 or c3 has be true
    && (condition2 || condition3) 
    // 🤯, we are messed up by this point
    && (condition4 && !condition5) {
    ...
}
```
    ]
][
    #only(3)[
```go
isValid = val > someConstant
isAllowed = condition2 || condition3
isSecure = condition4 && !condition5
// 🧠, we don't need to remember the conditions, there are descriptive variables
if isValid && isAllowed && isSecure {
    ...
}
```
  ]
 ]
]

#slide[
  #comment(```md 
  So System1 can do very basic math, and System2 can do math that is a bit more complex.

  But most decisions we have to do daily are not basic math, they often involve a fair bit
  of statistics. 

  Here we have a description of a person. Please read it.
  Once done, you get two options and you need to decide for the one that seems more likely to you.
  Don't be influenced by others, try to think for yourself.
  
  Some of you probably picked 2, which is logically more unlikely than option 1.
  Why? Because you build a mental model of the person Linda (how is likely a feminist)
  and matched to the answers. This pattern matching is what makes us intelligent and adaptable.
  Being able to reason the solution is what makes us rational and smart.

  Our brain was not made for fast reasoning.
  It's a bit like running DOOM on a toothbrush. Kinda works, but error prone.
  In this case we just replaced the question with "Which Linda description fits more to our image?".
  System1 did this and didn't even tell you that the question was replaced.

  That's by the way the same reason why AI's appear intelligent. They do pattern matching,
  but they do have a System2 doing the rational part yet.

  System2 needs time to work and time to kick in. You need to learn triggers to question
  your own behavior as we can't really change the way our brain works. In time pressure
  System1 will take over and you should not be mad if you do the same mistakes over and over.
  ```)

  = Intelligence vs Rationality 
  
  #emph[“Linda is 31 years old, single, outspoken and very bright. She majored in
  philosophy. As a student, she was deeply concerned with issues of
  discrimination and social justice, and also participated in antinuclear
  demonstrations.”]
  
  #uncover(2)[
  *You have 5 seconds. Which is more likely?*

  *Raise left hand for 1, right for 2.*
  ]
  
  #uncover(3)[
  1. Linda is a bank teller.
  2. Linda is a bank teller and is active in the feminist movement.
  ]

]

#slide[
  #comment(```md 
  Definition.

  Statistical thinking is very hard for us.
  10 crimes just sounds like much to us. We know how to calculate
  with 10%, but we do not really visualize it.
  
  This works well with negative framing ("You have to pay a fee if you are
  late") and positive framing ("You will get a discount if you are early") -
  negative is more effective here though.
  ```)
  = Framing

  #emph("The way of presentation of information influences how it is perceived.")

  Imagine a patient with psychological issues called "Jon":
  #item-by-item[
  - Patients like Jon commit crimes with a probability of 10%.
  - Out of 100 patients like Jon 10 will commit crimes.
  ]

  #uncover(3)[
  *Option 2 was considered way more dangerous by psychological practitioners.*
  ]
]

#new-section-slide("Agenda")

#slide[
  #comment(```md 
  Slowly but surely we will now explore connections of a wide variety of cognitive biases
  to our daily life of engineers. Many of them are not even software related, the examples
  I picked are of course from my memory as software engineer though.

  We have N biases and we might not manage to go over all of them. We will timebox around 90m.
  
  Spoiler: Most of those brain bugs are not fixable. Sometimes we can work around them, but only
  with enough time and distance.
  ```)

  #toolbox.side-by-side[
    #set text(size: 15pt)
    #toolbox.all-sections( (sections, current) => {
      enum(..sections)
    })
  ][
    #emph[3 slides per cognitive bias:]
    
    - Experiment (Quiz, Story time, ...)
    - Explanation (Why?)
    - Effect & Workaround
    - Discussion welcome after each bias.
  ]
]


////////////////////////////////

#new-section-slide("Priming")

#slide[
  #comment(```md 
Priming is not a cognitive bias per se, but more a
base that powers many cognitive biases.

Therefore we are going to discuss it at the start.
  ```)

  = Experiment
#toolbox.side-by-side[
    #image("images/priming-being-watched.png", height:85%)
  ][
    #item-by-item[
      - A trust fund ("Bierkasse") for coffee milk in office.
      - Amount of £ was based on trust.
      - Images on the left was put above the £ box & changed weekly.
      - Face images yielded a much higher cash flow.
    ]
  ]
]

#slide[
  #comment(```md 
  Our brain is not a logical processor, but a contextual processor.
  ```)
  = Explanation

  #toolbox.side-by-side[
  #item-by-item[
    - Feeling watched changes our behavior to more cautious.
    - Thinking of happy moments improves our mood and makes us more gullible.
    - Thinking of bad memories makes us more analytical (and sad).
    - Thinking of money makes us more greedy.
  ]
  ][
    #image("images/priming.jpg", width: 85%)
  ]
]

#slide[
  #comment(```md 
  But we can use priming for ourselves!
  ```)
  = Effect & Workaround
  
  #toolbox.side-by-side[
  None. If it happens it happens. But:
  
    #item-by-item[
  - *Pre-Mortem:* Prime yourself to think about possible mistakes.
  - *Asking advice:* Do not mix explanation with opinions.
  - *Take time:* Priming wears off over time. Sleep over it.
  ]
  ][
    #image("images/premortem.png", width: 80%)
  ]
]

////////////////////////////////

#new-section-slide("\"Autocomplete Bias\"")

#slide[
  #comment(```md 
Those are three biases trench-coating as one.

There are several things wrong with it:

1. MODE_ECB should not be used, as it's absolutely insecure.
2. Other modes require a dynamic IV.
3. You might feel you know what you're doing now.

What came in effect here:

1. Suggestibility: You have accepted the suggestion and did not check it.
2. Unknown unknowns are left out ()
3. Illusion of explanatory depth: You feel like you've done the job and feel knowledgable,
   because "you know how to encypt stuff".
  ```)

  = Experiment

#align(center)[
  ```python
from Crypto.Cipher import AES

# A piece of AI generated code:
# Anything wrong here?
def encrypt(msg, key):
    """
    Encrypt the data in `msg` with `key`,
    return the encrypted bytes.
    """
    cipher = AES.new(key, AES.MODE_ECB)
    return cipher.encrypt(msg) 
  ```
  ]
]

#slide[
  #comment(```md 
- Suggestibility: Autocomplete can work around System2.
  Maybe you know the effect: Someone says "I don't remember that word for that" and than proceeds 
  to say a wrong word: You gonna have issues remembering the word yourself now, even you could have done before.


- Illusion of explanatory Depth: You might feel like you understood.
- Availability heuristic: You only see the problems you know of.
  ```)
  = Explanation

  #align(center)[
      #uncover("1-")[*Suggestibility*]

      #uncover("2-")[+]

      #uncover("2-")[*Illusion of explanatory depth*]

      #uncover("3-")[+]

      #uncover("3-")[*Availability heuristic*]

      #uncover("4-")[=]

      #uncover("4-")[
        #set text(size: 30pt)
        🪲 🪲 🪲
      ]
  ]



]

#slide[
  #comment(```md 
You should be able to code without auto generation or use of AI.
If this is not the case, see it as a warning sign.

If you explain it to someone else or yourself does not matter.
It triggers questioning what you know.

  ```)
  = Effect & Workaround

  #item-by-item[
  - Do not auto-complete/generate big chunks of code.
  - If you learned something, try to explain it (to yourself).
  - Codegen does not replace RTFM.
  - Review is crucial to find unknown unknowns.
  ]

]

////////////////////////////////

#new-section-slide("Cargo Cult")

#slide[
  #comment(```md 
  This is a fun story and it sounds like a urban legend,
  but it is actually true. There are several wiki articles detailing this,
  I recommend this read.
  ```)
  = Story

  #toolbox.side-by-side[
    #image("images/cargo-cult-1.jpg", width: 80%)
    #image("images/cargo-cult-3.png", width: 50%)
  ][
    #image("images/cargo-cult-2.png", height: 85%)
  ]
]

#slide[
  #comment(```md 
  Basically an extreme form of dogmatism.
  This effect is also known under the name of bandwagon effect:
  https://en.wikipedia.org/wiki/Bandwagon_effect

  If Google uses k8s and is succesful we have to use it too.
  ```)
  = Explanation

  #toolbox.side-by-side[
    #item-by-item[
  - Doing rituals in the hope of gaining a benefit, without understanding what leads to the benefit.
  - For Software: Usually emulate successful software houses.
  - Examples: k8s, AI, Blockchain, ...
  - We simply tend to copy behaviors of others, without thinking twice.
  ]
  ][
    #uncover(4)[
    #image("images/lindner.jpg", height: 85%)
    ]
  ]
]

#slide[
  #comment(```md 
  Use your brain, Luke!
  ```)
  = Effect & Workaround

  *Ask:* Do I understand it and do I need it?

  *Do not:*

  - Copy & Paste solutions that worked elsewhere without understanding.
  - Fixing applications by #emph("Shotgun debugging").
  - Deploying tools like k8s - just because Google uses it.
  - Applying patterns (e.g. GoF) without limit.
  - ...
]

////////////////////////////////

#new-section-slide("Shiny Object Syndrome")

#slide[
  #comment(```md 
  Let's come to something that is closely related to Cargo Cult,
  but not quite the same. I'm sure everyone can relate to this one:
  The Shiny object syndrome - or: New feels better.
  ```)
  = Experiment

  #align(center)[
    #image("images/shiny-object-syndrome.png", height: 80%)
  ]
]

#slide[
  #comment(```md 
  Dopamine leads to using more of system1 in decision making.

  Examples:

  - New technology: Blockchain.
  - Distractions: NoSQL instead of Postgres.
  - Trends: Stopping work on a new Exo for trendy things like Cray Visor or SSV.
  ```)
  = Explanation

  #toolbox.side-by-side[
  - New and exciting things release Dopamine. 
  - Applies to...
    - ...choosing new technology.
    - ...distractions in projects.
    - ...trends. // AI, Blockchain, you name it. Cray Visor?
  ][
    #image("images/shiny-object-syndrom-2.jpg", width:100%)
  ]
]

#slide[
  #comment(```md 
  You have to realize: making progress is a far better way to get dopamine.

  There is also the opposite though: Status Quo Bias and Zero Risk Bias tend
  to make people do too conservative decisions. Innovate, but slowly.

  - Status Quo / Endowment: Not changing is preferred and what we already own is viewed as more valuable.
  - Zero Risk Bias: Options that have no perceived risk are viewed more valuable. But risk is often needed.

  Use innocation like a currency. Have a budget.
  ```)
  = Effect & Workaround

  - Use well-tested & renowned software.
  - Strategy first and then stick to it.
  - Get used to be skeptic about new technology: 

    - Does it solve an actual problem? // or is it a solution like Blockchain waiting for a problem to come around?
    - Can the technology improve software quality and reduce complexity?  
    - Can I understand the new technology?
    - Do not ask: #emph("Does it make my life easier?") or #emph("Is it cool?")

  - *Opposite:* Status Quo Bias.
  - *Bonus:*    Zero risk bias // tendency to build solutions that have zero perceived risk
]

////////////////////////////////

#new-section-slide("Anchoring")

#slide[
  #comment(```md 
  ```)
  = Experiment

  - Divide in two groups!
  - Answer the question *silently* below and note on a piece of paper.
  - If it is not your turn, close your eyes.

  #only(2)[
    *How high is the Eiffel tower? Is it higher than 1000m?*
    #align(center)[
      #image("images/eiffel.jpg", height: 30%)
    ]
  ]
  #only(3)[
    #align(center)[
      *Now the other group!*
    ]
  ]

  #only(4)[
    *How high is the Eiffel tower? Is it higher than 100m?*
    #align(center)[
      #image("images/eiffel.jpg", height: 30%)
    ]
  ]
]

#slide[
  #comment(```md 
  This is more of an emotionally guided process.

  It's not really doing some solid guess work or comparisons, let alone math.
  ```)
  = Explanation


  #toolbox.side-by-side[
    - We initially imagine something.
    - The initial image is the anchor.
    - We iterate until we feel happy about our guess.
  ][
    #align(center)[
      #image("images/anchor-2.jpg", height: 80%)
    ]
  ]
]

#slide[
  #comment(```md 
- Effort estimations: Senior says something, all others say a bit above or below. Ask individuals. (Affinity Bias!)
- Fixation on initial ideas: Name the effect! It helps.
- Dark patterns in frontend. Price tags for example.
  ```)
  = Effect & Workaround

  #toolbox.side-by-side[
    *Anchoring happens with...*

    - ...effort estimations.
    - ...fixation on initial ideas.
    - ...consumers due to dark patterns.

    *Mention the effect!*
  ][
    #align(center)[
      #image("images/anchor-3.png", width: 85%)
    ]
  ]
]

////////////////////////////////

#new-section-slide("Broken Window Theory")

#slide[
  #comment(```md 
Originates in crime statistics. Neighborhoods that look detoriated (e.g. by having buildings
with many broken windows) see a rise in getting even more broken.

There was some indication that this is due to broken windows "welcoming" doing more crime.
Basically like saying "It's already broken, not much more harm here".

A self-enhancing effect.

I should note that the broken window theory does not count as proven,
but it already made its way into software development as name.

  ```)
  = Story

  #align(center)[
    #image("images/broken_windows.jpg", height: 62%)
    #footnote[https://blog.codinghorror.com/the-broken-window-theory]
  ]
]

#slide[
  #comment(```md 
  "Just driving the excavator" is a (german?) meme that you don't need to care 
  for anything except driving an excavator. Learning other things? Not necessary.
  Cutting through pipes or cables? Not your problem.
  ```)
  = Explanation

  #item-by-item[
  - Shows people that breaking the rules has no downsides.
  - Enables "Just driving the excavator."-Mentality.
  - Negative, self-enhancing feedback loop.
  - Feeling suffocated by things that need to be fixed.
  ]
]

#slide[
  #comment(```md 
  It's rather simple this time.

  It's all a matter of pragmatism though. Some broken windows are fine for some time.
  Everyone has them.
  ```)
  = Effect & Workaround

  #v(4cm)

  #align(center)[
    #set text(size: 25pt)
    #strong("Repair bad decisions, design and poor code early.")

    #set text(size: 10pt)
    Well, at least try to.

  ]
]

////////////////////////////////

#new-section-slide("Overconfidence")

#slide[
  #comment(```md 
  Is that possible?

  Yes, if average is the regular mean. In case of very skewed data, it might happen that there
  are 20% exceptionally bad drivers and 80% of are good drivers.

  If it is the mean however, this is not possible. But honestly, this was just a little
  trip into how we are bad at statistics. The actual point is that the median is used
  and that means that most drivers are overly confident.

  Overconfidence is not a single effect, but is caused by man effect. For the purpose of this
  presentation I will mostly look into the well known Duning-Kruger effect.
  ```)
  = Story

  #[
    #align(center)[
    #set text(size: 40pt)
    80% of swedish drivers claim they are better than the average driver.

    #set text(size: 20pt)
    How can this be?
    ]
  ]
]

#slide[
  #comment(```md 
  The peak = "Mount stupid"

  Value of a skill: "Computer science is not required, I can use AI to program"

  High self esteem can be good, even if it's not based. It's a bit like a defense mechanism.
  Feeling good and superior to others also releases good chemicals in your body.

  Recognizing the own incompetence is required for growth (-> Valley of despair)
  ```)
  = Explanation

  #toolbox.side-by-side[
    #image("images/dunning-kruger.jpg", width: 100%)
  ][
    #item-by-item[
    - People with the required skill do not have the ability to judge a skill.
    - The value of a skill is often not recognized to be useful.
    - A positive self-image has positive effects on the own mental health. 
    - The unknown unknowns are ignored as usual.
    ]
  ]
]

#slide[
  #comment(```md
  For yourself: There is no fix. Whenever you start with some new tech or project
  you will feel some level of unjustified competence at the beginning.
  The only way is to "git gud" (i.e. become an expert)

  But if you are already an expert (or at least in despair) then the question is how you
  tackle people that are too confident. Let them explain themselves.
  ```)
  = Effect & Workaround

  #toolbox.side-by-side[
    #image("images/git_gud.jpg", height: 85%)
  ][
  - If you feel like you are lacking, it might be a good sign!
  - Be open for feedback and ask where you're lacking.
  - Force overconfident people to explain themselves.
  - Foster a feedback culture as a corrective.
  ]
]

////////////////////////////////

#new-section-slide("IKEA effect")

#slide[
  #comment(```md
  I've bought a house and I suffer from this effect as well:
  I renewed the flooring and some parts of it really look a bit shoddy,
  since it's the first time I've done such a thing.
  ```)
  = Story

  #toolbox.side-by-side[
    #item-by-item[
    - Items/Projects are more valued when self-build.
    - Even if you did a small part only.
    - Even if done very poorly!
    ]
  ][
    #image("images/ikea-house.jpg", height: 85%)
  ]
]

#slide[
  #comment(```md
  ```)
  = Explanation

  #toolbox.side-by-side[
    #item-by-item[
      - Building something makes us feel confident about our skills.
      - Elevates users to "co-creators".
      - The more effort the more positive we see the product.
    ]
  ][
    #image("images/ikea-paradöx.jpg", height: 85%)
  ]
]

#slide[
  #comment(```md
Not-Invented-Here-Syndrom: When persons or companies prefer to write their
own solution, even if there are off the shelve solutions.

People tend to defend tools they've written. (melon, anyone?)

Open Source: What's better to use than a tool you contributed to?
  ```)
  = Effect & Workaround

#emph("Negative:")

- The primary cause for #emph("Not-Invented-Here-Syndrom"). 
- Tools we researched ourselves are more appealing.

#emph("Positive:")

- Open Source: Increases contribution.
- If users can adjust something, they love it more (dashboards, profiles)
]

////////////////////////////////

#new-section-slide("Sunken Cost Fallacy")

#slide[
  #comment(```md
  The vietnam war was pro-longed more and more, even though costs (lives, material, war crimes) mounted and though
  massive demonstrations against it existed. The goverment's argument was though that they could not bail out now
  after spending billions and countless life. The argument against it was used as argument for the war.

  This is the sunken cost fallacy.
  ```)
  = Story

  #toolbox.side-by-side[
    #align(right)[
      #image("images/vietnam-war.jpg", height: 85%)
    ]
  ][
    #align(left)[
      #image("images/vietnam-why.jpg", height: 85%)
    ]
  ]
]

#slide[
  #comment(```md
    This happens in software a lot as well. Projects are started and continued for way too long, even though
    it's clear it's a dead horse. It's very costly as it wastes resources, binds employees to old project
    and stops innovation.
  ```)
  = Explanation

    #image("images/sunken-cost-why.png", height: 85%)
]

#slide[
  #comment(```md
We really should start bringing back the fail of the week procedure.
  ```)
  = Effect & Workaround

  #toolbox.side-by-side[
    #item-by-item[
    - If you ride a dead horse, get off.
    - Evaluate choices like you'd start freshly on a  green field.
    - Have a good error culture.
    - Get used to abandoning old stuff.
    - IKEA effect contributes here.
    ]
  ][
    #v(2cm)
    #image("images/dead_horse.jpg", width: 100%)
  ]
]

////////////////////////////////

#new-section-slide("Curse of knowledge")

#slide[
  #comment(```md 
  The expected outcome here is that you're going to have trouble explaining the detail,
  if the hobby is uncommon enough. You will likely have to expand the scope of your
  of your explanations more and more.

  This happens when you try to see the explanation from the eyes of your seating neighbor.

  In this case you are forced to explain and you will surely succeed, but often enough
  we do not even notice that we should explain something.
  ```)
  = Experiment

  #v(3cm)

  #align(center)[
  *Explain to your seating neighbor a specific detail you assume they have no idea about.*
  For example from a hobby of yours.

  What do you notice?
  ]
]

#slide[
  #comment(```md 

  Comments: For example when reading code that we understood perfectly at that time, but no longer fully do.

  Not called out:  Either because being ashamed ("I should know that already!") or because one does not know the explanation was missing stuff.
  ```)
  = Explanation

  #toolbox.side-by-side[
    #item-by-item[
      - We implicitly assume everyone else has the same knowledge as we do.
      - This can apply also to future selfs No comments in code, anyone?
      - UI design also suffers from #emph("CoS"): We assume the user knows.
      - Often not called out.
    ]
  ][
    #image("images/curse-of-knowledge.jpg", height: 80%)
  ]
]

#slide[
  #comment(```md 
  ```)
  = Effect & Workaround

  - Knowing about it helps. Feel free to interrupt your peer. // Your peer probably does not notice he does at bad job explaining.
  - Try to see the world from your peer's perspective.
  - Ask questions to see if your peer understood.
  - Be patient as explainer.
]

////////////////////////////////

#new-section-slide("Bikeshedding")

#slide[
  #comment(```md 
  
Story: When building a nuclear plant a lot of things have to be designed and
decided. This cannot be done by a single person usually, so there are many
experts for different fields, so you usually have a sort of committee. One for
the cooling, one for the building process and another one for waste disposal.
Some finance guy is probably also in there.

When those experts talk about nuclear fission, then only few people have an opinion
or can give feedback. But if talking about how to design the bike shed then everyone
has an opinion. As a result, the discussion time for building the bikeshed is disproportionally
pro-longed, while other topics might even fells short.

Examples:
- Discussing what file layout should be used.
- Coding conventions of all sorts.
- Whether the microservice principle is exactly followed and whether we should split a service.
- 
  ```)
  = Story & Experiment

  #toolbox.side-by-side[
    #align(right)[
      #image("images/bikeshed.jpg", height: 70%)
    ]
  ][
    #align(left)[
      #image("images/bike-shed-expl.png", height: 70%)
    ]
  ]
  
  #align(center)[
    *Discuss: What trivial detail did you did give disproportional detail?*
  ]
]

#slide[
  #comment(```md 
  ```)
  = Explanation

    #item-by-item[
    - We tend to decide quickly on things we do not know much about. // Hi from Dunning-Kruger!
    - Focusing illusion shifts priorities. // The impact of details is overestimated. Example: Paraplegic people are often happier than people imagine due to their disability. Or thinking "This one promotion will make me so much more happy for a long time".
    - If we know much about a subject we tend to over discuss it.
    - We see opportunity to demonstrate our skills.
    - We forget about the greater goal.
    - Can lead to Analysis Paralysis.
    ]
]

#slide[
  #comment(```md 
  ```)
  = Effect & Workaround

Hard to fix, since it often masquerades as useful discussion.

  #item-by-item[
  - Have frameworks like OKR for common goals.
  - Time-box meetings and give priorities.
  - Leaders should actively discussions gone wild.
  - Explain Bikeshedding to peers.
  ]
]

////////////////////////////////

// Or: The holy trinity of being an asshole.
#new-section-slide("The \"antisocial\" biases")


#slide[
  #comment(```md 
  NOTE: "antisocial" is my own wording. Those biases work together and make social interactions
  a pain. The powering force is Cognitive dissonance.

  Confirmation bias:

  When confronted with evidence, we tend to pick the part of it that confirms our existing beliefs
  and reject those parts that contradicts them. Often very vocally.

  Hindsight Bias:

  Interpreting past events in a way that it was clear
  Past unpredictability is cleared from our memory.


  Fundamental_attribution_error:

  - Deployment was successful because we're so great.
  - Sales fucked up everything because they are such bad persons.
  - The deployment failed, really a weird issue that we could not have see coming.
  - Sales meeting worked well. Eh, they did their job.

  ```)
  = Story & Experiment

    #place(
      dx: 00%,
      dy: 10%,
      image("images/confirmation-bias.jpg", height: 60%),
    )
    
    #place(
      dx: 60%,
      dy: 10%,
      image("images/hindisght-bias.jpg", height: 50%)
    )

    #place(
      dx: 35%,
      dy: 50%,
      image("images/fundamental_attribution_error_comic.png", height: 50%)
    )
]

#slide[
  #comment(```md 

  Mental shortcut: // Easier to process already known information.

  - Desire for control. // It's hard to accept that we did not have the control that lead to this situation.
  - Reducing regret by sugarcoating. // https://en.wikipedia.org/wiki/Choice-supportive_bias
  ```)
  = Explanation

  #toolbox.side-by-side[
    *Confirmation bias*:

    - Desire to be right & self esteem.
    - We like to confirm more than to refute. Being wrong feels bad.
    - Mental shortcut. 

  *Hindsight bias:*

  - Desire for control.
  - Reducing regret by sugarcoating.
  ][
    #image("images/fundamental_attribution_error.png", height: 85%)

  ]
]

#slide[
  #comment(```md 
  - echo chambers: people confirming each other do not grow.
  - Testing: Side effect of confirmation bias: We confirm what is there already.
  - Re-use of old solutions for new problems. // Things like: The user/sales is dumb, it's the RTC, ...
  - When Deployment goes wrong: I had a bad feeling! // well, no. You didn't.
  - Colleague X is such an idiot, I would have it done so much better! // Attribution bias.
  - I don't like Chris, his ideas are no good. // Over-generalizing and tendency to refuse ideas from people we do not like (Horn effect)

  ```)
  = Effect & Workaround

  #item-by-item[
  - Tends to create echo chambers.
  - Testing: Positive tests > Negative tests. 
  - Re-use of old solutions for new problems. 
  - When Deployment goes wrong: I had a bad feeling! 
  - Colleague X is such an idiot, I would have it done so much better!
  - I don't like Chris, his ideas are no good. 
  ]

  #only("5-")[
    #v(2cm)
    *No solution here. Humans are weird.*
  ]
]

////////////////////////////////

#new-section-slide("Optimism bias")

#slide[
  #comment(```md 
I did say some of these already...

Can you find some more?
  ```)
= Common sayings amongst developers

#place(dx: 50%, dy: 45%)[#emph("Loosing all backups is really unlikely")]
#place(dx: 20%, dy: 90%)[#emph("Hackers target only big companies!")]
#place(dx: 00%, dy: 30%)[#emph("I smoke way less than others")]
#place(dx: 60%, dy: 25%)[#emph("That solution will be fast enough!")]
#place(dx: 10%, dy: 55%)[#emph("That deadline will be no issue.")]
#place(dx: 30%, dy: 70%)[#emph("That new framework/tool/whatever will fix it all.")]
#place(dx: 30%, dy: 10%)[#emph("It's not that hard to add 2 database columns...")]
]

#slide[
  #comment(```md 
- Representativeness heuristic - When thinking of a car accident, we do think of a bad driver and not an average driver like ourselves. We compare each other with the bad driver and think "That won't happen to me!"
- People want to feel good. // And optimistic outcomes are more desirable. Also they want to signal "I can do that!"
- Focus on desired end states. // Meaning that we tend to focus on things we wish for, ignoring unwanted output.
- Good mood. // The better the mood, the more likely the effect of optimism bias.
  ```)
= Explanation

#toolbox.side-by-side[
  #item-by-item[
    - Representativeness heuristic.
    - People want to feel good. 
    - Focus on desired end states.
    - Missing painful experiences.
    - Good mood makes us optimistic.
  ]
][
  #image("images/optimism.jpg", height: 80%)
]

]

#slide[
  #comment(```md 
There is no glory in prevention. // security, maintainability but also health and climate crisis - all due optimism.

- Convince others of preemptive measures.
- Use base rates // Consider past performance of similar projects.
- Pre-Mortem it!  // i.e. imagine a negative outcome.
- Let peers challenge your plans.

NOTE: There is also a pessimism bias. It depends on the character which applies more.
  ```)
= Effect & Workaround

  #item-by-item[
  -  *Very hard to fully eliminate.*
  - There is no glory in prevention.
  - Base rates (i.e. look at other projects).
  - Use pre-mortem.
  ]
]

////////////////////////////////


#new-section-slide("Halo effect")

#slide[
  #comment(```md 
  Kahnemann worked as professor and had to grade his students after exams.
  He noticed that he gave better grades to students that 

  Solutions for Kahnemann:

  - Grade each question invidually, so that you can compare answers.
  - Grade each work anonymously.

  More generally: A positive impression stemming from a positive attribute of
  a person (or a thing) "shines over" other attribtues.

  Pretty persons tend to be assumed smart and friendly due to that.

  Developers that made good projects in the past are expected to perform well
  in the future and are assumed to be smart in general.
  ```)
= Story

#toolbox.side-by-side[
  #only("1-")[
    #image("images/grading.jpg", height: 65%)
  ]
][
  #only(2)[
    #image("images/halo-effect.png", height: 65%)
  ]
]
]

#slide[
= Explanation

  #comment(```md 
There is also the opposite effect: The horn effect (so instead of an angel's halo it plays on the devil's horns).

*Bonus:* Affinity Bias: Overvalue opinions of people we trust or that are similar to us. You could call it Mini-Me-Bias. We tend to overtake the opinions of people that have generally similar beliefs to ours, even we would have good reason not to. The effect has some similarities to anchoring.
  ```)

  #align(center)[
    #image("images/halo-effect-impact.jpg", height: 80%)
  ]
]

#slide[
  #comment(```md 

- Each of us have a technology they love. Be aware. // Linux, Flutter, Apple - We tend to defend it and choose tools similar to it.
- Do not use #emph("exciting") software, but boring one. // Would you rather have a good looking but bad surgeon or a jerk that is an excellent surgeon?
  ```)

= Effect & Workaround

  #item-by-item[
  - We tend to overvalue #emph("Rockstar") developers.
  - Each of us have a technology they love. Be aware.
  - Do not use #emph("exciting") software, but boring one.
  - Mind this effect as a manager.
  - Accept all software sucks. 😏
]
]

////////////////////////////////

#new-section-slide("Outro")

#slide[
  #comment(```md 
  Cognitive biases can be frustrating. Humans are not machines and they can react in very 
  unexpected ways. I'm sure everyone can relate a bit to this tweet.
  ```)
  #align(center)[
    #image("images/facts.jpg", width: 70%)
  ]
]

#slide[
  #comment(```md 
  Everyone has biases.

  This talk will not fix them, you are just now aware they exist.
  There are no real fixes, just workarounds.
  ```)
= Summary

  #toolbox.side-by-side[
  - Even if we know about biases, our brain will still experience them.
  - Now we can at least debug our past behavior. // and feel bad about it.
  - Make it a habit watching your mind.
  - Take time for important decisions.
  - Build intuition through experience to use System1.
  - This talk was not complete (e.g. Dark Patterns in UI/UX)
  ][
    // The Bias-blind-spot is a cognitive bias by itself.
    // Maybe this enables us to have some compassion for others, even when we think we are wrong.
    // They (or maybe us) might be a victim of a set of cognitive biases.
    #image("images/bias-blind-spot.jpg", height: 85%)
  ]
]

////////////////////////////////

#slide[
  #v(4cm)
  #align(center)[
    #set text(size: 100pt)
    Doubt yourself!

    #set text(size: 10pt)
    (and me)

  ]
]

#slide[
= Sources

- https://thedecisionlab.com/biases
- https://en.wikipedia.org/wiki/Cognitive_bias
- https://github.com/zakirullin/cognitive-load
- https://thevaluable.dev/cognitive-bias-software-development
- [...]
]

// DONE:
// - Lack of Statistic Intuition https://en.wikipedia.org/wiki/Conjunction_fallacy and base rate fallacy
//   (Intuition is just the experience of years)
// - Dunning Kruger (+Overconfidence effect)
// - Imposter Syndrome
// - Attribute substitution (replace complex question with easier to answer ones)
// - Shiny object Syndrome
// - Sunken Cost Fallacy
// - IKEA effect (over value things you have build yourself)
// - Affinity Bias (overestimating opinions of people similar to us)
// - Curse of knowledge
// - Bikeshedding - Tendency to focus on trivial things (e.g. how to structure file layout in big projects)
//    - Focusing Illusion (overestimating of specific things impacting overall happiness:
//          promotion, better solutions, fresher technology, misjudgement how happy people with paraplegia - happiness is relative)
// - Confirmation Bias / Cognitive Dissonance: Tendency to interpret events in a way to confirm existing opinion
//    - Hindsight Bias (bad events are sugar coated in retrospective, good events are attributed to skill - "Could have known that bug - sooo easy")
// - Optimism bias 
// - Halo Effect (positive feelings towards something influence future decisions about something) 
//    - basically fanboy-ism: If you love Linux, you might feel inclined to defend its weak parts.
//    - We tend to over-value people and their decision we have a positive image of. 
//    - https://en.wikipedia.org/wiki/Reactive_devaluation - proposals of people we don't like are ignored.
//    - https://en.wikipedia.org/wiki/Authority_bias - also tend to over-value authority opinions
// - Peak-End-Rule / Memory Bias (memory is dominated by the most intense & recent peak of it instead of total average)

// SORTED OUT:
// 
// - Actor–observer asymmetry
// - Survivorship Bias
// - Complexity bias (Tendency to push towards too complex solutions) NOTE: Does not sreally seem based.
// - Generation effect (information is easier remembered when a person reasoned it themself, same applies to humor)
// - Additive Bias (tendency to add to a solution instead of removing it, even if better) -> Not strong and thin scientific proof
// - Loss aversions:
//     - Zero risk bias (tendency to build solutions that have zero perceived risk)
//     - Analysis Paralysis
// - https://en.wikipedia.org/wiki/Automation_bias - Favor of decisions made by automated systems over human decisions.
// - Broken Windows Theory - if something is already broken, we tend to be less critical when only quick repairing it. // NOTE: Not really based and software related.
// - https://en.wikipedia.org/wiki/Choice-supportive_bias - Sugarcoating the own decision afterwards. "It was the right one!"
// - Google Effect: https://en.wikipedia.org/wiki/Google_effect - Tendency to forgot things we know we can search again.
