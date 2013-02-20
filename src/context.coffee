# **Context** stores the original `template` elements and is responsible for creating,
# adding and removing template `instances` to match the amount of `models`.
class Context

  detach = chainable ->
    @parent = @el.parentNode
    if @parent
      @nextSibling = @el.nextSibling
      @parent.removeChild @el

  attach = chainable ->
    if @parent
      if @nextSibling
      then @parent.insertBefore @el, @nextSibling
      else @parent.appendChild @el

  constructor: (@el) ->
    @template      = cloneNode @el
    @instances     = [new Instance(@el)]
    @instanceCache = []

  render: \
    before(detach) \
    after(attach) \
    chainable \
    (models, directives, options) ->

      # Cloning DOM elements is expensive, so save unused template `instances` and reuse them later.
      while models.length < @instances.length
        @instanceCache.push @instances.pop().remove()

      for model, index in models
        unless instance = @instances[index]
          instance = @instanceCache.pop() || new Instance(cloneNode(@template))
          @instances.push instance.appendTo(@el)

        children = []
        instance
          .prepare(model, children)
          .renderValues(model, children)
          .renderDirectives(model, index, directives)
          .renderChildren(model, children, directives, options)
