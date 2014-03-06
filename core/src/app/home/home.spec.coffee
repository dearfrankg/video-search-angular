
describe 'home controller', ->

  scope = genericUrlRegExp = $httpBackend = cfg = undefined

  genres = [
    { value: 'all-genres', label: 'All Genres'}
    { value: 'blues', label: 'Blues'}
    { value: 'jazz', label: 'Jazz'}
  ]

  videos = result: [
    {"id":"1", "title":"One (Official)"}
    {"id":"2", "title":"Two (Official)"}
    {"id":"3", "title":"Three (Official)"}
  ]

  beforeEach ->

    module 'vevoDemoApp'
    module 'Templates'

    inject ($rootScope, _$httpBackend_, $controller, CONFIG) ->

      cfg = CONFIG
      $httpBackend = _$httpBackend_

      scope = $rootScope.$new()
      createController = () ->
        $controller('HomeCtrl', {
          '$scope': scope
          'genres': genres # test the ctrl not the resolve
        })

      $httpBackend.expectGET(cfg.videoUrl + '?max=40&offset=0').respond(videos)
      controller = createController()
      $httpBackend.flush()

      genericUrlRegExp = /^http.*$/

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()


  describe 'action handler', ->

    describe '#appendVideos()', ->

      it 'should add scope.max to scope.offset', ->
        expect(scope.offset is 40).toBeTruthy()

      it 'should append video objects to scope.videos', ->
        expect(scope.videos.length is 3).toBeTruthy()


    describe '#changeGenres()', ->

      it 'should set scope.videos to an empty array', ->
        $httpBackend.expectGET(genericUrlRegExp).respond(videos)
        scope.appendVideos()
        $httpBackend.flush()
        expect(scope.videos.length).toEqual 6

        $httpBackend.expectGET(genericUrlRegExp).respond(videos)
        scope.changeGenre()
        $httpBackend.flush()
        expect(scope.videos.length).toEqual 3

      it 'should reset scope.offset when changing genres', ->
        $httpBackend.expectGET(genericUrlRegExp).respond(videos)
        scope.appendVideos()
        $httpBackend.flush()
        expect(scope.offset).toEqual 80

        $httpBackend.expectGET(genericUrlRegExp).respond(videos)
        scope.changeGenre()
        $httpBackend.flush()
        expect(scope.offset).toEqual 40

      it 'should call appendVideos() with scope.selectedGenre', ->
        $httpBackend.expectGET(cfg.videoUrl + '?genres=jazz&max=40&offset=40').respond(videos)
        scope.selectedGenre = 'jazz'
        scope.appendVideos()
        $httpBackend.flush()
        expect(true).toBeTruthy() # we get an error if $httpBackend fails


  describe 'initialization', ->

    it 'should initialize controller properly', ->
      expect(scope.genres.length is 3 and  scope.genres[0].value is 'all-genres').toBeTruthy()
      expect(scope.videos.length).toEqual 3
      expect(scope.offset).toEqual 40
      expect(scope.max).toEqual 40

    it 'should call appendVideos', ->
      expect(scope.videos.length is 3).toBeTruthy()



