#Rikulo Couchbase Client
* June 7, 2013
  * Releaes version 0.3.0+5
  * For CouchClient#observe() method, the return value was 
    Future<Map<MemcachedNode, ObserveResult>> and now changed to 
    Future<Map<SocketAddress, ObserverResult>>.

* June 5, 2013
  * Release version 0.3.0+4
  * Make compatible with SDK version 0.5.13.1_r23552
  * issue 4: CouchClient.close() doesn't stop
  
* May 29, 2013
  * Release version 0.3.0
  * Support keystats command
  * Support unlock command
  * Support getAndLock command
  * Support stats command
  * Support noop command
  * Support getAndTouch command

* May 20, 2013
  * Release version 0.2.0 
  * Support observe command
  * Support automatic reconfiguration
  * Fine tune hashCode and operator equality
  
* May 8, 2013
  * Release version 0.1.0
  
* April 22, 2013
  * Split into `couchclient` and `memcached-client` two projects.
  
* January 24, 2013
  * Initialize the Project

