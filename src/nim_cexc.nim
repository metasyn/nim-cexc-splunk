# Copyright Alexander Johnson
# A chunked execution protocol base for Splunk custom search commands.
from strutils import parseInt, repeat
from strformat import fmt, `&`
from json import JsonNode, `$`, parseJson, `%*`
from re import `=~`, `re`
from logging import error, debug
import streams
from os import sleep

import setupLogging

let emptyChunk = (metadata: %* "", body: "", eof: true)

proc parseHeader(h: string): tuple[metadataLength: int, bodyLength: int] =
  let headerRegex = re"chunked\s+1.0,(?P<metadataLength>\d+),(?P<bodyLength>\d+)"
  var
    metadataLength: int
    bodyLength: int
  if h =~ headerRegex:
    metadataLength = parseInt(matches[0])
    bodyLength = parseInt(matches[1])
  else:
    raise newException(ValueError, fmt"Unable to parse header: {h}")
  return (metadataLength, bodyLength)

proc readChunk(i: Stream): tuple[metadata: JsonNode, body: string, eof: bool] =
  # Read header up to 256 bytes
  var header = newStringOfCap(256).TaintedString 
  let ok = i.readLine(header)
  
  if not ok:
    return emptyChunk
  
  # Parse lengths
  let (metadataLength, bodyLength) = parseHeader(header)

  # then read metadta & body in appropriate buffers
  let 
    metadata = i.readStr(metadataLength)
    body = i.readStr(bodyLength)

  # Convert metadata to json
  let jsonMetadata = parseJson(metadata)
  return (metadata: jsonMetadata, body: body, eof: false)

proc writeChunk(o: Stream, jsonMetadata: JsonNode, body: string) =
  let 
    metadata = $jsonMetadata
    metadataLength = len(metadata) + 1 # for new line
    bodyLength = len(body)
    header = &"chunked 1.0,{metadataLength},{bodyLength}\n"
  # The writeLine here (and its inclusion of \n) is actually
  # crucial to ensure that the protocol will write when we expect.
  o.writeLine(header)
  o.writeLine(metadata)
  o.writeLine(body)
  o.flush()

proc handleChunk(i: Stream, o: Stream, handler: proc): bool =
  # Read in new chunk
  let (metadata, body, eof) = readChunk(i)
  # Check if we are done
  if eof:
    return false

  # Invoke handler 
  let (returnMetadata, returnBody) = handler(metadata, body)

  # Write return chunk
  writeChunk(o, returnMetadata, returnBody)
  return true

proc run*(i: Stream, o: Stream, handler: proc) = 
  if not isNil(i) and not isNil(o):
    try:
      while handleChunk(i, o, handler):
        continue
    except:
      let 
        e = getCurrentException()
        msg = getCurrentExceptionMsg()
      error(&"Uncaught exception: {repr(e)}: {msg}")
  else:
    error(&"Input stream is nil. Cannot run.")