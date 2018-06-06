(function($, Modules) {
  'use strict';

  Modules.TableOfContents = function () {
    var $html = $('html');

    var $contentPane;
    var $toc;
    var $tocList;
    var $topLevelItems;

    var $openLink;
    var $closeLink;

    this.start = function ($element) {
      $toc = $element;
      $tocList = $toc.find('.js-toc-list');
      $topLevelItems = $tocList.find('> ul > li');
      $contentPane = $('.app-pane__content');

      // Open link is not inside the module
      $openLink = $html.find('.js-toc-show');
      $closeLink = $toc.find('.js-toc-close');

      fixRubberBandingInIOS();
      updateAriaAttributes();

      // Attach collapsible heading functionality,on mobile and desktop
      collapsibleHeadings();
      openActiveHeading();
      $contentPane.on('scroll', _.debounce(openActiveHeading, 100, { maxWait: 100 }));

      // Need delegated handler for show link as sticky polyfill recreates element
      $openLink.on('click.toc', preventingScrolling(openNavigation));
      $closeLink.on('click.toc', preventingScrolling(closeNavigation));
      $tocList.on('click.toc', 'a', closeNavigation);

      // Allow aria hidden to be updated when resizing from mobile to desktop or
      // vice versa
      $(window).on('resize.toc', updateAriaAttributes)

      $(document).on('keydown.toc', function (event) {
        var ESC_KEY = 27;

        if (event.keyCode == ESC_KEY) {
          closeNavigation();
        }
      });
    };

    function collapsibleHeadings() {
      var $headings = $topLevelItems.find('> a');
      var $listings = $topLevelItems.find('> ul');

      $topLevelItems.addClass('collapsible');
      $listings.addClass('collapsible__body');
      $headings.addClass('collapsible__heading').on('click', function(e) {
        e.preventDefault();
        var $parent = $(this).parent();
        $parent.toggleClass('is-open');
      });
    }

    function openActiveHeading() {
      var currentLocation = window.location.pathname + window.location.hash;
      var $activeElement;
      for (var i = $topLevelItems.length - 1; i >= 0; i--) {
        var $element = $($topLevelItems[i]);
        var $heading = $element.find('> a');
        // Check if this item href matches
        if($heading.is('[href="' + currentLocation + '"]')) {
          $activeElement = $element;
          break;
        }
        // Otherwise check the children
        var $children = $element.find('li > a');
        var $matchingChildren = $children.filter('[href="' + currentLocation + '"]');
        if ($matchingChildren.length) {
          $activeElement = $element;
          break;
        }
      }
      if($activeElement) {
        $activeElement.addClass('is-open');
      }
    }

    function fixRubberBandingInIOS() {
      // By default when the table of contents is at the top or bottom,
      // scrolling in that direction will scroll the body 'behind' the table of
      // contents. Fix this by preventing ever reaching the top or bottom of the
      // table of contents (by 1 pixel).
      //
      // http://blog.christoffer.me/six-things-i-learnt-about-ios-safaris-rubber-band-scrolling/
      $toc.on("touchstart.toc", function () {
        var $this = $(this),
          top = $this.scrollTop(),
          totalScroll = $this.prop('scrollHeight'),
          currentScroll = top + $this.prop('offsetHeight');

        if (top === 0) {
          $this.scrollTop(1);
        } else if (currentScroll === totalScroll) {
          $this.scrollTop(top - 1);
        }
      });
    }

    function openNavigation() {
      $html.addClass('toc-open');

      toggleBackgroundVisiblity(false);
      updateAriaAttributes();

      focusFirstLinkInToc();
    }

    function closeNavigation() {
      $html.removeClass('toc-open');

      toggleBackgroundVisiblity(true);
      updateAriaAttributes();
    }

    function focusFirstLinkInToc() {
      $('a', $tocList).first().focus();
    }

    function toggleBackgroundVisiblity(visibility) {
      $('.toc-open-disabled').attr('aria-hidden', visibility ? '' : 'true');
    }

    function updateAriaAttributes() {
      var tocIsVisible = $toc.is(':visible');

      $($openLink).add($closeLink)
        .attr('aria-expanded', tocIsVisible ? 'true' : 'false');

      $toc.attr('aria-hidden', tocIsVisible ? 'false' : 'true');
    }

    function preventingScrolling(callback) {
      return function (event) {
        event.preventDefault();
        callback();
      }
    }
  };
})(jQuery, window.GOVUK.Modules);
