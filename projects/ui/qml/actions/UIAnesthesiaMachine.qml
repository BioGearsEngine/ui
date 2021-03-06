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
  property bool leftSubCheck : true    //defining as property to connect to IsValid function of UISubstanceEntry used for left chamber
  property bool rightSubCheck : true   //defining as property to connect to IsValid function of UISubstanceEntry used for right chamber

  actionType : "Anesthesia Machine"
  actionClass : EventModel.AnesthesiaMachineConfiguration
  fullName  :  "<b>%1</b><br>".arg(description)

  shortName : "<font color=\"lightsteelblue\"> %2</font> <b>%1</b>".arg(actionType).arg(connection)
  property bool validBuildConfig : {
    let hasBaseValues = connection !== "" && primaryGas !== "" && o2Source !== "" && inletFlow_L_Per_min > 0.0 && ieRatio > 0.0 && pMax_cmH2O > 0.0 && peep_cmH2O > 0.0
                          && respirationRate_Per_min > 0.0 && reliefPressure_cmH2O > 0.0 && o2Fraction > 0.0;
    let bottle1Check = o2Source !== "Bottle One" ? true : bottle1_mL > 0.0 ? true : false 
    let bottle2Check =  o2Source !== "Bottle Two" ? true : bottle2_mL > 0.0 ? true : false 
    return hasBaseValues && bottle1Check && bottle2Check && leftSubCheck && rightSubCheck && actionDuration_s > 0.0
  }

  //Builder mode data -- data passed to scenario builder
  buildParams : "Connection=" + connection + ";PrimaryGas=" + primaryGas + ";OxygenSource=" + o2Source + ";VentilatorPressure=" + pMax_cmH2O + ",cmH2O;PositiveEndExpiredPressure=" + peep_cmH2O + ",cmH2O;InletFlow="
          +  inletFlow_L_Per_min + ",L/min; RespirationRate=" + respirationRate_Per_min + ",1/min;InspiratoryExpiratoryRatio=" + ieRatio + ";OxygenFraction=" + o2Fraction + ";ReliefValvePressure=" + reliefPressure_cmH2O + ",cmH2O;"
          + "OxygenBottleOne=" +  bottle1_mL + ",mL;OxygenBottleTwo=" + bottle2_mL + ",mL;LeftChamberSubstance=" + leftChamberSub + ";LeftChamberSubstanceFraction=" + leftChamberFraction + ";RightChamberSubstance="
          +  rightChamberSub + ";RightChamberSubtanceFraction=" + rightChamberFraction + ";"
  //Interactive mode -- apply action immediately while running
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

  controlsDetails : Component  {
    GridLayout {
      id: grid
      columns : 4
      rows    : 13
      width : root.width -5
      anchors.centerIn : parent 
      //Row 1
      Label {
        font.pointSize : 12
        Layout.columnSpan : 4
        Layout.fillWidth : true
        font.bold : true
        Layout.leftMargin : 5
		color : "#34495e"
        text : "%1 [%2]".arg(actionType).arg(root.connection)
      }      
      //Row 2
      Label {
        Layout.row : 1
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Maximum Pressure"
        font.pointSize : 10
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
		background: Rectangle {
			x: pMaxSlider.leftPadding
			y: pMaxSlider.topPadding + pMaxSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: pMaxSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: pMaxSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: pMaxSlider.leftPadding + pMaxSlider.visualPosition * (pMaxSlider.availableWidth - width)
			y: pMaxSlider.topPadding + pMaxSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: pMaxSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.pMax_cmH2O = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 1
        Layout.column : 3
		color : "#34495e"
        text : "%1 cmH2O".arg(root.pMax_cmH2O)
        font.pointSize : 10
      }
      //Row 3
      Label {
        Layout.row : 2
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "PEEP"
        font.pointSize : 10
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
		background: Rectangle {
			x: peepSlider.leftPadding
			y: peepSlider.topPadding + peepSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: peepSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: peepSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: peepSlider.leftPadding + peepSlider.visualPosition * (peepSlider.availableWidth - width)
			y: peepSlider.topPadding + peepSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: peepSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.peep_cmH2O = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 2
        Layout.column : 3
		color : "#34495e"
        text :  "%1 cmH2O".arg(root.peep_cmH2O)
        font.pointSize : 10
      }
      //Row 4
      Label {
        Layout.row : 3
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Respiration Rate"
        font.pointSize : 10
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
		background: Rectangle {
			x: respirationRateSlider.leftPadding
			y: respirationRateSlider.topPadding + respirationRateSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: respirationRateSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: respirationRateSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: respirationRateSlider.leftPadding + respirationRateSlider.visualPosition * (respirationRateSlider.availableWidth - width)
			y: respirationRateSlider.topPadding + respirationRateSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: respirationRateSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.respirationRate_Per_min = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 3
        Layout.column : 3
		color : "#34495e"
        text : "%1 /min".arg(respirationRate_Per_min)
        font.pointSize : 10
      }
      //Row 5
      Label {
        Layout.row : 4
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Inlet Flow"
        font.pointSize : 10
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
		background: Rectangle {
			x: inletFlowSlider.leftPadding
			y: inletFlowSlider.topPadding + inletFlowSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: inletFlowSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: inletFlowSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: inletFlowSlider.leftPadding + inletFlowSlider.visualPosition * (inletFlowSlider.availableWidth - width)
			y: inletFlowSlider.topPadding + inletFlowSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: inletFlowSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.inletFlow_L_Per_min = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 4
        Layout.column : 3
		color : "#34495e"
        text : "%1 L/min".arg(inletFlow_L_Per_min)
        font.pointSize : 10
      }
      //Row 6
      Label {
        Layout.row : 5
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
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
		background: Rectangle {
			x: ieRatioSlider.leftPadding
			y: ieRatioSlider.topPadding + ieRatioSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: ieRatioSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: ieRatioSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: ieRatioSlider.leftPadding + ieRatioSlider.visualPosition * (ieRatioSlider.availableWidth - width)
			y: ieRatioSlider.topPadding + ieRatioSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: ieRatioSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.ieRatio = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 5
        Layout.column : 3
		color : "#34495e"
        text : "%1".arg(ieRatio)
      }
      //Row 7
      Label {
        Layout.row : 6
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
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
		background: Rectangle {
			x: oxygenFractionSlider.leftPadding
			y: oxygenFractionSlider.topPadding + oxygenFractionSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: oxygenFractionSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: oxygenFractionSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: oxygenFractionSlider.leftPadding + oxygenFractionSlider.visualPosition * (oxygenFractionSlider.availableWidth - width)
			y: oxygenFractionSlider.topPadding + oxygenFractionSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: oxygenFractionSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.o2Fraction = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 6
        Layout.column : 3
		color : "#34495e"
        text : "%1".arg(o2Fraction)
      }
      //Row 8
      Label {
        Layout.row : 7
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
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
		background: Rectangle {
			x: reliefPressureSlider.leftPadding
			y: reliefPressureSlider.topPadding + reliefPressureSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: reliefPressureSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: reliefPressureSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: reliefPressureSlider.leftPadding + reliefPressureSlider.visualPosition * (reliefPressureSlider.availableWidth - width)
			y: reliefPressureSlider.topPadding + reliefPressureSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: reliefPressureSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.reliefPressure_cmH2O = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 7
        Layout.column : 3
		color : "#34495e"
        text : "%1 cmH2O".arg(root.reliefPressure_cmH2O)
      }
      //Row 9 : Only visible if Bottle 1 defined (if invisible, it takes up 0 area)
      Label {
        visible : o2Source === "Bottle One"
        Layout.column : 0
        Layout.row : 8
		Layout.leftMargin : 5
		color : "#34495e"
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
		background: Rectangle {
			x: bottle1Slider.leftPadding
			y: bottle1Slider.topPadding + bottle1Slider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: bottle1Slider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: bottle1Slider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: bottle1Slider.leftPadding + bottle1Slider.visualPosition * (bottle1Slider.availableWidth - width)
			y: bottle1Slider.topPadding + bottle1Slider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: bottle1Slider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
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
		color : "#34495e"
        visible : o2Source === "Bottle One"
        text : "%1 mL".arg(bottle1_mL)
      }
      //Row 10 : Only visible if Bottle 2 defined (if invisible, it takes up 0 area)
      Label {
        visible : o2Source === "Bottle Two"
        Layout.column : 0
        Layout.row : 9
		Layout.leftMargin : 5
		color : "#34495e"
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
		background: Rectangle {
			x: bottle2Slider.leftPadding
			y: bottle2Slider.topPadding + bottle2Slider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: bottle2Slider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: bottle2Slider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: bottle2Slider.leftPadding + bottle2Slider.visualPosition * (bottle2Slider.availableWidth - width)
			y: bottle2Slider.topPadding + bottle2Slider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: bottle2Slider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
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
		color : "#34495e"
        visible : o2Source ==="Bottle Two"
        text : "%1 mL".arg(bottle2_mL)
      }
      //Row 11 : Only visible if Left Chamber substance defined (if invisible, it takes up 0 area)
      Label {
        visible : leftChamberSub !==""
        Layout.column : 0
        Layout.row : 10
		Layout.leftMargin : 5
		color : "#34495e"
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
		background: Rectangle {
			x: leftSubSlider.leftPadding
			y: leftSubSlider.topPadding + leftSubSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: leftSubSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: leftSubSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: leftSubSlider.leftPadding + leftSubSlider.visualPosition * (leftSubSlider.availableWidth - width)
			y: leftSubSlider.topPadding + leftSubSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: leftSubSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
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
		color : "#34495e"
        visible : leftChamberSub !==""
        text : "%1".arg(leftChamberFraction)
      }
      //Row 12 : Only visible if Right Chamber substance defined (if invisible, it takes up 0 area)
      Label {
        visible : rightChamberSub !==""
        Layout.column : 0
        Layout.row : 11
		Layout.leftMargin : 5
		color : "#34495e"
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
		background: Rectangle {
			x: rightSubSlider.leftPadding
			y: rightSubSlider.topPadding + rightSubSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: rightSubSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: rightSubSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: rightSubSlider.leftPadding + rightSubSlider.visualPosition * (rightSubSlider.availableWidth - width)
			y: rightSubSlider.topPadding + rightSubSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: rightSubSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
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
		color : "#34495e"
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
		Layout.bottomMargin : 5
		radius : pill.width * 0.6
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
			radius : pill.width * 0.6
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
 builderDetails : Component {
    id : builderDetails
    GridLayout {
      id: grid
      columns : 12
      rows : 7 
      width : root.width -5
      anchors.centerIn : parent
      columnSpacing : 10
      rowSpacing : 10
      signal clear()
      onClear : {
        root.connection = ""
        connectionRadioGroup.radioGroup.checkState = Qt.Unchecked
        root.primaryGas = ""
        gasRadioGroup.radioGroup.checkedState = Qt.Unchecked
        root.inletFlow_L_Per_min = 0.0
        root.ieRatio = 0.0
        root.pMax_cmH2O = 0.0
        root.peep_cmH2O = 0.0
        root.respirationRate_Per_min = 0.0
        root.reliefPressure_cmH2O = 0.0
        root.o2Fraction = 0.0
        root.o2Source = 0.0
        sourceRadioGroup.radioGroup.checkedState = Qt.Unchecked
        root.bottle1_mL = 0.0
        root.bottle2_mL = 0.0
        root.leftChamberSub = ""
        root.leftChamberFraction = 0.0
        leftSub.subEntry.reset()
        root.rightChamberSub = ""
        root.rightChamberFraction = 0.0
        rightSub.subEntry.reset()
        startTimeLoader.item.clear()
        durationLoader.item.clear()
      }
      Label {
        id : actionLabel
        Layout.row : 0
        Layout.column : 0
        Layout.columnSpan : 12
        Layout.fillHeight : true
        Layout.fillWidth : true
        Layout.preferredWidth : grid.width * 0.5
        font.pixelSize : 20
        font.bold : true
        color : "blue"
        leftPadding : 5
        text : "%1".arg(actionType) + "[%1]".arg(root.compartment)
      }    
      //Row 2
      UIRadioButtonForm {
        id : connectionRadioGroup
        Layout.row : 1
        Layout.column : 0
        Layout.columnSpan : 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignVCenter
        Layout.preferredWidth : grid.width / 4 - grid.columnSpacing  * 3
        Layout.maximumWidth : grid.width / 4 - grid.columnSpacing * 3
        Layout.preferredHeight : 50
        elementRatio : 0.5
        radioGroup.checkedButton : root.connection === "" ? null : root.connection === "Mask" ? radioGroup.buttons[0] : radioGroup.buttons[1]
        label.text : "Connection"
        label.font.pixelSize : 15
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ["Mask", "Tube"]
        radioGroup.onClicked : {
          root.connection = buttonModel[button.buttonIndex]
        }
      }
      UIRadioButtonForm {
        id : gasRadioGroup
        Layout.row : 1
        Layout.column : 3
        Layout.columnSpan : 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignVCenter
        Layout.preferredWidth : grid.width / 4 - grid.columnSpacing * 3
        Layout.maximumWidth : grid.width / 4 - grid.columnSpacing * 3
        Layout.preferredHeight : 50
        elementRatio : 0.5
        radioGroup.checkedButton : root.primaryGas === "" ? null : root.primaryGas === "Air" ? radioGroup.buttons[0] : radioGroup.buttons[1]
        label.text : "Primary Gas"
        label.font.pixelSize : 15
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ["Air", "Nitrogen"]
        radioGroup.onClicked : {
          root.primaryGas = buttonModel[button.buttonIndex]
        }
      }
      Loader {
        id : startTimeLoader
        sourceComponent : timeEntry
        onLoaded : {
          item.entryName = "Start Time"
          Layout.row = 1
          Layout.column = 6
          Layout.columnSpan = 3
          Layout.alignment = Qt.AlignLeft
          Layout.fillWidth = true
          Layout.fillHeight = true
          Layout.maximumWidth = grid.width / 5
          if (actionStartTime_s > 0.0){
            item.reload(actionStartTime_s)
          }
        }
      }
      Connections {
        target : startTimeLoader.item
        onTimeUpdated : {
          root.actionStartTime_s = totalTime_s
        }
      }
      Loader {
        id : durationLoader
        sourceComponent : timeEntry
        onLoaded : {
          item.entryName = "Duration"
          Layout.row = 1
          Layout.column = 9
          Layout.columnSpan = 3
          Layout.alignment = Qt.AlignHCenter
          Layout.fillWidth = true
          Layout.fillHeight = true
          Layout.maximumWidth = grid.width / 5
          if (actionDuration_s > 0.0){
            item.reload(actionDuration_s)
          }
        }
      }
      Connections {
        target : durationLoader.item
        onTimeUpdated : {
          root.actionDuration_s = totalTime_s
        }
      }
      //Row 3
      RowLayout {
        id : flowWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 0
        Layout.columnSpan : 4
        Label {
          id : flowLabel
          leftPadding : 5
          text : "Inlet Flow"
          font.pixelSize : 15
        }
        Slider {
          id: flowSlider
          Layout.fillWidth : true
          from : 0
          to : 10
          stepSize : 0.25
          value : root.inletFlow_L_Per_min
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: flowSlider.leftPadding
				y: flowSlider.topPadding + flowSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: flowSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: flowSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: flowSlider.leftPadding + flowSlider.visualPosition * (flowSlider.availableWidth - width)
				y: flowSlider.topPadding + flowSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: flowSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.inletFlow_L_Per_min = value
          }
        }
        Label {
          text : "%1 L/min".arg(root.inletFlow_L_Per_min)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : ieWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 4
        Layout.columnSpan : 4
        Label {
          id : ieLabel
          leftPadding : 5
          text : "IE Ratio"
          font.pixelSize : 15
        }
        Slider {
          id: ieSlider
          Layout.fillWidth : true
          from : 0
          to : 2.0
          stepSize : 0.1
          value : root.ieRatio
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: ieSlider.leftPadding
				y: ieSlider.topPadding + ieSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: ieSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: ieSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: ieSlider.leftPadding + ieSlider.visualPosition * (ieSlider.availableWidth - width)
				y: ieSlider.topPadding + ieSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: ieSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.ieRatio = value
          }
        }
        Label {
          text : "%1".arg(root.ieRatio)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : maxWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 8
        Layout.columnSpan : 4
        Label {
          id : maxLabel
          leftPadding : 5
          text : "Pmax"
          font.pixelSize : 15
        }
        Slider {
          id: maxSlider
          Layout.fillWidth : true
          from : 0
          to : 20
          stepSize : 1
          value : root.pMax_cmH2O
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: maxSlider.leftPadding
				y: maxSlider.topPadding + maxSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: maxSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: maxSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: maxSlider.leftPadding + maxSlider.visualPosition * (maxSlider.availableWidth - width)
				y: maxSlider.topPadding + maxSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: maxSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.pMax_cmH2O = value
          }
        }
        Label {
          text : "%1 cmH2O".arg(root.pMax_cmH2O)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      //Row 4
      RowLayout {
        id : peepWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 3
        Layout.column : 0
        Layout.columnSpan : 4
        Label {
          id : peepLabel
          leftPadding : 5
          text : "PEEP"
          font.pixelSize : 15
        }
        Slider {
          id: peepSlider
          Layout.fillWidth : true
          from : 0
          to : 10
          stepSize : 0.5
          value : root.peep_cmH2O
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: peepSlider.leftPadding
				y: peepSlider.topPadding + peepSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: peepSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: peepSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: peepSlider.leftPadding + peepSlider.visualPosition * (peepSlider.availableWidth - width)
				y: peepSlider.topPadding + peepSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: peepSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.peep_cmH2O = value
          }
        }
        Label {
          text : "%1 cmH2O".arg(root.peep_cmH2O)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : rrWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 3
        Layout.column : 4
        Layout.columnSpan : 4
        Label {
          id : rrLabel
          leftPadding : 5
          text : "Respiration Rate"
          font.pixelSize : 15
        }
        Slider {
          id: rrSlider
          Layout.fillWidth : true
          from : 0
          to : 20
          stepSize : 0.5
          value : root.respirationRate_Per_min
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: rrSlider.leftPadding
				y: rrSlider.topPadding + rrSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: rrSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: rrSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: rrSlider.leftPadding + rrSlider.visualPosition * (rrSlider.availableWidth - width)
				y: rrSlider.topPadding + rrSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: rrSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.respirationRate_Per_min = value
          }
        }
        Label {
          text : "%1".arg(root.respirationRate_Per_min)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : reliefWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 3
        Layout.column : 8
        Layout.columnSpan : 4
        Label {
          id : reliefLabel
          leftPadding : 5
          text : "Relief Pressure"
          font.pixelSize : 15
        }
        Slider {
          id: reliefSlider
          Layout.fillWidth : true
          from : 0
          to : 100
          stepSize : 5
          value : root.reliefPressure_cmH2O
          Layout.alignment : Qt.AlignLeft
			  background: Rectangle {
				x: reliefSlider.leftPadding
				y: reliefSlider.topPadding + reliefSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: reliefSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: reliefSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: reliefSlider.leftPadding + reliefSlider.visualPosition * (reliefSlider.availableWidth - width)
				y: reliefSlider.topPadding + reliefSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: reliefSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.reliefPressure_cmH2O = value
          }
        }
        Label {
          text : "%1 cmH2O".arg(root.reliefPressure_cmH2O)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      //Row 5
      RowLayout {
        id : o2FracWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 4
        Layout.column : 0
        Layout.columnSpan : 4
        Label {
          id : o2FracLabel
          leftPadding : 5
          text : "O2 Fraction"
          font.pixelSize : 15
        }
        Slider {
          id: o2FracSlider
          Layout.fillWidth : true
          from : 0
          to : 1
          stepSize : 0.01
          value : root.o2Fraction
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: O2FracSlider.leftPadding
				y: O2FracSlider.topPadding + O2FracSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: O2FracSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: O2FracSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: O2FracSlider.leftPadding + O2FracSlider.visualPosition * (O2FracSlider.availableWidth - width)
				y: O2FracSlider.topPadding + O2FracSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: O2FracSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.o2Fracton = value
          }
        }
        Label {
          text : "%1".arg(root.o2Fraction)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      UIRadioButtonForm {
        id : sourceRadioGroup
        Layout.row : 4
        Layout.column : 4
        Layout.columnSpan : 4
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignVCenter
        Layout.preferredWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.preferredHeight : 75
        elementRatio : 0.4
        radioGroup.checkedButton : root.o2Source === "" ? null : root.o2Source === "Wall" ? radioGroup.buttons[0] : root.o2Source === "Bottle One" ? radioGroup.buttons[1] : radioGroup.buttons[2]
        label.text : "O2 Source"
        label.font.pointSize : 11
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ['Wall', 'Bottle One', 'Bottle Two']
        radioGroup.onClicked : {
          o2Source = buttonModel[button.buttonIndex]
        }
      }
      RowLayout {
        id : bottleWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 4
        Layout.column : 8
        Layout.columnSpan : 4
        enabled : (root.o2Source === "Bottle One" || root.o2Source ==="Bottle Two")
        property double bottleOpacity : (root.o2Source === "Wall" || root.o2Source ==="") ? 0.4 : 1
        Label {
          id : bottleLabel
          leftPadding : 5
          text : (root.o2Source === "Wall" || root.o2Source === "") ? "Bottle   Volume" : root.o2Source === "Bottle One" ? "Bottle 1 Volume" : "Bottle 2 Volume"
          font.pixelSize : 15
          opacity : parent.bottleOpacity
        }
        Slider {
          id: bottleSlider
          Layout.fillWidth : true
          opacity : parent.bottleOpacity
          from : 0
          to : 2000
          stepSize : 100
          value : root.o2Source === "Bottle One" ? bottle1_mL : root.o2Source === "Bottle Two" ? bottle2_mL : 0
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: bottleSlider.leftPadding
				y: bottleSlider.topPadding + bottleSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: bottleSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: bottleSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: bottleSlider.leftPadding + bottleSlider.visualPosition * (bottleSlider.availableWidth - width)
				y: bottleSlider.topPadding + bottleSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: bottleSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            if (root.o2Source === "Bottle One"){
              root.bottle1_mL = value
            } else if (root.o2Source === "Bottle Two"){
              root.bottle2_mL = value
            }
          }
        }
        Label {
          text : (root.o2Source === "Wall" || root.o2Source === "") ? " mL" : root.o2Source === "Bottle One" ? "%1 mL".arg(root.bottle1_mL) : "%1 mL".arg(root.bottle2_mL)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
          opacity : parent.bottleOpacity
        }
      }
      //Row 6
      RowLayout {
        id : leftSub
        Layout.row : 5
        Layout.column : 0
        Layout.columnSpan : 6
        Layout.fillWidth : true
        Layout.preferredHeight : 60
        Layout.maximumWidth : grid.width / 2 - grid.columnSpacing
        property alias subEntry : leftSubEntry
        Label {
          id : leftSubLabel
          text : "Left Chamber Substance"
          verticalAlignment : Text.AlignBottom
          Layout.alignment : Qt.AlignBottom
          leftPadding : 5
          font.pixelSize : 15
          bottomPadding : 7
        }
        Rectangle {
          color : "transparent"
          Layout.fillWidth : true
          Layout.maximumWidth : parent.width - leftSubLabel.width
          Layout.fillHeight : true
          UISubstanceEntry {
            id : leftSubEntry
            prefWidth : parent.width * 0.9
            prefHeight : parent.height * 0.9
            anchors.centerIn : parent
            type : "fraction"
            border.width : 0
            onInputAccepted : {
              leftChamberSub = input[0]
              leftChamberFraction = input[1]
            }
            Component.onCompleted : {
              //Set up components for drop down
              let components = scenario.get_volatile_drugs()
              for (let i = 0; i < components.length; ++i){
                entry.componentListModel.append({"component" : components[i]})
              }
              //Update entry text (need to let it load first since entry is bound to item property of loader in UISubstanceEntry)
              entry.substanceInput.font.pointSize = 11
              entry.scalarInput.font.pointSize = 11
              if (leftChamberSub!==""){
                setEntry([leftChamberSub, leftChamberFraction])
              }
              //Connect valid input to root check so that we know when it's ok to collapse action def
              entry.validInputChanged.connect(function(input) {root.leftSubCheck = entry.validInput})
            }
          }
        }
      }
      RowLayout {
        id : rightSub
        Layout.row : 5
        Layout.column : 6
        Layout.columnSpan : 6
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.preferredHeight : 60
        Layout.maximumWidth : grid.width / 2 - grid.columnSpacing
        property alias subEntry : rightSubEntry
        Label {
          id : rightSubLabel
          text : "Right Chamber Substance"
          leftPadding : 5
          font.pixelSize : 15
          verticalAlignment : Text.AlignBottom
          Layout.alignment : Qt.AlignBottom
          bottomPadding : 7
        }
        Rectangle {
          color : "transparent"
          Layout.fillWidth : true
          Layout.maximumWidth : parent.width - rightSubLabel.width
          Layout.fillHeight : true
          UISubstanceEntry {
            id : rightSubEntry
            prefWidth : parent.width * 0.9
            prefHeight : parent.height * 0.9
            anchors.centerIn : parent
            type : "fraction"
            border.width : 0
            onInputAccepted : {
              rightChamberSub = input[0]
              rightChamberFraction = input[1]
            }
            Component.onCompleted : {
              let components = scenario.get_volatile_drugs()
              for (let i = 0; i < components.length; ++i){
                entry.componentListModel.append({"component" : components[i]})
              }
              entry.substanceInput.font.pointSize = 11
              entry.scalarInput.font.pointSize = 11
              if (rightChamberSub!==""){
                setEntry([rightChamberSub, rightChamberFraction])
              }
              entry.validInputChanged.connect(function(input){root.rightSubCheck = entry.validInput})
            }
          }
        }
      }
      //Row 7
      Rectangle {
        //placeholder for spacing
        color : "transparent"
        Layout.row : 6
        Layout.column : 0
        Layout.columnSpan : 4
        Layout.preferredHeight : bottleWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillHeight : true
      }
      Rectangle {
        Layout.row : 6
        Layout.column : 4
        Layout.columnSpan : 4
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 3
        color : "transparent"
        border.width : 0
        Button {
          text : "Set Action"
          opacity : validBuildConfig ? 1 : 0.4
          anchors.centerIn : parent
          height : parent.height
          width : parent.width / 2
          onClicked : {
            if (validBuildConfig){
              viewLoader.state = "collapsedBuilder"
              root.buildSet(root)
            }
          }
        }
      }
      Rectangle {
        Layout.row : 6
        Layout.column : 8
        Layout.columnSpan : 4
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 3 
        color : "transparent"
        border.width : 0
        Button {
          text : "Clear Fields"
          anchors.centerIn : parent
          height : parent.height
          width : parent.width / 2
          onClicked : {
            grid.clear()
          }
        }
      }
    }
  } //end builder details component
}