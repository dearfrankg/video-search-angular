pkg = require '../package.json'

cfg = {

  appDirs:
    dist: 'dist'
    bin: '../bin'

  appFiles:
    script: [
      'src/**/*.{js,coffee}'
      '!src/**/*.spec.{js,coffee}'
    ]
    style:
      all: ['src/**/*/less']
      bootstrap: [ 'src/less/bootstrap.less' ]
      main: [ 'src/less/main.less' ]
    image: [ 'src/**/*.{jpg,png,gif}' ]
    html: [ 'src/index.html' ]
    template: [ 'src/**/*.tpl.html' ]
    config: [ 'build-config.coffee', 'gulpfile.coffee' ]

  vendorFiles:
    script: [
      'vendor/lodash/dist/lodash.js'
      'vendor/jquery/dist/jquery.js'
      'vendor/angular/angular.js'
      'vendor/angular-route/angular-route.js'
      'vendor/angular-sanitize/angular-sanitize.js'
      'vendor/angular-animate/angular-animate.js'
      'vendor/angular-mocks/angular-mocks.js'
      'vendor/angular-strap/src/helpers/parse-options.js'
      'vendor/angular-strap/dist/angular-strap.js'
      'vendor/angular-strap/dist/angular-strap.tpl.js'
    ]
    css: [
      # cannot be an empty array
      ''
    ]

  testFiles:
    script: [
      "dist/#{pkg.name}.js"
      'src/**/*.spec.{js,coffee}'
    ]

}

# remove mocks if env is production

if process.env.production
  console.log '\n** not including angular-mocks **\n'
  cfg.vendorFiles.script = cfg.vendorFiles.script.filter (e) ->
    e != 'vendor/angular-mocks/angular-mocks.js'

module.exports = cfg