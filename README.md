# sudo_make_me_a_sandwich
http://xkcd.com/149/ implementation as a GNU Makefile + Jimmy John's online delivery

Presently, this Makefile lets you:

1. Order a sub, club or gargantuan sandwich (sorry, no SLIMs)
2. State your preferences of onions, tomatoes and peppers
3. Choose your favorite Jimmy Chips
4. Order a delicious pickle (or not)

It simply depends upon:
* GNU Make
* sudo (don't worry, root privs are dropped before we get to the net)
* cURL
* coreutils
* a POSIX-compatible shell 

The dependencies are minimal because I like my software the same way I like my
sandwiches: freaky fast.

You will be asked to provide enough information to complete the order. If you
don't like answering so many questions all the time you may hardcode the
responses into the variables near the top of the Makefile.

Unlike shell languages, Makefiles don't require quote marks around string
literals which contain whitespace. Indeed, the quotes will become part of the
value, interfering with the JSON sent to JJ's!

For example, you should write your delivery address like so:

```Makefile

DELIV_ADDR1=350 5th Avenue

```

Instead of doing this:

```Makefile

DELIV_ADDR1="405 Lexington Avenue"

```

The trickiest piece of information to come up with is the four-digit Jimmy
John's Location ID. It is, unfortunately, not the same four-digit number which
is printed on your JJ's receipt.

Perhaps the easiest way to discover this ID number is to visit
online.jimmyjohns.com in your browser with the developer tools enabled.  Get
into the view which shows you each URI request the browser makes as you
traverse their pages. Start a delivery order and enter your address. If you
haven't used this address before, JJ's will ask you to verify your address on a
page that says "VERIFY ADDRESS". The locationId parameter will appear in a GET
request to the API/Location/ URI after you click the "CONFIRM ADDRESS" button
(e.g. https://online.jimmyjohns.com/API/Location/?locationId=2144).
