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

  property string description : ""
  property string connection : ""
  property string primaryGas : ""
  property string o2Source : ""
  property string leftChamberSub : ""
  property string rightChamberSub : ""
  property double inletFlow_L_Per_min : 5.0
  property double ieRatio : 0.5
  property double pMax_cmH2O : 10.0
  property double peep_cmH2O : 1.0
  property double respirationRate_Per_min : 12.0
  property double reliefPressure_cmH2O : 50.0 
  property double o2Fraction : 0.25
  property double leftChamberFraction : 0.0
  property double rightChamberFraction : 0.0
  property double bottle1_mL : 0.0
  property double bottle2_mL : 0.0

  actionType : "Anesthesia Machine"
  fullName  :  "<b>%1</b><br>".arg(description)

  shortName : "<font color=\"lightsteelblue\"> %2</font> <b>%1</b>".arg(actionType).arg(connection)

  details : Component  {
    GridLayout {
      id: grid
      columns : 4
      rows    : 13
      width : root.width -5
      anchors.centerIn : parent 
      //Row 1
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
        text : "[%1]".arg(root.connection)
        Layout.alignment : Qt.AlignHCenter
      }
      //Row 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : "Maximum Pressure"
      }      
      Slider {
        id: pMaxSlider
        Layout.fillWidth : true
        Layout.row : 1
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 30
        stepSize : 1
        value : root.pMax_cmH2O
        onMoved : {
          root.pMax_cmH2O = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 1
        Layout.column : 3
        text : "%1 cmH2O".arg(root.pMax_cmH2O)
      }
      //Row 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : "PEEP"
      }      
      Slider {
        id: peepSlider
        Layout.fillWidth : true
        Layout.row : 2
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 10
        stepSize : 0.5
        value : root.peep_cmH2O
        onMoved : {
          root.peep_cmH2O = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 2
        Layout.column : 3
        text :  "%1 cmH2O".arg(root.peep_cmH2O)
      }
      //Row 4
      Label {
        Layout.row : 3
        Layout.column : 0
        text : "Respiration Rate"
      }      
      Slider {
        id: respirationRateSlider
        Layout.fillWidth : true
        Layout.row : 3
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 20
        stepSize : 0.5
        value : root.respirationRate_Per_min
        onMoved : {
          root.respirationRate_Per_min = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 3
        Layout.column : 3
        text : "%1 /min".arg(respirationRate_Per_min)
      }
      //Row 5
      Label {
        Layout.row : 4
        Layout.column : 0
        text : "Inlet Flow"
      }      
      Slider {
        id: inletFlowSlider
        Layout.fillWidth : true
        Layout.row : 4
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 10
        stepSize : 0.25
        value : root.inletFlow_L_Per_min
        onMoved : {
          root.inletFlow_L_Per_min = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 4
        Layout.column : 3
        text : "%1 L/min".arg(inletFlow_L_Per_min)
      }
      //Row 6
      Label {
        Layout.row : 5
        Layout.column : 0
        text : "IE Ratio"
      }      
      Slider {
        id: ieRatioSlider
        Layout.fillWidth : true
        Layout.row : 5
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 2
        stepSize : 0.1
        value : root.ieRatio
        onMoved : {
          root.ieRatio = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 5
        Layout.column : 3
        text : "%1".arg(ieRatio)
      }
      //Row 7
      Label {
        Layout.row : 6
        Layout.column : 0
        text : "Oxygen Fraction"
      }      
      Slider {
        id: oxygenFractionSlider
        Layout.fillWidth : true
        Layout.row : 6
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.05
        value : root.o2Fraction
        onMoved : {
          root.o2Fraction = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 6
        Layout.column : 3
        text : "%1".arg(o2Fraction)
      }
      //Row 8
      Label {
        Layout.row : 7
        Layout.column : 0
        text : "Relief Pressure"
      }      
      Slider {
        id: reliefPressureSlider
        Layout.fillWidth : true
        Layout.row : 7
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 150
        stepSize : 5
        value : root.reliefPressure_cmH2O
        onMoved : {
          root.reliefPressure_cmH2O = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 7
        Layout.column : 3
        text : "%1 cmH2O".arg(reliefPressure_cmH2O)
      }
      //Row 9 : Only visible if Bottle 1 defined (if invisible, it takes up 0 area)
      Label {
        visible : o2Source === "Bottle One"
        Layout.column : 0
        Layout.row : 8
        text : "Bottle 1"
      }      
      Slider {
        id: bottle1Slider
        visible : o2Source === "Bottle One"
        Layout.fillWidth : true
        Layout.row : 8
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.05
        value : root.bottle1_mL
        onMoved : {
          root.bottle1_mL = value
          if ( root.active ){
            root.active = false;
          }
        }
      }
      Label {
        Layout.row : 8
        Layout.column : 3
        visible : o2Source === "Bottle One"
        text : "%1 mL".arg(bottle1_mL)
      }
      //Row 10 : Only visible if Bottle 2 defined (if invisible, it takes up 0 area)
      Label {
        visible : o2Source === "Bottle Two"
        Layout.column : 0
        Layout.row : 9
        text : "Bottle 2"
      }      
      Slider {
        id: bottle2Slider
        visible : o2Source === "Bottle Two"
        Layout.fillWidth : true
        Layout.row : 9
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.05
        value : root.bottle2_mL
        onMoved : {
          root.bottle2_mL = value
          if ( root.active ){
            root.active = false;
          }
        }
      }
      Label {
        Layout.row : 9
        Layout.column : 3
        visible : o2Source ==="Bottle Two"
        text : "%1 mL".arg(bottle2_mL)
      }
      //Row 11 : Only visible if Left Chamber substance defined (if invisible, it takes up 0 area)
      Label {
        visible : leftChamberSub !==""
        Layout.column : 0
        Layout.row : 10
        text : leftChamberSub + " Fraction"
      }      
      Slider {
        id: leftSubSlider
        visible : leftChamberSub !==""
        Layout.fillWidth : true
        Layout.row : 10
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.05
        value : root.leftChamberFraction
        onMoved : {
          root.leftChamberFraction = value
          if ( root.active ){
            root.active = false;
          }
        }
      }
      Label {
        Layout.row : 10
        Layout.column : 3
        visible : leftChamberSub !==""
        text : "%1".arg(leftChamberFraction)
      }
      //Row 12 : Only visible if Right Chamber substance defined (if invisible, it takes up 0 area)
      Label {
        visible : rightChamberSub !==""
        Layout.column : 0
        Layout.row : 11
        text : rightChamberSub + " Fraction"
      }      
      Slider {
        id: rightSubSlider
        visible : rightChamberSub !==""
        Layout.fillWidth : true
        Layout.row : 11
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.05
        value : root.rightChamberFraction
        onMoved : {
          root.rightChamberFraction = value
          if ( root.active ){
            root.active = false;
          }
        }
      }
      Label {
        Layout.row : 11
        Layout.column : 3
        visible : rightChamberSub !==""
        text : "%1".arg(rightChamberFraction)
      }
      // Row 13 : On/Off toggle
      Rectangle {
        id: toggle      
        Layout.row : 12
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
    let connectEnum = root.connection == "Mask" ? 1 : (root.connection == "Tube" ? 2 : 0)
    let primaryGasEnum = root.primaryGas == "Air" ? 0 : 1
    let sourceEnum = root.o2Source == "Wall" ? 0 : (root.o2Source == "Bottle One" ? 1 : 2)
    scenario.create_anesthesia_machine_action(connectEnum, primaryGasEnum, sourceEnum, pMax_cmH2O, peep_cmH2O, reliefPressure_cmH2O, inletFlow_L_Per_min, respirationRate_Per_min, ieRatio, o2Fraction, bottle1_mL, bottle2_mL, leftChamberSub, leftChamberFraction, rightChamberSub, rightChamberFraction ) 
  }
  onDeactivate: { 
    let connectEnum = 0; //Off
    let primaryGasEnum = root.primaryGas == "Air" ? 0 : 1   //Not important to shut off but need all args
    let sourceEnum = root.o2Source == "Wall" ? 0 : (root.o2Source == "Bottle One" ? 1 : 2)  //Not important to shut off but need all args 
    scenario.create_anesthesia_machine_action(connectEnum, primaryGasEnum, sourceEnum, pMax_cmH2O, peep_cmH2O, reliefPressure_cmH2O, inletFlow_L_Per_min, respirationRate_Per_min, ieRatio, o2Fraction, bottle1_mL, bottle2_mL, leftChamberSub, leftChamberFraction, rightChamberSub, rightChamberFraction)   
  }
}