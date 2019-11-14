describe('Collapsible navigation', function () {
  'use strict'

  var module
  var $navigation

  beforeEach(function () {
    module = new GOVUK.Modules.CollapsibleNavigation()
    $navigation = $(`
      <nav id="toc" class="js-toc-list toc__list" aria-labelledby="toc-heading" data-module="collapsible-navigation">
        <ul>
          <li>
            <a href="/nested-page/"><span>Nested page</span></a>
            <ul>
              <li>
                <a href="/nested-page/another-nested-page/#another-nested-page"><span>Another nested page</span></a>
              </li>
            </ul>
            <ul>
              <li>
                <a href="/nested-page/another-nested-nested-page/#another-nested-nested-page"><span>Another nested nested page</span></a>
              </li>
            </ul>
          </li>
        </ul>
      </nav>`)
    module.start($navigation)
  })

  it('sanitizes headings to unique IDs correctly', function () {
    $navigation.find('ul > li > ul').each(function (i) {
      expect($(this)[0].id).toEqual('toc-nested-page-' + i)
    })
  })
})
