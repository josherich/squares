'use strict';

var gulp = require('gulp');

var del = require('del');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var gutil = require('gulp-util');
var livereload = require('gulp-livereload');

var path = {
  scripts: ['src/*.coffee','src/images.json', 'src/images.png'],
  assets: ['src/images.json', 'src/images.png']
};

gulp.task('coffee', ['clean'], function() {
  gulp.src('./src/*.coffee')
  .pipe(concat('main.coffee'))
  .pipe(coffee({bare: true, join: 'main.js'}).on('error', gutil.log))
  .pipe(gulp.dest('./public'));
});

gulp.task('copy', function() {
  gulp.src(['src/vendor/*.js', 'src/images.json', 'src/images.png'], {base: 'src/'})
  .pipe(gulp.dest('public'));
});

gulp.task('clean', function(cb) {
  del(['public/main.js'], cb);
});

gulp.task('watch', function() {
  livereload.listen();
  gulp.watch(path.scripts, ['coffee', 'copy']).on('change', livereload.changed);
});

gulp.task('default', ['watch', 'coffee', 'copy']);