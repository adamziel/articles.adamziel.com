---
layout: post
title:  "PHP pitfalls - type juggling"
date:   2015-01-22
categories: php
series: PHP Pitfalls
---

What do you think is returned by the following comparison?

{% highlight php startinline %}
var_dump('e358efa489f58062f10dd7316b65649e' == 0);
{% endhighlight %}

Of course, it's `true`!

**What?!**

In PHP, when you use a loose comparison (`==`) instead of a strict comparison (`===`), you will get some surprising results.
This occurs because loose comparisons [cast both variables to the same type before comparing them][php.type-comparison].
Example results of some of these comparisons are described in a [loose comparisons table in the PHP manual][php.loose-comparison].

In this particular case, [we're comparing a string to a number][php.type-comparison#types-table]. And this conversion
has a [very nasty property][php.string#to-number]:

> If the string starts with valid numeric data, this will be the value used. Otherwise, the value will be 0 (zero).

"e" is not valid numeric data, so the final value is 0; therefore, we really just compare 0 to 0 — which is true.

Another surprising example:

{% highlight php startinline %}
var_dump("foo" == TRUE);
var_dump("foo" == 0);
var_dump(TRUE == 0);
{% endhighlight %}

What do you think we will get? `true`, `true`, and of course `false`! **Why?** Take a look:

{% highlight php startinline %}
// "foo" is converted to bool (true)
var_dump("foo" == TRUE);

// "foo" is converted to a number (0)
var_dump("foo" == 0);

// 0 is converted to bool (false)
var_dump(TRUE == 0);
{% endhighlight %}

What may be really dangerous, is how PHP treats numeric strings. You may read more about it
in the next article: [PHP Pitfalls - numeric strings]({% post_url 2015-01-29-php-pitfalls-numeric-strings %})

Prequisites change and data mutates, but your teammates should be able to promptly understand the flow of your code.
Every loose comparison is a stopping point for you to think, "can I be sure that it will not backfire in this particular case?"

{% include series.html %}

[php.string#to-number]: http://php.net/manual/en/language.types.string.php#language.types.string.conversion
[php.type-casting]: http://php.net/manual/en/language.types.type-juggling.php#language.types.typecasting
[php.loose-comparison]: http://php.net/manual/en/types.comparisons.php#types.comparisions-loose
[php.type-comparison]: http://php.net/manual/en/language.operators.comparison.php
[php.type-comparison#types-table]: http://php.net/manual/en/language.operators.comparison.php#language.operators.comparison.types
