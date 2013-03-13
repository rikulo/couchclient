part of rikulo_memcached;

/**
 * The protocol operation type.
 */
class OnErrorType extends Enum {
  /**
   * Stop the processing of the view query when an error occurs and populate
   * the errors response with details.
   *
   */
  static const STOP = const OnErrorType(0x01, 'stop');
  /**
   * Continue processing the query even if errors occur, populating the errors
   * response at the end of the query response.
   *
   * This is the default if no on_error argument is supplied.
   */
  static const CONTINUE = const OnErrorType(0x02, 'continue');

  final String name;
  const OnErrorType(int ordinal, this.name)
      : super(ordinal);
}
