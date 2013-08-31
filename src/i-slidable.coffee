pointerToXY = (e) ->
    result = {pageX:0, pageY:0}
    if e.type == 'touchstart' || e.type == 'touchmove' || e.type == 'touchend' || e.type == 'touchcancel'
        touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0]
        result.pageX = touch.pageX
        result.pageY = touch.pageY
    else if e.type == 'mousedown' || e.type == 'mouseup' || e.type == 'mousemove' || e.type == 'mouseover'|| e.type=='mouseout' || e.type=='mouseenter' || e.type=='mouseleave'
        result.pageX = e.pageX
        result.pageY = e.pageY
    return result

###
Handles drag operations- done globally to enable sliding action that starts on an element but continues across the window
###
class DragManager
    constructor: ->
        @_reset()
        @_$window = $(window)
        @_$body = $('body')

    ###
    Private: reset the drag manager and related document styles (cursor).

    Returns nothing.
    ###
    _reset: ->
        @isDragging = false
        if @_direction?
            @_$body.removeClass("dragging-#{ @_direction }")
        @_draggingTarget = null
        @_dragStartX = null
        @_dragStartY = null
        @_direction = null
        return

    ###
    Private: prepare the mouse position information for the handlers.

    cur_x - the integer current x position of the cursor
    cur_y - the integer current y position of the cursor

    Returns an object with the initial coordinates, and the change in position.
    ###
    _assembleUI: (cur_x, cur_y) ->
        return {
            x_start : @_dragStartX
            y_start : @_dragStartY
            x_delta : cur_x - @_dragStartX
            y_delta : cur_y - @_dragStartY
        }

    ###
    Public: initiate a drag operation for a given view.

    e - the jQuery.Event from the initial mousedown event
    view - the BaseElementView of the element starting the drag
    direction - the String direction of the drag: 'x', 'y', or 'both'

    Returns nothing.
    ###
    start: (e, view, direction) ->
        @isDragging = true
        { pageX, pageY } = pointerToXY(e)
        @_direction = direction
        @_dragStartX = pageX
        @_dragStartY = pageY
        @_draggingTarget = view
        @_$window.on('mousemove touchmove', @_drag)
        @_$window.on('mouseup touchend touchcancel', @_stop)
        @_$body.addClass("dragging-#{ @_direction }")

    _drag: (e) =>
        { pageX, pageY } = pointerToXY(e)
        ui = @_assembleUI(pageX, pageY)
        @_draggingTarget.onDrag?(ui)

    _stop: (e) =>
        @_$window.off('mousemove touchmove', @_drag)
        @_$window.off('mouseup touchend touchcancel', @_stop)
        if @_draggingTarget?
            { pageX, pageY } = pointerToXY(e)
            ui = @_assembleUI(pageX, pageY)
            @_draggingTarget.stopDragging?(ui)
            @_reset()

angular.module('iSlidable', ['iReactable'])
    .directive('iSlidable', ['$iReactable', ($iReactable) ->
        dragManager = new DragManager()
        aProcessEvent = (ngModelCtrl, options, scope, element, attrs, nextValueFn) ->
            _$body = $('body')
            oldBodyStyle = _$body.attr('style')
            options.hint = "Drag it to adjust @#{attrs.ngModel}'s value"
            el = $(element)
            _updateCursor = (value)->
                if value >= options.range.max
                    _$body.css(cursor: 'w-resize')
                    el.css(cursor: 'w-resize')
                else if value <= options.range.min
                    _$body.css(cursor: 'e-resize')
                    el.css(cursor: 'e-resize')
                else
                    _$body.css(cursor: 'col-resize')
                    el.css(cursor: 'col-resize')
                return
            _reset = ->
                now = new Date()
                if now - options.lastClick < 500
                    scope.$apply(()->
                        ngModelCtrl.$setViewValue(options.defaultValue)
                        ngModelCtrl.$render()
                    )
                    _updateCursor(options.defaultValue)
                    #model.assign(scope, options.defaultValue)
                options.lastClick = now
                return

            _onDrag = ({ x_start, y_start, x_delta, y_delta }) ->
                options.range.mulStep = Math.floor(x_delta / 15)
                value = nextValueFn(ngModelCtrl.$modelValue, options, false)
                _updateCursor(value)
                scope.$apply( ()->
                    ngModelCtrl.$setViewValue(value)
                )
                return

            _stopDragging = ->
                element.removeClass('active')
                _updateCursor(ngModelCtrl.$modelValue)
                if oldBodyStyle?
                    _$body.attr('style', oldBodyStyle)
                else
                    _$body.removeAttr('style')
                el.removeAttr('style')
                return

            _startDragging = (e) ->
                if !options.readonly
                    this.onDrag = _onDrag
                    this.stopDragging = _stopDragging
                    dragManager.start(e, this, 'x')
                    options.defaultValue = ngModelCtrl.$modelValue
                    element.addClass('active')
                    e.preventDefault()
                return

            element.bind('click', (e)->
                if !options.readonly
                    _reset()
                return
            )
            element.bind('mousedown touchstart', _startDragging)
        return $iReactable('iSlidable', aProcessEvent)
    ])
