//= require _vendor/jquery
//= require _vendor/modernizr
//= require _vendor/fixedsticky
//= require _vendor/lodash
//= require _analytics
//= require _start-modules
//= require all.bundle.js

$(function () {
  $('.fixedsticky').fixedsticky()
  GOVUKFrontend.initAll()
})
