import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Window 2.12

Window {
    //property alias actionMenuModel : actionMenuModel

   ListView {
        anchors.fill : parent
        clip : true
        model : actionMenuModel
        delegate : actionMenuDelegate
    
        section {
            property : "section"
            delegate : Rectangle {
                color : "#7CB342"
                width : parent.width
                height : childrenRect.height
                Text {
                    anchors.horizontalCenter : parent.horizontalCenter
                    text : section
                    font.pointSize : 14
                }
            }
        }
    }

    Component {
        id : actionMenuDelegate
        Text {
            text : name
            font.pointSize : 12
        }
    }
    ListModel {
        id : actionMenuModel
        ListElement { name : "Exercise"; section : "Patient Actions"}
        ListElement { name : "ConsumeMeal"; section : "Patient Actions"}
        ListElement { name : "Hemorrhage"; section : "Insults"}
        ListElement { name : "TensionPneumothorax"; section : "Insults"}
        ListElement { name : "Sepsis"; section : "Insults"}
        ListElement { name : "AsthmaAttack"; section : "Insults"}
        ListElement { name : "AirwayObstruction"; section : "Insults"}
        ListElement { name : "TraumaticBrainInjury"; section : "Insults"}
        ListElement { name : "Bronchoconstriction"; section : "Insults" }
        ListElement { name : "AcuteStress"; section : "Insults"}
        ListElement { name : "DrugAdministration"; section : "Interventions"}
        ListElement { name : "NeedleDecompression"; section : "Interventions"}
        ListElement { name : "Inhaler"; section : "Interventions" }
        ListElement { name : "AnesthesiaMachine"; section : "Interventions"}
        ListElement { name : "Transfusion"; section : "Interventions"}
        ListElement { name : "Diabetes (Type 1)"; section : "Conditions"}
        ListElement { name : "Diabetes (Type 2)"; section : "Conditions"}
        ListElement { name : "Bronchitis"; section : "Conditions"}

    }

}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
