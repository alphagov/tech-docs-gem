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
    $element = $('<div class="search" data-module="search">' +
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
    // Construct a dummy search index
    module.downloadSearchIndex = function downloadSearchIndex () {
      module.lunrData = JSON.parse('{"index": {"version":"0.7.0","fields":[{"name":"title","boost":100},{"name":"content","boost":50}],"ref":"id","tokenizer":"default","documentStore":{"store":{"16":["child","expir","highlight","navig","page"],"17":["banner","expir","page","see"],"18":["banner","expir","page","see"],"20":["banner","expir","owner","page","see"],"22":["addit","alway","chang","content","control","detail","document","edit","editor","exampl","favourit","file","gov.uk","hello","html","includ","look","markdown","more","need","open","page","project","readme.md","root","slightli","source/documentation/index.md","source/index.html.md.erb","start","syntax","take","text","titl","troubleshoot","us","usual","want","world!edit","write","you’ll","you’r"],"23":["page","proxi"]},"length":6},"tokenStore":{"root":{"docs":{},"c":{"docs":{},"h":{"docs":{},"i":{"docs":{},"l":{"docs":{},"d":{"docs":{"16":{"ref":16,"tf":40.47619047619047}}}}},"a":{"docs":{},"n":{"docs":{},"g":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}},"o":{"docs":{},"n":{"docs":{},"t":{"docs":{},"e":{"docs":{},"n":{"docs":{},"t":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}},"r":{"docs":{},"o":{"docs":{},"l":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}}},"e":{"docs":{},"x":{"docs":{},"p":{"docs":{},"i":{"docs":{},"r":{"docs":{"16":{"ref":16,"tf":47.61904761904761},"17":{"ref":17,"tf":60},"18":{"ref":18,"tf":60},"20":{"ref":20,"tf":58.33333333333333}}}}},"a":{"docs":{},"m":{"docs":{},"p":{"docs":{},"l":{"docs":{"22":{"ref":22,"tf":33.33333333333333}}}}}}},"d":{"docs":{},"i":{"docs":{},"t":{"docs":{"22":{"ref":22,"tf":2.3255813953488373}},"o":{"docs":{},"r":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}},"h":{"docs":{},"i":{"docs":{},"g":{"docs":{},"h":{"docs":{},"l":{"docs":{},"i":{"docs":{},"g":{"docs":{},"h":{"docs":{},"t":{"docs":{"16":{"ref":16,"tf":7.142857142857142}}}}}}}}}},"e":{"docs":{},"l":{"docs":{},"l":{"docs":{},"o":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}},"t":{"docs":{},"m":{"docs":{},"l":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}},"n":{"docs":{},"a":{"docs":{},"v":{"docs":{},"i":{"docs":{},"g":{"docs":{"16":{"ref":16,"tf":7.142857142857142}}}}}},"e":{"docs":{},"e":{"docs":{},"d":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}},"p":{"docs":{},"a":{"docs":{},"g":{"docs":{},"e":{"docs":{"16":{"ref":16,"tf":47.61904761904761},"17":{"ref":17,"tf":70},"18":{"ref":18,"tf":70},"20":{"ref":20,"tf":66.66666666666666},"22":{"ref":22,"tf":1.1627906976744187},"23":{"ref":23,"tf":75}}}}},"r":{"docs":{},"o":{"docs":{},"j":{"docs":{},"e":{"docs":{},"c":{"docs":{},"t":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}},"x":{"docs":{},"i":{"docs":{"23":{"ref":23,"tf":75}}}}}}},"b":{"docs":{},"a":{"docs":{},"n":{"docs":{},"n":{"docs":{},"e":{"docs":{},"r":{"docs":{"17":{"ref":17,"tf":10},"18":{"ref":18,"tf":10},"20":{"ref":20,"tf":8.333333333333332}}}}}}}},"s":{"docs":{},"e":{"docs":{},"e":{"docs":{"17":{"ref":17,"tf":10},"18":{"ref":18,"tf":10},"20":{"ref":20,"tf":8.333333333333332}}}},"l":{"docs":{},"i":{"docs":{},"g":{"docs":{},"h":{"docs":{},"t":{"docs":{},"l":{"docs":{},"i":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}}},"o":{"docs":{},"u":{"docs":{},"r":{"docs":{},"c":{"docs":{},"e":{"docs":{},"/":{"docs":{},"d":{"docs":{},"o":{"docs":{},"c":{"docs":{},"u":{"docs":{},"m":{"docs":{},"e":{"docs":{},"n":{"docs":{},"t":{"docs":{},"a":{"docs":{},"t":{"docs":{},"i":{"docs":{},"o":{"docs":{},"n":{"docs":{},"/":{"docs":{},"i":{"docs":{},"n":{"docs":{},"d":{"docs":{},"e":{"docs":{},"x":{"docs":{},".":{"docs":{},"m":{"docs":{},"d":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}}}}}}}}}}}}}}}}}},"i":{"docs":{},"n":{"docs":{},"d":{"docs":{},"e":{"docs":{},"x":{"docs":{},".":{"docs":{},"h":{"docs":{},"t":{"docs":{},"m":{"docs":{},"l":{"docs":{},".":{"docs":{},"m":{"docs":{},"d":{"docs":{},".":{"docs":{},"e":{"docs":{},"r":{"docs":{},"b":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}}}}}}}}}}}}}}}}}}},"t":{"docs":{},"a":{"docs":{},"r":{"docs":{},"t":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}},"y":{"docs":{},"n":{"docs":{},"t":{"docs":{},"a":{"docs":{},"x":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}},"o":{"docs":{},"w":{"docs":{},"n":{"docs":{},"e":{"docs":{},"r":{"docs":{"20":{"ref":20,"tf":8.333333333333332}}}}}},"p":{"docs":{},"e":{"docs":{},"n":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}},"a":{"docs":{},"d":{"docs":{},"d":{"docs":{},"i":{"docs":{},"t":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}},"l":{"docs":{},"w":{"docs":{},"a":{"docs":{},"y":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}},"d":{"docs":{},"e":{"docs":{},"t":{"docs":{},"a":{"docs":{},"i":{"docs":{},"l":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}},"o":{"docs":{},"c":{"docs":{},"u":{"docs":{},"m":{"docs":{},"e":{"docs":{},"n":{"docs":{},"t":{"docs":{"22":{"ref":22,"tf":33.33333333333333}}}}}}}}}},"f":{"docs":{},"a":{"docs":{},"v":{"docs":{},"o":{"docs":{},"u":{"docs":{},"r":{"docs":{},"i":{"docs":{},"t":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}}},"i":{"docs":{},"l":{"docs":{},"e":{"docs":{"22":{"ref":22,"tf":2.3255813953488373}}}}}},"g":{"docs":{},"o":{"docs":{},"v":{"docs":{},".":{"docs":{},"u":{"docs":{},"k":{"docs":{"22":{"ref":22,"tf":33.33333333333333}}}}}}}},"i":{"docs":{},"n":{"docs":{},"c":{"docs":{},"l":{"docs":{},"u":{"docs":{},"d":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}},"l":{"docs":{},"o":{"docs":{},"o":{"docs":{},"k":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}},"m":{"docs":{},"a":{"docs":{},"r":{"docs":{},"k":{"docs":{},"d":{"docs":{},"o":{"docs":{},"w":{"docs":{},"n":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}}},"o":{"docs":{},"r":{"docs":{},"e":{"docs":{"22":{"ref":22,"tf":2.3255813953488373}}}}}},"r":{"docs":{},"e":{"docs":{},"a":{"docs":{},"d":{"docs":{},"m":{"docs":{},"e":{"docs":{},".":{"docs":{},"m":{"docs":{},"d":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}}}},"o":{"docs":{},"o":{"docs":{},"t":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}},"t":{"docs":{},"a":{"docs":{},"k":{"docs":{},"e":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}},"e":{"docs":{},"x":{"docs":{},"t":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}},"i":{"docs":{},"t":{"docs":{},"l":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}},"r":{"docs":{},"o":{"docs":{},"u":{"docs":{},"b":{"docs":{},"l":{"docs":{},"e":{"docs":{},"s":{"docs":{},"h":{"docs":{},"o":{"docs":{},"o":{"docs":{},"t":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}}}}}}}},"u":{"docs":{},"s":{"docs":{"22":{"ref":22,"tf":3.488372093023256}},"u":{"docs":{},"a":{"docs":{},"l":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}},"w":{"docs":{},"a":{"docs":{},"n":{"docs":{},"t":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}},"o":{"docs":{},"r":{"docs":{},"l":{"docs":{},"d":{"docs":{},"!":{"docs":{},"e":{"docs":{},"d":{"docs":{},"i":{"docs":{},"t":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}}}}},"r":{"docs":{},"i":{"docs":{},"t":{"docs":{},"e":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}},"y":{"docs":{},"o":{"docs":{},"u":{"docs":{},"’":{"docs":{},"l":{"docs":{},"l":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}},"r":{"docs":{"22":{"ref":22,"tf":1.1627906976744187}}}}}}}},"length":61},"corpusTokens":["addit","alway","banner","chang","child","content","control","detail","document","edit","editor","exampl","expir","favourit","file","gov.uk","hello","highlight","html","includ","look","markdown","more","navig","need","open","owner","page","project","proxi","readme.md","root","see","slightli","source/documentation/index.md","source/index.html.md.erb","start","syntax","take","text","titl","troubleshoot","us","usual","want","world!edit","write","you’ll","you’r"],"pipeline":["trimmer","stopWordFilter","stemmer"]}, "docs": {"16":{"title":"This is a child of expired page","content":"This is a child of expired page\\nExpired page should highlight in the navigation.\\n","url":"/child-of-expired-page.html"},"17":{"title":"This is an expired page","content":"This is not an expired page\\nSee the banner on this page.\\n","url":"/not-expired-page.html"},"18":{"title":"This is an expired page","content":"This is an expired page\\nSee the banner on this page.\\n","url":"/expired-page.html"},"20":{"title":"This is an expired page","content":"This is an expired page with owner\\nSee the banner on this page.\\n","url":"/expired-page-with-owner.html"},"22":{"title":"GOV.UK Documentation Example","content":"Hello, World!Edit Me!\\nOpen source/documentation/index.md in your favourite text editor and start editing!\\n\\nYou can write content in Markdown using all of the usual syntax that you’re used to!\\n\\nTo change the title of the page or include additional files you’ll need to edit source/index.html.md.erb.\\n\\nIf you want slightly more control, you can always use HTML.\\n\\nFor more detail and troubleshooting, take a look at the README.md file in the root of this project.\\n","url":"/"},"23":{"title":"Proxied page","content":"Proxied page\\nThis is a proxied page.\\n","url":"/a-proxied-page.html"}}}')
      module.lunrIndex = lunr.Index.load(module.lunrData.index)
    }
    module.start($element)

    query = 'test'
    content = 'This sentence should not be shown. This is test sentence one. This is test sentence two? This is test sentence three:\nThis is test sentence four! This sentence should not be shown! This is test sentence five\n'
    processedContent = module.processContent(content, query)
    module.search('expired', function (r) {
      searchResults = r
    })
  })

  it('returns concatenated sentences that contain the search query', function () {
    var expectedResults = ' … This is <mark data-markjs="true">test</mark> sentence one … This is <mark data-markjs="true">test</mark> sentence two … This is <mark data-markjs="true">test</mark> sentence three … This is <mark data-markjs="true">test</mark> sentence four … This is <mark data-markjs="true">test</mark> sentence five … '
    expect(processedContent).toEqual(expectedResults)
  })

  it('renders search results in the search results area', function () {
    var expectedResults = [
      {
        title: 'This is an expired page',
        content: 'This is not an expired page\nSee the banner on this page.\n',
        url: '/not-expired-page.html'
      },
      {
        title: 'This is an expired page',
        content: 'This is an expired page\nSee the banner on this page.\n',
        url: '/expired-page.html'
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
})
