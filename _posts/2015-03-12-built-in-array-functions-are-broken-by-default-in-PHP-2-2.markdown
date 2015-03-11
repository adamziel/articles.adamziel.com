---
layout: post
title:  "Built in array functions are broken by default in PHP (1/2)"
date:   2015-03-12
categories: php
series: PHP Pitfalls
---

What do you think will happen?

{% highlight php startinline %}
$a = array(0 => 'Foo', 1 => 'Bar');
$b = array(1 => 'Foo', 0 => 'Bar');

var_dump($a == $b);
var_dump($a === $b);
{% endhighlight %}

The first comparison returns `true` and the second returns `false`. This is because
`==` [compares only key/value pairs][php.operators-array], and `===` [checks the order and type, as well][php.operators-array].

# Searching in Arrays

Beware of [Array functions][php.array-functions] in their non-strict variant:

{% highlight php startinline %}
$a = ['5.5'];
// loose search:
var_dump(in_array('5.50', $a)); // true

// Strict search:
var_dump(in_array('5.50', $a, true)); // false
var_dump(in_array('5.5', $a, true)); // true
{% endhighlight %}

Another example:

{% highlight php startinline %}
$a = array('7.1' => '7.1');
// false
var_dump(array_key_exists('7.10000000000000001', $a));

// true (non-strict)
var_dump(in_array('7.10000000000000001', $a));

// false (strict)
var_dump(in_array('7.100000000000000025', $a, true));
{% endhighlight %}

**To summarize:**
Do not use a loose comparison. Use a strong comparison and instruct built-in functions to do the same when possible.


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

