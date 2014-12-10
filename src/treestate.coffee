makeid = (size=5) ->
    possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    text = (possible.charAt(Math.floor(Math.random() * possible.length)) for num in [1..size])
    return text.join()

class TreeState
    @fromJSON: (string, newIDs=false) ->
        simpleObject = JSON.parse(string)
        treeStateFromSimpleObject = (simpleObject, parent = null) ->
            newTree = new TreeState
                value: simpleObject.value
                parent: parent
                type: simpleObject.type
            newTree.id = simpleObject.id
            if newIDs
                newTree.id = makeid()
            newTree.mutator().setCollapsed simpleObject.collapsed
            for subObject in simpleObject.subtrees
                newTree.subtrees.push treeStateFromSimpleObject(subObject, newTree)
            return newTree
        return treeStateFromSimpleObject simpleObject
    constructor: ({@value, @parent, @type}) ->
        @subtrees = []
        @id = "#{makeid()}"
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
        setType: (newType) =>
            @type = newType        
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
        addSubTreeExisting: (tree) =>
            @subtrees.push(tree)
            tree.parent = this
            @soil()
        removeChildren: =>
            @subtrees = []
            @soil()
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
        removeSelfFromChain: =>
            if @subtrees.length != 1
                return false
            if not @parent?
                return false

            child = @subtrees[0]
            @parent.mutator().deleteSubTree(this)
            @parent.mutator().addSubTreeExisting(child)
            return true
        orphan: =>
            @parent = null

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
    getTextWidth: ->
        lineLengths = [line.length for line in @value.split('\n')][0]
        maxLineLength = Math.max.apply(null, lineLengths)
        return Math.max(maxLineLength * 7, 1)
    getTextHeight: ->
        numLines = @value.split('\n').length
        return numLines * 14
    getLabelWidth: ->
        return switch @type
            when 'rectangle' then @getTextWidth() + 10
            when 'circle' then Math.max(@getTextWidth(), @getTextHeight()) * Math.sqrt(2)
            when 'square' then Math.max(@getTextWidth() + 10, @getTextHeight() + 10)
            when 'triangle' then Math.max(@getTextWidth(), @getTextHeight()) * ( 1 + 2*Math.sqrt(3)/3)
    getLabelHeight: ->
        return switch @type
            when 'rectangle' then @getTextHeight() + 10
            when 'circle' then Math.max(@getTextWidth(), @getTextHeight()) * Math.sqrt(2)
            when 'square' then Math.max(@getTextWidth() + 10, @getTextHeight() + 10)
            when 'triangle' then Math.max(@getTextWidth(), @getTextHeight()) * ( 1 + Math.sqrt(2)/2)
    copy: ->
        return TreeState.fromJSON(@toJSON(), newIDs=true)
    toJSON: ->
        toSimpleObject = (tree) ->
            value: tree.value
            subtrees: toSimpleObject(subtree) for subtree in tree.subtrees
            collapsed: tree.collapsed
            id: tree.id
            type: tree.type
        return JSON.stringify toSimpleObject this

module.exports = TreeState
