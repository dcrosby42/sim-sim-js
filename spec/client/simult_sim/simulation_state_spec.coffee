SimulationState = require '../../../client/simult_sim/simulation_state'

describe 'SimulationState', ->
  beforeEach ->
    @world = {some:'data'}

    @subject = new SimulationState(
      0.2.fixed()
      5
      0
      @world
    )

  it 'sets expected ivars', ->
    expect(@subject.timePerTurn).toEqual 0.2.fixed()
    expect(@subject.stepsPerTurn).toEqual 5
    expect(@subject.step).toEqual 0
    expect(@subject.world).toEqual @world

  it 'calculates @timePerStep', ->
    expect(@subject.timePerStep).toEqual (0.2 / 5.0).fixed()

    


  
  
