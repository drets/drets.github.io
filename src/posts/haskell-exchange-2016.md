---
title: Haskell eXchange 2016
published: 2016-10-22T03:00:00Z
license: CC-BY-SA
reddit: false
gh-issue: 1
---

A few weeks ago I was able to attend the “Haskell eXchange” conference in London. In this
post, I'd like to introduce readers to functional programming and briefly highlight the
advantages and techniques of functional programming which I learned from a
talk[^t] by [Don Stewart](https://donsbot.wordpress.com/about), the author of the book 
[“Real World Haskell"](http://book.realworldhaskell.org/). Then I'll
share some thoughts about how companies might start to integrate functional
programming into their tech stack.

[^t]: To see full talk:
*[“Haskell in the Large - The day to day practice of using Haskell to write large systems”](https://skillsmatter.com/skillscasts/9098-haskell-in-the-large-the-day-to-day-practice-of-using-haskell-to-write-large-systems)*,
you can sign up to “skills matter” site (it's free!).

<div></div><!--more-->

Introduction to functional programming
--------------------------------------------------------

*What is functional programming?*  
A style of building programs using mathematical functions.  

*What is mathematical function?*  
A relation exists between a set of inputs and a set of outputs; each with the property that
each input is related to *exactly one* output.

Let me give an example:

```js
var x = 1;

function impure(y) {
  x = x + y;
  return x;
}
  
function pure(x) {
  return x + 1;
}

console.log(impure(3)); // 4
console.log(impure(3)); // 7

console.log(pure(3)); // 4
console.log(pure(3)); // 4
```

Impure functions return different result for the same
input (number `3`). In other words − impure functions have side-effects.

*Why is this bad?*  
Because you lose modularity and it is harder to think about functions with
side-effects.  

On the other hand, it's really easy to compose pure functions:

```js
function compose(f,g) {
   return function(x) {
     return f(g(x));
   }
}

function plusOne(x) {
  return x + 1;
}

var plusTwo = compose(plusOne, plusOne);
var plusThree = compose(plusTwo, plusOne);

console.log(plusOne(1)); // 2
console.log(plusTwo(1)); // 3
console.log(plusThree(1)); // 4
```

It's like *lego* games; by having a set of pure functions you can easily build your
own galaxy.

*Why aren't pure functions used all the time?*  
Pure functions are awesome but the real life programs have a bunch of
side-effects. Getting a response from the server, reading from the file, printing
to the screen − all these operations have side-effects. You can't build a truly
*useful* program just on top of pure functions − you need functions with
side-effects as well.

Don Stewart's talk
--------------------------
Haskell has a smart way to distinguish between pure and impure
functions. It is common in the Haskell community to write function types for the
functions.

```haskell
makeApple :: Seed → IO Apple

makeJuice :: Apple → Juice
```

If you see `IO` (it's a Monad) somewhere in type signature, it means the function is impure.  
As well, Haskell has strong static typing. Before running a program, compiler should correctly type
check a program (and compiler can catch a dozens of errors!).  
Now, let me highlight some parts from Don Stewart's talk. Don Stewart leads
the Haskell teams in  the financial sector. In his talk, he shared how
to control complexity of applications with more than **3** million lines of
code. 

Here are a few tips from him:  

• Types help to control complexity.  

• Compare 2 pricing functions:

```haskell
f :: Double -> Double -> String -> Double

g :: Rate Libor -> Spot SGD -> Date -> Rate SIBOR
```

`g` has more expressive types. In other words, you can say more about the function
by looking in function type assuming you know financial domain.  

• Remove unclear types.  

• No side effects. Instead, try to write pure functions as many as possible.  

• Make things simpler by controlling `IO` and new types.  

• Types are for keeping code maintainable and self-documented.  

• Use “new types” and “data” to distinguish unique entities in the system.  

• Using [Phantom types](https://wiki.haskell.org/Phantom_type), you can tag the
things. Make it impossible to mix up or combine values in nonsense ways.  

• As opposed to `Stings` and `Double` types have too many valid values for most
use cases, `Bool` often has too little information.  
Instead of `authenticate :: String -> String -> Bool`  
write `authenticate :: Privileges p => User -> Password -> IO (AuthUser p)`  

• Lift errors into types (using `Maybe` and `Either`) for  making functions modular.  

• Move [partial functions](https://wiki.haskell.org/Partial_functions) to the
edges and write total functions as a core of program.  

• Types − in order to minimize complexity; it helps to deliver faster. Reuse is extremely cheap.  

Of course, for the reader unfamiliar with Haskell, these tips don't tell much,
but let me repeat once more. Basically, the main idea is that you need to use
meaningful types as much as possible. In such a way you give a compiler more
information about a program and consequently, the compiler helps to catch a
lot of errors and hopefully optimize the code. Other simple ideas are to use
total functions, move side-effects to the edges of a program. That's it!

Haskell to industry
--------------------------
Even if Haskell has a great community with a lot of academic folks behind it,
the community is really small compare to the Python or Javascript, or Php
communities. It tends to lack some useful libraries, so if you
switch to Haskell you should expect to have to contribute a lot to existing libraries
or write more libraries for your needs. However, I believe it should be
changed soon since a lot of people have realized that the OOP paradigm is not
an answer to robust software development, especially in the time when
parallel and concurrent programming plays more important role. 
I understand that re-writing back-end systems on Haskell, if you were building
the systems during last 10 years using Javasript, Php, Java may not be an
option. As a first step towards Haskell I suggest a “Haskell-like” language
− [Elm](http://elm-lang.org). Why Elm? Elm looks a bit simpler to start and
it's web-browser-based, and so it looks like a good alternative to almighty Javascipt.
One more advantage of Elm is that you can introduce it gradually into an
existing JS project[^elm]. Once you are happy with your front-end using
Elm you may think to move some of your back-end services to Haskell. After Elm
it should be much easier to start.  

[^elm]: [How to use Elm at work](http://elm-lang.org/blog/how-to-use-elm-at-work)

Happy hacking!  

At the end of this post I'd like to share a photo with one of the core
Haskell developers,  
[Simon Peyton Jones](https://en.wikipedia.org/wiki/Simon_Peyton_Jones).

![](/images/posts/haskell-exchange-2016/simon_and_me.png)
