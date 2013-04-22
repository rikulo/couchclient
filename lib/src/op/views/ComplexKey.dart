//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of couchclient;

/**
 * Allows simple definition of complex JSON keys for query inputs.
 *
 * If you use the ComplexKey class, the stored objects ultimately get converted
 * into a JSON string. As a result, make sure your custom objects implement the
 * "toString" method accordingly (unless you work with trivial types like
 * Strings or numbers).
 *
 * Here are some simple examples:
 *
 * // generated JSON: [2012,9,7]
 * new ComplexKey([2012, 9, 7]);
 *
 * // generated JSON: ["Hello","World",5.12]
 * new ComplexKey(["Hello", "World", 5.12]);
 *
 * // generated JSON: {}
 * new ComplexKey.emptyKey();
 *
 * // generated JSON: []
 * new ComplexKey.emptyKeyArray();
 *
 */
class ComplexKey {
  static final ComplexKey EMPTY_KEY = new ComplexKey({});
  static final ComplexKey EMPTY_KEY_ARRAY = new ComplexKey([]);

  final keys;

  ComplexKey(var keys)
      : this.keys = keys;

  /**
   * Returns a single empty key.
   *
   * @return Returns the empty object
   */
  factory ComplexKey.emptyKey()
  => ComplexKey.EMPTY_KEY;

  /**
   * Returns an empty array of objects.
   *
   * @return Returns an empty array of objects
   */
  factory ComplexKey.emptyKeyArray()
  => ComplexKey.EMPTY_KEY_ARRAY;

  /**
   * Generate a JSON string of the ComplexKey.
   *
   * This method is responsible for processing and converting the
   * complex key list and returning it as a JSON string. This string
   * heavily depends on the structure of the stored objects.
   *
   * @return the JSON of the underlying complex key
   */
  String toJson()
  => json.stringify(keys);
}
