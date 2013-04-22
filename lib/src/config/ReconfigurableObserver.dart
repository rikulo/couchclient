//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Apr 10, 2013  04:17:08 PM
// Author: hernichen

part of couchclient;

class ReconfigurableObserver implements Observer<Bucket> {
  final Reconfigurable _reconfig;
  Logger _logger;

  ReconfigurableObserver(Reconfigurable reconfig)
      : _reconfig = reconfig;

  void update(Observable o, Bucket arg) {
    _logger.finest("Receive an update, notifying reconfigurables about a $arg");
    _logger.finest("It says it is ${arg.name} and it is talking to ${arg.streamingUri}");
    _reconfig.reconfigure(arg);
  }

  int get hashCode
  => _reconfig.hashCode;
}

