import 'dart:async';
import 'dart:convert' show UTF8, JSON;
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';

/**
 * This program assumes that Couchbase Server 2.0 is installed and the sample
 * data which is contained in default is created and ready for use.
 *
 * see examples of Java client in http://www.couchbase.com/develop/java/current.
 */
void main() {
  // Connect to server per the provided Uris
  // Here assume your Couchbase Server is installed on localhost
  // Use "default" bucket with no password
  CouchClient
  .connect([Uri.parse("http://127.0.0.1:8091/pools")], "default", "")
  //when client is ready, query the database
  .then((client) => queryByView(client))
  // Catch all possible errors/exceptions
  .catchError((err) => print("$err"));
}

/**
 * The JavaScript Map-Reduce View function. It will look at the documents in
 * the bucket and emite the name and id as a key value pairs, if they are of
 * type "beer" and they have a name
 */
String VIEW = '''
function (doc, meta) {
  if (doc.type && doc.name && doc.type == "beer") {
    emit(doc.name, meta.id);
  }
}''';

/**
 * Read a document whose name is "Wrath" using the View function.
 */
Future queryByView(CouchClient client) {
  // Prepare View function with name "by_name"
  ViewDesign vd = new ViewDesign("by_name", VIEW);
  // Prepare Design document with the name "beer"
  DesignDoc dd = new DesignDoc("beer", views: [vd]);

  // Add the design document "beer" with "by_name" map function into database
  return client.addDesignDoc(dd)
  // Get ViewDesign function "by_name" from DesignDocument "beer"
  .then((_) => client.getView("beer", "by_name"))
  // When ViewDesign function is ready
  .then((view) {
    // Configurate Query object
    Query query = new Query();
    // Retreive the beer with name "Wrath"
    query.key = "Wrath";
    // Include associated document as well
    query.includeDocs = true;

    // Query the server and return the ViewResponse
    return client.query(view, query);
  })
  // Process the View response
  .then((results) {
    for (ViewRow row in results.rows) {
      // Convert List<int> to String
      String data = UTF8.decode(row.doc.data);
      // Print out some infos about the document
      print("The Key is: ${row.key}");
      print("The full document is : ${data}");

      // Convert it back to an object with json
      Map bm = JSON.decode(data);
      Beer beer = new Beer.fromMap(bm);

      print("Hi, my name is ${beer.name}!");
    }
  })
  // Close the client
  .then((_) => client.close());
}

/**
 * The Beer class to model the Json document
 */
class Beer {
  String name;
  double abv;
  double ibu;
  double srm;
  int upc;
  String type;
  String brewery_id;
  String updated;
  String description;
  String style;
  String category;

  Beer.fromMap(Map<String,dynamic> m) {
    this.name = m['name'];
    this.abv = m['abv'];
    this.ibu = m['ibu'];
    this.srm = m['srm'];
    this.upc = m['upc'];
    this.type = m['type'];
    this.brewery_id = m['brewery_id'];
    this.updated = m['updated'];
    this.description = m['description'];
    this.style = m['style'];
    this.category = m['category'];
  }
}
