//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of couchclient;

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
  bool _includedocs = false;

  final Map<String, Object> _args;

  /**
   * Creates a new Query object with default settings.
   */
  Query()
      : _args = new HashMap<String, Object>();

  /**
   * Returns whether reduce is enabled or not.
   */
  bool get willReduce
  => _args.containsKey(REDUCE) ? _args[REDUCE] : false;

  /**
   * Returns whether the full documents will be included in the query
   * results.
   */
  bool get includeDocs
  => _includedocs;

  /**
   * Sets query results in key descending order. true to return query
   * results in key descending order; false to return query results
   * in key ascending order.
   */
  void set descending(bool descending) {
    _args[DESCENDING] = descending;
  }

  /**
   * Sets the end document id for this query.
   */
  void set endkeyDocID(String endkeydocid) {
    _args[ENDKEYDOCID] = endkeydocid;
  }

  /**
   * Sets whether to make query results into groups or a single row
   * with reduce function. true to reduce into groups; otherwise to
   * a single row.
   */
  void set group(bool group) {
    _args[GROUP] = group;
  }

  /**
   * Sets how deep the goruping level should be.
   */
  void set groupLevel(int grouplevel) {
    _args[GROUPLEVEL] = grouplevel;
  }

  /**
   * Sets true to include full documents in the query results.
   * This implementation call client's getAll() for you so the
   * performance is not necessary better.
   */
  void set includeDocs(bool include) {
    this._includedocs = include;
  }

  /**
   * Sets true to specify that end key should be included in the query result.
   */
  void set inclusiveEnd(bool inclusiveend) {
    _args[INCLUSIVEEND] = inclusiveend;
  }

  /**
   * Sets the key to retrive the matched document.
   */
  void set key(String key) {
    _args[KEY] = key;
  }

  /**
   * Sets query to return documents that match each of keys specified.
   */
  void set keys(List<String> keys) {
    _args[KEYS] = JSON.encode(keys);
  }

  /**
   * Set the number of the query results to the specified number.
   */
  void set limit(int limit) {
    _args[LIMIT] = limit;
  }

  /**
   * Returns the currently set limit.
   */
  int get limit
  => _args.containsKey(LIMIT) ? _args[LIMIT] : -1;

  /**
   * Sets the key range of this query.
   */
  void setRange(String startkey, String endkey) {
    _args[ENDKEY] = endkey;
    _args[STARTKEY] = startkey;
  }

  /**
   * Sets the start key of a range for this query. If your keys are complex
   * ones, use [#complexRangeStart] instead.
   */
  void set rangeStart(String startkey) {
    _args[STARTKEY] = startkey;
  }

  /**
   * Set true to use the reduction function.
   */
  void set reduce(bool reduce) {
    _args[REDUCE] = reduce;
  }

  /**
   * Sets the end key of a range for this query. If your keys are complex
   * ones, use [#complexRangeEnd] instead.
   */
  void set rangeEnd(String endkey) {
    _args[ENDKEY] = endkey;
  }

  /**
   * Set the number of records skipped before starting to return the results.
   */
  void set skip(int docstoskip) {
    _args[SKIP] = docstoskip;
  }

  /**
   * Set the "Stale" type for document re-indexing. Default setting
   * is Stale.UPDATE_AFTER.
   *
   * + [Stale.OK] - Use current index for query without re-indexing first.
   * + [Stale.FALSE] - re-indexing first if necessary; then query.
   * + [Stale.UPDATE_AFTER] - Use current index for query and mark re-indexing
   *   later.
   */
  void set stale(Stale stale) {
    _args[STALE] = stale;
  }

  /**
   * Sets the start document id for this query.
   */
  void set startkeyDocID(String startkeydocid) {
    _args[STARTKEYDOCID] = startkeydocid;
  }

  /**
   * Sets the response type when error occured in this query. default
   * is [OnErrorType.CONTINUE].
   */
  void set onErrorType(OnErrorType opt) {
    _args[ONERROR] = opt;
  }

  /**
   * Sets the params for a spatial bounding box view query.
   *
   * + [lowerLeftLong] -  The longitude of the lower left corner.
   * + [lowerLeftLat] - The latitude of the lower left corner.
   * + [upperRightLong] - The longitude of the upper right corner.
   * + [upperRightLat] - The latitude of the upper right corner.
   */
  void setBbox(double lowerLeftLong, double lowerLeftLat,
    double upperRightLong, double upperRightLat) {
    String combined = "$lowerLeftLong,$lowerLeftLat,"
                      "$upperRightLong,$upperRightLat";
    _args[BBOX] = combined;
  }

  /**
   * Set true to enabled debugging on view queries.
   */
  void set debug(bool debug) {
    _args[DEBUG] = debug;
  }

  /**
   * Creates and return a new query instance with the same properties
   * bound to this query.
   */
  Query clone() {
    Query query = new Query();

    if (_args.containsKey(DESCENDING)) {
      query.descending = _args[DESCENDING];
    }
    if (_args.containsKey(ENDKEY)) {
      query.rangeEnd = _args[ENDKEY];
    }
    if (_args.containsKey(ENDKEYDOCID)) {
      query.endkeyDocID = _args[ENDKEYDOCID];
    }
    if (_args.containsKey(GROUP)) {
      query.group = _args[GROUP];
    }
    if (_args.containsKey(GROUPLEVEL)) {
      query.groupLevel = _args[GROUPLEVEL];
    }
    if (_args.containsKey(INCLUSIVEEND)) {
      query.inclusiveEnd = _args[INCLUSIVEEND];
    }
    if (_args.containsKey(KEY)) {
      query.key = _args[KEY];
    }
    if (_args.containsKey(KEYS)) {
      query.keys = _args[KEYS];
    }
    if (_args.containsKey(LIMIT)) {
      query.limit = _args[LIMIT];
    }
    if (_args.containsKey(REDUCE)) {
      query.reduce = _args[REDUCE];
    }
    if (_args.containsKey(SKIP)) {
      query.skip = _args[SKIP];
    }
    if (_args.containsKey(STALE)) {
      query.stale = _args[STALE];
    }
    if (_args.containsKey(STARTKEY)) {
      query.rangeStart = _args[STARTKEY];
    }
    if (_args.containsKey(STARTKEYDOCID)) {
      query.startkeyDocID = _args[STARTKEYDOCID];
    }
    if (_args.containsKey(ONERROR)) {
      query.onErrorType = _args[ONERROR];
    }
    if (_args.containsKey(BBOX)) {
      query._args[BBOX] = _args[BBOX];
    }
    if (_args.containsKey(DEBUG)) {
      query.debug = _args[DEBUG];
    }
    query.includeDocs = includeDocs;

    return query;
  }

  /**
   * Returns the Query object as a string, suitable for the HTTP queries.
   */
  @override
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
        argument = "$key=${_prepareValue(key, _args[key])}";
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
   * + [key] - The key for the corresponding value.
   * + [value] - The value to prepared.
   */
  String _prepareValue(String key, dynamic value) {
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

    return Uri.encodeComponent(encoded);
  }

  /**
   * Returns all current args for proper inspection.
   *
   * @return returns the currently stored arguments
   */
  Map<String, Object> get args
  => _args;

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

