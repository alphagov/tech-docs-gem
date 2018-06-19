//= require lunr.min
(function($, Modules) {
  'use strict';

  Modules.Search = function Search() {
    var $html = $('html');
    var lunrIndex;
    var lunrData;
    var $searchInput;
    var $searchResults;
    var $searchResultsWrapper;
    var results;
    var maxSearchEntries = 10;

    this.start = function start($element) {
      $searchInput = $('#search');
      $searchResultsWrapper = $('.search-results')
      $searchResults = $searchResultsWrapper.find('.search-results__content');
      downloadSearchIndex();
      attach();
    };

    function downloadSearchIndex() {
      $searchResults.addClass('is-loading-index');
      $.ajax({
        url: '/search.json',
        cache: true,
        method: 'GET',
        success: function(data) {
          lunrData = data;
          lunrIndex = lunr.Index.load(lunrData.index);
          $searchResults.removeClass('is-loading-index');
        }
      });
    }

    function attach() {
      $searchInput.on('input', function (e) {
        e.preventDefault();
        showResults();
        // The index has not been downloaded yet, exit early.
        // Todo: Be more useful.
        if(!lunrIndex) {
          return;
        }
        var query = $(this).val();
        if(query === '') {
          hideResults();
          return;
        }
        results = searchIndex(query);
        renderResults();
      });
    }

    function searchIndex(query) {
      var results = [];
      lunrIndex.search(query).forEach( function (item, index) {
        if ( index < maxSearchEntries ) {
          results.push(lunrData.docs[item.ref]);
        }
      });

      return results;
    }

    function renderResults() {
      var output = '';
      if (results.length == 0) {
        output += '<p>Nothing found</p>';
      }
      output += '<ul>';
      for(var index in results) {
        var result = results[index];
        output += '<li class="search-result">';
        output += '<h3 class="search-result__title">';
        output += '<a href="' + result.url + '">';
        output += result.title;
        output += '</a>';
        output += '</h3>';
        output += '</li>';
      }
      output += '</ul>';        

      $searchResults.html( output );
    }

    function showResults() {
      $searchResultsWrapper.addClass('is-open');
      $searchResults.attr('aria-hidden', 'false');
      $html.addClass('has-search-results-open');
    }

    function hideResults() {
      $searchResultsWrapper.removeClass('is-open');
      $searchResults.attr('aria-hidden', 'true');
      $html.removeClass('has-search-results-open');
    }
  };
})(jQuery, window.GOVUK.Modules);



