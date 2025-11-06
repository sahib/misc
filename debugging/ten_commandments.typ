#set page(paper: "a5", flipped: true)
#set text(font: "TT2020 Style E", size: 20pt)

#align(center)[
= The 10 Debugging commandments
]

#let commandment = (num, commandmentText) => {
  align(left)[
    #set text(size: 15pt, weight: 900)

    #box(
      width: 1.5cm
    )[
      #num
    ] #commandmentText
  ]
}

#pad(top: 1cm, left: 1cm)[
#commandment("I.", "Understand the system")
#commandment("II.","Make it fail")
#commandment("III.","Quit Thinking and Look")
#commandment("IV.","Divide and Conquer")
#commandment("V.","Change one Thing at a Time")
#commandment("VI.","Keep an Audit Trail")
#commandment("VII.","Check the Plug")
#commandment("VIII.","Get a Fresh View")
#commandment("IX.","Double check it really is fixed")
#commandment("X.","Make it easy to debug")
]
