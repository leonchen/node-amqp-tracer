Tracer = require '../tracer'

d0 = { text:"this is a message" }
d1 = require './5k.json'
d2 = require './255k.json'
MSG = d1

times = 10000
c = pc = dc = 0
traceName = "trace"

exchangeName = "tracer.test.exchange"
queueName = "tracer.test.queue"
routingKey = "performanceTestKey"

tracer = new Tracer()
tracer.on 'connect.ready', ->
  console.log "connected"

  # create exchange
  tracer.conn.exchange exchangeName, {durable: true, autoDelete: false}, (ex) ->
    console.log "exchange declared"

    # create consumer queue and bind to exchange
    tracer.conn.queue queueName, {durable: true, autoDelete: false}, (q) ->
      console.log "connect to sub queue"
      q.bind exchangeName, routingKey, ->
        q.subscribe (message) ->
          console.log "consumed"
          c++
          if c == times
            console.timeEnd(traceName)

        # publish messages
        console.log "publishing #{times} messages"
        console.time(traceName)
        for idx in [1..times]
          ex.publish routingKey, MSG, {}, ->


tracer.on 'message.published', (data) ->
  console.log "published"
  pc++
  if pc == times
    console.log "publish trace done"

tracer.on 'message.delivered', (data) ->
  console.log "delivered"
  dc++
  if dc == times
    console.log "deliver trace done"

tracer.on 'connect.error', (err) =>
  console.warn err
  process.exit(1)
