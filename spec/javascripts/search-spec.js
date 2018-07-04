describe('Search', function() {
  'use strict';

  var module;
  var content;
  var query;
  var processedContent;
  var expectedResults;

  beforeEach(function() {
    module = new GOVUK.Modules.Search();
    query = 'test';
    content = 'This sentence should not be shown. This is test sentence one. This is test sentence two? This is test sentence three:\nThis is test sentence four! This sentence should not be shown! This is test sentence five\n'
    processedContent = module.processContent(content, query);
  });

  it('returns concatenated sentences that contain the search query', function() {
    expectedResults = ' … This is <mark data-markjs="true">test</mark> sentence one … This is <mark data-markjs="true">test</mark> sentence two … This is <mark data-markjs="true">test</mark> sentence three … This is <mark data-markjs="true">test</mark> sentence four … This is <mark data-markjs="true">test</mark> sentence five … '
    expect(processedContent).toEqual(expectedResults)
  });

});
