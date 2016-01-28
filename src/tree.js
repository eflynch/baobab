var React = require('react');

var TreeState = require('./treestate');
var TreeNode = require('./treenode');

var Tree = React.createClass({
    displayName: 'BaobabTree',
    onMutate: function() {
        if (this.props.onChange != null) {
            this.props.onChange(this.state.root.toJSON());
        }
        return this.forceUpdate();
    },
    getInitialState: function() {
        var initialRoot;
        initialRoot = new TreeState({
            value: '',
            type: 'circle',
            onMutate: this.onMutate
        });
        return {
            root: initialRoot,
            focus: initialRoot,
            head: initialRoot,
            clipboard: null,
            changed: true,
            allFocus: true
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
            this.props.setRoot.setOnMutate(this.onMutate);
            return this.setState({
                root: this.props.setRoot,
                focus: this.props.setRoot,
                head: this.props.setRoot
            });
        }
    },
    componentWillReceiveProps: function(nextProps) {
        if ((nextProps.setRoot != null) && nextProps.setRoot !== this.state.root) {
            nextProps.setRoot.setOnMutate(this.onMutate);
            this.setState({
                root: nextProps.setRoot,
                focus: nextProps.setRoot,
                head: nextProps.setRoot
            });
        }
        if ((nextProps.focusType != null) && (this.state.focus != null) && nextProps.focusType !== this.state.focus.type) {
            return this.callbacks().setTypeCallback(nextProps.focusType);
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
        head.mutator('collapseYouth')(this.props.maxAncestor);
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
        oldIndex = parent.childs.indexOf(focus);
        if (oldIndex > 0) {
            newFocus = parent.childs[oldIndex - 1];
        } else {
            newFocus = parent;
        }
        parent.mutator('deleteSubTree')(focus);
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
                        _this.state.focus.mutator('setValue')(newValue);
                    }
                };
            })(this),
            setTypeCallback: (function(_this) {
                return function(newType) {
                    if (_this.state.focus != null) {
                        _this.state.focus.mutator('setType')(newType);
                    }
                };
            })(this),
            toggleElectivelyCollapsedCallback: (function(_this) {
                return function() {
                    if (_this.state.focus.getCollapsed()) {
                        _this.state.focus.mutator('setCollapsed')(false);
                    } else {
                        _this.state.focus.mutator('setCollapsed')(true);
                    }
                    _this.setHeadAndCollapseYouth();
                };
            })(this),
            addChildCallback: (function(_this) {
                return function() {
                    var newTree;
                    newTree = _this.state.focus.mutator('addSubTree')('', null, null, _this.props.type);
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
                            type: _this.props.type,
                            onMutate: _this.onMutate
                        });
                        newTree.childs.push(_this.state.root);
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
                        _this.state.focus.mutator('addSubTreeExisting')(_this.state.clipboard.copy());
                        _this.setHeadAndCollapseYouth();
                    }
                };
            })(this),
            addLeftSiblingCallback: (function(_this) {
                return function() {
                    var newTree;
                    if (_this.state.focus !== _this.state.head) {
                        newTree = _this.state.focus.parent.mutator('addSubTree')('', _this.state.focus, 'right', _this.props.type);
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
                        newTree = _this.state.focus.parent.mutator('addSubTree')('', _this.state.focus, 'left', _this.props.type);
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
                        _this.state.focus.mutator('setCollapsed')(false);
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
                    if (_this.state.focus.childs.length) {
                        if (_this.state.focus.getCollapsed()) {
                            _this.state.focus.mutator('setCollapsed')(false);
                        }
                        _this.setState({
                            focus: _this.state.focus.childs[0]
                        });
                        _this.setHeadAndCollapseYouth();
                    }
                };
            })(this),
            rightSiblingCallback: (function(_this) {
                return function() {
                    var oldIndex;
                    if (_this.state.focus !== _this.state.head) {
                        oldIndex = _this.state.focus.parent.childs.indexOf(_this.state.focus);
                        if (_this.state.focus.parent.childs.length > (oldIndex + 1)) {
                            _this.setState({
                                focus: _this.state.focus.parent.childs[oldIndex + 1]
                            });
                        }
                    }
                };
            })(this),
            leftSiblingCallback: (function(_this) {
                return function() {
                    var oldIndex;
                    if (_this.state.focus !== _this.state.head) {
                        oldIndex = _this.state.focus.parent.childs.indexOf(_this.state.focus);
                        if (oldIndex > 0) {
                            _this.setState({
                                focus: _this.state.focus.parent.childs[oldIndex - 1]
                            });
                        }
                    }
                };
            })(this),
            deleteCallback: (function(_this) {
                return function() {
                    var child, focus, head, newFocus, newHead, newRoot, parent;
                    if (_this.state.focus.childs.length > 1) {
                        return;
                    }
                    if (_this.state.focus.value !== '') {
                        return;
                    }
                    if (_this.state.focus.childs.length === 1) {
                        focus = _this.state.focus;
                        parent = _this.state.focus.parent;
                        child = _this.state.focus.childs[0];
                        head = _this.state.head;
                        newFocus = child;
                        if (focus === _this.state.root) {
                            newRoot = child;
                            newHead = child;
                            child.mutator('orphan')();
                        } else {
                            focus.mutator('removeSelfFromChain')();
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
                    _this.state.focus.mutator('removeChildren')();
                    return _this.setState({
                        head: _this.state.root,
                        focus: _this.state.root,
                        root: _this.state.root
                    });
                };
            })(this)
        };
    },
    keyHandler: function(e){
        var ctrl, meta, shift;
        shift = e.shiftKey;
        ctrl = e.ctrlKey;
        meta = e.metaKey;
        switch (false) {
            case !(e.key === 'Enter' && ctrl):
                e.preventDefault();
                return this.callbacks().setHeadCallback();
            case !(e.key === ' ' && shift):
                e.preventDefault();
                return this.callbacks().toggleElectivelyCollapsedCallback();
            case e.key !== 'Backspace':
                if (shift) {
                    e.preventDefault();
                    return this.callbacks().forceDeleteCallback();
                } else {
                    return this.callbacks().deleteCallback();
                }
                break;
            case !(e.key === 'Enter' && (!shift)):
                e.preventDefault();
                return this.callbacks().addChildCallback();
            case e.key !== 'Tab':
                e.preventDefault();
                return this.callbacks().addRightSiblingCallback();
            case e.key !== 'Escape':
                e.preventDefault();
                if (!this.callbacks().ascendCallback()) {
                    return this.callbacks().addParentCallback();
                }
                break;
            case !(shift && e.key === 'ArrowLeft'):
                e.preventDefault();
                if (meta) {
                    return this.callbacks().addLeftSiblingCallback();
                } else {
                    return this.callbacks().leftSiblingCallback();
                }
                break;
            case !(shift && e.key === 'ArrowRight'):
                e.preventDefault();
                if (meta) {
                    return this.callbacks().addRightSiblingCallback();
                } else {
                    return this.callbacks().rightSiblingCallback();
                }
                break;
            case !(shift && e.key === 'ArrowDown'):
                e.preventDefault();
                if (meta) {
                    return this.callbacks().addChildCallback();
                } else {
                    return this.callbacks().descendCallback();
                }
                break;
            case !(shift && e.key === 'ArrowUp'):
                if (meta) {
                    return this.callbacks().addParentCallback();
                } else {
                    e.preventDefault();
                    return this.callbacks().ascendCallback();
                }
                break;
            case !(ctrl && e.keyCode === 67):
                return this.callbacks().copyCallback();
            case !(ctrl && e.keyCode === 86):
                return this.callbacks().pasteCallback();
        }
    },
    onBlur: function (e){
        if (this.state.allFocus && e.relatedTarget === null){
            this.setState({focus: null});
        }
    },
    render: function() {
        return (
            <div id='BAOBAB' style={{position:'relative'}} onFocus={function (){this.setState({allFocus: true});}.bind(this)} onBlur={function (){this.setState({allFocus:false});}.bind(this)}>
                <TreeNode keyHandler={this.keyHandler} 
                          focusCallback={this.callbacks().focusCallback}
                          changeCallback={this.callbacks().changeCallback}
                          onBlur={this.onBlur}
                          showEtc={this.state.head !== this.state.root}
                          focus={this.state.focus}
                          allFocus={this.state.allFocus}
                          root={this.state.head}
                          maxDepth={this.props.maxAncestor}
                          lineSpacing={20}/>
            </div>
        );
    }
});

module.exports = Tree;
