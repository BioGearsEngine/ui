import QtQuick 2.4

import com.biogearsengine.ui.scenario 1.0

ControlsForm {
    id: root
    signal restartClicked()
    signal pauseClicked()
    signal playClicked()
    signal speedToggled(int speed)

    signal patientMetricsChanged(PatientMetrics metrics )
    signal patientStateChanged(PatientState patientState )
    signal patientConditionsChanged(PatientConditions conditions )
    signal actionMenuClosed()

    property bool running : false
    property bool paused : false
    property bool actionMenuVisible : false
    property int speed  :1
    property Scenario scenario : biogears_scenario
    patientBox.scenario : biogears_scenario

    Scenario {
        id: biogears_scenario
        onPatientMetricsChanged: {
            if(metrics){
                root.respritoryRate.value        = metrics.RespritoryRate
                root.heartRate.value             = metrics.HeartRate 
                root.core_temp_c.value           = metrics.CoreTemp + "c"
                root.oxygenSaturation.value      = metrics.OxygenSaturation
                root.systolicBloodPressure.value = metrics.SystolicBloodPressure
                root.dystolicBloodPressure.value = metrics.DiastolicBloodPressure
                

                var seconds = metrics.SimulationTime % 60
                var minutes = Math.floor(metrics.SimulationTime / 60) % 60
                var hours   = Math.floor(metrics.SimulationTime / 3600)

                seconds = (seconds<60) ? "0%1".arg(seconds) : "%1".arg(seconds)
                minutes = (minutes<60) ? "0%1".arg(minutes) : "%1".arg(minutes)

                playback.simulationTime = "%1:%2:%3".arg(hours).arg(minutes).arg(seconds)
                root.patientMetricsChanged(metrics)
                
            }
        }
        onPatientStateChanged: {
                root.age_yr.value    = patientState.Age
                root.gender.value    = patientState.Gender
                root.height_cm.value = patientState.Height + " cm"
                root.weight_kg.value = patientState.Weight + " kg"
                root.condition.value = patientState.ExerciseState
                root.bodySufaceArea.value       = patientState.BodySurfaceArea
                root.bodyMassIndex.value        = patientState.BodyMassIndex
                root.fat_pct.value              = patientState.BodyFat
                
                root.patientStateChanged(patientState)
        }
        onPatientConditionsChanged:{
            root.patientConditionsChanged(conditions)
        }
    }
    playback.onRestartClicked: {
            console.log("Restarting BioGears")
            biogears_scenario.restart()
            root.stopClicked()
        } 
    playback.onPauseClicked: {
        console.log("Pausing BioGears")
        if(root.running)
        {
            root.paused = biogears_scenario.pause_play()
        }
        root.pauseClicked()
    }
    playback.onPlayClicked: {
        console.log("Starting BioGears")
        biogears_scenario.run()
        root.running = true;
        root.playClicked()
    }
    playback.onRateToggleClicked: {
        console.log("Setting BioGears run rate to %1".arg(speed))
        biogears_scenario.speed_toggle(speed)
        root.speedToggled(speed)
        root.speed = speed
    } 
    action_1.onPressed:{
        console.log("Hemorrhage Stop") 
        biogears_scenario.create_hemorrhage_action("LeftArm",0.0);
    } 
    action_2.onPressed:{
        console.log("Hemorrhage Mild")
        biogears_scenario.create_hemorrhage_action("LeftArm",5.0);
    } 
    action_3.onPressed:{
        console.log("Hemorrhage Extreme") 
        biogears_scenario.create_hemorrhage_action("Aorta",250.0);
    } 
    action_4.onPressed:{
        console.log("ASthma Attack") 
    } 
    action_5.onPressed:{
        console.log("Morphine Drip") 
    } 
    action_6.onPressed:{
        console.log("Burn Patient 25%") 
    } 
    action_7.onPressed:{
        console.log("Mild Infection") 
    }
    explorer.onClicked : {
                //var win = Qt.createQmlObject('import QtQuick.Window 2.12; Window {}', root, "TestWin");
                //win.height = root.parent.height //Makes the window the height of the full app window, not just this column layout
                //win.width = root.width
                //win.title = "BioGears Action Menu"
                if(!actionMenuVisible){
                root.actionMenuVisible = true
                var itemCoor = explorer.mapToItem(root, x, y)
                var globalCoor = explorer.mapToGlobal(x, y)
                var windowX = globalCoor.x - itemCoor.x - root.width
                var windowY = globalCoor.y - itemCoor.y

                var winComponent = Qt.createComponent("UIActionExplorer.qml")
                var explorerWin = winComponent.createObject(root, {"x" : windowX, "y" : windowY, "height" : root.parent.height, "width" : root.width})
                //Unlike most items, a new Window's position is defined relative to Screen, and not its parent
                //The mapTo functions take the coordinates of "this" (explorer button) and converts them relative to the given item 
                //(for mapToItem)and the Screen (for mapToGlobal).  We then substract the window width to move it over left so that
                //its right edge aligns with the main app window.  When (if) we make a separate file to implement this window 
                //(e.g. UIActionWindow.qml), we'll probably need to revisit this
                explorerWin.onClosing.connect(root.actionMenuClosed)
                explorerWin.show()

                }
    }
    onActionMenuClosed : {
        actionMenuVisible = false
    }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:600;width:300}
}
 ##^##*/
