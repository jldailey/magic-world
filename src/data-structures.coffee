$ = require "bling"

class ListNode # just to avoid using anonymous objects
	constructor: (@value, @next) ->

_export = (klass) -> module.exports[klass.name] = klass

_export class ObjectPool
	constructor: (klass, capacity, grow=true, reconstruct=true) ->
		@length = parseInt(capacity)
		start = $.now
		pool = new Array @length
		for i in [0...@length] by 1
			pool[i] = Object.assign new klass(), poolId: i
		freeList = $.range(0, @length).toArray()
		console.log "[ObjectPool] creating pool of #{$.commaize @length} #{klass.name} objects took #{$.now - start}ms"
		Object.assign @,
			alloc: (args...) =>
				if freeList.length is 0
					if not grow
						return null # no room at the inn
					else
						start = $.now
						n = 1000
						for i in [0...n] by 1
							freeList.push @length+i
						@length += n
						console.log "[ObjectPool] growing pool of #{klass.name} to #{$.commaize @length} took #{$.now - start}ms"
				i = freeList.pop()
				if pool[i]? and reconstruct
					console.log "[ObjectPool] reconstructing", args
					klass.apply pool[i], args
				return pool[i]
			free: (obj) =>
				if 0 <= obj.poolId < pool.length
					freeList.push obj.poolId
				null

# A Class decorator version of ObjectPool
module.exports.Pooled = (klass) ->
	pool = new ObjectPool klass, 10
	klass.alloc = -> pool.alloc.apply pool, arguments
	klass::free = -> pool.free @

# Creating pool of nodes for List, Queue, Stack...
listNodes = new ObjectPool(ListNode, 11, true)

_export class List
	constructor: (iterable) ->
		@length = 0
		@head = @tail = null
		@push item for item in iterable ? []
	pop: ->
		ret = undefined
		if h = @head
			ret = h.value
			@head = h.next
			@length -= 1
			listNodes.free h
		ret
	each: (f) ->
		item = @head
		while item
			f item.value
			item = item.next
		@
	concat: (items) ->
		if $.is List, items
			if not @head
				@head = items.head
				@tail = items.tail
			else
				@tail.next = items.head
				@tail = items.tail

_export class Stack extends List
	peek: -> @head?.value
	push: (item) ->
		cur = @head
		Object.assign @head = listNodes.alloc(),
			value: item
			next: cur 
		@length += 1

_export class Queue extends List
	peek: -> @tail?.value
	push: (item) ->
		Object.assign node = listNodes.alloc(),
			value: item
			next: null
		if @head
			@tail = @tail.next = node
		else
			@head = @tail = node
		@length += 1

class IndexedQueue extends Queue
	class QueryCache extends Queue
		constructor: (@query) -> super()
		push: (item) -> # only push if matches
			($.matches @query, obj) and super(item)
		pop: (item) -> # only pop if matches
			(@head?.value is item) and  super()
		toQueue: ->
			Object.assign Object.create(Queue::), {
				@head, @tail, @length
			}
	constructor: ->
		super()
		@indexes = []
	push: (item) ->
		super(item)
		for index in @indexes
			index.push item
	pop: ->
		item = super()
		for index in @indexes
			index.pop item
	ensureIndex: (query) ->
		@indexes.push cache = new QueryCache(query)
		@each (item) -> if $.matches query, item then cache.push item
	equal = (a, b) ->
		for k,v of a when b[k] isnt v
			return false
		return true
	find: (query) ->
		for index in @indexes when equal index.query, query
			return index.toQueue()

#define LEFT(i)  (2*i+1)
#define RIGHT(i) (2*i+2)
#define PARENT(i) ((i-1)/2)
_export class Heap
	constructor: (@capacity, @score = (x) -> x?.nice ? 0 ) ->
		@clear()
	clear: ->
		@data = new Array(@capacity)
		@length = 0
	peek: -> @data[0]
	pop: -> @remove(0)
	remove: (i) ->
		if @length <= i
			return null
		ret = @data[i]
		@data[i] = @data[@length - 1]
		@data[@length - 1] = null
		@length -= 1
		@trickleDown(i)
		ret
	insert: (item) ->
		if @length is 0
			@data[0] = item
			@length++
		else if @length <= @capacity
			@data[n = @length++] = item
			@bubbleUp(n)
		else @.log "Heap ignoring insert because it's full...", item
		@
	trickleDown: (i) ->
		si = @score(@data[i])
		li = LEFT(i)
		sli = @score(@data[li])
		ri = RIGHT(i)
		sri = @score(@data[ri])
		if sri > sli < si
			SWAP(@data[li], @data[i])
			@trickleDown li
		else if sli > sri < si
			SWAP(@data[ri], @data[i])
			@trickleDown ri
	bubbleUp: (i) ->
		p = PARENT(i)
		while i > 0 and @score(@data[i]) < @score(@data[p])
			SWAP(@data[i], @data[p])
			i = p
			p = PARENT(i)
