import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;
import Toybox.Math;
import Toybox.ActivityMonitor;


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
        var race_day = new Time.Moment(getApp().getProperty("RACE_DATE_ID") as Number);

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

        title = getApp().getProperty("NAME_ID");
        value = getApp().getProperty("DATA_ID");
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
}
        