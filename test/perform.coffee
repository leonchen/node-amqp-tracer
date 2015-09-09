Tracer = require '../tracer'
amqp = require 'amqplib/callback_api'
async = require 'async'

exchangeName = "tracer.test.exchange"
queueName = "tracer.test.queue"
routingKey = "performanceTestKey"

MESSAGES = [
 ["40B", new Buffer(JSON.stringify({ id: "testId", text:"this is a message" }))]
 ["5KB", new Buffer(JSON.stringify(require './5k.json'))]
 ["255KB", new Buffer(JSON.stringify(require './255k.json'))]
]

fin = (err) ->
  if err
    console.warn err
    process.exit(1)
  else
    console.log "done"
    # waiting for the delivered consuming to be finished
    # setTimeout ->
    #   process.exit(0)
    # , 10000

benchmark = (url) ->
  ch = null
  async.waterfall [
    (cb) ->
      amqp.connect url, cb
    (conn, cb) ->
      conn.createChannel cb
    (channel, cb) ->
      ch = channel
      ch.assertExchange exchangeName, "topic", {}, cb
    (ok, cb) ->
      ch.assertQueue queueName, {}, cb
    (ok, cb) ->
      ch.bindQueue queueName, exchangeName, routingKey, {}, cb
  ], (err) ->
    return fin(err) if err

    console.log "size\ttimes\ttotal(ms)\tdpm(ms)\trps"
    async.eachSeries [1000, 5000, 10000], (times, cb) ->
      async.eachSeries MESSAGES, (msg, cb) ->
        traceName = "#{msg[0]}\t#{times}"
        c = 0
        start = null
        ch.consume queueName, (msg) ->
          ch.ack(msg)
          c++
          if c == times
            #console.timeEnd(traceName)
            d = Date.now()-start
            console.log "#{traceName}\t#{d}\t#{d/times}\t#{parseInt(1000*times/d)}"
            ch.cancel(msg.fields.consumerTag)
            cb()
        , {}, (err, ok) ->
          return fin(err) if err

        # publish messages
        start = Date.now()
        #console.time(traceName)
        for _ in [1..times]
          ch.publish exchangeName, routingKey, msg[1], {contentType: "application/json"}
      , cb
    , fin
        

tracer = new Tracer()
tracer.on 'channel.ready', ->
  benchmark(tracer.serverUrl)

tracer.on 'message.published', (data) ->

tracer.on 'message.delivered', (data) ->
  
tracer.on 'channel.close', ->
  console.log "channel closed"

tracer.on 'error', (err) ->
  fin(err)
