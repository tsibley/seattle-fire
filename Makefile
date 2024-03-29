SHELL := /bin/bash
export SHELLOPTS := errexit:pipefail

all: data/apparatus-locations.csv data/active-incidents.tsv

.PHONY: data/active-incidents.tsv
data/active-incidents.tsv:
	./fetch-incidents > $@.new
	mv $@.new $@

data/apparatus-locations.csv: data/sources/wikipedia.tsv
	recs fromcsv -d $$'\t' --header $< \
		| recs decollate --dldeagg '_split(units, qr/, */, apparatus)' \
		| recs xform '{{apparatus_note}} = $$1 if {{apparatus}} =~ s/ +\((.+?)\)$$//' \
		| recs tocsv -k apparatus,station,apparatus_note \
		> $@

publish:
	rsync -av --no-owner --no-group --delete \
		--chmod=u=rwX,og=rX \
		--exclude='.git*' \
		--exclude=data/active-incidents.tsv{,.new} \
		--exclude=.update-incidents.error \
		. tsibley.net:www/seattle/fire/
