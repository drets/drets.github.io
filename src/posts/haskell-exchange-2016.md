---
title: Haskell eXchange 2016
published: 2016-10-22T03:00:00Z
license: CC-BY-SA
reddit: false
gh-issue: 1
---

A few weeks ago I visited “Haskell eXchange 2016” conference in London. In this
post I'd like to introduce reader to functional programming, briefly highlight the
advantages  and techniques of functional programming which I learnt from first
talk[^t] by [Don Stewart](https://donsbot.wordpress.com/about). Then, I want to
share my opinion on how companies may start to integrate functional programming
to  their tech stack.

[^t]: To see
*[“Haskell in the Large - The day to day practice of using Haskell to write large systems”](https://skillsmatter.com/skillscasts/9098-haskell-in-the-large-the-day-to-day-practice-of-using-haskell-to-write-large-systems)*
talk you must a sign up on “skills matter” site.

<div></div><!--more-->

Introduction to functional programming
--------------------------------------------------------

*What is functional programming?*  
A style of building programs using mathematical functions.  

*What is mathematical function?*  
A relation between a set of inputs and a set of outputs with the property that
each input is related to exactly one output.

Let me give an example:

```js
var x = 1;

function impure(y) {
  x = x + y
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

Impure function returns different result for the same
input (number `3`). In other words − impure function has side-effects.

*Why is bad?*  
Because you lose modularity and it is harder to think about functions with
side-effects.  

On the other hand it's really easy to compose pure functions:

```js
function compose(f,g) {
   return function(x) {
     return f(g(x));
   }
}

function plusOne(x) {
  return x + 1
}

var plusTwo = compose(plusOne, plusOne);
var plusThree = compose(plusTwo, plusOne);

console.log(plusOne(1)); // 2
console.log(plusTwo(1)); // 3
console.log(plusThree(1)); // 4
```

It's like *lego* games − having a set of pure functions you can easily build your
own galaxy.

*Why don't use pure functions all the time?*  
Pure functions are awesome but the real life programs have a bunch of side-effects. Let me give
an example: getting response from the server, reading from file, printing to a screen − all
these operations have side-effects. You can't build *useful* program just on top of
pure functions − you need functions with side-effects as well.

Don Stewart's talk (assumes a basic Haskell knowledge)
--------------------------------------------------------------------------------
Haskell has a smart way to distinguish between pure and impure
functions. It  is common in Haskell community to write function types for the
functions.

```haskell
makeApple :: Seed → IO Apple

makeJuice :: Apple → Juice
```

If you see `IO` somewhere in type signature, it means function is impure.  
Haskell has strong static typing. Each Haskell program should be correctly type
checked by compiler before ability to run a program (compiler may catch a dozens
of errors!).  
It seems we are set to start  highlighting some parts from the Don's talk. Don
Stewart leads  the Haskell teams in a  financial sector and he shared how
to control complexity of application with more than 2 millions lines of
code. And answer is simple!  

• Types helps to control complexity.  

• Compare 2 pricing functions:

```haskell
f :: Double -> Double -> String -> Double

g :: Rate Libor -> Spot SGD -> Date -> Rate SIBOR
```

`g` has more expressive types (in other words you can say more about the function
by looking in function type (assuming you know financial domain)).  

• Remove unclear types.  

• No side effects.  Try to write a pure function as many as possible.  

• Make things simpler by controlling `IO` and new types.  

• Types are for keeping code maintainable and self-documented.  

• Use “new types” and “data” to distinguish unique entities in the system.  

• Using [Phantom types](https://wiki.haskell.org/Phantom_type) you can tag the
things. Make it impossible to mix up or combine values in nonsense ways.  

• As a dual to how `Stings` and `Double` types have too many valid values for most
use cases. `Bool` often has to little information. Instead of  
`authenticate :: String -> String -> Bool`  
write  
`authenticate :: Privilege p => User -> Password -> IO (AuthUser p)`  

• Lift errors into types (using `Maybe` ane `Either`) for making functions modular.  

• Move [partial functions](https://wiki.haskell.org/Partial_functions) to the
edges − write total functions as a core of program.  

• Types − for minimize complexity; it helps to deliver faster; reuse is extremely cheap.  

Haskell to industry
--------------------------
WIP
