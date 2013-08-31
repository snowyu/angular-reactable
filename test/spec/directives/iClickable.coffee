'use strict'

describe 'Directive: iClickable', () ->
  $scope = {}
  $compile = null

  beforeEach module 'iClickable'
  beforeEach inject (_$rootScope_, _$compile_) ->
    $scope = _$rootScope_
    $compile = _$compile_

  element = {}

  it 'should make element clickable and bind variable', inject ($rootScope, $compile) ->
    element = angular.element  '<i-clickable ng-model="myvar">{{myvar}}</i-clickable>'
    $scope.myvar = 1
    element = $compile(element) $scope
    $scope.$digest()
    expect(element.text()).toBe '1'
    element.click()
    expect(element.text()).toBe '2'

