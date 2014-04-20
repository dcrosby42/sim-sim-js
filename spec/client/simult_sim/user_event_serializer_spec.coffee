UserEventSerializer = require '../../../client/simult_sim/user_event_serializer.coffee'

describe 'UserEventSerialzier', ->
  
  beforeEach ->
    @subject = new UserEventSerializer()
  
  describe 'pack', ->
    it 'is currently a noop', ->
      data = "hello this is whatever"
      packed = @subject.pack(data)
      expect(packed).toEqual data
    
  describe 'unpack', ->
    it 'is currently a noop', ->
      packed = "hello this is whatever"
      data = @subject.unpack(packed)
      expect(data).toEqual packed
    
  
