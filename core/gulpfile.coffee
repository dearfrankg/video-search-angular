
#
# LOAD PLUGINS
#

gulp         = require 'gulp'
gutil        = require 'gulp-util'
_if          = require 'gulp-if'
plumber      = require 'gulp-plumber'
streamqueue  = require('streamqueue')

connect      = require 'connect'
http         = require 'http'
path         = require 'path'
lr           = require 'tiny-lr'
server       = lr()
refresh      = require 'gulp-livereload'

coffee       = require 'gulp-coffee'
coffeelint   = require 'gulp-coffeelint'
reporter     = require('coffeelint-stylish').reporter
browserify   = require 'gulp-browserify'


clean        = require 'gulp-clean'
header       = require 'gulp-header'
rename       = require 'gulp-rename'
concat       = require 'gulp-concat'

template     = require 'gulp-template'
ngHtml2Js    = require 'gulp-ng-html2js'

uglify       = require 'gulp-uglify'
ngmin        = require 'gulp-ngmin'


less         = require 'gulp-less'
autoprefixer = require("gulp-autoprefixer")
minifyCSS    = require 'gulp-minify-css'

minifyHTML   = require 'gulp-minify-html'

imagemin     = require 'gulp-imagemin'

#----------------------------------
# HELPERS
#----------------------------------

toCamel = (name) -> name.replace /(\-[a-z])/g, ($1) -> $1.toUpperCase().replace('-','')

#----------------------------------
# BUILD CONFIG
#----------------------------------


isRelease = undefined

pkg = require './package.json'
pkg.appname = toCamel pkg.name
cfg = require './config/build-config'

#----------------------------------
# TASKS
#----------------------------------

banner = [
  '/**'
  ' * <%= pkg.name %> - <%= pkg.description %>'
  ' * @version v<%= pkg.version %>'
  ' * @link <%= pkg.homepage %>'
  ' * @license <%= pkg.license %>'
  ' */'
  ''].join '\n'


# #
# # WEBSERVER AND RELOAD
# #

# # Starts the webserver (http://localhost:3000)
# gulp.task 'webserver', ->
#   port = 3000
#   hostname = null # allow to connect from anywhere
#   base = path.resolve cfg.appDirs.dist
#   # directory = path.resolve './dist'

#   app = connect()
#     .use(connect.static base)
#     # .use(connect.directory directory)

#   http.createServer(app).listen port, hostname


# Starts the livereload server
gulp.task 'livereload', ->
    server.listen 35729, (err) ->
        console.log err if err?



#
# VARIOUS TASKS
#

gulp.task 'clean-dist', ->
  gulp.src('dist', {read: false})
    .pipe clean()

gulp.task 'coffeelint', ->
  gulp.src('./src/*.coffee')
    .pipe plumber()
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task 'scripts', ['coffeelint'], ->
  streamqueue({ objectMode: true },
    gulp.src cfg.vendorFiles.script
    gulp.src cfg.appFiles.script
      .pipe _if(/coffee$/, coffee({bare:true}).on('error', gutil.log))
      .pipe ngmin()
    gulp.src cfg.appFiles.template
      .pipe ngHtml2Js
        moduleName: "Templates",
        prefix: "/partials/"
  )
  .pipe plumber()
  .pipe concat(pkg.name + '.js')
  .pipe _if(isRelease, do uglify)
  .pipe header(banner, { pkg : pkg })
  .pipe gulp.dest(cfg.appDirs.dist)
  .pipe refresh(server)

gulp.task 'styles', [], ->
  streamqueue({ objectMode: true },
    gulp.src cfg.vendorFiles.css
    gulp.src cfg.appFiles.style.bootstrap
      .pipe less()
    gulp.src cfg.appFiles.style.main
      .pipe less()
      .pipe autoprefixer("last 2 version", "safari 5", "ie 8", "ie 9", "opera 12.1", "ios 6", "android 4")
  )
  .pipe plumber()
  .pipe concat(pkg.name + '.css')
  .pipe _if(isRelease, do minifyCSS)
  .pipe header(banner, { pkg : pkg })
  .pipe gulp.dest(cfg.appDirs.dist)
  .pipe refresh(server)

gulp.task 'html', ->
  gulp.src cfg.appFiles.html
  .pipe plumber()
  .pipe template(pkg)
  .pipe _if(isRelease, minifyHTML({ empty:true, quotes:true}))
  .pipe gulp.dest(cfg.appDirs.dist)
  .pipe(refresh server)

gulp.task 'images', ->
  gulp.src cfg.appFiles.image
  .pipe plumber()
  .pipe _if(isRelease, do imagemin)
  .pipe gulp.dest(cfg.appDirs.dist)
  .pipe refresh(server)

gulp.task 'build', [
    # clean-dist
    'images'
    'scripts'
    'styles'
    'html'
  ]

gulp.task 'setrelease', ->
  isRelease = true

gulp.task 'release', ['setrelease', 'build']

gulp.task 'default', [
  # 'webserver'
  'livereload'
  'build'
  ], ->

    if isRelease
      return
    else
      console.log 'starting watch...'
      # Watches files for changes
      gulp.watch cfg.appFiles.config, ['build']
      gulp.watch cfg.appFiles.script, ['scripts']
      gulp.watch cfg.appFiles.style.all, ['styles']
      gulp.watch cfg.appFiles.html, ['html']

























# DISABLED CODE
# # BROWSERIFY - Not working because the browserify plugin wraps multiuple times

# gulp.task 'scripts', ['coffeelint'], ->
#   gulp.src(cfg.appFiles.script)
#     .pipe( gulpif(/[.]coffee$/, coffee({bare:true})) )
#     .pipe(concat pkg.name + '.js')
#     .pipe(uglify({ output: { max_line_len: 100 }}))
#     .pipe(header(banner, { pkg : pkg } ))
#     .pipe(gulp.dest 'dist')
#     .pipe(refresh server)

# opts = {
#   transform: ['coffeeify']
#   extensions: ['.coffee']
#   shim: # Make CommonJS-Incompatible Files Browserifyable
#     angular:
#       path: 'vendor/jquery/jquery.js'
#       exports: '$'
#     angular:
#       path: 'vendor/angular/angular.js'
#       exports: 'angular'
#     'angular-route':
#       path: 'vendor/angular-route/angular-route.js'
#       exports: 'ngRoute'
#       depends:
#         angular: 'angular'
# }
# #
# # BROWSERIFY - Not working because the browserify plugin wraps multiuple times
# #
# gulp.task 'scripts', ['coffeelint'], ->
#   gulp.src(cfg.appFiles.script, { read: false })
#     .pipe( browserify opts )
#     .pipe(concat(pkg.name + '.js'))
#     # .pipe(do uglify)
#     .pipe(header(banner, { pkg : pkg } ))
#     .pipe(gulp.dest 'dist')
#     .pipe(refresh server)






