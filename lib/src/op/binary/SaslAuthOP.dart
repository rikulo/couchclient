//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 15, 2013  03:35:02 PM
// Author: hernichen

part of rikulo_memcached;

class SaslAuthOP extends SaslOP {
  int retry;
  SaslAuthOP(String mechanism, List<int> authData, int retry)
      : this.retry = retry,
        super(OPType.saslAuth, mechanism, authData);

  bool _authenticated;
  int handleData(List<int> aLine) {
    if (_status == OPStatus.AUTHEN_ERROR.code) {//authentication failure
      _authenticated = false;
      _cmpl.complete(false);
    } else if (_status == OPStatus.NO_ERROR.code) {//success
      _authenticated = true;
      _cmpl.complete(true);
    } else { //unknown status
      _authenticated = false;
      _cmpl.completeError(new UnsupportedError("OPStatus:$_status"));
    }
    return _HANDLE_COMPLETE;
  }

  List<int> _prepareSaslCommand(OPType type, String key, List<int> val) {
    _logger.finest("_prepareSaslAuthCommand:$cmd");
    return super._prepareSaslCommand(type, key, val);
  }

  String toString()
  => 'SaslAuthOP: $seq';
}
