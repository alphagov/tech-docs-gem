(function($, Modules) {
  'use strict';

  Modules.TableOfContents = function () {
    var $html = $('html');

    var $contentPane;
    var $toc;
    var $tocList;
    var $topLevelItems;
    var $headings;
    var $listings;

    var $openLink;
    var $closeLink;

    this.start = function ($element) {
      $contentPane = $('.app-pane__content');
      $toc = $element;
      $tocList = $toc.find('.js-toc-list');
      $topLevelItems = $tocList.find('> ul > li');
      $headings = $topLevelItems.find('> a');
      $listings = $topLevelItems.find('> ul');

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
      for (var i = $topLevelItems.length - 1; i >= 0; i--) {
        var $topLevelItem = $($topLevelItems[i]);
        var $heading = $topLevelItem.find('> a');
        var $listing = $topLevelItem.find('> ul');
        // Only add collapsible functionality if there are children.
        if ($listing.length == 0) {
          continue;
        }
        $topLevelItem.addClass('collapsible');
        $listing.addClass('collapsible__body')
        .attr('aria-expanded', 'false');
        $heading.addClass('collapsible__heading')
        .after('<button class="collapsible__toggle"><span class="collapsible__toggle-label">Expand ' + $heading.text() + '</span><span class="collapsible__toggle-icon" aria-hidden="true"></button>')
        $topLevelItem.on('click', '.collapsible__toggle', function(e) {
          e.preventDefault();
          var $parent = $(this).parent();
          toggleHeading($parent);
        });
      }
    }

    function toggleHeading($topLevelItem) {
      var isOpen = $topLevelItem.hasClass('is-open');
      var $heading = $topLevelItem.find('> a');
      var $body = $topLevelItem.find('collapsible__body');
      var $toggleLabel = $topLevelItem.find('.collapsible__toggle-label');

      $topLevelItem.toggleClass('is-open', !isOpen);
      $body.attr('aria-expanded', isOpen ? 'true' : 'false');
      $toggleLabel.text(isOpen ? 'Expand ' + $heading.text() : 'Collapse ' + $heading.text());
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
      if($activeElement && !$activeElement.hasClass('is-open')) {
        toggleHeading($activeElement);
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
