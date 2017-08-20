assert = require 'assert'
import { Queue, Stack, List } from '../lib/data-structures'

describe "List", ->
	it "is an ABSTRACT linked list", ->
		assert.equal (typeof List::pop), 'function'
	it "does not define push", ->
		assert.equal (typeof List::push), 'undefined'

describe "Queue", ->
	it "is a kind of List", ->
		assert.equal Queue::pop, List::pop
		assert.equal (typeof Queue::push), 'function'
	it "pushes on to the end", ->
		q = new Queue()
		q.push 1
		q.push 2
		assert.equal q.pop(), 1
		assert.equal q.pop(), 2
		assert.equal q.length, 0

describe "Stack", ->
	it "is a kind of List", ->
		assert.equal Stack::pop, List::pop
		assert.equal (typeof Stack::push), 'function'
	it "pushes on to the front", ->
		s = new Stack()
		s.push 1
		s.push 2
		assert.equal s.pop(), 2
		assert.equal s.pop(), 1
		assert.equal s.length, 0
