---
layout: post
title:  "Why PHP thinks two different hashes are equals"
date:   2015-02-05
categories: php
series: PHP Pitfalls
---

**The following snippet of code returns true!**

{% highlight php startinline %}
var_dump(md5('240610708') == md5('QNKCDZO'));
{% endhighlight %}

**What?! Why?** Intuitively it should return `false`!

This is an excellent example of why you should avoid using loose comparison.

The following hashes are computed from these two strings:

{% highlight text %}
string(32) "0e462097431906509019562988736854"
string(32) "0e830400451993494058024219903391"
{% endhighlight %}

You may be tempted to say they both are converted to `0` because both starts with `0`.
The first part is true, but the latter is not.

Consider the following example:

{% highlight php startinline %}
var_dump(md5('9920') == md5('9948'));
// md5('9920') is 0a9612880adf61ac669c2eb54e4207e3
// md5('9948') is 0bdf2c1f053650715e1f0c725d754b96
{% endhighlight %}

Comparison returns `false`, but both hashes starts with `0`, too. So what's going on?

Our initial hashes are very special because they are both numeric strings. They both contain a valid
number written in scientific notation (like 1e10, only longer). For this reason, PHP tries to convert
them to a number. In both cases the coefficient is equal to `0`, so they both are converted to `0`.

**Finally, PHP compares `0` to `0`, and returns `true`!**

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

