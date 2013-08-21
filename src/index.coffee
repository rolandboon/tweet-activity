http = require 'http'
express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
io = require 'socket.io'
collector = require __dirname + '/collector.js'

app = express()
app.port = 1082

app.use assets()
app.use express.static(process.cwd() + '/public')

app.set 'view engine', 'jade'
app.use express.bodyParser()

app.enable 'trust proxy'

routes = require './routes'
routes(app)

app.start = ->
  server = http.createServer(app)
  io = io.listen(server)
    .enable('browser client minification')
    .enable('browser client etag')
    .enable('browser client gzip')
    .set('log level', 1)
    .set('transports', ['websocket', 'htmlfile', 'xhr-polling'])

  io.sockets.on('connection', (socket) ->
    socket.on 'init', ->
      socket.emit('keywords', collector.keywords)

    socket.on 'addKeyword', (data) ->
      collector.addKeyword(data.title, data.keywords.split(','))

    socket.on 'removeKeyword', (data) ->
      collector.removeKeyword(data.title)
  )

  server.listen(app.port)

module.exports = app