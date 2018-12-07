(in-package :mahogany/tree)

;; various hooks
(defvar *split-frame-hook* nil
  "Hook that is called when a frame is split. It calls a function
with two arguments: the first is the newly created frame, and the second
is the parent of the new frame.")

(defvar *new-frame-hook* nil
  "Hook that is called whenever a new leaf frame is created. The function
called should expect one argument, the newly created frame.")

(defvar *remove-split-hook* nil
  "Hook for when a frame is removed. Called with the deleted frame
as the first argument.")

(defvar *new-split-type* :binary
  "Directs a newly split frame to have two or many children.
Valid choices are :binary or :poly. You can change the split type
of an already existing frame with the `set-split-frame-type` function")

(defclass frame ()
  ((x :initarg :x
      :accessor frame-x
      :type integer)
   (y :initarg :y
      :accessor frame-y
      :type integer)
   (width :initarg :width
	  :accessor frame-width
	  :type integer)
   (height :initarg :height
	   :accessor frame-height
	   :type integer)
   (parent :initarg :parent
	   :accessor frame-parent))
  (:documentation "A frame that is displayed on an output"))

(defclass tree-container ()
  ((tree :initarg :root
	:accessor root-tree
	:type frame
	:documentation "Holds the root of a frame-tree"))
  (:documentation "A class that contains a frame-tree"))

(defclass tree-frame (frame)
  ((children :initarg :children
	     :initform nil
	    :accessor tree-children
	    :type list)
   (split-direction :initarg :split-direction
		    :reader tree-split-direction
		    :type keyword))
  (:documentation "An inner node of a frame-tree"))

(defclass floating-frame (frame)
  ((top-frame :initarg :top-frame
	      :accessor top-frame
	      :type frame)))

(defclass binary-tree-frame (tree-frame)
  ()
  (:documentation "An inner node of a frame-tree that can only have two children"))

(defclass poly-tree-frame (tree-frame)
  ()
  (:documentation "An inner node of a frame-tree that can have more than two children"))

;; frame-tree interface
(defgeneric set-split-frame-type (frame type)
  (:documentation "Sets the split frame type. Note that this may change the
the layout of the tree depending on the frame type.
See *new-split-type* for more details"))

(defgeneric split-frame-v (frame &key ratio direction)
  (:documentation "Split the frame vertically. Returns a tree of the split frames.
The parent tree is modified appropriately.
   RATIO: the size of newly created frame compared to the given frame. If not given, then
     the the size is split evenly between the other child frame(s)
   DIRECTION: where the new frame is placed. Either :left or :right"))

(defgeneric split-frame-h (frame &key ratio direction)
  (:documentation "Split the frame horizontally. Returns a tree of the split frames.
The parent tree is modified appropriately.
   RATIO: the size of newly created frame compared to the given frame. If not given, then
     the the size is split evenly between the other child frame(s)
   DIRECTION: where the new frame is placed. Either :top or :bottom"))

(defgeneric remove-frame-from-parent (parent frame cleanup-func)
  (:documentation "Remove the frame from the tree. Parent must be the parent of frame."))

(defun remove-frame (frame &optional (cleanup-func #'identity))
  "Remove the frame from the poly tree. The remaining children grow to equally take up the available space.
e.g. If there are three frames of width (20, 40, 40), and the 20 width one is removed, the new widths
will be (40, 40). If a tree only has one child left, it is replaced with its child.
CLEANUP-FUNC is called on the removed frame(s) after they are removed."
  (check-type frame frame)
  (remove-frame-from-parent (frame-parent frame) frame cleanup-func))


(defgeneric swap-positions (frame1 frame2)
  (:documentation "Swap the positions of the two frames in their trees."))

(defgeneric find-empty-frame (root)
  (:documentation "Finds the first veiw-frame in the given tree that doesn't have
a view assigned to it."))

(defgeneric get-empty-frames (root)
  (:documentation "Gets a list of empty frames in the tree."))

(defgeneric set-dimensions (frame width height)
  (:documentation "Set the dimensions of the frame. If setting both the width and
height of a frame, use this method instead of frame-x and frame-y"))

;; helper functions:

(defun root-frame-p (frame)
  ;; the root frame's parent will be a tree-container:
  (typep (frame-parent frame) 'tree-container))
