React = require('react')
$ = require('jquery')

ra = React.DOM

class TreeState
	constructor: ({@value, @callback, @parent}) ->
		@subtrees = []
		@id = Math.round Math.random() * 100000
	setValue: (newValue) =>
		@value = newValue
		@callback()
		return
	addSubTree: (value) =>
		newTree = new TreeState({value: value, callback: @callback, parent: this})
		@subtrees.push newTree
		@callback()
		return newTree
	deleteSubTree: (subtree) =>
		indexToDelete = @subtrees.indexOf(subtree)
		if indexToDelete?
			@subtrees.splice(indexToDelete, 1)


mockData = new TreeState
	value: ''
	callback: -> React.renderComponent(Tree(null), document.getElementById('content'))

Tree = React.createClass
	getInitialState: ->
		root: mockData
		focus: mockData
	render: -> TreeNode
		changeCallback: (newValue) =>
			if @state.focus?
				@state.focus.setValue newValue
				return true
			return false
		addChildCallback: =>
			newTree = @state.focus.addSubTree ''
			@setState({focus: newTree})
			return true
		addSiblingCallback: =>
			if @state.focus.parent?
				newTree = @state.focus.parent.addSubTree ''
				@setState({focus: newTree})
				return true
			return false
		focusCallback: (newFocus) =>
			@setState({focus: newFocus})
			return true
		ascendCallback: =>
			if @state.focus.parent?
				@setState({focus: @state.focus.parent})
				return true
			return false
		descendCallback: =>
			if @state.focus.subtrees.length
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
		onBlur: (e) =>
			if e.relatedTarget is null
				@setState({focus: null})

		root: @state.root
		focus: @state.focus

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
		return @transferPropsTo ra.div
			className: 'circle',
			style: {
				position: 'absolute'
				left: @props.left
				borderRadius: @props.radius
				width: 2 * @props.radius
				height: 2 * @props.radius
				backgroundColor: backgroundColor
				textAlign: 'center'
			}
			onClick: (e) =>
				e.currentTarget.children[0].focus()
			onKeyDown: (e) =>
				switch e.key
					when 'Enter'
						if e.shiftKey
							@props.addChildCallback()
						else
							if not @props.descendCallback()
								if not @props.rightSiblingCallback()
									@props.addChildCallback()
					when 'Escape' then @props.ascendCallback()
					when 'Tab'
						e.preventDefault()
						if e.shiftKey
							@props.addSiblingCallback()
						else
							if not @props.rightSiblingCallback()
								@props.addSiblingCallback()
					when 'ArrowDown' then @props.descendCallback()
					when 'ArrowUp' then @props.ascendCallback()
					when 'ArrowRight'
						e.preventDefault()
						@props.rightSiblingCallback()
					when 'ArrowLeft'
						e.preventDefault()
						@props.leftSiblingCallback()
					when 'Backspace'
						if e.shiftKey
							e.preventDefault()
							if not @props.leftSiblingCallback()
								@props.ascendCallback()
						if not @props.children
							@props.deleteCallback()

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
	getRadiusFromValue: (value) ->
		test = document.getElementById('textTest')
		test.innerHTML = value
		return Math.max((test.clientWidth + 5) / 2, 15)
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
		startX: @getCircleOffset() + @getRadiusFromValue(@props.root.value)
		startY: @getRadiusFromValue(@props.root.value)
		endX: @props.parentWidth / 2 - @props.offset
		endY: @props.parentRadius - @props.verticalOffset

	getCircleOffset: -> @getThisWidth() / 2 - @getRadiusFromValue(@props.root.value)

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
			Line
				width: '2px'
				color: '#000000'
				startX: @getLineValues().startX
				startY: @getLineValues().startY
				endX: @getLineValues().endX
				endY: @getLineValues().endY
			Circle
				left: @getCircleOffset()
				radius: @getRadiusFromValue(@props.root.value)
				changeCallback: @props.changeCallback
				addChildCallback: @props.addChildCallback
				addSiblingCallback: @props.addSiblingCallback
				ascendCallback: @props.ascendCallback
				descendCallback: @props.descendCallback
				rightSiblingCallback: @props.rightSiblingCallback
				leftSiblingCallback: @props.leftSiblingCallback
				deleteCallback: @props.deleteCallback
				onFocus: =>
					@props.focusCallback @props.root
				hasFocus: hasFocus
			, @props.root.value
			ra.ul null,
				for subtree in @props.root.subtrees
					offset += @getWidth(subtree)
					focusCallback = @props.focusCallback
					TreeNode
						changeCallback: @props.changeCallback
						addChildCallback: @props.addChildCallback
						addSiblingCallback: @props.addSiblingCallback
						focusCallback: @props.focusCallback
						ascendCallback: @props.ascendCallback
						descendCallback: @props.descendCallback
						rightSiblingCallback: @props.rightSiblingCallback
						leftSiblingCallback: @props.leftSiblingCallback
						deleteCallback: @props.deleteCallback
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

$(document).ready ->
	mockData.callback()
