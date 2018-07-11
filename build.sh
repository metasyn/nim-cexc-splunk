#!/bin/bash

nim c -d:release src/nim_cexc/handler.nim
cp src/nim_cexc/handler app/bin/handler
