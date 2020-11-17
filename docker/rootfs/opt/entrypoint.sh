#!/bin/sh
exec java $JAVA_MIN_MEM $JAVA_MAX_MEM $EXTRA_JAVA_OPTS -jar jars/gs-spring-boot-0.1.0.jar
