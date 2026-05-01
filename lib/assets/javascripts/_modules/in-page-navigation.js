(function ($, Modules) {
  'use strict'

  Modules.InPageNavigation = function InPageNavigation () {
    let $contentPane
    let $tocItems
    let $targets

    this.start = function start ($element) {
      $contentPane = $element.find('.app-pane__content')
      $tocItems = $('.js-toc-list').find('a')
      $targets = $contentPane.find('[id]')

      $contentPane.on('scroll', _.debounce(handleScrollEvent, 100, { maxWait: 100 }))

      if (Modernizr.history) {
        // Popstate is triggered when using the back button to navigate 'within'
        // the page, i.e. changing the anchor part of the URL.
        $(window).on('popstate', function (event) {
          restoreScrollPosition(event.originalEvent.state)
        })

        if (history.state && history.state.scrollTop) {
          // Restore existing state when e.g. using the back button to return to
          // this page
          restoreScrollPosition(history.state)
        } else {
          // Store the initial position so that we can restore it even if we
          // never scroll.
          window.requestAnimationFrame(handleInitialLoadEvent)
        }
      }
    }

    function restoreScrollPosition (state) {
      if (state && typeof state.scrollTop !== 'undefined') {
        $contentPane.scrollTop(state.scrollTop)
      }
    }

    function handleInitialLoadEvent () {
      let fragment = fragmentForTargetElement()

      if (!fragment) {
        fragment = fragmentForFirstElementInView()
      }

      highlightActiveItemInToc(fragment)
    }

    function handleScrollEvent () {
      const fragment = fragmentForFirstElementInView()

      storeCurrentPositionInHistoryApi(fragment)
      highlightActiveItemInToc(fragment)
    }

    function storeCurrentPositionInHistoryApi (fragment) {
      if (Modernizr.history && fragment) {
        history.replaceState(
          { scrollTop: $contentPane.scrollTop() },
          '',
          fragment
        )
      }
    }

    function highlightActiveItemInToc (fragment) {
      // Navigation items for single page navigation don't necessarily include the path name, but
      // navigation items for multipage navigation items do include it. This checks for either case.
      let $activeTocItem = $tocItems.filter(function (_) {
        const url = new URL($(this).attr('href'), window.location.href)
        return url.href === window.location.href
      })

      // Navigation items with children don't contain fragments in their url
      // Check to see if any nav items contain just the path name.
      if (!$activeTocItem.get(0)) {
        $activeTocItem = $tocItems.filter(function (_) {
          const url = new URL($(this).attr('href'), window.location.href)
          return url.hash === '' && url.pathname === window.location.pathname
        })
      }
      if ($activeTocItem.get(0)) {
        $tocItems.removeClass('toc-link--in-view')
        $activeTocItem.addClass('toc-link--in-view')
        scrollTocToActiveItem($activeTocItem)
      }
    }

    function scrollTocToActiveItem ($activeTocItem) {
      const el = $activeTocItem.get(0)
      if (el && typeof el.scrollIntoView === 'function') {
        el.scrollIntoView({ block: 'nearest', inline: 'nearest' })
      }
    }

    function fragmentForTargetElement () {
      return window.location.hash
    }

    function fragmentForFirstElementInView () {
      let result = null

      $($targets.get().reverse()).each(function checkIfInView (index) {
        if (result) {
          return
        }

        const $this = $(this)

        if (Math.floor($this.position().top) <= 0) {
          result = $this
        }
      })

      return result ? '#' + result.attr('id') : false
    }
  }
})(jQuery, window.GOVUK.Modules)
