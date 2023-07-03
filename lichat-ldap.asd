(asdf:defsystem lichat-ldap
  :version "1.0.0"
  :license "zlib"
  :author "Yukari Hafner <shinmera@tymoon.eu>"
  :maintainer "Yukari Hafner <shinmera@tymoon.eu>"
  :description "LDAP backend for the Lichat server profiles."
  :homepage "https://github.com/Shirakumo/lichat-ldap"
  :serial T
  :components ((:file "package")
               (:file "ldap")
               (:file "documentation"))
  :depends-on (:lichat-serverlib
               :trivial-ldap
               :documentation-utils))
