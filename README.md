# Tweet activity
Monitor tweet activity per keyword and display this activity into a realtime horizon graph. This tool consists of a tweet collector and a web interface.

![Screenshot](http://rolandboon.com/drop/activity.jpg)

## Collector
The collector uses the [Twitter Public Streaming API](https://dev.twitter.com/docs/api/1.1/post/statuses/filter) to retrieve tweets. Due to the limitations of this API, there is a limit of 400 keywords that can be tracked simultaneously. The connection to the Streaming API reconnects following the twitter stream concepts thanks to the [immortal-ntwitter](https://github.com/horixon/immortal-ntwitter) implementation by Horixon. Retrieved tweets are stored with the event store [Cube](http://square.github.com/cube/) which is built on [MongoDB](http://www.mongodb.org/).

## Interface
The interface is a web interface powered by [Express](http://expressjs.com/) coded in [CoffeeScript](http://coffeescript.org), [Jade](http://jade-lang.com/) and [Stylus](http://learnboost.github.com/stylus/). Real time tweet activity graphs are displayed in the interface and new keyword groups can be added and removed. Keyword groups are defined by a title (for your own reference) and a set of keyword separated by a comma (,).

The real time horizon graphs are generated by [Cubism](http://square.github.com/cubism/) which is built on [D3](http://d3js.org/). The other interface elements are styled with [Bootstrap](http://twitter.github.com/bootstrap/). Real time interactions with the collector are performed by [socket.io](http://socket.io/).

## Requirements
This tool is developed and tested on

- Node.js v0.10.13
- NPM v1.3.2
- MongoDB v2.0.4

## Configure
You need to set your Twitter API keys in /src/collector.coffee.

The activity monitor requires 3 processes to be accessible by your browser and server. Cube's collector and evaluator listen by default on port 1080 and 1081. The interface defaults to port 1082.

One way to easily serve the 3 processes is to proxy them through Nginx (make sure to use version >= 1.3.13 to support WebSockets). A example configuration can be found [here](https://gist.github.com/rolandboon/6294381).

If you wish to change the defaults you need to modify /Cakefile, /src/collector.coffee, /src/index.coffee and /assets/js/app.coffee.

## Running
Clone this repository and install dependencies with npm install. Use the Cakefile to run all requirements processes.

## For internal use only
This tweet activity monitor is designed for internal use only. No access control is provided by this monitor, neither by the database interface Cube. Use a firewall are an authentication proxy to prevent unintended use.

## Exporting
Currently no nice interface is available to export activity data, however Cube's evaluator provides a extensive querying endpoint which returns JSON. See the [Cube wiki](https://github.com/square/cube/wiki/Evaluator) for more details.

Retrieving the latest collected tweets:
http://evaluator.example.com/1.0/event?expression=tweet(text)&limit=50

Retrieving aggregated activity counts for a keyword:
http://evaluator.example.com/1.0/metric?expression=sum(tweet.in(keyword%2C%20%5B"%23belieber"%5D))&start=2013-08-01T00:00:00.000Z&stop=2013-08-07T00:00:00.000Z&step=36e5