TurnCalculator = require '../../../client/simult_sim/turn_calculator.coffee'
SimulationStateFactory = require '../../../client/simult_sim/simulation_state_factory.coffee'
require '../../../client/helpers.coffee'
TestWorld = require './test_world'

describe 'TurnCalculator', ->
  subject = null
  world = null
  simState = null
  expectedDT = null

  beforeEach ->
    subject = new TurnCalculator()
  
    stateFactory = new SimulationStateFactory(
      timePerTurn: 0.1
      stepsPerTurn: 6
      worldClass: TestWorld
      worldData: {someProperty:'the daater'}
    )
    simState = stateFactory.createSimulationState()

    expectedDT = (0.1 / 6.0).fixed()

  describe 'advanceTurn', ->
    describe 'when no steps have been taken', ->
      it "steps through the whole turn", ->
        subject.advanceTurn(simState)
        expect(simState.world.stepCalls).toEqual [
          expectedDT
          expectedDT
          expectedDT
          expectedDT
          expectedDT
          expectedDT
        ]
      
    describe 'when some steps have already been taken', ->
      it 'executes remaining steps for the current turn and resets the step counter', ->
        simState.step = 3
        subject.advanceTurn(simState)
        expect(simState.world.stepCalls).toEqual [
          expectedDT
          expectedDT
          expectedDT
        ]

    describe 'when all steps have already been taken', ->
      it 'executes no further steps and resets the step counter', ->
        simState.step = 6
        subject.advanceTurn(simState)
        expect(simState.world.stepCalls).toEqual []

        simState.step = 20
        subject.advanceTurn(simState)
        expect(simState.world.stepCalls).toEqual []

  describe 'stepUntilTurnTime', ->
    it 'determines how many steps are needed to make it to the given turn time, and executes those steps', ->
      # 0.0 0.017 0.034 0.051 0.068 0.085
      for x in [
        { startingStep: 0, turnTime: 0, expectedSteps: 0 }
        { startingStep: 1, turnTime: 0, expectedSteps: 0 }
        { startingStep: 0, turnTime: 0.02, expectedSteps: 1 }
        { startingStep: 0, turnTime: 0.04, expectedSteps: 2 }
        { startingStep: 0, turnTime: 0.1, expectedSteps: 6 }
        { startingStep: 2, turnTime: 0.06, expectedSteps: 2 }
        { startingStep: 5, turnTime: 0.1, expectedSteps: 1 }
      ]
        simState.world.stepCalls = []
        simState.step = x.startingStep
        subject.stepUntilTurnTime(simState, x.turnTime)
        expect(simState.world.stepCalls.length).toEqual x.expectedSteps
