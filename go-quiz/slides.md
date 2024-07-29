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
theme: gaia
title: Go Quiz
author: Chris Pahl
class:
  - uncover
---

<link rel="icon" type="image/x-icon" href="./favicon.ico">

<!-- _class: lead -->

# Go Quiz

It's an <span id="strikethrough"><span id="strikethrough-inner">&hairsp;silly&hairsp;</span></span><span id="easy" class="handwritten">easy</span> language, right?

<p id="author">🄯 <a href="https://sahib.github.io">Chris Pahl</a> 2024 (<a href="https://github.com/sahib/misc/tree/master/go-quiz">source</a>)</p>

![bg right width:600px](./images/gopher.png)

<!--
Let's explore some dark corners of our favorite language (or language that will become the favorite).
Don't worry, it will be challenging at times and I don't think you can answer all of them without looking things up - at least I couldn't.
The questions will also get harder one by one. Many questions are not entirely go specific and other languages probably act weirdly too here.

We'll do this as a proper quiz, so in the end there will be a winner!
-->

----

<!-- paginate: true --->

# Rules

* There are **25** questions.
* Every correct answer gets **one** point.
* Each question is discussed **after** being answered by everyone.
* Please **raise your hand** when you decided on an answer.
* You have **~1 minute** at most for each question.
* The questions are getting more and more difficult.
* Have fun. You will be wrong often.

<!---
Take a guess how often you will be right.
-->

----

# 1. Testing the rules

<div class="columns">
<div>

```go
// a piece of code
fmt.Println(1 + 1)
```

</div>
<div>

**What will this print?**

1. Fuck, I dropped math in school.
2. π?
3. 2

<!--
The answer is surprisingly two.
Everyone who guessed it right gets one point.
-->

[Playground Link](https://go.dev/play/p/QFEMFhCYc9h)

</div>

----

# 2. Range Loop

<div class="columns">
<div>

```go
func main() {
  for i := range 10 {
    fmt.Println("blub")
  }
}
```

</div>
<div>

**What will this print?**

1. Compilation error.
2. Prints `blub` 10 times.
3. Prints `blub` just once.

<!--
Trick question.

The range syntax is valid since Go 1.22, but I did not use `i` so it fails to compile in any case.
-->

[Playground Link](<https://go.dev/play/p/k4GTgoil2V-?v=goprev>)

</div>

----

# 3. String Iteration

<div class="columns">
<div>

```go
func main() {
  s := "🙀"
  fmt.Println("LEN", len(s))
  for i, c := range s {
    fmt.Println(i, string(c))
  }
}
```

</div>
<div>

**What will this print?**

1. `LEN 1` and one run of the loop.
2. `LEN 3` and each byte of s.
3. `LEN 4` and one run of the loop.

[Playground Link](<https://go.dev/play/p/xSebkXAzRHY?v=goprev>)

<!-- Answer 3. Strings store bytes and len reports the number of bytes.
But when iterating over a string it iterates over runes, i.e. c is of type rune.
Each rune is a unicode codepoint.
-->

</div>

----

# 4. Trimpoline

<div class="columns">
<div>

```go
func main() {
  fmt.Println(
    strings.TrimRight("oxoxo", "xo"),
  )
}
```

</div>
<div>

**What will this print?**

1. `o`
2. `""` (empty string)
3. `oxo`

[Playground Link](<https://go.dev/play/p/9NIfYqRbHf4>)

<!--

Empty string (2). The `xo` set just trims every x or o character it finds.
It often gets confused with TrimSuffix.

-->

</div>

----

# 5. Integer overflows

<div class="columns">
<div>

```go
func main() {
  var x uint32 = (1 << 31)
  fmt.Println(x*2, int32(x)*2)
}
```

</div>
<div>

**What will this print?**

1. `0 -1`
2. `0 0`
3. `1 1`

[Playground Link](<https://go.dev/play/p/Z4L8b5YZstK>)

<!--
Answer 2: When uint32 overflows it starts at 0 again.
For int32 it's harder to visualize, but imagine it as (-2**31 + 2**31)
-->

</div>

-----

# 6. Floating point

<div class="columns">
<div>

```go
func main() {
  var x, y float64 = 1, 0
  fmt.Println(x / y)
}
```

</div>
<div>

**What will this print?**

1. It panics.
2. `NaN`
3. `+Inf`

[Playground Link](<https://go.dev/play/p/qWLUFc-8rnE?v=goprev>)

<!--
Answer 3: Dividing through 0 only panics for integers.
For floats it yields +Inf (For -1/0 it would be -Inf)

Different to python by the way!
-->

</div>

----

# 7. Map Iteration Order

<div class="columns">
<div>

```go
m := map[string]int{
  "a": 3,
  "b": 2,
  "c": 1,
}
s := ""
for k := range m {
  s += k
}
fmt.Println(s)
```

</div>
<div>

**What will this print?**

1. `abc`
2. It's random.
3. `cba`

[Playground Link](<https://go.dev/play/p/iJiE4T4nWD9?v=goprev>)

<!--
It's random. Maps do not guarantee a valid iteration order.
You would need to use a btree if you need that.
-->

</div>

----

# 8. Map Deletion during Iteration

<div class="columns">
<div>

```go
m := map[string]int{
  "a": 3,
  "b": 2,
  "c": 1,
}
count := 0
for k := range m {
  delete(m, k)
  count++
}
fmt.Println(count)
```

</div>
<div>

**What will this print?**

1. Always 3.
2. Always 1.
3. It's random.

[Playground Link](<https://go.dev/play/p/K5gHwse7xgl?v=goprev>)

<!--
Answer 1.

Deletion during iteration is safe in Go. That's because delete() does not free space up immediately
but rather sets a flag that this values can be cleaned up later.
-->

</div>

----

# 9. Map Insertion during Iteration

<div class="columns">
<div>

```go
m := map[string]int{
  "a": 3,
  "b": 2,
  "c": 1,
}
count := 0
for _, v := range m {
  m[fmt.Sprint(v)] = v
  count++
}
fmt.Println(count)
```

</div>
<div>

**What will this print?**

1. It's random.
2. Always 3.
3. Always 6.

[Playground Link](<https://go.dev/play/p/kEHrf5Glk9D>)

<!--
In contrast to deletion, insertion is not safe during iteration.
The number of loops therefore vary between 3 and 6.
</div>
-->

----

# 10. The `any` key

<div class="columns">
<div>

```go
type A int
type B int

func main() {
  m := map[any]string{A(1): "hello!"}
  fmt.Println(m[1])
  fmt.Println(m[A(1)])
  fmt.Println(m[B(1)])
}
```

</div>
<div>

**What will this print?**

1. Three times `hello!`
2. Just the middle one works.
3. First and second works.

[Playground Link](<https://go.dev/play/p/CIMC48o1dfc>)

<!---
Just the middle one works. In an any map, the type is important and part of the value.
-->

</div>

----

# 11. What are interfaces?

<div class="columns">
<div>

```go
func nope() any {
  var x *int = nil
  return x
}

func main() {
  fmt.Println(nope() == nil)
}
```

</div>
<div>

**What will this print?**

1. `true`
2. `false`
3. Depends on Go version.

[Playground Link](<https://go.dev/play/p/t5etHZSamnC>)

<!--
false - a variable of type any (or some other interface type) is like a Pointer
to another variables. Since that pointer is not nil by itself it prints false.
</div>
-->

----

# 12. Oh no, not again math

<div class="columns">
<div>

```go
var x, y int
if 1 + 1 == 2 {
  x := 3
  y = x * x
} else {
  x := 5
  y = x + x
}
fmt.Println(x, y)
```

</div>
<div>

**What will this print?**

1. `5 10`
2. `0 9`
3. `3 9`

<!--
Answer 2. The trick is just variable shadowing. x is re-defined in the if body.
-->

[Playground Link](<https://go.dev/play/p/CQXCFqb49_s>)

</div>

----

# 13. Embedding

<div class="columns">
<div>

```go
type A struct{}
func (a *A) M() { fmt.Println("A") }
type B struct{}
func (b *B) M() { fmt.Println("B") }

type C struct {
  *A
  B
}

func main() {
  var c C
  c.M()
}
```

</div>
<div>

**What will this print?**

1. Compilation error
2. Runtime error (`ambiguous selector c.M`)
3. `A`
4. `B`

[Playground Link](<https://go.dev/play/p/ZnaH5wRMBXQ>)

</div>

<!--
It's number 1. The compiler can't decided which method to call. (`ambiguous selector c.M`)
-->

----

# 14. Slice a `nil`

<div class="columns">
<div>

```go
func main() {
  var s1 []int
  s2 := []int{}
  fmt.Println(s1 == nil, s2 == nil)
}
```

</div>
<div>

**What will this print?**

1. `true false`
2. `false true`
3. `true true`

[Playground Link](<https://go.dev/play/p/Tdv5Kar6egO>)

<!--
Number one again. A nil slice is slightly different than an empty slice.
Always check with len() to see if it's empty.

Sometimes annoying with json, where it prints null nstead of [].
-->

</div>

----

# 15. Slice Confusion

<div class="columns">
<div>

```go
func main() {
  s1 := []int{1, 2, 3}
  s2 := s1[2:3:3]
  s2[0] = 4
  s3 := append(s2, 5)
  fmt.Println(s1, s2, s3)
}
```

</div>
<div>

**What will this print?**

1. Compilation error
2. Panic!
3. `[1 2 4] [4] [4 5]`
3. `[1 2 3] [4] [4 5]`

[Playground Link](<https://go.dev/play/p/9IwSS89I62O>)

<!--
Slices share the same underlying memory. Therefore the change to s2 will also show to the other ones.
The syntax with the two colons is the cap syntax. It can be used to re-cap a slice.
-->

</div>

----

# 16. Yoda

<div class="columns">
<div>

```go
const (
  A = iota * 3
  B
  C = 1 << iota
)

const (
  D = iota * iota
)

func main() {
  fmt.Println(A, B, C, D)
}
```

</div>
<div>

**What will this print?**

1. `0 3 4 0`
2. `0 3 4 9`
3. `3 6 8 16`

[Playground Link](https://go.dev/play/p/lZgDq8qczrm)

<!--
iota works only inside const blocks. It always starts with zero. When a constant does not have an explicit calculation attached to it,
then the previous one is continued (as for B). It starts with zero for each const block anew.
-->

</div>

----

# 17. Loop Variables

<div class="columns">
<div>

```go
func main() {
  s := []*int{}
  for idx := 0; idx < 3; idx++ {
    s = append(s, &idx)
  }
  for _, v := range s {
    fmt.Println(*v+1)
  }
}
```

</div>
<div>

**What will this print?**

1. Depends on the Go version.
2. `1 2 3`
3. `4 4 4`

[Playground Link](<https://go.dev/play/p/FxWEikc7qWs>)

<!--
Before 1.22 the loop variable was captured.
Now, a new loop variable is created, which it works as expected.
-->

</div>

----

# 18. Modulo

<div class="columns">
<div>

```go
func main() {
  // Try that in python ;-)
  fmt.Println(+2 % +3)
  fmt.Println(+2 % -3)
  fmt.Println(-2 % +3)
  fmt.Println(-2 % -3)
}
```

</div>
<div>

**What will this print?**

1. `2 -1  1 -2`
2. `2  2 -2 -2`
3. `2 -2  2 -2`

[Playground Link](<https://go.dev/play/p/Io6A4kMt38F>)

<!--
It's complicated and each language has their own definition.
Please read it up here: https://torstencurdt.com/tech/posts/modulo-of-negative-numbers/

For Go, it's Answer 2.
-->

</div>

----

# 19. `defer` Order

<div class="columns">
<div>

```go
func f(x int) int {
  fmt.Printf("f(%d)\n", x)
  return x 
}
func g(x int) int {
  fmt.Printf("g(%d)\n", x)
  return x 
}
func main() {
  defer g(f(1))
  defer f(2)
  defer g(3)
}
```

</div>
<div>

**What will this print?**

1. `g(3) f(2) f(1) g(1)`
2. `f(1) g(1) f(2) g(3)`
3. `f(1) g(3) f(2) g(1)`

[Playground Link](<https://go.dev/play/p/b8KFSLEwqMR>)

<!--
The f(1) is called immediately. Otherwise defer calls are stacked. They are executed in reverse order then - last in, first out.
-->

</div>

----

# 20. Receiver / Deceiver

<div class="columns">
<div>

```go
type A int
func (a *A) M() { *a = 3 }

type B int
func (b B) M() { b = 5 }

func main() {
  a, b := A(0), B(0)
  a.M()
  b.M()
  fmt.Println(a, b)
}
```

</div>
<div>

**What will this print?**

1. Compilation error
2. `0 5`
3. `3 0`
4. `3 5`

[Playground Link](<https://go.dev/play/p/eWm7jaU_mek>)

<!--
Answer 3 (3 0)

The method B.M() has a value receiver. Therefore the change is not carried out and gets lost after the execution is done.
A.M() has a pointer receiver which is automatically picked. The values survives therefore.
-->

</div>

----

# 21. Bare select

<div class="columns">
<div>

```go
func main() {
  select {}
}
```

</div>
<div>

**What will happen?**

1. Compilation error
2. The program will block forever.
3. The program immediately panics.

[Playground Link](<https://go.dev/play/p/P8xdJOH_USj>)

<!--
Answer 3.
select{} simply blocks forever without busy polling. Since it's a single go routine we panic because and deadlock is detected.
-->

</div>

----

# 22. Closed Channels

<div class="columns">
<div>

```go
func main() {
  ch := make(chan int)
  close(ch)
  for {
    select {
    case <-ch:
      fmt.Println("new item")
    }
  }
}
```

</div>
<div>

**What will happen?**

1. The program will print `new item` very fast infinitely.
2. The program will panic due to a deadlock.
3. The program will block forever.

[Playground Link](<https://go.dev/play/p/FOYaetjwCfv>)

<!--
A closed channel always returns the zero value in a select (and also when doing `v, ok := <-ch`).
Therefore the program loops forever.
-->

</div>

----

# 23. Coco Channel

<div class="columns">
<div>

```go
func f(ch chan<- int) {
  for idx := 0; idx < 10; idx++ {
    ch <- idx
  }
}
func main() {
  ch := make(chan int, 5)
  go f(ch)
  for idx := 0; idx < 5; idx++ {
    fmt.Println(<-ch)
  }
  close(ch)
  time.Sleep(time.Second)
}
```

</div>
<div>

**What will happen?**

1. The program will panic.
2. The behavior is undefined.
3. It will print the numbers 0-5 then exit.

[Playground Link](<https://go.dev/play/p/lGpi31pWsjB>)

<!--
We put 10 items into `ch` (a buffered channel with 5 items) in a separate go routine.
In the main routine we pull 7 items out of it and then close the channel.
Since we might close the channel before the write is finished, we  might panic.
But not always since this is a race condition. Therefore answer 2.
-->

</div>

----

# 24. GO(TO)?

<div class="columns">
<div>

```go
outer:
  for x := 0; x < 2; x++ {
  inner:
    for y := 0; y < 2; y++ {
      if y == 0 { continue inner }
      fmt.Println("PRINT!", x, y)
    }
    if x == 1 { break outer }
  }
  ```

</div>
<div>

**How many lines will this program print?**

1. One.
2. Two.
3. Four.

[Playground Link](https://go.dev/play/p/5tcKR0qqQsj>)

<!--
A label can be assigned to a for, select or switch so that we either continue with that loop or break from it.
This can be useful to break out of nested loops. Continuing in nested loops is seldomly used and a bit weird.

Here we skip the first inner loop run if y == 0, thus only the second is printed (y = 1). For the outer loops
we break out of it when x = 1 - that's the termination condition anyways so nothing changes and we print twice.
-->

</div>

----

# 25. Memory Mischief

<div class="columns">
<div>

```go
func dummyMessage() string {
  return strings.Repeat("hello", 1000)
}

func main() {
  messages := []string{}
  for idx := 0; idx < 10; idx++ {
    message := dummyMessage()
    messages = append(messages, message[:5])
  }

  runtime.GC()
  // >>>> HERE <<<<
  fmt.Println(messages)
}
```

</div>
<div>

**How many bytes are still allocated at `HERE` by `main()`?**

1. 50184 Bytes
2. 234 Bytes
3. 734 Bytes

[Playground Link](<https://go.dev/play/p/pxlLVUvmIlf>)

<!--
If you listened to my performance talk,
you might know :-)

A slice has 24 Bytes overhead + contents.
A string has 16 Bytes overhead + contents.

One string consists of 1000 5-character words (hello).
Each of those strings have ()(1000 * 5) + 16) bytes.
10 of those strings are created, and even though they are sub-sliced
we do store the full array behind that string, so it's 10 times.
Since we store it in slice we have 24 bytes more.

((1000 * 5) + 16) * 10 + 24 = 50184
-->

</div>

----

<!-- _class: lead -->

![bg right width:600px](./images/zombiegopher.png)

That's all I have.
Hope you had fun.

<p class="small handwritten">Now go brag with your score!</p>
