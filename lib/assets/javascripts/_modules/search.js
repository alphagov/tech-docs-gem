//= require lunr.min
//= require _vendor/jquery.mark.js
(function ($, Modules) {
  'use strict'

  Modules.Search = function Search () {
    var s = this
    var $html = $('html')
    var $header
    var $headerContent
    var $tocNav
    var $mainContent
    var $searchContainer
    var $searchForm
    var $searchLabel
    var $searchInput
    var $searchResults
    var $searchResultsTitle
    var $searchResultsWrapper
    var $searchResultsClose
    var results
    var query
    var maxSearchEntries = 20

    this.start = function start ($element) {
      $header = $html.find('.app-pane__header')
      $headerContent = $header.find('.govuk-header__content')
      $searchContainer = $html.find('.search')
      $searchForm = $element.find('form')
      $searchInput = $element.find('#search')
      $searchLabel = $element.find('.search__label')
      $searchResultsWrapper = $element.find('.search-results')
      $searchResults = $searchResultsWrapper.find('.search-results__content')
      $searchResultsTitle = $searchResultsWrapper.find('.search-results__title')
      $searchResultsClose = $searchResultsWrapper.find('.search-results__close')
      $mainContent = $html.find('.app-pane__content')
      $tocNav = $('#toc')
      s.downloadSearchIndex()
      attach()
      changeSearchLabel()
    }

    this.downloadSearchIndex = function downloadSearchIndex () {
      updateTitle('Loading search index')
      $.ajax({
        url: '/search.json',
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

    function attach () {
      // Set focus on the results close link instead of submiting the search
      // form to Google
      $searchForm.on('submit', function (e) {
        e.preventDefault()

        query = $searchInput.val()
        s.search(query, function (r) {
          results = r
          renderResults(query)
          updateTitle()
        })
        if (window.ga) {
          sendQueryToAnalytics()
        }

        showResults()
        var $closeButton = $searchResultsWrapper.find('.search-results__close')
        $closeButton.focus()
        updateTitle()
      })

      // Closing the search results, move focus back to the search input
      $searchResultsClose.on('click', function (e) {
        e.preventDefault()
        $searchInput.focus()
        hideResults()
      })

      // Attach analytics events to search result clicks
      if (window.ga) {
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

      // When selecting navigation link, close the search results.
      $('#toc').on('click', 'a', function (e) {
        hideResults()
      })
    }

    function changeSearchLabel () {
      $searchLabel.text('Search this documentation')
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
        hideResults()
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

    function renderResults (query) {
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
        output += '<a href="' + result.url + '">'
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
      content = '<div>' + content + '</div>'
      content = $(content).mark(query)

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
        var count = results ? results.length : 0
        var resultsText = count + ' results'
      }
      $searchResultsTitle.text(text || resultsText)
    }

    function showResults () {
      $searchResultsWrapper.addClass('is-open')
        .attr('aria-hidden', 'false')
      $searchContainer.attr('aria-modal', 'true')
      $mainContent.prop('inert', true)
      $tocNav.prop('inert', true)
      $header.prop('inert', true)
      $headerContent.prop('inert', true)
      $html.addClass('has-search-results-open')
      $tocNav.addClass('search-results-open')
    }

    function hideResults () {
      $searchResultsWrapper.removeClass('is-open')
        .attr('aria-hidden', 'true')
      $searchContainer.attr('aria-modal', 'false')
      $mainContent.prop('inert', false)
      $tocNav.prop('inert', false)
      $header.prop('inert', false)
      $headerContent.prop('inert', false)
      $html.removeClass('has-search-results-open')
      $tocNav.removeClass('search-results-open')
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
