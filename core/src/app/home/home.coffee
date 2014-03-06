
app = angular.module('HomeModule', [
  'ngSanitize'
  'Templates'
  'mgcrea.ngStrap.helpers.parseOptions'
  'mgcrea.ngStrap.tooltip'
  'mgcrea.ngStrap.select'
  ])


app.config ($routeProvider) ->

  $routeProvider

    .when '/',
      controller: 'HomeCtrl'
      templateUrl: '/partials/app/home/home.tpl.html',
      resolve: {
        genres: [ '$http', 'CONFIG', ($http, CONFIG) ->
          $http.get(CONFIG.genreUrl).then (data) ->
            genres = _.map data.data.result, (item) ->
              return {
                value: item.Key
                label: item.Value
              }
            genres.unshift { value: 'all-genres', label: 'All Genres'}
            return genres
        ]
      }
      data:
        pageTitle: 'Home'

    .otherwise
      redirectTo: '/'


app.controller 'HomeCtrl', ($scope, $http, genres, CONFIG) ->

  $scope.appendVideos = ->
    params =
      offset: $scope.offset
      max: $scope.max
    genre = $scope.selectedGenre
    params.genres = genre unless genre is 'all-genres'

    $scope.offset += $scope.max

    $http.get(CONFIG.videoUrl, {params: params}).then (data) ->
      $scope.videos = $scope.videos.concat data.data.result


  $scope.changeGenre = ->
    $scope.videos = []
    $scope.offset = 0
    $scope.appendVideos()


  initialize = ->
    # setup genres popup
    $scope.genres = genres
    $scope.selectedGenre = 'all-genres'

    $scope.videos = []
    $scope.offset = 0
    $scope.max = 40
    $scope.appendVideos()


  initialize()

