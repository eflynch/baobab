var React = require('react');
var ReactDOM = require('react-dom');

var Baobab = require('../dist/baobab');

var Tree = Baobab.Tree;
var TreeState = Baobab.TreeState;

window.onload = function() {
    var maxAncestor, onChange, target, type;
    type = 'circle';
    maxAncestor = 6;
    onChange = function(string) {
        return document.getElementById('textOutput').value = string;
    };
    target = document.getElementById('treeview');
    ReactDOM.render(<Tree onChange={onChange} maxAncestor={maxAncestor} type={type}/>, target);
    document.getElementById('textInput').onkeydown = function(e) {
        var initialRoot;
        if (e.keyCode === 13) {
            e.preventDefault();
            initialRoot = TreeState.fromJSON(e.currentTarget.value);
            ReactDOM.render(<Tree onChange={onChange} setRoot={initialRoot} maxAncestor={maxAncestor} type={type}/>, target);
        }
    };
    
    window.onkeydown = function(e){
        target = document.getElementById('treeview');
        if (e.keyCode === 191 && e.metaKey) {
            type = (function() {
                switch (type) {
                    case 'circle':
                        return 'rectangle';
                    case 'rectangle':
                        return 'triangle';
                    case 'triangle':
                        return 'square';
                    case 'square':
                        return 'circle';
                }
            })();
            ReactDOM.render(<Tree type={type} focusType={type}
                maxAncestor={maxAncestor} onChange={onChange}/>, target);
        }
        if (e.keyCode === 189 && e.ctrlKey) {
            maxAncestor = Math.max(maxAncestor - 1, 3);
            ReactDOM.render(<Tree type={type} focusType={type}
                maxAncestor={maxAncestor} onChange={onChange}/>, target);
        }
        if (e.keyCode === 187 && e.ctrlKey) {
            maxAncestor = Math.min(maxAncestor + 1, 45);
            ReactDOM.render(<Tree type={type} focusType={type}
                maxAncestor={maxAncestor} onChange={onChange}/>, target);
        }
    };
};

