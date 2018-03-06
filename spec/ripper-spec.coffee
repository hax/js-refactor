{ Ripper } = require '../lib/js_refactor'
{ Range } = require 'atom'
{ inspect } = require 'util'

expectNoRefs = (ripper, range) ->
  resultRanges = ripper.find range
  expect(resultRanges.length).toBe 0

expectEqualRefs = (ripper, ranges...) ->
  # console.log inspect ranges
  resultRanges = ripper.find ranges[0].start
  # console.log inspect resultRanges
  ranges.sort (a, b) ->
    return delta if (delta = a.start.row - b.start.row) isnt 0
    a.start.column - b.start.column
  resultRanges.sort (a, b) ->
    return delta if (delta = a.start.row - b.start.row) isnt 0
    a.start.column - b.start.column
  # expect(ranges).toEqual resultRanges
  expect(resultRanges.length).toBe ranges.length
  for resultRange, i in resultRanges
    expect(resultRange.start).toEqual ranges[i].start
    expect(resultRange.end).toEqual ranges[i].end

describe 'Ripper', ->

  ripper = new Ripper

  it 'should find refs in LF', ->
    ripper.parse "var a;\na = 100;"
    expectEqualRefs ripper,
      new Range([0, 4], [0, 5]),
      new Range([1, 0], [1, 1])

  it 'should find refs in CR', ->
    ripper.parse "var a;\ra = 100;"
    expectEqualRefs ripper,
      new Range([0, 4], [0, 5]),
      new Range([1, 0], [1, 1])

  it 'should find refs in CRLF', ->
    ripper.parse "var a;\r\na = 100;"
    expectEqualRefs ripper,
      new Range([0, 4], [0, 5]),
      new Range([1, 0], [1, 1])

  it 'should find refs in LFCR', ->
    ripper.parse "var a;\r\na = 100;"
    expectEqualRefs ripper,
      new Range([0, 4], [0, 5]),
      new Range([1, 0], [1, 1])

  it 'should support ES6 class', ->
    ripper.parse "class A {}\nnew A"
    expectEqualRefs ripper,
      new Range([0, 6], [0, 7]),
      new Range([1, 4], [1, 5])

  it 'should support ES6 const/let and ES7 **', ->
    ripper.parse "const a = 1\nlet b = a ** a"
    expectEqualRefs ripper,
      new Range([0, 6], [0, 7]),
      new Range([1, 8], [1, 9]),
      new Range([1, 13], [1, 14])

  xit 'should support ES2018 object rest spread', ->
    ripper.parse "const a = {b, ...c}\n;({b, ...a} = a)"
    expectEqualRefs ripper,
      new Range([0, 6], [0, 7]),
      new Range([1, 2], [1, 11]),
      new Range([1, 14], [1, 15]),

  it 'should support number separator proposal', ->
    ripper.parse "const a = 1_2_3\nlet b = a"
    expectEqualRefs ripper,
      new Range([0, 6], [0, 7]),
      new Range([1, 8], [1, 9]),

  xit 'should support type annotation', ->
    ripper.parse "type a = number\nx: a = 1"
    console.log(ripper.find([0, 5], [0, 6]))
    expectEqualRefs ripper,
      new Range([1, 4], [1, 5]),
      new Range([0, 5], [0, 6]),
    expectEqualRefs ripper,
      new Range([0, 5], [0, 6]),
      new Range([1, 4], [1, 5]),
