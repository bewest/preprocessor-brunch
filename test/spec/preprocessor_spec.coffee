fs = require 'fs'

Module = require './lib/module'
Preprocessor = require './lib/preprocessor'
expect = require('chai').expect

MatchedDeclarationsFixtures = require './fixtures/declarations/matched'
NotMatchedDeclarationsFixtures = require './fixtures/declarations/not_matched'

describe 'preprocessor', ->

  # make the preprocessor var available
  preprocessor = null

  beforeEach ->
    preprocessor = new Preprocessor
      paths:
        app: ''

  it 'should instantiate', ->
    expect(preprocessor).to.be.ok
    expect(preprocessor).to.be.an.instanceof Preprocessor

  it 'should have its regexes instantiated', ->
    expect(preprocessor.regexes.require).to.be.an.instanceof RegExp
    expect(preprocessor.regexes.export).to.be.an.instanceof RegExp

  describe 'regex require', ->

    for declaration in MatchedDeclarationsFixtures.require
      do (declaration) ->
        it 'should match declaration ' + declaration.before, ->
          matched = preprocessor.regexes.require.test(declaration.before)
          expect(matched).to.be.true

        it 'should generate the correct declaration for ' + declaration.before, ->
          content = preprocessor.preprocessRequires declaration.before
          expect(content).to.equal declaration.after

    for declaration in NotMatchedDeclarationsFixtures.require
      do (declaration) ->
        it 'should not match declaration ' + declaration, ->
          matched = preprocessor.regexes.require.test(declaration)
          expect(matched).to.be.false

  describe 'regex export', ->

    for declaration in MatchedDeclarationsFixtures.export
      do (declaration) ->
        it 'should match declaration ' + declaration.before, ->
          matched = preprocessor.regexes.export.test(declaration.before)
          expect(matched).to.be.true

        it 'should generate the correct declaration for ' + declaration.before, ->
          content = preprocessor.preprocessExports declaration.before
          expect(content).to.equal declaration.after

    for declaration in NotMatchedDeclarationsFixtures.export
      do (declaration) ->
        it 'should not match declaration ' + declaration, ->
          matched = preprocessor.regexes.export.test(declaration)
          expect(matched).to.be.false

  describe 'content generation', ->

    files = [
      {
        before: 'test/files/controller.coffee'
        after : 'test/files/controller_generated.coffee'
      }
      {
        before: 'test/files/view.coffee'
        after : 'test/files/view_generated.coffee'
      }
    ]

    for file in files
      do (file) ->

        it 'should generate the correct file content', ->

          # we need utf8 option to get the content and not the buffer
          beforeContent = fs.readFileSync file.before, 'utf8'
          afterContent = fs.readFileSync file.after, 'utf8'

          processedContent = preprocessor.preprocess beforeContent

          expect(processedContent).to.equal(afterContent)
