# sudo_make_me_a_sandwich
http://xkcd.com/149/ implementation as a GNU Makefile + Jimmy John's online delivery

Presently, this Makefile lets you:

1. Order a sub, club or gargantuan sandwich (sorry, no SLIMs)
2. State your preferences of onions, tomatoes and peppers
3. Choose your favorite Jimmy Chips
4. Order a delicious pickle (or not)
5. Order a giant cookie
6. Select the nearest JJ's location to your delivery address

It simply depends upon:
* GNU Make
* sudo (don't worry, root privs are dropped before we get to the net)
* cURL
* coreutils
* a POSIX-compatible shell
* GNU AWK

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

The latest version geocodes your delivery address through the Google Maps geocode API
and returns a list of the nearest JJ's restaraunts to you, sorted by distance
from your ZIP code. There is (allegedly) a limit to the number of times you can use this
API in one day, and these extra HTTP requests increase the amount of time standing between
you and your freaky-fast sub. If you

## New in v1.3(beta)

* Input handling is in general much improved
* Rudimentary input validation on all text-entry fields
  (i.e. numeric fields accept only digits; an empty line causes the prompt to
  be repeated)
* Sensitive information (e.g. credit card number, CCV number) is obscured as
  you type álàsmartphone password field
* Geolocation and restaraunt location selection is implemented
