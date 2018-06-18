//= require lunr.min
(function($, Modules) {
  'use strict';

  Modules.Search = function Search() {
    var lunrIndex;
    var lunrData;
    var $searchInput;
    var $searchResults;

    this.start = function start($element) {
      $searchInput = $('#search');
      $searchResults = $('.search-results__content');
      downloadSearchIndex();
      searchAsYouType();
    };

    function downloadSearchIndex() {
      $.ajax({
        url: '/search.json',
        cache: true,
        method: 'GET',
        success: function(data) {
          lunrData = data;
          lunrIndex = lunr.Index.load(lunrData.index);
        }
      });
    }

    function searchAsYouType() {
      $searchInput.on('input', function (e) {
        e.preventDefault();
        var query = $(this).val();
        var max_search_entries = 50;
        var results = []; //initialize empty array
        
        lunrIndex.search(query).forEach( function (item, index) {
          if ( index < max_search_entries ) {
            results.push(lunrData.docs[item.ref]);
          }
        });

        var output = '';
        if (results.length == 0) {
          output = '<h2 class="minor-text">Nothing found</h2>';
        }
        for(var index in results) {
          var result = results[index];
          output += '<div class="search-result">';
          output += '<a href="' + result.url + '">';
          output += '<h2 class="search-result__title">';
          output += result.title;
          output += '</h2>';
          output += '</a>';
          output += '</div>';
        }

        $searchResults.html( output );

      });
    }
  };
})(jQuery, window.GOVUK.Modules);



