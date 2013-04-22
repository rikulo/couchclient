#Rikulo Couchbase Client

[Rikulo Couchbase Client](http://rikulo.org) is a client implementation in Dart 
language of [Couchbase](http://www.couchbase.com/), an open source NoSQL 
database. 

* [Home](http://rikulo.org)
* [Discussion](http://stackoverflow.com/questions/tagged/rikulo)
* [Issues](https://github.com/rikulo/couchclient/issues)

Rikulo Couchbase Client is distributed under the Apache 2.0 License.

##Install from Dart Pub Repository

Add this to your `pubspec.yaml` (or create it):

    dependencies:
      couchclient:

Then run the [Pub Package Manager](http://pub.dartlang.org/doc) (comes with 
the Dart SDK):

    pub install

##Install from Github for Bleeding Edge Stuff

To install stuff that is still in development, add this to your `pubspec.yam`:

    dependencies:
      couchclient:
        git: git://github.com/rikulo/couchclient.git

For more information, please refer to [Pub: Dependencies]
(http://pub.dartlang.org/doc/pubspec.html#dependencies).

##Usage

Using Rikulo Couchbase Client is straightforward.

    import "package:couchclient/couchclient.dart"; //Couchbase Client APIs

##Notes to Contributors

###Test and Debug

You are welcome to submit [bugs and feature requests]
(https://github.com/rikulo/couchclient/issues). Or even better if you can 
fix or implement them!

###Fork Rikulo Couchbase Client

If you'd like to contribute back to the core, you can [fork this repository]
(https://help.github.com/articles/fork-a-repo) and send us a pull request, 
when it is ready.

Please be aware that one of Rikulo Couchbase Client's design goals is to 
keep the sphere of API as neat and consistency as possible. Strong enhancement 
always demands greater consensus.

If you are new to Git or GitHub, please read 
[this guide](https://help.github.com/) first.
