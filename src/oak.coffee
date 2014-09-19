React = require('react')
ra = React.DOM

treeStateFromJSON = (string) ->
	simpleObject = JSON.parse(string)
	treeStateFromSimpleObject = (simpleObject, parent = null) ->
		newTree = new TreeState
			value: simpleObject.value
			parent: parent
			type: simpleObject.type
		newTree.id = simpleObject.id
		newTree.mutator().setCollapsed simpleObject.collapsed
		for subObject in simpleObject.subtrees
			newTree.subtrees.push treeStateFromSimpleObject(subObject, newTree)
		return newTree
	return treeStateFromSimpleObject simpleObject


id = 0
class TreeState
	constructor: ({@value, @parent, @type}) ->
		@subtrees = []
		@id = "#{id}"
		id += 1
		@collapsed = false
		@width = null
	mutator: =>
		setCollapsed: (newValue) =>
			@collapsed = newValue
			if newValue == false
				for subtree in @subtrees
					subtree.mutator().setCollapsed false
			@soil()
			return
		setValue: (newValue) =>
			@value = newValue
			@soil()
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
			newTree = new TreeState({value: value, parent: this, type: type})
			@subtrees.splice insertIndex, 0, newTree
			@soil()
			return newTree
		deleteSubTree: (subtree) =>
			indexToDelete = @subtrees.indexOf(subtree)
			if indexToDelete?
				@subtrees.splice(indexToDelete, 1)
			@soil()
		collapseYouth: (nearNess) =>
			if not @subtrees.length
				return true
			if nearNess < 0
				@mutator().setCollapsed true
				return true
			for subtree in @subtrees
				subtree.mutator().collapseYouth (nearNess - 1)
			return true
	getCollapsed: ->
		if not @subtrees.length
			@collapsed = false
			return false
		if @collapsed
			return true
	getWidth: ->
		if @width?
			return @width

		@width = @getLabelWidth() + 4
		if @collapsed
			return @width
		total = 0
		for subtree in @subtrees
			total += subtree.getWidth()
		if total > @width
			@width = total
		return @width
	getNearerAncestor: (ancestor, nearNess) ->
		if not @parent?
			return this
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
			when 'square' then @getLabelWidth()
	toJSON: ->
		toSimpleObject = (tree) ->
			value: tree.value
			subtrees: toSimpleObject(subtree) for subtree in tree.subtrees
			collapsed: tree.collapsed
			id: tree.id
			type: tree.type
		return JSON.stringify toSimpleObject this


			

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
		style:
			position: 'absolute'
			left: @props.left
			width: @props.width
			height: @props.height
	,
		@props.children

Square = React.createClass
	displayName: 'Square'

	render: -> @transferPropsTo ra.div
		className: 'label'
		style:
			position: 'absolute'
			left: @props.left
			width: @props.width
			height: @props.width
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
					when e.key == 'Enter' and shift
						@props.cb.setHeadCallback()
					when e.key == ' ' and shift
						e.preventDefault()
						@props.cb.toggleElectivelyCollapsedCallback()
					when e.key == 'Backspace'
						if shift
							e.preventDefault()
							@props.cb.forceDeleteCallback()
						else
							if not @props.children
								e.preventDefault()
								@props.cb.deleteCallback()
					when e.key == 'Enter'
						e.preventDefault()
						@props.cb.addChildCallback()
					when e.key == 'Tab'
						e.preventDefault()
						@props.cb.addRightSiblingCallback()
					when e.key == 'Escape'
						e.preventDefault()
						if not @props.cb.ascendCallback()
							@props.cb.addParentCallback()
					when (shift and e.key == 'ArrowLeft')
						e.preventDefault()
						if meta
							@props.cb.addLeftSiblingCallback()
						else
							@props.cb.leftSiblingCallback()

					when (shift and e.key == 'ArrowRight')
						e.preventDefault()
						if meta
							@props.cb.addRightSiblingCallback()
						else
							@props.cb.rightSiblingCallback()
					when (shift and e.key == 'ArrowDown')
						e.preventDefault()
						if meta
							@props.cb.addChildCallback()
						else
							@props.cb.descendCallback()
					when (shift and e.key == 'ArrowUp')
						if meta
							@props.cb.addParentCallback()
						else
							e.preventDefault()
							@props.cb.ascendCallback()
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
					@props.cb.changeCallback newValue

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
		return @transferPropsTo ra.li
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
						endX:	@getLineValues().startX
						endY: -20
			TreeLabel
				type: @props.root.type
				left: @getCenter().x - @props.root.getLabelWidth() / 2
				width: @props.root.getLabelWidth()
				height: @props.root.getLabelHeight()
				hasFocus: hasFocus
				collapsed: @props.root.getCollapsed()
				cb: @props.cb
				onFocus: =>
					@props.cb.focusCallback @props.root

			, @props.root.value
			ra.ul null,
				if not @props.root.getCollapsed()
					leftAccumulator = 0
					for subtree in @props.root.subtrees
						leftAccumulator += subtree.getWidth()
						TreeNode
							root: subtree
							focus: @props.focus
							key: subtree.id
							left: leftAccumulator - subtree.getWidth()
							top: 20 + @props.root.getLabelHeight()
							maxDepth: @props.maxDepth - 1
							cb: @props.cb
							

OakTree = React.createClass
	getInitialState: ->
		root: @props.initialRoot
		focus: @props.initialRoot
		head: @props.initialRoot
		textSetter: @props.textSetter
		type: 'circle'
		maxAncestor: 6

	componentWillReceiveProps: (nextProps) ->
		if nextProps.initialRoot?
			@setState
				root: nextProps.initialRoot
				focus: nextProps.initialRoot
				head: nextProps.initialRoot
		if nextProps.type?
			@setState({type: nextProps.type})
		if nextProps.maxAncestor?
			@setState({maxAncestor: nextProps.maxAncestor})
		if nextProps.textSetter?
			@setState({textSetter: nextProps.textSetter})

	componentDidUpdate: ->
		if @state.textSetter?
			@state.textSetter @state.root.toJSON()

	setHeadAndCollapseYouth: (focus = null, head = null) ->
		focus ?= @state.focus
		head ?= @state.head
		head.mutator().collapseYouth @state.maxAncestor
		@setState
			head: focus.getNearerAncestor(head, @state.maxAncestor)

	render: -> ra.div
		style:
			position: 'relative'
		,
			TreeNode
				cb:
					changeCallback: (newValue) =>
						if @state.focus?
							@state.focus.mutator().setValue newValue
							@setState({focus: @state.focus})
							return true
						return false
					toggleElectivelyCollapsedCallback: =>
						if @state.focus.getCollapsed()
							@state.focus.mutator().setCollapsed false
						else
							@state.focus.mutator().setCollapsed true
						@setState({focus: @state.focus})
					addChildCallback: =>
						newTree = @state.focus.mutator().addSubTree('', null, null, @state.type)
						@setState({focus: newTree})
						@setHeadAndCollapseYouth()
						return true
					addParentCallback: =>
						if not @state.focus.parent?
							newTree = new TreeState
								value: ''
								type: @state.type
							newTree.subtrees.push(@state.root)
							@state.root.parent = newTree
							@setHeadAndCollapseYouth newTree, newTree
							@setState
								root: newTree
								focus: newTree
								head: newTree
					addLeftSiblingCallback: =>
						if @state.focus != @state.head
							newTree = @state.focus.parent.mutator().addSubTree '', @state.focus, 'right', @state.type
							@setState({focus: newTree})
							return true
						return false
					addRightSiblingCallback: =>
						if @state.focus != @state.head
							newTree = @state.focus.parent.mutator().addSubTree '', @state.focus, 'left', @state.type
							@setState({focus: newTree})
							return true
						return false

					focusCallback: (newFocus) =>
						@setState({focus: newFocus})
						@setHeadAndCollapseYouth(newFocus)
						return true
					setHeadCallback: =>
						if @state.focus.getCollapsed()
							@state.focus.mutator().setCollapsed false
						@setState({head: @state.focus})
					ascendCallback: =>
						if @state.focus.parent?
							if @state.focus == @state.head
								head = @state.head.parent
							else
								head = @state.head
							focus = @state.focus.parent
							@setState({focus: focus, head: head})
							@setHeadAndCollapseYouth focus, head
							return true
						return false
					descendCallback: =>
						if @state.focus.subtrees.length
							if @state.focus.getCollapsed()
								@state.focus.mutator().setCollapsed false
							@setState({focus: @state.focus.subtrees[0]})
							@setHeadAndCollapseYouth()
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

							parent.mutator().deleteSubTree(focus)
							return true
						return false
					forceDeleteCallback: =>
						focus = @state.focus
						for subtree in @state.focus.subtrees
							focus.mutator().deleteSubTree(subtree)
						@setState({focus: focus})
						return true
				onBlur: (e) =>
					if e.relatedTarget is null
						@setState({focus: null})

				showEtc: @state.head != @state.root
				focus: @state.focus
				root: @state.head
				maxDepth: @state.maxAncestor

module.exports =
	OakTreeState: TreeState
	OakTree: OakTree
	treeStateFromJSON: treeStateFromJSON
