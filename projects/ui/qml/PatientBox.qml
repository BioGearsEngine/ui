import QtQuick 2.12
import QtQuick.Controls 2.12
import Qt.labs.folderlistmodel 2.12
import com.biogearsengine.ui.scenario 1.0

UIComboBox {
    id: root
    property alias label :root.label
    property Scenario scenario
    signal patientFolderReady()
    splitToken : '@'

    FolderListModel {
        id: folderModel
        nameFilters: ["*.xml"]
        folder: "file:states"
        showDirs : false
        onStatusChanged : {
            if (folderModel.status == FolderListModel.Ready){
                root.patientFolderReady();
            }
        }
    }

    comboBox.font.pointSize : 10
    comboBox.model: folderModel
    comboBox.displayText: comboBox.model.status == FolderListModel.Ready ? comboBox.model.get(comboBox.currentIndex,'fileName').split('@')[0] : "Not loaded"
    comboBox.currentIndex: 4  //Corresponds to DefaultMale
  
    comboBox.onAccepted:  {
        scenario.load_patient(comboBox.model.get(comboBox.currentIndex,'fileName'));
    }
    comboBox.onActivated:  {
        scenario.load_patient(comboBox.model.get(comboBox.currentIndex,'fileName'));
    }
    onScenarioChanged: {

    }
    onPatientFolderReady:{
        scenario.load_patient(comboBox.model.get(comboBox.currentIndex,'fileName'));
    }
}
