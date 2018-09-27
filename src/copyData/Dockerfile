FROM hseeberger/scala-sbt as build
WORKDIR /opt/input
COPY . .
RUN sbt clean package

FROM jamesrcounts/spark:2.3.0 as final
RUN mkdir -p /opt/spark/jars
COPY --from=build /opt/input/target/scala-2.11/copy-data_2.11-0.1.0-SNAPSHOT.jar /opt/spark/jars
