Tracer = require '../tracer'

d1 = require './5k.json'
d2 = require './255k.json'
MSG = d1

times = 1000
c = pc = dc = 0
traceName = "trace"

tracer = new Tracer()
tracer.on 'connect.ready', ->
  console.log "connected"
  tracer.conn.queue "dev.test", {durable: true, autoDelete: false}, (q) ->
    console.log "connect to sub queue"
    q.subscribe (message) ->
      c++
      if c == times
        console.timeEnd(traceName)

  tracer.conn.exchange "dev.test", {durable: true, autoDelete: false}, (ex) ->
    console.log "publishing #{times} messages"
    console.time(traceName)
    for idx in [1..times]
      ex.publish "somekey", MSG, {}, ->

tracer.on 'message.published', (data) ->
  pc++
  if pc == times
    console.log "publish trace done"

tracer.on 'message.delivered', (data) ->
  dc++
  if dc == times
    console.log "deliver trace done"

tracer.on 'connect.error', (err) =>
  console.warn err
  process.exit(1)
