#!/bin/sh -x
./ps &
redis-server --port 8888 &
perl stylehouse.pl
