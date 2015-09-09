merge = require 'merge'
amqp = require 'amqplib'
co = require 'co'
{ EventEmitter } = require 'events'

DEFAULT_CONFIG = require __dirname+'/config.default.json'
TRACE_EXCHANGE = 'amq.rabbitmq.trace'

class Tracer extends EventEmitter
  constructor: (config) ->
    config = config || {}
    @config = merge DEFAULT_CONFIG, config

    @init()
    @connect()

  init: ->
    @serverUrl = null
    @conn = null
    @ch = null
    @publishConsumerTag = null
    @deliverConsumerTag = null
    @closing = false

  connect: ->
    co =>
      try
        {host, port, user, pass, vhost} = @config.amqp
        @serverUrl = "amqp://#{user}:#{pass}@#{host}:#{port}"
        @serverUrl += "/" + encodeURIComponent(vhost) if vhost
        @conn = yield amqp.connect(@serverUrl)
        @emit "connect.ready"
        @ch = yield @conn.createChannel()
        @emit "channel.ready"

        {publish, deliver} = @config.queues

        yield @ch.assertQueue publish.name, publish.options
        yield @ch.bindQueue publish.name, TRACE_EXCHANGE, publish.routingKey
        pc = yield @ch.consume publish.name, (msg) =>
          @ch.ack(msg)
          @emit 'message.published', msg
        @publishConsumerTag = pc.consumerTag
        @emit 'consume.publish.start', @publishConsumerTag

        yield @ch.assertQueue deliver.name, deliver.options
        yield @ch.bindQueue deliver.name, TRACE_EXCHANGE, deliver.routingKey
        dc = yield @ch.consume deliver.name, (msg) =>
          @ch.ack(msg)
          @emit 'message.delivered', msg
        @deliverConsumerTag = dc.consumerTag
        @emit 'consume.deliver.start', @deliverConsumerTag

        @conn.on 'error', (err) =>
          @emit "connect.error", err
        @conn.on "close", =>
          @emit "connect.close"
          @connect() unless @closing
        @conn.on 'blocked', (reason) =>
          @emit "connect.blocked", reason
        @conn.on 'unblocked', =>
          @emit "connect.unblocked"

        @ch.on "close", =>
          @emit "channel.close"
        @ch.on "error", (err) =>
          @emit "channel.error", err
        @ch.on 'return', (msg) =>
          @emit "channel.return", msg
        @ch.on 'drain', =>
          @emit "channel.drain", err

        @emit "ready"
      catch err
        @emit "error", err

  purge: ->
    co =>
      try
        {publish, deliver} = @config.queues
        yield @ch.purgeQueue publish.name
        yield @ch.purgeQueue deliver.name
      catch err
        @emit "purge.error", err
          
  close: ->
    co =>
      try
        @closing = true
        if @ch
          yield @ch.cancel(@publishConsumerTag) if @publishConsumerTag
          yield @ch.cancel(@deliverConsumerTag) if @deliverConsumerTag
          yield @ch.close()
        yield @conn.close() if @conn
      catch e
        @emit "close.error", e
      @init()

module.exports = Tracer
