(function ($, Modules) {
  'use strict'

  // Most of the code below is gratefully taken from:
  // https://www.tpgi.com/prevent-focused-elements-from-being-obscured-by-sticky-headers/
  var StickyOverlapMonitors = function ($sticky) {
    this.$sticky = $sticky
    this.offset = 0
    this.onFocus = this.showObscured.bind(this)
    this.isMonitoring = false
  }
  StickyOverlapMonitors.prototype.run = function () {
    var stickyIsVisible = this.$sticky.length > 0 && this.$sticky.is(':visible')
    if (stickyIsVisible && !this.isMonitoring) {
      document.addEventListener('focus', this.onFocus, true)
      this.isMonitoring = true
    }
    if (!stickyIsVisible && this.isMonitoring) {
      document.removeEventListener('focus', this.onFocus, true)
      this.isMonitoring = false
    }
  }
  StickyOverlapMonitors.prototype.showObscured = function () {
    var focused = document.activeElement || document.body
    var applicable = focused !== document.body

    if (!applicable) { return }

    if (this.$sticky && this.$sticky.is(':visible') && this.$sticky.get(0)) {
      var stickyEdge = this.$sticky.get(0).getBoundingClientRect().bottom + this.offset
      var diff = focused.getBoundingClientRect().top - stickyEdge

      if (diff < 0) {
        $(window).scrollTop($(window).scrollTop() + diff)
      }
    }
  }

  Modules.TableOfContents = function () {
    var $html = $('html')

    var $toc
    var $tocList

    var $openButton
    var $closeButton

    var stickyOverlapMonitors

    this.start = function ($element) {
      $toc = $element
      $tocList = $toc.find('.js-toc-list')
      // Open link is not inside the module
      $openButton = $html.find('.js-toc-show')
      $closeButton = $toc.find('.js-toc-close')

      fixRubberBandingInIOS()
      updateAriaAttributes()
      stickyOverlapMonitors = new StickyOverlapMonitors($('.fixedsticky'))
      stickyOverlapMonitors.run()

      // Need delegated handler for show link as sticky polyfill recreates element
      $openButton.on('click.toc', preventingScrolling(openNavigation))
      $closeButton.on('click.toc', preventingScrolling(closeNavigation))
      $tocList.on('click.toc', 'a', closeNavigation)

      // Allow aria hidden to be updated when resizing from mobile to desktop or
      // vice versa
      $(window).on('resize.toc', function () {
        updateAriaAttributes()
        stickyOverlapMonitors.run()
      })

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

      updateAriaAttributes()
      $toc.focus()
    }

    function closeNavigation () {
      $html.removeClass('toc-open')

      updateAriaAttributes()
      $openButton.focus()
    }

    function updateAriaAttributes () {
      var tocIsVisible = $toc.is(':visible')
      var tocIsDialog = $openButton.is(':visible')

      $($openButton).add($closeButton)
        .attr('aria-expanded', tocIsVisible ? 'true' : 'false')

      $toc.attr({
        'aria-hidden': tocIsVisible ? 'false' : 'true',
        role: tocIsDialog ? 'dialog' : null
      })

      $('.app-pane__content').attr('aria-hidden', (tocIsDialog && tocIsVisible) ? 'true' : 'false')

      // only make main content pane focusable if it scrolls independently of the toc
      if (!tocIsDialog) {
        $('.app-pane__content').attr('tabindex', '0')
      } else {
        $('.app-pane__content').removeAttr('tabindex')
      }
    }

    function preventingScrolling (callback) {
      return function (event) {
        event.preventDefault()
        callback()
      }
    }
  }
})(jQuery, window.GOVUK.Modules)
