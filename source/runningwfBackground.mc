import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.System;

class Background extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc as Dc) as Void {

        // Background line structure
        var size = 260;
        var length = 50;

        var center = size / 2;
        var cc1 = Math.round(center / Math.sqrt(2));
        var cc2 = Math.round((center-length) / Math.sqrt(2));

        dc.setColor(Graphics.COLOR_WHITE, Properties.getValue("BackgroundColor") as Number);
        dc.setPenWidth(2);

        dc.drawLine(0, center, length, center); // left
        dc.drawLine(size, center, size-length, center); // right

        dc.drawLine(center, 0, center, length); // up
        dc.drawLine(center, size, center, size-length); // down

        dc.drawLine(center+cc1, center+cc1, center+cc2, center+cc2); // right-down
        dc.drawLine(center+cc1, center-cc1, center+cc2, center-cc2); // right-up

        dc.drawLine(center-cc1, center+cc1, center-cc2, center+cc2); // left-down
        dc.drawLine(center-cc1, center-cc1, center-cc2, center-cc2); // left-up

        // System.println(center-cc1); 38
        // System.println(center-cc2); 73

        // Finally set the background and foreground color
        dc.setColor(Properties.getValue("ForegroundColor") as Number, Properties.getValue("BackgroundColor") as Number);
    }
}
