//= require lunr.min
//= require _vendor/jquery.mark.js
(function($, Modules) {
  'use strict';

  Modules.Search = function Search() {
    var $html = $('html');
    var lunrIndex;
    var lunrData;
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
      downloadSearchIndex();
      attach();
    };

    function downloadSearchIndex() {
      updateTitle('Loading search index')
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

    function attach() {
      $searchInput.on('input', function (e) {
        e.preventDefault();
        showResults();
        // The index has not been downloaded yet, exit early.
        if(!lunrIndex) {
          return;
        }
        var query = $(this).val();
        if(query === '') {
          hideResults();
          return;
        }
        results = searchIndex(query);
        renderResults(query);
        updateTitle();
      });

      $searchForm.on('submit', function(e) {
        e.preventDefault();
        // Set focus on the first search result instead of submiting to Google.
        $searchResults.find('.search-result__title a').first().focus();
      });

      $searchResultsClose.on('click', function(e) {
        e.preventDefault();
        // Move focus back to the search input.
        $searchInput.focus();
        hideResults();
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

    function renderResults(query) {
      var output = '';
      if (results.length == 0) {
        output += '<p>Nothing found</p>';
      }
      output += '<ul>';
      for(var index in results) {
        var result = results[index];
        var content = processContent(result.content, query);
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

    function processContent(content, query) {
      var output;
      content = '<div>'+  content + '</div>'; 
      content = $(content).mark(query);

      // Split content by sentence.
      var sentences = content.html().replace(/(\.+|\:|\!|\?|\r|\n)(\"*|\'*|\)*|}*|]*)/gm, "|").split("|");

      // Select the first five sentences that contain a <mark>
      var selectedSentences = [];
      for (var i = sentences.length - 1; i >= 0; i--) {
        if(selectedSentences.length >= 4) {
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
        var text = count + ' Results';        
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
})(jQuery, window.GOVUK.Modules);



