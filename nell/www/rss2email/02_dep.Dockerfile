ARG VERSION=3.14
ARG PYTHON_VERSION=3.14.7

FROM oci.badsysadm.local:80/src/www/rss2email:${VERSION} AS src_image
FROM 127.0.0.1:12670/pkg/dev/python3.14:${PYTHON_VERSION} AS python_image
FROM oci.badsysadm.local:80/get/dep:latest AS build

COPY debian ./debian/
RUN apt-get -qq update
RUN mk-build-deps --install --remove --tool 'apt-get -y -qq -o Dpkg::Options::="--force-confnew"'

COPY --from=python_image /usr/bin/python3.14 /usr/bin/python3.14
COPY --from=python_image /usr/lib/python3.14 /usr/lib/python3.14

RUN curl -fsSL https://bootstrap.pypa.io/get-pip.py | /usr/bin/python3.14
RUN /usr/bin/python3.14 -m pip install --no-cache-dir setuptools wheel

COPY --from=src_image /src/ /src/
WORKDIR /src/rss2email

RUN /usr/bin/python3.14 -m pip wheel --no-cache-dir \
    --wheel-dir /src/wheels "feedparser>=6.0.5" "html2text>=2020.1.16"
RUN /usr/bin/python3.14 setup.py bdist_wheel --dist-dir /src/wheels
