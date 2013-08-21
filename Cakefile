fs            = require 'fs'
{print}       = require 'util'
which         = require 'which'
{spawn, exec} = require 'child_process'

# ANSI Terminal Colors
bold = '\x1b[0;1m'
green = '\x1b[0;32m'
reset = '\x1b[0m'
red = '\x1b[0;31m'

log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

# Compiles the src directory to the .app directory
build = (callback) ->
  options = ['-c','-b', '-o', '.app', 'src']
  cmd = which.sync 'coffee'
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  coffee.on 'exit', (status) -> callback?() if status is 0

# Runs the Cube collector and evaluator
cube = () ->
  try
    process.chdir 'node_modules/cube'

    log(green, 'starting cube collector')
    collector = spawn 'node', ['bin/collector.js']
    collector.stdout.on 'data', (data) ->
      print data.toString()

    log(green,'starting cube evaluator')
    evaluator = spawn 'node', ['bin/evaluator.js']
    evaluator.stdout.on 'data', (data) ->
      print data.toString()

  catch err
    log(red, 'cube not found')

task 'build', ->
  build -> log ":)", green

task 'run', 'Compile and watch coffeescript', ->
  # watch_coffee
  options = ['-c', '-b', '-w', '-o', '.app', 'src']
  cmd = which.sync 'coffee'
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  log 'Watching coffee files', green
  # watch_js
  supervisor = spawn 'node', [
    './node_modules/supervisor/lib/cli-wrapper.js',
    '-w',
    '.app,views',
    '-e',
    'js|jade',
    'server'
  ]
  supervisor.stdout.pipe process.stdout
  supervisor.stderr.pipe process.stderr
  log 'Watching js files and running server', green
  cube()