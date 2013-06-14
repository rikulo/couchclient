//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Jun 14, 2013  05:23:51 PM
// Author: hernichen

part of couchclient;

/**
 * The enum of different Couchbase Bucket type.
 */
class AuthType extends Enum {
  /**
   * No authentication.
   */
  static const NONE = const AuthType(0x00, 'none');

  /**
   * Specifies SASL authentication.
   */
  static const SASL = const AuthType(0x01, 'sasl');

  final String name;
  const AuthType(int ordinal, this.name)
      : super(ordinal);
}
