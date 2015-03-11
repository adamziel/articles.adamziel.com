---
layout: post
title:  "Angular.js vs React.js performance comparison"
date:   2015-01-02 10:18:00
categories: javascript frontend angularjs reactjs
---

WEBRTC LEAKS DATA
GET REQUESTS FROM CHROME EXTENSIONS / WEBSITES

JS TRAPS!
return statement with new line afterwards

Promises are sneaky (outlives context)

angular:
ng-repeat on table rows
$interval invokeApply does not work


tl;dr don't use angular.js for bigger applications, use react.js

### Angular is jack of all trades, master of none

traps everywhere you go:

1. ng-cloak
1. ng-src
1. new scopes where you don't expect them
1. two way binding issues
1. dependency injection requiring async configuration
1. routes requiring async configuration, ans ui-router itself
1. slow watches
1. html compilation
1. seemingly useful services like $q, $http, $resource, that will give you a headache
1. 1. $q has no .always()
1. 1. $http has no .abort()
1. 1. they hav

filters issues
syntax problems in templates
when watcher assigns a new object or filter creates a new array
btw filters are run twice

### Angular pretends to be your friend, but it's not

### Angular is slow

#### Digest cycle

How do angular know whether or not it should update DOM? Watchers.
Directives tends to work directly with DOM (reference needed)

1. watches tends to pile up, all watches are executed whenever anything changes
1. it is very easy to create too many or too slow watches
    1. ngRepeat creates n scopes, each with it's own watches
    1. ngIf (and a bunch of other built in directives) creates a new scope
    1. Deep watch of an object will cost you a lot
1. $digest cycle is O(n²)

if you one day find out that digest cycle takes 1s to complete, you are screwed
They had this problem:
https://guys
https://guys2
https://guys3

I found no posts about migrating to angular because react is slow

reads from DOM (check source code of e.g. ngRepeat)
direct DOM transforms for anything

Check out this example:
http://
it receives new data about twice per second and feels clunky
what's wrong with it?
* the computation is slow
* data is required to update just the leaf node, but whole digest cycle has to be executed
* angular reads directly from DOM in ... directive

### React is fast

virtual dom and event system


componentShouldUpdate()



### Angular is hard

"Ah but I've already learned it" - nope, this paragraph still applies.

Gimmick #1 ng-if adds new scope
Gimmick #2 shadowing properties in prototypal inheritance
Gimmick #3 something with ngModelController
Gimmick #4 
Doc sucks
Error messages sucks
Two-way data binding sucks

### Angular does not give you one way to do it right

How should directives talk to each other?
1. $rootScope
2. custom GlobalEventDispatcher
3. require: '^anotherController'
4. passing function via two-way binding
5. back-passing function via & binding
6. ??

How to create an efficient directive with multitude of options? e.g. google maps
How to use jQuery UI? in react it's here:

### Angular has it's own DI

they claim it's orthogonal to require.js, but it's not

### React is easy

Great docks



### Facebook actually uses React
angular only here: http://google.com/smallsideproject



### Fundamentals are the same

Both provide tree of "contexts" (non-isolated scope derives from parent) that reacts to changes,
but "scopes are a very leaky abstraction" - Pete hunt


Jekyll also offers powerful support for code snippets:

{% highlight ruby %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}

Check out the [Jekyll docs][jekyll] for more info on how to get the most out of Jekyll. File all bugs/feature requests at [Jekyll's GitHub repo][jekyll-gh].

[jekyll-gh]: https://github.com/mojombo/jekyll
[jekyll]:    http://jekyllrb.com
