ChecksumCalculator = require '../../../client/simult_sim/checksum_calculator'

describe 'ChecksumCalculator', ->
  beforeEach ->
    @subject = new ChecksumCalculator()

  it "calculates a 0 checksum on empty string", ->
    expect(@subject.calculate('')).toEqual(0)

  it "passes through on the old checksum for empty string", ->
    expect(@subject.calculate('',123)).toEqual(123)

  it "calculates a checksum for the given string", ->
    expect(@subject.calculate('this is the string',0)).toEqual(850153909)

  it "accumulates a checksum the same way with the same sequence of inputs", ->
    words = [ 'lets', 'calc', 'us', 'some', 'crc32' ]

    crc = 0
    for w in words
      crc = @subject.calculate(w,crc)
    firstResult = crc

    crc = 0
    for w in words
      crc = @subject.calculate(w,crc)
    secondResult = crc

    expect(firstResult).not.toEqual(0)
    expect(firstResult).toEqual(secondResult)


