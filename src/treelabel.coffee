React = require('react/addons')
ra = React.DOM
cx = React.addons.classSet

TreeLabelWrapper = React.createClass
    displayName: 'TreeLabelWrapper'
    getStyle: ->
        return switch @props.type
            when 'circle'
                position: 'absolute'
                left: @props.left
                borderRadius: @props.width / 2
                width: @props.width
                height: @props.height
            when 'rectangle'
                position: 'absolute'
                left: @props.left
                borderRadius: 5
                width: @props.width
                height: @props.height
            when 'triangle'
                position: 'absolute'
                left: @props.left
                width: @props.width
                height: @props.height
            when 'square'
                position: 'absolute'
                left: @props.left
                width: @props.width
                height: @props.height
    render: -> ra.div
        className: "BAOBAB_#{@props.type} " + cx
            BAOBAB_label: true
            BAOBAB_hasFocus: @props.hasFocus
            BAOBAB_collapsed: @props.collapsed
        onClick: (e) =>
            e.currentTarget.children[0].focus()
        onKeyDown: @props.onKeyDown
        onFocus: @props.onFocus
        style: @getStyle()
    ,
        @props.children


TreeLabel = React.createClass
    displayName: 'TreeLabel'
    componentDidMount: ->
        @componentDidUpdate()
    componentDidUpdate: ->
        if @props.hasFocus and @props.allFocus
            @getDOMNode().children[0].focus()
    render: ->
        return React.createElement TreeLabelWrapper,
            type: @props.type
            hasFocus: @props.hasFocus
            collapsed: @props.collapsed
            left: @props.left
            width: @props.width
            height: @props.height
            onFocus: @props.onFocus
            onKeyDown: @props.keyHandler
        ,
            ra.textarea
                type: 'text'
                value: @props.children
                style:
                    width: @props.textWidth
                    height: @props.textHeight
                    marginTop: (@props.height - @props.textHeight) / 2
                    marginLeft: (@props.width - @props.textWidth) / 2
                onChange: (e) =>
                    newValue = e.currentTarget.value
                    @props.changeCallback newValue
                    return

module.exports = React.createFactory TreeLabel
