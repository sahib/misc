---
marp: true
style: |
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
theme: gaia
paginate: true
title: Go Quiz
author: Chris Pahl
class:
  - uncover
---

<!-- _class: lead -->

# Go Quiz

It's an easy language, right?

![bg right width:600px](./gopher.)

----

# Rules

* There are 20 questions. TODO: correct number
* Every correct answer gets **one** point.
* Each question is discussed **AFTER** being answered by everyone.
* You have ~1 minute at most for each question.
* Have fun. You will be wrong often.

----

# Testing the rules

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

</div>

----

# Range Loop

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
3. Something else.

</div>

----

# String Iteration

<div class="columns">
<div>

<https://go.dev/play/p/aj1a3vPJRWv>

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

1. `LEN 1` and just one run of the loop.
2. `LEN 4` and each byte of s.
3. `LEN 4` and just one run of the loop.

</div>

----

# Stdlib pitfalls

<div class="columns">
<div>

```go
fmt.Println(strings.TrimRight("123oxo", "xo"))
```

</div>
<div>

TODO: Find some other examples here and collect them on one slide.

</div>

----

## Integer overflows

<div class="columns">
<div>

```go
func main() {
  n := 1 << 31
}
```

</div>
<div>

TODO: Stuff missing.

</div>

-----

# Floating point

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

</div>

----

# Map Iteration Order

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

</div>

----

# Map deletion during iteration

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

</div>

----

# Map insertion during iteration

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

</div>

----

# `map[any]any`

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

</div>

----

# `any`

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
3. undefined

</div>

----

# Oh no

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
3. 3 9

</div>

----

# Embedding

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

1. Compilation error (`ambiguous selector c.M`)
2. Compilation error (`syntax error`)
3. `A`
4. `B`

</div>

----

# Slice values

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
3. `false false`

</div>

----

# Slice magic

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

</div>

----

# Loop Variables

<div class="columns">
<div>

```go
func main() {
 s := []*int{}
 for idx := 0; idx < 3; idx++ {
  s = append(s, &idx)
 }
 for _, v := range s {
  fmt.Println(*v)
 }
}
```

</div>
<div>

**What will this print?**

1. In Go1.22 `1 2 3`, in Go1.21 `3 3 3`
2. `1 2 3`
3. `3 3 3`

</div>

----

# Modulo

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

</div>

----

# `defer` order

<div class="columns">
<div>

```go
func f(x int) int { fmt.Printf("f(%d)\n", x); return x }
func g(x int) int { fmt.Printf("g(%d)\n", x); return x }
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

</div>

----

# Pointer receiver method

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
2. `3 5`
3. `0 5`

</div>

----

# Closed Channels

<div class="columns">
<div>

```go
ch := make(chan int)
for {
  select {
  case <-ch:
    fmt.Println("new item")
  }
}
```

</div>
<div>

**What will happen?**

1. The program will print `new item` very fast infinitely.
2. The program will panic due to a deadlock.
3. The program will be stuck forever.

</div>

----

# Coco Channel

<div class="columns">
<div>

```go
func f(ch chan<- int) {
 for idx := 0; idx < 10; idx++ {
  ch <- idx
 }
}

func main() {
 ch := make(chan int, 1)
 var wg sync.WaitGroup
 wg.Add(1)
 go func() { f(ch); wg.Done() }()
 for idx := 0; idx < 5; idx++ {
  fmt.Println(<-ch)
 }
 close(ch)
 wg.Wait()
}
```

</div>
<div>

**What will happen?**

1. The program will definitely panic.
2. It will print the numbers 0-5 then exit.
3. The behavior is undefined.

</div>

----

# Memory

<div class="columns">
<div>

```go
func dummyMessage() string {
 return strings.Repeat("hello", 1000)
}

func main() {
 messages := []string{}
 for idx := 10; idx < 10; idx++ {
  message := dummyMessage()
  messages = append(messages, message[:5])
 }

  runtime.GC()
 // >>>> HERE <<<<

 for _, message := range messages {
  fmt.Println(message)
 }
}
```

</div>
<div>

**How many heap bytes are allocated at `HERE`?**

1. 50184 Bytes
2. 234 Bytes
3. 734 Bytes

<!--
If you listened to my performance talk,
you might know :-)

((1000 * 5) + 16) * 10 + 24
-->

</div>

----

<!-- _class: lead -->

That's all I have.
Hope you had fun.

<!---
TODO:

* break in select statements? or break with labels.
* theming / styling
* add go playground links
* comments.
-->
