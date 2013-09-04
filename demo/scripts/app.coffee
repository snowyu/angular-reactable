'use strict'

angular.module('demo', ['ngRoute', 'iClickable', 'iSlidable'])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .otherwise
        redirectTo: '/'
