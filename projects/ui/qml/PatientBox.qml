import QtQuick 2.12
import QtQuick.Controls 2.12
import Qt.labs.folderlistmodel 2.12
import com.biogearsengine.ui.scenario 1.0

UIComboBox {
    id: root
    property alias label :root.label
    property Scenario scenario
    
    signal patientFolderReady()

    function loadState (){
      scenario.restart(comboBox.model.get(comboBox.currentIndex, 'fileName'));
    }

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

    splitToken : '@'    //UIComboBox will use this to generate PatientState from PatientState@0s
    comboBox.textRole : 'fileBaseName'
    comboBox.font.pointSize : 10
    comboBox.model: folderModel
    comboBox.displayText: comboBox.model.status == FolderListModel.Ready ? comboBox.model.get(comboBox.currentIndex,'fileBaseName').split('@')[0] : "Not loaded"
    comboBox.currentIndex: 4  //Corresponds to DefaultMale
  
    comboBox.onAccepted:  {
        root.loadState();
    }
    comboBox.onActivated:  {
        root.loadState();
    }
    onScenarioChanged: {

    }
    onPatientFolderReady:{
        root.loadState();
    }
}
