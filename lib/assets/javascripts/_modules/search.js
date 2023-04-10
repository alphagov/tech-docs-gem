//= require lunr.min
//= require _vendor/jquery.mark.js
(function ($, Modules) {
  'use strict'

  Modules.Search = function Search () {
    var s = this
    var $html = $('html')
    var $searchForm
    var $searchLabel
    var $searchInput
    var $searchResults
    var $searchResultsTitle
    var $searchResultsWrapper
    var $searchHelp
    var results
    var query
    var maxSearchEntries = 20
    var pathToSiteRoot

    this.start = function start ($element) {
      $searchForm = $element.find('form')
      $searchInput = $element.find('#search')
      $searchLabel = $element.find('.search__label')
      $searchResultsWrapper = $('#search-results')
      $searchResults = $searchResultsWrapper.find('.search-results__content')
      $searchResultsTitle = $searchResultsWrapper.find('.search-results__title')
      $searchHelp = $('#search-help')
      pathToSiteRoot = $element.data('pathToSiteRoot')

      changeSearchAction()
      changeSearchLabel()

      // Only do searches on the search page
      if (s.isOnSearchPage()) {
        s.downloadSearchIndex()
        $html.addClass('has-search-results-open')

        if (window.location.search) {
          query = s.getQuery()
          if (query) {
            $searchInput.val(query)
            doSearch(query, pathToSiteRoot)
            doAnalytics()
            document.title = query + ' - ' + document.title
          }
        }
      }
    }

    this.downloadSearchIndex = function downloadSearchIndex () {
      updateTitle('Loading search results')
      $.ajax({
        url: pathToSiteRoot + 'search.json',
        cache: true,
        method: 'GET',
        success: function (data) {
          s.lunrData = data
          s.lunrIndex = lunr.Index.load(s.lunrData.index)
          replaceStopWordFilter()
          $(document).trigger('lunrIndexLoaded')
        }
      })
    }

    function changeSearchAction () {
      // We need JavaScript to do search, so if JS is not available the search
      // input sends the query string to Google. This JS function changes the
      // input to instead send it to the search page.
      $searchForm.prop('action', pathToSiteRoot + 'search/index.html')
      $searchForm.find('input[name="as_sitesearch"]').remove()
    }

    function changeSearchLabel () {
      $searchLabel.text('Search this documentation')
    }

    this.isOnSearchPage = function isOnSearchPage () {
      return Boolean(window.location.pathname.match(/\/search(\/|\/index.html)?$/))
    }

    this.getQuery = function getQuery () {
      var query = decodeURIComponent(
        window.location.search
          .match(/q=([^&]*)/)[1]
          .replace(/\+/g, ' ')
      )
      return query
    }

    function doSearch (query, pathToSiteRoot) {
      s.search(query, function (r) {
        results = r
        renderResults(query, pathToSiteRoot)
        updateTitle()
      })
    }

    // TODO: remove this and sendQueryToAnalytics in a future breaking release
    function doAnalytics () {
      if (window.ga) {
        sendQueryToAnalytics()

        // Attach analytics events to search result clicks
        $searchResults.on('click', '.search-result__title a', function () {
          var href = $(this).attr('href')
          ga('send', {
            hitType: 'event',
            eventCategory: 'Search result',
            eventAction: 'click',
            eventLabel: href,
            transport: 'beacon'
          })
        })
      }
    }

    function getResults (query) {
      var results = []
      s.lunrIndex.search(query).forEach(function (item, index) {
        if (index < maxSearchEntries) {
          results.push(s.lunrData.docs[item.ref])
        }
      })
      return results
    }

    this.search = function search (query, callback) {
      if (query === '') {
        return
      }
      showResults()
      // The index has not been downloaded yet, exit early and wait.
      if (!s.lunrIndex) {
        $(document).on('lunrIndexLoaded', function () {
          s.search(query, callback)
        })
        return
      }
      callback(getResults(query))
    }

    function renderResults (query, pathToSiteRoot) {
      var output = ''
      if (results.length === 0) {
        output += '<p>Nothing found</p>'
      }
      output += '<ul>'
      for (var index in results) {
        var result = results[index]
        var content = s.processContent(result.content, query)
        output += '<li class="search-result">'
        output += '<h3 class="search-result__title">'
        var pagePathWithoutLeadingSlash = result.url.startsWith('/') ? result.url.slice(1) : result.url
        var url = pathToSiteRoot.startsWith('.') ? pathToSiteRoot + pagePathWithoutLeadingSlash : '/' + pagePathWithoutLeadingSlash
        output += '<a href="' + url + '">'
        output += result.title
        output += '</a>'
        output += '</h3>'
        if (typeof content !== 'undefined') {
          output += '<p>' + content + '</p>'
        }
        output += '</li>'
      }
      output += '</ul>'

      $searchResults.html(output)
    }

    this.processContent = function processContent (content, query) {
      var output
      var sanitizedContent = $('<div></div>').text(content).html()
      content = $('<div>' + sanitizedContent + '</div>').mark(query)

      // Split content by sentence.
      var sentences = content.html().replace(/(\.+|:|!|\?|\r|\n)("*|'*|\)*|}*|]*)/gm, '|').split('|')

      // Select the first five sentences that contain a <mark>
      var selectedSentences = []
      for (var i = 0; i < sentences.length; i++) {
        if (selectedSentences.length === 5) {
          break
        }

        var sentence = sentences[i].trim()
        var containsMark = sentence.includes('mark>')
        if (containsMark && (selectedSentences.indexOf(sentence) === -1)) {
          selectedSentences.push(sentence)
        }
      }
      if (selectedSentences.length > 0) {
        output = ' … ' + selectedSentences.join(' … ') + ' … '
      }
      return output
    }

    // Default text is to display the number of search results
    function updateTitle (text) {
      if (typeof text === 'undefined') {
        var count = results.length
        var resultsText = 'Search - ' + query + ' - ' + count + ' results'
      }
      $searchResultsTitle.text(text || resultsText)
    }

    function showResults () {
      $searchResultsWrapper.removeAttr('hidden')
      $searchHelp.attr('hidden', 'true')
    }

    function sendQueryToAnalytics () {
      if (query === '') {
        return
      }
      var stripped = window.stripPIIFromString(query)
      ga('send', {
        hitType: 'event',
        eventCategory: 'Search query',
        eventAction: 'type',
        eventLabel: stripped,
        transport: 'beacon'
      })
    }

    function replaceStopWordFilter () {
      // Replace the default stopWordFilter as it excludes useful words like
      // 'get'
      // See: https://lunrjs.com/docs/stop_word_filter.js.html#line43
      s.lunrIndex.pipeline.remove(lunr.stopWordFilter)
      s.lunrIndex.pipeline.add(s.govukStopWorldFilter)
    }

    this.govukStopWorldFilter = lunr.generateStopWordFilter([
      'a',
      'able',
      'about',
      'across',
      'after',
      'all',
      'almost',
      'also',
      'am',
      'among',
      'an',
      'and',
      'any',
      'are',
      'as',
      'at',
      'be',
      'because',
      'been',
      'but',
      'by',
      'can',
      'cannot',
      'could',
      'dear',
      'did',
      'do',
      'does',
      'either',
      'else',
      'ever',
      'every',
      'for',
      'from',
      'got',
      'had',
      'has',
      'have',
      'he',
      'her',
      'hers',
      'him',
      'his',
      'how',
      'however',
      'i',
      'if',
      'in',
      'into',
      'is',
      'it',
      'its',
      'just',
      'least',
      'let',
      'like',
      'likely',
      'may',
      'me',
      'might',
      'most',
      'must',
      'my',
      'neither',
      'no',
      'nor',
      'not',
      'of',
      'off',
      'often',
      'on',
      'only',
      'or',
      'other',
      'our',
      'own',
      'rather',
      'said',
      'say',
      'says',
      'she',
      'should',
      'since',
      'so',
      'some',
      'than',
      'that',
      'the',
      'their',
      'them',
      'then',
      'there',
      'these',
      'they',
      'this',
      'tis',
      'to',
      'too',
      'twas',
      'us',
      'wants',
      'was',
      'we',
      'were',
      'what',
      'when',
      'where',
      'which',
      'while',
      'who',
      'whom',
      'why',
      'will',
      'with',
      'would',
      'yet',
      'you',
      'your'
    ])
  }

  // Polyfill includes
  if (!String.prototype.includes) {
    String.prototype.includes = function (search, start) { // eslint-disable-line no-extend-native
      'use strict'
      if (typeof start !== 'number') {
        start = 0
      }

      if (start + search.length > this.length) {
        return false
      } else {
        return this.indexOf(search, start) !== -1
      }
    }
  }
})(jQuery, window.GOVUK.Modules)
