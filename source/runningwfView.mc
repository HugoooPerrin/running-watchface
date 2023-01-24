import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;

class runningwfView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();

        var method = getApp().getProperty("METHOD_ID") as Number;

        if (method == 0) {
            // Compute weekly metrics
            var window = getApp().getProperty("DATA_SOURCE_ID") as Number;
            var running_metrics = new RunningMetrics(window);

            running_metrics.compute();
            
            var distance = running_metrics.get_distance();
            var time = running_metrics.get_time();
            var runs = running_metrics.get_runs();
            var climbed = running_metrics.get_climbed();

            // Store them
            Storage.setValue("distance", distance);
            Storage.setValue("time", time);
            Storage.setValue("runs", runs);
            Storage.setValue("climbed", climbed);
        }
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

        // Get data source
        var data_source = getApp().getProperty("DATA_SOURCE_ID") as Number;

        //-----------------------------------
        // Get the current time and format it correctly
        var clockTime = System.getClockTime();

        // Update hours
        var hours = View.findDrawableById("HoursLabel") as Text;
        hours.setText(clockTime.hour.format("%02d"));

        // Update minutes
        var minutes = View.findDrawableById("MinutesLabel") as Text;
        minutes.setColor(getApp().getProperty("ForegroundColor") as Number);
        minutes.setText(clockTime.min.format("%02d"));

        //-----------------------------------
        // DATA
        var method = getApp().getProperty("METHOD_ID") as Number;

        var distance = "--";
        var time = "--";
        var runs = "--";
        var climbed = "--";

        if (method == 0) {
            // Get pre-computed weekly metrics
            distance = Storage.getValue("distance");
            time = Storage.getValue("time");
            runs = Storage.getValue("runs");
            climbed = Storage.getValue("climbed");

        } else if (method == 1) {
            // Compute weekly metrics
            var window = getApp().getProperty("DATA_SOURCE_ID") as Number;
            var running_metrics = new RunningMetrics(window);

            running_metrics.compute();
            
            distance = running_metrics.get_distance();
            time = running_metrics.get_time();
            runs = running_metrics.get_runs();
            climbed = running_metrics.get_climbed();
        }

        // Elevation gain
        var name1 = View.findDrawableById("Name1") as Text;
        var data1 = View.findDrawableById("Data1") as Text;
        name1.setColor(getApp().getProperty("ForegroundColor") as Number);
        name1.setText("Climb");
        data1.setText(climbed.format("%d"));

        // Duration
        var name2 = View.findDrawableById("Name2") as Text;
        var data2 = View.findDrawableById("Data2") as Text;
        name2.setColor(getApp().getProperty("ForegroundColor") as Number);
        name2.setText("Time");
        data2.setText(time);

        // Distance
        var name3 = View.findDrawableById("Name3") as Text;
        var data3 = View.findDrawableById("Data3") as Text;
        name3.setColor(getApp().getProperty("ForegroundColor") as Number);
        name3.setText("Km");
        data3.setText(distance);

        // Number of runs
        var name4 = View.findDrawableById("Name4") as Text;
        var data4 = View.findDrawableById("Data4") as Text;
        name4.setColor(getApp().getProperty("ForegroundColor") as Number);
        if (runs.toNumber() <= 1) {
            name4.setText("Run");
        } else {
            name4.setText("Runs");
        }
        data4.setText(runs);

        // Bonus field 1
        var bonus_field_1 = new BonusMetrics(getApp().getProperty("BONUS_1_ID") as Number);

        var name5 = View.findDrawableById("Name5") as Text;
        var data5 = View.findDrawableById("Data5") as Text;
        name5.setColor(getApp().getProperty("ForegroundColor") as Number);
        name5.setText(bonus_field_1.get_title());
        data5.setText(bonus_field_1.get_value());

        // Date
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

        var name6 = View.findDrawableById("Name6") as Text;
        var data6 = View.findDrawableById("Data6") as Text;
        name6.setColor(getApp().getProperty("ForegroundColor") as Number);
        name6.setText(today.month);
        data6.setText(today.day.format("%02d"));

        // Battery
        var battery = Math.round(System.getSystemStats().battery).format("%d") + "%";

        var name7 = View.findDrawableById("Name7") as Text;
        var data7 = View.findDrawableById("Data7") as Text;
        name7.setColor(getApp().getProperty("ForegroundColor") as Number);
        name7.setText("Batt.");
        data7.setText(battery);

        // Bonus field 2
        var bonus_field_2 = new BonusMetrics(getApp().getProperty("BONUS_2_ID") as Number);

        var name8 = View.findDrawableById("Name8") as Text;
        var data8 = View.findDrawableById("Data8") as Text;
        name8.setColor(getApp().getProperty("ForegroundColor") as Number);
        name8.setText(bonus_field_2.get_title());
        data8.setText(bonus_field_2.get_value());
        
        //-----------------------------------
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Hour strip
        draw_strip(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {

        var method = getApp().getProperty("METHOD_ID") as Number;

        if (method == 0) {
            // Compute weekly metrics
            var window = getApp().getProperty("DATA_SOURCE_ID") as Number;
            var running_metrics = new RunningMetrics(window);

            running_metrics.compute();
            
            var distance = running_metrics.get_distance();
            var time = running_metrics.get_time();
            var runs = running_metrics.get_runs();
            var climbed = running_metrics.get_climbed();

            // Store them
            Storage.setValue("distance", distance);
            Storage.setValue("time", time);
            Storage.setValue("runs", runs);
            Storage.setValue("climbed", climbed);
        }
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }
}
