FROM jamesrcounts/spark:2.3.0 AS base
WORKDIR /opt
RUN mkdir -p /opt/ml

FROM hseeberger/scala-sbt:latest AS build-env

WORKDIR /opt/input

# Project Definition layers change less often than application code
COPY build.sbt ./

WORKDIR /opt/input/project
# COPY project/*.scala ./
COPY project/build.properties ./
COPY project/*.sbt ./

WORKDIR /opt/input
RUN sbt reload

# Copy rest of application
COPY . ./
RUN sbt clean package

FROM base AS final
RUN mkdir -p /opt/spark/jars
COPY --from=build-env /opt/input/target/scala-2.11/sagemaker-spark_2.11-0.1.jar  /opt/spark/jars