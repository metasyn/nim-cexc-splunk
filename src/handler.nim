import logging
from json import JsonNode, `$`, `%*`, getStr, `[]`
from strformat import fmt
from streams import newFileStream

from nim_cexc import run
from setupLogging import setupLogger

proc handleGetinfo(metadata: JsonNode, body: string): tuple[metadata: JsonNode, body: string] =
  ## Use this method to communicate back to the chunked protocol what kind of command we are.

  # %* is a macro to convert an expression to a JsonNode
  let returnMetadata = %* {"type": "events"}
  return (metadata: returnMetadata, body: "")

proc handleExecute(metadata: JsonNode, body: string): tuple[metadata: JsonNode, body: string] =
  ## Use this method to interact with and change the data that we return to the chunked protocol.
  let returnMetadata = %* {"finished": true}
  # Simply reflect
  return (metadata: returnMetadata, body: body)

proc handler(metadata: JsonNode, body: string): tuple[metadata: JsonNode, body: string] =
  let action = metadata["action"].getStr()
  # Handle the getinfo exchange
  if action == "getinfo":
    return handleGetinfo(metadata, body)

  # Handle the execute chunks
  if action == "execute":
    return handleExecute(metadata, body)

let 
  i = newFileStream(stdin)
  o = newFileStream(stdout)

if isMainModule:
  let myCommand = "foo"
  setupLogger(myCommand)
  # Now logging to "$SPLUNK_HOME/var/log/foo.log"
  # or ./foo.log if $SPLUNK_HOME isn't set
  debug(fmt"Starting {myCommand} command, written in nim!")
  run(i, o, handler)
  debug("Later skater!")