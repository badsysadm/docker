build: get refresh

get:
	python3 ./main.py get
	python3 ./main.py convert

refresh:
	python3 ./main.py merge
	python3 ./main.py refresh

install:
	install -D -m 755 dpkg-cvecheck.py $(DESTDIR)/usr/bin/dpkg-cvecheck
	install -D -m 644 .buildcve/merged-purl.txt $(DESTDIR)/var/lib/cve/db.txt

clean:
	rm -rf .buildcve

verify:
	python3 ./main.py verify
