FROM debian:buster as build
RUN apt-get update && apt-get install --no-install-recommends -y \
  ca-certificates
RUN \
  echo "## Installing dependencies" && \
  apt-get update && apt-get -y install --no-install-recommends \
  build-essential git libsdl2-dev
RUN git clone https://github.com/ioquake/ioq3.git && \
    cd ioq3 && \
    make

FROM gcr.io/distroless/base-debian10
COPY --from=build /ioq3/build/release-linux-x86_64/baseq3  /ioq3/baseq3
COPY --from=build /ioq3/build/release-linux-x86_64/ioq3ded.x86_64 /ioq3/ioq3ded.x86_64
COPY pk3/*.pk3 /ioq3/baseq3/
COPY cfg/*.cfg /ioq3/baseq3/
COPY output/q3config_server.cfg /ioq3/baseq3/
EXPOSE 27960/udp
ENTRYPOINT [ "/ioq3/ioq3ded.x86_64", "+exec", "maprotation.cfg" ]
