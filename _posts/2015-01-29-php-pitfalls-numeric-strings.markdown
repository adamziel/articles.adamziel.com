---
layout: post
title:  "PHP pitfalls - numeric strings"
date:   2015-01-29
categories: php
series: PHP Pitfalls
---

Zend (in their infinite wisdom) designed loose comparison to be sensible and intuitive.
Just take a look at this example:

{% highlight php startinline %}
var_dump("15" == "0xF"); // true
var_dump("1000" == "1e3"); // true
var_dump("6" == " 06"); // true
var_dump("+0123.45e6" == 123450000);// true
{% endhighlight %}

See how easy it is for a new person to adapt a language? Okay, enough with sarcasm.

**What just happened?!**

When comparing two strings with `==`, PHP will treat both like numbers if they are "Numeric strings".
What are numeric strings? Let's check the PHP manual:

> Numeric strings consist of an optional sign, any number of digits, an optional decimal part and an optional exponential part.
> Thus +0123.45e6 is a valid numeric value.

It is entirely OK to add any string after the numeric part, thus "3kkk" is a valid numeric string and will be converted to 3
whenever possible.

Even more examples of how deceitful is `==`:

{% highlight php startinline %}
// true, string starts with 3
var_dump('3c7c0ace395d80182db07ae2c30f034' == 3);

// true, string starts with 3e1 which is 30
// in scientific notation
var_dump('3e1c0ace395d80182db07ae2c30f034' == 30);

// true, string starts with 0xFF which is 255 in hexadecimal
var_dump('0xFFyc0ace395d80182db07ae2c30f034' == 255);

// false, surprise! octal numbers don't fly
// even though var_dump(0123 == 83) returns true
var_dump('0123yc0ace395d80182db07ae2c30f034' == 83);

// but this returns true
var_dump('0123yc0ace395d80182db07ae2c30f034' == 123);
{% endhighlight %}

Oh by the way, you may add numbers and strings (and subtract, and multiply etc):

{% highlight php startinline %}
var_dump("40 + 2 = " +1);
{% endhighlight %}

The output is `41` because the string evaluates to `40`.

How to validate if string is a number then? Do not use [is_numeric][php.is-numeric]!
It behaves similar to the mentioned examples (so it will will return `true` for `0xFF`).
For integers, use [ctype_digit][php.ctype-digit], and for floats, use regular expressions.

Prequisites change and data mutates, but your teammates should be able to promptly understand the flow of your code.
Every loose comparison is a stopping point for you to think, "can I be sure that it will not backfire in this particular case?"

{% include series.html %}


[php.references]: http://php.net/manual/en/language.references.whatdo.php
[php.spl-types]: http://php.net/manual/en/book.spl-types.php
[php.array-functions]: http://php.net/manual/en/ref.array.php
[php.arrays#syntax]: http://php.net/manual/en/language.types.array.php#language.types.array.syntax
[php.operators-array]: http://php.net/manual/en/language.operators.array.php#language.operators.array
[php.type-juggling]: http://php.net/manual/en/types.comparisons.php#types.comparisions-loose
[php.type-casting]: http://php.net/manual/en/language.types.type-juggling.php#language.types.typecasting
[php.type-comparison#types-table]: http://php.net/manual/en/language.operators.comparison.php#language.operators.comparison.types
[php.string#to-number]: http://php.net/manual/en/language.types.string.php#language.types.string.conversion
[php.array-search]: http://php.net/manual/en/function.array-search.php
[php.array-intersect#notes]: http://php.net/manual/en/function.array-intersect.php#refsect1-function.array-intersect-notes
[php.sort#parameters]: http://php.net/manual/en/function.sort.php#refsect1-function.sort-parameters
[php.is-numeric]: http://php.net/manual/en/function.is-numeric.php
[php.ctype-digit]: http://php.net/manual/en/function.ctype-digit.php
[php.gmp-cmp]: http://php.net/manual/en/function.gmp-cmp.php
[php.bccomp]: http://php.net/manual/en/function.bccomp.php

