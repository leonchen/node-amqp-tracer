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
Example:

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
  console.log "published:", data

tracer.on 'message.delivered', (data) ->
  console.log "delivered:", data
````
### Events
* **connect.ready**
  
  Connection is established
* **connect.error**

  see [amqplib doc](http://www.squaremobius.net/amqp.node/doc/channel_api.html), Note that **connection.close** will be emit too after this.
* **connect.close**
  
  see [amqplib doc](http://www.squaremobius.net/amqp.node/doc/channel_api.html). For error caused closing(not manually closing), tracer will try to reconnect.
* **connect.blocked**

  see [amqplib doc](http://www.squaremobius.net/amqp.node/doc/channel_api.html)
* **connect.unblocked**

  see [amqplib doc](http://www.squaremobius.net/amqp.node/doc/channel_api.html)
* **channel.ready**

  channel is created
* **channel.error**

  see [amqplib doc](http://www.squaremobius.net/amqp.node/doc/channel_api.html)
* **channel.close**

  see [amqplib doc](http://www.squaremobius.net/amqp.node/doc/channel_api.html)
* **channel.return**

  see [amqplib doc](http://www.squaremobius.net/amqp.node/doc/channel_api.html)
* **channel.drain**

  see [amqplib doc](http://www.squaremobius.net/amqp.node/doc/channel_api.html)
* **consume.publish.start**
  
  starts consuming publish queue
* **consume.deliver.start**

  starts consuming deliver queue
* **message.published**

  message received on publish queue
* **message.delivered**

  message received on deliver queue
* **ready**

  successfully connected and consuming
* **error**

  failed to connect or consume
* **purge.error**

  calling tracer.purge failed
* **close.error**

  close tracer.close failed
  
### Methods
#### tracer.purge
Most likely used for cleaning existing data when running tests
#### tracer.close
Manually stop consuming the publish/deliver queues and close the channel/connection. Note that this will also emit **channel.close** and **connect.close** events.