## Flexy to Twig converter

This tool converts [X-Cart 5](http://www.x-cart.com/) Flexy templates (original version is found on [PEAR](https://pear.php.net/manual/en/package.html.html-template-flexy.intro.php)) to the [Twig](http://twig.sensiolabs.org/) syntax.

### Installation:

The recommended way is to install globally via:

```
npm install -g flexy-to-twig
```

Or install locally:

```
npm install flexy-to-twig
```

(in that case you will need to either run converter as `./node_modules/.bin/flexy-to-twig` or somehow alter your PATH)

### Usage:

```
flexy-to-twig example.tpl
```

The above command will print generated twig template contents to stdout. Redirect stdout to file to actually create a twig template file:

```
flexy-to-twig example.tpl > example.twig
```

To recursively convert all files starting from the `skins` subdirectory:
 
```
find skins/ -name '*.tpl' -exec bash -c 'file="{}" ; flexy-to-twig "{}" > ${file%.tpl}.twig' -- {}  \;
```

### Instructions to modify & build:

The converter is based on [Jison](http://zaach.github.io/jison/) parser generator, the build process is automated with gulp. Install the `npm` dependencies and run `gulp`:

```
npm install
gulp
```

The source file for the flexy grammar is bundled with AST converter in `flexy-to-twig.jison`

