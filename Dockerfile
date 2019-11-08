FROM centos:8 AS build

ENV version=2.6.0

WORKDIR /tmp

RUN yum install -y bzip2 zlib-devel libcurl-devel gtk3-devel
RUN yum group install -y "Development Tools"
RUN curl -sL http://files.freeciv.org/stable/freeciv-$version.tar.bz2 | tar xjf -
RUN (cd freeciv-$version && ./configure --prefix=/freeciv && make install)
RUN rm /freeciv/bin/freeciv-gtk3

FROM centos:8
MAINTAINER Zoran Regvart <zregvart+freeciv@gmail.com>
LABEL mane="zregvart/freeciv" \
  maintainer="zregvart+freeciv@gmail.com" \
  version="$version" \
  summary="FreeCIV Server $version" \
  description="Freeciv is a single, and multiplayer, turn-based strategy game for workstations and personal computers inspired by the proprietary Sid Meier's Civilization series. It is available for most desktop computer operating systems and available in an online browser based version" \
  url="http://freeciv.org/" \
  io.k8s.description="FreeCIV Server $version" \
  io.k8s.display-name="FreeCIV Server $version" \
  io.openshift.expose-services="5556/tcp:freeciv" \
  io.openshift.tags="freeciv"

WORKDIR /freeciv
COPY --from=build /freeciv .
ADD uid_entrypoint /
USER 10001
ENTRYPOINT ["/uid_entrypoint"]
CMD /freeciv/bin/freeciv-server --log /dev/stdout
