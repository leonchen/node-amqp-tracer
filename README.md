# node-amqp-tracer
The trace/firehose feature of RabbitMQ is very useful for debugging, and it can be more than that.

## Install
````
npm install amqp-tracer
````

## Usage
````
Tracer = require '../tracer'
# checkout config.defualt.json for config options such as RabbitMq host/port
config = {}
tracer = new Tracer(config)
tracer.on 'message.published', (data) ->
  console.log "published:", data.message

tracer.on 'message.delivered', (data) ->
  console.log "delivered:", data.message

tracer.on 'connect.error', (err) =>
  console.warn err
````