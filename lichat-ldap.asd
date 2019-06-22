#|
 This file is a part of lichat
 (c) 2018 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(asdf:defsystem lichat-ldap
  :version "1.0.0"
  :license "zlib"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :maintainer "Nicolas Hafner <shinmera@tymoon.eu>"
  :description "LDAP backend for the Lichat server profiles."
  :homepage "https://github.com/Shirakumo/lichat-ldap"
  :serial T
  :components ((:file "package")
               (:file "ldap")
               (:file "documentation"))
  :depends-on (:lichat-serverlib
               :trivial-ldap
               :documentation-utils))
