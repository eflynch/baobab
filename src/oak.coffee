React = require('react')
ra = React.DOM

id = 0
class TreeState
	constructor: ({@value, @callback, @parent, @type}) ->
		@subtrees = []
		@id = "#{id}"
		id += 1
		@collapsed = false
		@width = null
	setElectivelyCollapsed: (newValue) =>
		@collapsed = newValue
		@soil()
		@callback()
		return
	getElectivelyCollapsed: ->
		if @subtrees.length
			return @collapsed
		@collapsed = false
		return false
	setValue: (newValue) =>
		@value = newValue
		@soil()
		@callback()
		return
	addSubTree: (value, sibling = null, relation = null, type = null) =>
		if sibling?
			if relation == 'right'
				insertIndex = @subtrees.indexOf(sibling)
			if relation == 'left'
				insertIndex = @subtrees.indexOf(sibling) + 1
		else
			insertIndex = @subtrees.length
		if not type?
			type = @type
		newTree = new TreeState({value: value, callback: @callback, parent: this, type: type})
		@subtrees.splice insertIndex, 0, newTree
		@soil()
		@callback()
		return newTree
	deleteSubTree: (subtree) =>
		indexToDelete = @subtrees.indexOf(subtree)
		if indexToDelete?
			@subtrees.splice(indexToDelete, 1)
		@soil()
		@callback()
	getWidth: (collapsed = false)->
		if collapsed
			@width = @getLabelWidth() + 4
			return @width
		if @width?
			return @width
		byItself = @getLabelWidth() + 4
		total = 0
		for subtree in @subtrees
			total += subtree.getWidth()
		if total > byItself
			@width = total
			return total
		@width = byItself
		return byItself
	getDistanceToAncestor: (ancestor) ->
		if ancestor == this
			return 0
		else
			return 1 + @parent.getDistanceToAncestor(ancestor)
	getNearerAncestor: (ancestor, nearNess) ->
		if ancestor == this
			return ancestor
		if nearNess == 0
			return this
		return @parent.getNearerAncestor(ancestor, nearNess - 1)
	soil: ->
		@width = null
		if @parent?
			@parent.soil()

	getLabelWidth: -> Math.max(@value.length * 4 + 1, 16) * 2

	getLabelHeight: ->
		return switch @type
			when 'rectangle' then 25
			when 'circle' then @getLabelWidth()
			when 'triangle' then @getLabelWidth()

Line = React.createClass
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
		return @transferPropsTo ra.div
			className: 'line',
			style: {
				width: length
				height: @props.width
				'-ms-transform-origin': '0% 0%'
				'-webkit-transform-origin': '0% 0%'
				'-moz-transform-origin': '0% 0%'
				'transform-origin': '0% 0%'
				'-ms-transform': "rotate(#{angle}deg)"
				'-webkit-transform': "rotate(#{angle}deg)"
				'-moz-transform': "rotate(#{angle}deg)"
				'transform': "rotate(#{angle}deg)"
				'background-color': @props.color
				left: "#{left}px"
				top: "#{top}px"
				position: 'absolute'
				zIndex: -1
			}

Circle = React.createClass
	displayName: 'Circle'

	render: -> @transferPropsTo ra.div
		className: 'label'
		style: {
			position: 'absolute'
			left: @props.left
			borderRadius: @props.width / 2
			width: @props.width
			height: @props.width
		}
	,
		@props.children

Rectangle = React.createClass
	displayName: 'Rectangle'

	render: -> @transferPropsTo ra.div
		className: 'label'
		style: {
			position: 'absolute'
			left: @props.left
			borderRadius: 5
			width: @props.width
			height: @props.height
		}
	,
		@props.children

Triangle = React.createClass
	displayName: 'Triangle'

	render: -> @transferPropsTo ra.div
		className: 'label'
		style: {
			position: 'absolute'
			left: @props.left
			width: @props.width
			height: @props.height
		}
	,
		@props.children

Square = React.createClass
	displayName: 'Square'

	render: -> @transferPropsTo ra.div
		className: 'label'
		style: {
			position: 'absolute'
			left: @props.left
			width: @props.width
			height: @props.width
		}
	,
		@props.children

TreeLabel = React.createClass
	displayName: 'TreeLabel'
	componentDidMount: ->
		@componentDidUpdate()
	componentDidUpdate: ->
		if @props.hasFocus
			@getDOMNode().children[0].focus()
	render: ->
		backgroundColor = switch
			when @props.hasFocus and @props.collapsed then '#8c8'
			when @props.hasFocus then '#afa'
			when @props.collapsed then '#888'
			else '#fff'
		comp = switch @props.type
			when 'circle' then Circle
			when 'rectangle' then Rectangle
			when 'triangle' then Triangle
			when 'square' then Square
		return @transferPropsTo comp
			style:
				position: 'absolute'
				left: @props.left
				backgroundColor: backgroundColor
				textAlign: 'center'
			onClick: (e) =>
				e.currentTarget.children[0].focus()
			onKeyDown: (e) =>
				shift = e.shiftKey
				ctrl = e.ctrlKey
				meta = e.metaKey
				switch
					when e.key == 'Enter' and ctrl
						@props.setHeadCallback()
					when e.key == ' ' and shift
						e.preventDefault()
						@props.toggleElectivelyCollapsedCallback()
					when e.key == 'Backspace'
						if shift
							e.preventDefault()
							@props.forceDeleteCallback()
						else
							if not @props.children
								e.preventDefault()
								@props.deleteCallback()
					when (shift and e.key == 'ArrowLeft') or (e.key == 'Backspace' and ctrl)
						e.preventDefault()
						if meta
							@props.addLeftSiblingCallback()
						else
							if not @props.leftSiblingCallback()
								@props.addLeftSiblingCallback()
					when (shift and e.key == 'ArrowRight') or e.key == 'Tab'
						e.preventDefault()
						if meta
							@props.addRightSiblingCallback()
						else
							if not @props.rightSiblingCallback()
								@props.addRightSiblingCallback()
					when (shift and e.key == 'ArrowDown') or e.key == 'Enter'
						e.preventDefault()
						if meta
							@props.addChildCallback()
						else
							if not @props.descendCallback()
								@props.addChildCallback()
					when (shift and e.key == 'ArrowUp') or e.key == 'Escape'
						if meta
							@props.addParentCallback()
						else
							e.preventDefault()
							if not @props.ascendCallback()
								@props.addParentCallback()
		, ra.input
				type: 'text'
				value: @props.children
				style:
					display: 'table-cell'
					width: @props.width - 5
					textAlign: 'center'
					marginTop: @props.height / 2 - 7
					border: 'none'
					backgroundColor: backgroundColor
				onChange: (e) =>
					newValue = e.currentTarget.value
					@props.changeCallback newValue

TreeNode = React.createClass
	
	rendersCollapsed: -> (@props.root.getElectivelyCollapsed() or (@props.maxDepth < 0))
	getDefaultProps: ->
		left: 0 
		top: 0
		showEtc: false

	getLineValues: ->
		startX: @getCenter().x
		startY: @getCenter().y
		endX: @props.root.parent.getWidth() / 2 - @props.left if @props.root.parent?
		endY: @props.root.parent.getLabelHeight() / 2 - @props.top if @props.root.parent?

	getCenter: ->
		x: @props.root.getWidth(@rendersCollapsed()) / 2
		y: @props.root.getLabelHeight() / 2

	render: ->
		if @props.focus?
			hasFocus = @props.focus.id == @props.root.id
		else
			hasFocus = false
		left = 0

		return @transferPropsTo ra.li
			style:
				position: 'absolute'
				top: @props.top
				left: @props.left
				width: "#{@props.root.getWidth(@rendersCollapsed())}px"
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
						endX:	@getLineValues().startX
						endY: -20
			TreeLabel
				type: @props.root.type
				left: @getCenter().x - @props.root.getLabelWidth() / 2
				width: @props.root.getLabelWidth()
				height: @props.root.getLabelHeight()
				hasFocus: hasFocus
				collapsed: @rendersCollapsed()
				# Callbacks
				changeCallback: @props.changeCallback
				toggleElectivelyCollapsedCallback: @props.toggleElectivelyCollapsedCallback
				addChildCallback: @props.addChildCallback
				addParentCallback: @props.addParentCallback
				addRightSiblingCallback: @props.addRightSiblingCallback
				addLeftSiblingCallback: @props.addLeftSiblingCallback
				ascendCallback: @props.ascendCallback
				descendCallback: @props.descendCallback
				rightSiblingCallback: @props.rightSiblingCallback
				leftSiblingCallback: @props.leftSiblingCallback
				deleteCallback: @props.deleteCallback
				forceDeleteCallback: @props.forceDeleteCallback
				onFocus: =>
					@props.focusCallback @props.root
				setHeadCallback: @props.setHeadCallback

			, @props.root.value
			ra.ul null,
				if not @rendersCollapsed()
					for subtree in @props.root.subtrees
						left += subtree.getWidth(@rendersCollapsed())
						focusCallback = @props.focusCallback
						TreeNode
							root: subtree
							focus: @props.focus
							key: subtree.id
							left: left - subtree.getWidth(@rendersCollapsed())
							top: 20 + @props.root.getLabelHeight()
							# Callbacks
							changeCallback: @props.changeCallback
							toggleElectivelyCollapsedCallback: @props.toggleElectivelyCollapsedCallback
							addChildCallback: @props.addChildCallback
							addParentCallback: @props.addParentCallback
							addRightSiblingCallback: @props.addRightSiblingCallback
							addLeftSiblingCallback: @props.addLeftSiblingCallback
							focusCallback: @props.focusCallback
							setHeadCallback: @props.setHeadCallback
							ascendCallback: @props.ascendCallback
							descendCallback: @props.descendCallback
							rightSiblingCallback: @props.rightSiblingCallback
							leftSiblingCallback: @props.leftSiblingCallback
							deleteCallback: @props.deleteCallback
							forceDeleteCallback: @props.forceDeleteCallback
							maxDepth: @props.maxDepth - 1
							

ListNode = React.createClass
	render: -> ra.li null,
		ra.p null, @props.value
		ra.ul null,
			for subtree in @props.subtrees
				ListNode
					value: subtree.value
					subtrees: subtree.subtrees or []


OakTree = (id) ->
	data = new TreeState
		value: ''
		callback: -> React.renderComponent(Tree(null), document.getElementById(id))
		type: 'circle'

	Tree = React.createClass
		getInitialState: ->
			root: data
			focus: data
			head: data
			type: 'circle'
			maxAncestor: 5

		componentDidMount: ->
			window.onkeydown = (e) =>
				newType = switch @state.type
					when 'circle' then 'rectangle'
					when 'rectangle' then 'triangle'
					when 'triangle' then 'circle'
				if e.keyCode == 191 and e.metaKey
					@setState({type: newType})
		render: -> ra.div
			style:
				position: 'relative'
			, TreeNode
				changeCallback: (newValue) =>
					if @state.focus?
						@state.focus.setValue newValue
						return true
					return false
				toggleElectivelyCollapsedCallback: =>
					if @state.focus.getElectivelyCollapsed()
						@state.focus.setElectivelyCollapsed false
					else
						@state.focus.setElectivelyCollapsed true
				addChildCallback: =>
					newTree = @state.focus.addSubTree('', null, null, @state.type)
					@setState({focus: newTree})
					@setState({head: @state.focus.getNearerAncestor(@state.head, @state.maxAncestor)})
					return true
				addParentCallback: =>
					if not @state.focus.parent?
						newTree = new TreeState
							value: ''
							callback: @state.root.callback
							type: @state.type
						newTree.subtrees.push(@state.root)
						@state.root.parent = newTree
						@setState
							root: newTree
							focus: newTree
							head: newTree
				addLeftSiblingCallback: =>
					if @state.focus != @state.head
						newTree = @state.focus.parent.addSubTree '', @state.focus, 'right', @state.type
						@setState({focus: newTree})
						return true
					return false
				addRightSiblingCallback: =>
					if @state.focus != @state.head
						newTree = @state.focus.parent.addSubTree '', @state.focus, 'left', @state.type
						@setState({focus: newTree})
						return true
					return false

				focusCallback: (newFocus) =>
					@setState({focus: newFocus})
					@setState({head: @state.focus.getNearerAncestor(@state.head, @state.maxAncestor)})
					return true
				setHeadCallback: =>
					@setState({head: @state.focus})
				ascendCallback: =>
					if @state.focus.parent?
						if @state.focus == @state.head
							@setState({head: @state.head.parent})
						@setState({focus: @state.focus.parent})
						return true
					return false
				descendCallback: =>
					if @state.focus.subtrees.length
						if @state.focus.getElectivelyCollapsed()
							@state.focus.setElectivelyCollapsed false
						@setState({focus: @state.focus.subtrees[0]})
						@setState({head: @state.focus.getNearerAncestor(@state.head, @state.maxAncestor)})
						return true
					return false
				rightSiblingCallback: =>
					if @state.focus != @state.head
						oldIndex = @state.focus.parent.subtrees.indexOf(@state.focus)
						if @state.focus.parent.subtrees.length > (oldIndex + 1)
							@setState({focus: @state.focus.parent.subtrees[oldIndex + 1]})
							return true
					return false
				leftSiblingCallback: =>
					if @state.focus != @state.head
						oldIndex = @state.focus.parent.subtrees.indexOf(@state.focus)
						if oldIndex > 0
							@setState({focus: @state.focus.parent.subtrees[oldIndex - 1]})
							return true
					return false
				deleteCallback: =>
					if @state.focus != @state.root and not @state.focus.subtrees.length
						focus = @state.focus
						parent = @state.focus.parent

						oldIndex = parent.subtrees.indexOf(focus)
						if oldIndex > 0
							@setState({focus: parent.subtrees[oldIndex - 1]})
						else
							@setState({focus: parent})

						parent.deleteSubTree(focus)
						return true
					return false
				forceDeleteCallback: =>
					if @state.focus != @state.root
						focus = @state.focus
						parent = @state.focus.parent

						oldIndex = parent.subtrees.indexOf(focus)
						if oldIndex > 0
							@setState({focus: parent.subtrees[oldIndex - 1]})
						else
							@setState({focus: parent})

						parent.deleteSubTree(focus)
						return true
					return false
				onBlur: (e) =>
					if e.relatedTarget is null
						@setState({focus: null})

				showEtc: @state.head != @state.root
				focus: @state.focus
				root: @state.head
				maxDepth: @state.maxAncestor

	return data.callback

window.onload = ->
  callback = OakTree('content')
  callback()


