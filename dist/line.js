var React = require('react');

var Line = React.createClass({
    displayName: 'Line',
    getAngle: function() {
        var deltaX, deltaY, theta;
        deltaX = this.props.endX - this.props.startX;
        deltaY = this.props.endY - this.props.startY;
        theta = (function() {
            switch (false) {
                case !(deltaX < 0 && deltaY < 0):
                    return Math.atan(deltaY / deltaX) + Math.PI;
                case !(deltaX > 0 && deltaY < 0):
                    return Math.atan(deltaY / deltaX);
                default:
                    return Math.atan(deltaY / deltaX);
            }
        })();
        return 180 / Math.PI * theta;
    },
    render: function() {
        var angle, left, length, top;
        angle = this.getAngle();
        left = this.props.startX;
        top = this.props.startY;
        length = Math.sqrt(Math.pow(Math.abs(this.props.startX - this.props.endX), 2) + Math.pow(Math.abs(this.props.startY - this.props.endY), 2));
        var style = {
            width: length,
            height: this.props.width,
            msTransformOrigin: '0% 0%',
            WebkitTransformOrigin: '0% 0%',
            MozTransformOrigin: '0% 0%',
            transformOrigin: '0% 0%',
            msTransform: "rotate(" + angle + "deg)",
            WebkitTransform: "rotate(" + angle + "deg)",
            MozTransform: "rotate(" + angle + "deg)",
            Transform: "rotate(" + angle + "deg)",
            backgroundColor: this.props.color,
            left: left,
            top: top,
            position: 'absolute'
        }
        return (
            React.createElement("div", {className: "BAOBAB_line", style: style})
        );
    }
});

module.exports = Line;