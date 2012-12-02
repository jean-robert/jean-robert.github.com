---
layout: post
title: 1 + 1 = 3, the proof in R
---

Discussing with some friends the other day, one of them mentioned a supposedly famous quote from Einstein saying that 1 + 1 = 3. Despite my best efforts, Google couldn't find that particular quote. Anyway, we were trying to understand how could have Einstein come up with that. Our answer was that the proposition "1 + 1 = 3" is true when "+" corresponds to the concatenate operator and "=" corresponds to the equality between a base-2 number and a base-10 number.

Jokes aside, this is a good opportunity to remember how nice R is when it comes to overriding primitive operators. Indeed, the "+" operator in R works well with many various types (numeric, vector, matrices, ...), but you can also make it work the way you want. In our case, we want the "+" operator to concatenate and compute in base 2. This can be done as follow:


```
"+" <- function(e1, e2) {
    sum(c(e1 * 2, e2))
}
```

A pitfall to avoid is to define your function like this:

```
"+" <- function(e1, e2) {
    e1 * 2 + e2
}
```

This won't work since you are defining "+" using "+"... Hence an infinite recursion that R will quickly remind you of. Instead, using the `sum` function (another primitive) allows you to use the correct "+" when suming up.

If you use the first function defined above, you get the answer that everyone expected: 1+1=3. Even better, you can write any number in base 2, like 1+1+0+1 and it will return the base-10 answer: 13.


```
1 + 1
1 + 1 + 0 + 1
```

In a more generic way, you can define any operator you like using "%":

```
"%foo%" <- function(e1, e2) {
    sum(c(e1 * 3, e2))
}
```

Oh, and just in case, do not forget to `rm('+')`...

