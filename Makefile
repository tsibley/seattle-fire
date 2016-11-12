SHELL := /bin/bash
export SHELLOPTS := errexit:pipefail

data/apparatus-stations-geocoded.csv: data/apparatus-locations.csv data/stations-geocoded.csv
	recs join --left station station \
		<(recs fromcsv --header $(firstword $^)) \
		<(recs fromcsv --header $(lastword $^)) \
			| recs sort -k apparatus \
			| recs tocsv -k apparatus,station,address,lon,lat \
			> $@
