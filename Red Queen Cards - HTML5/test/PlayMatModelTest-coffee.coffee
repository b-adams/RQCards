describe 'Model Playmat', ->
  mat = null

  beforeEach ->
    mat = new PlayMat()

  afterEach ->
    mat = null

  it 'starts with an inactive feature', ->
    result = mat.isCellActive TYPE_FEATURE, 1
    expect(result).toBeFalsy()

  it 'allows features to be toggled on', ->
    mat.toggleCell TYPE_FEATURE, 1
    result = mat.isCellActive TYPE_FEATURE, 1
    expect(result).toBeTruthy()

  it 'allows features to be toggled back off', ->
    mat.toggleCell TYPE_FEATURE, 1
    mat.toggleCell TYPE_FEATURE, 1
    result = mat.isCellActive TYPE_FEATURE, 1
    expect(result).toBeFalsy()
