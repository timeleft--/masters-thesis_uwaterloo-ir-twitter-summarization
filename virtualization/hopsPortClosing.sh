#!/bin/bash
kill `ps aux | grep ssh.*L.*192.168.122.$1 | tr -s ' ' | cut -d ' ' -f 2`

