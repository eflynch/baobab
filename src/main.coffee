Baobab = require('./baobab.coffee')
React = require('react')

BaobabTree = Baobab.BaobabTree
TreeState = Baobab.BaobabTreeState
treeStateFromJSON = Baobab.treeStateFromJSON

window.onload = ->
	target = document.getElementById('treeview')
	initialRoot = new TreeState {value: '', type: 'circle'}
	textSetter = (string) -> document.getElementById('textOutput').value = string
	React.renderComponent BaobabTree({initialRoot: initialRoot, textSetter: textSetter}), target

	document.getElementById('textInput').onkeydown = (e) ->
		if e.keyCode == 13
			e.preventDefault()
			initialRoot = treeStateFromJSON(e.currentTarget.value)
			React.renderComponent BaobabTree({initialRoot: initialRoot}), target

type = 'circle'
maxAncestor = 6
window.onkeydown = (e) =>
	target = document.getElementById('treeview')
	
	if e.keyCode == 191 and e.metaKey
		type = switch type
			when 'circle' then 'rectangle'
			when 'rectangle' then 'triangle'
			when 'triangle' then 'square'
			when 'square' then 'circle'
		React.renderComponent BaobabTree({type: type}), target
	if e.keyCode == 189 and e.ctrlKey
		maxAncestor = Math.max(maxAncestor - 1, 3)
		React.renderComponent BaobabTree({maxAncestor: maxAncestor}), target
	if e.keyCode == 187 and e.ctrlKey
		maxAncestor = Math.min(maxAncestor + 1, 45)
		React.renderComponent BaobabTree({maxAncestor: maxAncestor}), target
