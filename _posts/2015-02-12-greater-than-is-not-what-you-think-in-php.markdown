---
layout: post
title:  "Greater-than in is not what you think in PHP"
date:   2015-02-12
categories: php
series: PHP Pitfalls
---

`Greater/less than` comparison of two strings is perfectly valid (and really fun):

{% highlight php startinline %}
var_dump("a" < "b"); // true
var_dump("a" > "b"); // false
var_dump("z" > "yy"); // true
var_dump("zz" > "z"); // false
var_dump("zz" < "z"); // false

var_dump("z" < "az"); // false
var_dump("z" < "za"); // true
{% endhighlight %}

But what does it compare? **Two strings alphabetically**. Unless they are numeric:

{% highlight php startinline %}
var_dump('1e1' < '0x0C'); // true (10 < 12)
var_dump('2e1' < '1'); // false (20 < 1)
var_dump('2e1' < '100'); // true (20 < 100)
var_dump('2e1' < 'zzzzzz'); // true (alphabetically)
{% endhighlight %}

It turns out, this is not easy to deal with. If you simply cast both of these to an `int` or a `float`, you will run into trouble because of type casting.
However, you could create a function that compares two numbers for you and throws an exception if you didn't pass values deemed valid.
I would suggest a [gmp_cmp][php.gmp-cmp], but it does not work with decimal places. [bccomp][php.bccomp] does, but it returns no errors when rubbish data is passed.
To wrap it up, you're basically on your own.

There is a related quirk that I described in
["In PHP you may increment strings"]({% post_url 2015-02-10-in-php-you-may-increment-strings %}).
There is a semi-practical way to use this behavior, but it has a catch:

{% highlight php startinline %}
for ($i = 'a'; $i <= 'z'; ++$i) echo "$i ";
echo 'DONE';
{% endhighlight %}

What does that print? All characters from a to z. And then all combinations of {a-y}{a-z}: aa ab ac... az ba bb... yx yy yz.

**What?!**

What was our loop?

`$i = 'a'; $i <= 'z'; ++$i`

And what is `++"z"`?

`"aa"`!

So it's better to use `range('a', 'z')`.

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


