/*
 * This code turns an index entry like:
 *
 * na: 6, 6, 7, 8, 8, 9, 10, 11, 11, 16, 17, 20, 21, 22, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 38, 38, 38
 *
 * into:
 *
 * na: 6-11, 16-17, 20-22, 37-38
 *
 * Some bits came from http://www.princexml.com/howcome/2015/index/musick.html
 *
 * Much else came from
 * http://www.princexml.com/forum/topic/3129/merge-repeated-cross-links?p=1#15392
 * ; much thanks to mikeday for his help!
 *
 */

Prince.trackBoxes = true;
window.addEventListener("load", prep_index, false);
Prince.addScriptFunc( "index_term", index_term );

/* Takes an arbitrary number of page number arguments, and returns
 * text from them, after de-duplication, so:
 *
 * index_term( 1, 2, 3, 3, 3, 7, 7, 7 )
 *
 * becomes:
 *
 * "1-3, 7"
 *
 */
function index_term()
{
  var text='';
  var last=0;
  var range=false;
  // console.log('it: ' + arguments)
  for(var i=0; i<arguments.length; i++)
  {
    var arg = arguments[i];
    if( last != arg ) {
      if( Number(arg) == (Number(last) + 1) ) {
        range = true;
        last = arg;
      } else {
        if( range == true ) {
          // If we're in a range but the argument is *not* in said
          // range, we end the range
          text = text + "-" + last
          range = false;
        }

        if( text != '' ) {
          text = text + ", "
        }
        text = text + arg;
        last = arg;
      }
    }
  }

  // Boo code repitition
  if( range == true ) {
    // If we're in a range but the argument is *not* in said
    // range, we end the range
    text = text + "-" + last
    range = false;
  }

  return text;
}

/* The basics here come from
 * http://www.princexml.com/forum/topic/3129/merge-repeated-cross-links?p=1#15392
 * ; much thanks to mikeday for his help!
 *
 * The goal here is to turn index dt elements from:
 *
 * <dt>little: <a class="indexterm" href="#idm217009053168">Three-part tanru grouping with bo</a>, <a class="indexterm" href="#idm217009048368">Three-part tanru grouping with bo</a>, <a class="indexterm" href="#idm217009044128">Three-part tanru grouping with bo</a></dt>
 *
 * to:
 *
 * <dt>little: <span style="content: prince-script(index_term, target-counter(url(#idm217009053168), page), target-counter(url(#idm217009048368), page), target-counter(url(#idm217009044128), page))"></span></dt>
 *
 * and then the actual index collapsing happens in index_term above.
 */
function prep_index()
{
  ix = document.getElementsByClassName("indexdiv");
  for(var i=0; i<ix.length; i++)
  {
    // dts = ix[i].getElementsByTagName("dl")[0].getElementsByTagName("dt")
    dts = ix[i].getElementsByTagName("dt")
    for(var j=0; j<dts.length; j++)
    {
      // console.log(dts[j].textContent);
      var parent = dts[j];
      // console.log(dts[j].firstChild.nodeValue);
      links = dts[j].getElementsByTagName("a")
      var text = '';
      var first = true;
      // console.log('ll: ' + links.length );
      for(var k=0; k<links.length; k++) {
        if( text == '' ) {
          text = '<span style="content: prince-script(index_term, ';
        }
        var child = links[k];
        // console.log('child: ' + child.textContent);
        var hrefHash = links[k].getAttribute("href");
        // console.log('hh: ' + hrefHash);

        if( first ) {
          first = false;
        } else {
          text = text + ", ";
        }
        text = text + "target-counter(url(" + hrefHash + "), page)";
      }
      if( text != '' ) {
        text = text + ' )"></span>'
        var firstText = "";
        for (var i = 0; i < parent.childNodes.length; i++) {
          var curNode = parent.childNodes[i];
          if (curNode.nodeName === "#text") {
            firstText = curNode.nodeValue;
            break;
          }
        }
        parent.innerHTML = firstText + text;
      }
      // console.log(text);
    }
  }
}
