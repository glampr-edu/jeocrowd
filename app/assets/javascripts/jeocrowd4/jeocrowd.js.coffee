# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
# to do:
# add parallelization
# check how we can draw hybrid grids (with tiles from bigger levels!!)
# check resuming from server in rf mode, golden gate park

MAX_LEVEL = 6

window.Jeocrowd = 
  config: {}
  
  _grids: null
  grids: (level) ->
    @_grids ||= [0..MAX_LEVEL].map (i) ->
      new Grid(i)
    if level == undefined
      @_grids
    else
      @_grids[level] || (@_grids[level] = new Grid(level))
  
  _provider : null
  provider: ->
    @_provider ||= new window.Provider 'Flickr', window.location.href, @config.search
  
  _visibleLayer: 'degree'
  visibleLayer: (layer) ->
    if layer
      $('#layer').val(layer)
      @_visibleLayer = layer
      @visibleGrid().draw()
    @_visibleLayer

  _visibleLevel: 0
  visibleLevel: (level) ->
    if level != undefined
      level = parseInt(level) if typeof level == 'string'
      $('#level').val(level)
      @grids(@_visibleLevel).undraw()
      @_visibleLevel = level
      @grids(@_visibleLevel).draw()
    @_visibleLevel
      
  visibleGrid: ->
    @grids(@visibleLevel())

  buildMap: (div) ->
    initialOptions = { zoom: 12, mapTypeId: google.maps.MapTypeId.ROADMAP }
    initialLocation = new google.maps.LatLng 37.97918, 23.716647
    if placeholder = document.getElementById div 
      @map = new google.maps.Map placeholder, initialOptions 
      @map.setCenter initialLocation 
      return @map
      
  loadConfiguration: ->
    configurationElement = document.getElementById 'jeocrowd_config'
    @config.search = JSON.parse configurationElement.innerHTML if configurationElement
    if @config.search
      $('#available_points_value').text(@config.search.statistics.total_available_points)
      $('#exploratory_pages_value').text(JSON.stringify @config.search.pages)
      @visibleLayer('neighbors')
      if @config.search.phase == 'exploratory'
        @grids(0).addTile(id, info.degree, info.points) for own id, info of @config.search.xpTiles
        @visibleLevel(0)
      else if @config.search.phase == 'refinement'
        @levels = @config.search.levels
        @maxLevel = @levels.length - 1
        @refinementLevel = Util.lastMissingFromRange(@levels)
        if @config.search.rfTiles[@refinementLevel] == null
          @gotoBelowLevel()
        else
          @grids(@refinementLevel).addTile(id, degree) for own id, degree of @config.search.rfTiles[@refinementLevel]
          @visibleLevel(@refinementLevel)
        $('#refinement_boxes_value').text((@grids(level).refinementPercent() * 100).toFixed(2) + '%') if @grids(level)
        $('#level_label label').text(@maxLevel)
  
  
  autoStart: ->
    @config.autoStart || true
    
  resumeSearch: ->
    return if $('#running:checked').length == 0
    if @config.search.phase == 'exploratory'
      next = @provider().exploratorySearch @config.search.keywords, @receiveResults
      @switchToRefinementPhase() if next == null
    else if @config.search.phase == 'refinement'
      next = @provider().refinementSearch @config.search.keywords, @refinementLevel, @receiveResults
      @gotoBelowLevel(@refinementLevel = @refinementLevel - 1) if next == null
    
  receiveResults: (data, pageOrLevel, box) ->
    if @config.search.phase == 'exploratory'
      page = pageOrLevel
      @grids(0).addPoints(data)
      @visibleGrid().draw()
      @map.panTo @visibleGrid().hottestTile.getCenter() if $('#pan_map:checked[value=hottest]').length > 0      
      @provider().saveExploratoryResults @grids(0).tiles.toJSON({withoutID: true}), page, Jeocrowd.syncWithServer
    else if @config.search.phase == 'refinement'
      level = pageOrLevel
      if box.degree > 0
        box.drawNeighborhood() if level == @visibleLevel()
      else
        box.undraw() if level == @visibleLevel()
        @grids(level).removeTile box.id
      @provider().saveRefinementResults box.toSimpleJSON('degree'), level, Jeocrowd.syncWithServer
      
  switchToRefinementPhase: ->
    @config.search.phase = 'refinement'
    $('#phase').text('refinement')
    @maxLevel = @calculateMaxLevel()
    @grids(@maxLevel).growUp Tile.prototype.atLeastOne
    @grids(@maxLevel).clearBeforeRefinement()
    @visibleLevel(@maxLevel)
    @levels = []
    @levels[i] = null for i in [0..@maxLevel]
    @levels[@maxLevel] = @maxLevel
    @refinementLevel = @maxLevel - 1
    (delete(@_grids[grid.level]) if grid.level != @maxLevel) for grid in @_grids
    @provider().saveRefinementResults @visibleGrid().tiles.toSimpleJSON('degree'), 
                                      @visibleGrid().level, Jeocrowd.gotoBelowLevel
  
  gotoBelowLevel: ->
    if @refinementLevel == -1
      @markAsCompleted()
      return
    @levels[@refinementLevel + 1] = @refinementLevel + 1  # mark above level as complete
    @grids(@refinementLevel + 1).addTile(id, degree) for own id, degree of @config.search.rfTiles[@refinementLevel + 1]
    @grids(@refinementLevel + 1).clearBeforeRefinement() if (@refinementLevel + 1 != @maxLevel)
    @grids(@refinementLevel).growDown(Tile.prototype.always)
    @visibleLevel(@refinementLevel)
    @provider().saveRefinementResults @grids(@refinementLevel).tiles.toSimpleJSON('degree'), 
                                      @refinementLevel, Jeocrowd.syncWithServer
  
  syncWithServer: (newData) ->
    @resumeSearch()
  
  markAsCompleted: ->
    $('#phase').text('completed')
  
  calculateMaxLevel: ->
    @visibleGrid().undraw()
    grid.dirty = grid.level > 0 for grid in Jeocrowd.grids()
    @grids(MAX_LEVEL).growUp Tile.prototype.atLeastTwo
    i = MAX_LEVEL
    i-- while @grids(i).tiles.size() == 0
    grid.dirty = grid.level > 0 for grid in Jeocrowd.grids()
    @maxLevel = i








