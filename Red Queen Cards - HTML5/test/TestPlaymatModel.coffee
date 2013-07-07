describe 'Playmat', ->
  sut = null

  beforeEach ->
    sut = new PlayMat()

  afterEach ->
    sut = null

  describe 'Toggling', ->

    describe 'Feature', ->

      cellType = TYPE_FEATURE;

      it 'starts inactive', ->
        result = sut.isCellActive cellType, 1
        expect(result).toBeFalsy()

      it 'calls setCell when toggling', ->
        spyOn sut, "setCell"
        sut.toggleCell cellType, 2
        expect(sut.setCell).toHaveBeenCalled

      it 'can be toggled on', ->
        sut.toggleCell cellType, 3
        result = sut.isCellActive cellType, 3
        expect(result).toBeTruthy()

      it 'can be toggled on and back off', ->
        sut.toggleCell cellType, 4
        sut.toggleCell cellType, 4
        result = sut.isCellActive cellType, 4
        expect(result).toBeFalsy()

      it 'does not confuse different slots', ->
        sut.toggleCell cellType, 5
        sut.toggleCell cellType, 6
        result = sut.isCellActive cellType, 5
        expect(result).toBeTruthy()

    describe 'Detector', ->

      cellType = TYPE_DETECTOR;

      it 'starts inactive', ->
        result = sut.isCellActive cellType, 1
        expect(result).toBeFalsy()

      it 'calls setCell when toggling', ->
        spyOn sut, "setCell"
        sut.toggleCell cellType, 2
        expect(sut.setCell).toHaveBeenCalled

      it 'can be toggled on', ->
        sut.toggleCell cellType, 3
        result = sut.isCellActive cellType, 3
        expect(result).toBeTruthy()

      it 'can be toggled on and back off', ->
        sut.toggleCell cellType, 4
        sut.toggleCell cellType, 4
        result = sut.isCellActive cellType, 4
        expect(result).toBeFalsy()

      it 'does not confuse different slots', ->
        sut.toggleCell cellType, 5
        sut.toggleCell cellType, 6
        result = sut.isCellActive cellType, 5
        expect(result).toBeTruthy()

    describe 'Alarm', ->

      cellType = TYPE_ALARM;

      it 'starts inactive', ->
        result = sut.isCellActive cellType, 1,0
        expect(result).toBeFalsy()

      it 'calls setCell when toggling', ->
        spyOn sut, "setCell"
        sut.toggleCell cellType, 2,1
        expect(sut.setCell).toHaveBeenCalled

      it 'can be toggled on', ->
        sut.toggleCell cellType, 3,0
        result = sut.isCellActive cellType, 3,0
        expect(result).toBeTruthy()

      it 'can be toggled on and back off', ->
        sut.toggleCell cellType, 4,1
        sut.toggleCell cellType, 4,1
        result = sut.isCellActive cellType, 4,1
        expect(result).toBeFalsy()

      it 'does not confuse different slots', ->
        sut.toggleCell cellType, 5,0
        sut.toggleCell cellType, 6,0
        result = sut.isCellActive cellType, 5,0
        expect(result).toBeTruthy()

      it 'does not confuse different subslots', ->
        sut.toggleCell TYPE_ALARM, 7, 0
        sut.toggleCell TYPE_ALARM, 7, 1
        result = sut.isCellActive TYPE_ALARM, 7, 0
        expect(result).toBeTruthy()

    describe 'Effector', ->

      cellType = TYPE_EFFECTOR;

      it 'starts inactive', ->
        result = sut.isCellActive cellType, 1,0
        expect(result).toBeFalsy()

      it 'calls setCell when toggling', ->
        spyOn sut, "setCell"
        sut.toggleCell cellType, 2,1
        expect(sut.setCell).toHaveBeenCalled

      it 'can be toggled on', ->
        sut.toggleCell cellType, 3,0
        result = sut.isCellActive cellType, 3,0
        expect(result).toBeTruthy()

      it 'can be toggled on and back off', ->
        sut.toggleCell cellType, 4,1
        sut.toggleCell cellType, 4,1
        result = sut.isCellActive cellType, 4,1
        expect(result).toBeFalsy()

      it 'does not confuse different slots', ->
        sut.toggleCell cellType, 5,0
        sut.toggleCell cellType, 6,0
        result = sut.isCellActive cellType, 5,0
        expect(result).toBeTruthy()

      it 'does not confuse different subslots', ->
        sut.toggleCell TYPE_ALARM, 7, 0
        sut.toggleCell TYPE_ALARM, 7, 1
        result = sut.isCellActive TYPE_ALARM, 7, 0
        expect(result).toBeTruthy()

  describe 'Board States', ->

    describe 'Initial', ->

      it 'has no active ETI', ->
        expect(sut.isPlantETIActive()).toBeFalsy()

      it 'has no active MTI', ->
        expect(sut.isPlantMTIActive()).toBeFalsy()

      # TODO: Flip this for 2-MAMP minimum
      it 'is virulent', ->
        expect(sut.isPathogenVirulent()).toBeTruthy()

    describe 'Clear', ->
      beforeEach ->
        sut.clearBoard()

      it 'has no active ETI', ->
        expect(sut.isPlantETIActive()).toBeFalsy()

      it 'has no active MTI', ->
        expect(sut.isPlantMTIActive()).toBeFalsy()

      # TODO: Flip this for 2-MAMP minimum
      it 'is virulent', ->
        expect(sut.isPathogenVirulent()).toBeTruthy()

    describe 'MAMP1', ->
      beforeEach ->
        sut.toggleCell TYPE_FEATURE,1

      it 'has no active ETI', ->
        expect(sut.isPlantETIActive()).toBeFalsy()

      it 'has no active MTI', ->
        expect(sut.isPlantMTIActive()).toBeFalsy()

      # TODO: Flip this for 2-MAMP minimum
      it 'is virulent', ->
        expect(sut.isPathogenVirulent()).toBeTruthy()

      describe '+DETECTOR1', ->

        beforeEach ->
          sut.toggleCell TYPE_DETECTOR,1

        it 'has no active ETI', ->
          expect(sut.isPlantETIActive()).toBeFalsy()

        it 'has no active MTI', ->
          expect(sut.isPlantMTIActive()).toBeFalsy()

        # TODO: Flip this for 2-MAMP minimum
        it 'is virulent', ->
          expect(sut.isPathogenVirulent()).toBeTruthy()

      describe '+MAMP2', ->

        beforeEach ->
          sut.toggleCell TYPE_FEATURE,2

        it 'has no active ETI', ->
          expect(sut.isPlantETIActive()).toBeFalsy()

        it 'has no active MTI', ->
          expect(sut.isPlantMTIActive()).toBeFalsy()

        it 'is virulent', ->
          expect(sut.isPathogenVirulent()).toBeTruthy()

        describe '+DETECTOR1+DETECTOR2', ->

          beforeEach ->
            sut.toggleCell TYPE_DETECTOR,1
            sut.toggleCell TYPE_DETECTOR,2

          it 'has no active ETI', ->
            expect(sut.isPlantETIActive()).toBeFalsy()

          it 'has active MTI', ->
            expect(sut.isPlantMTIActive()).toBeTruthy()

          it 'is not virulent', ->
            expect(sut.isPathogenVirulent()).toBeFalsy()

          describe '+EFFECTOR1a', ->
            beforeEach ->
              sut.toggleCell TYPE_EFFECTOR,1,0

            it 'has no active ETI', ->
              expect(sut.isPlantETIActive()).toBeFalsy()

            it 'has inactive MTI', ->
              expect(sut.isPlantMTIActive()).toBeFalsy()

            it 'is  virulent', ->
              expect(sut.isPathogenVirulent()).toBeTruthy()

            describe '+ALARM1a', ->
              beforeEach ->
                sut.toggleCell TYPE_ALARM,1,0

              it 'has active ETI', ->
                expect(sut.isPlantETIActive()).toBeTruthy()

              it 'has inactive MTI', ->
                expect(sut.isPlantMTIActive()).toBeFalsy()

              it 'is not virulent', ->
                expect(sut.isPathogenVirulent()).toBeFalsy()

    describe 'EFFECTOR2b+ALARM2b', ->
      beforeEach ->
        sut.toggleCell TYPE_EFFECTOR,2,1
        sut.toggleCell TYPE_ALARM,2,1

      it 'has active ETI', ->
        expect(sut.isPlantETIActive()).toBeTruthy()

      it 'has no active MTI', ->
        expect(sut.isPlantMTIActive()).toBeFalsy()

      it 'is virulent', ->
        expect(sut.isPathogenVirulent()).toBeFalsy()

    describe 'EFFECTOR1a+ALARM1b', ->
      beforeEach ->
        sut.toggleCell TYPE_EFFECTOR,1,0
        sut.toggleCell TYPE_ALARM,1,1

      it 'has inactive ETI', ->
        expect(sut.isPlantETIActive()).toBeFalsy()

      it 'has no active MTI', ->
        expect(sut.isPlantMTIActive()).toBeFalsy()

      it 'is virulent', ->
        expect(sut.isPathogenVirulent()).toBeTruthy()
