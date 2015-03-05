#!/bin/sh -x
./ps &
redis-server --port 8888 &
