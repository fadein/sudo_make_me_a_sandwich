## Configuration items
## Hardcode values for questions you don't want to be asked each on each order

# The JJ's store location number which can be found by looking for a "Location"
# element in the JSON sent to you in a response from online.jimmyjohns.com.
# This is NOT the same as the store number found on your receipt (that would be
# too easy :)
JJ_LOCATION=

# Delivery address
DELIV_ADDR1=
DELIV_ADDR2=
DELIV_CITY=
DELIV_STATE=
DELIV_ZIP=
DELIV_COUNTRY=

# Your contact information
CONTACT_FIRSTNAME=
CONTACT_LASTNAME=
CONTACT_EMAIL=
CONTACT_PHONE=

# Your payment information
PAYMENT_CODE=CC
CC_NUM=
CC_TYPE=
CC_CVV=
CC_YEAR=
CC_MONTH=
CC_ADDR1=
CC_ADDR2=
CC_CITY=
CC_STATE=
CC_ZIP=
CC_COUNTRY=

# Don't actually go through with the order; don't click "Submit" at the end
DRY_RUN=


# The base URL for Jimmy John's online store
BASE=https://online.jimmyjohns.com

# cURL stuff - don't change unless you know what you're doing
cURL=curl
cURL_OPTS = --silent --fail -w '%{response_code}'                                               \
	--cookie-jar $(COOKIE_JAR) --cookie $(COOKIE_JAR)                                       \
	-H api-key:A6750DD1-2F04-463E-8D64-6828AFB6143D                                         \
	-H 'Accept-Language: en-US,en;q=0.8'                                                    \
	-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
	-H 'Cache-Control: max-age=0'                                                           \
	-H 'Connection: keep-alive'                                                             \
	-H 'mimeType:application/json;charset=UTF-8'                                            \
	-A 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.155 Safari/537.36'
CONTENT_TYPE_JSON = -H 'Content-Type:application/json;charset=UTF-8'
POST=--data @-
PUT=-T -

# Shut up about which directory we're in
MAKEFLAGS = --no-print-directory

.ONESHELL:
.SILENT:
.PHONY: me a banner TODO

define TODO
_ query ADDR2 fields only when the corresponding ADDR1 was also blank
_ Support JJ's gift cards
endef

ifeq ($(DRY_RUN),)
TARGETS = banner choose make-cookie-jar place-order submit-order success cleanup-cookie-jar
else
TARGETS = banner choose make-cookie-jar place-order cleanup-cookie-jar
endif

all:
	echo You must be new here. Go check this out:
	echo     http://xkcd.com/149/

me a: ; :

sandwich:
ifneq ($(shell uname), CYGWIN_NT-6.1)

ifneq ($(USER),root)
	echo What? Make it yourself.
else
	echo Okay
	sudo -u $(SUDO_USER) $(MAKE) $(TARGETS)
endif

else
	echo Okay
	$(MAKE) $(TARGETS)
endif


TODO: ; $(info $(TODO)) :

banner: ; $(info $(BANNER)) :

define BANNER =
         ________________________  _______________________
        (      .         .   `   `;  .     .              )
       (   .         .           ;    ,        .           )
      (__________________________,__________________________)
      {{ {{ {{ {{ {{ {{  {{   {{   }}  }} {{ {{ }} {{ { }} }}
       {{ {{ {{~~~ {~~{{~~{{`~~,}}  }}  }} }} {{ }} {{ }} }}
     {{ {{ {{~~~~~~~~~  {{`~~,}}  }} ,~~~~~'  `~~~~~, } }}
         `~~~~~' `~~'   `~~   ~~~`~~~ (=======) `~~, (===)~~`
     `~~~~~(=========) ~~~~~~`  ,~~~~~~`    (=====) ,~~~~`
      (=======)~___~(=====)~~___ _~~(=========)~~__~~(======)
       (  .   .         .  ,   `;       .      ,         )
        (        ,          .   ;     ,           .     )
         (_____________________,_______________________)
endef

choose: pc-sandwich pc-chips pc-pickle get-JJ_LOCATION get-delivery-info get-contact-info get-payment-info
get-delivery-info: get-DELIV_ADDR1 get-DELIV_CITY get-DELIV_STATE get-DELIV_ZIP get-DELIV_COUNTRY
get-contact-info: get-CONTACT_FIRSTNAME get-CONTACT_LASTNAME get-CONTACT_EMAIL get-CONTACT_PHONE
get-payment-info: get-PAYMENT_CODE get-CC_NUM get-CC_TYPE get-CC_CVV get-CC_YEAR get-CC_MONTH get-CC_ADDR1 get-CC_CITY get-CC_STATE get-CC_ZIP get-CC_COUNTRY get-tip-amount
place-order: initial-requests negotiate-address schedule put-delivery-address post-items put-contact-info put-tip post-payment

make-cookie-jar:
	$(eval COOKIE_JAR = $(shell mktemp -t cookies.XXXXXX))

cleanup-cookie-jar:
	-rm -f $(COOKIE_JAR)

initial-requests:
	$(cURL) $(cURL_OPTS) $(BASE)
	$(cURL) $(cURL_OPTS) $(BASE)/api/Customer/

negotiate-address: CheckForManualAddress ForDeliveryAddress VerifyDeliveryAddress
CheckForManualAddress VerifyDeliveryAddress: export METHOD=$(POST)
CheckForManualAddress VerifyDeliveryAddress: get-delivery-info
	echo
	echo
	echo $(cURL) $(METHOD) $(cURL_OPTS) $(BASE)/api/Order/$@/
	echo
	cat <<JSON | $(cURL) $(METHOD) $(cURL_OPTS) $(BASE)/api/Order/$@/
	{
		"City" : "$(DELIV_CITY)",
		"State" : "$(DELIV_STATE)",
		"AddressLine1" : "$(DELIV_ADDR1)",
		"AddressLine2" : "$(DELIV_ADDR2)",
		"Zipcode" : "$(DELIV_ZIP)",
		"Country" : "$(DELIV_COUNTRY)",
		"DisplayText" : "",
		"DeliveryInstructions" : "",
		"Company" : "",
		"SaveInstructions" : true,
		"FriendlyName" : "",
		"GateCode" : "",
		"CacheAddress" : true,
		"Latitude" : 0,
		"Longitude" : 0
	}
	JSON
	echo


ForDeliveryAddress: export METHOD=$(POST)
ForDeliveryAddress: get-delivery-info
	echo
	echo
	echo $(cURL) $(METHOD) $(cURL_OPTS) $(BASE)/API/Location/$@/
	echo
	cat <<JSON | $(cURL) $(METHOD) $(cURL_OPTS) $(BASE)/API/Location/$@/
	{
		"City" : "$(DELIV_CITY)",
		"State" : "$(DELIV_STATE)",
		"AddressLine1" : "$(DELIV_ADDR1)",
		"AddressLine2" : "$(DELIV_ADDR2)",
		"Zipcode" : "$(DELIV_ZIP)",
		"Country" : "$(DELIV_COUNTRY)",
		"DisplayText" : "",
		"DeliveryInstructions" : "",
		"Company" : "",
		"SaveInstructions" : true,
		"FriendlyName" : "",
		"GateCode" : "",
		"CacheAddress" : true,
		"Latitude" : 0,
		"Longitude" : 0
	}
	JSON
	echo


schedule: export METHOD=$(POST)
schedule: get-JJ_LOCATION
	echo
	echo
	echo $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Order/
	echo
	cat <<JSON | $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Order/
	{
		"LocationId" : $(JJ_LOCATION),
		"OrderType" : "Delivery",
		"ScheduleTime" : "ASAP"
	}
	JSON
	echo

put-delivery-address: export METHOD=$(PUT)
put-delivery-address: get-delivery-info
	echo
	echo
	echo $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Order/DeliveryAddress/
	echo
	cat <<JSON | $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Order/DeliveryAddress/
	{
		"Zipcode" : "$(DELIV_ZIP)",
		"City" : "$(DELIV_CITY)",
		"AddressLine1" : "$(DELIV_ADDR1)",
		"AddressLine2" : "$(DELIV_ADDR2)",
		"State" : "$(DELIV_STATE)",
		"Country" : "$(DELIV_COUNTRY)",
		"FriendlyName" : "",
		"Longitude" : 0,
		"Company" : "",
		"DisplayText" : null,
		"OrderType" : "Delivery",
		"Index" : null,
		"Latitude" : 0,
		"ScheduleTime" : "ASAP",
		"DeliveryInstructions" : "",
		"SaveInstructions" : true,
		"GateCode" : "",
		"CacheAddress" : false
	}
	JSON
	echo

# Post your order; sandwich, chips and pickle
post-items: export METHOD=$(POST)
post-items: pc-sandwich pc-chips pc-pickle
	echo
	echo
	echo $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Order/Items/
	echo
	cat <<JSON | $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Order/Items/
	[
		{
			$(SANDWICH_JSON)
		},
		{
			$(CHIPS_JSON)
		},
		{
			$(PICKLE_JSON)
		}
	]
	JSON
	echo

# Submit the user's contact information, and opt out of marketing communications
put-contact-info: export METHOD=$(PUT)
put-contact-info: get-contact-info
	echo
	echo
	echo $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Order/ContactInfo/
	echo
	cat <<JSON | $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Order/ContactInfo/
	{
		"ContactFirstName" : "$(CONTACT_FIRSTNAME)",
		"ContactLastName" : "$(CONTACT_LASTNAME)",
		"ContactPhone" : "$(CONTACT_PHONE)",
		"ContactEmail" : "$(CONTACT_EMAIL)",
		"OptInPromos" : false,
		"OptInNews" : false,
		"AcceptedTermsAndConditions" : true,
		"IsAnonymousUser" : true
	}
	JSON
	echo

# Submit the tip
put-tip: export METHOD=$(PUT)
put-tip: get-tip-amount
	echo
	echo
	echo $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Payment/Tip/
	echo
	cat <<JSON | $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Payment/Tip/
	{
	    "TipAmount" : "$(tip-amount)",
	    "TipType" : "AMOUNT"
	}
	JSON
	echo

# Send off the billing information
post-payment: export METHOD=$(POST)
post-payment: get-payment-info
	echo
	echo
	echo $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Payment
	echo
	cat <<JSON | $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Payment
	{
		"PaymentCode" : "$(PAYMENT_CODE)",
		"CardHolderName" : "$(CONTACT_FIRSTNAME) $(CONTACT_LASTNAME)",
		"BillingAddress1" : "$(CC_ADDR1)",
		"BillingAddress2" : "$(CC_ADDR2)",
		"BillingCity" : "$(CC_CITY)",
		"BillingState" : "$(CC_STATE)",
		"BillingZipcode" : "$(CC_ZIP)",
		"CardType" : "$(CC_TYPE)",
		"CreditCardNumber" : "$(CC_NUM)",
		"CvvNumber" : "$(CC_CVV)",
		"ExpirationYear" : $(CC_YEAR),
		"ExpirationMonth" : "$(CC_MONTH)",
		"BillingCountry" : "$(CC_COUNTRY)",
		"SaveCreditCardInformation" : false,
		"GiftCardNumber" : "",
		"SaveGiftCardInformation" : false,
		"GiftCardPinNumber" : "",
		"Amount" : 30.00
	}
	JSON
	echo

# This target clicks the "Submit" button
submit-order:
	echo
	echo
	echo $(cURL) $(cURL_OPTS) $(BASE)/api/Order/Submit/
	echo
	$(cURL) $(cURL_OPTS) $(BASE)/api/Order/Submit/
	echo

success:
	cat <<WINNER
	
	Your order was placed successfully
	WINNER


## The sandwich menus
sandwich-opts = 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19

define SANDWICH_IDS
	3688 3689 3690 3691 3692
	3693 3701 3702 3703 3704
	3705 3706 3707 3730 3709
	3710 3844 3694 3711
endef

define SANDWICH_JSON
      "IsSizeFixed" : false,
      "MustEdit" : false,
      "MenuItemText" : "",
      "MenuItemId" : "$(sandwich)",
      "IsQuantityFixed" : false,
      "CouponReference" : "",
      "CanEdit" : false,
      "IsPriceFixed" : false,
      "SelectedSize" : "Regular",
      "DisplayPrice" : "",
      "DisplayText" : "",
      "IsMainCouponItem" : false,
      "ConfirmedSprouts" : false,
      "Label" : "",
      "Index" : "",
      "Quantity" : 1,
      "ItemCost" : 0,
      "NoMayo" : false,
      "CanDelete" : false,
      "RewardNotes" : "",
      "FavoriteName" : "",
      "ExtendedPrice" : 0,
      "Modifiers" : [
         {
			 "EditItem" : false,
			 "SelectedAnswerId" : "$(peppers)",
			 "SelectedAnswerText" : "",
			 "GroupId" : "3895"
         },
         {
            "EditItem" : false,
            "SelectedAnswerText" : "",
            "SelectedAnswerId" : "$(tomatoes)",
            "GroupId" : "2998"
         },
         {
            "EditItem" : false,
            "GroupId" : "3021",
            "SelectedAnswerId" : "$(onions)",
            "SelectedAnswerText" : ""
         },
         {
            "EditItem" : false,
            "GroupId" : "3892",
            "SelectedAnswerId" : "$(leave-bread-in)",
            "SelectedAnswerText" : ""
         },
         {
            "EditItem" : false,
            "GroupId" : "3974",
            "SelectedAnswerId" : "$(cut-in-half)",
            "SelectedAnswerText" : ""
         }
      ]
endef

pc-sandwich: prompt-sandwich choose-sandwich prompt-customize-sandwich

prompt-sandwich:
	cat <<SANDWICH
	
	Choose your sandwich:
	1)  Pepe                  7)  Smoked Ham Club        13) Gourmet Veggie Club
	2)  Big John              8)  Billy Club             14) Bootlegger Club
	3)  Totally Tuna          9)  Italian Night Club     15) Club Tuna
	4)  Turkey Tom            10) Hunters Club           16) Club Lulu
	5)  Vito                  11) Country Club           17) Ultimate Porker
	6)  The Veggie            12) Beach Club             18) J.J.B.L.T.
	19) The J.J. Gargantuan
	SANDWICH

choose-sandwich:
	$(eval sandwich = $(shell read -p 'sandwich> '; echo $$REPLY))
	$(if $(filter-out $(sandwich-opts), $(sandwich)),
	 $(eval sandwich = $(shell $(MAKE) choose-sandwich-recurse)))
	$(eval sandwich = $(word $(sandwich), $(SANDWICH_IDS)))

choose-sandwich-recurse:
	$(eval sandwich = $(shell read -p 'sandwich> '; echo $$REPLY))
	$(if $(filter-out $(sandwich-opts), $(sandwich)),
	 $(eval sandwich = $(shell $(MAKE) choose-sandwich-recurse)))
	$(info $(sandwich))

# customizing the sandwich
prompt-customize-sandwich: customize-sandwich

leave-bread-in = 0
cut-in-half = 0
#TODO: this extra level of indirection is to allow me to (hopefully)
# skip these extra questions and use default values if the user
# doesn't care to deviate from the default values
customize-sandwich: pc-tomatoes pc-onions pc-peppers


## Hot Cherry Peppers - the default is No Peppers
peppers = 23557

define PEPPERS_IDS
	23557 23427 23425 23428
endef

peppers-opts = 1 2 3 4

pc-peppers: prompt-peppers choose-peppers

prompt-peppers:
	cat <<PEPPERS
	
	Do you want hot cherry peppers?
	1) No           3) Regular
	2) Go easy      4) Extra
	PEPPERS

choose-peppers:
	$(eval peppers = $(shell read -p 'peppers> '; echo $$REPLY))
	$(if $(filter-out $(peppers-opts), $(peppers)),
	 $(eval peppers = $(shell $(MAKE) choose-peppers-recurse)))
	$(eval peppers = $(word $(peppers), $(peppers_IDS)))

choose-peppers-recurse:
	$(eval peppers = $(shell read -p 'peppers> '; echo $$REPLY))
	$(if $(filter-out $(peppers-opts), $(peppers)),
	 $(eval peppers = $(shell $(MAKE) choose-peppers-recurse)))
	$(info $(peppers))


## Tomatoes - the default is Regular Tomatoes
tomatoes = 23258

define TOMATOES_IDS
	23256 23259 23258 23260
endef

tomatoes-opts = 1 2 3 4

pc-tomatoes: prompt-tomatoes choose-tomatoes

prompt-tomatoes:
	cat <<TOMATOES
	
	Would you like tomatoes?
	1) No           3) Regular
	2) Go easy      4) Extra
	TOMATOES

choose-tomatoes:
	$(eval tomatoes = $(shell read -p 'tomatoes> '; echo $$REPLY))
	$(if $(filter-out $(tomatoes-opts), $(tomatoes)),
	 $(eval tomatoes = $(shell $(MAKE) choose-tomatoes-recurse)))
	$(eval tomatoes = $(word $(tomatoes), $(TOMATOES_IDS)))

choose-tomatoes-recurse:
	$(eval tomatoes = $(shell read -p 'tomatoes> '; echo $$REPLY))
	$(if $(filter-out $(tomatoes-opts), $(tomatoes)),
	 $(eval tomatoes = $(shell $(MAKE) choose-tomatoes-recurse)))
	$(info $(tomatoes))


## Onions - the default is No Onions
onions = 23559

define ONIONS_IDS
	23559 23314 23312 23315
endef

onions-opts = 1 2 3 4

pc-onions: prompt-onions choose-onions

prompt-onions:
	cat <<ONIONS
	
	How about onions?
	1) No           3) Regular
	2) Go easy      4) Extra
	ONIONS

choose-onions:
	$(eval onions = $(shell read -p 'onions> '; echo $$REPLY))
	$(if $(filter-out $(onions-opts), $(onions)),
	 $(eval onions = $(shell $(MAKE) choose-onions-recurse)))
	$(eval onions = $(word $(onions), $(ONIONS_IDS)))

choose-onions-recurse:
	$(eval onions = $(shell read -p 'onions> '; echo $$REPLY))
	$(if $(filter-out $(onions-opts), $(onions)),
	 $(eval onions = $(shell $(MAKE) choose-onions-recurse)))
	$(info $(onions))


## Selecting your chips
chips-opts = 0 1 2 3 4 5

define CHIPS_IDS
	23223 23222 23221 23220 23403
endef

define CHIPS_JSON
      "NoMayo" : false,
      "ItemCost" : 0,
      "RewardNotes" : "",
      "CanDelete" : false,
      "FavoriteName" : null,
      "ExtendedPrice" : 0,
      "Modifiers" : [
         {
            "EditItem" : false,
            "SelectedAnswerId" : "$(chips)",
            "SelectedAnswerText" : "",
            "GroupId" : "3882"
         }
      ],
      "DisplayPrice" : "",
      "DisplayText" : "",
      "IsMainCouponItem" : false,
      "ConfirmedSprouts" : false,
      "Label" : "",
      "Index" : "",
      "Quantity" : 1,
      "IsQuantityFixed" : false,
      "CouponReference" : "",
      "IsPriceFixed" : false,
      "CanEdit" : false,
      "SelectedSize" : "Per Bag",
      "IsSizeFixed" : false,
      "MustEdit" : false,
      "MenuItemText" : "Real Potato Chips",
      "MenuItemId" : "3725"
endef

pc-chips: prompt-chips choose-chips

prompt-chips:
	cat <<CHIPS
	
	Choose your chips:
	0) None                 3) BBQ
	1) Salt & Vinegar       4) Regular
	2) Jalapeno             5) Thinny
	CHIPS

choose-chips:
	$(eval chips = $(shell read -p 'chips> '; echo $$REPLY))
	$(if $(filter-out $(chips-opts), $(chips)),
	 $(eval chips = $(shell $(MAKE) choose-chips-recurse)))
	$(eval chips = $(subst 0,,$(chips)))
	$(if $(chips), $(eval chips = $(word $(chips), $(CHIPS_IDS))))

choose-chips-recurse:
	$(eval chips = $(shell read -p 'chips> '; echo $$REPLY))
	$(if $(filter-out $(chips-opts), $(chips)),
	 $(eval chips = $(shell $(MAKE) choose-chips-recurse)))
	$(info $(chips))



## Selecting a pickle
pickle-opts = 0 1 2 3

define PICKLE_IDS
	23597 23595 23596
endef

define PICKLE_JSON
      "MenuItemText" : "Jumbo Kosher Dill Pickle",
      "MenuItemId" : "3716",
      "IsSizeFixed" : false,
      "MustEdit" : false,
      "IsPriceFixed" : false,
      "CanEdit" : false,
      "CouponReference" : "",
      "SelectedSize" : "Regular",
      "IsQuantityFixed" : false,
      "Label" : "",
      "Quantity" : 1,
      "Index" : "",
      "DisplayText" : "",
      "DisplayPrice" : "",
      "ConfirmedSprouts" : false,
      "IsMainCouponItem" : false,
      "FavoriteName" : null,
      "RewardNotes" : "",
      "CanDelete" : false,
      "Modifiers" : [
         {
            "EditItem" : false,
            "GroupId" : "3943",
            "SelectedAnswerId" : "$(pickle)",
            "SelectedAnswerText" : ""
         }
      ],
      "ExtendedPrice" : 0,
      "ItemCost" : 0,
      "NoMayo" : false
endef

pc-pickle: prompt-pickle choose-pickle

prompt-pickle:
	cat <<PICKLE
	
	Do you want a pickle?
	0) None                 2) Halved
	1) Whole                3) Quartered
	PICKLE

choose-pickle:
	$(eval pickle = $(shell read -p 'pickle> '; echo $$REPLY))
	$(if $(filter-out $(pickle-opts), $(pickle)),
	 $(eval pickle = $(shell $(MAKE) choose-pickle-recurse)))
	$(eval pickle = $(subst 0,,$(pickle)))
	$(if $(pickle), $(eval pickle = $(word $(pickle), $(PICKLE_IDS))))

choose-pickle-recurse:
	$(eval pickle = $(shell read -p 'pickle> '; echo $$REPLY))
	$(if $(filter-out $(pickle-opts), $(pickle)),
	 $(eval pickle = $(shell $(MAKE) choose-pickle-recurse)))
	$(info $(pickle))


get-tip-amount:
	$(if $(tip-amount), ,
	 $(eval tip-amount = $(shell read -p "Tip amount $$"; echo $$REPLY | tr -d '$$'))
	 $(if $(strip $(tip-amount)), ,
	  $(eval tip-amount = $(shell $(MAKE) get-tip-amount)))
	 $(info $(tip-amount)))


define CC_TYPE_TABLE
1) American Express       3) Mastercard              5) Diners
2) Visa                   4) Discover
endef

define CC_TYPE_IDS
	Amex Visa Mastercard Discover Diners
endef

get-CC_TYPE:
	$(if $(CC_TYPE), ,
	 $(info $(CC_TYPE_TABLE))
	 $(eval CC_TYPE = $(word $(shell $(MAKE) choose-CC_TYPE), $(CC_TYPE_IDS))))

choose-CC_TYPE:
	$(eval CC_TYPE = $(shell read -p 'Credit card Type> '; echo $$REPLY))
	$(if $(filter-out 1 2 3 4 5, $(CC_TYPE)),
	 $(eval CC_TYPE = $(shell $(MAKE) choose-CC_TYPE)))
	 $(info $(CC_TYPE))


get-JJ_LOCATION:
	$(if $(JJ_LOCATION), ,
	 $(eval JJ_LOCATION = $(shell read -p "Jimmy John's location #> "; echo $$REPLY))
	 $(if $(strip $(JJ_LOCATION)), ,
	  $(eval JJ_LOCATION = $(shell $(MAKE) get-JJ_LOCATION))))


get-DELIV_ADDR1:
	$(if $(DELIV_ADDR1), ,
	 $(eval DELIV_ADDR1 = $(shell read -p "Delivery address 1> "; echo $$REPLY))
	 $(if $(strip $(DELIV_ADDR1)), ,
	  $(eval DELIV_ADDR1 = $(shell $(MAKE) get-DELIV_ADDR1))))


get-DELIV_ADDR2:
	$(if $(DELIV_ADDR2), ,
	 $(eval DELIV_ADDR2 = $(shell read -p "Delivery address 2> "; echo $$REPLY))
	 $(if $(strip $(DELIV_ADDR2)), ,
	  $(eval DELIV_ADDR2 = $(shell $(MAKE) get-DELIV_ADDR2))))


get-DELIV_CITY:
	$(if $(DELIV_CITY), ,
	 $(eval DELIV_CITY = $(shell read -p "Delivery city> "; echo $$REPLY))
	 $(if $(strip $(DELIV_CITY)), ,
	  $(eval DELIV_CITY = $(shell $(MAKE) get-DELIV_CITY))))


get-DELIV_STATE:
	$(if $(DELIV_STATE), ,
	 $(eval DELIV_STATE = $(shell read -p "Delivery state> "; echo $$REPLY))
	 $(if $(strip $(DELIV_STATE)), ,
	  $(eval DELIV_STATE = $(shell $(MAKE) get-DELIV_STATE))))


get-DELIV_ZIP:
	$(if $(DELIV_ZIP), ,
	 $(eval DELIV_ZIP = $(shell read -p "Delivery ZIP> "; echo $$REPLY))
	 $(if $(strip $(DELIV_ZIP)), ,
	  $(eval DELIV_ZIP = $(shell $(MAKE) get-DELIV_ZIP))))


get-DELIV_COUNTRY:
	$(if $(DELIV_COUNTRY), ,
	 $(eval DELIV_COUNTRY = $(shell read -p "Delivery country> "; echo $$REPLY))
	 $(if $(strip $(DELIV_COUNTRY)), ,
	  $(eval DELIV_COUNTRY = $(shell $(MAKE) get-DELIV_COUNTRY))))


get-CONTACT_FIRSTNAME:
	$(if $(CONTACT_FIRSTNAME), ,
	 $(eval CONTACT_FIRSTNAME = $(shell read -p "Your first name> "; echo $$REPLY))
	 $(if $(strip $(CONTACT_FIRSTNAME)), ,
	  $(eval CONTACT_FIRSTNAME = $(shell $(MAKE) get-CONTACT_FIRSTNAME))))


get-CONTACT_LASTNAME:
	$(if $(CONTACT_LASTNAME), ,
	 $(eval CONTACT_LASTNAME = $(shell read -p "Your last name> "; echo $$REPLY))
	 $(if $(strip $(CONTACT_LASTNAME)), ,
	  $(eval CONTACT_LASTNAME = $(shell $(MAKE) get-CONTACT_LASTNAME))))


get-CONTACT_EMAIL:
	$(if $(CONTACT_EMAIL), ,
	 $(eval CONTACT_EMAIL = $(shell read -p "Your email address> "; echo $$REPLY))
	 $(if $(strip $(CONTACT_EMAIL)), ,
	  $(eval CONTACT_EMAIL = $(shell $(MAKE) get-CONTACT_EMAIL))))


get-CONTACT_PHONE:
	$(if $(CONTACT_PHONE), ,
	 $(eval CONTACT_PHONE = $(shell read -p "Your phone #> "; echo $$REPLY | tr -d ' ()-.'))
	 $(if $(strip $(CONTACT_PHONE)), ,
	  $(eval CONTACT_PHONE = $(shell $(MAKE) get-CONTACT_PHONE))))


get-PAYMENT_CODE:
	$(if $(PAYMENT_CODE), ,
	 $(eval PAYMENT_CODE = $(shell read -p "Payment type> "; echo $$REPLY))
	 $(if $(strip $(PAYMENT_CODE)), ,
	  $(eval PAYMENT_CODE = $(shell $(MAKE) get-PAYMENT_CODE))))


get-CC_NUM:
	$(if $(CC_NUM), ,
	 $(eval CC_NUM = $(shell read -p "Credit card #> "; echo $$REPLY | tr -d ' -'))
	 $(if $(strip $(CC_NUM)), ,
	  $(eval CC_NUM = $(shell $(MAKE) get-CC_NUM))))


get-CC_CVV:
	$(if $(CC_CVV), ,
	 $(eval CC_CVV = $(shell read -p "CVV security code> "; echo $$REPLY))
	 $(if $(strip $(CC_CVV)), ,
	  $(eval CC_CVV = $(shell $(MAKE) get-CC_CVV))))


get-CC_YEAR:
	$(if $(CC_YEAR), ,
	 $(eval CC_YEAR = $(shell read -p "CC expiration year (4 digits)> "; echo $$REPLY))
	 $(if $(strip $(CC_YEAR)), ,
	  $(eval CC_YEAR = $(shell $(MAKE) get-CC_YEAR))))


get-CC_MONTH:
	$(if $(CC_MONTH), ,
	 $(eval CC_MONTH = $(shell read -p "CC expiration month> "; echo $$REPLY))
	 $(if $(strip $(CC_MONTH)), ,
	  $(eval CC_MONTH = $(shell $(MAKE) get-CC_MONTH))))


get-CC_ADDR1:
	$(if $(CC_ADDR1), ,
	 $(eval CC_ADDR1 = $(shell read -p "Billing address 1> "; echo $$REPLY))
	 $(if $(strip $(CC_ADDR1)), ,
	  $(eval CC_ADDR1 = $(shell $(MAKE) get-CC_ADDR1))))


get-CC_ADDR2:
	$(if $(CC_ADDR2), ,
	 $(eval CC_ADDR2 = $(shell read -p "Billing address 2> "; echo $$REPLY))
	 $(if $(strip $(CC_ADDR2)), ,
	  $(eval CC_ADDR2 = $(shell $(MAKE) get-CC_ADDR2))))


get-CC_CITY:
	$(if $(CC_CITY), ,
	 $(eval CC_CITY = $(shell read -p "Billing city> "; echo $$REPLY))
	 $(if $(strip $(CC_CITY)), ,
	  $(eval CC_CITY = $(shell $(MAKE) get-CC_CITY))))


get-CC_STATE:
	$(if $(CC_STATE), ,
	 $(eval CC_STATE = $(shell read -p "Billing state> "; echo $$REPLY))
	 $(if $(strip $(CC_STATE)), ,
	  $(eval CC_STATE = $(shell $(MAKE) get-CC_STATE))))


get-CC_ZIP:
	$(if $(CC_ZIP), ,
	 $(eval CC_ZIP = $(shell read -p "Billing ZIP> "; echo $$REPLY))
	 $(if $(strip $(CC_ZIP)), ,
	  $(eval CC_ZIP = $(shell $(MAKE) get-CC_ZIP))))


get-CC_COUNTRY:
	$(if $(CC_COUNTRY), ,
	 $(eval CC_COUNTRY = $(shell read -p "Billing country> "; echo $$REPLY))
	 $(if $(strip $(CC_COUNTRY)), ,
	  $(eval CC_COUNTRY = $(shell $(MAKE) get-CC_COUNTRY))))
