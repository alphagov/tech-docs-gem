describe('Table of contents', function () {
  'use strict'

  // global variables
  var $html
  var $tocBase
  var $toc
  var $closeButton
  var $openButton
  var $tocStickyHeader
  var module

  beforeAll(function () {
    $html = $('html')
    $tocBase = $(
      '<div class="toc" data-module="table-of-contents" tabindex="-1" aria-label="Table of contents">' +
        '<div class="search" data-module="search" data-path-to-site-root="/">' +
          '<form action="/search/index.html" method="get" role="search" class="search__form govuk-!-margin-bottom-4">' +
            '<label class="govuk-label search__label" for="search">Search this documentation</label>' +
            '<input type="text" id="search" name="q" class="govuk-input govuk-!-margin-bottom-0 search__input" aria-controls="search-results" placeholder="Search">' +
            '<button type="submit" class="search__button">Search</button>' +
          '</form>' +
        '</div>' +
        '<button type="button" class="toc__close js-toc-close" aria-controls="toc" aria-label="Hide table of contents"></button>' +
        '<nav id="toc" class="js-toc-list toc__list" aria-labelledby="toc-heading" data-module="collapsible-navigation">' +
          '<ul>' +
            '<li>' +
              '<a href="/"><span>Technical Documentation Template</span></a>' +
            '</li>' +
            '<li>' +
              '<a href="/"><span>Get started</span></a>' +
            '</li>' +
            '<li>' +
              '<a href="/"><span>Configure your documentation site</span></a>' +
            '</li>' +
          '</ul>' +
        '</nav>' +
      '</div>'
    )

    // some of the module's logic depends on the display style of the table of contents and the open button (.toc-show)
    // this is set in the CSS so replicate that, with classes we control for screen size
    $('head').append(
      '<style>' +
      '.toc-show { display: none; }' +
      '.mobile-size .toc-show { display: block; }' +
      '.toc { display: block; }' +
      '.mobile-size .toc { display: none; }' +
      '.mobile-size.toc-open .toc { display: block; }' +
      '</style>')
  })

  beforeEach(function () {
    $toc = $tocBase.clone()

    $html.find('body')
      .append(
        '<div id="toc-heading" class="toc-show fixedsticky">' +
          '<button type="button" class="toc-show__label js-toc-show" aria-controls="toc">' +
            'Table of contents <span class="toc-show__icon"></span>' +
          '</button>' +
        '</div>'
      )
      .append($toc)

    $closeButton = $toc.find('.js-toc-close')
    $openButton = $html.find('.js-toc-show')

    $tocStickyHeader = $html.find('.toc-show')
  })

  afterEach(function () {
    // clear up any classes left on <html>
    $html.removeClass('toc-open')
    $html.find('body #toc-heading').remove()
    $html.find('body .toc').remove()
    if ($tocStickyHeader && $tocStickyHeader.length) {
      $tocStickyHeader.remove()
    }
  })

  describe('when the module is started', function () {
    it('on a mobile-size screen, it should mark the table of contents as hidden', function () {
      // styles applied by this test simulate the styles media-queries will apply on real web pages
      // the .mobile-size class hides the table of contents and the open button
      $html.addClass('mobile-size') // simulate the styles media-queries will apply on real web pages

      module = new GOVUK.Modules.TableOfContents()
      module.start($toc)

      expect($toc.attr('aria-hidden')).toEqual('true')

      $html.removeClass('mobile-size')
    })

    it('on a desktop-size screen, it should mark the table of contents as visible', function () {
      // styles applied by this test simulate the styles media-queries will apply on real web pages
      // by default, they show the table of contents

      module = new GOVUK.Modules.TableOfContents()
      module.start($toc)

      expect($toc.attr('aria-hidden')).toEqual('false')
    })
  })

  describe('when the screen resizes', function () {
    describe('on a mobile-size screen', function () {
      beforeEach(function () {
        $html.addClass('mobile-size')

        module = new GOVUK.Modules.TableOfContents()
        module.start($toc)
      })

      afterEach(function () {
        $html.removeClass('mobile-size')
      })

      it("the table of contents should have a role of 'dialog'", function () {
        $(window).trigger('resize')

        expect($toc.attr('role')).toEqual('dialog')
      })

      it('if the table of contents is closed, it should mark the buttons as not expanded', function () {
        // the table of contents is closed by default, set by CSS styles

        $(window).trigger('resize')

        expect($closeButton.attr('aria-expanded')).toEqual('false')
        expect($openButton.attr('aria-expanded')).toEqual('false')
      })

      it('if the table of contents is open, it should mark the buttons as expanded', function () {
        $html.addClass('toc-open')

        $(window).trigger('resize')

        expect($closeButton.attr('aria-expanded')).toEqual('true')
        expect($openButton.attr('aria-expanded')).toEqual('true')

        $html.removeClass('toc-open')
      })
    })

    it('on a desktop-size screen, the table of contents should have no role', function () {
      module = new GOVUK.Modules.TableOfContents()
      module.start($toc)

      $(window).trigger('resize')

      expect($toc.attr('role')).toEqual(undefined)
    })
  })

  describe('if the open button is clicked', function () {
    beforeEach(function () {
      module = new GOVUK.Modules.TableOfContents()
      module.start($toc)
    })

    it('the click event should be cancelled', function () {
      var clickEvt = new $.Event('click')

      $openButton.trigger(clickEvt)

      expect(clickEvt.isDefaultPrevented()).toBe(true)
    })

    it('the table of contents should show and be focused', function () {
      // detecting focus has proved unreliable so track calls to $toc.focus instead
      var _focus = $.fn.focus
      var tocFocusSpy = jasmine.createSpy('tocFocusSpy')
      var clickEvt

      $.fn.extend({
        focus: function () {
          if (this === $toc) {
            tocFocusSpy()
          } else {
            _focus.call($toc)
          }
        }
      })

      clickEvt = new $.Event('click')
      $openButton.trigger(clickEvt)

      expect($toc.attr('aria-hidden')).toEqual('false')

      expect(tocFocusSpy).toHaveBeenCalled()

      // reset .focus method
      $.fn.extend({ focus: _focus })
    })
  })

  describe('if the close button is clicked', function () {
    var clickEvt

    beforeEach(function () {
      $html.addClass('mobile-size')

      module = new GOVUK.Modules.TableOfContents()
      module.start($toc)

      // tocIsVisible = false // controls what $toc.is(':visible') returns, which will be controlled by CSS in a web page
      clickEvt = new $.Event('click')
      $closeButton.trigger(clickEvt)
    })

    afterEach(function () {
      $html.removeClass('mobile-size')
    })

    it('the click event should be cancelled', function () {
      expect(clickEvt.isDefaultPrevented()).toBe(true)
    })

    it('the table of contents should be hidden', function () {
      expect($toc.attr('aria-hidden')).toEqual('true')
    })
  })

  it('on mobile-size screens, when the table of contents is open and the escape key is activated, the table of contents should be hidden', function () {
    $html.addClass('mobile-size')

    module = new GOVUK.Modules.TableOfContents()
    module.start($toc)

    $openButton.trigger('click')

    $(document).trigger(new $.Event('keydown', {
      keyCode: 27
    }))

    expect($html.hasClass('toc-open')).toBe(false)

    $html.removeClass('mobile-size')
  })

  describe("Fix for iOS 'rubber banding'", function () {
    var _scrollTop
    var _prop
    var scrollTop
    var scrollHeight
    var offsetHeight
    var scrollTopSpy

    beforeEach(function () {
      // stub out jQuery methods
      _scrollTop = $.fn.scrollTop
      _prop = $.fn.prop

      scrollTopSpy = jasmine.createSpy('scrollTopSpy')

      $.fn.extend({
        scrollTop: function (val) {
          if (val !== undefined) {
            return scrollTopSpy(val)
          }
          return scrollTop
        }
      })

      $.fn.extend({
        prop: function (key) {
          if (key === 'scrollHeight') {
            return scrollHeight
          }
          if (key === 'offsetHeight') {
            return offsetHeight
          }
          return _prop.call($toc, key)
        }
      })

      module = new GOVUK.Modules.TableOfContents()
      module.start($toc)
    })

    afterEach(function () {
      // reset jQuery methods
      $.fn.extend({ prop: _prop })
      $.fn.extend({ scrollTop: _scrollTop })
    })

    it('should stop the scroll reaching the top edge if at the top of the page', function () {
      scrollTop = 0
      scrollHeight = 1000
      offsetHeight = 600

      $toc.trigger('touchstart')

      expect(scrollTopSpy).toHaveBeenCalledWith(1)
    })

    it('should stop the scroll reaching the bottom edge if at the bottom of the page', function () {
      scrollTop = 400
      scrollHeight = 1000
      offsetHeight = 600

      $toc.trigger('touchstart')

      expect(scrollTopSpy).toHaveBeenCalledWith(399)
    })
  })

  describe('Prevent table of contents open button overlapping focused elements', function () {
    var _getBoundingClientRect
    var _addEventListener
    var _scrollTop
    var $link
    var $tocStickyHeader

    beforeEach(function () {
      _getBoundingClientRect = Element.prototype.getBoundingClientRect
      _addEventListener = Document.prototype.addEventListener
      _scrollTop = $.fn.scrollTop

      $tocStickyHeader = $('.toc-show')
      $link = $('<a href="">Test link</a>')
      $('body').append($link)
    })

    afterEach(function () {
      Element.prototype.getBoundingClientRect = _getBoundingClientRect
      Document.prototype.addEventListener = _addEventListener
      $.fn.extend({ scrollTop: _scrollTop })

      $link.remove()
    })

    it('if an element is focused while being overlaped by the table of contents sticky header, the screen should scroll to reveal it', function () {
      var tocStickyHeaderBottomPos = 50
      var linkTopPos = 30
      var windowScrollPos = 300
      var scrollTopSpy = jasmine.createSpy('scrollTop')

      $html.addClass('mobile-size') // the open button only appears on mobile-size screens

      module = new GOVUK.Modules.TableOfContents()
      module.start($toc)

      // stub DOM APIs used to work out if an element is overlaped
      Element.prototype.getBoundingClientRect = function () {
        if (this === $tocStickyHeader.get(0)) {
          return {
            bottom: tocStickyHeaderBottomPos
          }
        }
        if (this === $link.get(0)) {
          return {
            top: linkTopPos
          }
        }
      }
      $.fn.scrollTop = function (yPos) {
        if (this.get(0) !== window) { return _scrollTop(arguments) }
        if (yPos === undefined) { // call for current scrollTop position
          return windowScrollPos
        } else {
          scrollTopSpy(yPos)
        }
      }

      // replicating a real event requires us to focus the element and fire the event ourselves
      $link.focus()
      $link.get(0).dispatchEvent(new Event('focus'))

      expect(scrollTopSpy).toHaveBeenCalledWith(windowScrollPos - (tocStickyHeaderBottomPos - linkTopPos))

      $html.removeClass('mobile-size')
    })

    it('if the table of contents sticky header isn\'t shown, no focus tracking should happen', function () {
      var scrollTopSpy = jasmine.createSpy('scrollTop')
      var getBoundingClientRectSpy = jasmine.createSpy('getBoundingClientRectSpy')

      module = new GOVUK.Modules.TableOfContents()
      module.start($toc)

      // stub out web APIs used if focus tracking runs
      Element.prototype.getBoundingClientRect = function () {
        if ((this === $tocStickyHeader.get(0)) || (this === $link.get(0))) {
          getBoundingClientRectSpy()
          return {
            bottom: 50,
            top: 30
          }
        }
      }
      $.fn.scrollTop = function (yPos) {
        if (this.get(0) !== window) { return _scrollTop(arguments) }
        scrollTopSpy(arguments)
      }

      // replicating a real event requires us to focus the element and fire the event ourselves
      $link.focus()
      $link.get(0).dispatchEvent(new Event('focus'))

      expect(getBoundingClientRectSpy).not.toHaveBeenCalled()
      expect(scrollTopSpy).not.toHaveBeenCalled()
    })

    it('if the table of contents sticky header shows but then is hidden when the screen resizes, no focus tracking should happen', function () {
      var scrollTopSpy = jasmine.createSpy('scrollTop')
      var getBoundingClientRectSpy = jasmine.createSpy('getBoundingClientRectSpy')

      $html.addClass('mobile-size') // the open button only appears on mobile-size screens

      module = new GOVUK.Modules.TableOfContents()
      module.start($toc)

      // simulate screen resizing to desktop-size
      $html.removeClass('mobile-size')
      $(window).trigger('resize')

      // stub out web APIs used if focus tracking runs
      Element.prototype.getBoundingClientRect = function () {
        if ((this === $tocStickyHeader.get(0)) || (this === $link.get(0))) {
          getBoundingClientRectSpy()
          return {
            bottom: 50,
            top: 30
          }
        }
      }
      $.fn.scrollTop = function (yPos) {
        if (this.get(0) !== window) { return _scrollTop(arguments) }
        scrollTopSpy(arguments)
      }

      // replicating a real event requires us to focus the element and fire the event ourselves
      $link.focus()
      $link.get(0).dispatchEvent(new Event('focus'))

      expect(getBoundingClientRectSpy).not.toHaveBeenCalled()
      expect(scrollTopSpy).not.toHaveBeenCalled()
    })
  })
})
