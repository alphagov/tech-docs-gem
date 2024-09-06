(function ($, Modules) {
  'use strict'

  Modules.PageExpiry = function PageExpiry () {
    this.start = function start ($element) {
      var rawDate = $element.data('last-reviewed-on')
      var isExpired = Date.parse(rawDate) < new Date()

      if (isExpired) {
        $element.find('.page-expiry--not-expired').attr('hidden', '')
        $element.find('.page-expiry--expired').removeAttr('hidden')
      }
    }
  }
})(jQuery, window.GOVUK.Modules)
