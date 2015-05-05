---
layout: post
title:  "setTimeout is not guaranteed to be on time 2/2"
date:   2015-04-22
categories: javascript
series: Javascript Pitfalls
---


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

*Why would I do that?* You may not even know that the current *nesting level* is higher than 5. If you passed a callback to a third party library, it may nest a lot of setTimeout calls before giving back the control, especially if you use `promises`.

So, what do we do to achieve real 0ms scheduling? We should append a task to a [task queue][whatwg-task-queue] using a mechanism that is not constrained by [timers specification][whatwg-timers]. It turns out that [window.postMessage does just the thing][mozilla-post-message]. [Here is an excellent example][dbaron-timeouts] by David Baron. At [the example page][dbaron-zerotimeout], I get the following results:

> 100 iterations of setZeroTimeout took 29 milliseconds.
> 100 iterations of setTimeout(0) took 401 milliseconds.

As you can see, the difference is significant. There is also a non-standard [setImmediate][mozilla-set-immediate] method specifically for this, but it is only supported by IE10 and node.js.


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

