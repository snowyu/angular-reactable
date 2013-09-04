# translating camel-case to snake-case.
String::snake_case = (separator) ->
    SNAKE_CASE_REGEXP = /[A-Z]/g
    separator = separator || '_'
    this.replace(SNAKE_CASE_REGEXP, (letter, pos) ->
        (if pos then separator else '') + letter.toLowerCase()
    )

# the internal abstract Hint class
class CustomHint
    constructor: (@options, @element, @attrs)->
    enabled: () ->
        !!@options.hintOn
    apply: () ->
        if @enabled()
            hint = ''
            if !@options.readonly
                hint = if @options.hint?.length then @options.hint else "@"+ @attrs.ngModel
                #attrs.$set('tooltip', hint)
            else
                hint = "@#{@attrs.ngModel}" #if options.bind? then "@#{options.bind}" else ""
                #attrs.$set('tooltip', "{{'#{hint}'}}")
            if hint != ''
                @_on()
                @_set(hint)
            else
                @_off()
        else
            @_off()
        return

# the internal Hint class for bootstrap tooltip
# class HintTooltip

# the internal Hint class for hint.css
class HintCss extends CustomHint
    _on: () ->
        @element.addClass('hint--top')
        if !@options.readonly
            @element.removeClass('hint--error')
            @element.addClass('hint--info')
        else
            @element.removeClass('hint--info')
            @element.addClass('hint--error')
        return
    _off: () ->
        @element.removeClass('hint--info')
        @element.removeClass('hint--error')
        @element.removeClass('hint--top')
        @element.removeAttr('data-hint')
        return
    _set: (text) ->
        @attrs.$set('data-hint', text)
        return
    init: () ->
        #if @enabled()
        ###
        if isHintEnabled options
            element.addClass('hint--info')
            element.addClass('hint--top')
            hint = if options.hint?.length then options.hint else "@#{attrs.ngModel}" #+ options.bind
            attrs.$set('data-hint', hint)
        ###

Hint = HintCss

flashAnimate = (element) ->
    ###
    jQuery(element).css({
        position:'relative',
        left:0,
        opacity:0.5
    })
    ###
    if !$(element).is(':animated')
        $(element).animate({
            #fontSize: '+=1px',
            opacity: '-=0.66'
        })
        $(element).animate({
            #fontSize: '-=1px',
            opacity:'+=0.66'
        })

###
    .animation('.i-flash-animation', ()->
        addClass : (element, className, done) ->
                jQuery(element).css({
                    position:'relative',
                    left:-10,
                    opacity:0
                })
                jQuery(element).animate({
                    left:0,
                    opacity:1
                }, done)

        removeClass : (element, className, done) ->
                jQuery(element).css({
                    opacity:0.5
                })
                jQuery(element).animate({
                    opacity:1
                }, done)
    )
###
angular.module('iReactable', ['ngAnimate'])
    .directive('iHighlighted', [() ->
        {
            restrict: 'AE'
            link: (scope, element, attrs) ->
                scope.$watch(attrs.ngModel, (value, oldValue) ->
                    element.toggleClass('highlighted', angular.isUndefined(attrs.iHighlightedOff) and attrs.iHighlighted != 'off')
                )
        }
    ])
    .directive('iFlash', [() ->
        {
            restrict: 'AE'
            link: (scope, element, attrs) ->
                scope.$watch(attrs.ngModel, (value, oldValue) ->
                    if value != oldValue
                        flashAnimate(element) if angular.isUndefined(attrs.iFlashOff) and attrs.iFlash != 'off'
                    return
                )
        }
    ])
    .provider '$iReactable', [() ->
        ###
        *   arguments:
        *       * aDirectiveName: the created new directive name
        *       * aEvent: bind to the event, it can be a event string name, or a array, the item is:
        *         * [{evName, evFn}, ...]
        *           * eventName:
        *           * eventFn: the event callback functions
        *         * aprocessCallbackFunc(model, options, scope, element, attrs, NextValueFn)
        *   return: the directive definition object
        ###

        # AngularJS will instantiate a singleton by calling "new" on this function
        # The default options
        defaultOptions =
            readonly: false,
            index: undefined,
            # the values can be null, array and function
            #   * null: means it's a number
            #   * array: means it's a list, the item is picked from it. the index is the current item.
            #   * function: means get next value from it.
            values: null,
            # enable/disable hint
            hintOn: true,
            # the hint text
            hint: undefined,
            # the range may be a object, a list or a func
            # the default is a object
            range: {min: -Infinity, max: Infinity, step: 1, minIn: true, maxIn: true, mulStep: 1}

        # The options specified to the provider globally.
        globalOptions = {}

        ###
        * `options({})` allows global configuration of all react-able in the
        * application.
        *
        *   var app = angular.module( 'App', ['iReactable'], function( $iReactableProvider ) {
        *     // readonly instead of editable by default
        *     $iReactableProvider.options( { readonly: true } );
        *   });
        ###
        this.options = ( value ) ->
            angular.extend( globalOptions, value )
            return

        getNextValueInLoop = (value, config, looped) ->
            if angular.isNumber value
                range = config.range
                step = range.step * range.mulStep || 1
                sign = if step > 0 then 1 else -1
                if !looped
                    if sign == 1 and value >= range.max
                        return if range.maxIn then range.max else range.max - sign*step
                    else if sign== -1 and value <= range.min
                        return if range.minIn then range.min else range.min + sign*step
                value += step
                if looped
                    if step > 0       # step > 0?
                        if (value < range.min) or (value >= range.max)
                            if (value != range.max) or (value == range.max and !range.maxIn)
                                value = range.min
                                value += range.step if !range.minIn
                    else if step < 0
                        if (value <= range.min) or (value > range.max)
                            if (value != range.min) or (value == range.min and !range.minIn)
                                value = range.max
                                value += range.step if !range.maxIn
                value

        getNextValueInList = (value, config, looped) ->
            # the range is list
            if angular.isArray config.values
                values = config.values
            else
                values = []
            range = config.range
            if angular.isUndefined config.index
                # try find the index by value
                config.index = _.indexOf(values, value)
            config.index = getNextValueInLoop(config.index, config, looped)
            config.index = 0 if config.index < 0 or config.index >= values.length
            values[config.index]


        this.$get = [ '$injector', '$parse', '$timeout', '$animate', ($injector, $parse, $timeout, $animate) ->
            (aDirectiveName, aEvent) ->
                iReactablelink = (scope, element, attrs, ngModelCtrl) ->
                    if(!ngModelCtrl) then return # do nothing if no ng-model
                    options = angular.extend({}, defaultOptions, globalOptions)
                    options = angular.extend(options, scope.$eval(attrs[aDirectiveName]))
                    options.range = angular.extend({}, defaultOptions.range, options.range, scope.$eval(attrs.range))
                    options.values = scope.$eval(attrs.values) if attrs.values
                    options.hint = scope.$eval(attrs.hint) if attrs.hint

                    if angular.isArray options.values
                        nextValueFn = getNextValueInList
                    else if angular.isFunction options.values
                        nextValueFn = options.values
                    else
                        nextValueFn = getNextValueInLoop
                    vHint = new Hint(options, element, attrs)

                    # model -> UI
                    ngModelCtrl.$render =  () ->
                        element.toggleClass('editable', !options.readonly)
                        attrs.$set("readonly", "readonly") if options.readonly and angular.isUndefined attrs.readonly
                        vHint.apply attrs
                        return

                    if angular.isDefined attrs.ngReadonly  # watch the readonly variable changing.
                        scope.$watch(attrs.ngReadonly, (value, oldValue) ->
                            #if value != oldValue
                            options.readonly = !!value  # readonly is true
                            ngModelCtrl.$render()
                            return
                        )

                    element.addClass('iReactable'.snake_case('-'))
                    element.addClass(aDirectiveName.snake_case('-'))

                    options.defaultValue = ngModelCtrl.$modelValue
                    if angular.isFunction aEvent
                        aEvent(ngModelCtrl, options, scope, element, attrs, nextValueFn)
                    else if angular.isString aEvent
                        element.bind(aEvent, (el)->
                            if !options.readonly
                                value = nextValueFn(ngModelCtrl.$modelValue, options, true)

                                # In clickingCallback, if you are changing any model/scope data,
                                # you'll want to call scope.$apply(), or put the contents of the
                                # method inside scope.$apply(function() { ...contents here...});
                                #scope.$apply(opts.bind+"="+value)

                                # the $parse can use string expression like: user.name 
                                #scope[options.bind] = value
                                #model.assign(scope, value)
                                scope.$apply(()->
                                    ngModelCtrl.$setViewValue(value)
                                )
                            return
                        )
                    ngModelCtrl.$render()
                    return
                {
                    restrict: 'AE'
                    require:'ngModel'
                    compile: (tElement, tAttrs, transclude) ->
                        links = []
                        # set tooltip property and 'call' tooltip direcitve.
                        #directive = $injector.get('tooltip'+'Directive')[0]
                        #link = directive.compile(tElement, tAttrs, transclude)
                        #links.push(link)
                        links.push(iReactablelink)
                        return (scope, elm, attrs, ctrl) ->
                            if angular.isUndefined attrs.iFlash
                                # insert the iFlash directive here:
                                directive = $injector.get('iFlash'+'Directive')[0]
                                link = directive.compile(tElement, tAttrs, transclude)
                                links.push(link)
                            for link in links
                                link(scope, elm, attrs, ctrl)
                }
        ]
        return
        # this.$get ---END
    ]

