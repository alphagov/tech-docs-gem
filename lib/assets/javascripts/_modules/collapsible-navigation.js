(function ($, Modules) {
  'use strict'

  Modules.CollapsibleNavigation = function () {
    var $contentPane
    var $nav
    var $topLevelItems

    this.start = function ($element) {
      $contentPane = $('.app-pane__content')
      $nav = $element
      $topLevelItems = $nav.find('> ul > li')

      // Attach collapsible heading functionality,on mobile and desktop
      collapsibleHeadings()
      openActiveHeading()
      $contentPane.on('scroll', _.debounce(openActiveHeading, 100, { maxWait: 100 }))
    }

    function collapsibleHeadings () {
      for (var i = $topLevelItems.length - 1; i >= 0; i--) {
        var $topLevelItem = $($topLevelItems[i])
        var $heading = $topLevelItem.find('> a')
        var $listing = $topLevelItem.find('> ul')
        var id = 'toc-' + $heading.text().toLowerCase().replace(/\s+/g, '-')
        // Only add collapsible functionality if there are children.
        if ($listing.length === 0) {
          continue
        }
        $topLevelItem.addClass('collapsible')
        var arrayOfIds = []
        $listing.each(function (i) {
          var uniqueId = id + '-' + i
          arrayOfIds.push(uniqueId)
          $(this).addClass('collapsible__body')
            .attr('id', uniqueId)
        })
        $heading.addClass('collapsible__heading')
          .after('<button class="collapsible__toggle" aria-expanded="false" aria-controls="' + arrayOfIds.join(' ') + '"><span class="collapsible__toggle-label">Expand ' + $heading.text() + '</span><span class="collapsible__toggle-icon" aria-hidden="true"></button>')
        $topLevelItem.on('click', '.collapsible__toggle', function (e) {
          e.preventDefault()
          var $parent = $(this).parent()
          toggleHeading($parent)
        })
      }
    }

    function toggleHeading ($topLevelItem) {
      var setOpen = !$topLevelItem.hasClass('is-open')

      var $heading = $topLevelItem.find('> a')
      var $button = $topLevelItem.find('.collapsible__toggle')
      var $toggleLabel = $topLevelItem.find('.collapsible__toggle-label')

      $topLevelItem.toggleClass('is-open', setOpen)
      $button.attr('aria-expanded', setOpen ? 'true' : 'false')
      $toggleLabel.text(setOpen ? 'Collapse ' + $heading.text() : 'Expand ' + $heading.text())
    }

    /**
     * Returns an absolute pathname to $target by combining it with window.location.href
     * @param $target The target whose pathname to return. This may be an anchor with an absolute or relative href.
     * @returns {string} The absolute pathname of $target
     */
    function getAbsolutePath ($target) {
      return new URL($target.attr('href'), window.location.href).pathname
    }

    function openActiveHeading () {
      var $activeElement
      var currentPath = window.location.pathname
      for (var i = $topLevelItems.length - 1; i >= 0; i--) {
        var $element = $($topLevelItems[i])
        var $heading = $element.find('> a')
        // Check if this item href matches
        if (getAbsolutePath($heading) === currentPath) {
          $activeElement = $element
          break
        }
        // Otherwise check the children
        var $children = $element.find('li > a')
        var $matchingChildren = $children.filter(function (_) {
          return getAbsolutePath($(this)) === currentPath
        })
        if ($matchingChildren.length) {
          $activeElement = $element
          break
        }
      }
      if ($activeElement && !$activeElement.hasClass('is-open')) {
        toggleHeading($activeElement)
      }
    }
  }
})(jQuery, window.GOVUK.Modules)
