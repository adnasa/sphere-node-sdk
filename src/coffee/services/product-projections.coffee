_ = require 'underscore'
BaseService = require './base'

###*
 * Creates a new ProductProjectionService.
 * @class ProductProjectionService
###
class ProductProjectionService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a ProductProjections API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/product-projections'

  ###*
   * @private
   * Reset default query/search params
  ###
  _setDefaults: ->
    super()
    @_customParams =
      query:
        staged: false
        filter: []
        filterByQuery: []
        filterByFacets: []
        facet: []

  ###*
   * Define whether to query for staged or current product projection.
   * @param Boolean [staged] true to query staged products (default). False to query published products
   * @return {ProductProjectionService} Chained instance of this class
  ###
  staged: (staged = true) ->
    @_customParams.query.staged = staged
    @_logger.debug @_customParams.query, 'Setting \'staged\' parameter'
    this

  ###*
   * Define the language tag used for searching product projection.
   * @param {String} language An ISO language tag, used for search, for the 'lang' search parameter.
   * @return {ProductProjectionService} Chained instance of this class
  ###
  lang: (language) ->
    throw new Error 'Language parameter is required for searching' unless language
    @_customParams.query.lang = language
    @_logger.debug @_customParams.query, 'Setting \'lang\' parameter'
    this

  ###*
   * Define the text to analyze and search.
   * @param {String} [text] A string for the `text` search parameter.
   * @return {ProductProjectionService} Chained instance of this class
  ###
  text: (text) ->
    return this unless text
    @_customParams.query.text = text
    @_logger.debug @_customParams.query, 'Setting \'text\' parameter'
    this

  ###*
   * Define a {Filter} used for filtering searched product projections.
   * @link http://commercetools.de/dev/http-api-projects-products.html#search-filters
   * @param {String} [filter] A {Filter} string for the `filter` search parameter.
   * @return {ProductProjectionService} Chained instance of this class
  ###
  filter: (filter) ->
    return this unless filter
    encodedFilter = encodeURIComponent(filter)
    @_customParams.query.filter.push encodedFilter
    @_logger.debug @_customParams.query, 'Setting \'filter\' parameter'
    this

  ###*
   * Define a {Filter} (applied to query result) used for filtering searched product projections.
   * @link http://commercetools.de/dev/http-api-projects-products.html#search-filters
   * @param {String} [filter] A {Filter} string for the `filter.query` search parameter.
   * @return {ProductProjectionService} Chained instance of this class
  ###
  filterByQuery: (filter) ->
    return this unless filter
    encodedFilter = encodeURIComponent(filter)
    @_customParams.query.filterByQuery.push encodedFilter
    @_logger.debug @_customParams.query, 'Setting \'filter.query\' parameter'
    this

  ###*
   * Define a {Filter} (applied to facet calculation) used for filtering searched product projections.
   * @link http://commercetools.de/dev/http-api-projects-products.html#search-filters
   * @param {String} [filter] A {Filter} string for the `filter.facets` search parameter.
   * @return {ProductProjectionService} Chained instance of this class
  ###
  filterByFacets: (filter) ->
    return this unless filter
    encodedFilter = encodeURIComponent(filter)
    @_customParams.query.filterByFacets.push encodedFilter
    @_logger.debug @_customParams.query, 'Setting \'filter.facets\' parameter'
    this

  ###*
   * Define a {Facet} used for calculating statistical counts for searched product projections.
   * @link http://commercetools.de/dev/http-api-projects-products.html#search-facets
   * @param {String} [facet] A {Facet} string for the `facet` search parameter.
   * @return {ProductProjectionService} Chained instance of this class
  ###
  facet: (facet) ->
    return this unless facet
    encodedFacet = encodeURIComponent(facet)
    @_customParams.query.facet.push encodedFacet
    @_logger.debug @_customParams.query, 'Setting \'facet\' parameter'
    this

  ###*
   * @private
   * Build a query string from (pre)defined params and custom search params.
   * @return {String} the query string
  ###
  _queryString: ->
    {staged, lang, text, filter, filterByQuery, filterByFacets, facet} = _.defaults @_customParams.query,
      staged: false
      filter: []
      filterByQuery: 'and'
      filterByFacets: []
      facet: []

    # filter param
    filterParam = filter.join '&'

    # filterByQuery param
    filterByQueryParam = filterByQuery.join '&'

    # filterByFacets param
    filterByFacetsParam = filterByFacets.join '&'

    # facet param
    facetParam = facet.join '&'

    customQueryString = []
    customQueryString.push "staged=#{staged}" if staged
    customQueryString.push "lang=#{lang}" if lang
    customQueryString.push "text=#{text}" if text
    customQueryString.push "filter=#{filterParam}" if filterParam
    customQueryString.push "filter.query=#{filterByQueryParam}" if filterByQueryParam
    customQueryString.push "filter.facets=#{filterByFacetsParam}" if filterByFacetsParam
    customQueryString.push "facet=#{facetParam}" if facetParam

    _.compact([super()].concat(customQueryString)).join '&'

  ###*
   * Search product projections with search parameters
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  search: ->
    @_currentEndpoint = '/product-projections/search'
    @fetch()


###*
 * The {@link ProductProjectionService} service.
###
module.exports = ProductProjectionService
