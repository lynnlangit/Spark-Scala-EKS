FROM hseeberger/scala-sbt:latest AS base

WORKDIR /opt/input
COPY build.sbt ./

WORKDIR /opt/input/project
COPY project/build.properties ./

WORKDIR /opt/input
RUN sbt reload

COPY . .
RUN sbt clean package

FROM jamesrcounts/spark:2.3.0 as final
RUN mkdir -p /opt/spark/jars
COPY --from=build /opt/input/target/scala-2.11/hello-kubernetes_2.11-0.1.jar /opt/spark/jars
