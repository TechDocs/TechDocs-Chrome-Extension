gulp        = require 'gulp'
streamify   = require 'gulp-streamify'
uglify      = require 'gulp-uglify'
sourcemaps  = require 'gulp-sourcemaps'
changed     = require 'gulp-changed'
coffee      = require 'gulp-coffee'
sketch      = require 'gulp-sketch'
merge       = require 'merge-stream'
runSequence = require 'run-sequence'
browserify  = require 'browserify'
coffeeify   = require 'coffeeify'
source      = require 'vinyl-source-stream'
buffer      = require 'vinyl-buffer'
rt          = require 'react-templates'
map         = require 'map-stream'
path        = require 'path'
del         = require 'del'

$ =
  root:   './src/root/*'
  coffee: ['./src/coffee/popup.coffee', './src/coffee/background.coffee']
  rt:     './src/templates/'
  rtopt:  modules: 'commonjs'
  sketch: './src/images/*.sketch'
  dist:   './dist/'

gulp.task 'default', (cb) -> runSequence 'clean', [
  'browserify'
  'sketch'
  'root'
], cb

gulp.task 'clean', (cb) -> del [$.dist], -> cb()

gulp.task 'rt', (cb) ->
  gulp.src "#{$.rt}*.rt"
  .pipe gulpRT $.rtopt
  .pipe gulp.dest $.rt

gulp.task 'browserify', ['rt'], ->
  merge stream =
    for file in $.coffee
      browserify
        entries: [file]
        extensions: ['.coffee', '.js']
        debug: true
      .transform coffeeify
      .bundle()
      .pipe source "#{path.basename file, '.coffee'}.js"
      .pipe buffer()
      .pipe sourcemaps.init loadMaps: true
      .pipe streamify uglify()
      .pipe sourcemaps.write './'
      .pipe gulp.dest $.dist

gulp.task 'root', ->
  gulp.src $.root
  .pipe changed $.dist
  .pipe gulp.dest $.dist

gulp.task 'sketch', ->
  gulp.src $.sketch
  .pipe sketch
    export: 'artboards'
    formats: 'png'
    scales: '1.0'
  .pipe gulp.dest $.dist

gulp.task 'watch', ->
  o = debounceDelay: 3000
  gulp.watch [
    './src/coffee/**/*.coffee'
  ], o, ['browserify']
  gulp.watch [$.sketch], o, ['sketch']
  gulp.watch [$.root], o, ['root']

gulpRT = (option) ->
  map (file, cb) ->
    html = file.contents.toString()
    js = rt.convertTemplateToReact html, option
    file.contents = new Buffer js
    file.path += '.js'
    cb null, file
