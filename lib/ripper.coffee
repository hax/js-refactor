Context = require './Context'
{ parse } = require './parser'
{ Range } = require 'atom'
{ locator } = require './util'
d = (require './debug') 'js-refactor:ripper'

module.exports =
class Ripper

  @locToRange: ({ start, end }) ->
    new Range [ start.line - 1, start.column ], [ end.line - 1, end.column ]

  @scopeNames: [
    'source.js'
    'source.mjs'
    'source.js.jsx'
    'source.babel'
  ]

  parseOptions:
    sourceType: 'unambiguous'
    allowImportExportEverywhere: true
    allowReturnOutsideFunction: true
    allowSuperOutsideMethod: true
    plugins: [
      '*' # see https://github.com/babel/babel/issues/7508
      'jsx'
      # 'typescript'
      'flow'
      'flowComments'
      'doExpressions'
      'objectRestSpread'
      'decorators2'
      'classProperties'
      'classPrivateProperties'
      'classPrivateMethods'
      'exportDefaultFrom'
      'exportNamespaceFrom'
      'asyncGenerators'
      'functionBind'
      'functionSent'
      'dynamicImport'
      'numericSeparator'
      'optionalChaining'
      'importMeta'
      'bigInt'
      'optionalCatchBinding'
      'throwExpressions'
      'pipelineOperator'
      'nullishCoalescingOperator'
    ]

  constructor: ->
    @context = new Context

  destruct: ->
    delete @context

  parse: (code, callback) ->
    try
      # d 'parse', code
      rLine = /.*(?:\r?\n|\n?\r)/g
      @locator = locator(code)
      @parseError = null
      @context.setCode code, @parseOptions
      callback() if callback
    catch err
      { loc, message } = @parseError = err
      if loc? and message?
        { line, column } = loc
        lineNumber = line - 1
        callback [
          range  : new Range [lineNumber, column], [lineNumber, column + 1]
          message: message
        ] if callback
      else
        d 'unknown error', err
        callback() if callback

  find: ({ row, column }) ->
    return if @parseError?
    d 'find', row, column

    loc = @locator row, column
    binding = @context.identify loc
    return [] unless binding

    declRange =
      if binding.path.isImportSpecifier()
        { imported, local } = binding.path.node
        range = Ripper.locToRange local.loc
        range.shorthand = local.start == imported.start
        range.key = Ripper.locToRange imported.loc if not range.shorthand
        range.delimiter = ' as '
        range
      else if binding.identifier.typeAnnotation
        Ripper.locToRange
          start: binding.identifier.loc.start
          end:   binding.identifier.typeAnnotation.loc.start
      else
        Ripper.locToRange binding.identifier.loc
    declRange.type = 'decl'

    ranges = [declRange]

    refPaths = binding.referencePaths
      .filter (p) => p  # filter undefined for ImportDefault
      .filter (p) => !p.isExportDeclaration()  # filter exports

    ranges = ranges.concat refPaths.map (p) ->
      range = Ripper.locToRange p.node.loc
      range.type = 'ref'
      if p.parentPath.isObjectProperty()
        { key, shorthand } = p.parentPath.node
        range.shorthand = shorthand
        range.key = Ripper.locToRange key.loc if not shorthand
        range.delimiter = ': '
      range

    ranges = ranges.concat binding.constantViolations.map (p) ->
      node = p.node.left || p.node
      range = Ripper.locToRange node.loc
      range.type = 'mut'
      range
    ranges
