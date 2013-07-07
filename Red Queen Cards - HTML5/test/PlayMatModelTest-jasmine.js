/**
 * Created with JetBrains PhpStorm.
 * User: badams
 * Date: 7/6/13
 * Time: 9:46 PM
 * To change this template use File | Settings | File Templates.
 */
describe('Playmat Model', function () {
    var mat;

    beforeEach(function () {
        mat = new PlayMat();
    });

    afterEach(function () {
        mat = null;
    });

    it('starts with an inactive feature', function () {
        expect(mat.isCellActive(TYPE_FEATURE, 1)).toBeFalsy();
    });

    it("allows features to be toggled on", function () {
        expect(mat.toggleCell(TYPE_FEATURE, 1)).toBeTruthy();
    });

    it("allows features to be toggled back off", function () {
        mat.toggleCell(TYPE_FEATURE, 1);
        expect(mat.toggleCell(TYPE_FEATURE, 1)).toBeFalsy();
    });
});

