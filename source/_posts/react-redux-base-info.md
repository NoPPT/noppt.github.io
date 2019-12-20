---
title: React Redux 基础概念
date: 2017-2-21 17:38:56
tags:
  - React
categories: 前端
---

### Redux

随着 JavaScript 单页应用开发日趋复杂，JavaScript 需要管理比任何时候都要多的 state （状态）。
这些 state 可能包括服务器响应、缓存数据、本地生成尚未持久化到服务器的数据，也包括 UI 状态，如激活的路由，被选中的标签，是否显示加载动效等等。state 在什么时候，由于什么原因，如何变化已然不受控制。前端开发越来越复杂。

#### 基础

##### 1. Action

Action 是把数据从应用传到 store 的有效载荷。它是 store 数据的唯一来源。一般来说你会通过`store.dispatch()`将 action 传到 store。Action 本质上就是 JavaScript 的普通对象。约定 action 内必须使用一个字符串类型 type 字段来表示将要执行的动作。多数情况下，type 会被定义成字符串常量。当应用规模变大时，建议使用单独的模块或者文件来存放 action。建议尽量减少在 action 中传递的数据。

<!-- more -->

```
{
	id: 0
   	type: 'ADD_TODO',
   	text: 'first action',
}
```

Action 创建函数 是生成 action 的方法，在 redux 中 action 创建函数只是简单的返回一个 action：

```
export const ADD_TODO = 'ADD_TODO';
function addTodo(text) {
	return {
   		type: ADD_TODO,
   		id: nextTodoId ++,
   		text
	}
};
```

Action 只是描述了有事情发生这一事实，并没有指明应用应该如何更新 state。而这正是 reducer 要做的事情。

##### 2. Reducer

在 reudx 中，所有的 state 都被存储在一个单一对象中，所以写代码之前，需要我们先想一下这个对象的结构，尽可能的把 state 范式化，不存在嵌套。
Redux 就是一个纯函数，接收旧的 state 和 action，返回新的 state。`(previousState, action) => newState`

```
function todos(state = [], action) {
 	switch (action.type) {
   		case types.ADD_TODO: //不要修改 state，这里使用对象展开运算符，新建了一个副本。
       		return [
           		...state,
           		{
					id: action.id,
           			text: action.text
       			}
       		];

       		...

   		default: //在 default 情况下返回旧的 state。否则在未知情况下会返回 undefined。
       		return state
 	}
}
```

注意，不要在 reducer 里做这些操作：

1. 修改传入参数；
2. 执行有副作用的操作，如 API 请求和路由跳转；
3. 调用非纯函数，如 `Date.now()` 或 `Math.random()`。
   reducer 一定要保持纯净，只要传入参数相同，返回计算得到的下一个 state 就一定相同。没有特殊情况、没有副作用，没有 API 请求、没有变量修改，单纯执行计算。

随着需要处理的 action 增多，单个 reducer 也变得越来越冗长，这个时候我们可以拆分 reducer 把一些相互独立的业务逻辑拆分出来，让每个 reducer 只负责管理全局 state 中它负责的一部分。每个 reducer 的 state 参数都不同，分别对应它管理的那部分 state 数据。使用`combineReducers()`工具类，这个函数来调用你的一系列 reducer，每个 reducer 根据它们的 key 来筛选出 state 中的一部分数据并处理，然后这个生成的函数再将所有 reducer 的结果合并成一个大的对象。

```
//1
import { combineReducers } from 'redux';
import todos from './todos';
import visibilityFilter from './visibilityFilter';
export default combineReducers({
	todos,
	visibilityFilter
});

//2
export default function todoApp(state = {}, action) {
	return {
		visibilityFilter: visibilityFilter(state.visibilityFilter, action),
		todos: todos(state.todos, action)
	}
}

//3
const reducer = combineReducers({
	a: doSomethingWithA,
	b: processB,
	c: c
})

//4
function reducer(state = {}, action) {
	return {
		a: doSomethingWithA(state.a, action),
		b: processB(state.b, action),
		c: c(state.c, action)
	}
}

//5
在ES6中，可以把所有顶级的 reducer 放到一个独立的文件中，通过 export 暴露出每个 reducer 函数，然后使用 import * as reducers 得到一个以它们名字作为 key 的 object。

import * as reducers from './reducers'
const todoApp = combineReducers(reducers)
```

> 纯函数
> 在计算机编程中，假如满足下面这两个句子的约束，一个函数可能被描述为一个纯函数：
>
> 1.  给出同样的参数值，该函数总是求出同样的结果。该函数结果值不依赖任何隐藏信息或程序执行处理可能改变的状态或在程序的两个不同的执行，也不能依赖来自 I/O 装置的任何外部的输入（通常是这样的--看下面的描述）。
> 2.  结果的求值不会促使任何可语义上可观察的副作用或输出，例如易变对象的变化或输出到 I/O 装置。
>     该结果值不需要依赖所有（或任何）参数值。然而，必须不依赖参数值以外的东西。函数可能返回多重结果值，并且对于被认为是纯函数的函数，这些条件必须应用到所有返回值。假如一个参数通过引用调用，任何内部参数变化将改变函数外部的输入参数值，它将使函数变为非纯函数。

##### 3. Store

Store 就是把 action 和 reducer 联系到一起的对象

1. 维持应用的 `state`；
2. 提供 `getState()` 方法获取 `state`；
3. 提供 `dispatch(action)` 方法更新 `state`；
4. 通过 `subscribe(listener)` 注册监听器;
5. 通过 `subscribe(listener)` 返回的函数注销监听器。

创建一个 `store` 的方法

```
import { createStore, applyMiddleware } from 'redux';
import todoApp from '../reducers';

export const store = createStore(todoApp, '这个参数传初始 state，如果不需要就不传');

//如何使用
console.log(store.getState()); //打印 store 的状态
let unsubscribe = store.subscribe(() => { //每次更新的时候都会调用这里，同时subscribe()返回的是一个函数，用于注销监听器。
    console.log(store.getState());
});

store.dispatch(addTodo('Learn about actions'));

unsubscribe(); //停止监听 state 更新
```

#### 总结

Redux 应用中数据的生命周期遵循下面 4 个步骤：

1. 调用 `store.dispatch(action)`。
2. Redux store 调用传入的 reducer 函数。
3. 根 reducer 应该把多个子 reducer 输出合并成一个单一的 state 树。
4. Redux store 保存了根 reducer 返回的完整 state 树。

![](http://note.youdao.com/yws/public/resource/8554541642d2f883da8a6639b9fe46bc/WEBRESOURCEe6ffa2706e5da603afd3b94159d4a7f0)

#### 三大原则

##### 1. 单一数据源

整个应用的 state 被存储在一颗 object tree 中，并且这个 object tree 只存在于惟一一个 store 中。

##### 2. state 是只读的

惟一改变 state 的方法是触发 action，action 是一个用于描述已发生事件的普通对象。

##### 3. 使用纯函数来执行修改

为了描述 action 如何修改 state store，你需要编写 reducer。

---

#### 实践

##### 1. 处理异步 Action

当调用异步 API 时，发起请求的时刻，和接收到响应的时刻，可能会更改 state，因此，需要 dispatch 普通的同步 action。一般情况下需要 dispatch 三种 action：

1. 一种通知 reducer 请求开始的 action
2. 一种通知 reducer 请求成功的 action
3. 一种通知 reducer 请求失败的 action
   首先我们需要按照同步的顺序，设计好 state，action，reducer，然后编写 action 创建函数，由于是异步请求，我们需要使用 redux-thunk（redux-promise, redux-promise-middleware, 自定义）这个专门的库才能使用，通过使用指定的 middleware，action 创建函数除了返回 action 对象外，还可以返回函数。

```
import {createStore, applyMiddleware} from 'redux';
import thunkMiddleware from 'redux-thunk';
import todoApp from '../reducers';

const createStoreWithMiddleware = applyMiddleware(thunkMiddleware)(createStore);
export const store = createStoreWithMiddleware(todoApp);
```

##### 2. Middleware

middleware 是发送 action 和 action 到达 reducer 之间的第三方扩展，也就是中间层。也可以这样说，middleware 是架在 action 和 store 之间的一座桥梁。
![](http://note.youdao.com/yws/public/resource/8554541642d2f883da8a6639b9fe46bc/WEBRESOURCEb7ab136b2ab90bd74fd96fadfb1fd879)

[0]: https://www.w3ctech.com/topic/1561
[1]: http://react-china.org/t/redux/2687
[2]: https://github.com/camsong/redux-in-chinese
[3]: http://redux.js.org
[4]: https://github.com/gaearon/redux-thunk
