(function(){var BaobabTree,Circle,Line,React,Rectangle,Square,TreeLabel,TreeNode,TreeState,Triangle,id,ra,treeStateFromJSON,__bind=function(fn,me){return function(){return fn.apply(me,arguments)}};React=require("react");ra=React.DOM;treeStateFromJSON=function(string){var simpleObject,treeStateFromSimpleObject;simpleObject=JSON.parse(string);treeStateFromSimpleObject=function(simpleObject,parent){var newTree,subObject,_i,_len,_ref;if(parent==null){parent=null}newTree=new TreeState({value:simpleObject.value,parent:parent,type:simpleObject.type});newTree.id=simpleObject.id;newTree.mutator().setCollapsed(simpleObject.collapsed);_ref=simpleObject.subtrees;for(_i=0,_len=_ref.length;_i<_len;_i++){subObject=_ref[_i];newTree.subtrees.push(treeStateFromSimpleObject(subObject,newTree))}return newTree};return treeStateFromSimpleObject(simpleObject)};id=0;TreeState=function(){function TreeState(_arg){this.value=_arg.value,this.parent=_arg.parent,this.type=_arg.type;this.mutator=__bind(this.mutator,this);this.subtrees=[];this.id=""+id;id+=1;this.collapsed=false;this.width=null}TreeState.prototype.mutator=function(){return{setCollapsed:function(_this){return function(newValue){var subtree,_i,_len,_ref;_this.collapsed=newValue;if(newValue===false){_ref=_this.subtrees;for(_i=0,_len=_ref.length;_i<_len;_i++){subtree=_ref[_i];subtree.mutator().setCollapsed(false)}}_this.soil()}}(this),setValue:function(_this){return function(newValue){_this.value=newValue;_this.soil()}}(this),addSubTree:function(_this){return function(value,sibling,relation,type){var insertIndex,newTree;if(sibling==null){sibling=null}if(relation==null){relation=null}if(type==null){type=null}if(sibling!=null){if(relation==="right"){insertIndex=_this.subtrees.indexOf(sibling)}if(relation==="left"){insertIndex=_this.subtrees.indexOf(sibling)+1}}else{insertIndex=_this.subtrees.length}if(type==null){type=_this.type}newTree=new TreeState({value:value,parent:_this,type:type});_this.subtrees.splice(insertIndex,0,newTree);_this.soil();return newTree}}(this),deleteSubTree:function(_this){return function(subtree){var indexToDelete;indexToDelete=_this.subtrees.indexOf(subtree);if(indexToDelete!=null){_this.subtrees.splice(indexToDelete,1)}return _this.soil()}}(this),collapseYouth:function(_this){return function(nearNess){var subtree,_i,_len,_ref;if(!_this.subtrees.length){return true}if(nearNess<0){_this.mutator().setCollapsed(true);return true}_ref=_this.subtrees;for(_i=0,_len=_ref.length;_i<_len;_i++){subtree=_ref[_i];subtree.mutator().collapseYouth(nearNess-1)}return true}}(this)}};TreeState.prototype.getCollapsed=function(){if(!this.subtrees.length){this.collapsed=false;return false}if(this.collapsed){return true}};TreeState.prototype.getWidth=function(){var subtree,total,_i,_len,_ref;if(this.width!=null){return this.width}this.width=this.getLabelWidth()+4;if(this.collapsed){return this.width}total=0;_ref=this.subtrees;for(_i=0,_len=_ref.length;_i<_len;_i++){subtree=_ref[_i];total+=subtree.getWidth()}if(total>this.width){this.width=total}return this.width};TreeState.prototype.getNearerAncestor=function(ancestor,nearNess){if(this.parent==null){return this}if(ancestor===this){return ancestor}if(nearNess===0){return this}return this.parent.getNearerAncestor(ancestor,nearNess-1)};TreeState.prototype.soil=function(){this.width=null;if(this.parent!=null){return this.parent.soil()}};TreeState.prototype.getLabelWidth=function(){return Math.max(this.value.length*4+1,16)*2};TreeState.prototype.getLabelHeight=function(){switch(this.type){case"rectangle":return 25;case"circle":return this.getLabelWidth();case"triangle":return this.getLabelWidth();case"square":return this.getLabelWidth()}};TreeState.prototype.toJSON=function(){var toSimpleObject;toSimpleObject=function(tree){var subtree;return{value:tree.value,subtrees:function(){var _i,_len,_ref,_results;_ref=tree.subtrees;_results=[];for(_i=0,_len=_ref.length;_i<_len;_i++){subtree=_ref[_i];_results.push(toSimpleObject(subtree))}return _results}(),collapsed:tree.collapsed,id:tree.id,type:tree.type}};return JSON.stringify(toSimpleObject(this))};return TreeState}();Line=React.createClass({getAngle:function(){var deltaX,deltaY,theta;deltaX=this.props.endX-this.props.startX;deltaY=this.props.endY-this.props.startY;theta=function(){switch(false){case!(deltaX<0&&deltaY<0):return Math.atan(deltaY/deltaX)+Math.PI;case!(deltaX>0&&deltaY<0):return Math.atan(deltaY/deltaX);default:return Math.atan(deltaY/deltaX)}}();return 180/Math.PI*theta},render:function(){var angle,left,length,top;angle=this.getAngle();left=this.props.startX;top=this.props.startY;length=Math.sqrt(Math.pow(Math.abs(this.props.startX-this.props.endX),2)+Math.pow(Math.abs(this.props.startY-this.props.endY),2));return this.transferPropsTo(ra.div({className:"line",style:{width:length,height:this.props.width,"-ms-transform-origin":"0% 0%","-webkit-transform-origin":"0% 0%","-moz-transform-origin":"0% 0%","transform-origin":"0% 0%","-ms-transform":"rotate("+angle+"deg)","-webkit-transform":"rotate("+angle+"deg)","-moz-transform":"rotate("+angle+"deg)",transform:"rotate("+angle+"deg)","background-color":this.props.color,left:""+left+"px",top:""+top+"px",position:"absolute",zIndex:-1}}))}});Circle=React.createClass({displayName:"Circle",render:function(){return this.transferPropsTo(ra.div({className:"label",style:{position:"absolute",left:this.props.left,borderRadius:this.props.width/2,width:this.props.width,height:this.props.width}},this.props.children))}});Rectangle=React.createClass({displayName:"Rectangle",render:function(){return this.transferPropsTo(ra.div({className:"label",style:{position:"absolute",left:this.props.left,borderRadius:5,width:this.props.width,height:this.props.height}},this.props.children))}});Triangle=React.createClass({displayName:"Triangle",render:function(){return this.transferPropsTo(ra.div({className:"label",style:{position:"absolute",left:this.props.left,width:this.props.width,height:this.props.height}},this.props.children))}});Square=React.createClass({displayName:"Square",render:function(){return this.transferPropsTo(ra.div({className:"label",style:{position:"absolute",left:this.props.left,width:this.props.width,height:this.props.width}},this.props.children))}});TreeLabel=React.createClass({displayName:"TreeLabel",componentDidMount:function(){return this.componentDidUpdate()},componentDidUpdate:function(){if(this.props.hasFocus){return this.getDOMNode().children[0].focus()}},render:function(){var backgroundColor,comp;backgroundColor=function(){switch(false){case!(this.props.hasFocus&&this.props.collapsed):return"#8c8";case!this.props.hasFocus:return"#afa";case!this.props.collapsed:return"#888";default:return"#fff"}}.call(this);comp=function(){switch(this.props.type){case"circle":return Circle;case"rectangle":return Rectangle;case"triangle":return Triangle;case"square":return Square}}.call(this);return this.transferPropsTo(comp({style:{position:"absolute",left:this.props.left,backgroundColor:backgroundColor,textAlign:"center"},onClick:function(_this){return function(e){return e.currentTarget.children[0].focus()}}(this),onKeyDown:function(_this){return function(e){var ctrl,meta,shift;shift=e.shiftKey;ctrl=e.ctrlKey;meta=e.metaKey;switch(false){case!(e.key==="Enter"&&shift):return _this.props.cb.setHeadCallback();case!(e.key===" "&&shift):e.preventDefault();return _this.props.cb.toggleElectivelyCollapsedCallback();case e.key!=="Backspace":if(shift){e.preventDefault();return _this.props.cb.forceDeleteCallback()}else{if(!_this.props.children){e.preventDefault();return _this.props.cb.deleteCallback()}}break;case e.key!=="Enter":e.preventDefault();return _this.props.cb.addChildCallback();case e.key!=="Tab":e.preventDefault();return _this.props.cb.addRightSiblingCallback();case e.key!=="Escape":e.preventDefault();if(!_this.props.cb.ascendCallback()){return _this.props.cb.addParentCallback()}break;case!(shift&&e.key==="ArrowLeft"):e.preventDefault();if(meta){return _this.props.cb.addLeftSiblingCallback()}else{return _this.props.cb.leftSiblingCallback()}break;case!(shift&&e.key==="ArrowRight"):e.preventDefault();if(meta){return _this.props.cb.addRightSiblingCallback()}else{return _this.props.cb.rightSiblingCallback()}break;case!(shift&&e.key==="ArrowDown"):e.preventDefault();if(meta){return _this.props.cb.addChildCallback()}else{return _this.props.cb.descendCallback()}break;case!(shift&&e.key==="ArrowUp"):if(meta){return _this.props.cb.addParentCallback()}else{e.preventDefault();return _this.props.cb.ascendCallback()}}}}(this)},ra.input({type:"text",value:this.props.children,style:{display:"table-cell",width:this.props.width-5,textAlign:"center",marginTop:this.props.height/2-7,border:"none",backgroundColor:backgroundColor},onChange:function(_this){return function(e){var newValue;newValue=e.currentTarget.value;return _this.props.cb.changeCallback(newValue)}}(this)})))}});TreeNode=React.createClass({getDefaultProps:function(){return{left:0,top:0,showEtc:false,collapsed:false}},getLineValues:function(){return{startX:this.getCenter().x,startY:this.getCenter().y,endX:this.props.root.parent!=null?this.props.root.parent.getWidth()/2-this.props.left:void 0,endY:this.props.root.parent!=null?this.props.root.parent.getLabelHeight()/2-this.props.top:void 0}},getCenter:function(){return{x:this.props.root.getWidth()/2,y:this.props.root.getLabelHeight()/2}},render:function(){var hasFocus,leftAccumulator,subtree;if(this.props.focus!=null){hasFocus=this.props.focus.id===this.props.root.id}else{hasFocus=false}return this.transferPropsTo(ra.li({style:{position:"absolute",top:this.props.top,left:this.props.left,width:""+this.props.root.getWidth()+"px"}},this.props.root.parent!=null?!this.props.showEtc?Line({width:"2px",color:"#000000",startX:this.getLineValues().startX,startY:this.getLineValues().startY,endX:this.getLineValues().endX,endY:this.getLineValues().endY}):Line({width:"2px",color:"#aaa",startX:this.getLineValues().startX,startY:this.getLineValues().startY,endX:this.getLineValues().startX,endY:-20}):void 0,TreeLabel({type:this.props.root.type,left:this.getCenter().x-this.props.root.getLabelWidth()/2,width:this.props.root.getLabelWidth(),height:this.props.root.getLabelHeight(),hasFocus:hasFocus,collapsed:this.props.root.getCollapsed(),cb:this.props.cb,onFocus:function(_this){return function(){return _this.props.cb.focusCallback(_this.props.root)}}(this)},this.props.root.value),ra.ul(null,function(){var _i,_len,_ref,_results;if(!this.props.root.getCollapsed()){leftAccumulator=0;_ref=this.props.root.subtrees;_results=[];for(_i=0,_len=_ref.length;_i<_len;_i++){subtree=_ref[_i];leftAccumulator+=subtree.getWidth();_results.push(TreeNode({root:subtree,focus:this.props.focus,key:subtree.id,left:leftAccumulator-subtree.getWidth(),top:20+this.props.root.getLabelHeight(),maxDepth:this.props.maxDepth-1,cb:this.props.cb}))}return _results}}.call(this))))}});BaobabTree=React.createClass({getInitialState:function(){return{root:this.props.initialRoot,focus:this.props.initialRoot,head:this.props.initialRoot,textSetter:this.props.textSetter,type:"circle",maxAncestor:6}},componentWillReceiveProps:function(nextProps){if(nextProps.initialRoot!=null){this.setState({root:nextProps.initialRoot,focus:nextProps.initialRoot,head:nextProps.initialRoot})}if(nextProps.type!=null){this.setState({type:nextProps.type})}if(nextProps.maxAncestor!=null){this.setState({maxAncestor:nextProps.maxAncestor})}if(nextProps.textSetter!=null){return this.setState({textSetter:nextProps.textSetter})}},componentDidUpdate:function(){if(this.state.textSetter!=null){return this.state.textSetter(this.state.root.toJSON())}},setHeadAndCollapseYouth:function(focus,head){if(focus==null){focus=null}if(head==null){head=null}if(focus==null){focus=this.state.focus}if(head==null){head=this.state.head}head.mutator().collapseYouth(this.state.maxAncestor);return this.setState({head:focus.getNearerAncestor(head,this.state.maxAncestor)})},render:function(){return ra.div({style:{position:"relative"}},TreeNode({cb:{changeCallback:function(_this){return function(newValue){if(_this.state.focus!=null){_this.state.focus.mutator().setValue(newValue);_this.setState({focus:_this.state.focus});return true}return false}}(this),toggleElectivelyCollapsedCallback:function(_this){return function(){if(_this.state.focus.getCollapsed()){_this.state.focus.mutator().setCollapsed(false)}else{_this.state.focus.mutator().setCollapsed(true)}return _this.setState({focus:_this.state.focus})}}(this),addChildCallback:function(_this){return function(){var newTree;newTree=_this.state.focus.mutator().addSubTree("",null,null,_this.state.type);_this.setState({focus:newTree});_this.setHeadAndCollapseYouth();return true}}(this),addParentCallback:function(_this){return function(){var newTree;if(_this.state.focus.parent==null){newTree=new TreeState({value:"",type:_this.state.type});newTree.subtrees.push(_this.state.root);_this.state.root.parent=newTree;_this.setHeadAndCollapseYouth(newTree,newTree);return _this.setState({root:newTree,focus:newTree,head:newTree})}}}(this),addLeftSiblingCallback:function(_this){return function(){var newTree;if(_this.state.focus!==_this.state.head){newTree=_this.state.focus.parent.mutator().addSubTree("",_this.state.focus,"right",_this.state.type);_this.setState({focus:newTree});return true}return false}}(this),addRightSiblingCallback:function(_this){return function(){var newTree;if(_this.state.focus!==_this.state.head){newTree=_this.state.focus.parent.mutator().addSubTree("",_this.state.focus,"left",_this.state.type);_this.setState({focus:newTree});return true}return false}}(this),focusCallback:function(_this){return function(newFocus){_this.setState({focus:newFocus});_this.setHeadAndCollapseYouth(newFocus);return true}}(this),setHeadCallback:function(_this){return function(){if(_this.state.focus.getCollapsed()){_this.state.focus.mutator().setCollapsed(false)}return _this.setState({head:_this.state.focus})}}(this),ascendCallback:function(_this){return function(){var focus,head;if(_this.state.focus.parent!=null){if(_this.state.focus===_this.state.head){head=_this.state.head.parent}else{head=_this.state.head}focus=_this.state.focus.parent;_this.setState({focus:focus,head:head});_this.setHeadAndCollapseYouth(focus,head);return true}return false}}(this),descendCallback:function(_this){return function(){if(_this.state.focus.subtrees.length){if(_this.state.focus.getCollapsed()){_this.state.focus.mutator().setCollapsed(false)}_this.setState({focus:_this.state.focus.subtrees[0]});_this.setHeadAndCollapseYouth();return true}return false}}(this),rightSiblingCallback:function(_this){return function(){var oldIndex;if(_this.state.focus!==_this.state.head){oldIndex=_this.state.focus.parent.subtrees.indexOf(_this.state.focus);if(_this.state.focus.parent.subtrees.length>oldIndex+1){_this.setState({focus:_this.state.focus.parent.subtrees[oldIndex+1]});return true}}return false}}(this),leftSiblingCallback:function(_this){return function(){var oldIndex;if(_this.state.focus!==_this.state.head){oldIndex=_this.state.focus.parent.subtrees.indexOf(_this.state.focus);if(oldIndex>0){_this.setState({focus:_this.state.focus.parent.subtrees[oldIndex-1]});return true}}return false}}(this),deleteCallback:function(_this){return function(){var focus,oldIndex,parent;if(_this.state.focus!==_this.state.root&&!_this.state.focus.subtrees.length){focus=_this.state.focus;parent=_this.state.focus.parent;oldIndex=parent.subtrees.indexOf(focus);if(oldIndex>0){_this.setState({focus:parent.subtrees[oldIndex-1]})}else{_this.setState({focus:parent})}parent.mutator().deleteSubTree(focus);return true}return false}}(this),forceDeleteCallback:function(_this){return function(){var focus,subtree,_i,_len,_ref;focus=_this.state.focus;_ref=_this.state.focus.subtrees;for(_i=0,_len=_ref.length;_i<_len;_i++){subtree=_ref[_i];focus.mutator().deleteSubTree(subtree)}_this.setState({focus:focus});return true}}(this)},onBlur:function(_this){return function(e){if(e.relatedTarget===null){return _this.setState({focus:null})}}}(this),showEtc:this.state.head!==this.state.root,focus:this.state.focus,root:this.state.head,maxDepth:this.state.maxAncestor}))}});module.exports={BaobabTreeState:TreeState,BaobabTree:BaobabTree,treeStateFromJSON:treeStateFromJSON}}).call(this);