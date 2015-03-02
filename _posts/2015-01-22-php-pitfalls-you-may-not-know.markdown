---
layout: post
title:  "PHP pitfalls you may not know"
date:   2015-01-22 12:54:00
categories: php backend
---

This post refers to PHP 5.6.

{% include preamble.html %}

---

# 1. Type juggling

## Basics

What do you think is returned by this comparison?

{% highlight php startinline %}
var_dump('e358efa489f58062f10dd7316b65649e' == 0);
{% endhighlight %}

Of course, it's `true`!

**What?!**

In PHP, when you use a weak comparison (`==`) instead of a strict comparison (`===`), you will get some surprising results.
This occurs because weak comparisons [cast both variables to the same type before comparing them][php.type-casting].
Example results of some of these comparisons are described in a [type juggling table][php.type-juggling], which is also described in the PHP manual.

In this particular case, [we're comparing a string to a number][php.type-comparison#types-table]. And this conversion
has a [very nasty property][php.string#to-number]:

> If the string starts with valid numeric data, this will be the value used. Otherwise, the value will be 0 (zero).

"e" is not valid numeric data, so the final value is 0; therefore, we really just compare 0 to 0—which is true.

## Numeric strings

Zend (in their infinite wisdom) designed type juggling to be sensible and intuitive. Just take a look at this example:

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

See how easy it is for a new person to adapt a language? Okay, enough with sarcasm.

Note what happens when comparing two strings.
All of the following evaluate to true:

{% highlight php startinline %}
var_dump("15" == "0xF");
var_dump("1000" == "1e3");
var_dump("6" == " 06");
var_dump("+0123.45e6" == 123450000);
{% endhighlight %}

> Numeric strings consist of an optional sign, any number of digits, an optional decimal part and an optional exponential part.
> Thus +0123.45e6 is a valid numeric value. 

A weak comparison has even more surprises:

{% highlight php startinline %}
var_dump("foo" == TRUE);
var_dump("foo" == 0);
var_dump(TRUE == 0);
{% endhighlight %}

What do you think we will get? `true`, `true`, and of course `false`!

This is also true with `+` operator:
{% highlight php startinline %}
var_dump("40 + 2 = " +1);
{% endhighlight %}

The answer is `41` because the string evaluates to `40`.

Make sure not use [is_numeric][php.is-numeric] to deal with numeric strings, because it behaves similar to the mentioned examples (so it will will return `true` for `0xFF`).
For integers, use [ctype_digit][php.ctype-digit], and for floats, use regular expressions.

Type juggling will haunt us every day of every year since some built in functions are [comparing variables using weak comparisons][php.sort#parameters].
Others will use strict ones, but only after [converting variables to a common base (using type juggling)][php.array-intersect#notes].
[Some other functions][php.array-search] will give us a choice between weak and strict comparisons. Watch your steps!

## Hash comparison edge-case

What will be result of the following snippet?

{% highlight php startinline %}
var_dump(md5('240610708') == md5('QNKCDZO'));
{% endhighlight %}

It is `true`, but intuitively it should be `false`. And no, there is no collision between the two.

**Oh my god! Are all my `==` password checks doomed???**

The following hashes are computed from these two strings:

{% highlight text %}
string(32) "0e462097431906509019562988736854"
string(32) "0e830400451993494058024219903391"
{% endhighlight %}

You may be tempted to say they both get converted to `0` because both starts with `0`.
The first part is true, but the latter is not.

Consider the following example:

{% highlight php startinline %}
var_dump(md5('9920') == md5('9948'));
// md5('9920') is 0a9612880adf61ac669c2eb54e4207e3
// md5('9948') is 0bdf2c1f053650715e1f0c725d754b96
{% endhighlight %}

Comparison returns `false`, but both hashes starts with `0`, too. So what's going on?

Our initial hashes are very special because they are both numeric strings. They both contain a valid number written in scientific notation. For this reason, PHP tries to convert them to a number. In both cases the coefficient is equal to `0`, so they both are converted to `0`. **Finally, PHP compares `0` to `0`, and returns `true`!**

## Another obscure case related to hashes:

{% highlight php startinline %}
$a = md5('2744819');
$b = md5('10951062');

// both hashes are also numbers written in scientific notation:
var_dump($a == "645134e5695203203737253415082374");
var_dump($b == "24950e92549174085766247816063786");

// false:
var_dump(md5('2744819') == md5('10951062'));

// everything below is true on PHP 5.6 but
// false on PHP 5.2 (64bit):
var_dump(md5('2744819') == INF);
var_dump(md5('10951062') == INF);
var_dump(md5('2744819') == pow(10,1000000));
var_dump(md5('10951062') == pow(10,1000000));
{% endhighlight %}

Why is this? PHP is limited when comparing ordinary numerical strings:

{% highlight php startinline %}
// true:
var_dump("1799999999999999999" == "1799999999999999999.0");

// false on PHP 5.6, true on PHP 5.2 (64bit):
var_dump("17999999999999999990" == "17999999999999999990.0");
{% endhighlight %}

But if you use scientific notation, it's a whole different story:

{% highlight php startinline %}
// true:
var_dump("18".str_repeat('0', 100) == "18e100");

// true:
var_dump("18".str_repeat('0', 300) == "18e300");

// false:
var_dump("18".str_repeat('0', 310) == "18e400");
{% endhighlight %}

## Incrementation
What will be the result of the following snippet?

{% highlight php startinline %}
$a = $b = null;
var_dump(++$a, --$b);
{% endhighlight %}

It will be `1` and `null`. Incrementation operators convert `null` to `0`, but funnily enough, decrementation operators do not.

{% highlight php startinline %}
$a = 'bazinga';
var_dump(++$a);
{% endhighlight %}

Not a warning, not an error. Just `bazingb` because the last character in a string was incremented by one.

But don't be too quick to rely on this behavior:

{% highlight php startinline %}
for ($i = 'a'; $i <= 'z'; ++$i) echo "$i ";
echo 'DONE';
{% endhighlight %}

What does that print? All characters from a to z. And then all combinations of {a-y}{a-z}: aa ab ac... az ba bb... yx yy yz.

**What?!**

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

But what does it compare? **Two strings alphabetically**. 

What was our loop?

`$i = 'a'; $i <= 'z'; ++$i`

And what is `++"z"`?

`"aa"`!

One final thing to note is that strings are compared alphabetically unless they are numeric:
{% highlight php startinline %}
var_dump('1e1' < '0x0C'); // true (10 < 12)
var_dump('2e1' < '1'); // false (20 < 1)
var_dump('2e1' < '100'); // true (20 < 100)
var_dump('2e1' < 'zzzzzz'); // true (alphabetically)
{% endhighlight %}

This leads us to the next point:

## "Greater-than" comparisons

**There are no strong operators for < or >**.

Thus, the following is true:

{% highlight php startinline %}
// evaluates to 100 < 1000 because
// 1e3 is 1000 in scientific notation
var_dump("100" < "1e3ace395");
{% endhighlight %}

It turns out, this is not easy to deal with. If you simply cast both of these to an `int` or a `float`, you will run into trouble because of type casting.
However, you could create a function that compares two numbers for you and throws an exception if you didn't pass values deemed valid.
I would suggest a [gmp_cmp][php.gmp-cmp], but it does not work with decimal places. [bccomp][php.bccomp] does, but it returns no errors when rubbish data is passed.
To wrap it up, you're basically on your own.

## Static typing

Aside from using strict comparisons everywhere, PHP has an [spl types][php.spl-types] extension that kind of
support static typing:

{% highlight php startinline %}
$int = new SplInt(94);
$float = new SplFloat(3.154);
$bool = new SplBool(true);
$string = new SplString("1e2");

$int = 'a'; // throws UnexpectedValueException
$float = 'a'; // throws UnexpectedValueException
$string = 8; // throws UnexpectedValueException

// Just kidding, it would be too beautiful:
$bool = 8; // perfectly legal
$bool = 'c'; // perfectly legal
{% endhighlight %}

For real static types, use [Hack][hack].


# 2. Arrays

## Float keys

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

## Internal index value

{% highlight php startinline %}
$array = array(0 => 'January', 1 => 'February', 2 => 'March');

foreach($array as $key => $value){
  unset($array[$key]);
}

$array[] = 'January';
var_dump($array);
// array(1) { [3]=> string(6) "January" }
{% endhighlight %}

Unsetting keys does not reset the value of the index, so the next number in a sequence gets automatically assigned. If you want to reset array keys, the easiest way is to create a new array consisting of values of the old one: 
{% highlight php startinline %}
$array = array_values($array);
var_dump($array);
// array(1) { [0]=> string(6) "January" }
{% endhighlight %}

## Sorting arrays

See how the `sort` function performs on an Array of numeric strings:

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

In some cases sorting acts strange, too:

{% highlight php startinline %}
$a = array('a', 0);
sort($a);
$t = $a;
sort($a);
var_dump($t === $a); // false

$t = $a;
sort($a);
sort($a);
var_dump($t === $a); // true
{% endhighlight %}

## Comparing arrays

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
// Weak search:
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
Do not use a weak comparison. Use a strong comparison and instruct built-in functions to do the same when possible.

Prequisites change and data mutates, but your teammates should be able to promptly understand the flow of your code.
Every weak comparison is a stopping point for you to think, "can I be sure that it will not backfire in this particular case?"



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

