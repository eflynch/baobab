var browserify   = require('browserify');
var coffeeify    = require('coffeeify');
var watchify     = require('watchify');
var gulp         = require('gulp');
var gutil        = require('gulp-util');
var notify       = require('gulp-notify');
var source       = require('vinyl-source-stream');

var scriptsDir = './src';
var buildDir = './dist';
var entryPoint = 'main.coffee';
var exitPoint = 'main.js';

gulp.task('default', function() {
  var bundler = watchify(browserify(scriptsDir + '/' + entryPoint, watchify.args));

  bundler.transform(coffeeify);

  bundler.on('update', rebundle);

  function handleErrors() {
    var args = Array.prototype.slice.call(arguments);
    notify.onError({
      title: "Compile Error",
      message: "<%= error.message %>"
    }).apply(this, args);
    this.emit('end'); // Keep gulp from hanging on this task
  }

  function rebundle() {
    return bundler.bundle()
      .on('error', handleErrors)
      .pipe(source(exitPoint))
      .pipe(gulp.dest(buildDir));
  }

  return rebundle();
});
