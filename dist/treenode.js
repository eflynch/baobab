var React = require('react');

var TreeLabel = require('./treelabel');
var Line = require('./line');

var TreeNode = React.createClass({displayName: "TreeNode",
    getDefaultProps: function() {
        return {
            left: 0,
            top: 0,
            showEtc: false,
            collapsed: false
        };
    },
    getLineValues: function() {
        return {
            startX: this.getCenter().x,
            startY: this.getCenter().y,
            endX: this.props.root.parent != null ? this.props.root.parent.getWidth() / 2 - this.props.left : void 0,
            endY: this.props.root.parent != null ? this.props.root.parent.getLabelHeight() / 2 - this.props.top : void 0
        };
    },
    getCenter: function() {
        return {
            x: this.props.root.getWidth() / 2,
            y: this.props.root.getLabelHeight() / 2
        };
    },
    render: function() {
        var hasFocus, leftAccumulator, subtree;
        if (this.props.focus != null) {
            hasFocus = this.props.focus.id === this.props.root.id;
        } else {
            hasFocus = false;
        }
        return (
            React.createElement("li", {onBlur: this.props.onBlur, style: {position:'absolute', top:this.props.top, left:this.props.left, width: this.props.root.getWidth()}}, 
                function(){
                    if (this.props.root.parent !== null && this.props.root.parent !== undefined){
                        if (this.props.showEtc){
                            return React.createElement(Line, {width: "2px", color: "#aaa", startX: this.getLineValues().startX, 
                                       startY: this.getLineValues().startY, 
                                       endX: this.getLineValues().startX, 
                                       endY: -this.props.lineSpacing})
                        } else {
                            return React.createElement(Line, {width: "2px", color: "#000000", startX: this.getLineValues().startX, 
                                         startY: this.getLineValues().startY, 
                                         endX: this.getLineValues().endX, 
                                         endY: this.getLineValues().endY})
                        }
                          
                    }
                }.bind(this)(), 
                React.createElement(TreeLabel, {type: this.props.root.type, 
                           left: this.getCenter().x - this.props.root.getLabelWidth() / 2, 
                           width: this.props.root.getLabelWidth(), 
                           height: this.props.root.getLabelHeight(), 
                           textWidth: this.props.root.getTextWidth(), 
                           textHeight: this.props.root.getTextHeight(), 
                           hasFocus: hasFocus, 
                           allFocus: this.props.allFocus, 
                           collapsed: this.props.root.getCollapsed(), 
                           onFocus: function (){this.props.focusCallback(this.props.root);}.bind(this), 
                           keyHandler: this.props.keyHandler, 
                           changeCallback: this.props.changeCallback}, 
                    this.props.value
                ), 
                React.createElement("ul", null, 
                    function (){
                        if (!this.props.root.getCollapsed()) {
                            var leftAccumulator = 0;
                            return this.props.root.subtrees.map(function (subtree){
                                leftAccumulator += subtree.getWidth();
                                return (
                                    React.createElement(TreeNode, {lineSpacing: this.props.lineSpacing, 
                                              root: subtree, 
                                              focus: this.props.focus, 
                                              allFocus: this.props.allFocus, 
                                              key: subtree.id, 
                                              left: leftAccumulator - subtree.getWidth(), 
                                              top: this.props.lineSpacing + this.props.root.getLabelHeight(), 
                                              maxDepth: this.props.maxDepth - 1, 
                                              focusCallback: this.props.focusCallback, 
                                              changeCallback: this.props.changeCallback, 
                                              keyHandler: this.props.keyHandler, 
                                              onBlur: this.props.onBlur})
                                );
                            }.bind(this));
                        }
                    }.bind(this)()
                )
            )
        );
    }
});

module.exports = TreeNode;
