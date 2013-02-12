Browser Watcher
===

This piece of code has no other purpose than showing how to display processes output started from NodeJS into the browser in real time (with socket.io).
**Don't use "AS IS" because it doesn't manage processes correctly (no killing).**

How to use
===
Simply run the following command: coffee server.coffee.

Open the browser on http://localhost:4568 and see the result.

server.coffee starts brunch in project/ and the test.coffee script.

* test.coffee updates automatically (simple number incrementation).
* make a modification in the project/ directory. IE: project/app/mytest.coffee