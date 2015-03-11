---
layout: post
title:  "setTimeout is not guaranteed to be on time 1/2"
date:   2015-04-15
categories: javascript
series: Javascript Pitfalls
---


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

