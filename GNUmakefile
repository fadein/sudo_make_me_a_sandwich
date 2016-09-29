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



################################################################################
## User configuration
## Handcode values for questions you don't want to be asked each on each order
################################################################################

JJ_LOCATION=

# Delivery address
DELIV_ADDR1=358 Lauralin Drive
DELIV_ADDR2=
DELIV_CITY=Logan
DELIV_STATE=UT
DELIV_ZIP=84321
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
DRY_RUN=

################################################################################
## END User configuration
################################################################################

.ONESHELL:
.PHONY: me a banner TODO

# The base URL for Jimmy John's online store
BASE=https://online.jimmyjohns.com
GEOCODE=https://maps.googleapis.com/maps/api/geocode/json?address=


## Geocode the delivery address to find JJ's location
## TODO: we won't want to do all of this if JJ_LOCATION is already known

location: get-JJ_LOCATION
	$(info JJ_LOCATION is $(JJ_LOCATION))


get-JJ_LOCATION: prompt-LOCATIONS choose-JJ_LOCATION



LAT=41.7579498291
LNG=-111.83466339
debug-LAT_LNG: get-LAT_LNG
	@$(info "LAT is $(LAT) .. LNG is $(LNG)")



# split $(LOCATIONS) on their separators:
# display a prompt w/ address
# form a list of valid inputs
prompt-LOCATIONS: export RP=)
prompt-LOCATIONS: api-query-LOCATIONS get-LOCATIONS
	@$(foreach l,$(shell echo $(LOCATIONS) | tr @ \\n),
	@  $(info $(firstword $(subst _, ,$(l)))$(RP) $(wordlist 2,20,$(subst _, ,$(l)))))

get-LOCATIONS: api-query-LOCATIONS
	@$(foreach l,$(shell echo $(LOCATIONS) | tr @ \\n),
	@ $(eval VALID_LOC_ID = $(VALID_LOC_ID) $(firstword $(subst _, ,$(l)))))

choose-JJ_LOCATION:
	@$(eval JJ_LOCATION = $(shell read -p "$@ Jimmy John's location #> "; echo $$REPLY))
	@$(if $(JJ_LOCATION), $(filter-out $(VALID_LOC_ID), $(JJ_LOCATION)),
	@ $(eval JJ_LOCATION = $(shell $(MAKE) choose-JJ_LOCATION-recurse VALID_LOC_ID="$(VALID_LOC_ID)")))

choose-JJ_LOCATION-recurse:
	@$(eval JJ_LOCATION = $(shell read -p "$@ Jimmy John's location #> "; echo $$REPLY))
	@$(warning $@ VALID_LOC_ID = $(VALID_LOC_ID))
	@$(if $(JJ_LOCATION), $(filter-out $(VALID_LOC_ID), $(JJ_LOCATION)),
	@ $(eval JJ_LOCATION = $(shell $(MAKE) choose-JJ_LOCATION-recurse VALID_LOC_ID="$(VALID_LOC_ID)")))
	@$(info $(JJ_LOCATION))


# guard this recipe body with an $(if ) on the value of LOCATIONS or perhaps even JJ_LOCATION
api-query-LOCATIONS: get-LAT_LNG
	$(eval LOCATIONS = $(shell cat locations.response |
	sed -e 's/[,{}]/\n/g' -e 's/:/ /g' | awk '
	BEGIN { id = addr = city = state = ""; FS = "\"" }
	{
	    if (NF == 0) {
	        if (id) { stores[id] = addr "_" city ",_" state }
	        id = addr = city = state = ""
	    }
	    else if ($$2 ~ "^Id")           { gsub(/ /, "", $$3);  id    = $$3 }
	    else if ($$2 ~ "^AddressLine1") { gsub(/ /, "_", $$4); addr  = $$4 }
	    else if ($$2 ~ "^City")         {                      city  = $$4 }
	    else if ($$2 ~ "^State")        {                      state = $$4 }
	}
	END {
	    ORS = "@"
	    OFS = "_"
	    if (id) { stores[id] = addr "_" city ",_" state }
	    for (s in stores) { print s, stores[s] }
	}
	'))

get-LAT_LNG:
	$(if $(and $(LAT), $(LNG)), ,
	@ $(eval ADDR_FOR_GEOCODE = $(shell echo $(DELIV_ADDR1) $(DELIV_ADDR2) $(DELIV_CITY) $(DELIV_STATE) $(DELIV_ZIP) | tr ' ' +))
	@ $(eval LATLNG = $(shell $(cURL) $(cURL_BASIC_OPTS) $(GEOCODE)$(ADDR_FOR_GEOCODE) | sed -e 's/[,{}]/\n/g' -e 's/:/ /g' | awk '
	@ {
	@     if (lat && lng)  { print lat " " lng;              exit }
	@     if ($$1 ~ "lat") { lat = $$2; sub(/,$$/, "", lat); next }
	@     if ($$1 ~ "lat") { lat = $$2; sub(/,$$/, "", lat); next }
	@     if ($$1 ~ "lng") { lng = $$2; sub(/,$$/, "", lng)       }
	@ }
	@ '))
	@ $(eval LAT = $(word 1, $(LATLNG)))
	@ $(eval LNG = $(word 2, $(LATLNG))))

