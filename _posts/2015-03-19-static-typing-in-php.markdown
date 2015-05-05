---
layout: post
title:  "Static typing in PHP"
date:   2015-03-19
categories: php
series: PHP Pitfalls
---

As you know from
[PHP Pitfalls - numeric strings]({% post_url 2015-01-29-php-pitfalls-numeric-strings %}),
loose comparison will give you a headache and you should use strict comparison when possible.

Additionally, PHP has an [spl types][php.spl-types] extension that kind of support static typing:

{% highlight php startinline %}
$int = new SplInt(94);
$float = new SplFloat(3.154);
$bool = new SplBool(true);
$string = new SplString("1e2");

$int = 'a'; // throws UnexpectedValueException
$float = 'a'; // throws UnexpectedValueException
$string = 8; // throws UnexpectedValueException
{% endhighlight %}

But with a catch:

{% highlight php startinline %}
// Just kidding, it would be too beautiful:
$bool = 8; // perfectly legal
$bool = 'c'; // perfectly legal
{% endhighlight %}

For real static types, use [Hack][hack]:

{% highlight php startinline %}
function increment(int $x): int {
    $y = $x + 1;
    return $y;
}

increment(1);
// works perfectly

increment("a");
// Catchable fatal error: Argument 1 passed
// to increment() must be an instance of int,
// string given
{% endhighlight %}


{% include series.html %}


[hack]: http://hacklang.org/
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

