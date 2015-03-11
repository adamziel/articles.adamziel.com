---
layout: post
title:  "You may modify array length in javascript"
date:   2015-02-03
categories: javascript
series: Javascript Pitfalls
---

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

