
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

var makeSerial = function(size) {
    var num, possible, text;
    if (size == null) {
        size = 5;
    }
    possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    text = (function() {
        var _i, _results;
        _results = [];
        for (num = _i = 1; 1 <= size ? _i <= size : _i >= size; num = 1 <= size ? ++_i : --_i) {
            _results.push(possible.charAt(Math.floor(Math.random() * possible.length)));
        }
        return _results;
    })();
    return text.join();
};

var TreeState = (function() {
    TreeState.fromJSON = function(string, newIDs, onMutate) {
        var simpleObject, treeStateFromSimpleObject;
        if (newIDs == null) {
            newIDs = false;
        }
        if (onMutate == null) {
            onMutate = null;
        }
        simpleObject = JSON.parse(string);
        treeStateFromSimpleObject = function(simpleObject, parent) {
            var newTree, subObject, _i, _len, _ref;
            if (parent == null) {
                parent = null;
            }
            newTree = new TreeState({
                value: simpleObject.value,
                parent: parent,
                type: simpleObject.type,
                onMutate: onMutate
            });
            newTree.serial = simpleObject.serial;
            if (newIDs) {
                newTree.serial = makeSerial();
            }
            newTree.mutator('setCollapsed')(simpleObject.collapsed);
            _ref = simpleObject.childs;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                subObject = _ref[_i];
                newTree.childs.push(treeStateFromSimpleObject(subObject, newTree));
            }
            return newTree;
        };
        return treeStateFromSimpleObject(simpleObject);
    };

    function TreeState(_arg) {
        this.value = _arg.value, this.parent = _arg.parent, this.type = _arg.type, this.onMutate = _arg.onMutate;
        this.mutator = __bind(this.mutator, this);
        this.setOnMutate = __bind(this.setOnMutate, this);
        this.childs = [];
        this.serial = "" + (makeSerial());
        this.collapsed = false;
        this.width = null;
    }

    TreeState.prototype.setOnMutate = function(onMutate) {
        var child, _i, _len, _ref;
        this.onMutate = onMutate;
        _ref = this.childs;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            child = _ref[_i];
            child.setOnMutate(onMutate);
        }
    };

    TreeState.prototype.mutator = function(mutation) {
        var mutationFunction;
        mutationFunction = (function() {
            switch (mutation) {
                case 'setCollapsed':
                    return (function(_this) {
                        return function(newValue) {
                            var child, _i, _len, _ref;
                            _this.collapsed = newValue;
                            if (newValue === false) {
                                _ref = _this.childs;
                                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                                    child = _ref[_i];
                                    child.mutator('setCollapsed')(false);
                                }
                            }
                            _this.soil();
                        };
                    })(this);
                case 'setType':
                    return (function(_this) {
                        return function(newType) {
                            _this.type = newType;
                            _this.soil();
                        };
                    })(this);
                case 'setValue':
                    return (function(_this) {
                        return function(newValue) {
                            _this.value = newValue;
                            _this.soil();
                        };
                    })(this);
                case 'addSubTree':
                    return (function(_this) {
                        return function(value, sibling, relation, type) {
                            var insertIndex, newTree;
                            if (sibling == null) {
                                sibling = null;
                            }
                            if (relation == null) {
                                relation = null;
                            }
                            if (type == null) {
                                type = null;
                            }
                            if (sibling != null) {
                                if (relation === 'right') {
                                    insertIndex = _this.childs.indexOf(sibling);
                                }
                                if (relation === 'left') {
                                    insertIndex = _this.childs.indexOf(sibling) + 1;
                                }
                            } else {
                                insertIndex = _this.childs.length;
                            }
                            if (type == null) {
                                type = _this.type;
                            }
                            newTree = new TreeState({
                                value: value,
                                parent: _this,
                                type: type,
                                onMutate: _this.onMutate
                            });
                            _this.childs.splice(insertIndex, 0, newTree);
                            _this.soil();
                            return newTree;
                        };
                    })(this);
                case 'addSubTreeExisting':
                    return (function(_this) {
                        return function(tree) {
                            _this.childs.push(tree);
                            tree.parent = _this;
                            return _this.soil();
                        };
                    })(this);
                case 'removeChildren':
                    return (function(_this) {
                        return function() {
                            _this.childs = [];
                            return _this.soil();
                        };
                    })(this);
                case 'deleteSubTree':
                    return (function(_this) {
                        return function(child) {
                            var indexToDelete;
                            indexToDelete = _this.childs.indexOf(child);
                            if (indexToDelete != null) {
                                _this.childs.splice(indexToDelete, 1);
                            }
                            return _this.soil();
                        };
                    })(this);
                case 'collapseYouth':
                    return (function(_this) {
                        return function(nearNess) {
                            var child, _i, _len, _ref;
                            if (!_this.childs.length) {
                                return true;
                            }
                            if (nearNess < 0) {
                                _this.mutator('setCollapsed')(true);
                                return true;
                            }
                            _ref = _this.childs;
                            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                                child = _ref[_i];
                                child.mutator('collapseYouth')(nearNess - 1);
                            }
                            return true;
                        };
                    })(this);
                case 'removeSelfFromChain':
                    return (function(_this) {
                        return function() {
                            var child;
                            if (_this.childs.length !== 1) {
                                return false;
                            }
                            if (_this.parent == null) {
                                return false;
                            }
                            child = _this.childs[0];
                            _this.parent.mutator('deleteSubTree')(_this);
                            _this.parent.mutator('addSubTreeExisting')(child);
                            return true;
                        };
                    })(this);
                case 'orphan':
                    return (function(_this) {
                        return function() {
                            return _this.parent = null;
                        };
                    })(this);
            }
        }).call(this);
        return (function(_this) {
            return function() {
                var result;
                result = mutationFunction.apply(_this, arguments);
                if (typeof _this.onMutate === "function") {
                    _this.onMutate();
                }
                return result;
            };
        })(this);
    };

    TreeState.prototype.getCollapsed = function() {
        if (!this.childs.length) {
            this.collapsed = false;
            return false;
        }
        if (this.collapsed) {
            return true;
        }
    };

    TreeState.prototype.getWidth = function() {
        var child, total, _i, _len, _ref;
        if (this.width != null) {
            return this.width;
        }
        this.width = this.getLabelWidth() + 4;
        if (this.collapsed) {
            return this.width;
        }
        total = 0;
        _ref = this.childs;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            child = _ref[_i];
            total += child.getWidth();
        }
        if (total > this.width) {
            this.width = total;
        }
        return this.width;
    };

    TreeState.prototype.getNearerAncestor = function(ancestor, nearNess) {
        if (this.parent == null) {
            return this;
        }
        if (ancestor === this) {
            return ancestor;
        }
        if (nearNess === 0) {
            return this;
        }
        return this.parent.getNearerAncestor(ancestor, nearNess - 1);
    };

    TreeState.prototype.soil = function() {
        this.width = null;
        if (this.parent != null) {
            return this.parent.soil();
        }
    };

    TreeState.prototype.getTextWidth = function() {
        var line, lineLengths, maxLineLength;
        lineLengths = [
            (function() {
                var _i, _len, _ref, _results;
                _ref = this.value.split('\n');
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                    line = _ref[_i];
                    _results.push(line.length);
                }
                return _results;
            }).call(this)
        ][0];
        maxLineLength = Math.max.apply(null, lineLengths);
        return Math.max(maxLineLength * 7, 1);
    };

    TreeState.prototype.getTextHeight = function() {
        var numLines;
        numLines = this.value.split('\n').length;
        return numLines * 14;
    };

    TreeState.prototype.getLabelWidth = function() {
        switch (this.type) {
            case 'rectangle':
                return this.getTextWidth() + 10;
            case 'circle':
                return Math.max(this.getTextWidth(), this.getTextHeight()) * Math.sqrt(2);
            case 'square':
                return Math.max(this.getTextWidth() + 10, this.getTextHeight() + 10);
            case 'triangle':
                return Math.max(this.getTextWidth(), this.getTextHeight()) * (1 + 2 * Math.sqrt(3) / 3);
        }
    };

    TreeState.prototype.getLabelHeight = function() {
        switch (this.type) {
            case 'rectangle':
                return this.getTextHeight() + 10;
            case 'circle':
                return Math.max(this.getTextWidth(), this.getTextHeight()) * Math.sqrt(2);
            case 'square':
                return Math.max(this.getTextWidth() + 10, this.getTextHeight() + 10);
            case 'triangle':
                return Math.max(this.getTextWidth(), this.getTextHeight()) * (1 + Math.sqrt(2) / 2);
        }
    };

    TreeState.prototype.copy = function() {
        var newIDs, onMutate;
        return TreeState.fromJSON(this.toJSON(), newIDs = true, onMutate = this.onMutate);
    };

    TreeState.prototype.toJSON = function() {
        var toSimpleObject;
        toSimpleObject = function(tree) {
            var child;
            return {
                value: tree.value,
                childs: (function() {
                    var _i, _len, _ref, _results;
                    _ref = tree.childs;
                    _results = [];
                    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                        child = _ref[_i];
                        _results.push(toSimpleObject(child));
                    }
                    return _results;
                })(),
                collapsed: tree.collapsed,
                serial: tree.serial,
                type: tree.type
            };
        };
        return JSON.stringify(toSimpleObject(this));
    };

    return TreeState;
})();

module.exports = TreeState;
