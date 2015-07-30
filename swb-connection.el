;;; swb-connection.el --- Basic interface for talking to databases.

;; Copyright (C) 2015 Matúš Goljer <matus.goljer@gmail.com>

;; Author: Matúš Goljer <matus.goljer@gmail.com>
;; Maintainer: Matúš Goljer <matus.goljer@gmail.com>
;; Version: 0.0.1
;; Created: 26th July 2015
;; Keywords: data

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Here we define the interface for talking to databases.  To support
;; a new database, it would be enough to implement all the required
;; methods.

;;; Code:

(require 'eieio)

(defclass swb-connection ()
  ((host :initarg :host
         :initform "localhost"
         :type string
         :protection :protected
         :accessor swb-get-host
         :documentation
     "IP or URL where the database is located.
Should not contain port number, use the `port' attribute for
that.")
   (port :initarg :port
         :type integer
         :initform 3306
         :protection :protected
         :accessor swb-get-port
         :documentation "Port.")
   (user :initarg :user
         :type string
         :protection :protected
         :accessor swb-get-user
         :documentation "User.")
   (password :initarg :password
             :type string
             :protection :protected
             :documentation "Password.")
   (database :initarg :database
             :type string
             :protection :protected
             :accessor swb-get-database
             :documentation "Database."))
  :abstract t
  :documentation
  "Connection interface for work with the database.")

;; TODO: send the query with -vvv to get back selected/changed rows
;; and time the query took.  This will require some light parsing on
;; our part.  This will also help in case of empty result set, when we
;; can echo "0 rows" in the minibuffer (where the "result statistics"
;; should go as well).
;; TODO: show status in the mode line or header line somehow.  The
;; sentinel can update it once the process is finished.
(defmethod swb-query ((this swb-connection) query buffer &rest args)
  "Run a QUERY asynchronously.

BUFFER is a buffer where the result is stored.

ARGS is a plist with additional arguments:

- :extra-args are extra arguments which should be passed to the
  underlying process.")

(defmethod swb-query-synchronously ((this swb-connection) query buffer &rest args)
  "Run a QUERY synchronously.

BUFFER is a buffer where the result is stored.

ARGS is a plist with additional arguments:

- :extra-args are extra arguments which should be passed to the
  underlying process.")

(defmethod swb-query-display-result ((this swb-connection) query buffer)
  "Run QUERY and display its result in a `swb-result-mode' BUFFER.")

(defmethod swb-query-fetch-column ((this swb-connection) query)
  "Run QUERY and return a list of values.

The query should return one column only.  The resulting list is
such that each successive element of the list represent nth row
of the result set (= column).

Data are retrieved synchronously.")

(defmethod swb-query-fetch-one ((this swb-connection) query)
  "Run QUERY and return a value.

The query should return one column and one row only.

Data are retrieved synchronously."
  (car (swb-query-fetch-column this query)))

(defmethod swb-query-fetch-tuples ((this swb-connection) query)
  "Run QUERY and return a list of tuples, one for each row.

Each tuple contains as many elements as there were columns
returned, in that order.

Data are retrieved synchronously.")

(defmethod swb-query-fetch-plist ((this swb-connection) query)
  "Run QUERY and return a list of plists, one for each row.

Each plist has as key the symbol :column and as value the
corresponding value.

Data are retrieved synchronously.")

(defmethod swb-query-fetch-alist ((this swb-connection) query)
  "Run QUERY and return a list of alists, one for each row.

Each alist has as key the symbol `column' and as value the
corresponding value.

Data are retrieved synchronously.")

;; Helper methods

(defmethod swb-get-databases ((this swb-connection))
  "Return a list of databases available at this connection.")

(defmethod swb-get-tables ((this swb-connection))
  "Return a list of tables available at this connection in current database.")

(provide 'swb-connection)
;;; swb-connection.el ends here
