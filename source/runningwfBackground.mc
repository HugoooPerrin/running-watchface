import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Math;

class Background extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc as Dc) as Void {

        var size = 260;
        var length = 50;

        var center = size / 2;
        var cc1 = Math.round(center / Math.sqrt(2));
        var cc2 = Math.round((center-length) / Math.sqrt(2));

        // Set the background color then call to clear the screen
        dc.setColor(getApp().getProperty("ForegroundColor") as Number, getApp().getProperty("BackgroundColor") as Number);
        dc.clear();

        // Background line structure
        dc.setColor(Graphics.COLOR_WHITE, getApp().getProperty("BackgroundColor") as Number);
        dc.setPenWidth(2);

        dc.drawLine(0, center, length, center); // left
        dc.drawLine(size, center, size-length, center); // right

        dc.drawLine(center, 0, center, length); // up
        dc.drawLine(center, size, center, size-length); // down

        dc.drawLine(center+cc1, center+cc1, center+cc2, center+cc2); // right-down
        dc.drawLine(center+cc1, center-cc1, center+cc2, center-cc2); // right-up

        dc.drawLine(center-cc1, center+cc1, center-cc2, center+cc2); // left-down
        dc.drawLine(center-cc1, center-cc1, center-cc2, center-cc2); // left-up

        // Set the background and foreground color
        dc.setColor(getApp().getProperty("ForegroundColor") as Number, getApp().getProperty("BackgroundColor") as Number);
    }
}
