//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of rikulo_memcached;

class Query {
  static const String DESCENDING = "descending";
  static const String ENDKEY = "endkey";
  static const String ENDKEYDOCID = "endkey_docid";
  static const String GROUP = "group";
  static const String GROUPLEVEL = "group_level";
  static const String INCLUSIVEEND = "inclusive_end";
  static const String KEY = "key";
  static const String KEYS = "keys";
  static const String LIMIT = "limit";
  static const String REDUCE = "reduce";
  static const String SKIP = "skip";
  static const String STALE = "stale";
  static const String STARTKEY = "startkey";
  static const String STARTKEYDOCID = "startkey_docid";
  static const String ONERROR = "on_error";
  static const String BBOX = "bbox";
  static const String DEBUG = "debug";
  bool includedocs = false;

  Map<String, Object> _args;

  /**
   * Creates a new Query object with default settings.
   */
  Query() {
    _args = new HashMap<String, Object>();
  }

  /**
   * Read if reduce is enabled or not.
   *
   * @return Whether reduce is enabled or not.
   */
  bool get willReduce
  => _args.containsKey(REDUCE) ? _args[REDUCE] : false;

  /**
   * Read if full documents will be included on the query.
   *
   * @return Whether the full documents will be included or not.
   */
  bool get willIncludeDocs
  => includedocs;

  /**
   * Return the documents in descending by key order.
   *
   * @param descending True if the sort-order should be descending.
   * @return The Query instance.
   */
  void setDescending(bool descending) {
    _args[DESCENDING] = descending;
  }

  /**
   * Stop returning records when the specified document ID is reached.
   *
   * @param endkeydocid The document ID that should be used.
   * @return The Query instance.
   */
  void setEndkeyDocID(String endkeydocid) {
    _args[ENDKEYDOCID] = endkeydocid;
  }

  /**
   * Group the results using the reduce function to a group or single row.
   *
   * @param group True when grouping should be enabled.
   * @return The Query instance.
   */
  void setGroup(bool group) {
    _args[GROUP] = group;
  }

  /**
   * Specify the group level to be used.
   *
   * @param grouplevel How deep the grouping level should be.
   * @return The Query instance.
   */
  void setGroupLevel(int grouplevel) {
    _args[GROUPLEVEL] = grouplevel;
  }

  /**
   * If the full documents should be included in the result.
   *
   * @param include True when the full docs should be included in the result.
   * @return The Query instance.
   */
  void setIncludeDocs(bool include) {
    this.includedocs = include;
  }

  /**
   * Specifies whether the specified end key should be included in the result.
   *
   * @param inclusiveend True when the key should be included.
   * @return The Query instance.
   */
  void setInclusiveEnd(bool inclusiveend) {
    _args[INCLUSIVEEND] = inclusiveend;
  }

  /**
   * Return only documents that match the specified key.
   *
   * The "key" param must be specified as a valid JSON string, but the
   * ComplexKey class takes care of this. See the documentation of the
   * ComplexKey class for more information on its usage.
   *
   * @param key The document key.
   * @return The Query instance.
   */
  void setComplexKey(ComplexKey key) {
    _args[KEY] = key.toJson();
  }

  /**
   * Return only documents that match the specified key.
   *
   * Note that the given key string has to be valid JSON!
   *
   * @param key The document key.
   * @return The Query instance.
   */
  void setKey(String key) {
    _args[KEY] = key;
  }

  /**
   * Return only documents that match each of keys specified within the given
   * array.
   *
   * The "keys" param must be specified as a valid JSON string, but the
   * ComplexKey class takes care of this. See the documentation of the
   * ComplexKey class for more information on its usage.
   *
   * Also, sorting is not applied when using this option.
   *
   * @param keys The document keys.
   * @return The Query instance.
   */
  void setKeys(ComplexKey keys) {
    _args[KEYS] = keys.toJson();
  }

//  /**
//   * Return only documents that match each of keys specified within the given
//   * array.
//   *
//   * Note that the given key string has to be valid JSON! Also, sorting is not
//   * applied when using this option.
//   *
//   * @param keys The document keys.
//   * @return The Query instance.
//   */
//  void setKeys(String keys) {
//    _args.put(KEYS, keys);
//    return this;
//  }

  /**
   * Limit the number of the returned documents to the specified number.
   *
   * @param limit The number of documents to return.
   * @return The Query instance.
   */
  void setLimit(int limit) {
    _args[LIMIT] = limit;
  }

  /**
   * Returns the currently set limit.
   *
   * @return The current limit (or -1 if none is set).
   */
  int get limit
  => _args.containsKey(LIMIT) ? _args[LIMIT] : -1;

  /**
   * Returns records in the given key range.
   *
   * Note that the given key strings have to be valid JSON!
   *
   * @param startkey The start of the key range.
   * @param endkey The end of the key range.
   * @return The Query instance.
   */
  void setRange(String startkey, String endkey) {
    _args[ENDKEY] = endkey;
    _args[STARTKEY] = startkey;
  }

  /**
   * Returns records in the given key range.
   *
   * The range keys must be specified as a valid JSON strings, but the
   * ComplexKey class takes care of this. See the documentation of the
   * ComplexKey class for more information on its usage.
   *
   * @param startkey The start of the key range.
   * @param endkey The end of the key range.
   * @return The Query instance.
   */
  void setComplexRange(ComplexKey startkey, ComplexKey endkey) {
    _args[ENDKEY] = endkey.toJson();
    _args[STARTKEY] = startkey.toJson();
  }

  /**
   * Return records with a value equal to or greater than the specified key.
   *
   * Note that the given key string has to be valid JSON!
   *
   * @param startkey The start of the key range.
   * @return The Query instance.
   */
  void setRangeStart(String startkey) {
    _args[STARTKEY] = startkey;
  }

  /**
   * Return records with a value equal to or greater than the specified key.
   *
   * The range key must be specified as a valid JSON string, but the
   * ComplexKey class takes care of this. See the documentation of the
   * ComplexKey class for more information on its usage.
   *
   * @param startkey The start of the key range.
   * @return The Query instance.
   */
  void setComplexRangeStart(ComplexKey startkey) {
    _args[STARTKEY] = startkey.toJson();
  }

  /**
   * Use the reduction function.
   *
   * @param reduce True if the reduce phase should also be executed.
   * @return The Query instance.
   */
  void setReduce(bool reduce) {
    _args[REDUCE] = reduce;
  }

  /**
   * Stop returning records when the specified key is reached.
   *
   * Note that the given key string has to be valid JSON!
   *
   * @param endkey The end of the key range.
   * @return The Query instance.
   */
  void setRangeEnd(String endkey) {
    _args[ENDKEY] = endkey;
  }

  /**
   * Stop returning records when the specified key is reached.
   *
   * The range key must be specified as a valid JSON string, but the
   * ComplexKey class takes care of this. See the documentation of the
   * ComplexKey class for more information on its usage.
   *
   * @param endkey The end of the key range.
   * @return The Query instance.
   */
 void setComplexRangeEnd(ComplexKey endkey) {
    _args[ENDKEY] = endkey.toJson();
  }

  /**
   * Skip this number of records before starting to return the results.
   *
   * @param docstoskip The number of records to skip.
   * @return The Query instance.
   */
 void setSkip(int docstoskip) {
    _args[SKIP] = docstoskip;
  }

  /**
   * Allow the results from a stale view to be used.
   *
   * See the "Stale" enum for more information on the possible options. The
   * default setting is "update_after"!
   *
   * @param stale Which stale mode should be used.
   * @return The Query instance.
   */
  void setStale(Stale stale) {
    _args[STALE] = stale;
  }

  /**
   * Return records starting with the specified document ID.
   *
   * @param startkeydocid The document ID to match.
   * @return The Query instance.
   */
  void setStartkeyDocID(String startkeydocid) {
    _args[STARTKEYDOCID] = startkeydocid;
  }

  /**
   * Sets the response in the event of an error.
   *
   * See the "OnError" enum for more details on the available options.
   *
   * @param opt The appropriate error handling type.
   * @return The Query instance.
   */
  void setOnErrorType(OnErrorType opt) {
    _args[ONERROR] = opt;
  }

  /**
   * Sets the params for a spatial bounding box view query.
   *
   * @param lowerLeftLong The longitude of the lower left corner.
   * @param lowerLeftLat The latitude of the lower left corner.
   * @param upperRightLong The longitude of the upper right corner.
   * @param upperRightLat The latitude of the upper right corner.
   * @return The Query instance.
   */
  void setBbox(double lowerLeftLong, double lowerLeftLat,
    double upperRightLong, double upperRightLat) {
    String combined = "$lowerLeftLong,$lowerLeftLat,"
                      "$upperRightLong,$upperRightLat";
    _args[BBOX] = combined;
  }

  /**
   * Enabled debugging on view queries.
   *
   * @param debug True when debugging should be enabled.
   * @return The Query instance.
   */
  void setDebug(bool debug) {
    _args[DEBUG] = debug;
  }

  /**
   * Creates a new query instance and returns it with the properties
   * bound to the current object.
   *
   * @return The new Query object.
   */
  Query copy() {
    Query query = new Query();

    if (_args.containsKey(DESCENDING)) {
      query.setDescending(_args[DESCENDING]);
    }
    if (_args.containsKey(ENDKEY)) {
      query.setRangeEnd(_args[ENDKEY]);
    }
    if (_args.containsKey(ENDKEYDOCID)) {
      query.setEndkeyDocID(_args[ENDKEYDOCID]);
    }
    if (_args.containsKey(GROUP)) {
      query.setGroup(_args[GROUP]);
    }
    if (_args.containsKey(GROUPLEVEL)) {
      query.setGroupLevel(_args[GROUPLEVEL]);
    }
    if (_args.containsKey(INCLUSIVEEND)) {
      query.setInclusiveEnd(_args[INCLUSIVEEND]);
    }
    if (_args.containsKey(KEY)) {
      query.setKey(_args[KEY]);
    }
    if (_args.containsKey(KEYS)) {
      query.setKeys(_args[KEYS]);
    }
    if (_args.containsKey(LIMIT)) {
      query.setLimit(_args[LIMIT]);
    }
    if (_args.containsKey(REDUCE)) {
      query.setReduce(_args[REDUCE]);
    }
    if (_args.containsKey(SKIP)) {
      query.setSkip(_args[SKIP]);
    }
    if (_args.containsKey(STALE)) {
      query.setStale(_args[STALE]);
    }
    if (_args.containsKey(STARTKEY)) {
      query.setRangeStart(_args[STARTKEY]);
    }
    if (_args.containsKey(STARTKEYDOCID)) {
      query.setStartkeyDocID(_args[STARTKEYDOCID]);
    }
    if (_args.containsKey(ONERROR)) {
      query.setOnErrorType(_args[ONERROR]);
    }
    if (_args.containsKey(BBOX)) {
      List<String> bbox = (_args[BBOX] as String).split(",");
      query.setBbox(double.parse(bbox[0]), double.parse(bbox[1]),
        double.parse(bbox[2]), double.parse(bbox[3]));
    }
    if (_args.containsKey(DEBUG)) {
      query.setDebug(_args[DEBUG]);
    }
    query.setIncludeDocs(willIncludeDocs);

    return query;
  }

  /**
   * Returns the Query object as a string, suitable for the HTTP queries.
   *
   * @return Returns the query object as its string representation
   */
  //@Override
  String toString() {
    bool first = true;
    StringBuffer result = new StringBuffer();
    for (String key in _args.keys) {
      if (first) {
        result.write("?");
        first = false;
      } else {
        result.write("&");
      }
      String argument;
      try {
        argument = "$key=${prepareValue(key, _args[key])}";
      } catch (ex) {
        throw new ArgumentError("Could not prepare view argument: $ex");
      }
      result.write(argument);
    }
    return result.toString();
  }

  /**
   * Takes a given object, inspects its type and returns
   * its string representation.
   *
   * This helper method aids the toString() method so that it does
   * not need to transform map entries to their string representations
   * for itself. It also checks for various special cases and makes
   * sure the correct string representation is returned.
   *
   * When no previous match was found, the final try is to cast it to a
   * long value and treat it as a numeric value. If this doesn't succeed
   * either, then it is treated as a string.
   *
   * @param key The key for the corresponding value.
   * @param value The value to prepared.
   * @return The correctly formatted and encoded value.
   */
  String prepareValue(String key, dynamic value) {
    String encoded;
    if (key == STARTKEYDOCID || key == BBOX) {
      encoded = value;
    } else if (value is Stale) {
      encoded = value.name;
    } else if (value is OnErrorType) {
      encoded = value.name;
    } else {
      String valuestr = "$value";
      if (_isJsonObject(valuestr)) {
        encoded = valuestr;
      } else if (valuestr.startsWith('"')) {
        encoded = valuestr;
      } else {
        try {
          encoded = "${int.parse(valuestr)}";
        } on FormatException catch (e) {
          try {
            encoded = "${double.parse(valuestr)}";
          } on FormatException catch (e2) {
            encoded = '"$valuestr"';
          }
        }
      }
    }

    return encodeUriComponent(encoded);
  }

  /**
   * Returns all current args for proper inspection.
   *
   * @return returns the currently stored arguments
   */
  Map<String, Object> get args {
    return _args;
  }

  static bool _isJsonObject(String s) {
    if (s.startsWith("{") || s.startsWith("[") || s == "true"
        || s == "false" || s == "null") {
      return true;
    }
    try {
      int.parse(s);
      return true;
    } on FormatException catch (e) {
      return false;
    }
  }
}

