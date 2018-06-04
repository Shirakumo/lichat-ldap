## About Lichat-LDAP
This provides a server mixin class that will perform profile lookup and authentication using an LDAP server.

## How To
In your server definition, add `lichat-ldap:server` as the first superclass. Then, on construction, pass it the following arguments with appropriate values for your setup.

    :ldap-host      --- The LDAP server's hostname. Defaults to "localhost".
    :ldap-port      --- The LDAP server's port. Defaults to 389.
    :ldap-ssl       --- Whether to use SSL. Defaults to NIL
    :bind-dn        --- The DN to bind with for search requests. Defaults to NIL.
    :bind-pw        --- The password to bind with. Defaults to NIL.
    :profile-base   --- The base DN to search for profiles under. Defaults to NIL.
    :profile-query  --- The query as an sexpr to search for profiles. See below.
    :profile-attr   --- The attribute that returns the profile's username. Defaults to :CN.

When authenticating users, it will perform a bind attempt, letting the LDAP server's authentication perform the password validation. This means that this server will not store or access any password information at all. Password changes and profile registrations are thus not available in this scheme.

## Search Query
In order to search for profiles in the LDAP directory, a search query expression is used. This should be an s-expression of the following format:

    QUERY     ::= COMPOUND
    COMPOUND  ::= AND | OR | EQ
    AND       ::= (cl:and COMPOUND*)
    OR        ::= (cl:or COMPOUND*)
    EQ        ::= (cl:= ATTRIBUTE VALUE)
    VALUE     ::= STRING | lichat-ldap:name
    STRING    --- A string
    ATTRIBUTE --- A keyword

The default query is `(cl:= :cn lichat-ldap:name)` meaning it checks the `cn` attribute against the given name.
