import Toybox.Application;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;
import Toybox.Time.Gregorian;

function get_n_days_id(num_days) {
    var n_days_secs = new Time.Duration(-1 * (num_days - 1) * Gregorian.SECONDS_PER_DAY);
    var n_days_info = Gregorian.utcInfo(Time.now().add(n_days_secs), Time.FORMAT_SHORT);
    return Gregorian.moment({
        :year   => n_days_info.year,
        :month  => n_days_info.month,
        :day    => n_days_info.day,
        :hour   => 0,
        :minute => 1,
    });
}

function get_day_of_week() {

    // Get Garmin day of week
    var day_of_week = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT).day_of_week;

    // Correcting action to have 1=monday, 2=tuesday, etc.
    if (day_of_week > 1) {
        day_of_week -= 1;
    } else {
        day_of_week = 7;
    }

    return day_of_week;
}


function draw_strip(dc) {

    dc.setColor(Properties.getValue("BackgroundColor") as Number, Properties.getValue("BackgroundColor") as Number);
    dc.setPenWidth(2);

    var slope = 1;
    var step = 10;

    var x_min = 80.0;
    var x_max = 180.0;

    var y_min = 65.0;
    var y_max = 130.0;

    for (var i = 30; i <= 120; i += step) {

        var x1;
        var x2;
        var y1;
        var y2;

        if (i < x_min) {
            x1 = x_min;
            y1 = y_min + slope * (x_min - i);
        } else {
            x1 = i;
            y1 = y_min;
        }

        var j = (y_max - y_min + slope * i) / slope;

        if (j > x_max) {
            x2 = x_max;
            y2 = y_min + slope * (x_max - i);
        } else {
            y2 = y_max;
            x2 = j;
        }

        dc.drawLine(x1, y1, x2, y2);
    }
}