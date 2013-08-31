angular.module('iClickable', ['iReactable'])
    .directive('iClickable', ['$iReactable', ($iReactable) ->
        return $iReactable('iClickable', 'click')
    ])
