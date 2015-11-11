var gulp = require('gulp');
var jison = require('gulp-jison');
var insert = require('gulp-insert');
 
gulp.task('default', function() {
    return gulp.src('flexy-to-twig.jison')
        .pipe(jison({ moduleType: 'commonjs' }))
        .pipe(insert.prepend('#!/usr/bin/env node\nn'))
        .pipe(gulp.dest('.'));
});