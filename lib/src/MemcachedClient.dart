part of rikulo_memcached;

/**
 * Client to a memcached cluster servers.
 *
 * '''Basic usage'''
 *
 *     Future<MemcachedClient> future = MemcachedClient.connect(
 *       [new SocketAddress(host1,port1), new SocketAddress(host2,port2), ...],
 *       new BinaryConnectionFactory());
 *
 *     // Store a value (async) for one hour
 *     future
 *      .then((c) => c.set("someKey", someObject))
 *      .then((ok) => print("done"));
 *
 *     // Retrieve a value.
 *     future
 *      .then((c) => c.get("someKey"))
 *      .then((myObject) => print("$myObject"));
 */
abstract class MemcachedClient {
  /**
   * Maximum supported key length.
   */
  static const int MAX_KEY_LENGTH = 250;

  /**
   * Returns those servers that are currently active and respond to commands.
   */
  List<SocketAddress> get availableServers;

  /**
   * Returns those servers that are currently not active and cannot respond
   * to commands.
   */
  List<SocketAddress> get unavailableServers;

  /**
   * Returns default Transcoder used with this MemcachedClient.
   */
//  Transcoder get transcoder;

  /**
   * Returns the locator of the server nodes in the cluster.
   */
  NodeLocator get locator;

  /**
   * Set unconditinally the specified document. Returns
   * true if succeed; throw Error status otherwise.
   *
   * + [key] - the key of the document
   */
  Future<bool> set(String key, List<int> document, [int cas]);

  /**
   * Add specified document if the provided key is not existed yet. Returns
   * true if succeed; otherwise, throw OPStatus.NOT_STORED or
   * other Error status.
   */
  Future<bool> add(String key, List<int> document);

  /**
   * Replace the existing document of the provided key with the specified byte
   * array. Returns true if succeed; otherwise, throw
   * OPStatus.NOT_STORED or other Error status.
   */
  Future<bool> replace(String key, List<int> document, [int cas]);

  /**
   * Prepend byte array in front of the existing document of the provided key.
   * Returns true if succeed; otherwise, throw OPStatus.NOT_STORED or
   * other Error status.
   */
  Future<bool> prepend(String key, List<int> prepend, [int cas]);

  /**
   * append byte array at the rear of the existing document of the provided key.
   * Returns true if succeed; otherwise, throw OPStatus.NOT_STORED or
   * other Error status.
   */
  Future<bool> append(String key, List<int> document, [int cas]);

  /**
   * Delete the specified key; return true if succeed. Otherwise,
   * throws OPStatus.NOT_FOUND or other errors.
   */
  Future<bool> delete(String key);

  /**
   * Increment the docuemnt(must be an integer) by the provided [by] value.
   * Returns the result integer; otherwise, throw OPStatus.NOT_FOUND or other
   * error status.
   */
  Future<int> increment(String key, int by);

  /**
   * Decrement the document(must be an integer) by the provided [by] value.
   * Returns the result integer; otherwise, throw OPStatus.NOT_FOUND or other
   * error status.
   */
  Future<int> decrement(String key, int by);

  /**
   * Get document as a GetResult of the provided key. If you need cas token
   * to avoid racing when setting the document of the key, please use gets API.
   * This API returns GetResult if succeed; otherwise, throw OPStatus.NOT_FOUND
   * or other error status.
   */
  Future<GetResult> get(String key);

  /**
   * Get list of documents as a Stream of [GetResult]. If you need cas token
   * to avoid racing when setting the document of the key, please use getsAll
   * API. This API returns a Stream of GetResult per the provided key list;
   * return an empty Stream if none of the doucment of the provided key exists.
   */
  Stream<GetResult> getAll(List<String> keys);

  /**
   * Get document as a GetResult of the provided key with cas token. The cas
   * token can be used to avoid racing when setting the document of the key.
   * This API returns GetResult if succeed; otherwise, throw OPStatus.NOT_FOUND
   * or other error status.
   */
  Future<GetResult> gets(String key);

  /**
   * Get list of documents with cas tokens as a Stream of [GetResult]. The
   * cas token can be used to avoid racing when setting the document of the key.
   * This API returns a Stream of GetResult per the provided key list;
   * return an empty Stream if none of the doucment of the provided key exists.
   */
  Stream<GetResult> getsAll(List<String> keys);

  /** Touch document expiration time in seconds. 0 means permenent.
   * If exptime exceeds 30 days(30*24*60*60), it is deemed as an
   * absolute date in seconds. Returns true if succeed; othewise,
   * throw OPStatus.NOT_FOUND or other Error status.
   */
  Future<bool> touch(String key, int exptime);

  /**
   * Returns the versions of the connected servers. Returns version as a String.
   */
  Future<Map<SocketAddress, String>> versions();

  /**
   * Returns the set of supported SASL authentication mechanisms.
   */
  Future<Set<String>> listSaslMechs();

  /**
   * Close this memcached client.
   */
  void close();

  /**
   * Create and connect to a cluster of servers per the specified server
   * addresses and connection factory.
   */
  static Future<MemcachedClient> connect(
      List<SocketAddress> saddrs,
      [ConnectionFactory factory])
  => _MemcachedClientImpl.connect(saddrs, factory);
}

class _MemcachedClientImpl implements MemcachedClient {
  final ConnectionFactory _connFactory;
//  final Transcoder _transcoder;
  final OPFactory _opFactory;
  final MemcachedConnection _memcachedConn;
  final AuthDescriptor _authDescriptor;
  final int _opTimeout;

  Logger _logger;
  bool _closing = false;

  static Future<MemcachedClient> connect(
      List<SocketAddress> saddrs,
      [ConnectionFactory factory]) {
    if (saddrs == null || saddrs.isEmpty)
      throw new ArgumentError("Need at least one server to connect to: $saddrs");
    if (factory == null)
      factory = new BinaryConnectionFactory();
    return factory.createConnection(saddrs)
      .then((conn) => new _MemcachedClientImpl(conn, factory));
  }

  _MemcachedClientImpl(
      MemcachedConnection memcachedConn,
      ConnectionFactory connFactory)
      : _memcachedConn = memcachedConn,
        _connFactory = connFactory,
        _opFactory = connFactory.opFactory,
//        _transcoder = connFactory.transcorder,
        _opTimeout = connFactory.opTimeout,
        _authDescriptor = connFactory.authDescriptor {
    _logger = initLogger('memcached', this);
  }

  /**
   * Returns the addresses of available servers at this moment.
   */
  List<SocketAddress> get availableServers {
    List<SocketAddress> rv = new List();
    for (MemcachedNode node in locator.allNodes) {
      if (node.isActive)
        rv.add(node.socketAddress);
    }
    return rv;
  }

  /**
   * Returns the address of unavailable servers at this moment.
   */
  List<SocketAddress> get unavailableServers {
    List<SocketAddress> rv = new List();
    for (MemcachedNode node in locator.allNodes) {
      if (!node.isActive)
        rv.add(node.socketAddress);
    }
    return rv;
  }

  NodeLocator get locator
  => _memcachedConn.locator;

  /** set command */
  Future<bool> set(String key, List<int> doc, [int cas])
  => _store(OPType.set, key, 0, 0, doc, cas);

  /** add command */
  Future<bool> add(String key, List<int> doc)
  => _store(OPType.add, key, 0, 0, doc);

  /** replace command */
  Future<bool> replace(String key, List<int> doc, [int cas])
  => _store(OPType.replace, key, 0, 0, doc, cas);

  /** prepend command */
  Future<bool> prepend(String key, List<int> doc, [int cas])
  => _store(OPType.prepend, key, 0, 0, doc, cas);

  /** append command */
  Future<bool> append(String key, List<int> doc, [int cas])
  => _store(OPType.append, key, 0, 0, doc, cas);

  /** touch command */
  Future<bool> touch(String key, int exp, [bool noreply]) {
    TouchOP op = _opFactory.newTouchOP(key, exp);
    _handleOperation(key, op);
    return op.future;
  }

  /** delete command */
  Future<bool> delete(String key) {
    DeleteOP op = _opFactory.newDeleteOP(key);
    _handleOperation(key, op);
    return op.future;
  }

  /** increment command */
  Future<int> increment(String key, int value) {
    MutateOP op = _opFactory.newMutateOP(OPType.incr, key, value);
    _handleOperation(key, op);
    return op.future;
  }

  /** decrement command */
  Future<int> decrement(String key, int value) {
    MutateOP op = _opFactory.newMutateOP(OPType.decr, key, value);
    _handleOperation(key, op);
    return op.future;
  }

  /** versions command */
  Future<Map<SocketAddress, String>> versions()
  => _handleBroadcastOperation(() => _opFactory.newVersionOP());

  /** get command */
  Future<GetResult> get(String key) {
    GetSingleOP op = _opFactory.newGetSingleOP(OPType.get, key);
    _handleOperation(key, op);
    return op.future;
  }

  /** get command with multiple keys */
  Stream<GetResult> getAll(List<String> keys)
  => _retrieveAll(OPType.get, keys);

  /** gets(with cas data version token) command */
  Future<GetResult> gets(String key) {
    GetSingleOP op = _opFactory.newGetSingleOP(OPType.gets, key);
    _handleOperation(key, op);
    return op.future;
  }

  /** gets(with cas data version token) command with multiple keys */
  Stream<GetResult> getsAll(List<String> keys)
  => _retrieveAll(OPType.gets, keys);

  Future<Set<String>> listSaslMechs() {
    Completer<Set<String>> cmpl = new Completer();
    _handleBroadcastOperation(() => _opFactory.newSaslMechsOP())
    .then((map) {
      HashSet<String> set = new HashSet();
      for(List<String> mechs in map.values)
        set.addAll(mechs);
      cmpl.complete(set);
    });
    return cmpl.future;
  }

  Future<bool> _store(OPType type, String key, int flags, int exp, List<int> doc, [int cas, bool noreply]) {
    StoreOP op = _opFactory.newStoreOP(type, key, flags, exp, doc, cas:cas);
    _handleOperation(key, op);
    return op.future;
  }

  Stream<GetResult> _retrieveAll(OPType opCode, List<String> keys) {
    //break gets into groups of key
    final Map<MemcachedNode, List<String>> chunks = new HashMap();
    NodeLocator l = locator;
    bool binary = _opFactory is BinaryOPFactory;
    for (String key in keys) {
      validateKey(key, binary);
      MemcachedNode primary = l.getPrimary(key);
      MemcachedNode node = null;
      if (primary.isActive)
        node = primary;
      else {
        Iterator<MemcachedNode> i = l.getSequence(key);
        while( node == null && i.moveNext()) {
          MemcachedNode n = i.current;
          if (n.isActive)
            node = n;
        }
        if (node == null)
          node = primary;
      }
      List<String> ks = chunks[node];
      if (ks == null) {
        ks = new List();
        chunks[node] = ks;
      }
      ks.add(key);
    }

    //resync results in key sequence
    StreamController<GetResult> tgt = new StreamController();
    int keyi = 0; //key sequence index
    String currentKey = keys[0]; //the key should be add to Stream in sequence
    Map<String, GetResult> tmpMap = new HashMap(); //temporary map for out of sequence results
    for (MemcachedNode node in chunks.keys) {
      GetOP op = _opFactory.newGetOP(opCode, chunks[node]);
      _handleOperationAtNode(node, op);
      Stream<GetResult> src = op.stream;
      src.listen(
        (getr) {
          if (getr.key == currentKey) { //match the current key
            do {
              tgt.add(getr);
              //try next key; might have been stored in tmpMap
              ++keyi;
              if (keyi < keys.length) {
                currentKey = keys[keyi];
                getr = tmpMap.remove(currentKey);
              } else
                getr = null;
            } while(getr != null && getr.key == currentKey);
          } else //not match the current key; store it in tmpMap for later use
            tmpMap[getr.key] = getr;
        },
        onError: (err) => tgt.addError(err),
        onDone: () => tgt.close()
      );
    }
    return tgt.stream;
  }

  void _handleOperation(String key, OP op) {
    _memcachedConn.addOP(key, op);
  }

  void _handleOperationAtNode(MemcachedNode node, OP op) {
    _memcachedConn.addOPToNode(node, op);
  }

  Future<Map<SocketAddress, dynamic>> _handleBroadcastOperation(OP newOP())
  => _memcachedConn.broadcastOP(newOP, locator.allNodes);

  void close() {
    if (_closing)
      return;
    _closing = true;
    _memcachedConn.close();
  }
}

/** Key validation */
void validateKey(String key, bool binary) {
  List<int> keyBytes = encodeUtf8(key);
  if (keyBytes.length > MemcachedClient.MAX_KEY_LENGTH) {
    throw new ArgumentError("Key is too long (maxlen = "
        "${MemcachedClient.MAX_KEY_LENGTH})");
  }
  if (keyBytes.length == 0) {
    throw new ArgumentError(
        "Key must contain at least one character.");
  }
  if(!binary) {
    // Validate the key
    for (int j = 0; j < key.length; ++j) {
      String b = key[j];
      if (b == ' ' || b == '\n' || b == '\r' || b == 0) {
        throw new ArgumentError(
            "Key contains invalid characters:  ``$key''");
      }
    }
  }
}
