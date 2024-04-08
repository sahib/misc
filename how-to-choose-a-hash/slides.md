---
theme: default
class:
  - uncover
---

<!-- _class: lead -->

# How to choose a hash function

With flowcharts and 5 blockchains!

![bg right width:1200px](./images/choosing.jpg)

<!--
Agenda:

* What is a hash function?
* Why are they useful?
* Algorithm to choose an algorithm.
--->

---

# What is a function?

* $f(x) = x$
* $f(x) = 2x$
* $f(x) = \frac{2x−6}{3x+7}$
* $f(x) = sin(x)$

![bg right width:600px](./images/injective.png)

<!--
---

# What is an inverse function?

* $f^{-1}(x) = x$
* $f^{-1}(x) = \frac{x}{2}$
* $f^{-1}(x) = \frac{7x+6}{2-3x}$

---

# Does this work for all functions?

* $f(x) = sin(x)$ ![w:300 grayscale](sin.png)
* $f^{-1}(x) = arcsin(x)$ ![h:300 grayscale](arcsin.png)

-->
<!-- sin(x) can only be inverted between pi/2 and -pi/2 -->
<!-- If f(x) yields the same value several times for x, then we cannot fully reverse it -->

---

# What is a hash (code)?

<!-- in our context at least, hash can also mean hash brownies or minced meat... -->

Number with a fixed number of bits.

---

# What is a hash function?

$h(x)$ maps arbitrarily sized numbers to a fixed number of bits...

* ...with minimum number of collisions.
* ...as uniform as possible.
* ...is not invertable, except by brute-force (»preimage resistance«)

---

![flow chart](./images/flowchart.svg)

<!--
https://app.diagrams.net/#G11rSwTBF6jc5VIC4bXvHTUVJ2IJZM7aDa
-->

---

# Purpose

* Cryptography (e.g. for signatures or password hashing)
* Integrity checks (e.g. error detection)
* Hash tables, Merkle-Trees (`git`), Bloom filters, ...
* Identification (e.g. caching or deduplication)
* Synchronization (e.g. `rsync`)
* Scamming people with blockchains.

<!-- We will check some attributes of hash functions -->

---

# Uniformity

How well are the hash codes distributed?

![bg right width:900px](./distplot/image_random.png)

---

# Uniformity: Sum it

```go
// Just sum the input bytes:
// "123" has the same hash as "321"
// Not many bits are used...
var h uint64
for _, c := range data {
    h += uint64(c)
}

```

![bg right width:600px](./distplot/image_crosstotal.png)

---

# Uniformity: Multiplicative hashing

```go
const fib = 11400714819323198485
h := uint64(len(w))
for _, c := range data {
    h = h*fib + uint64(c)
}
```

![bg right width:900px](./distplot/image_fibonacci.png)

---


# Uniformity: crc32

![bg right width:900px](./distplot/image_crc32.png)

---

# Uniformity: fnv1a

![bg right width:900px](./distplot/image_fnv1a.png)

---

# Uniformity: sha3

![bg right width:900px](./distplot/image_sha3.png)

---

# Bit-size

Can be used to control number of collisions.

Cryptographic hash functions usually have a lot more.

![bg right width:1200px](./images/bitsize.webp)

---

# Collisions

Usecases:

* `git`: Really bad if something collides. Security issue!
* **Caching:** Annoying to the user, but not really terrible.
* **Deduplication:** Does not matter a lot, if done right.

![bg right width:1200px](./images/collision.jpg)

---

# Performance


Full list [here](https://rurban.github.io/smhasher/doc/table.html).


Algorithm    |   MiB/sec
-------------|---------:
MeowHash     | 29969.40
xxh128       | 18802.16
fibonacci    | 16878.32
crc32        | 8403.09
Murmur3F     | 7623.44
blake3_c     | 1288.84
FNV1a        | 760.52
sha1_64      | 575.68
md5_64       | 351.01
sha2-256     | 231.70
sha3-256     | 125.35
argon2       | <0.1

![bg right width:1300px](./images/performance.jpg)

<!-- Sometimes slow performance is a good thing
     as for example with key derivation function
     where you want an attacker to spend a lot of time.

     Examples would be scrypt or argon2

     It is important that the performance depends on
     the machine, as many modern hash algorithms utilize
     specialized machine instructions, baked into the CPU.

     Some hash algorithms are not suitable for certain platforms.
     We use FNV1a a lot, but the TI and Pi are not very good at it
     because they require a modulo operation, which is not supported
     in hardware on the Pi.
-->

---

# Cryptography

Important aspects:

* Is it standard? (NIST)
* Are there known attacks beyond brute force? (md5 †, SHA1 †)
* Collision resistant
* High-enough bit size
* Cannot be (easily) inverted
* Can it be keyed/seeded?

---

# Language support

* Good libraries available?
* Matches reference implementation?
* Streaming interface available?

    ```go
    type Hash interface {
        Write(b []byte) (int, error) // add content.
        Sum() uint64                 // return hash.
        Reset()                      // reset to zero.
    }

    // vs:
    Sum(data []byte) uint64          // all at once.
    ```

---

# Special case: Rolling Hash

<!--
rolling hashing: hash functions for data windows (data can be removed!)
--->

![](./images/rolling_hash.webp)

---

# Special case: Perfect Hash

<!--
perfect hash: specially constructed hash function for a known data set with no collisions.
-->

![width:800px](./images/perfect_hash.png)

---

# Sources:

https://en.wikipedia.org/wiki/Hash_function
https://en.wikipedia.org/wiki/List_of_hash_functions
https://en.wikipedia.org/wiki/Hash_function_security_summary
