describe('Search', function () {
  'use strict'

  var module
  var content
  var query
  var processedContent
  var searchResults
  var $element

  beforeEach(function () {
    module = new GOVUK.Modules.Search()
    $element = $('<div class="search" data-module="search" data-path-to-site-root="/">' +
  '<form action="https://www.google.co.uk/search" method="get" role="search">' +
    '<input type="hidden" name="as_sitesearch" value="<%= config[:tech_docs][:host] %>"/>' +
    '<label for="search"  class="govuk-label search__label">Search (via Google)</label>' +
    '<input type="text" id="search" name="q" placeholder="Search" aria-controls="search-results" class="govuk-input" />' +
  '</form>' +
  '<div id="search-results" class="search-results" aria-hidden="true">' +
    '<div class="search-results__inner">' +
      '<button class="search-results__close">Close<span class="search-results__close-label"> search results</span></button>' +
      '<h2 class="search-results__title" aria-live="polite">Results</h2>' +
      '<div class="search-results__content"></div>' +
    '</div>' +
  '</div>' +
'</div>')

    // Stub out isOnSearchPage and getQuery
    module.isOnSearchPage = function isOnSearchPage () {
      return true
    }

    module.getQuery = function getQuery () {
      return query
    }

    // Change the default search index location to use the search index from the example app
    module.downloadSearchIndex = function downloadSearchIndex () {
      $.ajax({
        url: 'example/build/search.json',
        async: false,
        cache: true,
        method: 'GET',
        success: function (data) {
          module.lunrData = data
          module.lunrIndex = lunr.Index.load(module.lunrData.index)
        }
      })
    }

    module.start($element)

    query = 'test'
    content = 'This sentence should not be shown. This is test sentence one. This is test sentence two? This is test sentence three:\nThis is test sentence four! This sentence should not be shown! This is test sentence five\n'
    processedContent = module.processContent(content, query)
    module.search('expired', function (r) {
      searchResults = r
    })
  })

  describe('the search method', function () {
    it('returns an array of search results', function () {
      var expectedResults = [
        {
          title: 'This is an expired page',
          content: 'This is an expired page\nSee the banner on this page.\n',
          url: '/expired-page.html'
        },
        {
          title: 'This is an expired page',
          content: 'This is not an expired page\nSee the banner on this page.\n',
          url: '/not-expired-page.html'
        },
        {
          title: 'This is an expired page',
          content: 'This is an expired page with owner\nSee the banner on this page.\n',
          url: '/expired-page-with-owner.html'
        },
        {
          title: 'This is a child of expired page',
          content: 'This is a child of expired page\nExpired page should highlight in the navigation.\n',
          url: '/child-of-expired-page.html'
        }
      ]
      expect(searchResults).toEqual(expectedResults)
    })

    it('autocompletes words', function () {
      module.search('documenta', function (incomplete) {
        module.search('documentation', function (complete) {
          expect(incomplete).toEqual(complete)
        })
      })
    })
  })

  describe('the processContent method', function () {
    it('returns concatenated sentences that contain the search query', function () {
      var expectedResults = ' … This is <mark data-markjs="true">test</mark> sentence one … This is <mark data-markjs="true">test</mark> sentence two … This is <mark data-markjs="true">test</mark> sentence three … This is <mark data-markjs="true">test</mark> sentence four … This is <mark data-markjs="true">test</mark> sentence five … '
      expect(processedContent).toEqual(expectedResults)
    })
  })
})
