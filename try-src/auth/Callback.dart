//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 15, 2013  03:35:02 PM
// Author: hernichen

part of rikulo_memcached;

/**
 * Marker interface for authentication Callback.
 */
abstract class Callback {}

class NameCallback implements Callback {
  /**
   * Username provided by application.
   */
  String name;

  /**
   * Prompt used to request the name.
   */
  final String prompt;

  /**
   * Default name used along with the prompt.
   */
  final String defaultName;

  NameCallback(this.prompt, [this.defaultName]);
}

class PasswordCallback implements Callback {
  /**
   * password provided by application.
   */
  String password;

  /**
   * Prompt used to request the password.
   */
  final String prompt;

  /**
   * Whether the password should be displayed as it is being typed.
   */
  final bool echoOn;

  PasswordCallback(this.prompt, this.echoOn);
}