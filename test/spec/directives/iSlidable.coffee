'use strict'

describe 'Directive: iSlidable', () ->
  beforeEach module 'iSlidable'

  element = {}

  it 'should make slidable element to bind', inject ($rootScope, $compile) ->
    element = angular.element '<i-slidable ng-model="myvar">{{myvar}}</i-slidable>'
    $rootScope.myvar = 1
    element = $compile(element) $rootScope
    $rootScope.$digest()
    expect(element.text()).toBe '1'
