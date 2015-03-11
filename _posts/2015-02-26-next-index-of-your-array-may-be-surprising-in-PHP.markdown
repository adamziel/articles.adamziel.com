---
layout: post
title:  "Next index of your array may be surprising in PHP"
date:   2015-02-26
categories: php
series: PHP Pitfalls
---

What will be result of the following snippet?

{% highlight php startinline %}
$array = array(0 => 'January', 1 => 'February', 2 => 'March');

foreach($array as $key => $value){
  unset($array[$key]);
}

$array[] = 'January';
print_r($array);
{% endhighlight %}

It will be: `Array( [3] => January )`

**Why?**

Unsetting keys does not reset the value of the index, so the next
number in a sequence gets automatically assigned. If you want to
reset array keys, the easiest way is to create a new array consisting
of values of the old one:

{% highlight php startinline %}
$array = array_values($array);
print_r($array);
// Array ( [0]=> January )
{% endhighlight %}

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

