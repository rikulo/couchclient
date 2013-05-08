part of couchclient;

/**
 * An enum containing the possible values for the stale
 * parameter.
 */
class Stale extends Enum {
  static const OK  = const Stale(0x01, 'ok');

  static const FALSE = const Stale(0x02, 'false');

  static const UPDATE_AFTER = const Stale(0x03, 'update_after');

  final String name;
  const Stale(int ordinal, this.name)
      : super(ordinal);
}
