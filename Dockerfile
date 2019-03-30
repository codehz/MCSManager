FROM codehz/archlinux:latest as builder

WORKDIR /data
LABEL maintainer=codehz
ARG TARGETS="nodejs npm cmake make docker jq binutils base-devel git util-linux systemd-libs"

RUN pacman -Syu --needed --noconfirm python pyalpm rsync ${TARGETS}
RUN python /dump.py ${TARGETS} > /list
RUN rsync -avih --exclude '*/' --files-from=/list / /data && cp /packager.sh /data

FROM scratch as node

COPY --from=builder /data /
ADD . /data/app
WORKDIR /data/app
RUN npm install --production
RUN /packager.sh -d /usr/bin/node /build
RUN /packager.sh -d /usr/bin/docker /build

FROM scratch

WORKDIR /data
COPY --from=node / /
CMD npm start