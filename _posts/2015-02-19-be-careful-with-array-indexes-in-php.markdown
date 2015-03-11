---
layout: post
title:  "Be careful with array indexes in PHP"
date:   2015-02-19
categories: php
series: PHP Pitfalls
---

What will be result of the following snippet?
{% highlight php startinline %}
$a = array(10.2 => "foo", "11.2" => "bar");
var_dump($a);
{% endhighlight %}

It will be:

{% highlight text %}
array(2) {
  [10]=> string(9) "Something"
  ["11.2"]=> string(8) "Anything"
}
{% endhighlight %}

**Why?**

Because [key may be an integer or string][php.arrays#syntax] and other types will cause unexpected results. Floats are cast to integers (by truncating the fractional part). For this reason, it's not that hard to imagine actually losing data:

{% highlight php startinline %}
$a = array(100.1 => "foo", 100.9 => "bar");
var_dump($a);
// $a is now:
// array(1) { [100]=>string(3) "bar" }
{% endhighlight %}

Or this:

{% highlight php startinline %}
$a = array(false => 'Foo', true => 'Bar');
$b = array('Foo', 'Bar');

var_dump($a === $b);
{% endhighlight %}

False and True evaluates to 0 and 1; so both arrays have identical key/value pairs in the same order.

## Null keys

Now that you know how keys are evaluated, it will be easier to guess the result of the following:

{% highlight php startinline %}
var_dump(array(NULL => 1));
{% endhighlight %}

The result is `array(1) { [""]=> int(1) }`. The manual states:
> Null will be cast to the empty string,  i.e. the key null will actually be stored under "".

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

