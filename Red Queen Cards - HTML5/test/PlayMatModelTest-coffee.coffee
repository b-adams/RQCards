describe 'Model Playmat', ->
  sut = null

  beforeEach ->
    sut = new PlayMat()

  afterEach ->
    sut = null

  it 'starts with an inactive feature', ->
    result = sut.isCellActive TYPE_FEATURE, 1
    expect(result).toBeFalsy()

  it 'calls setCell when toggling a cell', ->
    spyOn sut, "setCell"
    sut.toggleCell TYPE_FEATURE, 1
    expect(sut.setCell).toHaveBeenCalled

  it 'allows features to be toggled on', ->
    sut.toggleCell TYPE_FEATURE, 1
    result = sut.isCellActive TYPE_FEATURE, 1
    expect(result).toBeTruthy()

  it 'allows features to be toggled back off', ->
    sut.toggleCell TYPE_FEATURE, 1
    sut.toggleCell TYPE_FEATURE, 1
    result = sut.isCellActive TYPE_FEATURE, 1
    expect(result).toBeFalsy()
