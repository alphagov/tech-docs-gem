//= require _vendor/jquery
//= require _vendor/modernizr
//= require _vendor/fixedsticky
//= require _vendor/lodash
// header is only requirement but including all for the moment
//= require _vendor/all
//= require _analytics
//= require _start-modules

$(function() {
  $('.fixedsticky').fixedsticky();

  // Init the header
  window.GOVUKFrontend.initAll();
});

