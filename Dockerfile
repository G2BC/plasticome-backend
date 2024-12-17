FROM docker:24.0.2-dind as builder
USER root
ENV DEBIAN_FRONTEND=noninteractive
COPY . /app
WORKDIR /app

RUN apk update && apk add --no-cache \
  ca-certificates \
  curl \
  bash \
  tzdata \
  build-base \
  python3 \
  python3-dev \
  libffi-dev \
  openssl-dev \
  musl-dev \
  gcc \
  make \
  docker-cli \
  zlib \
  bzip2 \
  libgcc \
  libstdc++ \
  libgomp \
  gcompat 

# RUN apk add --no-cache bash curl binutils \
#     && curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
#     && curl -Lo /glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-2.35-r0.apk \
#     && curl -Lo /glibc-bin.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-bin-2.35-r0.apk \
#     && apk add --no-cache --force-overwrite /glibc.apk /glibc-bin.apk \
#     && rm /glibc.apk /glibc-bin.apk

# RUN curl -o ncbi-blast.tar.gz https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.16.0+-x64-linux.tar.gz && \
#   tar -xzvf ncbi-blast.tar.gz && \
#   rm ncbi-blast.tar.gz
# ENV BLAST_PATH="/app/ncbi-blast-2.16.0+/bin"
# ENV PATH="${BLAST_PATH}:${PATH}"

RUN curl -o fam-substrate-mapping-08012023.tsv https://bcb.unl.edu/dbCAN2/download/Databases/fam-substrate-mapping-08012023.tsv && \
  mv fam-substrate-mapping-08012023.tsv fam-substrate-mapping.tsv

ENV POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_CREATE=false \
  POETRY_CACHE_DIR='/var/cache/pypoetry' \
  POETRY_HOME='/usr/local' \
  POETRY_VERSION=1.5.1

RUN curl -sSL https://install.python-poetry.org | python3 -
RUN poetry install --no-root
RUN chmod +x /app/start.sh
RUN dos2unix /app/start.sh
RUN chmod +x /app/run_flask.sh
RUN dos2unix /app/run_flask.sh
ENV FLASK_APP=plasticome.routes.app.py
FROM builder as runner
CMD [ "/bin/bash", "/app/start.sh" ]
