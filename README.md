# i-Reactable directives [![Build Status](https://travis-ci.org/snowyu/angular-reactable.png)](https://travis-ci.org/snowyu/angular-reactable)

These directives allows you to add the reactable/computable ability to your elements of a document.


# Requirements

- Nodejs(for toolkit chain)
- Grunt(for testing)
- Bower(the browser package manager)
- AngularJS (>=v1.2.0-rc.1)

# Install

We use [bower](http://twitter.github.com/bower/) for dependency management.

```sh
cd your_app
bower install angular-reactable --save
```

this will install angular-reactable and add the dependency into 'bower.json' file:

```json
dependencies: {
  "angular-reactable": "latest"
}
```

Or write the dependency to your `bower.json` file. Then run

```sh
bower install
```

# Usage

This will copy the angular-reactable files into your `bower_components` folder, along with its dependencies. Load the script files in your application:

```html
<script type="text/javascript" src="bower_components/codemirror/lib/codemirror.js"></script>
<script type="text/javascript" src="bower_components/angular/angular.js"></script>
<script type="text/javascript" src="bower_components/angular-reactable/i-reactable.js"></script>
```

Add the your wanted reactable directives as a dependency to your application module:

```html
<script type="text/javascript" src="bower_components/angular-reactable/i-slidable.js"></script>
```

```javascript
var myAppModule = angular.module('MyApp', ['iSlidable']);
```

Apply the directive to your elements:

```html
<div i-slidable="{range:{min:1, max:40}}" ng-model="x">This is a slidable {{x}}</div>
<div i-clickable range="{min:1, max:40}" ng-model="x">This is a clickable {{x}}</div>
```

## directives

the directives are made of reactable directives and helper directives.

### reactable directives

we have these reactable directives:

* iSlidable: slide on the element to change value
* iClickable: click on the element to change value
* iPlayable: play carousel to change value.
* iExecutable: the value is script code can be executable.

All the reactable directives plays nicely with ng-model.

#### iSlidable/iClickable/iPlayable

these reactable directives have following parameters:

* readonly: boolean. you can disable reactable ability temporarily.
* hint: String, the hint text for the reactable element.
* hintOn: boolean, enable/disable the hint. The default is hintOn.
* range: this is the most import parameter in these reactable directives.
  * It can be a number: Object
     * min: the minimum value in the range. the default is -Infinity.
     * max: the maximum value in the range. the default is +Infinity.
     * step: the step over in the range. the default is 1.
     * minIn: boolean, whether the min is included.
     * maxIn: boolean, whether the max is included.
     * mulStep: the step multiply constant(realStep=mulStep*step), the default is 1.
  * It can be a list: ['first', 'second', 'third']
  * It can be a function to get the next value:
     * function(value, config, looped)
        * parameters:
           * value: the current value
           * config: the config object
           * looped: whether looped. the value should be the minimum when the value is exceed the maximum in the range if looped.
        * return: the next value
* index: the current index of the range. it's not available on number range.

the iPlayable directive has the following special parameters:

* delay
* effects
* paused
* controlbar


#### iExecutable directive


### helper directives


#### iFlash directive

Flash the element if ng-model's value changed.

```html
<div i-clickable range="{min:1, max:40}" i-flash ng-model="x">This is a clickable {{x}}</div>
```

You can disable it by:

* off/i-flash-off

```html
<div i-clickable range="{min:1, max:40}" i-flash='off' ng-model="x">This is a clickable {{x}}</div>
<div i-clickable range="{min:1, max:40}" i-flash i-flash-off ng-model="x">This is a clickable {{x}}</div>
```

#### iHighlighted directive

Highlighted the reactable element.

You can disable it by:

* off/i-highlighted-off

# Testing

We use karma (the new testacular) and jshint to ensure the quality of the code.  The easiest way to run these checks is to use grunt:

```sh
hub clone snowyu/angular-reactable
npm install -g grunt-cli bower
npm install
bower install
grunt test
```

The karma task will try to open Firefox as a browser in which to run the tests.  Make sure this is available or change the configuration in `test\karma.conf.js`

