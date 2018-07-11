#!/bin/bash

nim c -d:release src/cexc/handler.nim
cp src/cexc/handler app/bin/handler