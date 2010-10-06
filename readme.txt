Loosely Coupled Web App Skeleton
- this is how I generally start small webapps
- the goals are:
* ease of development
* ease of comprehension
* ease of testing
* loose coupling, so I can change clients and servers easily
* tend towards static html to make offline apps easier
* not caring awfully about "progressive enhancement" - real apps need
to care, I'm mostly assuming a modern browser with javascript enabled
* ugly languages can be precompiled - css from sass/scss, javascript
from coffeescript. Not so much of a fan of haml
- implementation:
* communications between client and server are mostly json over http
* the server logic is in ruby via sinatra
* the view logic is in javascript via sammy.js and jquery
* css can be built at compile-time from scss via sass
* precompiling of scss/coffeescript is separate from the app - do it
at the command line (rake precompile_now and rake precompile_watch commands)
* Sinatra is used for gluing everything together
* Bundler for handling Ruby gem dependencies
* Effectively static html5 for web pages, built from
** erb + yaml config (for now) with the possiblity of mustache or other templates later - using tilt?
***  Note though that it's assumed that data-driven pages will be built with Javascript
*** though anything you want SEO indexed might need to be in the static html pages
* Css3 built with Sass, using new-style SCSS
* Javascript built from CoffeeScript, plus the following libraries:
** JQuery for all the goodies JQuery gives you
** Sammy.js for client-side state management
** Sammy modules for client-side storage, page templating, etc
** Modernizr for browser feature detection
* A starter app with:
** basic html5/css3 template
** warnings for browsers with no js or missing html5 features
** sample json callbacks - see below for architecture and assumptions
* _No_ database - for many things I don't want a database, and even if I do, it'll be entirely hidden behind a Json API (possibly restful) so easily added later

Architecture
The basic architecture, front-to-back, is:
- front end is mostly static cacheable html5 plus asset files, optionally runnable offline
-- see http://diveintohtml5.org/offline.html
- anything dynamic needed from the server is fetched asynchronously via json-over-http calls
-- as mentioned earlier, if you are worried about SEO you might need some static html, also think about scalability -but note:
- make sure where possible data is cached in the browser local storage!
  http://diveintohtml5.org/storage.html
- back-end storage might be set up later; I tend to use MongoDB, but that gets tricky when deploying, so I'd prefer to make it optional, as many apps don't really need a DB if they have client-side storage

Assumptions:
- Javascript is available for anything non-trivial; keep SEO and accessibility in mind, but don't cripple your architecture.  Considering examining Google's hints for SEO and Ajax calls...
- Modern web browsers are the primary goal - warn users if features are unavailable, try to degrade nicely on ie7+ at least.
- Handling intermittently going offline makes for nice apps for phones, iPads, netbooks, and future mobile devices

TODO:
- use tilt instead of explicit erb / sass ?
- work out how to get html templates neatly into javascript source? Allows for smart editing, possibly sharing between server-side and client-side html
- option to precompile template files to htmlcan we get tilt or similar to compile to .html files via rake? I'd like something like bonsai to build a mostly plain system...

Notes:
- Sass is handled by rack not by sinatra - see http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#rackrailsmerb_plugin
- CoffeeScript might need to be optional - I like it, but it doesn't fit nicely in the ruby/gems world
