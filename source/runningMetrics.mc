import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;
import Toybox.Math;
import Toybox.ActivityMonitor;


// MAIN METRICS CLASS
class RunningMetrics {

    // Init
    var distance;
    var duration;
    var runs;
    var climbed;
    var n_days;

    // Initialize instance
    function initialize(window) {

        // Initialize metrics
        distance = 0;
        duration = 0;
        runs = 0;
        climbed = 0;

        // Get start moment
        n_days = (window == 0) ? get_day_of_week() : 7; // 1 to 7
    }

    function compute() {

        //--------------------------------------
        // Distance, duration and runs count
        var n_days_id = self.get_n_days_id(self.n_days);

        // Get user activity history
        var activityIterator = UserProfile.getUserActivityHistory();

        if (activityIterator != null) {

            // Go through activity and keep only runs from the current week
            var activity = activityIterator.next();

            while (activity != null) {

                // activity is not null but all its attributes are during an activity
                // This is the case when using the "resume later" option !
                if ((activity.type == 1) && activity.startTime.greaterThan(n_days_id)) {

                    // Compute aggregated metrics
                    distance += activity.distance;
                    duration += activity.duration.value();  // Duration type even if should be Number according to API docs (Type checking must be off in extension settings to compile)
                    runs++;
                }
                activity = activityIterator.next();
            }
        }

        //--------------------------------------
        // Elevation gain history
        var history = ActivityMonitor.getHistory();

        // Past days
        var loop = (self.n_days <= history.size()) ? self.n_days-1 : history.size();
        var daily_floor;
        for (var i = 0; i < loop; i++) {
            daily_floor = (history[i].floorsClimbed < history[i].floorsDescended) ? history[i].floorsDescended : history[i].floorsClimbed;
            climbed += daily_floor * 3;
        }
        
        // Adding current day
        var info = ActivityMonitor.getInfo();
        if (info.floorsClimbed < info.floorsDescended) {
            climbed += info.floorsDescended * 3;
        } else {
            climbed += info.floorsClimbed * 3;
        }

    }

    function get_distance() {
        return (self.distance / 1000.0).format("%.1f");
    }

    function get_time() {
        var div = self.duration / 3600.0;
        var hours = Math.floor(div);
        var mins = Math.round((div - hours) * 60);
        // Special case
        if (mins == 60) {
            hours++;
            mins = 0;
        }
        return Lang.format("$1$h$2$", [hours.format("%d"), mins.format("%02d")]);
    }

    function get_runs() {
        return self.runs.format("%d");
    }

    function get_climbed() {
        return self.climbed;
    }
}