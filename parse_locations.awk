
sed -e 's/[,{}]/\n/g' -e 's/:/ /g' locations.json | awk '
BEGIN { id = addr = city = state = ""; FS = "\"" }
{
	if (NF == 0) {
		if (id) { stores[id] = addr " " city ", " state }
		id = addr = city = state = ""
	}
	else if ($2 ~ "^Id")           { gsub(/ /, "", $3); id = $3 }
	else if ($2 ~ "^AddressLine1") { sub(/ /, "" $4); addr = $4 }
	else if ($2 ~ "^City")         { sub(/ /, "" $4); city = $4 }
	else if ($2 ~ "^State")        { sub(/ /, "" $4); state = $4 }
}
END {
	if (id) { stores[id] = addr " " city ", " state }
	for (s in stores) { print s " " stores[s] }
}
'
