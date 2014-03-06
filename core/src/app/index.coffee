

do ->

  app = angular.module("videoSearchAngularApp", [
      'ngRoute'
      'HomeModule'
    ])

  app.constant 'CONFIG',
    videoUrl: 'http://api.vevo.com/mobile/v1/video/list.json'
    genreUrl: 'http://api.vevo.com/mobile/v1/genre/list.json'

  app.config ($locationProvider) ->
    $locationProvider.html5Mode(true).hashPrefix('')

  app.controller 'AppCtrl', ($scope) ->
    $scope.name = 'Video Search'

    $scope.$on '$routeChangeSuccess', (event, current, previous, rejection) ->

      pageTitle = ''
      try
        pageTitle = current.$$route.data.pageTitle
      catch e

      $scope.pageTitle = "#{ pageTitle } | Video Search"






