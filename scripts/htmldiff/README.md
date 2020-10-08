JavaScript port of [HtmlDiff.NET](https://github.com/Rohland/htmldiff.net) which is itself a C# port of the Ruby implementation, [HtmlDiff](https://github.com/myobie/htmldiff/).

Project Description
-------------------

Diffs two HTML blocks, and returns a meshing of the two that includes `<ins>` and `<del>` elements.  The classes of these elements are `ins.diffins` for new code, `del.diffdel` for removed code, and `del.diffmod` and `ins.diffmod` for sections of code that have been changed.

For "special tags" (primarily style tags such as `<em>` and `<strong>`), `ins.mod` elements are inserted with the new styles.

Further description can be found at this [blog post](http://www.rohland.co.za/index.php/2009/10/31/csharp-html-diff-algorithm/) written by Rohland, the author of HtmlDiff.NET.

**Note**: The diffing algorithm isn't perfect.  One example is that if a new `<p>` ends in the same string as the previous `<p>` tag did, two `<ins>` tags will be created: one starting at the beginning of the common string in the first `<p>` and one in the second `<p>` containing all the content up to the point the trailing common string begins.  It's a little frustrating, but I didn't write the algorithm (and honestly don't really understand it); I only ported it.

Usage
-----

#### Html ####

```html
<html>
<body>
    <div id="oldHtml">
        <p>Some <em>old</em> html here</p>
    </div>

    <div id="newHtml">
        <p>Some <b>new</b> html goes here</p>
    </div>

    <div id="diffHtml">
    </div>
</body>
</html>
```

#### JavaScript ####

```javascript
import HtmlDiff from 'htmldiff-js';


let oldHtml = document.getElementById('oldHtml');
let newHtml = document.getElementById('newHtml');
let diffHtml = document.getElementById('diffHtml');

diffHtml.innerHTML = HtmlDiff.execute(oldHtml.innerHTML, newHtml.innerHTML);
```

Demo
----

I didn't port the demo, but it should output markup the same way the [htmldiff.net demo](https://github.com/Rohland/htmldiff.net/tree/master/Demo) does with a slight exception in what appeared to me to be a bug, which I 'fixed'.  I can no longer remember what that bug was, as I only ported this project quickly in order to use it in another project.
