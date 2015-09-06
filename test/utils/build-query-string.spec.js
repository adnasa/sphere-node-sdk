import expect from 'expect'
import buildQueryString from '../../lib/utils/build-query-string'

describe('Utils', () => {

  describe('::buildQueryString', () => {

    it('should throw if no argument is passed', () => {
      expect(() => buildQueryString())
        .toThrow(/Missing options object to build query string/)
    })

    it('should build fully encoded query string', () => {
      const params = {
        expand: [
          encodeURIComponent('productType'),
          encodeURIComponent('categories[*]')
        ],
        staged: false,
        pagination: {
          page: 3,
          perPage: 10,
          sort: [
            encodeURIComponent('name.en desc'),
            encodeURIComponent('createdAt asc')
          ]
        },
        query: {
          operator: 'or',
          where: [
            encodeURIComponent('name(en = "Foo")'),
            encodeURIComponent('name(en = "Bar") and categories(id = "123")')
          ]
        },
        search: {
          facet: [
            encodeURIComponent('variants.attributes.foo:"bar")'),
            encodeURIComponent('variants.sku:"foo123"')
          ],
          filter: [
            encodeURIComponent('variants.attributes.color.key:"red")'),
            encodeURIComponent('categories.id:"123"')
          ],
          filterByQuery: [
            encodeURIComponent('variants.attributes.color.key:"red")'),
            encodeURIComponent('categories.id:"123"')
          ],
          filterByFacets: [
            encodeURIComponent('variants.attributes.color.key:"red")'),
            encodeURIComponent('categories.id:"123"')
          ],
          text: { lang: 'en', value: 'Foo' }
        }
      }
      /*eslint-disable max-len*/
      const expectedQueryString =
        `staged=false&` +
        `where=${encodeURIComponent('name(en = "Foo") or name(en = "Bar") and categories(id = "123")')}&` +
        `expand=productType&` +
        `expand=${encodeURIComponent('categories[*]')}&` +
        `limit=10&offset=20&` +
        `sort=${encodeURIComponent('name.en desc')}&` +
        `sort=${encodeURIComponent('createdAt asc')}&` +
        `text.en=${encodeURIComponent('Foo')}&` +
        `facet=${encodeURIComponent('variants.attributes.foo:"bar")')}&` +
        `facet=${encodeURIComponent('variants.sku:"foo123"')}&` +
        `filter=${encodeURIComponent('variants.attributes.color.key:"red")')}&` +
        `filter=${encodeURIComponent('categories.id:"123"')}&` +
        `filter.query=${encodeURIComponent('variants.attributes.color.key:"red")')}&` +
        `filter.query=${encodeURIComponent('categories.id:"123"')}&` +
        `filter.facets=${encodeURIComponent('variants.attributes.color.key:"red")')}&` +
        `filter.facets=${encodeURIComponent('categories.id:"123"')}`
      /*eslint-enable max-len*/

      expect(buildQueryString(params)).toEqual(expectedQueryString)
    })
  })
})
