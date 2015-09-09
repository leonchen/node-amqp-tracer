# node-amqp-tracer
The trace/firehose feature of RabbitMQ is very useful for debugging, and it can be more than that.

## Install
make sure tracing is enabled for rabbitmq through rabbitmqctl(you will need to run this command everytime when rabbitmq server restarts):
````
rabbitmqctl trace_on
````
and then install this module:
````
npm install amqp-tracer
````

## Usage
For all the available events, please check out tracer.coffee.

````
Tracer = require 'amqp-tracer'
# checkout config.defualt.json for config options such as rabbitmq host/port
config = {}
tracer = new Tracer(config)
tracer.on 'ready', (err) =>
  console.log "tracer is ready"

tracer.on 'error', (err) =>
  console.warn "tracer error:", err

tracer.on 'message.published', (data) ->
  console.log "published:", data.message

tracer.on 'message.delivered', (data) ->
  console.log "delivered:", data.message
````
