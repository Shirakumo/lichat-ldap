(defpackage #:lichat-ldap
  (:nicknames #:org.shirakumo.lichat.ldap)
  (:use #:cl)
  (:export
   #:server
   #:name
   #:ldap-host
   #:ldap-port
   #:ldap-ssl
   #:bind-dn
   #:bind-pw
   #:profile-query
   #:profile-base
   #:profile-attr
   #:profile
   #:bind-error
   #:error-type
   #:error-message))
