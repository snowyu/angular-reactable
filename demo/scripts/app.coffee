'use strict'

angular.module('jsBlogApp', ['ngRoute', 'iReactive.clickable', 'iReactive.slidable'])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .otherwise
        redirectTo: '/'
