# Better although not to use default images
# since sometimes something unexpected
# can be added there, or keep built artifact
# in a private repo

FROM openjdk:8-jdk-alpine

ENV NAME=unknown
ENV SERVER_PORT=8080

# Avoid using root
RUN addgroup -S --gid 2000 java && \
    adduser -S -h /home/java -u 2000 -G java java

COPY --chown=java:java rootfs /

# There are other options as well:
# - s3 signed request
# - aws cli
# - checksum verification
# - multi stage build with "copy from"

ADD --chown=java:java \
    https://s3.amazonaws.com/tidal-fileshare-generic/187a5272-6044-4da6-af73-872efa342f1e/gs-spring-boot-0.1.0.jar \
    /opt/jars/

WORKDIR /opt/

RUN chmod -R +x scripts jars entrypoint.sh

USER java

EXPOSE $SERVER_PORT

# Minimum memory for the JVM
# ENV JAVA_MIN_MEM="-Xms"
# Maximum memory for the JVM
# ENV JAVA_MAX_MEM="-Xmx"
# Other opts
# ENV EXTRA_JAVA_OPTS=""

ENTRYPOINT ["/opt/entrypoint.sh"]
# as a point - we may use linter
# like dockerlint
