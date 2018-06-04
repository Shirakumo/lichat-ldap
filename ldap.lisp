#|
 This file is a part of lichat
 (c) 2018 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.lichat.ldap)

(defclass server (lichat-serverlib:server)
  ((ldap-host :initarg :ldap-host :accessor ldap-host)
   (ldap-port :initarg :ldap-port :accessor ldap-port)
   (ldap-ssl :initarg :ldap-ssl :accessor ldap-ssl)
   (bind-dn :initarg :bind-dn :accessor bind-dn)
   (bind-pw :initarg :bind-pw :accessor bind-pw)
   (profile-base :initarg :profile-base :accessor profile-base)
   (profile-query :initarg :profile-query :accessor profile-query)
   (profile-attr :initarg :profile-attr :accessor profile-attr))
  (:default-initargs
   :ldap-host "localhost"
   :ldap-port 389
   :ldap-ssl NIL
   :bind-dn NIL
   :bind-pw NIL
   :profile-base NIL
   :profile-query '(= :cn name)
   :profile-attr :cn))

(defclass profile (lichat-serverlib:profile)
  ((server :initarg :server :reader server)
   (bind-dn :initarg :bind-dn :reader bind-dn))
  (:default-initargs :timeout NIL))

(defmethod (setf lichat-serverlib:password) (value (profile profile))
  (error "Please change your password elsewhere."))

(define-condition bind-error (error)
  ((error-type :initarg :error-type :reader error-type)
   (error-message :initarg :error-message :reader error-message))
  (:report (lambda (c s) (format s "LDAP Bind failed: ~a" (error-type c)))))

(defmethod print-object ((bind-error bind-error) stream)
  (print-unreadable-object (bind-error stream :type T)
    (format stream "~a" (error-type bind-error))))

(defun replace-username (query name)
  (etypecase query
    (cons
     (cons (replace-username (car query) name)
           (replace-username (cdr query) name)))
    ((eql name) name)
    (T query)))

(defmacro with-ldap ((ldap object &key host port sslflag user pass) &body body)
  (let ((objectg (gensym "OBJECT")))
    `(let* ((,objectg ,object)
            (,ldap (ldap:new-ldap :host ,(or host `(ldap-host ,objectg))
                                  :port ,(or port `(ldap-port ,objectg))
                                  :sslflag ,(or sslflag `(ldap-ssl ,objectg))
                                  :user ,(or user `(bind-dn ,objectg))
                                  :pass ,(or pass `(bind-pw ,objectg))
                                  :timeout 10)))
       (multiple-value-bind (success error-type error-message) (ldap:bind ,ldap)
         (unless success
           (error 'bind-error :error-type error-type :error-message error-message)))
       (unwind-protect
            (progn ,@body)
         (ldap:unbind ,ldap)))))

(defmethod lichat-serverlib:make-profile ((server server) &key)
  (error "Please create a profile elsewhere."))

(defmethod lichat-serverlib:remove-profile (name (server server))
  (error "Please remove the profile elsewhere."))

(defmethod lichat-serverlib:list-profiles ((server server))
  (with-ldap (ldap server)
    (when (ldap:search ldap '(= objectClass inetorgperson)
                       :paging-size 500
                       :base (profile-base server)
                       :attributes (list (profile-attr server)))
      (loop for entry = (ldap:next-search-result ldap)
            while entry
            collect (make-instance 'profile :server server
                                            :bind-dn (ldap:dn entry)
                                            :name (first (ldap:attr-value entry (profile-attr server))))))))

(defmethod lichat-serverlib:find-profile ((name string) (server server))
  (with-ldap (ldap server)
    (when (ldap:search ldap (replace-username (profile-query server) name)
                       :size-limit 1
                       :base (profile-base server)
                       :attributes (list (profile-attr server)))
      (let ((entry (ldap:next-search-result ldap)))
        (make-instance 'profile :server server
                                :bind-dn (ldap:dn entry)
                                :name (first (ldap:attr-value entry (profile-attr server))))))))

(defmethod lichat-serverlib:password-valid-p ((profile profile) password)
  (ignore-errors
   (with-ldap (ldap (server profile)
               :user (bind-dn profile)
               :pass password)
     T)))
