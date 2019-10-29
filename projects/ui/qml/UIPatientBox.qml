import QtQuick 2.4
import Qt.labs.folderlistmodel 2.12
import com.biogearsengine.ui.scenario 1.0

UIComboBoxForm {
    id: root
    property alias label :root.label
    property Scenario scenario



    FolderListModel {
        id: folderModel
        nameFilters: ["*.xml"]
        folder: "file:patients"
        showDirs : false
        }

    comboBox.model: folderModel
    comboBox.textRole: 'fileName'
    comboBox.currentIndex: 0

    comboBox.onAccepted:  {
        console.log("onAccepted %1, %2".arg(comboBox.currentIndex).arg(comboBox.currentText))
        scenario.load_patient(comboBox.currentText);
        console.log(scenario.patient_name());
    }
    comboBox.onActivated:  {
        console.log("onActivated %1".arg(index))
        scenario.load_patient(comboBox.currentText);
        console.log(scenario.patient_name());
    }
    onScenarioChanged: {
        console.log("UIPatientBox's Scenario Changed " + scenario.patient_name())
    }
}







