---
layout: post
title:  "Built in array functions are broken by default in PHP (1/2)"
date:   2015-03-05
categories: php
series: PHP Pitfalls
---

`sort()` may produce unpredictable results:

{% highlight php startinline %}
    $a = array('a', 0);
    sort($a); // [0, 'a']
    sort($a); // ['a', 0]
{% endhighlight %}

What's even more interesting, is that it is a documented behavior:

> Be careful when sorting arrays with mixed types values because
> sort() can produce unpredictable results.

---

By default, `sort()` is suspectible to type juggling:

{% highlight php startinline %}
$a = ['11', '1e1', '0x0C'];
sort($a);
print_r($a);
// Array
// (
//     [0] => 1e1  // 10
//     [1] => 11   // 11
//     [2] => 0x0C // 12
// )
{% endhighlight %}

As you know from previous articles, this is an example
of [numeric strings in action]({% post_url 2015-01-29-php-pitfalls-numeric-strings %}).

To sort it as strings, you need to enforce sort mode using `SORT_STRING`:

{% highlight php startinline %}
$a = ['11', '1e1', '0x0C'];
sort($a, SORT_STRING);
print_r($a);
// Array
// (
//     [0] => 0x0C
//     [1] => 11
//     [2] => 1e1
// )
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

