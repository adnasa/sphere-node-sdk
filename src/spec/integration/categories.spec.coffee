_ = require 'underscore'
Q = require 'q'
SphereClient = require '../../lib/client'
Config = require('../../config').config

uniqueId = (prefix) ->
  _.uniqueId "#{prefix}#{new Date().getTime()}_"

newCategory = ->
  name:
    en: 'Category name'
  slug:
    en: uniqueId 'c'

updateCategory = (version, parentId) ->
  version: version
  actions: [
    {action: 'changeParent', parent: {typeId: 'category', id: parentId}}
  ]


describe 'Integration Categories', ->

  beforeEach (done) ->
    @client = new SphereClient
      config: Config
      logConfig:
        levelStream: 'info'
        levelFile: 'error'
    @logger = @client._logger

    @logger.info 'Creating 500 categories'
    Q.all _.map [1..50], => @client.categories.save(newCategory())
    .then (results) =>
      @logger.info "Created #{results.length} categories"
      done()
    .fail (error) =>
      @logger.error error
      done('Oops')
  , 30000 # 30sec

  afterEach (done) ->
    @logger.info 'About to delete all categories'
    @client.categories.perPage(0).fetch()
    .then (payload) =>
      @logger.info "Deleting #{payload.body.total} categories"
      Q.all _.map payload.body.results, (category) =>
        @client.categories.parallel(1).byId(category.id).delete(category.version)
    .then (results) =>
      @logger.info "Deleted #{results.length} categories"
      done()
    # .progress (progress) => @logger.info "Deleting: #{progress.percentage}% completed"
    .fail (error) =>
      @logger.error error
      done('Oops')
  , 60000 # 1min

  it 'should update descriptions with process', (done) ->
    @client.categories.sort('id').perPage(1).process (payload) =>
      cat = payload.body.results[0]
      if cat
        @client.categories.byId(cat.id).update
          version: cat.version
          actions: [
            {action: 'setDescription', description: {en: 'A new description'}}
          ]
      else
        @logger.warn 'No category found, skipping...'
        Q()
    .then (results) ->
      expect(results.length).toBe 50
      done()
    .fail (error) =>
      @logger.error error
      done('Oops')
  , 60000 # 1min