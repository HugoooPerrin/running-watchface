import Toybox.Math;
import Toybox.Time;
import Toybox.Time.Gregorian;

function get_day_of_week() {

    // Get Garmin day of week
    var day_of_week = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT).day_of_week;

    // Correct to have 1=monday, 2=tuesday, etc.
    if (day_of_week > 1) {
        day_of_week -= 1;
    } else {
        day_of_week = 7;
    }

    return day_of_week;
}