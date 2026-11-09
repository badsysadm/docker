build: get convert refresh

get:
	python3 ./connectors/nvd/import.py
	python3 ./connectors/debian/import.py
	python3 ./connectors/bdu/import.py
	python3 ./connectors/kubernetes/import.py
	python3 ./connectors/chainguard/import.py

convert:
	python3 ./connectors/nvd/converter.py
	python3 ./connectors/debian/converter.py
	python3 ./connectors/bdu/converter.py
	python3 ./connectors/kubernetes/converter.py
	python3 ./connectors/chainguard/converter.py

merge:
	LC_ALL=C sort -u -o .buildcve/merged-purl.txt \
		.buildcve/nvd-purl.txt \
		.buildcve/debian-purl.txt \
		.buildcve/fstec-purl.txt \
		.buildcve/kubernetes-purl.txt \
		.buildcve/chainguard-purl.txt

refresh: merge
	python3 ./refresh.py

install:
	install -D -m 755 dpkg-cvecheck.py $(DESTDIR)/usr/bin/dpkg-cvecheck
	install -D -m 644 .buildcve/merged-purl.txt $(DESTDIR)/var/lib/cve/db.txt

clean:
	rm -rf .buildcve

verify:
	python3 ./dpkg-cvecheck.py
