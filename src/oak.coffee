React = require('react')
ra = React.DOM

class TreeState
	constructor: ({@value, @callback, @parent}) ->
		@subtrees = []
		@id = Math.round Math.random() * 100000
		@collapsed = false
	setCollapsed: (newValue) =>
		@collapsed = newValue
		@callback()
		return
	getCollapsed: ->
		if @subtrees.length
			return @collapsed
		@collapsed = false
		return false
	setValue: (newValue) =>
		@value = newValue
		@callback()
		return
	addSubTree: (value, sibling = null, relation = null) =>
		if sibling?
			if relation == 'right'
				insertIndex = @subtrees.indexOf(sibling)
			if relation == 'left'
				insertIndex = @subtrees.indexOf(sibling) + 1
		else
			insertIndex = @subtrees.length
		newTree = new TreeState({value: value, callback: @callback, parent: this})
		@subtrees.splice insertIndex, 0, newTree
		@callback()
		return newTree
	deleteSubTree: (subtree) =>
		indexToDelete = @subtrees.indexOf(subtree)
		if indexToDelete?
			@subtrees.splice(indexToDelete, 1)
	getWidth: ->

	getRadius: ->

	getHeight: ->

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
		className: 'circle'
		style: {
			position: 'absolute'
			left: @props.left
			borderRadius: @props.radius
			width: 2 * @props.radius
			height: 2 * @props.radius
		}
	,
		@props.children

Square = React.createClass
	displayName: 'Square'

	render: -> @transferPropsTo ra.div
		className: 'circle'
		style: {
			position: 'absolute'
			left: @props.left
			width: 2 * @props.radius
			height: 2 * @props.radius
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
		if @props.hasFocus
			backgroundColor = '#afa'
		else
			backgroundColor = '#fff'
		if @props.collapsed
			comp = Square
		else
			comp = Circle
		return @transferPropsTo comp
			style: {
				position: 'absolute'
				left: @props.left
				backgroundColor: backgroundColor
				textAlign: 'center'
			}
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
						@props.toggleCollapsedCallback()
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
					width: 2 * @props.radius - 5
					textAlign: 'center'
					marginTop: @props.radius - 7
					border: 'none'
					backgroundColor: backgroundColor
				onChange: (e) =>
					newValue = e.currentTarget.value
					@props.changeCallback newValue

TreeNode = React.createClass
	getDefaultProps: ->
		parentWidth: 0 
		parentRadius: 0
		offset: 0 
		showEtc: false
	getRadiusFromValue: (value) -> Math.max(value.length * 4 + 1, 16)
	getWidth: (tree) ->
		byItself = @getRadiusFromValue(tree.value) * 2 + 4
		if not tree.subtrees.length
			return byItself
		total = 0
		for subtree in tree.subtrees
			total += @getWidth(subtree)
		if total > byItself
			return total
		return byItself

	getThisWidth: ->
		@getWidth({value: @props.root.value, subtrees: @props.root.subtrees})

	getHeight: (tree) ->
		if not tree.subtrees.length
			return 100
		max = 0
		for subtree in tree.subtrees
			if @getHeight(subtree) > max
				max = @getHeight(subtree)
		return max + 100

	getThisHeight: -> @getHeight({value: @props.root.value, subtrees: @props.root.subtrees})

	getLineValues: ->
		startX: @getCenter().x
		startY: @getCenter().y
		endX: @props.parentWidth / 2 - @props.offset
		endY: @props.parentRadius - @props.verticalOffset

	getCenter: ->
		x: @getThisWidth() / 2
		y: @getRadiusFromValue(@props.root.value)

	render: ->
		if @props.focus?
			hasFocus = @props.focus.id == @props.root.id
		else
			hasFocus = false
		offset = 0
		return @transferPropsTo ra.li
			style:
				position: 'absolute'
				top: @props.verticalOffset
				left: "#{@props.offset}px"
				width: "#{@getThisWidth()}px"
				height: "#{@getThisHeight()}px"
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
				left: @getCenter().x - @getRadiusFromValue(@props.root.value)
				radius: @getRadiusFromValue(@props.root.value)
				changeCallback: @props.changeCallback
				toggleCollapsedCallback: @props.toggleCollapsedCallback
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
				hasFocus: hasFocus
				collapsed: @props.root.getCollapsed()
			, @props.root.value
			ra.ul null,
				if not @props.root.getCollapsed()
					for subtree in @props.root.subtrees
						offset += @getWidth(subtree)
						focusCallback = @props.focusCallback
						TreeNode
							changeCallback: @props.changeCallback
							toggleCollapsedCallback: @props.toggleCollapsedCallback
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
							root: subtree
							focus: @props.focus
							key: subtree.id
							offset: offset - @getWidth(subtree)
							verticalOffset: 20 + @getRadiusFromValue(@props.root.value) * 2 
							parentWidth: @getThisWidth()
							parentRadius: @getRadiusFromValue(@props.root.value)

ListNode = React.createClass
	render: -> ra.li null,
		ra.p null, @props.value
		ra.ul null,
			for subtree in @props.subtrees
				ListNode
					value: subtree.value
					subtrees: subtree.subtrees or []


OakTree = (id) ->
	mockData = new TreeState
		value: ''
		callback: -> React.renderComponent(Tree(null), document.getElementById('content'))

	Tree = React.createClass
		getInitialState: ->
			root: mockData
			focus: mockData
			head: mockData
		render: -> TreeNode
			changeCallback: (newValue) =>
				if @state.focus?
					@state.focus.setValue newValue
					return true
				return false
			toggleCollapsedCallback: =>
				if @state.focus.getCollapsed()
					@state.focus.setCollapsed false
				else
					@state.focus.setCollapsed true
			addChildCallback: =>
				newTree = @state.focus.addSubTree ''
				@setState({focus: newTree})
				return true
			addParentCallback: =>
				if not @state.focus.parent?
					newTree = new TreeState
						value: ''
						callback: @state.root.callback
					newTree.subtrees.push(@state.root)
					@state.root.parent = newTree
					@setState
						root: newTree
						focus: newTree
						head: newTree
			addLeftSiblingCallback: =>
				if @state.focus.parent?
					newTree = @state.focus.parent.addSubTree '', @state.focus, 'right'
					@setState({focus: newTree})
					return true
				return false
			addRightSiblingCallback: =>
				if @state.focus.parent?
					newTree = @state.focus.parent.addSubTree '', @state.focus, 'left'
					@setState({focus: newTree})
					return true
				return false
			focusCallback: (newFocus) =>
				@setState({focus: newFocus})
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
					if @state.focus.getCollapsed()
						@state.focus.setCollapsed false
					@setState({focus: @state.focus.subtrees[0]})
					return true
				return false
			rightSiblingCallback: =>
				if @state.focus.parent?
					oldIndex = @state.focus.parent.subtrees.indexOf(@state.focus)
					if @state.focus.parent.subtrees.length > (oldIndex + 1)
						@setState({focus: @state.focus.parent.subtrees[oldIndex + 1]})
						return true
				return false
			leftSiblingCallback: =>
				if @state.focus.parent?
					oldIndex = @state.focus.parent.subtrees.indexOf(@state.focus)
					if oldIndex > 0
						@setState({focus: @state.focus.parent.subtrees[oldIndex - 1]})
						return true
				return false
			deleteCallback: =>
				if @state.focus.parent? and not @state.focus.subtrees.length
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
				if @state.focus.parent?
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

	return mockData.callback

window.onload = ->
  callback = OakTree('content')
  callback()


