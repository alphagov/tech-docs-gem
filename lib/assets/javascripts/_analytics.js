(function($) {
  function trackLinkClick(action, $element) {
    var linkText = $.trim($element.text());
    var linkURL = $element.attr('href');
    var label = linkText + '|' + linkURL;

    ga(
      'send',
      'event',
      'SM Technical Documentation', // Event Category
      action, // Event Action
      label // Event Label
    );
  }

  function linkTrackingEventHandler(action) {
    return function() {
      trackLinkClick(action, $(this));
    };
  };

  function catchBrokenFragmentLinks() {
    var fragment = window.location.hash;
    var $target = $(fragment);
    if(!$target.get(0)) {
      ga(
        'send',
        'event',
        'Broken fragment ID', // Event Category
        'pageview', // Event Action
        window.location.pathname + fragment // Event Label
      );
    }
  }

  $(document).on('ready', function() {
    if (typeof ga === 'undefined') {
      return;
    }

    $('.technical-documentation a').on('click', linkTrackingEventHandler('inTextClick'));
    $('.header a').on('click', linkTrackingEventHandler('topNavigationClick'));
    $('.toc a').on('click', linkTrackingEventHandler('tableOfContentsNavigationClick'));
    catchBrokenFragmentLinks();
  });
})(jQuery);
