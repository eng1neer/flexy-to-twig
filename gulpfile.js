var gulp = require('gulp');
var jison = require('gulp-jison');
var insert = require('gulp-insert');
var rename = require('gulp-rename');
 
gulp.task('default', function() {
    return gulp.src('flexy-to-twig.jison')
        .pipe(jison({ moduleType: 'commonjs' }))
        .pipe(gulp.dest('.'))
        .pipe(insert.prepend('#!/usr/bin/env node\n'))
        .pipe(rename('flexy-to-twig-bin.js'))
        .pipe(gulp.dest('.'));
});
