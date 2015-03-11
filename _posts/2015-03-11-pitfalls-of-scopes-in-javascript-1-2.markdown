---
layout: post
title:  "Pitfalls of scopes in Javascript (4/2)"
date:   2015-03-14
categories: javascript
series: Javascript Pitfalls
---
The specs does not mention scopes a lot.

* [Section 8.6.2][ecma-8.6.2] says that there is an internal property referred to as [[scope]]
* [Section 10.3][ecma-10.3] says that some locally available variables are not part of [[scope]]

For the sake of clarity, when I refer to a Scope, I mean a [context][ecma-10.3]
that allows you to define and use a local variable that is not visible to any parent context.

## Scopes pitfalls

By default, there is only a global scope. You can **only** create a new scope by creating
and calling a function. You may be tempted to try additional ways, however:

* A `with` statement does not create a new scope, it just tricks you
   by [temporarily augmenting the scope it's declared in][ecma-12.10]

{% highlight javascript %}
var a = {};
console.log(typeof a); // a is "object"
with({a: 1}) {
    console.log(typeof a); // a is "number"
    var bar = 1; // let's create a new variable
}
console.log(typeof a); // a is an "object" again
console.log(bar); // logs: 1, bummer!
{% endhighlight %}

* A `catch` statement does the same thing to give you the access to
  the exception

* `let`, `const`, and other ES6 goodies are not covered

## Hoisting pitfall

This behavior is described formally in [ECMAScript Edition 5.1 section 10.5][ecma-10.5], and in more approachable diction
at [Mozilla var statement reference][mozilla-hoisting], which says:

> Because variable declarations (and declarations in general) are processed
> before any code is executed, declaring a variable anywhere in the code
> is equivalent to declaring it at the top

Guess what is the output of this snippet would be:

{% highlight javascript %}
var example = 1;
function puzzle2() {
    console.log(example);
    if(example === 1) {
        var example = 2;
    }
};
puzzle2();
console.log(example)
{% endhighlight %}

`undefined` and number `1` respectively. Of course! But why?

What happens under the hood is roughly explained in the following steps.

1. Execution of `puzzle2` function is requested
1. Before any code is executed, it is scanned to search for declarations (`var`, `function`).
    These declarations are used to create a new scope. Since we declared `example` in line 5
    with `var example = 2;`, the newly created scope contains a local variable `example`
    [with no value (undefined)][ecma-12.2]. Any further references to `example` will be resolved
    to that variable and not to a parent-scope variable with the same name.
1. `console.log(example)` logs `undefined` since this variable has no value yet
1. `if(example === 1)` evaluates to `false`
1. `puzzle2()` is finished, `console.log(example)` logs `1`  since the current scope was never affected

Function declarations are processed in the same way, but the result may seem counterintuitive.
Since declarations are processed before executing a code and assigning values, you get undefined values when working with variable assignments. However, function body is a part of its declaration, so you may call a function right away. The last declaration always wins:

{% highlight javascript %}
var exampleNumber = 1;
function puzzle() {
    function exampleFn1() { console.log("1 works"); };
    exampleNumber = 2;
    exampleFn1(); // logged: "1 works"
    exampleFn2(); // logged: "2 works"
    return exampleNumber;

    function exampleNumber() {};
    function exampleFn2() { console.log("I won't be called :("); };
    function exampleFn2() { console.log("2 works"); };
};
console.log(puzzle()) // logged: 2
console.log(exampleNumber); // logged: 1
{% endhighlight %}


{% include series.html %}


[so-js-setinterval]: http://stackoverflow.com/a/731625/1510277
[so-js-single-thread]: http://stackoverflow.com/questions/2734025/is-javascript-guaranteed-to-be-single-threaded
[dbaron-timeouts]: http://dbaron.org/log/20100309-faster-timeouts
[dbaron-timeouts-example]: http://dbaron.org/mozilla/zero-timeout
[mozilla-set-immediate]: https://developer.mozilla.org/en-US/docs/Web/API/Window.setImmediate
[mozilla-set-interval-danger]: https://developer.mozilla.org/en-US/docs/Web/API/WindowTimers.setinterval#Dangerous_usage
[mozilla-post-message]: https://developer.mozilla.org/en-US/docs/Web/API/window.postMessage
[mozilla-bitwise-operations]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Bitwise_Operators#Signed_32-bit_integers
[mozilla-int32array]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Int32Array#Browser_compatibility
[mozilla-hoisting]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/var#var_hoisting
[mozilla-htmlcollection]: https://developer.mozilla.org/en-US/docs/Web/API/HTMLCollection
[mozilla-htmlcollection#methods]: https://developer.mozilla.org/en-US/docs/Web/API/HTMLCollection#methods
[mozilla-nodelist]: https://developer.mozilla.org/en-US/docs/Web/API/NodeList
[mozilla-timeout-nesting]: https://developer.mozilla.org/en-US/docs/Web/API/WindowTimers.setTimeout#Minimum.2F_maximum_delay_and_timeout_nesting
[whatwg-timers]: https://html.spec.whatwg.org/multipage/webappapis.html#timers
[whatwg-event-loop]: https://html.spec.whatwg.org/multipage/webappapis.html#event-loop
[whatwg-task-queue]: https://html.spec.whatwg.org/multipage/webappapis.html#task-queue
[w3-collection]: http://www.w3.org/TR/domcore/#concept-collection
[w3-dispatching-events]: http://www.w3.org/TR/domcore/#dispatching-events
[w3-interface-parentnode]: http://www.w3.org/TR/domcore/#interface-parentnode
[oracle-floats]: http://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html
[yahoo-on-floats]: http://www.yuiblog.com/blog/2009/03/10/when-you-cant-count-on-your-numbers/
[ecma-4.3.19]: http://www.ecma-international.org/ecma-262/5.1/#sec-4.3.19
[ecma-7.8.3]: http://www.ecma-international.org/ecma-262/5.1/#sec-7.8.3
[ecma-7.9]: http://www.ecma-international.org/ecma-262/5.1/#sec-7.9
[ecma-8.5]: http://www.ecma-international.org/ecma-262/5.1/#sec-8.5
[ecma-8.6.2]: http://www.ecma-international.org/ecma-262/5.1/#sec-8.6.2
[ecma-9.5]: http://www.ecma-international.org/ecma-262/5.1/#sec-9.5
[ecma-10.2.3]: http://www.ecma-international.org/ecma-262/5.1/#sec-10.2.3
[ecma-10.3]: http://www.ecma-international.org/ecma-262/5.1/#sec-10.3
[ecma-10.5]: http://www.ecma-international.org/ecma-262/5.1/#sec-10.5
[ecma-10.6]: http://www.ecma-international.org/ecma-262/5.1/#sec-10.6
[ecma-11.9.3]: http://www.ecma-international.org/ecma-262/5.1/#sec-11.9.3
[ecma-11.9.4]: http://www.ecma-international.org/ecma-262/5.1/#sec-11.9.4
[ecma-12.2]: http://www.ecma-international.org/ecma-262/5.1/#sec-12.2
[ecma-12.6.4]: http://www.ecma-international.org/ecma-262/5.1/#sec-12.6.4
[ecma-12.9]: http://www.ecma-international.org/ecma-262/5.1/#sec-12.9
[ecma-12.10]: http://www.ecma-international.org/ecma-262/5.1/#sec-12.10
[ecma-15.1.2.2]: http://www.ecma-international.org/ecma-262/5.1/#sec-15.1.2.2
[ecma-15.2.3.6]: http://www.ecma-international.org/ecma-262/5.1/#sec-15.2.3.6
[ecma-15.4]: http://www.ecma-international.org/ecma-262/5.1/#sec-15.4
[ecma-15.4.4.2]: http://www.ecma-international.org/ecma-262/5.1/#sec-15.4.4.2
[ecma-15.8.2.15]: http://www.ecma-international.org/ecma-262/5.1/#sec-15.8.2.15
[ecma5.1]: http://www.ecma-international.org/ecma-262/5.1/
[ecma6]: https://people.mozilla.org/~jorendorff/es6-draft.html
[ecma6-typed-arrays]: http://people.mozilla.org/~jorendorff/es6-draft.html#sec-typedarray-objects
[ecma6-toint32]: http://people.mozilla.org/~jorendorff/es6-draft.html#sec-toint32
[github-v8-int32value]: https://github.com/v8/v8/blob/aec5abab1e9faf1ab0949d2f068093544ba2bc40/include/v8.h#L1756
[github-bigdecimal]: https://github.com/iriscouch/bigdecimal.js
[dbaron-zerotimeout]: http://dbaron.org/mozilla/zero-timeout

