React = require 'react'
{div} = require 'reactionary'
{debounce} = require 'underscore-plus'
SubscriberMixin = require './subscriber-mixin'
CursorComponent = require './cursor-component'

module.exports =
CursorsComponent = React.createClass
  displayName: 'CursorsComponent'
  mixins: [SubscriberMixin]

  cursorBlinkIntervalHandle: null

  render: ->
    {editor, scrollTop, scrollLeft} = @props
    {blinking} = @state

    className = 'cursors'
    className += ' blinking' if blinking

    div {className},
      if @isMounted()
        for selection in editor.getSelections()
          if selection.isEmpty() and editor.selectionIntersectsVisibleRowRange(selection)
            {cursor} = selection
            CursorComponent({key: cursor.id, cursor, scrollTop, scrollLeft})

  getInitialState: ->
    blinking: true

  componentDidMount: ->
    {editor} = @props

  componentWillUnmount: ->
    clearInterval(@cursorBlinkIntervalHandle)

  componentWillUpdate: ({cursorsMoved}) ->
    @pauseCursorBlinking() if cursorsMoved

  startBlinkingCursors: ->
    @setState(blinking: true) if @isMounted()

  startBlinkingCursorsAfterDelay: null # Created lazily

  pauseCursorBlinking: ->
    @state.blinking = false
    @startBlinkingCursorsAfterDelay ?= debounce(@startBlinkingCursors, @props.cursorBlinkResumeDelay)
    @startBlinkingCursorsAfterDelay()
