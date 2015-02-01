gulp         = require 'gulp'
streamify    = require 'gulp-streamify'
uglify       = require 'gulp-uglify'
sourcemaps   = require 'gulp-sourcemaps'
changed      = require 'gulp-changed'
coffee       = require 'gulp-coffee'
sketch       = require 'gulp-sketch'
cssimport    = require 'gulp-cssimport'
autoprefixer = require 'gulp-autoprefixer'
minifyCss    = require 'gulp-minify-css'
replace      = require 'gulp-replace'
zip          = require 'gulp-zip'
merge        = require 'merge-stream'
runSequence  = require 'run-sequence'
browserify   = require 'browserify'
coffeeify    = require 'coffeeify'
source       = require 'vinyl-source-stream'
buffer       = require 'vinyl-buffer'
rt           = require 'react-templates'
map          = require 'map-stream'
path         = require 'path'
del          = require 'del'

$ =
  root:    './src/root/*'
  coffee:  ['./src/coffee/popup.coffee', './src/coffee/background.coffee']
  rt:      './src/components/'
  rtopt:   modules: 'commonjs'
  font:    './node_modules/font-awesome/fonts/*.woff2'
  css:     './src/css/style.css'
  sketch:  './src/images/*.sketch'
  dist:    './dist/'
  package: './dist/*'

gulp.task 'default', (cb) -> runSequence 'clean', [
  'browserify'
  'css'
  'sketch'
  'font-awesome'
  'root'
], 'package', cb

gulp.task 'clean', (cb) -> del [$.dist], -> cb()

gulp.task 'rt', (cb) ->
  gulp.src "#{$.rt}**/*.rt"
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

gulp.task 'font-awesome', ->
  gulp.src $.font
  .pipe changed $.dist
  .pipe gulp.dest $.dist

gulp.task 'css', ->
  gulp.src $.css
  .pipe cssimport()
  .pipe replace '../fonts/', ''
  .pipe autoprefixer 'last 2 versions'
  .pipe minifyCss keepSpecialComments: 0
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

gulp.task 'package', ->
  gulp.src [
    $.package
    '!*.map'
  ]
  .pipe zip 'techdocs.zip'
  .pipe gulp.dest './'

gulp.task 'watch', ->
  o = debounceDelay: 3000
  gulp.watch [
    './src/**/*.coffee'
    './src/**/*.rt'
  ], o, ['browserify']
  gulp.watch ['./src/**/*.css'], o, ['css']
  gulp.watch [$.sketch], o, ['sketch']
  gulp.watch [$.root], o, ['root']
  gulp.watch [$.package], o, ['package']

gulpRT = (option) ->
  map (file, cb) ->
    html = file.contents.toString()
    js = rt.convertTemplateToReact html, option
    file.contents = new Buffer js
    file.path += '.js'
    cb null, file
