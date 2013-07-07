/**
 * Created with JetBrains PhpStorm.
 * User: badams
 * Date: 6/30/13
 * Time: 5:21 PM
 * To change this template use File | Settings | File Templates.
 */

TestCase("PlayMatModelTest", {
    "test initial": function() {
        var sut = new PlayMat();
        assertFalse(sut.isCellActive(TYPE_FEATURE, 1));
    },
    "test toggle": function() {
        var sut = new PlayMat();
        assertTrue(sut.toggleCell(TYPE_FEATURE, 1));
    }
});
