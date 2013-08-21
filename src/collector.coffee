stream = null

cube = require 'cube'
client = cube.emitter('ws://collector.example.com:80')

twitter = require 'immortal-ntwitter'
twit = new twitter
  consumer_key: '--your-consumer-key--',
  consumer_secret: '--your-consumer-secret--',
  access_token_key: '--your-access-token-key--',
  access_token_secret: '--your-access-token-secret--'


collector =
  keywords: {}

  addKeyword: (t, k) ->
    @keywords[t] = k
    @monitor()

  removeKeyword: (t) ->
    if @keywords[t]?
      delete @keywords[t]
      @monitor()

  monitor: ->
    if stream?
      stream.destroy()

    words = []
    for t,k of @keywords
      words.push k...

    console.log words

    twit.immortalStream 'statuses/filter', track: words, (s) =>
      stream = s
      stream.on 'data', (data) =>
        for word in words
          if data.text.indexOf(word) > -1
            client.send
              type: 'tweet'
              time: Date.parse(data.created_at)
              data:
                keyword: word
                screen_name: data.user.screen_name
                text: data.text
            console.log data.user.screen_name+ ' says: '+word

      stream.on 'backoff', =>
        console.log 'Back off'

      stream.on 'destroy', =>
        console.log 'Stream destroyed'

module.exports = collector