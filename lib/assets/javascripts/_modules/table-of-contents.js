(function ($, Modules) {
  'use strict'

  Modules.TableOfContents = function () {
    var $html = $('html')

    var $toc
    var $tocList

    var $openButton
    var $closeButton

    this.start = function ($element) {
      $toc = $element
      $tocList = $toc.find('.js-toc-list')
      // Open link is not inside the module
      $openButton = $html.find('.js-toc-show')
      $closeButton = $toc.find('.js-toc-close')

      fixRubberBandingInIOS()
      updateAriaAttributes()

      // Need delegated handler for show link as sticky polyfill recreates element
      $openButton.on('click.toc', preventingScrolling(openNavigation))
      $closeButton.on('click.toc', preventingScrolling(closeNavigation))
      $tocList.on('click.toc', 'a', closeNavigation)

      // Allow aria hidden to be updated when resizing from mobile to desktop or
      // vice versa
      $(window).on('resize.toc', updateAriaAttributes)

      $(document).on('keydown.toc', function (event) {
        var ESC_KEY = 27

        if (event.keyCode === ESC_KEY) {
          closeNavigation()
        }
      })
    }

    function fixRubberBandingInIOS () {
      // By default when the table of contents is at the top or bottom,
      // scrolling in that direction will scroll the body 'behind' the table of
      // contents. Fix this by preventing ever reaching the top or bottom of the
      // table of contents (by 1 pixel).
      //
      // http://blog.christoffer.me/six-things-i-learnt-about-ios-safaris-rubber-band-scrolling/
      $toc.on('touchstart.toc', function () {
        var $this = $(this)
        var top = $this.scrollTop()
        var totalScroll = $this.prop('scrollHeight')
        var currentScroll = top + $this.prop('offsetHeight')

        if (top === 0) {
          $this.scrollTop(1)
        } else if (currentScroll === totalScroll) {
          $this.scrollTop(top - 1)
        }
      })
    }

    function openNavigation () {
      $html.addClass('toc-open')

      toggleBackgroundVisiblity(false)
      updateAriaAttributes()
      $toc.focus()
    }

    function closeNavigation () {
      $html.removeClass('toc-open')

      toggleBackgroundVisiblity(true)
      updateAriaAttributes()
    }

    function toggleBackgroundVisiblity (visibility) {
      $('.toc-open-disabled').attr('aria-hidden', visibility ? '' : 'true')
    }

    function updateAriaAttributes () {
      var tocIsVisible = $toc.is(':visible')

      $($openButton).add($closeButton)
        .attr('aria-expanded', tocIsVisible ? 'true' : 'false')

      $toc.attr('aria-hidden', tocIsVisible ? 'false' : 'true')
    }

    function preventingScrolling (callback) {
      return function (event) {
        event.preventDefault()
        callback()
      }
    }
  }
})(jQuery, window.GOVUK.Modules)
