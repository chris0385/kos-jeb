
Indent using tabs.
Use [K&R bracing style](https://en.wikipedia.org/wiki/Indent_style#K.26R)

While the language permits to write keywords in any case, you are encouraged to use lower case (function, if, else, local, set,...).

Variables should be written in lower camel-case.


Don't write more than one *run* command per line.
```c
runpath("foo.ks").
run "bar.ks".
runpath("foo.ks"). run "bar.ks". // <- NOT OK
```
