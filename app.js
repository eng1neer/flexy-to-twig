GLOBAL = window;

jQuery(function ($) {
    require('ace-builds/src-min-noconflict/ace.js');
    require('ace-builds/src-min-noconflict/mode-smarty.js');
    require('ace-builds/src-min-noconflict/mode-twig.js');
    require('ace-builds/src-min-noconflict/theme-monokai.js');

    var srcEditor = ace.edit("source");
    srcEditor.setTheme("ace/theme/monokai");
    srcEditor.getSession().setMode("ace/mode/smarty");

    var dstEditor = ace.edit("destination");
    dstEditor.setTheme("ace/theme/monokai");
    dstEditor.getSession().setMode("ace/mode/twig");

    var src = $('#source'),
        dst = $('#destination'),
        btn = $('#convert');

    var parser = require('flexy-to-twig').parser;

    btn.click(convert);

    convert();

    function convert() {
        var flexy = srcEditor.getValue();

        try {
            var twig = parser.parse(flexy);
        } catch (e) {
            alert("Flexy parsing error: \n\n" + e.message);

            twig = '';
        }

        dstEditor.setValue(twig);
    }
});