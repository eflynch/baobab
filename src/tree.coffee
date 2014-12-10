React = require('react')
ra = React.DOM

TreeState = require './treestate'
TreeNode = require './treenode'

Tree = React.createClass
    displayName: 'BaobabTree'
    onMutate: ->
        if @props.onChange?
            @props.onChange @state.root.toJSON()
        @forceUpdate()
    getInitialState: ->
        initialRoot = new TreeState {value: '', type: 'circle', onMutate: @onMutate}
        return {
            root: initialRoot
            focus: initialRoot
            head: initialRoot
            clipboard: null
            changed: true
            allFocus: true
        }
    getDefaultProps: ->
        maxAncestor: 6
        type: 'circle'
    componentWillMount: ->
        if @props.setRoot?
            @props.setRoot.setOnMutate @onMutate
            @setState
                root: @props.setRoot
                focus: @props.setRoot
                head: @props.setRoot
    componentWillReceiveProps: (nextProps) ->
        if nextProps.setRoot? and nextProps.setRoot != @state.root
            @props.setRoot.setOnMutate @onMutate
            @setState
                root: nextProps.setRoot
                focus: nextProps.setRoot
                head: nextProps.setRoot
        if nextProps.focusType? and @state.focus? and nextProps.focusType != @state.focus.type
            @callbacks().setTypeCallback nextProps.focusType
    setHeadAndCollapseYouth: (focus = null, head = null) ->
        focus ?= @state.focus
        head ?= @state.head
        head.mutator('collapseYouth') @props.maxAncestor
        @setState
            head: focus.getNearerAncestor(head, @props.maxAncestor)
    _deleteHelper: ->
        focus = @state.focus
        parent = @state.focus.parent
        head = @state.head

        if focus == head
            @setState({head: parent})
            head = parent

        oldIndex = parent.subtrees.indexOf(focus)
        if oldIndex > 0
            newFocus = parent.subtrees[oldIndex - 1]
        else
            newFocus = parent
        
        parent.mutator('deleteSubTree')(focus)
        @setState({focus: newFocus})
        @setHeadAndCollapseYouth newFocus, head
    callbacks: ->
        changeCallback: (newValue) =>
            if @state.focus?
                @state.focus.mutator('setValue') newValue
            return
        setTypeCallback: (newType) =>
            if @state.focus?
                @state.focus.mutator('setType') newType
            return
        toggleElectivelyCollapsedCallback: =>
            if @state.focus.getCollapsed()
                @state.focus.mutator('setCollapsed') false
            else
                @state.focus.mutator('setCollapsed') true
            @setHeadAndCollapseYouth()
            return
        addChildCallback: =>
            newTree = @state.focus.mutator('addSubTree')('', null, null, @props.type)
            @setState({focus: newTree})
            @setHeadAndCollapseYouth()
            return
        addParentCallback: =>
            if not @state.focus.parent?
                newTree = new TreeState
                    value: ''
                    type: @props.type
                    onMutate: @onMutate
                newTree.subtrees.push(@state.root)
                @state.root.parent = newTree
                @setHeadAndCollapseYouth newTree, newTree
                @setState
                    root: newTree
                    focus: newTree
                    head: newTree
        copyCallback: =>
            newTree = @state.focus.copy()
            @setState({clipboard: newTree})
            return
        pasteCallback: =>
            if @state.clipboard?
                @state.focus.mutator('addSubTreeExisting')(@state.clipboard.copy())
                @setHeadAndCollapseYouth()
            return
        addLeftSiblingCallback: =>
            if @state.focus != @state.head
                newTree = @state.focus.parent.mutator('addSubTree') '', @state.focus, 'right', @props.type
                @setState({focus: newTree})
            return
        addRightSiblingCallback: =>
            if @state.focus != @state.head
                newTree = @state.focus.parent.mutator('addSubTree') '', @state.focus, 'left', @props.type
                @setState({focus: newTree})
            return
        focusCallback: (newFocus) =>
            @setState({focus: newFocus})
            @setHeadAndCollapseYouth(newFocus)
            return
        setHeadCallback: =>
            if @state.focus.getCollapsed()
                @state.focus.mutator('setCollapsed') false
            @setState({head: @state.focus})
            return
        ascendCallback: =>
            if @state.focus.parent?
                if @state.focus == @state.head
                    head = @state.head.parent
                else
                    head = @state.head
                focus = @state.focus.parent
                @setState({focus: focus, head: head})
                @setHeadAndCollapseYouth focus, head
            return
        descendCallback: =>
            if @state.focus.subtrees.length
                if @state.focus.getCollapsed()
                    @state.focus.mutator('setCollapsed') false
                @setState({focus: @state.focus.subtrees[0]})
                @setHeadAndCollapseYouth()
            return
        rightSiblingCallback: =>
            if @state.focus != @state.head
                oldIndex = @state.focus.parent.subtrees.indexOf(@state.focus)
                if @state.focus.parent.subtrees.length > (oldIndex + 1)
                    @setState({focus: @state.focus.parent.subtrees[oldIndex + 1]})
            return
        leftSiblingCallback: =>
            if @state.focus != @state.head
                oldIndex = @state.focus.parent.subtrees.indexOf(@state.focus)
                if oldIndex > 0
                    @setState({focus: @state.focus.parent.subtrees[oldIndex - 1]})
            return
        deleteCallback: =>
            if @state.focus.subtrees.length > 1
                return

            if @state.focus.value != ''
                return

            if @state.focus.subtrees.length == 1
                focus = @state.focus
                parent = @state.focus.parent
                child = @state.focus.subtrees[0]
                head = @state.head

                newFocus = child

                if focus == @state.root
                    newRoot = child
                    newHead = child
                    child.mutator('orphan')()
                else
                    focus.mutator('removeSelfFromChain')()
                    newRoot = @state.root
                
                    if head == focus
                        newHead = child
                    else
                        newHead = head

                @setState
                    head: newHead
                    focus: newFocus
                    root: newRoot
                @setHeadAndCollapseYouth newFocus, newHead
                return
            if @state.focus != @state.root
                return @_deleteHelper()
        forceDeleteCallback: =>
            if @state.focus != @state.root
                return @_deleteHelper()

            @state.focus.mutator('removeChildren')()
            @setState
                head: @state.root
                focus: @state.root
                root: @state.root

    render: -> ra.div
            id: 'BAOBAB'
            style:
                position: 'relative'
            onFocus: =>
                @setState
                    allFocus: true
            onBlur: =>
                @setState
                    allFocus: false
        ,
            TreeNode
                keyHandler: (e) =>
                    shift = e.shiftKey
                    ctrl = e.ctrlKey
                    meta = e.metaKey
                    switch
                        when e.key == 'Enter' and ctrl
                            e.preventDefault()
                            @callbacks().setHeadCallback()
                        when e.key == ' ' and shift
                            e.preventDefault()
                            @callbacks().toggleElectivelyCollapsedCallback()
                        when e.key == 'Backspace'
                            if shift
                                e.preventDefault()
                                @callbacks().forceDeleteCallback()
                            else
                                @callbacks().deleteCallback()
                        when e.key == 'Enter' and (not shift)
                            e.preventDefault()
                            @callbacks().addChildCallback()
                        when e.key == 'Tab'
                            e.preventDefault()
                            @callbacks().addRightSiblingCallback()
                        when e.key == 'Escape'
                            e.preventDefault()
                            if not @callbacks().ascendCallback()
                                @callbacks().addParentCallback()
                        when (shift and e.key == 'ArrowLeft')
                            e.preventDefault()
                            if meta
                                @callbacks().addLeftSiblingCallback()
                            else
                                @callbacks().leftSiblingCallback()
                        when (shift and e.key == 'ArrowRight')
                            e.preventDefault()
                            if meta
                                @callbacks().addRightSiblingCallback()
                            else
                                @callbacks().rightSiblingCallback()
                        when (shift and e.key == 'ArrowDown')
                            e.preventDefault()
                            if meta
                                @callbacks().addChildCallback()
                            else
                                @callbacks().descendCallback()
                        when (shift and e.key == 'ArrowUp')
                            if meta
                                @callbacks().addParentCallback()
                            else
                                e.preventDefault()
                                @callbacks().ascendCallback()
                        when (ctrl and e.keyCode == 67)
                            @callbacks().copyCallback()
                        when (ctrl and e.keyCode == 86)
                            @callbacks().pasteCallback()

                focusCallback: @callbacks().focusCallback
                changeCallback: @callbacks().changeCallback
                onBlur: (e) =>
                    if @state.allFocus and e.relatedTarget is null
                        @setState({focus: null})
                    return
                showEtc: @state.head != @state.root
                focus: @state.focus
                allFocus: @state.allFocus
                root: @state.head
                maxDepth: @props.maxAncestor
                lineSpacing: 20

module.exports = React.createFactory Tree
