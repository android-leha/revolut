#!/bin/bash -xe

curl -s -X PUT -d 'dateOfBirth=1986-01-19' http://localhost:8080/hello/alexey
curl -s -X PUT -d 'dateOfBirth=1987-06-04' http://localhost:8080/hello/anna
curl -s -X PUT -d 'dateOfBirth=2017-09-13' http://localhost:8080/hello/mark
curl -s -X PUT -d 'dateOfBirth=2019-11-30' http://localhost:8080/hello/today
curl -s -X PUT -d 'dateOfBirth=2017-12-01' http://localhost:8080/hello/tom

curl -s http://localhost:8080/hello/alexey
curl -s http://localhost:8080/hello/anna
curl -s http://localhost:8080/hello/mark
curl -s http://localhost:8080/hello/today
curl -s http://localhost:8080/hello/tom



#curl -X PUT -d 'dateOfBirth=1986-01-19' http://revolut-app/hello/alexey && \
#curl -X PUT -d 'dateOfBirth=1987-06-04' http://revolut-app/hello/anna && \
#curl -X PUT -d 'dateOfBirth=2017-09-13' http://revolut-app/hello/mark && \
#curl -X PUT -d 'dateOfBirth=2019-11-30' http://revolut-app/hello/today && \
#curl -X PUT -d 'dateOfBirth=2017-12-01' http://revolut-app/hello/tom
#
#curl -s http://revolut-app/hello/alexey
#curl -s http://revolut-app/hello/anna
#curl -s http://revolut-app/hello/mark
#curl -s http://revolut-app/hello/today
#curl -s http://revolut-app/hello/tom