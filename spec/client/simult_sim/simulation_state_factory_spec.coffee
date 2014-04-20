SimulationStateFactory = require '../../../client/simult_sim/simulation_state_factory'
TestWorld = require './test_world'

describe 'SimulationStateFactory', ->

  beforeEach ->
    @subject = new SimulationStateFactory
      timePerTurn: 0.25
      stepsPerTurn: 7
      worldClass: TestWorld
      worldData: {someProperty:"interesting"}

  describe 'createSimulationState', ->
    it 'returns a new SimulationState instance using the constructed defaults', ->
      simState = @subject.createSimulationState()
      expect(simState.timePerTurn).toEqual 0.25
      expect(simState.stepsPerTurn).toEqual 7
      expect(simState.step).toEqual 0
      expect(simState.world).toBeDefined()
      expect(simState.world.someProperty).toEqual "interesting"
      expect(simState.world.isTestWorld()).toEqual true

    describe 'without worldData', ->

    describe 'without worldClass', ->
      beforeEach ->
        @subject = new SimulationStateFactory
          timePerTurn: 0.25
          stepsPerTurn: 7

      it 'throws an error', ->
        thrownErrorMessage = null
        try
          @subject.createSimulationState()
        catch e
          thrownErrorMessage = e.message
        expect(thrownErrorMessage).toMatch /needs a worldClass/



      
    

