import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;
import Toybox.Math;
import Toybox.ActivityMonitor;
import Toybox.SensorHistory;


// BONUS METRICS CLASS
class BonusMetrics {

    // Init
    var title;
    var value;
    var info;
    var profile;

    // Initialize instance
    function initialize(metric_id) {

        // Countdown
        if (metric_id == 0) {
            self.compute_counter();

        // VO2max
        } else if (metric_id == 1) {
            self.compute_vo2_max();

        // Average resting heart rate
        } else if (metric_id == 2) {
            self.compute_avg_resting_hr();

        // Average heart rate
        } else if (metric_id == 3) {
            self.compute_avg_hr();

        // Time to recovery
        } else if (metric_id == 4) {
            self.compute_time_to_recovery();

        // Daily steps
        } else if (metric_id == 5) {
            self.compute_steps();

        // Custom data
        } else if (metric_id == 6) {
            self.compute_custom_data();

        // Daily resting heart rate
        } else if (metric_id == 7) {
            self.compute_resting_hr();

        // Seconds
        } else if (metric_id == 8) {
            self.compute_seconds();

        // Elevation
        } else if (metric_id == 9) {
            self.compute_elevation();

        // Acute to chronic ratio
        } else if (metric_id == 10) {
            self.compute_acute_chronic_ratio();
        }

    }

    function get_title() {
        return self.title;
    }

    function get_value() {
        return self.value;
    }

    function compute_vo2_max() {
        profile = UserProfile.getProfile();

        title = "VO2";
        value = (profile.vo2maxRunning != null) ? profile.vo2maxRunning.format("%d") : "--";
    }

    function compute_counter() {
        var race_day = new Time.Moment(Properties.getValue("RACE_DATE_ID") as Number);

        var now = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
        var today = Gregorian.moment({
            :year   => now.year,
            :month  => now.month,
            :day    => now.day,
        });
    
        title = "Race";
        value = Math.round(race_day.subtract(today).value() / 86400.0).format("%d")+"d";
    }

    function compute_avg_resting_hr() {
        profile = UserProfile.getProfile();

        title = "RHR";
        value = (profile.averageRestingHeartRate != null) ? profile.averageRestingHeartRate.format("%d") : "--";
    }

    function compute_avg_hr() {
        var avg_hr;
        var one_minute = new Time.Duration(60);
        var hrIterator = ActivityMonitor.getHeartRateHistory(one_minute, true);

        if (hrIterator != null) {

            var hr_sum = 0.0;
            var hr_count = 0;

            // Go through sample and keep only valid measure
            var hrSample = hrIterator.next();

            while (hrSample != null) {

                if (hrSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {

                    // Compute aggregated metrics
                    hr_sum += hrSample.heartRate;
                    hr_count++;
                }
                hrSample = hrIterator.next();
            }
            avg_hr = (hr_count > 0) ? Math.round(hr_sum / hr_count).format("%d") : "--";

        } else {
            avg_hr = "--";
        }

        title = "HR";
        value = avg_hr;
    }

    function compute_time_to_recovery() {
        info = ActivityMonitor.getInfo();

        title = "Recov.";
        value = (info.timeToRecovery != null) ? info.timeToRecovery.format("%d")+"h" : "--";
    }

    function compute_steps() {
        info = ActivityMonitor.getInfo();

        title = "Steps";
        if (info.steps == null) {
            value = "--";
        } else if (info.steps < 9951) {
            value = (info.steps / 1000.0).format("%.1f")+"k";
        } else {
            value = Math.round(info.steps / 1000.0).format("%d")+"k";
        }
    }

    function compute_custom_data() {

        title = Properties.getValue("NAME_ID");
        value = Properties.getValue("DATA_ID");
    }

    function compute_resting_hr() {
        profile = UserProfile.getProfile();

        title = "rHR";
        value = (profile.restingHeartRate != null) ? profile.restingHeartRate.format("%d") : "--";
    }

    function compute_seconds() {
        var clockTime = System.getClockTime();

        title = "Secs";
        value = clockTime.sec.format("%02d");
    }

    function compute_elevation() {
        info = SensorHistory.getElevationHistory({
            :period => 1,
        });

        title = "Alti.";
        value = (info != null) ? info.next().data.format("%d") : "--";
    }

    function compute_acute_chronic_ratio() {

        // Var
        var acute_days = Properties.getValue("ACUTE_ID") as Number;
        var acute_duration;
        var chronic_days = Properties.getValue("CHRONIC_ID") as Number;
        var chronic_duration;

        // Initialize counters
        acute_duration = 0;
        chronic_duration = 0;

        // Get dates
        var acute_days_id = get_n_days_id(acute_days);
        var chronic_days_id = get_n_days_id(chronic_days);

        // Get user activity history
        var activityIterator = UserProfile.getUserActivityHistory();

        // Iterate through runs and agg durations
        if (activityIterator != null) {

            var activity = activityIterator.next();

            while (activity != null) {

                if ((activity.type == 1) && activity.startTime.greaterThan(acute_days_id)) {
                    acute_duration += activity.duration.value(); // seconds
                }

                if ((activity.type == 1) && activity.startTime.greaterThan(chronic_days_id)) {
                    chronic_duration += activity.duration.value(); // seconds
                }

                activity = activityIterator.next();
            }
        }

        // Compute ratio
        if ((chronic_duration == 0) | (chronic_days == 0) | (acute_days == 0)) {
            value = "--";
        } else {
            var load = (acute_duration.toFloat() / acute_days) / (chronic_duration.toFloat() / chronic_days) - 1;
            var sym = (load > 0) ? "+" : "";
            value = sym + Math.round(100 * load).format("%d") + "%";
        }
        title = "Load";
    }
}
        