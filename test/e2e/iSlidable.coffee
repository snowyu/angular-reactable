'use strict'

describe 'Directive: iSlidable', () ->

  el = {}

  beforeEach () ->
    browser().navigateTo('/index.html')
    el = element('[ng-view] h2:first')

  it 'should has a h2 element with slidable', () ->
    #expect(browser().location().url()).toBe("/view1")
    expect(el.text())
        .toMatch "-1"
    expect(el.attr("i-slidable"))
        #toBeDefined();
        .toMatch "{range:{min:1,max:50, step:1}}"

  ### I have to hack into the angular-scenario.js to simulate mouse event with coordinate:
//modified:
(function(fn){
  var parentTrigger = fn.trigger;
  fn.trigger = function(type, keys, x, y) { //<-- added the keys and x, y parameters
    if (/(click|change|keydown|blur|input|mousedown|mouseup|mousemove)/.test(type)) {
      var processDefaults = [];
      this.each(function(index, node) {
        processDefaults.push(browserTrigger(node, type, keys, x, y)); //<-- added the keys and x, y parameters
      });

      // this is not compatible with jQuery - we return an array of returned values,
      // so that scenario runner know whether JS code has preventDefault() of the event or not...
      return processDefaults;
    }
    return parentTrigger.apply(this, arguments);
  };
})(_jQuery.fn);

     //added this:
     chain.trigger = function(evtType, keys, x, y) {
      return this.addFutureAction("element '" + this.label + "' " + evtType, function($window, $document, done) {
        var elements = $document.elements();
        elements.trigger(evtType, keys, x, y);
        done();
      });
    };
  ###
  it 'should be slidable', () ->
    delta = 15
    el.trigger('mousedown', [], 0, 0)
    el.trigger('mousemove', [], delta, 0)

    expect(binding('myvar')).toEqual "0"
    expect(el.text())
        .toMatch "0"

    el.trigger('mousemove', [], delta*2-1, 0)
    expect(binding('myvar')).toEqual "1"
    expect(el.text())
        .toMatch "1"

    el.trigger('mousemove', [], delta*3-1, 0)
    expect(binding('myvar')).toEqual "2"
    expect(el.text())
        .toMatch "2"
    el.trigger('mouseup', [], delta*3, 0)
