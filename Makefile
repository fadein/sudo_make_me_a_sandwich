# The MIT License (MIT)
#
# Copyright (c) 2016 Erik Falor
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.



## Configuration items
## Hardcode values for questions you don't want to be asked each on each order

# The JJ's store location number which can be found by looking for a "Location"
# element in the JSON sent to you in a response from online.jimmyjohns.com.
# This is NOT the same as the store number found on your receipt (that would be
# too easy :)
#
# Perhaps the easiest way to discover this ID number is to visit
# online.jimmyjohns.com in your browser with the developer tools enabled.  Get
# into the view which shows you each URI request the browser makes as you
# traverse their pages. Start a delivery order and enter your address. JJ's will
# ask you to verify your address. The locationId parameter will appear in a GET
# request to the API/Location/ resource
# (e.g. https://online.jimmyjohns.com/API/Location/?locationId=2144).
JJ_LOCATION=

# Delivery address
DELIV_ADDR1=
DELIV_ADDR2=
DELIV_CITY=
DELIV_STATE=
DELIV_ZIP=
DELIV_COUNTRY=USA

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
DRY_RUN=1


# The base URL for Jimmy John's online store
BASE=https://online.jimmyjohns.com
GEOCODE=https://maps.googleapis.com/maps/api/geocode/xml?address=

#SHELL = /home/fadein/scripts/sh
.ONESHELL:
.PHONY: me a banner TODO echo-info

# helper macro to search $PATH for an executable
which = $(firstword $(wildcard $(addsuffix /$(1),$(subst :, ,$(PATH)))))

# cURL stuff - don't change unless you know what you're doing
cURL = $(call which,curl)
cURL_BASIC_OPTS = --progress-bar --fail
cURL_OPTS = $(cURL_BASIC_OPTS) --include -w '%{response_code}'                              \
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

# xmllint is used if/when you geocode your address into lat/long to find the nearest JJ's
XMLLINT = $(call which,xmllint)

# Shut up about which directory we're in
MAKEFLAGS += --no-print-directory

ifdef DEBUG
MAKEFLAGS += DEBUG=$(DEBUG)
cURL_OPTS += --trace-ascii -
endif

define TODO
_ Geocode addresses
_ Return your JJ's location IDs
_ I have *-recurse targets for the menu items; I also need to do that
  for the billing info. If I don't get an input on the 1st attempt, the 2nd
  and subsequent attempts won't really pass back their captured values
_ query ADDR2 fields only when the corresponding ADDR1 was also blank
_ Support JJ's gift cards
endef

ifeq ($(DRY_RUN),)
TARGETS = banner has-curl choose make-cookie-jar place-order submit-order success cleanup-cookie-jar
else
TARGETS = banner has-curl choose echo-info make-cookie-jar place-order dry-run-success cleanup-cookie-jar
endif

all:
	@echo You must be new here. Go check this out:
	@echo     http://xkcd.com/149/

me a: ; @:

sandwich:
ifneq ($(shell uname), CYGWIN_NT-6.1)

ifneq ($(USER),root)
	@echo What? Make it yourself.
else
	@echo Okay
	sudo -u $(SUDO_USER) $(MAKE) $(MAKEFLAGS) $(TARGETS)
endif

else
	@echo Okay
	$(MAKE) $(MAKEFLAGS) $(TARGETS)
endif


TODO: ; $(info $(TODO)) @:

banner: ; $(info $(BANNER)) @:

define BANNER =
         ________________________  _______________________
        (      .         .   `   `;  .     .              )
       (   .         .           ;    ,        .           )
      (__________________________,__________________________)
      {{ {{ {{ {{ {{ {{  {{   {{   }}  }} {{ {{ }} {{ { }} }}
       {{ {{ {{~~~ {~~{{~~{{`~~,}}  }}  }} }} {{ }} {{ }} }}
     {{ {{ {{~~~~~~~~~  {{`~~,}}  }} ,~~~~~'  `~~~~~, } }}
         `~~~~~' `~~'   `~~   ~~~`~~~ (=======) `~~, (===)~~` __   ___  
     `~~~~~(=========) ~~~~~~`  ,~~~~~~`    (=====) ,~~~~`   /_ | |__ \ 
      (=======)~___~(=====)~~___ _~~(=========)~~__~~(======)_| |    ) |
       (  .   .         .  ,   `;       .      ,         )\ / / |   / / 
        (        ,          .   ;     ,           .     )\ V /| |_ / /_ 
         (_____________________,_______________________)  \_/ |_(_)____|
            use ctrl-c to exit
endef

define SUCCESS =
        _      _                                           _             
         `.   /    __.  ,   . .___         __.  .___    ___/   ___  .___ 
           `./   .'   \ |   | /   \      .'   \ /   \  /   | .'   ` /   \ 
           ,'    |    | |   | |   '      |    | |   ' ,'   | |----' |   '
        _-'       `._.' `._/| /           `._.' /     `___,' `.___, /    
                                                           `             
                                                 
                            ,  _  /   ___    ____
                            |  |  |  /   `  (    
                            `  ^  ' |    |  `--. 
                             \/ \/  `.__/| \___.'
                                                 
                                                       ,__         .  
         ____ ,   .   ___    ___    ___    ____   ____ /  ` ,   .  |  
        (     |   | .'   ` .'   ` .'   `  (      (     |__  |   |  |  
        `--.  |   | |      |      |----'  `--.   `--.  |    |   |  |  
       \___.' `._/|  `._.'  `._.' `.___, \___.' \___.' |    `._/| /\__
                                                       /              
endef

define DRY_RUN_SUCCESS =
                       _____.___.                    
                       \__  |   | ____  __ _________ 
                        /   |   |/  _ \|  |  \_  __ \ 
                        \____   (  <_> )  |  /|  | \/
                        / ______|\____/|____/ |__|   
                        \/                           
                .___                                            
              __| _/______ ___.__.         _______ __ __  ____  
             / __ |\_  __ <   |  |  ______ \_  __ \  |  \/    \ 
            / /_/ | |  | \/\___  | /_____/  |  | \/  |  /   |  \ 
            \____ | |__|   / ____|          |__|  |____/|___|  /
                 \/        \/                                \/ 
                                                          .___
                ________ __   ____  ____  ____   ____   __| _/
               /  ___/  |  \_/ ___\/ ___\/ __ \_/ __ \ / __ | 
               \___ \|  |  /\  \__\  \__\  ___/\  ___// /_/ | 
              /____  >____/  \___  >___  >___  >\___  >____ | 
                   \/            \/    \/    \/     \/     \/ 
endef

choose: pc-sandwich pc-chips pc-pickle pc-cookie get-JJ_LOCATION get-delivery-info get-contact-info get-payment-info
get-delivery-info: get-DELIV_ADDR1 get-DELIV_CITY get-DELIV_STATE get-DELIV_ZIP get-DELIV_COUNTRY
get-contact-info: get-CONTACT_FIRSTNAME get-CONTACT_LASTNAME get-CONTACT_EMAIL get-CONTACT_PHONE
get-payment-info: get-PAYMENT_CODE get-CC_NUM get-CC_TYPE get-CC_CVV get-CC_YEAR get-CC_MONTH get-CC_ADDR1 get-CC_CITY get-CC_STATE get-CC_ZIP get-CC_COUNTRY get-tip-amount
place-order: initial-requests negotiate-address schedule put-delivery-address post-items put-contact-info put-tip post-payment

make-cookie-jar:
	$(eval COOKIE_JAR = $(shell mktemp -t cookies.XXXXXX))

cleanup-cookie-jar:
	-@rm -f $(COOKIE_JAR)

has-curl:
	@$(if $(cURL),@:,
	@ $(error "I cannot find where your cURL is installed"))

initial-requests:
	$(cURL) $(cURL_OPTS) $(BASE)
	$(cURL) $(cURL_OPTS) $(BASE)/api/Customer/

echo-info:
	@cat <<:
	JJ_LOCATION=$(JJ_LOCATION)
	DELIV_ADDR1=$(DELIV_ADDR1)
	DELIV_ADDR2=$(DELIV_ADDR2)
	DELIV_CITY=$(DELIV_CITY)
	DELIV_STATE=$(DELIV_STATE)
	DELIV_ZIP=$(DELIV_ZIP)
	DELIV_COUNTRY=$(DELIV_COUNTRY)
	CONTACT_FIRSTNAME=$(CONTACT_FIRSTNAME)
	CONTACT_LASTNAME=$(CONTACT_LASTNAME)
	CONTACT_EMAIL=$(CONTACT_EMAIL)
	CONTACT_PHONE=$(CONTACT_PHONE)
	PAYMENT_CODE=$(PAYMENT_CODE)
	CC_NUM=$(CC_NUM)
	CC_TYPE=$(CC_TYPE)
	CC_CVV=$(CC_CVV)
	CC_YEAR=$(CC_YEAR)
	CC_MONTH=$(CC_MONTH)
	CC_ADDR1=$(CC_ADDR1)
	CC_ADDR2=$(CC_ADDR2)
	CC_CITY=$(CC_CITY)
	CC_STATE=$(CC_STATE)
	CC_ZIP=$(CC_ZIP)
	CC_COUNTRY=$(CC_COUNTRY)
	:
	sleep 10

negotiate-address: CheckForManualAddress ForDeliveryAddress VerifyDeliveryAddress
CheckForManualAddress VerifyDeliveryAddress: export METHOD=$(POST)
CheckForManualAddress VerifyDeliveryAddress: get-delivery-info
	cat <<: | $(cURL) $(METHOD) $(cURL_OPTS) $(BASE)/api/Order/$@/
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
	:


ForDeliveryAddress: export METHOD=$(POST)
ForDeliveryAddress: get-delivery-info
	cat <<: | $(cURL) $(METHOD) $(cURL_OPTS) $(BASE)/API/Location/$@/
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
	:


schedule: export METHOD=$(POST)
schedule: get-JJ_LOCATION
	cat <<: | $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Order/
	{
		"LocationId" : $(JJ_LOCATION),
		"OrderType" : "Delivery",
		"ScheduleTime" : "ASAP"
	}
	:

put-delivery-address: export METHOD=$(PUT)
put-delivery-address: get-delivery-info
	cat <<: | $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Order/DeliveryAddress/
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
	:

# Post your order; sandwich, chips and pickle
post-items: export METHOD=$(POST)
post-items: pc-sandwich pc-chips pc-pickle
	cat <<: | $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Order/Items/
	[
		{
			$(SANDWICH_JSON)
		},
		{
			$(CHIPS_JSON)
		},
		{
			$(PICKLE_JSON)
		},
		{
			$(COOKIE_JSON)
		}
	]
	:

# Submit the user's contact information, and opt out of marketing communications
put-contact-info: export METHOD=$(PUT)
put-contact-info: get-contact-info
	cat <<: | $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Order/ContactInfo/
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
	:

# Submit the tip
put-tip: export METHOD=$(PUT)
put-tip: get-tip-amount
	cat <<: | $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Payment/Tip/
	{
	    "TipAmount" : "$(tip-amount)",
	    "TipType" : "AMOUNT"
	}
	:

# Send off the billing information
post-payment: export METHOD=$(POST)
post-payment: get-payment-info
	cat <<: | $(cURL) $(METHOD) $(cURL_OPTS) $(CONTENT_TYPE_JSON) $(BASE)/api/Payment
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
	:

# This target clicks the "Submit" button
submit-order:
	$(cURL) $(cURL_OPTS) $(BASE)/api/Order/Submit/

success: ; $(info $(SUCCESS)) @:

dry-run-success: ; $(info $(DRY_RUN_SUCCESS)) @:

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
            "SelectedAnswerId" : "$(onions3021)",
            "SelectedAnswerText" : ""
         },
         {
            "EditItem" : false,
            "GroupId" : "3020",
            "SelectedAnswerId" : "$(onions3020)",
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
	@cat <<:
	
	Choose your sandwich:
	1)  Pepe                  7)  Smoked Ham Club        13) Gourmet Veggie Club
	2)  Big John              8)  Billy Club             14) Bootlegger Club
	3)  Totally Tuna          9)  Italian Night Club     15) Club Tuna
	4)  Turkey Tom            10) Hunters Club           16) Club Lulu
	5)  Vito                  11) Country Club           17) Ultimate Porker
	6)  The Veggie            12) Beach Club             18) J.J.B.L.T.
	19) The J.J. Gargantuan
	:

choose-sandwich:
	@$(eval sandwich = $(shell read -p 'sandwich> '; echo $$REPLY))
	@$(if $(filter-out $(sandwich-opts), $(sandwich)),
	@ $(eval sandwich = $(shell $(MAKE) choose-sandwich-recurse)))
	@$(eval sandwich = $(word $(sandwich), $(SANDWICH_IDS)))

choose-sandwich-recurse:
	@$(eval sandwich = $(shell read -p 'sandwich> '; echo $$REPLY))
	@$(if $(filter-out $(sandwich-opts), $(sandwich)),
	@ $(eval sandwich = $(shell $(MAKE) choose-sandwich-recurse)))
	@$(info $(sandwich))

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
	@cat <<:
	
	Do you want hot cherry peppers?
	1) No           3) Regular
	2) Go easy      4) Extra
	:

choose-peppers:
	@$(eval peppers = $(shell read -p 'peppers> '; echo $$REPLY))
	@$(if $(filter-out $(peppers-opts), $(peppers)),
	@ $(eval peppers = $(shell $(MAKE) choose-peppers-recurse)))
	@$(eval peppers = $(word $(peppers), $(PEPPERS_IDS)))

choose-peppers-recurse:
	@$(eval peppers = $(shell read -p 'peppers> '; echo $$REPLY))
	@$(if $(filter-out $(peppers-opts), $(peppers)),
	@ $(eval peppers = $(shell $(MAKE) choose-peppers-recurse)))
	@$(info $(peppers))


## Tomatoes - the default is Regular Tomatoes
tomatoes = 23258

define TOMATOES_IDS
	23256 23259 23258 23260
endef

tomatoes-opts = 1 2 3 4

pc-tomatoes: prompt-tomatoes choose-tomatoes

prompt-tomatoes:
	@cat <<:
	
	Would you like tomatoes?
	1) No           3) Regular
	2) Go easy      4) Extra
	:

choose-tomatoes:
	@$(eval tomatoes = $(shell read -p 'tomatoes> '; echo $$REPLY))
	@$(if $(filter-out $(tomatoes-opts), $(tomatoes)),
	@ $(eval tomatoes = $(shell $(MAKE) choose-tomatoes-recurse)))
	@$(eval tomatoes = $(word $(tomatoes), $(TOMATOES_IDS)))

choose-tomatoes-recurse:
	@$(eval tomatoes = $(shell read -p 'tomatoes> '; echo $$REPLY))
	@$(if $(filter-out $(tomatoes-opts), $(tomatoes)),
	@ $(eval tomatoes = $(shell $(MAKE) choose-tomatoes-recurse)))
	@$(info $(tomatoes))

## Onions - the default is No Onions
onions3021 = 23559
onions3020 = 23311

define ONIONS3021_IDS
	23559 23314 23312 23315
endef

define ONIONS3020_IDS
	23311 23314 23313 23315
endef

onions-opts = 1 2 3 4

pc-onions: prompt-onions choose-onions

prompt-onions:
	@cat <<:
	
	How about onions?
	1) No           3) Regular
	2) Go easy      4) Extra
	:

choose-onions:
	@$(eval onions = $(shell read -p 'onions> '; echo $$REPLY))
	@$(if $(filter-out $(onions-opts), $(onions)),
	@ $(eval onions = $(shell $(MAKE) choose-onions-recurse)))
	@$(eval onions3020 = $(word $(onions), $(ONIONS3020_IDS)))
	@$(eval onions3021 = $(word $(onions), $(ONIONS3021_IDS)))

choose-onions-recurse:
	@$(eval onions = $(shell read -p 'onions> '; echo $$REPLY))
	@$(if $(filter-out $(onions-opts), $(onions)),
	@ $(eval onions = $(shell $(MAKE) choose-onions-recurse)))
	@$(info $(onions))


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
	@cat <<:
	
	Choose your chips:
	0) None                 3) BBQ
	1) Salt & Vinegar       4) Regular
	2) Jalapeno             5) Thinny
	:

choose-chips:
	@$(eval chips = $(shell read -p 'chips> '; echo $$REPLY))
	@$(if $(filter-out $(chips-opts), $(chips)),
	@ $(eval chips = $(shell $(MAKE) choose-chips-recurse)))
	@$(eval chips = $(subst 0,,$(chips)))
	@$(if $(chips), $(eval chips = $(word $(chips), $(CHIPS_IDS))))

choose-chips-recurse:
	@$(eval chips = $(shell read -p 'chips> '; echo $$REPLY))
	@$(if $(filter-out $(chips-opts), $(chips)),
	@ $(eval chips = $(shell $(MAKE) choose-chips-recurse)))
	@$(info $(chips))



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
	@cat <<:
	
	Do you want a pickle?
	0) None                 2) Halved
	1) Whole                3) Quartered
	:

choose-pickle:
	@$(eval pickle = $(shell read -p 'pickle> '; echo $$REPLY))
	@$(if $(filter-out $(pickle-opts), $(pickle)),
	@ $(eval pickle = $(shell $(MAKE) choose-pickle-recurse)))
	@$(eval pickle = $(subst 0,,$(pickle)))
	@$(if $(pickle), $(eval pickle = $(word $(pickle), $(PICKLE_IDS))))

choose-pickle-recurse:
	@$(eval pickle = $(shell read -p 'pickle> '; echo $$REPLY))
	@$(if $(filter-out $(pickle-opts), $(pickle)),
	@ $(eval pickle = $(shell $(MAKE) choose-pickle-recurse)))
	@$(info $(pickle))

## Selecting a cookie
cookie-opts = 0 1 2

define COOKIE_IDS
	23550 23551
endef

define COOKIE_JSON
      "MenuItemText" : "Cookie",
      "MenuItemId" : "3884",
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
            "GroupId" : "3992",
            "SelectedAnswerId" : "$(cookie)",
            "SelectedAnswerText" : ""
         }
      ],
      "ExtendedPrice" : 0,
      "ItemCost" : 0,
      "NoMayo" : false
endef

pc-cookie: prompt-cookie choose-cookie

prompt-cookie:
	@cat <<:
	
	Do you want a cookie?
	0) None
	1) Chocolate Chunk
	2) Raisin Oatmeal
	:

choose-cookie:
	@$(eval cookie = $(shell read -p 'cookie> '; echo $$REPLY))
	@$(if $(filter-out $(cookie-opts), $(cookie)),
	@ $(eval cookie = $(shell $(MAKE) choose-cookie-recurse)))
	@$(eval cookie = $(subst 0,,$(cookie)))
	@$(if $(cookie), $(eval cookie = $(word $(cookie), $(COOKIE_IDS))))

choose-cookie-recurse:
	@$(eval cookie = $(shell read -p 'cookie> '; echo $$REPLY))
	@$(if $(filter-out $(cookie-opts), $(cookie)),
	@ $(eval cookie = $(shell $(MAKE) choose-cookie-recurse)))
	@$(info $(cookie))


get-tip-amount:
	@$(if $(tip-amount), ,
	@ $(eval tip-amount = $(shell read -p "Tip amount $$"; echo $$REPLY | tr -d '$$'))
	@ $(if $(strip $(tip-amount)), ,
	@  $(eval tip-amount = $(shell $(MAKE) get-tip-amount)))
	@ $(info $(tip-amount)))


define CC_TYPE_TABLE
1) American Express       3) Mastercard              5) Diners
2) Visa                   4) Discover
endef

define CC_TYPE_IDS
	Amex Visa Mastercard Discover Diners
endef

get-CC_TYPE:
	@$(if $(CC_TYPE), ,
	@ $(info $(CC_TYPE_TABLE))
	@ $(eval CC_TYPE = $(word $(shell $(MAKE) choose-CC_TYPE), $(CC_TYPE_IDS))))

choose-CC_TYPE:
	@$(eval CC_TYPE = $(shell read -p 'Credit card Type> '; echo $$REPLY))
	@$(if $(filter-out 1 2 3 4 5, $(CC_TYPE)),
	@ $(eval CC_TYPE = $(shell $(MAKE) choose-CC_TYPE)))
	@ $(info $(CC_TYPE))


get-JJ_LOCATION:
	@$(if $(JJ_LOCATION), ,
	@ $(eval JJ_LOCATION = $(shell read -p "Jimmy John's location #> "; echo $$REPLY))
	@ $(if $(strip $(JJ_LOCATION)), ,
	@  $(eval JJ_LOCATION = $(shell $(MAKE) get-JJ_LOCATION))))


get-DELIV_ADDR1:
	@$(if $(DELIV_ADDR1), ,
	@ $(eval DELIV_ADDR1 = $(shell read -p "Delivery address 1> "; echo $$REPLY))
	@ $(if $(strip $(DELIV_ADDR1)), ,
	@  $(eval DELIV_ADDR1 = $(shell $(MAKE) get-DELIV_ADDR1))))


get-DELIV_ADDR2:
	@$(if $(DELIV_ADDR2), ,
	@ $(eval DELIV_ADDR2 = $(shell read -p "Delivery address 2> "; echo $$REPLY))
	@ $(if $(strip $(DELIV_ADDR2)), ,
	@  $(eval DELIV_ADDR2 = $(shell $(MAKE) get-DELIV_ADDR2))))


get-DELIV_CITY:
	@$(if $(DELIV_CITY), ,
	@ $(eval DELIV_CITY = $(shell read -p "Delivery city> "; echo $$REPLY))
	@ $(if $(strip $(DELIV_CITY)), ,
	@  $(eval DELIV_CITY = $(shell $(MAKE) get-DELIV_CITY))))


get-DELIV_STATE:
	@$(if $(DELIV_STATE), ,
	@ $(eval DELIV_STATE = $(shell read -p "Delivery state> "; echo $$REPLY))
	@ $(if $(strip $(DELIV_STATE)), ,
	@  $(eval DELIV_STATE = $(shell $(MAKE) get-DELIV_STATE))))


get-DELIV_ZIP:
	@$(if $(DELIV_ZIP), ,
	@ $(eval DELIV_ZIP = $(shell read -p "Delivery ZIP> "; echo $$REPLY))
	@ $(if $(strip $(DELIV_ZIP)), ,
	@  $(eval DELIV_ZIP = $(shell $(MAKE) get-DELIV_ZIP))))


get-DELIV_COUNTRY:
	@$(if $(DELIV_COUNTRY), ,
	@ $(eval DELIV_COUNTRY = $(shell read -p "Delivery country> "; echo $$REPLY))
	@ $(if $(strip $(DELIV_COUNTRY)), ,
	@  $(eval DELIV_COUNTRY = $(shell $(MAKE) get-DELIV_COUNTRY))))


get-CONTACT_FIRSTNAME:
	@$(if $(CONTACT_FIRSTNAME), ,
	@ $(eval CONTACT_FIRSTNAME = $(shell read -p "Your first name> "; echo $$REPLY))
	@ $(if $(strip $(CONTACT_FIRSTNAME)), ,
	@  $(eval CONTACT_FIRSTNAME = $(shell $(MAKE) get-CONTACT_FIRSTNAME))))


get-CONTACT_LASTNAME:
	@$(if $(CONTACT_LASTNAME), ,
	@ $(eval CONTACT_LASTNAME = $(shell read -p "Your last name> "; echo $$REPLY))
	@ $(if $(strip $(CONTACT_LASTNAME)), ,
	@  $(eval CONTACT_LASTNAME = $(shell $(MAKE) get-CONTACT_LASTNAME))))


get-CONTACT_EMAIL:
	@$(if $(CONTACT_EMAIL), ,
	@ $(eval CONTACT_EMAIL = $(shell read -p "Your email address> "; echo $$REPLY))
	@ $(if $(strip $(CONTACT_EMAIL)), ,
	@  $(eval CONTACT_EMAIL = $(shell $(MAKE) get-CONTACT_EMAIL))))


get-CONTACT_PHONE:
	@$(if $(CONTACT_PHONE), ,
	@ $(eval CONTACT_PHONE = $(shell read -p "Your phone #> "; echo $$REPLY | tr -d ' ()-.'))
	@ $(if $(strip $(CONTACT_PHONE)), ,
	@  $(eval CONTACT_PHONE = $(shell $(MAKE) get-CONTACT_PHONE))))


get-PAYMENT_CODE:
	@$(if $(PAYMENT_CODE), ,
	@ $(eval PAYMENT_CODE = $(shell read -p "Payment type> "; echo $$REPLY))
	@ $(if $(strip $(PAYMENT_CODE)), ,
	@  $(eval PAYMENT_CODE = $(shell $(MAKE) get-PAYMENT_CODE))))


get-CC_NUM:
	@$(if $(CC_NUM), ,
	@ $(eval CC_NUM = $(shell read -p "Credit card #> "; echo $$REPLY | tr -d ' -'))
	@ $(if $(strip $(CC_NUM)), ,
	@  $(eval CC_NUM = $(shell $(MAKE) get-CC_NUM))))


get-CC_CVV:
	@$(if $(CC_CVV), ,
	@ $(eval CC_CVV = $(shell read -p "CVV security code> "; echo $$REPLY))
	@ $(if $(strip $(CC_CVV)), ,
	@  $(eval CC_CVV = $(shell $(MAKE) get-CC_CVV))))


get-CC_YEAR:
	@$(if $(CC_YEAR), ,
	@ $(eval CC_YEAR = $(shell read -p "CC expiration year (4 digits)> "; echo $$REPLY))
	@ $(if $(strip $(CC_YEAR)), ,
	@  $(eval CC_YEAR = $(shell $(MAKE) get-CC_YEAR))))


get-CC_MONTH:
	@$(if $(CC_MONTH), ,
	@ $(eval CC_MONTH = $(shell read -p "CC expiration month> "; echo $$REPLY))
	@ $(if $(strip $(CC_MONTH)), ,
	@  $(eval CC_MONTH = $(shell $(MAKE) get-CC_MONTH))))


get-CC_ADDR1:
	@$(if $(CC_ADDR1), ,
	@ $(eval CC_ADDR1 = $(shell read -p "Billing address 1> "; echo $$REPLY))
	@ $(if $(strip $(CC_ADDR1)), ,
	@  $(eval CC_ADDR1 = $(shell $(MAKE) get-CC_ADDR1))))


get-CC_ADDR2:
	@$(if $(CC_ADDR2), ,
	@ $(eval CC_ADDR2 = $(shell read -p "Billing address 2> "; echo $$REPLY))
	@ $(if $(strip $(CC_ADDR2)), ,
	@  $(eval CC_ADDR2 = $(shell $(MAKE) get-CC_ADDR2))))


get-CC_CITY:
	@$(if $(CC_CITY), ,
	@ $(eval CC_CITY = $(shell read -p "Billing city> "; echo $$REPLY))
	@ $(if $(strip $(CC_CITY)), ,
	@  $(eval CC_CITY = $(shell $(MAKE) get-CC_CITY))))


get-CC_STATE:
	@$(if $(CC_STATE), ,
	@ $(eval CC_STATE = $(shell read -p "Billing state> "; echo $$REPLY))
	@ $(if $(strip $(CC_STATE)), ,
	@  $(eval CC_STATE = $(shell $(MAKE) get-CC_STATE))))


get-CC_ZIP:
	@$(if $(CC_ZIP), ,
	@ $(eval CC_ZIP = $(shell read -p "Billing ZIP> "; echo $$REPLY))
	@ $(if $(strip $(CC_ZIP)), ,
	@  $(eval CC_ZIP = $(shell $(MAKE) get-CC_ZIP))))


get-CC_COUNTRY:
	@$(if $(CC_COUNTRY), ,
	@ $(eval CC_COUNTRY = $(shell read -p "Billing country> "; echo $$REPLY))
	@ $(if $(strip $(CC_COUNTRY)), ,
	@  $(eval CC_COUNTRY = $(shell $(MAKE) get-CC_COUNTRY))))

get-LAT_LONG: get-delivery-info geocode-delivery-info
	$(info "LAT is $(LAT) .. LNG is $(LNG)")

has-xmllint:
	@$(if $(XMLLINT),@:,
	@ $(error "I cannot find where your xmllint is installed"))

geocode-delivery-info: has-xmllint
	@$(eval GEOXML_TMP = $(shell mktemp -t geoxml_tmp.XXXXXX))
	@$(eval ADDR_FOR_GEOCODE = $(shell echo $(DELIV_ADDR1) $(DELIV_ADDR2) $(DELIV_CITY) $(DELIV_STATE) $(DELIV_ZIP) | tr ' ' +))
	@$(info Geocoding $(ADDR_FOR_GEOCODE))
	@$(eval $(shell $(cURL) $(cURL_BASIC_OPTS) $(GEOCODE)$(ADDR_FOR_GEOCODE) > $(GEOXML_TMP))
		LAT = $(shell xmllint --xpath 'GeocodeResponse/result/geometry/location/lat/child::text()' $(GEOXML_TMP));
		LNG = $(shell xmllint --xpath 'GeocodeResponse/result/geometry/location/lng/child::text()' $(GEOXML_TMP)))
	-@rm -f $(GEOXML_TMP)


get-SECRET:
	@$(if $(SECRET), ,
	@ $(eval SECRET = $(shell $(MAKE) quot-sh))
	@ $(if $(strip $(SECRET)), ,
	@  $(eval SECRET = $(shell $(MAKE) get-SECRET-recurse))))

## This proves that I should be recursing over all inputs
get-SECRET-recurse:
	@$(if $(SECRET), ,
	@ $(eval SECRET = $(shell $(MAKE) quot-sh))
	@ $(if $(strip $(SECRET)), ,
	@  $(eval SECRET = $(shell $(MAKE) get-SECRET-recurse))))
	@$(info $(SECRET))

gs:
	@$(eval SECRET = $(shell $(MAKE) gsr)) :

gsr:
	@$(if $(SECRET), ,
	@ $(eval SECRET = $(shell $(MAKE) quot-sh))
	@ $(if $(strip $(SECRET)), ,
	@  $(eval SECRET = $(shell $(MAKE) gsr))))
	@$(info $(SECRET))

define chiff0 =
$(3):
	@$(info $(0) $(1) $(2) <$(3)> $(4) $@ $^)
	@$$(if $$($(1)), ,
	@ $$(eval $(1) = $$(shell $(MAKE) $(4)))
	@ $$(if $(strip $$($(1))), ,
	@  $$(eval $(1) = $$(shell $(MAKE) $(3)))))
	@$$(info $(1))

$(2):
	$(info $(0) $(1) <$(2)> $(3) $(4) $@ $^)
	$(eval $(1) = $(shell $(MAKE) $(3)))) :
endef

#             $(0)   $(1)         $(2) $(3) $(4)
#$(eval $(call chiff0,SSEECCRREETT,SS11,SS22,get-CC_NUM))

try: SS11
	$(info $(SSEECCRREETT))

trycc: get-CC_NUM
	$(info $(CC_NUM))

trytom: pc-tomatoes
	$(info $(tomatoes))

quot-sh:
	@exec 3>&1 1>&2
	@echo -n "QUOT-SH> "
	@while IFS= read -r -s -n1 char; do
	@if [ "0$$char" = 0 ]; then
	@echo -n $$'\b''*'
	@break
	@else
	@case $$char in
	@|)
	@if [ "0$$password" != 0 ]; then
	@password=$$(echo $$password | sed 's/.$$//')
	@echo -n $$'\b' $$'\b'
	@fi ;;
	@*)
	@if [ "0$$password" != 0 ]; then
	@echo -n $$'\b'"*$$char"
	@else
	@echo -n $$char
	@fi
	@password=$${password}$${char} ;;
	@esac
	@fi
	@done
	@echo
	@exec 1>&3 3>&-
	@echo $$password


define TEMPLATE_ONE_RULE =
$(1):
	@$$(info now is the time, $(1)) :
endef
$(eval $(call TEMPLATE_ONE_RULE,jimmer))

define TEMPLATE_TWO_RULES =
$(1)_:
	@$$(info then was the time, $(1)_) :

$(1): $(1)_
	@$$(info this is the other rule $(1))
endef
$(eval $(call TEMPLATE_TWO_RULES,jammer))

define templet =
$(1)_:
	@$$(info snark comment is snarky) :

$(1):
	@$$(eval $(2) = $$(shell $(MAKE) $(1)_))
	@$$(info $(2) is $$($(2)))
endef
$(eval $(call templet,rulez,varz))

# vim: set iskeyword+=- :
