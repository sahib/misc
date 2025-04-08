// Get Polylux from the official package repository
#import "@preview/polylux:0.4.0": *

#enable-handout-mode(false)

#show link: set text(blue)
#set text(font: "Andika", size: 20pt)
#show raw: set text(font: "Fantasque Sans Mono")
#show heading: it => [
  #set align(center)
  #it.body
]

#let stroke-thick-black = stroke(
  thickness: 10pt,
  paint: black,
  cap: "round",
)

#let new-section-slide(title) = slide[
  #set page(footer: none, header: none)
  #set align(horizon)
  #set text(size: 1.5em)
  #strong(title)
  #line(stroke: stroke-thick-black, length: 50%)
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
  #set page(footer: none, header: none)
  #align(center)[
    #link("https://upload.wikimedia.org/wikipedia/commons/6/65/Cognitive_bias_codex_en.svg")[
      #image("images/cognitive_bias_map.png")
    ]
  ]
]

#new-section-slide("Intro")

#slide[
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
      #image("images/kahnemann.png", width: 90%)
    ]
  ]

  // Accept defeat!
]

#slide[
= Cognitive bias

  - Our brain was not made to write software. // (but rather to find food and quickly notice the predators)
  - We tend to think of our brain as reliable logical processor. // ("We" is our brain and it is lying)
  - Our brain has bugs, which are called 'Cognitive bias'. // (and there are thousands of them)
  - We focus on how our brain prohibits writing good software.
  - I'm qualified for this talk because I do software and have a brain.
]

#slide[
  #align(center)[
    = Don't believe me?

    #toolbox.side-by-side[
      // Anything wrong in this picture?
      #image("images/thatcher-faces-upsidedown.png", width: 90%) 
    ][
      #uncover("2-")[
        // Our brain just inserted the info "there is a mouth, here are some eyes".
        #image("images/thatcher-faces-turnedaround.png", width: 90%)
      ]
    ]
  ]
]

#slide[
  #align(center)[Watch your thoughts:]
  #uncover("2-")[
    #align(center)[
      #image("images/banana-vomit.png")
    ]
  ]
  #uncover(3)[
    Your brain invented a little story about bananas making you sick without being asked.

    Also: You are now more likely to avoid bananas for some time subconsciously. Congratulations!
  ]
]

#slide[
    #align(center)[
      == Which is the longest line?
      #image("images/müller-lyer.png", width: 60%)
    ]
]

#slide[
    #align(center)[
      == Which is the longest line? (fixed)
      #image("images/müller-lyer-fixed.png", width: 60%)
      Even if you know, you can't see it.
    ]

]

#slide[
  #align(center)[
    #image("images/the_cat.png", width: 30%)
  ]
]

#slide[
  #align(center)[
    #image("images/system1and2.jpg")
  ]

// TODO: Finish notes.
// - Vorstellung System 1/2 (läuft 2 ist man praktisch blind und sieht keine Gorillas und kann nicht laufen und multiplizieren, System 1 kann man geradeauslaufen und denken oder blinker setzen)
// - Intelligenz vs Rationalität (Intelligenz -> System 1 sehr fit, Rationalität -> übernimmt System 2 ausreichend schnell?)
]

#slide[
  = Intelligence vs Rationality 
  
  #emph[“Linda is 31 years old, single, outspoken and very bright. She majored in
  philosophy. As a student, she was deeply concerned with issues of
  discrimination and social justice, and also participated in antinuclear
  demonstrations.”]
  
  #uncover(2)[
  *You have 5 seconds. Which is more likely?*
  
  1. Linda is a bank teller.
  2. Linda is a bank teller and is active in the feminist movement.
  
  *Raise left hand for 1, right for 2.*
  ]

// Some of you probably picked 2, which is logically more unlikely than option 1.
// Why? Because you build a mental model of the person Linda (how is likely a feminist)
// and matched to the answers. This pattern matching is what makes us intelligent and adaptable.
// Being able to reason the solution is what makes us rational and smart.
//
// Our brain was not made for fast reasoning.
// It's a bit like running DOOM on a toothbrush. Kinda works, but error prone.
// In this case we just replaced the question with "Which Linda description fits more to our image?".
// System1 did this and didn't even tell you that the question was replaced.
//
// That's by the way the same reason why AI's appear intelligent. They do pattern matching,
// but they do have a System2 doing the rational part yet.
//
// System2 needs time to work and time to kick in. You need to learn triggers to question
// your own behavior as we can't really change the way our brain works. In time pressure
// System1 will take over and you should not be mad if you do the same mistakes over and over.
]

#slide[
  = Framing

  #emph("The way of presentation of information influences how it is perceived.")

  #item-by-item[
  Imagine a patient with psychological issues called "Jon":

  - Patients like Jon commit crimes with a probability of 10%.
  - Out of 100 patients like Jon 10 will commit crimes.
  ]

  #uncover(3)[
  *Option 2 was considered way more dangerous by psychological practitioners.*
  ]


  // Statistical thinking is very hard for us.
  // 10 crimes just sounds like much to us. We know how to calculate
  // with 10%, but we do not really visualize it.
  //
  // This works well with negative framing ("You have to pay a fee if you are late") and positive framing ("You will get a discount if you are early") - negative is more effective here.
]

#slide[
  #item-by-item[
    - $2+2$       // you did not have to think right? Plain pattern matching.
    - $21 dot 13$ // now you probably have to use system 2.
    - $77+33$     // chances are you were wrong.
  ]
  // By the way: When you walk and see an equation you cannot solve immediately,
  // you probably just stop walking. Concurrency is also not build in.
]

#new-section-slide("Agenda")

#slide[
  #toolbox.side-by-side[
    #toolbox.all-sections( (sections, current) => {
      enum(..sections)
    })
  ][
    3 slides per cognitive bias:
    
    - Experiment (Quiz, Story time, ...)
    - Explanation (Why?)
    - Effect (How to fix?)
  ]
]


////////////////////////////////

#new-section-slide("Priming")

#slide[
  = Experiment
#toolbox.side-by-side[
    #image("images/priming-being-watched.png", height:85%)
  ][
    #item-by-item[
      - A trust fund for coffee milk in office.
      - Amount of £ was based on trust.
      - Images on the left was put above the £ box & changed weekly.

      // Nicely applicable to the Bierkasse as well.
    ]
  ]
]

#slide[
  = Explanation

  #item-by-item[
    - Feeling watched changes our behavior.
    - Thinking of happy moments improves our mood. // Good mood: more creative but more gullible; Bad mood: more analytical but more likely to give in
    - Thinking of money makes us more greedy.
    // - Not a cognitive bias by itself.
  ]
]

#slide[
  = Effect

  TODO: 
  - errors?
  - pre-mortem? Prime yourself about errors before they happen.
]

////////////////////////////////

#new-section-slide("Cargo Cult")

#slide[
  = Cargo Cult: Story

  #toolbox.side-by-side[
    #image("images/cargo-cult-1.jpg", width: 80%)
    #image("images/cargo-cult-3.png", width: 50%)
  ][
    #image("images/cargo-cult-2.png", height: 85%)
  ]
]

#slide[
  = Cargo Cult: Explanation

  Doing rituals in the hope of gaining a benefit without understanding what leads to the benefit.

  For Software: Usually emulate successful software houses.

  // Basically an extreme form of dogmatism and also not a cognitive bias per se.
  // Similar effect: https://en.wikipedia.org/wiki/Bandwagon_effect
]

#slide[
  = Cargo Cult: Effect

  - Copy & Paste solutions that worked elsewhere without understanding.
    (Use your brain, Luke!)
  - Fixing applications by "Shotgun debugging".
  - Applying tools like k8s - because Google uses it.
  - Applying patterns (e.g. GoF) without limit.
]

////////////////////////////////

#new-section-slide("Shiny Object Syndrome")

#slide[
  = Experiment

  #align(center)[
    #image("images/shiny-object-syndrome.png", height: 80%)
  ]
]

#slide[
  = Explanation

  #toolbox.side-by-side[
  - New and exciting things release Dopamine. // It makes you use System1 for decisions!
  - Applies to...
    - ...choosing new technology.
    - ...distractions in projects.
    - ...trends. // AI, Blockchain, you name it. Cray Visor?
  ][
    #image("images/shiny-object-syndrom-2.jpg", width:100%)
  ]
]

#slide[
  = Effect

  - Use well-tested & renowned software. // like Postgresql
  - Strategy first and stick to it. // making progress is a far better way to get dopamine.
  - Get used to be skeptic about new technology: // product managers hate this trick.

    - Does it solve an actual problem? // or is it a solution like Blockchain waiting for a problem to come around?
    - Can the technology improve software quality and reduce complexity?  
    - Can I understand the new technology?
    - Do not ask: "Does it make my life easier?" or "Is it cool?"

  - *Opposite:* Status Quo Bias.
  - *Bonus:*    Zero risk bias // tendency to build solutions that have zero perceived risk


// Status Quo Bias / Endowment Effect
//
// - Dinge werden als wertvoller eingeschätzt wenn man sie besitzt.
// - Beispiel: Existierende Infrastruktur wird zu Unrecht als gut dargestellt, auch wenn
// - Quelle: https://en.wikipedia.org/wiki/Status_quo_bias
  

  // I will not mention the word "AI" here. But it applies as well.
]

////////////////////////////////

#new-section-slide("Anchoring")

#slide[
  = Anchoring: Experiment

  - Divide in two groups!
  - Answer the question below, but 

  #only(2)[
    *How high is the Eiffel tower? Is it higher than 1000m?*
  ]
  #only(3)[
    *How high is the Eiffel tower? Is it higher than 100m?*
  ]

  // NOTE: Works only with people in the room.
]

#slide[
  = Anchoring: Explanation


  #toolbox.side-by-side[
    - We initially imagine something.
    - The initial image is the anchor.
    - We iterate until we feel happy about our guess.
  ][
    #align(center)[
      #image("images/anchor-2.jpg", height: 90%)
    ]
  ]
]

#slide[
  = Anchoring: Effect

  #toolbox.side-by-side[
    *Dangers:*

    - Effort estimations. // Senior says something, all others say a bit above or below. Ask individuals. (Affinity Bias!)
    - Fixation on initial ideas. // Name the effect! It helps.
    - Dark patterns in frontend. // Price tags for example.

    *Bonus:* Affinity Bias. // Overvalue opinions of people we trust or that are similar to us. You could call it Mini-Me-Bias. We tend to overtake the opinions of people that have generally similar beliefs to ours, even we would have good reason not to. The effect has some similarities to anchoring.

  ][
    #align(center)[
      #image("images/anchor-3.png", width: 90%)
    ]
  ]
]

////////////////////////////////

#new-section-slide("Overconfidence")

#slide[
  = Story

  // TODO: Needs some intro.

  - Dunning Kruger
  - Cogntitive Dissonance.
  - Illusory superiority
  - Worse-than-average-effect (for very hard tasks)
]

#slide[
  = Explanation

  - People with the required skill do not have the ability to judge themselves.
  - The value of a skill is often not recognized.
  - A positive self-image has positive effects on mental health. // high self esteem can be good, even if it's not based. It's a bit like a defense mechanism.
  - #link("https://en.wikipedia.org/wiki/Cognitive_dissonance")[Cognitive Dissonance]
  - Recognizing the own incompetence is required for growth.
]

#slide[
  = Effect

  - If you feel like you are lacking, it might be a good sign!
  - Force overconfident people to explain.
  - Don't write code that overloads your brain. // because it will overload other brains as well.
]

////////////////////////////////

#new-section-slide("IKEA effect")

#slide[
  = Story

  // I've bought a house and I suffer from this effect as well:
  // I renewed the flooring and some parts of it really look a bit shoddy,
  // since it's the first time I've done such a thing.

  #toolbox.side-by-side[
  - Goods are more valued if they are build by themselves.
  - Even if done partially only.
  - Even if done poorly!
  ][
    #image("images/ikea-house.jpg", height: 85%)
  ]
]

#slide[
  = Explanation

  #toolbox.side-by-side[
  - Building something makes us feel confident about our skills.
  - Elevates users to "co-creators".
  - The more effort the more positive we see the product.
  ][
    #image("images/ikea-paradöx.jpg", height: 85%)
  ]
]

#slide[
  = Effect

  #toolbox.side-by-side[
  - The primary cause for #emph("Not-Invented-Here-Syndrom"). // People tend to defend tools they've written. (melon, anyone?)
  - Open Source: Increases contribution. // What's better to use than a tool you contributed to?
  - Tools we researched more are more appealing.
  - If users can adjust something, they love it more (dashboards, profiles)
  ][
    #image("images/ikea-effect.jpg", height: 85%)
  ]
]

////////////////////////////////

#new-section-slide("Sunken Cost Fallacy")

#slide[
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

  // The vietnam war was pro-longed more and more, even though costs (lives, material, war crimes) mounted and though
  // massive demonstrations against it existed. The goverment's argument was though that they could not bail out now
  // after spending billions and countless life. The argument against it was used as argument for the war.
  //
  // This is the sunken cost fallacy.
]

#slide[
  = Explanation

    #image("images/sunken-cost-why.png", height: 85%)

    // This happens in software a lot as well. Projects are started and continued for way too long, even though
    // it's clear it's a dead horse. It's very costly as it wastes resources, binds employees to old project
    // and stops innovation.
]

#slide[
  = Effect

  #toolbox.side-by-side[
    - Evaluate choices like you'd start freshly.
    - Have a good error culture.
    - Get used to abandoning old stuff.
    - IKEA effect contributes here.
  ][
    #v(2cm)
    #image("images/dead_horse.jpg", width: 100%)

  ]
]

////////////////////////////////

#new-section-slide("Curse of knowledge")

#slide[
  = Experiment

  *Explain to your seating neighbor a specific detail you assume they have no idea about.*
  What do you notice?
]

#slide[
  = Explanation

  #toolbox.side-by-side[
    - We implicitly assume everyone else has the same knowledge as we do.
    - This can apply also to future selfs No comments in code, anyone? // For example when reading code that we understood perfectly at that time.
    - UI design also suffers from CoS: We assume the user knows.
    - Often not called out. // Either because being ashamed ("I should know that already!") or because one does not know the explanation was missing stuff.
  ][
    #image("images/curse-of-knowledge.jpg", height: 80%)
  ]
]

#slide[
  = Effect

  - Knowing about it helps. Feel free to interrupt your peer. // Your peer probably does not notice he does at bad job explaining.
  - Try to see the world from your peer's perspective.
  - Ask questions to see if your peer understood.
  - Be patient and do not be an a-hole.
]

////////////////////////////////

#new-section-slide("Bikeshedding")

#slide[
  = Story & Experiment

  #toolbox.side-by-side[
    #align(right)[
      #image("images/bikeshed.jpg", height: 70%)
    ]
  ][
    #align(left)[
      #image("images/bike-shed-expl.png", height: 70%)
    ]
  
  #align(center)[
    *Discuss what trivial detail did you did give disproportional detail?*
  ]
  

  // Examples:
  // - Discussing what file layout should be used.
  // - Whether the microservice principle is exactly followed and whether we should split a service.
  // - 

]

#slide[
  = Explanation

    - We tend to decide quickly on things we do not know much about. // Hi from Dunning-Kruger!
    - If we know much about a subject we tend to over discuss it.
    - We see opportunity to demonstrate our skills.
    - We forget about the greater goal.
]

#slide[
  = Effect

Hard to fix, since it often masquerades as useful discussion.

- Have frameworks like OKR.
- Time-box meetings and give priorities.
- Leaders should actively discussions gone wild.
- Explain Bikeshedding.
]

////////////////////////////////

#new-section-slide("Confirmation & Hindsight Bias")

#slide[
  = Story & Experiment
]

#slide[
  = Explanation
]

#slide[
  = Effect
]

////////////////////////////////

#new-section-slide("Outro")

#slide[
= Summary

  #toolbox.side-by-side[
  - Even if we know about bias, our brain will still experience them.
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

#slide[
= Outlook & Homework

I left out something important: Cognitive load.

https://minds.md/zakirullin/cognitive

]

#slide[
= Outro poem

- Riddled with problems is our mind
- Easy solutions not in sight
- Now no longer as blind,
- but our behavior is still not bright.
]


#slide[
= Sources

- https://en.wikipedia.org/wiki/Cognitive_bias
- https://github.com/zakirullin/cognitive-load
- https://thevaluable.dev/cognitive-bias-software-development
]

#slide[
  #align(center)[
    = The End

    *Tip:* The title slide is clickable!
  ]
]

// NOTES:

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


// OPEN:
// - Optimism bias 
//    -> "Loosing all backups is reeeeeeaaaly unlikely"
//    -> "Hackers target only big companies!"
//    -> "It's not that hard to add 2 db columns!"
//
// - Halo Effect (positive feelings towards something influence future decisions about something) 
//    - basically fanboy-ism: If you love Linux, you might feel inclined to defend its weak parts.
//    - We tend to over-value people and their decision we have a positive image of. 
//    - https://en.wikipedia.org/wiki/Reactive_devaluation - proposals of people we don't like are ignored.
//    - https://en.wikipedia.org/wiki/Authority_bias - also tend to over-value authority opinions
// - Confirmation Bias / Cognitive Dissonance: Tendency to interpret events in a way to confirm existing opinion
//    - Hindsight Bias (bad events are sugar coated in retrospective, good events are attributed to skill - "Could have known that bug - sooo easy")
// - Peak-End-Rule / Memory Bias (memory is dominated by the most intense & recent peak of it instead of total average)
// - Additive Bias (tendency to add to a solution instead of removing it, even if better)
// - Focusing Illusion (overestimating of specific things impacting overall happiness:
//    promotion, better solutions, fresher technology, misjudgement how happy people with paraplegia - happiness is relative)
// - Loss aversions:
//     - Zero risk bias (tendency to build solutions that have zero perceived risk)
//     - Analysis Paralysis
// - https://en.wikipedia.org/wiki/Fundamental_attribution_error / Correspondence Bias 
//    -> Deployment was successful because we're so great.
//    -> Sales fucked up everything because they are such bad persons.
//    -> The deployment failed, really a weird issue that we could not have see coming.
//    -> Sales meeting worked well. Eh, they did their job.
//

// SORTED OUT:
// 
// - Actor–observer asymmetry
// - Survivorship Bias
// - Complexity bias (Tendency to push towards too complex solutions) TODO: Is that a based one?
// - Generation effect (information is easier remembered when a person reasoned it themself, same applies to humor)


// MAYBE:
// - https://en.wikipedia.org/wiki/Automation_bias - Favor of decisions made by automated systems over human decisions.
// - Broken Windows Theory - if something is already broken, we tend to be less critical when only quick repairing it.
// - https://en.wikipedia.org/wiki/Choice-supportive_bias - Sugarcoating the own decision afterwards. "It was the right one!"
// - Google Effect: https://en.wikipedia.org/wiki/Google_effect - Tendency to forgot things we know we can search again.
