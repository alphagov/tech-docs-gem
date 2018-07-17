//= require lunr.min
//= require _vendor/jquery.mark.js
(function($, Modules) {
  'use strict';

  Modules.Search = function Search() {
    var s = this;
    var $html = $('html');
    s.lunrIndex;
    s.lunrData;
    var $searchForm;
    var $searchInput;
    var $searchResults;
    var $searchResultsTitle;
    var $searchResultsWrapper;
    var $searchResultsClose;
    var results;
    var maxSearchEntries = 10;

    this.start = function start($element) {
      $searchForm = $element.find('form');
      $searchInput = $element.find('#search');
      $searchResultsWrapper = $element.find('.search-results')
      $searchResults = $searchResultsWrapper.find('.search-results__content');
      $searchResultsTitle = $searchResultsWrapper.find('.search-results__title');
      $searchResultsClose = $searchResultsWrapper.find('.search-results__close');
      s.downloadSearchIndex();
      attach();
    };

    this.downloadSearchIndex = function downloadSearchIndex() {
      updateTitle('Loading search index')
      $.ajax({
        url: '/search.json',
        cache: true,
        method: 'GET',
        success: function(data) {
          s.lunrData = data;
          s.lunrIndex = lunr.Index.load(s.lunrData.index);
          $(document).trigger('lunrIndexLoaded');
        }
      });
    }

    function attach() {
      // Search functionality on search text input
      $searchInput.on('input', function (e) {
        e.preventDefault();
        var query = $(this).val();
        s.search(query, function(r) {
          results = r;
          renderResults(query);
          updateTitle();
        });
      });

      // Set focus on the first search result instead of submiting the search
      // form to Google
      $searchForm.on('submit', function(e) {
        e.preventDefault();
        $searchResults.find('.search-result__title a').first().focus();
      });

      // Closing the search results, move focus back to the search input
      $searchResultsClose.on('click', function(e) {
        e.preventDefault();
        $searchInput.focus();
        hideResults();
      });
    }

    function getResults(query) {
      var results = [];
      s.lunrIndex.search(query).forEach( function (item, index) {
        if ( index < maxSearchEntries ) {
          results.push(s.lunrData.docs[item.ref]);
        }
      });

      return results;
    }

    this.search = function search(query, callback) {
      if(query === '') {
        hideResults();
        return;
      }
      showResults();
      // The index has not been downloaded yet, exit early and wait.
      if(!s.lunrIndex) {
        $(document).on('lunrIndexLoaded', function() {
          s.search(query, callback);
        });
        return;
      }
      callback(getResults(query));
    }

    function renderResults(query) {
      var output = '';
      if (results.length == 0) {
        output += '<p>Nothing found</p>';
      }
      output += '<ul>';
      for(var index in results) {
        var result = results[index];
        var content = s.processContent(result.content, query);
        output += '<li class="search-result">';
        output += '<h3 class="search-result__title">';
        output += '<a href="' + result.url + '">';
        output += result.title;
        output += '</a>';
        output += '</h3>';
        if(typeof content !== 'undefined') {
          output += '<p>' + content + '</p>';
        }
        output += '</li>';
      }
      output += '</ul>';

      $searchResults.html( output );
    }

    this.processContent = function processContent(content, query) {
      var output;
      content = '<div>'+  content + '</div>';
      content = $(content).mark(query);

      // Split content by sentence.
      var sentences = content.html().replace(/(\.+|\:|\!|\?|\r|\n)(\"*|\'*|\)*|}*|]*)/gm, "|").split("|");

      // Select the first five sentences that contain a <mark>
      var selectedSentences = [];
      for (var i = 0; i < sentences.length; i++) {
        if(selectedSentences.length === 5) {
          break;
        }

        var containsMark = sentences[i].includes('mark>');
        if (containsMark) {
          selectedSentences.push(sentences[i].trim());
        }
      }
      if(selectedSentences.length > 0) {
        output = ' … ' + selectedSentences.join(' … ') + ' … ';
      }
      return output;
    }

    // Default text is to display the number of search results
    function updateTitle(text) {
      if(typeof text == "undefined") {
        var count = results.length;
        var text = count + ' results';
      }
      $searchResultsTitle.text(text);
    }

    function showResults() {
      $searchResultsWrapper.addClass('is-open')
      .attr('aria-hidden', 'false');
      $html.addClass('has-search-results-open');
    }

    function hideResults() {
      $searchResultsWrapper.removeClass('is-open')
      .attr('aria-hidden', 'true');
      $html.removeClass('has-search-results-open');
    }
  };

  // Polyfill includes
  if (!String.prototype.includes) {
    String.prototype.includes = function(search, start) {
      'use strict';
      if (typeof start !== 'number') {
        start = 0;
      }

      if (start + search.length > this.length) {
        return false;
      } else {
        return this.indexOf(search, start) !== -1;
      }
    };
  }
})(jQuery, window.GOVUK.Modules);



