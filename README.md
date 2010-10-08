# Loosely Coupled Web App Skeleton

This is how I generally start small webapps - with a basic structure and file layout, nothing too complex.
I've done this 4 or 5 times lately, each time growing the structure a bit, and in the interests of
avoiding repetition, I thought I'd save the definitive app skeleton for me (and others!) to use as a starting point.

Naming this sort of thing is hard - I chose "loosely coupled" as that's the main philosophical deviation from
most webapp samples - I don't want html generated on the server and manipulated on a client a-la Rails - I
want to use the server to handle data, the client to render the data, and keep them relatively separate.

## Goals
* ease of development
* ease of comprehension
* ease of testing
* loose coupling, so I can change clients and servers easily
* tend towards static html to make offline apps easier in the future
* not caring awfully about "progressive enhancement" - real apps need
to care, I'm mostly assuming a modern browser with javascript enabled
* ugly languages can be precompiled - css from sass/scss, javascript
from coffeescript.
* use the power of the shiny new web technologies available
* respect YAGNI - don't spend effort supporting things you might need some day. If you are building an enterprise app
    that definitely needs the stuff below, don't use this skeleton, use Rails or the like.

## What isn't handled
* old browsers - ie8 should be OK (though not heavily tested), the rest are out of scope
* accessibility - specifically, folks with Javascript off will not get far. There are ways around this, but they are too big for this app
* searchability - you can make your app SEO-friendly, but you'll probably want to dynamically build a pile of html
    to make it work; if you build everything in Javascript, Google and the like will only see your front page.
    This can be solved, it's just beyond the scope of this little app skeleton!
* databases - just because everyone has their favourite, and it should be pretty easy to put your own favourite behind
    the server's json APIs
* REST - you can do restful json APIs by hand, I just haven't built any here. Or you could use Rails.

## Technology choices
* communications between client and server are mostly json over http
* the server logic is in ruby via sinatra
* the view logic is in javascript via sammy.js and jquery (and probably other handy libraries soon)
* modern web features are detected via modernizr.js
* css is built at compile-time from scss via sass
* javascript is (optionally) built at compile-time from coffeescript
* precompiling of scss/coffeescript is separate from the app - it's done via command-line scripts (see watch_all.sh)
* Sinatra is used for gluing everything together
* Bundler for handling Ruby gem dependencies
* Web pages are static html and resources (may add option one day to build from templates at compile-time)

## Architecture
The basic architecture, front-to-back, is:
- web pages are static html
- the view layer is built using sammy.js and jquery at run-time
- anything dynamic needed from the server is fetched asynchronously via json-over-http calls
- for future offline application building, try to handle the situation where no server is available gracefully
- i.e. cache data in browser storage. This also makes offline apps a possiblity. See [http://diveintohtml5.org/storage.html]
- it also lets you run without a database at all for simple apps

## TODO
- upload to github
- add a "getting started" section for building from scratch (especially installing coffeescript!)
- add rake tasks to compile coffee/scss manually, and to stop/start watch servers
- work out how to do client-side templating
- think about precompiling html from template languages - see how bonsai works, or other similar options.
- actually implement offline application behaviour [http://diveintohtml5.org/offline.html]
- more testing:
-- rspec server-side unit testing
-- javascript client-side unit testing
-- javascript client/server integration testing
-- selenium and cucumber for acceptance-style BDD testing

## Notes
- Sass is handled by rack not by sinatra - see http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#rackrailsmerb_plugin
- CoffeeScript might need to be optional - I like it, but it doesn't fit nicely in the ruby/gems world
