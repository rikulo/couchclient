//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Apr 10, 2013  04:17:08 PM
// Author: hernichen

part of couchclient;

/**
 * An implementation of observer for calling Reconfigurable.
 */
class ReconfigurableObserver implements Observer<Bucket> {
  final Reconfigurable _reconfig;
  Logger _logger;

  ReconfigurableObserver(Reconfigurable reconfig)
      : _reconfig = reconfig {
    _logger = initLogger('couchclient.config', this);
  }

  /**
   * Delegates update to the reconfigurable passed in the constructor.
   */
  void update(Observable o, Bucket arg) {
    _logger.finest("Receive an update, notifying reconfigurables about a $arg");
    _logger.finest("It says it is ${arg.name} and it is talking to ${arg.streamingUri}");
    _reconfig.reconfigure(arg);
  }

  @override
  int get hashCode => _reconfig.hashCode;

  bool operator ==(other) {
    if (identical(this, other))
      return true;
    if (other is! ReconfigurableObserver)
      return false;

    return _reconfig == other._reconfig;
  }
}

