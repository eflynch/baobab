React = require('react')
ra = React.DOM

TreeLabel = require './treelabel'
Line = require './line'

TreeNode = React.createClass
    getDefaultProps: ->
        left: 0 
        top: 0
        showEtc: false
        collapsed: false

    getLineValues: ->
        startX: @getCenter().x
        startY: @getCenter().y
        endX: @props.root.parent.getWidth() / 2 - @props.left if @props.root.parent?
        endY: @props.root.parent.getLabelHeight() / 2 - @props.top if @props.root.parent?

    getCenter: ->
        x: @props.root.getWidth() / 2
        y: @props.root.getLabelHeight() / 2

    render: ->
        if @props.focus?
            hasFocus = @props.focus.id == @props.root.id
        else
            hasFocus = false
        return ra.li
            onBlur: @props.onBlur
            style:
                position: 'absolute'
                top: @props.top
                left: @props.left
                width: "#{@props.root.getWidth()}px"
        ,
            if @props.root.parent?
                if not @props.showEtc
                    Line
                        width: '2px'
                        color: '#000000'
                        startX: @getLineValues().startX
                        startY: @getLineValues().startY
                        endX: @getLineValues().endX
                        endY: @getLineValues().endY
                else
                    Line
                        width: '2px'
                        color: '#aaa'
                        startX: @getLineValues().startX
                        startY: @getLineValues().startY
                        endX:   @getLineValues().startX
                        endY:  -@props.lineSpacing
            TreeLabel
                type: @props.root.type
                left: @getCenter().x - @props.root.getLabelWidth() / 2
                width: @props.root.getLabelWidth()
                height: @props.root.getLabelHeight()
                textWidth: @props.root.getTextWidth()
                textHeight: @props.root.getTextHeight()
                hasFocus: hasFocus
                allFocus: @props.allFocus
                collapsed: @props.root.getCollapsed()
                onFocus: =>
                    @props.focusCallback @props.root
                keyHandler: @props.keyHandler
                changeCallback: @props.changeCallback

            , @props.root.value
            ra.ul null,
                if not @props.root.getCollapsed()
                    leftAccumulator = 0
                    for subtree in @props.root.subtrees
                        leftAccumulator += subtree.getWidth()
                        React.createElement TreeNode,
                            lineSpacing: @props.lineSpacing
                            root: subtree
                            focus: @props.focus
                            allFocus: @props.allFocus
                            key: subtree.id
                            left: leftAccumulator - subtree.getWidth()
                            top: @props.lineSpacing + @props.root.getLabelHeight()
                            maxDepth: @props.maxDepth - 1
                            focusCallback: @props.focusCallback
                            changeCallback: @props.changeCallback
                            keyHandler: @props.keyHandler
                            onBlur: @props.onBlur

module.exports = React.createFactory TreeNode
