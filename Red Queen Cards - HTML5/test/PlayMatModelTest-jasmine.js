/**
 * Created with JetBrains PhpStorm.
 * User: badams
 * Date: 7/6/13
 * Time: 9:46 PM
 * To change this template use File | Settings | File Templates.
 */
describe('Playmat Model', function () {
    var sut;

    beforeEach(function () {
        sut = new PlayMat();
    });

    afterEach(function () {
        sut = null;
    });

    it('starts with an inactive feature', function () {
        expect(sut.isCellActive(TYPE_FEATURE, 1)).toBeFalsy();
    });

    it("allows features to be toggled on", function () {
        expect(sut.toggleCell(TYPE_FEATURE, 1)).toBeTruthy();
    });

    it("allows features to be toggled back off", function () {
        sut.toggleCell(TYPE_FEATURE, 1);
        expect(sut.toggleCell(TYPE_FEATURE, 1)).toBeFalsy();
    });
});

