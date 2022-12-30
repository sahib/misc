module Config exposing (Kind(..), ResultKind(..), Wizard, Question, Page, configuredWizard)

-- Kind configures how the question widget looks like.
type Kind = Range Int | Text Int

-- ResultKind encapsulates the actual result.
type ResultKind = RangeResult Int | TextResult String

defaultRange : Kind
defaultRange = Range 10

type alias Question =
  { text : String
  , description : String
  , kind : Kind
  , required : Bool
  }

type alias Page =
    { questions : List Question
    , description : String
    , title : String
    }

type alias Wizard =
    { intro : String
    , outro : String
    , pages : List Page
    }


introText : String
introText =
    """
Welcome to the Team ELIOT 360 Degree Feedback Form.
Prior to our talks we ask our managers, team members, peers and directs to give feedback on our 4 major categories people, product, process, tech.
We want to grow as a team as well as individuals and feedback is the primary source to step back and evaluate ourselves, our performance and our contribution on regular bases.
Always give feedback in a way you want to receive your feedback. Be constructive, friendly and always assume good intentions. You can give your feedback anonymously or you can also decide to fill in your name if you want to.
Take your time and don't rush.

As a reminder here are our company values:

- We are pioneers
- We work together
- We are committed to our mission

And here are our agreements as team ELIOT:

- Never miss the sync! → quick and short and open communication ways via modern technology and scheduled team sync ups that guarantees team alignment and an open forum for discussion and participation. Participation and alignment are essential to work productive and successful.
- No work without a ticket! → provide a minimum of transparency towards your team members. They need to pick up where you might need help and support.
- Don't break master! Or in other words: Do not make the life of your team mates harder on purpose by taking shortcuts in testing or documentation. Testing is part of engineering.
- Don’t solder and drive! Plan ahead and avoid stressful situation where you have to finish projects last second before an important deadline.
- Bei Hardwarefragen, frag doch mal den Hardware-Chris! → Over the years there is a lot of internal jokes and nickname calling etc. Just jump in, create your own and participate. Don't forget to have a lot of fun on your journey. This is an incredible product and an incredible team. Enjoy it.
    """


outroText : String
outroText =
    """
Thank you for filling out the form. If you hit »Submit« now, your feedback will be saved for later.
You won't be able to go back and edit it later, so please think twice before clicking.
    """


configuredWizard : Wizard
configuredWizard =
    { intro = introText
    , outro = outroText
    , pages = [
        { title = "People"
        , description = ""
        , questions = [
            { text =  "Working with others"
            , description = "How well does the person work with other team members or colleagues from other departments, customers or managers?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Integrity & Trust"
            , description = "How well is the person trusted by you or others?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Sizing up people"
            , description = "How well does the person help others, support them and gives constructive feedback?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Dealing with Interdisciplinarity"
            , description = "How well does the person strive to support the interdisciplinary team culture (understanding of different work streams, technical backgrounds etc.)?"
            , kind = defaultRange
            , required = True
            }
        ]},
        { title = "Process"
        , description = ""
        , questions = [
            { text =  "Self Organization"
            , description = "How well does the person organize their own work & how structured does the person work (time management, preparations for meetings)?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Communication"
            , description = "How well does the person communicate problems, progress, plans?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Transparency"
            , description = "How well does the person live up to the transparency required in agile development frameworks (Jira, Confluence etc.)?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Contribution"
            , description = "How well does the person contribute to the team process and how eager is the person to improve the team continuously (team processes like ceremonies, team organization z.B. Jira Board, interfacing with other departments)?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Team representation"
            , description = "How well does the person represent our team our company (see intro)?"
            , kind = defaultRange
            , required = True
            }
        ]},
        { title = "Product"
        , description = ""
        , questions = [
            { text =  "Delivery"
            , description = "How well does the person deliver the OKRs and required functionality to the customer?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Ownership"
            , description = "How well does the person take ownership and responsibility for their work stream?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Customer Centric"
            , description = "How well does the person take the customer needs into account when developing requirements or functionalities (customer needs vs. technical perfection)?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Innovation"
            , description = "How well does the person strive for innovation and new ideas?"
            , kind = defaultRange
            , required = True
            }
        ]},
        { title = "Tech"
        , description = ""
        , questions = [
            { text =  "Engineering / Product Management Practice"
            , description = "How well does the person use and follow common practices of their work stream?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Pragmatism vs. Perfection"
            , description = "How well does the person deal with the contradictions of pragmatism and perfection?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Testing"
            , description = "How well does the person test their own products and how well does the person support others with their testing?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Debugging & Bug Fixing"
            , description = "How well does the person debug and fix problems in production or during development?"
            , kind = defaultRange
            , required = True
            }
        ]},
        { title = "Management"
        , description = ""
        , questions = [
            { text =  "Delegation"
            , description = "How well does the person delegate tasks to others? How well does the person explain expectations and does the person provide feedback?"
            , kind = defaultRange
            , required = True
            },
            { text =  "Hiring"
            , description = "How well does the person perform in hiring and interview processes? How well was your onboarding with this person? How well did the person onboard their hires?"
            , kind = defaultRange
            , required = True
            }
        ]},
        { title = "Feedback"
        , description = "Now is the time to give some qualitative feedback. Write some words to help explaining your scoring and give the person hints and ideas how to improve. You do not have to write novels but consider to say some words since those stick more than the scoring."
        , questions = [
            { text =  "Continue doing"
            , description = "What should the person continue doing? What does the person do very well? How is the person primarily contributing etc."
            , kind = Text 4
            , required = False
            },
            { text =  "Improving"
            , description = "What should the person improve in the upcoming month? Where do you see potential starting points for the person to grow?"
            , kind = Text 4
            , required = False
            },
            { text =  "Stop doing"
            , description = "What should the person stop doing? Did you notice some behaviour that blocks you or the team? What do you wish from the person?"
            , kind = Text 4
            , required = False
            },
            { text =  "Lastly, what I want to mention..."
            , description = "Note anything down that did not fit into any other field"
            , kind = Text 2
            , required = False
            },
            { text =  "Your name"
            , description = "You can provide your name if you want to. Leaving it empty makes your feedback anonymous."
            , kind = Text 1
            , required = False
            }
        ]}
    ]}
