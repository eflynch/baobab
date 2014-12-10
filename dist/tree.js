// Generated by CoffeeScript 1.8.0
(function() {
  var React, Tree, TreeNode, TreeState, ra;

  React = require('react');

  ra = React.DOM;

  TreeState = require('./treestate');

  TreeNode = require('./treenode');

  Tree = React.createClass({
    displayName: 'BaobabTree',
    getInitialState: function() {
      var initialRoot;
      initialRoot = new TreeState({
        value: '',
        type: 'circle'
      });
      return {
        root: initialRoot,
        focus: initialRoot,
        head: initialRoot,
        clipboard: null
      };
    },
    getDefaultProps: function() {
      return {
        maxAncestor: 6,
        type: 'circle'
      };
    },
    componentWillMount: function() {
      if (this.props.setRoot != null) {
        return this.setState({
          root: this.props.setRoot,
          focus: this.props.setRoot,
          head: this.props.setRoot
        });
      }
    },
    componentWillReceiveProps: function(nextProps) {
      if ((nextProps.setRoot != null) && nextProps.setRoot !== this.state.root) {
        this.setState({
          root: nextProps.setRoot,
          focus: nextProps.setRoot,
          head: nextProps.setRoot
        });
      }
      if ((nextProps.focusType != null) && nextProps.focusType !== this.state.focus.type) {
        return this.callbacks().setTypeCallback(nextProps.focusType);
      }
    },
    componentDidUpdate: function() {
      if (this.props.onChange != null) {
        return this.props.onChange(this.state.root.toJSON());
      }
    },
    setHeadAndCollapseYouth: function(focus, head) {
      if (focus == null) {
        focus = null;
      }
      if (head == null) {
        head = null;
      }
      if (focus == null) {
        focus = this.state.focus;
      }
      if (head == null) {
        head = this.state.head;
      }
      head.mutator().collapseYouth(this.props.maxAncestor);
      return this.setState({
        head: focus.getNearerAncestor(head, this.props.maxAncestor)
      });
    },
    _deleteHelper: function() {
      var focus, head, newFocus, oldIndex, parent;
      focus = this.state.focus;
      parent = this.state.focus.parent;
      head = this.state.head;
      if (focus === head) {
        this.setState({
          head: parent
        });
        head = parent;
      }
      oldIndex = parent.subtrees.indexOf(focus);
      if (oldIndex > 0) {
        newFocus = parent.subtrees[oldIndex - 1];
      } else {
        newFocus = parent;
      }
      parent.mutator().deleteSubTree(focus);
      this.setState({
        focus: newFocus
      });
      return this.setHeadAndCollapseYouth(newFocus, head);
    },
    callbacks: function() {
      return {
        changeCallback: (function(_this) {
          return function(newValue) {
            if (_this.state.focus != null) {
              _this.state.focus.mutator().setValue(newValue);
              _this.setState({
                focus: _this.state.focus
              });
            }
          };
        })(this),
        setTypeCallback: (function(_this) {
          return function(newType) {
            if (_this.state.focus != null) {
              _this.state.focus.mutator().setType(newType);
              _this.setState({
                focus: _this.state.focus
              });
            }
          };
        })(this),
        toggleElectivelyCollapsedCallback: (function(_this) {
          return function() {
            if (_this.state.focus.getCollapsed()) {
              _this.state.focus.mutator().setCollapsed(false);
            } else {
              _this.state.focus.mutator().setCollapsed(true);
            }
            _this.setState({
              focus: _this.state.focus
            });
            _this.setHeadAndCollapseYouth();
          };
        })(this),
        addChildCallback: (function(_this) {
          return function() {
            var newTree;
            newTree = _this.state.focus.mutator().addSubTree('', null, null, _this.props.type);
            _this.setState({
              focus: newTree
            });
            _this.setHeadAndCollapseYouth();
          };
        })(this),
        addParentCallback: (function(_this) {
          return function() {
            var newTree;
            if (_this.state.focus.parent == null) {
              newTree = new TreeState({
                value: '',
                type: _this.props.type
              });
              newTree.subtrees.push(_this.state.root);
              _this.state.root.parent = newTree;
              _this.setHeadAndCollapseYouth(newTree, newTree);
              return _this.setState({
                root: newTree,
                focus: newTree,
                head: newTree
              });
            }
          };
        })(this),
        copyCallback: (function(_this) {
          return function() {
            var newTree;
            newTree = _this.state.focus.copy();
            _this.setState({
              clipboard: newTree
            });
          };
        })(this),
        pasteCallback: (function(_this) {
          return function() {
            if (_this.state.clipboard != null) {
              _this.state.focus.mutator().addSubTreeExisting(_this.state.clipboard.copy());
              _this.setState({
                focus: _this.state.focus
              });
              _this.setHeadAndCollapseYouth();
            }
          };
        })(this),
        addLeftSiblingCallback: (function(_this) {
          return function() {
            var newTree;
            if (_this.state.focus !== _this.state.head) {
              newTree = _this.state.focus.parent.mutator().addSubTree('', _this.state.focus, 'right', _this.props.type);
              _this.setState({
                focus: newTree
              });
            }
          };
        })(this),
        addRightSiblingCallback: (function(_this) {
          return function() {
            var newTree;
            if (_this.state.focus !== _this.state.head) {
              newTree = _this.state.focus.parent.mutator().addSubTree('', _this.state.focus, 'left', _this.props.type);
              _this.setState({
                focus: newTree
              });
            }
          };
        })(this),
        focusCallback: (function(_this) {
          return function(newFocus) {
            _this.setState({
              focus: newFocus
            });
            _this.setHeadAndCollapseYouth(newFocus);
          };
        })(this),
        setHeadCallback: (function(_this) {
          return function() {
            if (_this.state.focus.getCollapsed()) {
              _this.state.focus.mutator().setCollapsed(false);
            }
            _this.setState({
              head: _this.state.focus
            });
          };
        })(this),
        ascendCallback: (function(_this) {
          return function() {
            var focus, head;
            if (_this.state.focus.parent != null) {
              if (_this.state.focus === _this.state.head) {
                head = _this.state.head.parent;
              } else {
                head = _this.state.head;
              }
              focus = _this.state.focus.parent;
              _this.setState({
                focus: focus,
                head: head
              });
              _this.setHeadAndCollapseYouth(focus, head);
            }
          };
        })(this),
        descendCallback: (function(_this) {
          return function() {
            if (_this.state.focus.subtrees.length) {
              if (_this.state.focus.getCollapsed()) {
                _this.state.focus.mutator().setCollapsed(false);
              }
              _this.setState({
                focus: _this.state.focus.subtrees[0]
              });
              _this.setHeadAndCollapseYouth();
            }
          };
        })(this),
        rightSiblingCallback: (function(_this) {
          return function() {
            var oldIndex;
            if (_this.state.focus !== _this.state.head) {
              oldIndex = _this.state.focus.parent.subtrees.indexOf(_this.state.focus);
              if (_this.state.focus.parent.subtrees.length > (oldIndex + 1)) {
                _this.setState({
                  focus: _this.state.focus.parent.subtrees[oldIndex + 1]
                });
              }
            }
          };
        })(this),
        leftSiblingCallback: (function(_this) {
          return function() {
            var oldIndex;
            if (_this.state.focus !== _this.state.head) {
              oldIndex = _this.state.focus.parent.subtrees.indexOf(_this.state.focus);
              if (oldIndex > 0) {
                _this.setState({
                  focus: _this.state.focus.parent.subtrees[oldIndex - 1]
                });
              }
            }
          };
        })(this),
        deleteCallback: (function(_this) {
          return function() {
            var child, focus, head, newFocus, newHead, newRoot, parent;
            if (_this.state.focus.subtrees.length > 1) {
              return;
            }
            if (_this.state.focus.value !== '') {
              return;
            }
            if (_this.state.focus.subtrees.length === 1) {
              focus = _this.state.focus;
              parent = _this.state.focus.parent;
              child = _this.state.focus.subtrees[0];
              head = _this.state.head;
              newFocus = child;
              if (focus === _this.state.root) {
                newRoot = child;
                newHead = child;
                child.mutator().orphan();
              } else {
                focus.mutator().removeSelfFromChain();
                newRoot = _this.state.root;
                if (head === focus) {
                  newHead = child;
                } else {
                  newHead = head;
                }
              }
              _this.setState({
                head: newHead,
                focus: newFocus,
                root: newRoot
              });
              _this.setHeadAndCollapseYouth(newFocus, newHead);
              return;
            }
            if (_this.state.focus !== _this.state.root) {
              return _this._deleteHelper();
            }
          };
        })(this),
        forceDeleteCallback: (function(_this) {
          return function() {
            if (_this.state.focus !== _this.state.root) {
              return _this._deleteHelper();
            }
            _this.state.focus.mutator().removeChildren();
            return _this.setState({
              head: _this.state.root,
              focus: _this.state.root,
              root: _this.state.root
            });
          };
        })(this)
      };
    },
    render: function() {
      return ra.div({
        id: 'BAOBAB',
        style: {
          position: 'relative'
        }
      }, TreeNode({
        keyHandler: (function(_this) {
          return function(e) {
            var ctrl, meta, shift;
            shift = e.shiftKey;
            ctrl = e.ctrlKey;
            meta = e.metaKey;
            switch (false) {
              case !(e.key === 'Enter' && ctrl):
                e.preventDefault();
                return _this.callbacks().setHeadCallback();
              case !(e.key === ' ' && shift):
                e.preventDefault();
                return _this.callbacks().toggleElectivelyCollapsedCallback();
              case e.key !== 'Backspace':
                if (shift) {
                  e.preventDefault();
                  return _this.callbacks().forceDeleteCallback();
                } else {
                  return _this.callbacks().deleteCallback();
                }
                break;
              case !(e.key === 'Enter' && (!shift)):
                e.preventDefault();
                return _this.callbacks().addChildCallback();
              case e.key !== 'Tab':
                e.preventDefault();
                return _this.callbacks().addRightSiblingCallback();
              case e.key !== 'Escape':
                e.preventDefault();
                if (!_this.callbacks().ascendCallback()) {
                  return _this.callbacks().addParentCallback();
                }
                break;
              case !(shift && e.key === 'ArrowLeft'):
                e.preventDefault();
                if (meta) {
                  return _this.callbacks().addLeftSiblingCallback();
                } else {
                  return _this.callbacks().leftSiblingCallback();
                }
                break;
              case !(shift && e.key === 'ArrowRight'):
                e.preventDefault();
                if (meta) {
                  return _this.callbacks().addRightSiblingCallback();
                } else {
                  return _this.callbacks().rightSiblingCallback();
                }
                break;
              case !(shift && e.key === 'ArrowDown'):
                e.preventDefault();
                if (meta) {
                  return _this.callbacks().addChildCallback();
                } else {
                  return _this.callbacks().descendCallback();
                }
                break;
              case !(shift && e.key === 'ArrowUp'):
                if (meta) {
                  return _this.callbacks().addParentCallback();
                } else {
                  e.preventDefault();
                  return _this.callbacks().ascendCallback();
                }
                break;
              case !(ctrl && e.keyCode === 67):
                return _this.callbacks().copyCallback();
              case !(ctrl && e.keyCode === 86):
                return _this.callbacks().pasteCallback();
            }
          };
        })(this),
        focusCallback: this.callbacks().focusCallback,
        changeCallback: this.callbacks().changeCallback,
        onBlur: (function(_this) {
          return function(e) {
            if (e.relatedTarget === null) {
              _this.setState({
                focus: null
              });
            }
          };
        })(this),
        showEtc: this.state.head !== this.state.root,
        focus: this.state.focus,
        root: this.state.head,
        maxDepth: this.props.maxAncestor,
        lineSpacing: 20
      }));
    }
  });

  module.exports = React.createFactory(Tree);

}).call(this);