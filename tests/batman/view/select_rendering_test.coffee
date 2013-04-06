helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

oldIteratorDeferEvery = Batman.DOM.IteratorBinding::deferEvery
oldRendererDeferEvery = Batman.Renderer::deferEvery
getSelections = (node) -> node.find('option').map((i, node) -> !!node.selected).toArray()
getContents = (node) -> node.find('option').map((i, node) -> node.innerHTML).toArray()

QUnit.module 'Batman.View select bindings',
  setup: ->
    Batman.DOM.IteratorBinding::deferEvery = false
    Batman.Renderer::deferEvery = false
  teardown: ->
    Batman.DOM.IteratorBinding::deferEvery = oldIteratorDeferEvery
    Batman.Renderer::deferEvery = oldRendererDeferEvery

asyncTest 'it should bind the value of a select box and update when the javascript land value changes', 2, ->
  context = Batman
    heros: new Batman.Set('mario', 'crono', 'link')
    selected: new Batman.Object(name: 'crono')
  helpers.render '<select data-bind="selected.name"><option data-foreach-hero="heros" data-bind-value="hero"></option></select>', context, (node) ->
    equal node[0].value, 'crono'
    context.set 'selected.name', 'link'
    equal node[0].value, 'link'
    QUnit.start()

asyncTest 'it should bind the value of a select box and update when options change', 7, ->
  context = Batman
    heros: new Batman.Set()
    selected: new Batman.Object(name: 'crono')
  helpers.render '<select data-bind="selected.name"><option data-foreach-hero="heros" data-bind-value="hero" data-bind="hero | capitalize"></option></select>', context, (node) ->
    equal node[0].value, ''
    equal context.get('selected.name'), 'crono'
    context.get('heros').add('mario', 'link', 'crono')
    delay ->
      equal node[0].value, 'crono'
      deepEqual getContents(node), ['Mario', 'Link', 'Crono']
      equal context.get('selected.name'), 'crono'
      context.set('selected.name', 'mario')
      equal node[0].value, 'mario'
      deepEqual getContents(node), ['Mario', 'Link', 'Crono']

asyncTest 'it should bind the value of a select box and update the javascript land value with the selected option', 3, ->
  context = Batman
    heros: new Batman.SimpleSet('mario', 'crono', 'link')
    selected: 'crono'
  helpers.render '<select data-bind="selected"><option data-foreach-hero="heros" data-bind-value="hero"></option></select>', context, (node) ->
    equal node[0].value, 'crono'
    context.set 'selected', 'link'
    equal node[0].value, 'link'
    context.set 'selected', 'mario'
    equal node[0].value, 'mario'
    QUnit.start()

asyncTest 'it binds the options of a select box and updates when the select\'s value changes', ->
  context = Batman
    something: 'crono'
    mario: Batman(selected: null)
    crono: Batman(selected: null)

  helpers.render '<select data-bind="something"><option value="mario" data-bind-selected="mario.selected">Mario</option><option value="crono" data-bind-selected="crono.selected">Crono</option></select>', context, (node) ->
    equal node[0].value, 'crono'
    equal context.get('crono.selected'), true
    equal context.get('mario.selected'), false
    deepEqual getContents(node), ['Mario', 'Crono']

    node[0].value = 'mario'
    helpers.triggerChange node[0]
    equal context.get('mario.selected'), true
    equal context.get('crono.selected'), false
    deepEqual getContents(node), ['Mario', 'Crono']

    QUnit.start()

asyncTest 'it binds options created by a foreach and remains consistent when the set instance iterated over swaps', ->
  leo = Batman name: 'leo', id: 1
  mikey = Batman name: 'mikey', id: 2

  context = Batman
    heroes: new Batman.Set(leo, mikey).sortedBy('id')
    selected: 1

  helpers.render  '<select data-bind="selected">' +
                    '<option data-foreach-hero="heroes" data-bind-value="hero.id" data-bind="hero.name" />' +
                  '</selected>', context, (node) ->
    delay ->
      deepEqual getContents(node), ['leo', 'mikey']
      equal node[0].value, "1"

      context.set 'heroes', new Batman.Set(leo, mikey).sortedBy('id')
      delay ->
        deepEqual getContents(node), ['leo', 'mikey']
        equal node[0].value, "1"

asyncTest 'it binds the value of a multi-select box and updates the options when the bound value changes', ->
  context = new Batman.Object
    heros: new Batman.Set('mario', 'crono', 'link', 'kirby')
    selected: new Batman.Object(name: ['crono', 'link'])
  helpers.render '<select multiple="multiple" size="2" data-bind="selected.name"><option data-foreach-hero="heros" data-bind-value="hero" data-bind="hero | capitalize"></option></select>', context, (node) ->
    deepEqual getSelections(node), [no, yes, yes, no]
    deepEqual getContents(node), ['Mario', 'Crono', 'Link', 'Kirby']

    context.set 'selected.name', ['mario', 'kirby']

    deepEqual getSelections(node), [yes, no, no, yes]
    deepEqual getContents(node), ['Mario', 'Crono', 'Link', 'Kirby']
    QUnit.start()

asyncTest 'it binds the value of a multi-select box and updates the options when the options changes', ->
  context = new Batman.Object
    heros: new Batman.Set()
    selected: new Batman.Object(names: ['crono', 'link'])

  source = '''
    <select multiple="multiple" size="2" data-bind="selected.names">
      <option data-foreach-hero="heros" data-bind-value="hero" data-bind="hero | capitalize"></option>
    </select>
  '''

  helpers.render source, context, (node) ->
    deepEqual context.get('selected.names'), ['crono', 'link']
    deepEqual getSelections(node), []
    deepEqual getContents(node), []

    context.get('heros').add 'mario', 'crono', 'link', 'kirby'
    delay ->
      deepEqual getSelections(node), [no, yes, yes, no]
      deepEqual getContents(node), ['Mario', 'Crono', 'Link', 'Kirby']

      context.set 'selected.names', ['mario', 'kirby']
      deepEqual getSelections(node), [yes, no, no, yes]
      deepEqual getContents(node), ['Mario', 'Crono', 'Link', 'Kirby']

      context.get('heros').clear()
      delay ->
        deepEqual context.get('selected.names'), ['mario', 'kirby']
        deepEqual getContents(node), []

asyncTest 'it binds the value of a multi-select box and updates the value when the selected options change', ->
  context = new Batman.Object
    selected: 'crono'
    mario: new Batman.Object(selected: null)
    crono: new Batman.Object(selected: null)

  helpers.render '<select multiple="multiple" data-bind="selected"><option value="mario" data-bind-selected="mario.selected"></option><option value="crono" data-bind-selected="crono.selected"></option></select>', context, (node) ->
    equal node[0].value, 'crono', 'node value is crono'
    equal context.get('selected'), 'crono', 'selected is crono'
    equal context.get('crono.selected'), true, 'crono is selected'
    equal context.get('mario.selected'), false, 'mario is not selected'

    context.set 'mario.selected', true
    equal context.get('mario.selected'), true, 'mario is selected'
    equal context.get('crono.selected'), true, 'crono is still selected'
    deepEqual context.get('selected'), ['mario', 'crono'], 'mario and crono are selected in binding'
    for opt in node[0].children
      ok opt.selected, "#{opt.value} option is selected"
    QUnit.start()

asyncTest 'it binds multiple select options created by a foreach and remains consistent when the set instance iterated over swaps', 4, ->
  context = new Batman.Object
    mario: mario = new Batman.Object(selected: false, name: 'mario')
    crono: crono = new Batman.Object(selected: true, name: 'crono')
    heros: new Batman.Set(mario, crono).sortedBy('name')

  source = '''
    <select multiple="multiple">
      <option data-foreach-hero="heros" data-bind-selected="hero.selected" data-bind="hero.name" data-bind-value="hero.name"></option>
    </select>
  '''

  helpers.render source, context, (node) ->
    deepEqual getContents(node), ['crono', 'mario']
    deepEqual getSelections(node), [true, false]
    context.set 'heros', new Batman.Set(context.get('crono'), context.get('mario')).sortedBy('name')
    delay ->
      deepEqual getContents(node), ['crono', 'mario']
      deepEqual getSelections(node), [true, false]

asyncTest 'should be able to destroy bound select nodes', 2, ->
  context = new Batman.Object selected: "foo"
  helpers.render '<select data-bind="selected"><option value="foo">foo</option></select>', context, (node) ->
    Batman.DOM.destroyNode(node[0])
    deepEqual Batman.data(node[0]), {}
    deepEqual Batman._data(node[0]), {}
    QUnit.start()

asyncTest "should select an option with value='' when the data is undefined", ->
  context = Batman
    current: Batman
      bar: 'foo'

  source = '''
    <select data-bind="current.bar">
      <option value="">none</option>
      <option value="foo">foo</option>
    </select>
  '''

  helpers.render source, context, (node) ->
    equal node[0].value, 'foo'
    deepEqual getContents(node), ['none', 'foo']

    context.unset 'current.bar'
    equal typeof context.get('current.bar'), 'undefined'
    equal node[0].value, ''
    deepEqual getContents(node), ['none', 'foo']
    delay ->
      equal typeof context.get('current.bar'), 'undefined'
      equal node[0].value, ''
      deepEqual getContents(node), ['none', 'foo']

asyncTest "should select an option with value='' when the data is null", ->
  context = Batman
    current: Batman
      bar: 'foo'

  source = '''
    <select data-bind="current.bar">
      <option value="">none</option>
      <option value="foo">foo</option>
    </select>
  '''

  helpers.render source, context, (node) ->
    equal node[0].value, 'foo'
    deepEqual getContents(node), ['none', 'foo']

    context.set 'current.bar', null
    equal context.get('current.bar'), null
    equal node[0].value, ''
    deepEqual getContents(node), ['none', 'foo']
    delay ->
      equal context.get('current.bar'), null
      equal node[0].value, ''
      deepEqual getContents(node), ['none', 'foo']


asyncTest "should select an option with value='' when the data is ''", ->
  context = Batman
    current: 'foo'

  source = '''
    <select data-bind="current">
      <option value="">none</option>
      <option value="foo">foo</option>
    </select>
  '''

  helpers.render source, context, (node) ->
    equal node[0].value, 'foo'
    deepEqual getContents(node), ['none', 'foo']

    context.set 'current', ''
    equal context.get('current'), ''
    equal node[0].value, ''
    deepEqual getContents(node), ['none', 'foo']

    delay ->
      equal context.get('current'), ''
      equal node[0].value, ''
      deepEqual getContents(node), ['none', 'foo']
