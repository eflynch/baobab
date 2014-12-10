Baobab = require('../dist/baobab')
React = require('react')

window.React = React

Tree = Baobab.Tree
TreeState = Baobab.TreeState

window.onload = ->
    type = 'circle'
    maxAncestor = 6
    onChange = (string) -> document.getElementById('textOutput').value = string

    target = document.getElementById('treeview')
    React.render Tree({
        onChange: onChange,
        maxAncestor: maxAncestor,
        type: type
    }), target
    
    document.getElementById('textInput').onkeydown = (e) ->
        if e.keyCode == 13
            e.preventDefault()
            initialRoot = TreeState.fromJSON(e.currentTarget.value)
            React.render Tree({
                setRoot: initialRoot,
                type: type,
                maxAncestor: maxAncestor,
                onChange: onChange
            }), target

    window.onkeydown = (e) =>
        target = document.getElementById('treeview')
        if e.keyCode == 191 and e.metaKey
            type = switch type
                when 'circle' then 'rectangle'
                when 'rectangle' then 'triangle'
                when 'triangle' then 'square'
                when 'square' then 'circle'
            React.render Tree({type: type, focusType: type, maxAncestor: maxAncestor, onChange: onChange}), target
        if e.keyCode == 189 and e.ctrlKey
            maxAncestor = Math.max(maxAncestor - 1, 3)
            React.render Tree({type: type, maxAncestor: maxAncestor, onChange: onChange}), target
        if e.keyCode == 187 and e.ctrlKey
            maxAncestor = Math.min(maxAncestor + 1, 45)
            React.render Tree({type: type, maxAncestor: maxAncestor, onChange: onChange}), target
