$ ->
  keywords = {}
  context = cubism.context().step(1e4).size(940)
  cube = context.cube('http://evaluator.example.com')

  d3.select("#activity").call (div) ->
    # Add axis
    div.append('div').attr('class','axis').call(context.axis().orient('top').tickFormat(d3.time.format('%H:%M')))

    # Add ruler
    div.append('div').attr('class','rule').call(context.rule())


  # Reposition ruler
  context.on 'focus', (i) ->
    d3.selectAll('.value').style('right', if i is null then null else context.size() - i + 'px')

  # Starting socket
  socket = io.connect 'http://interface.example.com'
  socket.emit('init')
  socket.on('keywords', (data) ->
    $('#loading').hide()
    keywords = data
    drawGraph()
  )

  # Add keyword event
  $('#add-keywords .btn-primary').click((e) ->
    socket.emit('addKeyword', {title: $('#data-title').val(), keywords: $('#data-keywords').val()})
    $('#add-keywords').modal('hide')
    keywords[$('#data-title').val()] = $('#data-keywords').val().split(',')
    $('#data-title, #data-keywords').val('')
    drawGraph()
  )

  # Remove keyword event
  $('#remove-keywords .btn-primary').click((e) ->
    $('#remove-keywords input:checked').each (i,el) ->
      socket.emit('removeKeyword', {title: $(el).val()})
      delete keywords[$(el).val()]

    $('#remove-keywords').modal('hide')
    drawGraph()
  )

  drawGraph = ->
    data = []
    modal = $('#remove-keywords .control-group')
    modal.empty()

    for t,k of keywords
      data.push {title: t, metric: cube.metric('sum(tweet.in(keyword, ["'+k.join('","')+'"]))')}
      modal.append('<div class="controls"><label class="checkbox"><input type="checkbox" value="'+t+'"> '+t+'</label></div>')

    d3.select('#activity').selectAll('.horizon').call(context.horizon().remove).remove()
    d3.select('#activity').selectAll('.horizon')
      .data(data)
      .enter().append('div').attr('class','horizon')
      .call(
        context.horizon().height(80)
          .title((d) -> d.title)
          .metric((d) -> d.metric)
      )