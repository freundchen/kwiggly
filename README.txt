- in short: restructured, adress book integration, system preference access

- bindings are now generally distinguished by different "schemes", i.e. everything up to the first colon consitute the scheme of a binding. currently, four schemes are supported:

          http://www.foo.bar/%@  ---> http scheme
          url:mailto:foo@bar.com ---> url scheme
          script:systemprefs     ---> script scheme
          builtin:about          ---> builtin scheme


- no hard wired keywords anymore. to get them back, you have to bind them yourself using the
  (new) builtin-scheme:

        pref -> builtin:preferences
        about -> builtin:about
        quit, q -> builtin:quit

  or delete your preferences ... :-)


- attach AppleScripts to keywords via the script-scheme. try binding "mail" -> "script:newmail". (see below for an explanation what the newmail-script does)

- scripts are searched in ( ~ | / | /Network | /System )/Library/Application Support/Kwiggly/Scripts   and in the bundle itself. to     bind to a script called myscript.scpt simply use "script:myscript" the script itself needs to define a subroutine 
"on feedMe(searchString)" which will be called with the users input.
  
- each scheme has a corresponding handler in the Resolver (called automatically via reflection from the scheme name) which is passed whatever has been configured in the prefs and the actual searchString. e.g. if "gg" is bound to "http://www.google.com/q=%@" and the users enters "gg cool mac utilities" then the "httpHandler:searchString:" will be called with the params "//www.google.com/q=%@" and
   "cool mac utililities" and it's this handlers job to do the actual replacement. (actually, the http-scheme is only there for convenience reasons, since the url-scheme alone suffices to handle all kind of urls.)

- added a new class Builtins which contains all functions that can be used as buitins. each method taking one string as an argument is automatically a builtin and can be used literally with the builtin-scheme. (e.g. builtin:about will automatically call Builtins.about: via reflection)

- reworked "newmail.scpt" to offer more functionality over a simple "mailto:"-URL. this script will now either immediately open a new mail if passed s.th. containing an "@" (assuming it's a complete eMail-address) or search the address book for a person with a corresponding name and then creating a new email to this person

- added systemprefs-script. this will open system preferences and open the first pane whose localized name starts with the searchstring. e.g. adding a binding "sp" -> "script:systemprefs" and then entering "sp net" should take you to the network preferences.

- miscellaneous clean ups. moved string constants for notifications and defaults in new class Commons.m with header Commons.h

