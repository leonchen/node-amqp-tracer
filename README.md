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
````
Tracer = require 'amqp-tracer'
# checkout config.defualt.json for config options such as rabbitmq host/port
config = {}
tracer = new Tracer(config)
tracer.on 'connect.ready', (err) =>
  console.log "connected"

tracer.on 'connect.error', (err) =>
  console.warn err

tracer.on 'message.published', (data) ->
  console.log "published:", data.message

tracer.on 'message.delivered', (data) ->
  console.log "delivered:", data.message
````
