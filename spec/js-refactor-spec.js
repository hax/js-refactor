const path = require('path')
const fs = require('fs')
const { inspect } = require('util')
const { Range } = require('atom')
const assert = require('assert')

// loadLanguage = ->
//   #languageCoffeeScriptPath = atom.packages.resolvePackagePath 'language-javascript'
//   # grammarDir = path.resolve languageCoffeeScriptPath, 'grammars'
//   # for filename in fs.readdirSync grammarDir
//   #   atom.syntax.loadGrammarSync path.resolve grammarDir, filename
//

async function activatePackages() {
	return Promise.all([
		atom.packages.activatePackage('refactor'),
		atom.packages.activatePackage('js-refactor'),
		atom.packages.activatePackage('language-javascript'),
	])
}

function loadLanguage() {
}

describe("main", () => {

	let watchers, editor, editorView

	function trigger(commandName) {
		atom.commands.dispatch(editorView, commandName)
	}

	beforeEach(async () => {
		atom.project.setPaths([path.join(__dirname, 'fixtures')])
		editor = await atom.workspace.open('fibonacci.js')
		editorView = atom.views.getView(editor)

		;[{mainModule: {watchers}}] = await activatePackages()
		// jasmine.attachToDOM(atom.views.getView(editor))
		loadLanguage()
	})

	it("activates watcher", () => {
		expect(editorView).toBeDefined()

		expect(watchers).toBeDefined()
		expect(watchers.size).toBe(1)
		const [watcher] = watchers
		// const sn = editor.getGrammar().scopeName
		// const m = watcher.moduleManager.getModule(sn)
		// console.log(sn, m)
		// console.log(m.Ripper)
		watcher.verifyGrammar()
		expect(watcher.ripper).toBeDefined()
	})

	//
	//   # it "attaches the views", ->
	//   #   waitsForPromise ->
	//   #     activationPromise
	//   #   runs ->
	//   #     errorView = atom.workspace.find ".refactor-error"
	//   #     referenceView = atom.workspace.find ".refactor-reference"
	//   #     expect(errorView).toExist()
	//   #     expect(referenceView).toExist()
	//
	//
	//   it "starts highlighting", ->
	//     waitsForPromise ->
	//       activationPromise
	//     runs ->
	//       expect(referenceView.find('.marker').length).toEqual 5
	//

	it("has single cursor", () => {
			expect(editor.getCursors().length).toBe(1)
	})

	describe("when 'js-refactor:rename' event is triggered", () => {
		it("has multi-cursors", () => {
			const [watcher] = watchers
			watcher.verifyGrammar()
			editor.setCursorBufferPosition([0, 4])
			trigger('refactor:rename')
			expect(editor.getCursors().length).toBe(5)
		})
	})

	describe("when 'js-refactor:done' event is triggered", () => {
		it("has single cursor", () => {
			trigger('refactor:done')
			expect(editor.getCursors().length).toBe(1)
		})
	})
})
