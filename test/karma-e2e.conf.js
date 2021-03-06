// Karma E2E configuration

// base path, that will be used to resolve files and exclude
basePath = '../';

frameworks = ['ng-scenario'];

// list of files / patterns to load in the browser
files = [
  'deps/jquery/jquery.js',
  'deps/lodash/lodash.js',
  //ANGULAR_SCENARIO,
  'test/lib/angular-scenario.js',
  ANGULAR_SCENARIO_ADAPTER,
  'src/*.coffee',
  'src/**/*.coffee',
  'test/e2e/**/*.js',
  'test/e2e/**/*.coffee'
];

// list of files to exclude
exclude = [];

// test results reporter to use
// possible values: dots || progress || growl
reporters = ['progress'];

// web server port
port = 8080;

// cli runner port
runnerPort = 9100;

// enable / disable colors in the output (reporters and logs)
colors = true;

// level of logging
// possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
logLevel = LOG_INFO;

// enable / disable watching file and executing tests whenever any file changes
autoWatch = false;

// Start these browsers, currently available:
// - Chrome
// - ChromeCanary
// - Firefox
// - Opera
// - Safari (only Mac)
// - PhantomJS
// - IE (only Windows)
browsers = ['Firefox'];

// If browser does not capture in given timeout [ms], kill it
captureTimeout = 5000;

// Continuous Integration mode
// if true, it capture browsers, run tests and exit
singleRun = true;

// Uncomment the following lines if you are using grunt's server to run the tests
proxies = {
   '/': 'http://localhost:9001/'
};
// URL root prevent conflicts with the site root
// urlRoot = '_karma_';

plugins = [
        'karma-junit-reporter',
        'karma-chrome-launcher',
        'karma-firefox-launcher',
        'karma-jasmine',
        'karma-ng-scenario'
        ];

junitReporter = {
  outputFile: 'test_out/e2e.xml',
  suite: 'e2e'
};
