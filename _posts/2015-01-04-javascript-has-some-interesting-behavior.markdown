---
layout: post
title:  "Javascript has some interesting behavior"
date:   2015-01-04 10:18:00
categories: javascript dom frontend 
---

This post refers to [ECMA 5.1][ecma5.1].

{% include preamble.html %}

---


# 1. Arrays

## The `for in` loop

What are the differences between the following loops?

{% highlight javascript %}
var data = [0,1,2,3,4];
data.foo = 'bar';
Array.prototype.shim = function() {};

// for
for(var i=0,max=data.length;i<max;i++) {
    console.log(i);
}
// for-in
for(var i in data) {
    console.log(i);
}
{% endhighlight %}

**for** explicitly enumerates numeric indexes in a given order: `0, 1, 2, 3, 4`

**for-in** [iterates over object properties and prototype chain properties][ecma-12.6.4] 

> Enumerating the properties of an object includes enumerating properties of its prototype,
> and the prototype of the prototype, and so on, recursively

Therefore, you will get `0, 1, 2, 3, 4, foo, shim`. You can filter out properties coming from prototype chain (`shim`) by checking `if(data.hasOwnProperty(i))`.

**for-in** only works because the
[Array is an object and indexes are stored as properties][ecma-15.4].

**for-in** [does not guarantee any particular order][ecma-12.6.4]—so it's entirely possible that you
could get `3, 1, 4, 2, 0, foo, shim`.

> The mechanics and order of enumerating the properties (...) is not specified

---

**for** allows you to add new indexes on-the-fly while still being able to iterate over them (just update the `max` value).

**for-in** doesn't guarantee that new properties will be visited.

> If new properties are added to the object being enumerated during enumeration, the newly added
> properties are not guaranteed to be visited in the active enumeration.


**So, you should always use the `for-in` loop (or Array.forEach) and never use the `for` loop to enumerate over arrays!**

---

## Playing with Arrays

Suppose you modify an Array like the one below. What is being logged?

{% highlight javascript %}
var data = [0,1,2,3,4];
data[600] = 5;
data.forEach(function(x) { console.log(x); });
console.log('---');
for(var i=0,max=data.length;i<max;i++) {
    console.log(data[i]);
}
console.log('---');
console.log(data.length);
{% endhighlight %}

`forEach` outputs `0 1 2 3 4 5`, but `for` loop outputs numbers from `0` to `600`.

*Wait, what?*

We just broke the consistency between `for` and `forEach`; but [this is by design][ecma-15.4]. We added only a single property, which causes `forEach` to loop over 6 elements. The `length` is now 601, meaning `for` runs 601 times. Keys 5-599 are undefined.

> whenever a property is added whose name is an array index, the length property is changed, 
> if necessary, to be one more than the numeric value of that array index;

also

> whenever the length property is changed, every property whose name is an array index whose 
> value is not smaller than the new length is automatically deleted

Thus, we can use it to lenghten or shorten an Array.

{% highlight javascript %}
var data = [0,1,2,3,4];
data.length = 3;

console.log(data.length);
data.forEach(function(x) { console.log(x); });
{% endhighlight %}

the output is `3` and `0 1 2`

---

## Infamous disappearing object keys

Suppose you construct an object like the one below. What is the value of `data`?
{% highlight javascript %}
var anotherObject = {toString: function() { return "0"; }};

var data = {};

data[0] = 'lorem';
data['0'] = 'ipsum';
data[Number(0)] = 'dolor';
data[anotherObject] = 'sit';
data[[]] = 'amet';

console.log(data);
{% endhighlight %}

In this example, `data` is `{0: "amet", "": "amet"}`. *Why?*

[All keys get converted to strings via toString()][ecma-15.2.3.6] before being added to the object.

`[]` [evaluates to ""][ecma-15.4.4.2], other keys evaluates to `0`.

Let's go even further. What is being logged in the following case?

{% highlight javascript %}
var data = {};
data[0.1+0.2] = 1;

console.log(data);
{% endhighlight %}

**`Object {0.30000000000000004: 1}`**.

Why? Because of how floating-point numbers work. More on that in next paragraph.

---

## There are no integers in Javascript

Let's do some simple math:
{% highlight javascript %}
0.1 + 1 - 1 === 0.1
0.1 + 0.2 === 0.3
{% endhighlight %}

In this instance, every line will evaluate to **false**.

**Why?**

The specification says that [every Number is a float][ecma-8.5], and [floats are not particularly precise][yahoo-on-floats] [(click for more info)][oracle-floats]. This results in the following:

* [Every number literal evaluates to a `Number`][ecma-7.8.3]
* [`parseInt` returns a `Number`][ecma-15.1.2.2] as well as [Math.round][ecma-15.8.2.15] and just about everything else
* [Internally a conversion to Int32 may occur][ecma-9.5], like when you use [bitwise operators][mozilla-bitwise-operations] to truncate a number. But that's only a trick—what you really get is a truncated `Number` (still a float).

{% highlight javascript %}
console.log(typeof ~~1); // number
{% endhighlight %}
 
* [ECMAScript6 defines TypedArray][ecma6-typed-arrays] objects, and [modern browsers][mozilla-int32array] already support them. Unfortunately, `TypedArray` is only about [how your data is stored internally][ecma6-typed-arrays]. When you assign a `Number` to a `TypedArray`, it is truncated by [abstract conversion operations][ecma6-toint32].  There is still no way to read an integer in Javascript:

{% highlight javascript %}
console.log(typeof (new Int32Array([1,2]))[0]); // number
{% endhighlight %}


**To summarize**

If you need high precision, don't trust `Numbers`. Use a [BigDecimal implementation][github-bigdecimal] instead.


## The `"why can't I use this Array like other ones?"` pitfall

What will happen in the following snippet of code?

{% highlight javascript %}
function test() { arguments.slice(0, 1);}
test("1","2","3");

var collection = document.getElementsByTagName('span');
collection.forEach(function() {});
{% endhighlight %}

Let's take a look:

* `arguments` is not an Array, it's an [`Arguments Object`][ecma-10.6]
* `collection` is not an Array, it's a [HTMLCollection][mozilla-htmlcollection]

Therefore this code will fail with an error `undefined is not a function`

**What do we do then?**

You can convert both of them to an `Array` with this little trick:

{% highlight javascript %}
argArray = Array.prototype.slice.call(arguments);
collection = Array.prototype.slice.call(collection);
{% endhighlight %}

Since `Array.prototype.slice` returns an Array, we can feed it our Array-like object and the snippet will work with no errors.
{% highlight javascript %}
function test() {
    var argArray = Array.prototype.slice.call(arguments);
    argArray.slice(0, 1);
}
test("1","2","3");

var collection = document.getElementsByTagName('span');
collection = Array.prototype.slice.call(collection);
collection.forEach(function() {});
{% endhighlight %}


---


# 2. DOM

## Live and Static collections of nodes

What is being logged in the following code?

{% highlight javascript %}
document.body.appendChild(document.createElement('span'));

var collection1 = document.getElementsByTagName('span');
var collection2 = document.querySelectorAll('span');

console.log('collection1.length is', collection1.length);
console.log('collection2.length is', collection2.length);

document.body.appendChild(document.createElement('span'));

console.log('collection1.length is', collection1.length);
console.log('collection2.length is', collection2.length);
{% endhighlight %}

The answer is:

{% highlight text %}
collection1.length is 1
collection2.length is 1
collection1.length is 2
collection2.length is 1
{% endhighlight %}

**Why? (Some boring intro first)**

When requesting nodes from `document` based methods, you don't get an Array instance. You get one of these: 

* [NodeList][mozilla-nodelist] - consists of Nodes
* [HTMLCollection][mozilla-htmlcollection] - consists of Elements, same methods as in NodeList + [namedItem()][mozilla-htmlcollection#methods]

Regardless of which you receive, your collection may either be **live** or **static**.

* **[live collection][w3-collection]** is updated whenever DOM is updated
* **[static collection][w3-collection]** is a snapshot that remains the same across DOM updates

In general, collections are **live**, except for in the following cases when they become static:

1. [Event path of DOM Event whose target is part of DOM][w3-dispatching-events]
    (this way, you may remove one of its parents from DOM and its snapshot will still be available via event.path)
1. [**When you use `document.querySelectorAll`**][w3-interface-parentnode]

**Now, on to the point**

In our snippet, we request two collections via

* `collection1 = getElementsByTagName` - a live collection
* `collection2 = querySelectorAll` - a static collection

After we add a second `span` to DOM, only `collection1` reflects the change because.

## I really want to stop the event propagation!

What will be logged after I click `span` element?
{% highlight javascript %}
var span = document.createElement('span');
span.innerText = 'Click me';
document.body.appendChild(span);

span.addEventListener('click', function(event) {
    event.stopPropagation();
    console.log('first handler');
}, false);

span.addEventListener('click', function(event) {
    console.log('second handler');
}, false);

document.body.addEventListener('click', function(event) {
    console.log('third and last handler');
}, false);
{% endhighlight %}

The output will be **first handler, second handler**

**Why?**

Because `event.stopPropagation` prevents events from bubbling up the DOM. However, it does not prevent calling other event handlers attached directly to the same element.

In that case, **use event.stopImmediatePropagation()**
{% highlight javascript %}
var span = document.createElement('span');
span.innerText = 'Click me';
document.body.appendChild(span);

span.addEventListener('click', function(event) {
    event.stopImmediatePropagation();
    console.log('first handler');
}, false);

span.addEventListener('click', function(event) {
    console.log('second handler');
}, false);
{% endhighlight %}

The output is `first handler`, as is expected.

---


# 3. Scopes

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

## Beware of callbacks inside loops

What will be logged when you click on a first `div` element in the following snippet?

{% highlight html %}
<div>The div element in question</div>
<div>Lorem</div>
<div>Ipsum</div>
<div>Dolor</div>
<script>
function a() {
    var divs = document.getElementsByTagName('div');
    for(var i=0,max=divs.length;i<max;i++) {
        divs[i].onclick = function() {
            console.log(i);
        };
    };
}
a();
</script>
{% endhighlight %}

The answer is `4`. Why?

Because `i` does not exist in the local scope of our event handler and it is resolved from a parent scope.
The event handler is called well after the loop has finished.
What value does `i` have after the loop is finished? **`4`**.

So, what we want to reference is not the loop counter, but is actually a snapshot of it from a given loop pass.
We may, for example, create a self-calling function that receives `i` as a parameter:

{% highlight javascript %}
for(var i=0,max=divs.length;i<max;i++) {
    (function(i) {
        // i is now a completely new local
        // variable, unaffected by loop cycles
        divs[i].onclick = function() {
            console.log(i);
        };
    })(i);
};
{% endhighlight %}

If we were working with Arrays, I would suggest `Array.forEach`, but that is not available on a `NodeList`.

# 4. Other

## Weak comparison is a headache

What will be logged in the following snippet?
{% highlight javascript %}
console.log('' == ['']);
console.log('' == []);
console.log('' == 0);
console.log(0 == ['0']);
console.log(0 == []);
console.log(0 == [[[]]]);
console.log(0 == '0');
console.log(false == ['0']);
console.log(false == ['']);
console.log(false == 0);
console.log(false == '0');
console.log(undefined == null);
{% endhighlight %}

Each line will result in `true`

**Why?**

[Because of how the `==` operator works][ecma-11.9.3].
Don't try to memorize it, [just use `===` instead][ecma-11.9.4].
{% highlight javascript %}
console.log('' === ['']); //false
console.log('' === []); //false
console.log('' === 0); //false
console.log(0 === ['0']); //false
console.log(0 === []); //false
console.log(0 === [[[]]]); //false
console.log(0 === '0'); //false
console.log(false === ['0']); //false
console.log(false === ['']); //false
console.log(false === 0); //false
console.log(false === '0'); //false
console.log(undefined === null); //false
{% endhighlight %}

## I really want to return that value!

What will be logged in the following snippet?
{% highlight javascript %}
function a() {
    return
        2
    ;
}
console.log(a());
{% endhighlight %}

The output is `undefined`, but **why?**

[The `return` statement is terminated exclusively by a semicolon][ecma-12.9].
It may also take an expression representing a value it should return; this expression MUST be
given before any LineTerminator. When a LineTerminator is found after a `return`,[automatic semicolon insertion][ecma-7.9] kicks in, and our snippet gets interpreted like this:

{% highlight javascript %}
function a() {
    return;
    2;
}
console.log(a());
{% endhighlight %}

So, remember to always put your return expressions in the same line.

## setTimeout is not always on schedule

What will be the result of following snippet?
{% highlight javascript %}
console.log('starting');
var start = (new Date()).getTime();
setTimeout(function() {
    var end = (new Date()).getTime()
    console.log('It took ', end-start, 'ms to fire callback1');
}, 500);

alert();
console.log('alert dismissed');
{% endhighlight %}

The exact number depends on how fast you dismiss the alert, but you should see something like
`It took  1013 ms to fire callback1`.

But we told it to run after 500ms! *So what happened?*

Javascript runs in an [event loop][whatwg-event-loop] (I assume you know how the event loop works), which is [*usually* being executed on a single thread][so-js-single-thread].
If something blocks execution in an unrelated function, it will directly influence when our callback is called.
[This is specified in HTML standard][whatwg-timers]:

> This API does not guarantee that timers will run exactly on schedule. Delays due to CPU load, other tasks, etc., are to be expected.

What it also means, is that setTimeout schedule is more loose in some cases (e.g., on inactive tabs or in power-save mode).



## setTimeout(fn, 0) does not kick in right after the current synchronous code is finished

What will be the result of following snippet?
{% highlight javascript %}
console.log('starting');
var start = (new Date()).getTime()
setTimeout(function() {
    var end = (new Date()).getTime()
    console.log('It took ', end-start, 'ms to fire callback1');
    
    start = (new Date()).getTime()
    setTimeout(function() {
    setTimeout(function() {
    setTimeout(function() {
    setTimeout(function() {
        var end = (new Date()).getTime()
        console.log('It took ', end-start, 'ms to fire callback2');
        
        start = (new Date()).getTime()
        setTimeout(function() {
            var end = (new Date()).getTime()
            console.log('It took ', end-start, 'ms to fire callback3');
        }, 0);
    }, 0);
    }, 0);
    }, 0);
    }, 0);
}, 0);
{% endhighlight %}

Exact results may vary, but you will get something similar to:

{% highlight text %}
It took  1 ms to fire callback1
It took  8 ms to fire callback2
It took  4 ms to fire callback3 
{% endhighlight %}

Why "it took 1ms to fire callback1"? Why "it took 8ms to fire callback2", which was four `setTimeout` calls away while "4ms to fire callback3", which was just one `setTimeout` call away?

[Every nested call to setTimeout increases the internal *nesting level* variable][mozilla-timeout-nesting]. And if we go deep enough, then this happens:
> If nesting level is greater than 5, and timeout is less than 4, then increase timeout to 4.

*Why would I do that?* You may not even know that the current *nesting level* is higher than 5. If you're past a callback to a third party library, it may nest a lot of setTimeout calls before giving back the control, especially if you use `promises`.

So, what do we do to achieve real 0ms scheduling? We should append a task to a [task queue][whatwg-task-queue] using a mechanism that is not constrained by [timers specification][whatwg-timers]. It turns out that [window.postMessage does just the thing][mozilla-post-message]. [Here is an excellent example][dbaron-timeouts] by David Baron. At [the example page][dbaron-zerotimeout], I get the following results:

> 100 iterations of setZeroTimeout took 29 milliseconds.
> 100 iterations of setTimeout(0) took 401 milliseconds.

As you can see, the difference is significant. There is also a non-standard [setImmediate][mozilla-set-immediate] method specifically for this, but it is only supported by IE10 and node.js.


## setInterval callback is not guaranteed to be executed

What will be logged in the following code?

{% highlight javascript %}
var startedAt = new Date().getTime();
var actual = 0;
var intervalHandle = setInterval(function() {
    ++actual;
    // just anything slow
    for(var i=0,max=2000000,r;i<max;i++) {
        r = document.querySelector('body').width + 1;
    }
}, 100);


setTimeout(function() {
    var now = new Date().getTime();
    console.log("Actual", actual);
    console.log("Expected", Math.floor((now-startedAt)/100));
}, 2000);
{% endhighlight %}

Exact numbers depends on your hardware, but you will get something along the lines of:
{% highlight text %}
Actual 5
Expected 96 
{% endhighlight %}

**Why?**

If the thread is blocked, the interval is pending until the current handler finishes.
If the thread is blocked for 10s while the interval is scheduled every 2s,
you may think that Javascript will queue 5 calls. But this is not the case. It will queue,
at most, one call to be executed as soon as flow control is passed back to the browser.
[This answer on StackOverflow contains more details if you are curious][so-js-setinterval].

[You should also try not to schedule asynchronous code inside callbacks passed to `setInterval`][mozilla-set-interval-danger].


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

