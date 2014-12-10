React = require('react')
ra = React.DOM

Line = React.createClass
    displayName: 'Line'
    getAngle: ->
        deltaX = @props.endX - @props.startX
        deltaY = @props.endY - @props.startY
        theta = switch
            when deltaX < 0 and deltaY < 0 then Math.atan(deltaY / deltaX) + Math.PI
            when deltaX > 0 and deltaY < 0 then Math.atan(deltaY / deltaX)
            else Math.atan(deltaY / deltaX)
        return 180 / Math.PI * theta
    render: ->
        angle = @getAngle()
        left = @props.startX
        top = @props.startY
        length = Math.sqrt Math.pow(Math.abs(@props.startX - @props.endX), 2) + Math.pow(Math.abs(@props.startY - @props.endY), 2)
        return ra.div
            className: 'BAOBAB_line',
            style: {
                width: length
                height: @props.width
                msTransformOrigin: '0% 0%'
                WebkitTransformOrigin: '0% 0%'
                MozTransformOrigin: '0% 0%'
                transformOrigin: '0% 0%'
                msTransform: "rotate(#{angle}deg)"
                WebkitTransform: "rotate(#{angle}deg)"
                MozTransform: "rotate(#{angle}deg)"
                Transform: "rotate(#{angle}deg)"
                backgroundColor: @props.color
                left: "#{left}px"
                top: "#{top}px"
                position: 'absolute'
            }

module.exports = React.createFactory Line
