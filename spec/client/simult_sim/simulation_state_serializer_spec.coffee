SimulationStateSerializer = require '../../../client/simult_sim/simulation_state_serializer'
SimulationState = require '../../../client/simult_sim/simulation_state'

describe 'SimulationStateSerialzier', ->
  
  beforeEach ->
    @simulationStateFactory = { createWorld: (->) }
    @checksumCalculator = { calculate: (->) }


    @subject = new SimulationStateSerializer(@simulationStateFactory, @checksumCalculator)

    @timePerTurn = 0.5
    @stepsPerTurn = 2
    @step = 451
    @worldAsAttributes = "the world attrs"
    @world = { getData: => @worldAsAttributes }
    @newWorld = "the new world"
  
  describe 'packSimulationState', ->
    it 'converts SimulationState into a pojo', ->
      simState = new SimulationState(@timePerTurn,@stepsPerTurn,@step,@world)
      packed = @subject.packSimulationState(simState)
      expect(packed).toEqual
        timePerTurn: @timePerTurn
        stepsPerTurn: @stepsPerTurn
        step: @step
        world: @worldAsAttributes
    
  describe 'unpackSimulationState', ->
    it 'converts the given object into a SimulationState and deserializes the World data', ->
      packed =
        timePerTurn: @timePerTurn
        stepsPerTurn: @stepsPerTurn
        step: @step
        world: @worldAsAttributes
      spyOn(@simulationStateFactory, 'createWorld').andReturn(@newWorld)

      simState= @subject.unpackSimulationState(packed)

      expect(simState.timePerTurn).toEqual @timePerTurn
      expect(simState.stepsPerTurn).toEqual @stepsPerTurn
      expect(simState.step).toEqual @step
      expect(simState.world).toEqual @newWorld
      expect(@simulationStateFactory.createWorld).toHaveBeenCalledWith(@worldAsAttributes)
    
