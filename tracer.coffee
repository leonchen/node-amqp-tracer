merge = require 'merge'
amqp = require 'amqp'
{ EventEmitter } = require 'events'

DEFAULT_CONFIG = require __dirname+'/config.default.json'
TRACE_EXCHANGE = 'amq.rabbitmq.trace'

class Tracer extends EventEmitter
  constructor: (config) ->
    config = config || {}
    @config = merge DEFAULT_CONFIG, config

    @conn = null
    @connected = false

    @connect()

  connect: ->
    {host, port, user, pass} = @config.amqp
    url = "amqp://#{user}:#{pass}@#{host}:#{port}"
    @conn = amqp.createConnection({url})

    @conn.on "ready", =>
      @connected = true
      @bindQueues()
      @emit "connect.ready"

    @conn.on "error", (err) =>
      @emit "connect.error", err

    @conn.on "close", =>
      @connected = false

  close: ->
    @conn.disconnect()
    @conn = null

  bindQueues: () ->
    {publish, deliver} = @config.queues
    @conn.queue publish.name, publish.options, (q) =>
      q.bind TRACE_EXCHANGE, publish.routingKey
      q.subscribe (message, headers, deliveryInfo, messageObject) =>
        @emit 'message.published', {message, headers, deliveryInfo, messageObject}

    @conn.queue deliver.name, deliver.options, (q) =>
      q.bind TRACE_EXCHANGE, deliver.routingKey
      q.subscribe (message, headers, deliveryInfo, messageObject) =>
        @emit 'message.delivered', {message, headers, deliveryInfo, messageObject}


module.exports = Tracer
