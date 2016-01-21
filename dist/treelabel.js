var React = require('react');
var cx = require('classnames');

TreeLabelWrapper = React.createClass({
    displayName: 'TreeLabelWrapper',
    getStyle: function() {
        switch (this.props.type) {
            case 'circle':
                return {
                    position: 'absolute',
                    left: this.props.left,
                    borderRadius: this.props.width / 2,
                    width: this.props.width,
                    height: this.props.height
                };
            case 'rectangle':
                return {
                    position: 'absolute',
                    left: this.props.left,
                    borderRadius: 5,
                    width: this.props.width,
                    height: this.props.height
                };
            case 'triangle':
                return {
                    position: 'absolute',
                    left: this.props.left,
                    width: this.props.width,
                    height: this.props.height
                };
            case 'square':
                return {
                    position: 'absolute',
                    left: this.props.left,
                    width: this.props.width,
                    height: this.props.height
                };
        }
    },
    render: function() {
        return (
            <div className={cx("BAOBAB_"+this.props.type, {
                    "BAOBAB_label": true,
                    BAOBAB_hasFocus: this.props.hasFocus,
                    BAOBAB_collapsed: this.props.collapsed})}
                 onClick={function(e){e.currentTarget.children[0].focus();}}
                 onKeyDown={this.props.onKeyDown}
                 onFocus={this.props.onFocus}
                 style={this.getStyle()}>
                {this.props.children}
            </div>
        );
    }
});

TreeLabel = React.createClass({
    displayName: 'TreeLabel',
    componentDidMount: function() {
        return this.componentDidUpdate();
    },
    componentDidUpdate: function() {
        if (this.props.hasFocus && this.props.allFocus) {
            return this.getDOMNode().children[0].focus();
        }
    },
    render: function() {
        return (
            <TreeLabelWrapper type={this.props.type} hasFocus={this.props.hasFocus}
                              collapsed={this.props.collapsed} left={this.props.left}
                              width={this.props.width} height={this.props.height}
                              onFocus={this.props.onFocus} onKeyDown={this.props.keyHandler}>
                <textarea type='text' value={this.props.children}
                          style={{
                            width: this.props.textWidth,
                            height: this.props.textHeight,
                            marginTop: (this.props.height - this.props.textHeight) / 2,
                            marginLeft: (this.props.width - this.props.textWidth) / 2
                          }}
                          onChange={function(e){this.props.changeCallback(e.currentTarget.value)}.bind(this)}/>
            </TreeLabelWrapper>
        );
    }
});

module.exports = TreeLabel;

