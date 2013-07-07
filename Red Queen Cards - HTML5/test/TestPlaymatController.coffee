describe 'Controller', ->
  sut = null

  beforeEach ->
    sut = new PlayMatController()

  afterEach ->
    sut = null

  describe 'Toggling', ->

    it 'has a model', ->
      model = sut.model
      expect(model).toBeDefined()
      
    it 'calls setCell when toggling', ->
      spyOn sut, "setCell"
      sut.toggleCell cellType, 2
      expect(sut.setCell).toHaveBeenCalled

