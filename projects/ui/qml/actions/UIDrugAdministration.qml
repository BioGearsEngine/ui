import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

UIActionForm {
  id: root
  color: "transparent"
  border.color: "black"

  property string adminRoute : ""
  property double  dose : 0.0
  property double  concentration : 0.0
  property double rate : 0.0
  property string drug : ""
  

  actionType : "Administration"
  fullName  : {
    let tmp =  "<b>%1 %2</b><br>".arg(adminRoute).arg(actionType)
    if (root.adminRoute == 'Bolus-Intraarterial' ||
           root.adminRoute == 'Bolus-Intramuscular' || 
           root.adminRoute == 'Bolus-Intravenous')
    {
      tmp += "<br> Dose %1mL<br> Concentration %2ug/mL".arg(root.dose).arg(root.concentration)
    } else if ( root.adminRoute == 'Infusion-Intravenous') {
      tmp += "<br> Concentration %1ug/mL<br> Concentration %2mL/min".arg(root.concentration).arg(root.rate)
    } else {
      tmp += "<br> Dose %1mg".arg(root.dose)
    }
    return tmp
  }
  shortName : "<font color=\"lightsteelblue\"> %2</font> <b>%1</b>".arg(actionType).arg(drug)

  details : Component  {
    GridLayout {
      id: grid
      columns : 4
      rows    : 4
      width : root.width -5
      anchors.centerIn : parent      
      Label {
        font.pixelSize : 10
        font.bold : true
        color : "blue"
        text : "%1".arg(actionType)
      }      
      Label {
        font.pixelSize : 10
        font.bold : false
        color : "steelblue"
        text : "[%1]".arg(root.compartment)
        Layout.alignment : Qt.AlignHCenter
      }
 //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : "Dose"
      }      
      Slider {
        id: dosage
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1000
        stepSize : 1
        value : root.dose

        enabled :  (root.adminRoute!=  'Infusion-Intravenous') ?  true : false

        onMoved : {
          root.dose = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : {
              if (root.adminRoute == 'Bolus-Intraarterial' ||
                  root.adminRoute == 'Bolus-Intramuscular' || 
                  root.adminRoute == 'Bolus-Intravenous')
                return "%1%mL".arg(root.dose)
              else (root.adminRoute == 'Oral' || root.adminRoute == 'Transmucosal')
                return "%1mg".arg(root.dose)
          }
      }
      //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : "Concentration"
      }      
      Slider {
        id: concentration
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1000
        stepSize : 1
        value : root.concentration
        enabled : {
          if ( root.adminRoute == 'Oral' || root.adminRoute == 'Transmucosal') {
            return false;
          } else {
            return true;
          }
        }
        onMoved : {
          root.concentration = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1ug/mL".arg(root.concentration )
      }
    //Column 4
      Label {
        Layout.row : 3
        Layout.column : 0
        text : "Flow Rate"
      }      
      Slider {
        id: flowRate
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1000
        stepSize : 1
        value : root.rate
        enabled : {
          if ( root.adminRoute == 'Infusion-Intravenous' ) {
            return true;
          } else {
            return false;
          }
        }
        onMoved : {
          root.rate = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1ml/min".arg(root.rate )
      }
    
      // Column 5
      Rectangle {
        id: toggle      
        Layout.row : 4
        Layout.column : 2
        Layout.columnSpan : 2
        Layout.fillWidth : true
        Layout.preferredHeight : 30      
        color:        root.active? 'green': 'red' // background
        opacity:      active  &&  !mouseArea.pressed? 1: 0.3 // disabled/pressed state      
        Text {
          text:  root.active?    'On': 'Off'
          color: root.active? 'white': 'white'
          horizontalAlignment : Text.AlignHCenter
          width : pill.width
          x:    root.active ? 0: pill.width
          font.pixelSize: 0.5 * toggle.height
          anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle { // pill
            id: pill
    
            x: root.active ? pill.width: 0 // binding must not be broken with imperative x = ...
            width: parent.width * .5;
            height: parent.height // square
            border.width: parent.border.width
    
        }
        MouseArea {
            id: mouseArea
    
            anchors.fill: parent
    
            drag {
                target:   pill
                axis:     Drag.XAxis
                maximumX: toggle.width - pill.width
                minimumX: 0
            }
    
            onReleased: { // Did we drag the button far enough.
              if( root.active) {
                  if(pill.x < toggle.width - pill.width) {
                    root.active = false // right to left
                  }
              } else {
                  if(pill.x > toggle.width * 0.5 - pill.width * 0.5){
                    root.active = true // left  to right
                } 
              }
            }
            onClicked: {
              root.active = !root.active
            }// emit
        }
      }
    }
  }// End Details Component
 
  onActivate:   { 
    if (root.adminRoute == 'Bolus-Intraarterial' ) {
      scenario.create_substance_bolus_action(drug, 0, dose, concentration) 
    } else if ( root.adminRoute == 'Bolus-Intramuscular' ) {
      scenario.create_substance_bolus_action(drug, 1, dose, concentration) 
    } else if ( root.adminRoute == 'Bolus-Intravenous') {
      scenario.create_substance_bolus_action(drug, 2, dose, concentration) 
    }  else if ( root.adminRoute == 'Infusion-Intravenous') {
      scenario.create_substance_compound_infusion_action(drug, concentration, rate) 
    } else if ( root.adminRoute == 'Infusion-Intravenous') {
      scenario.create_substance_oral_action(drug, 0, dose) 
    } else {
      scenario.create_substance_oral_action(drug, 1, dose) 
    }
  }
  onDeactivate: { 
       if (root.adminRoute == 'Bolus-Intraarterial' ) {
      scenario.create_substance_bolus_action(drug, 0, 0, 0) 
    } else if ( root.adminRoute == 'Bolus-Intramuscular' ) {
      scenario.create_substance_bolus_action(drug, 1, 0, 0) 
    } else if ( root.adminRoute == 'Bolus-Intravenous') {
      scenario.create_substance_bolus_action(drug, 2, 0, 0) 
    }  else if ( root.adminRoute == 'Infusion-Intravenous') {
      scenario.create_substance_compound_infusion_action(drug, 0, 0) 
    } else if ( root.adminRoute == 'Infusion-Intravenous') {
      scenario.create_substance_oral_action(drug, 0, 0) 
    } else {
      scenario.create_substance_oral_action(drug, 1, 0) 
    }
  }
}