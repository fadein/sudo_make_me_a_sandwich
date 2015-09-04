# sudo_make_me_a_sandwich
http://xkcd.com/149/ implementation a GNU Makefile + Jimmy John's online delivery

It simply depends upon:
* GNU Make
* sudo
* cURL
* coreutils
* POSIX-compatible shell 

The dependencies are minimal because I like software the same way I like my
sandwiches: freaky fast.

You will be asked to provide enough information to complete the order. If you
don't like answering so many questions all the time you may hardcode the
responses into the variables near the top of the Makefile.

Unlike shell languages, Makefiles don't require quotes around string literals
which contain whitespace. Indeed, the quotes will become part of the value, and
will interfere with the JSON sent back to JJ's!
