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

Using Rikulo Couchbase Client is straightforward. Connect to the server and
use the client's APIs to access the database.

    import "dart:uri";
    import "dart:utf";
    import "package:couchclient/couchclient.dart";

    void main() {
      // The unique key of the document
      final String KEY = "beer_Wrath";

      // The Json encoded document
      final String VALUE =
          '{"name":"Wrath","abv":9.0,'
          '"type":"beer","brewery_id":"110f1a10e7",'
          '"updated":"2010-07-22 20:00:20",'
          '"description":"WRATH Belgian-style ",'
          '"style":"Other Belgian-Style Ales",'
          '"category":"Belgian and French Ale"}';

      // Prepare connection factory
      // Here aassume your Couchbase Server is installed on localhost
      // Use "default" bucket with no password
      var fact = new CouchbaseConnectionFactory(
          [Uri.parse("http://localhost:8091/pools")], "default", "");

      // Connect to server per the provided connection factory
      CouchClient.connect(fact)
      //when client is ready
      .then((client) {
        // Do a set
        return client.set(KEY, encodeUtf8(VALUE))
        // Check if set succeeded and show message
        .then((ok) => print(ok ? "Set Succeeded" : "Set failed"))
        // Then get the value back by key
        .then((_) => client.get(KEY))
        // Check if get data equals to set one
        .then((val) => decodeUtf8(val.data) == VALUE)
        // Show message
        .then((ok) => print(ok ? "Get Succeeded" : "Get failed"))
        // Close the client
        .then((_) => client.close());
      })
      //catch all possible errors/exceptions
      .catchError((err) => print('Exception: $err'));
    }

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