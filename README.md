axiom-sexp
============

[![Build Status](https://secure.travis-ci.org/mbj/axiom-sexp.png?branch=master)](http://travis-ci.org/mbj/axiom-sexp)
[![Dependency Status](https://gemnasium.com/mbj/axiom-sexp.png)](https://gemnasium.com/mbj/axiom-sexp)
[![Code Climate](https://codeclimate.com/github/mbj/axiom-sexp.png)](https://codeclimate.com/github/mbj/axiom-sexp)

A simple generator/parser from/to [axiom](https://github.com/dkubb/axiom)/s-expressions.

Usage
-----

```
require 'axiom'
require 'axiom-sexp'

relation = Veritas::Relation::Base.new(:name, Veritas::Relation::Header.coerce([[:id, Integer], [:foo, String]])

Veritas::Sexp::Generator.visit(relation) # => [ :base, :name, [[ :id, Veritas::Attribute::Integer ], [ :foo, Veritas::Attribute::String ]] ]
   

Installation
------------

There is currently no gem release. Use git source in your Gemfile:

```gem 'axiom-sexp', :git => 'https://github.com/mbj/axiom-sexp'```

Credits
-------

* [Markus Schirp (mbj)](https://github.com/mbj) Author

Contributing
-------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with Rakefile or version
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

License
-------

See LICENSE file.
