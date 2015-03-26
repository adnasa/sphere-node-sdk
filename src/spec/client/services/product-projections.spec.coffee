_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{TaskQueue} = require '../../../lib/main'
ProductProjectionService = require '../../../lib/services/product-projections'

###*
 * Describe service specific implementations
###
describe 'ProductProjectionService', ->

  beforeEach ->
    @restMock =
      config: {}
      GET: (endpoint, callback) ->
      POST: -> (endpoint, payload, callback) ->
      PUT: ->
      DELETE: -> (endpoint, callback) ->
      PAGED: -> (endpoint, callback, notify) ->
      _preRequest: ->
      _doRequest: ->
    @task = new TaskQueue
    @service = new ProductProjectionService
      _rest: @restMock
      _task: @task
      _stats:
        includeHeaders: false

  it 'should reset default params', ->
    expect(@service._params).toEqual
      encoded: ['where', 'expand', 'sort', 'filter', 'filter.query', 'filter.facets', 'facets']
      query:
        where: []
        operator: 'and'
        sort: []
        expand: []
        staged: false
        filter: []
        filterByQuery: []
        filterByFacets: []
        facet: []
        searchKeywords: []

  _.each [
    ['staged', [false]]
    ['text', ['foo', 'de']]
    ['filter', ['foo:bar']]
    ['filterByQuery', ['foo:bar']]
    ['filterByFacets', ['foo:bar']]
    ['facet', ['foo:bar']]
  ], (f) ->
    it "should chain search function '#{f[0]}'", ->
      clazz = @service[f[0]].apply(@service, _.toArray(f[1]))
      expect(clazz).toEqual @service

      promise = @service[f[0]].apply(@service, _.toArray(f[1])).search()
      expect(promise.isPending()).toBe true

  it 'should query for staged', ->
    expect(@service.staged()._queryString()).toBe 'staged=true'

  it 'should query for published', ->
    expect(@service.staged(false)._queryString()).toBe ''

  it 'should query for text', ->
    expect(@service.text('foo', 'de')._queryString()).toBe 'text.de=foo'

  it 'should encode query for text', ->
    expect(@service.text('äöüß', 'de')._queryString()).toBe "text.de=#{encodeURIComponent('äöüß')}"

  it 'should throw if lang is not defined', ->
    expect(=> @service.text('foo')).toThrow new Error 'Language parameter is required for searching'

  it 'should query for filter', ->
    expect(@service.filter('foo:bar')._queryString()).toBe 'filter=foo%3Abar'

  it 'should query for filter.query', ->
    expect(@service.filterByQuery('foo:bar')._queryString()).toBe 'filter.query=foo%3Abar'

  it 'should query for filter.facets', ->
    expect(@service.filterByFacets('foo:bar')._queryString()).toBe 'filter.facets=foo%3Abar'

  it 'should query for facet', ->
    expect(@service.facet('foo:bar')._queryString()).toBe 'facet=foo%3Abar'

  it 'should build search query string', ->
    queryString = @service
      .page 3
      .perPage 25
      .sort('createdAt')
      .text('foo', 'de')
      .filter('foo:bar')
      .filterByQuery('foo:bar')
      .filterByFacets('foo:bar')
      .facet('foo:bar')
      ._queryString()

    expect(queryString).toBe 'limit=25&offset=50&sort=createdAt%20asc&text.de=foo&filter=foo%3Abar&filter.query=foo%3Abar&filter.facets=foo%3Abar&facet=foo%3Abar'

  it "should reset search custom params after creating a promise", ->
    _service = @service
      .page 3
      .perPage 25
      .sort('createdAt')
      .staged()
      .text('foo', 'de')
      .filter('filter1:bar1')
      .filter('filter2:bar2')
      .filterByQuery('filterQuery1:bar1')
      .filterByQuery('filterQuery2:bar2')
      .filterByFacets('filterFacets1:bar1')
      .filterByFacets('filterFacets2:bar2')
      .facet('facet1:bar1')
      .facet('facet2:bar2')
    expect(@service._params).toEqual
      encoded: ['where', 'expand', 'sort', 'filter', 'filter.query', 'filter.facets', 'facets']
      query:
        where: []
        operator: 'and'
        sort: [encodeURIComponent('createdAt asc')]
        expand: []
        page: 3
        perPage: 25
        staged: true
        text:
          lang: 'de'
          value: 'foo'
        filter: [encodeURIComponent('filter1:bar1'), encodeURIComponent('filter2:bar2')]
        filterByQuery: [encodeURIComponent('filterQuery1:bar1'), encodeURIComponent('filterQuery2:bar2')]
        filterByFacets: [encodeURIComponent('filterFacets1:bar1'), encodeURIComponent('filterFacets2:bar2')]
        facet: [encodeURIComponent('facet1:bar1'), encodeURIComponent('facet2:bar2')]
        searchKeywords: []
    _service.search()
    expect(@service._params).toEqual
      encoded: ['where', 'expand', 'sort', 'filter', 'filter.query', 'filter.facets', 'facets']
      query:
        where: []
        operator: 'and'
        sort: []
        expand: []
        staged: false
        filter: []
        filterByQuery: []
        filterByFacets: []
        facet: []
        searchKeywords: []

  it 'should set queryString, if given', ->
    @service.byQueryString('where=name(en = "Foo")&limit=10&staged=true&sort=name asc&expand=foo.bar1&expand=foo.bar2')
    expect(@service._params.queryString).toEqual 'where=name(en%20%3D%20%22Foo%22)&limit=10&staged=true&sort=name%20asc&expand=foo.bar1&expand=foo.bar2'

    @service.byQueryString('filter=variants.price.centAmount:100&filter=variants.attributes.foo:bar&staged=true&limit=100&offset=2')
    expect(@service._params.queryString).toEqual 'filter=variants.price.centAmount%3A100&filter=variants.attributes.foo%3Abar&staged=true&limit=100&offset=2'

  it 'should set queryString, if given (already encoding)', ->
    @service.byQueryString('where=name(en%20%3D%20%22Foo%22)&limit=10&staged=true&sort=name%20asc&expand=foo.bar1&expand=foo.bar2', true)
    expect(@service._params.queryString).toEqual 'where=name(en%20%3D%20%22Foo%22)&limit=10&staged=true&sort=name%20asc&expand=foo.bar1&expand=foo.bar2'

    @service.byQueryString('filter=variants.price.centAmount%3A100&filter=variants.attributes.foo%3Abar&staged=true&limit=100&offset=2', true)
    expect(@service._params.queryString).toEqual 'filter=variants.price.centAmount%3A100&filter=variants.attributes.foo%3Abar&staged=true&limit=100&offset=2'

  describe ':: search', ->

    it 'should call \'fetch\' after setting search endpoint', ->
      spyOn(@service, 'fetch')
      @service.text('foo', 'de').filter('foo:bar').search()
      expect(@service.fetch).toHaveBeenCalled()
      expect(@service._currentEndpoint).toBe '/product-projections/search'

  describe ':: suggest', ->

    it 'should call \'fetch\' after setting suggest endpoint', ->
      spyOn(@service, 'fetch')
      @service.searchKeywords('foo', 'de').suggest()
      expect(@service.fetch).toHaveBeenCalled()
      expect(@service._currentEndpoint).toBe '/product-projections/suggest'

    it 'should build query for multiple search keywords', ->
      spyOn(@service, 'fetch')
      @service
      .searchKeywords('foo1', 'de')
      .searchKeywords('foo2', 'en')
      .searchKeywords('äöüß', 'it')
      .suggest()
      expect(@service._queryString()).toBe "searchKeywords.de=foo1&searchKeywords.en=foo2&searchKeywords.it=#{encodeURIComponent('äöüß')}"

    it 'should throw if text or lang are not defined', ->
      expect(=> @service.searchKeywords()).toThrow new Error 'Suggestion text parameter is required for searching for a suggestion'
      expect(=> @service.searchKeywords('foo')).toThrow new Error 'Language parameter is required for searching for a suggestion'

  describe ':: fetch', ->

    it 'should fetch all with defaul sorting', (done) ->
      spyOn(@restMock, 'PAGED').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 1, results: []})
      @service.where('foo=bar').staged(true).all().fetch()
      .then (result) =>
        expect(@restMock.PAGED).toHaveBeenCalledWith "/product-projections?where=foo%3Dbar&limit=0&sort=id%20asc&staged=true", jasmine.any(Function)
        done()
      .catch (err) -> done(_.prettify err)

  describe ':: process', ->

    it 'should call each page with the same query (default sorting)', (done) ->
      spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 21, endpoint: endpoint})
      fn = (payload) ->
        Promise.resolve payload.body.endpoint
      @service.where('foo=bar').whereOperator('or').staged(true).process(fn)
      .then (result) ->
        expect(_.size result).toBe 2
        expect(result[0]).toMatch /\?where=foo%3Dbar&limit=20&sort=id%20asc&staged=true$/
        expect(result[1]).toMatch /\?where=foo%3Dbar&limit=20&offset=20&sort=id%20asc&staged=true$/
        done()
      .catch (err) -> done(_.prettify err)

    it 'should call each page with the same query (given sorting)', (done) ->
      spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 21, endpoint: endpoint})
      fn = (payload) ->
        Promise.resolve payload.body.endpoint
      @service.where('foo=bar').whereOperator('or').staged(true).sort('name', false).process(fn)
      .then (result) ->
        expect(_.size result).toBe 2
        expect(result[0]).toMatch /\?where=foo%3Dbar&limit=20&sort=name%20desc&staged=true$/
        expect(result[1]).toMatch /\?where=foo%3Dbar&limit=20&offset=20&sort=name%20desc&staged=true$/
        done()
      .catch (err) -> done(_.prettify err)