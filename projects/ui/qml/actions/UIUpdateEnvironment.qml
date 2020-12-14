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

  property string actionType : "Environment"
  actionClass : EventModel.EnvironmentChange

  //Begin Action Properties
  property string name : "Default"
  property string sourceFile : ""
  property string surroundingType : ""
  property double airDensity_kg_Per_m3 : 12
  property double airVelocity_m_Per_s : 0
  property double ambientTemperature_C : 220
  property double atmpshpericPressure_Pa  : 100000
  property double clothingResistance_clo : 50
  property double emissivity : 95
  property double meanRadiantTemperature_C : 220
  property double relativeHumidity : 60
  property double respirationAmbientTemperature_C  : 220
  property double gasFractionO2 : 21 //fraction value
  property double gasFractionCO2 : 0 // fraction value
  property double gasFractionCO : 0  // fraction value
  property double gasFractionN2 : 79 //fraction value
  property double concentrationSarin : 0 // concentration value
  property double concentrationFireParticulate : 0  // concentration value
  
  fullName  : "<b><font color=\"lightsteelblue\">%1</font>  Environment</b>".arg(root.name)
  shortName : "<b>Environmental Conditions <font color=\"lightsteelblue\"></font> </b>"
  
  property bool validBuildConfig : {
    //let GasCheck = Add gas fractions and check do not exceed 1.00
	let GasCheck = (root.gasFractionCO + root.gasFractionCO2 + root.gasFractionN2 + root.gasFractionO2)  == 1
	
    return GasCheck
  }

  //Builder mode data -- data passed to scenario builder
  buildParams : "Surrounding Type=" + surroundingType + ";Air Density=" + airDensity_kg_Per_m3 + ",kg/m3;Air Velocity=" + airVelocity_m_Per_s + ",m/s;Ambient Temperature=" + ambientTemperature_C + ",C;Atmospheric Pressure=" + atmpshpericPressure_Pa + ",Pa;Clothing Resistance=" + clothingResistance_clo + ",clo;Emissivity=" + emissivity + ";Mean Radiant Temperature=" + meanRadiantTemperature_C + ",C;Respiration Ambient Temperature=" + respirationAmbientTemperature_C + ",C;Gas Fraction O2=" + gasFractionO2 + ";Gas Fraction CO2=" + gasFractionCO2 + ";Gas Fraction CO=" + gasFractionCO + ";Gas Fraction N2=" + gasFractionN2 + ";Concentration Sarin=" + concentrationSarin + ",mg/m3;Concentration Fire Particulate=" + concentrationFireParticulate + ",mg/m3;";
  //Interactive mode -- apply action immediately while running
  onActivate:   { 
  let surroundTypeEnum = root.surroundingType == "Air" ? 1 : (root.connection == "Water" ? 2 : 0)
  scenario.create_environment_action(name, surroundingType, airDensity_kg_Per_m3, airVelocity_m_Per_s, ambientTemperature_C, atmpshpericPressure_Pa, clothingResistance_clo, emissivity, meanRadiantTemperature_C, relativeHumidity, respirationAmbientTemperature_C, gasFractionO2, gasFractionCO2, gasFractionCO, gasFractionN2, concentrationSarin, concentrationFireParticulate)  
  }
  onDeactivate: { //cannot really deactivate an environment
  let surroundTypeEnum = 0; //off
  scenario.create_environment_action(name, surroundingType, airDensity_kg_Per_m3, airVelocity_m_Per_s, ambientTemperature_C, atmpshpericPressure_Pa, clothingResistance_clo, emissivity, meanRadiantTemperature_C, relativeHumidity, respirationAmbientTemperature_C, gasFractionO2, gasFractionCO2, gasFractionCO, gasFractionN2, concentrationSarin, concentrationFireParticulate)  
  }

  controlsDetails : Component  {
    GridLayout {
      id: grid
      columns : 4
      rows    : 14
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
        text : "%1 [%2]".arg(actionType).arg(root.surroundingType)
      }      
      //Row 2
      Label {
        Layout.row : 1
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Air Density"
        font.pointSize : 10
      }      
      Slider {
        id: airDensSlider
        Layout.fillWidth : true
        Layout.row : 1
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 3
        stepSize : 0.1
        value : root.airDensity_kg_Per_m3
		background: Rectangle {
			x: airDensSlider.leftPadding
			y: airDensSlider.topPadding + airDensSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: airDensSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: airDensSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: airDensSlider.leftPadding + airDensSlider.visualPosition * (airDensSlider.availableWidth - width)
			y: airDensSlider.topPadding + airDensSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: airDensSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.airDensity_kg_Per_m3 = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 1
        Layout.column : 3
		color : "#34495e"
        text : "%1 kg/m3".arg(root.airDensity_kg_Per_m3)
        font.pointSize : 10
      }
      //Row 3
      Label {
        Layout.row : 2
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Air Velocity"
        font.pointSize : 10
      }      
      Slider {
        id: airVelSlider
        Layout.fillWidth : true
        Layout.row : 2
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 60
        stepSize : 1
        value : root.airVelocity_m_Per_s
		background: Rectangle {
			x: airVelSlider.leftPadding
			y: airVelSlider.topPadding + airVelSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: airVelSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: airVelSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: airVelSlider.leftPadding + airVelSlider.visualPosition * (airVelSlider.availableWidth - width)
			y: airVelSlider.topPadding + airVelSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: airVelSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.airVelocity_m_Per_s = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 2
        Layout.column : 3
		color : "#34495e"
        text :  "%1 m/s".arg(root.airVelocity_m_Per_s)
        font.pointSize : 10
      }
      //Row 4
      Label {
        Layout.row : 3
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Ambient Temperature"
        font.pointSize : 10
      }      
      Slider {
        id: ambientTempSlider
        Layout.fillWidth : true
        Layout.row : 3
        Layout.column : 1
        Layout.columnSpan : 2
        from : -15
        to : 45
        stepSize : 0.5
        value : root.ambientTemperature_C
		background: Rectangle {
			x: ambientTempSlider.leftPadding
			y: ambientTempSlider.topPadding + ambientTempSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: ambientTempSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: ambientTempSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: ambientTempSlider.leftPadding + ambientTempSlider.visualPosition * (ambientTempSlider.availableWidth - width)
			y: ambientTempSlider.topPadding + ambientTempSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: ambientTempSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.ambientTemperature_C = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 3
        Layout.column : 3
		color : "#34495e"
        text : "%1 C".arg(ambientTemperature_C)
        font.pointSize : 10
      }
      //Row 5
      Label {
        Layout.row : 4
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Atmospheric Pressure"
        font.pointSize : 10
      }      
      Slider {
        id: atmPressSlider
        Layout.fillWidth : true
        Layout.row : 4
        Layout.column : 1
        Layout.columnSpan : 2
        from : 10000
        to : 100000
        stepSize : 10000
        value : root.atmpshpericPressure_Pa
		background: Rectangle {
			x: atmPressSlider.leftPadding
			y: atmPressSlider.topPadding + atmPressSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: atmPressSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: atmPressSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: atmPressSlider.leftPadding + atmPressSlider.visualPosition * (atmPressSlider.availableWidth - width)
			y: atmPressSlider.topPadding + atmPressSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: atmPressSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.atmpshpericPressure_Pa = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 4
        Layout.column : 3
		color : "#34495e"
        text : "%1 Pa".arg(atmpshpericPressure_Pa)
        font.pointSize : 10
      }
      //Row 6
      Label {
        Layout.row : 5
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Clothing Resistance"
      }      
      Slider {
        id: cloSlider
        Layout.fillWidth : true
        Layout.row : 5
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 2
        stepSize : 0.05
        value : root.clothingResistance_clo
		background: Rectangle {
			x: cloSlider.leftPadding
			y: cloSlider.topPadding + cloSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: cloSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: cloSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: cloSlider.leftPadding + cloSlider.visualPosition * (cloSlider.availableWidth - width)
			y: cloSlider.topPadding + cloSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: cloSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.clothingResistance_clo = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 5
        Layout.column : 3
		color : "#34495e"
        text : "%1 clo".arg(clothingResistance_clo)
      }
      //Row 7
      Label {
        Layout.row : 6
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Emissivity"
      }      
      Slider {
        id: emissivitySlider
        Layout.fillWidth : true
        Layout.row : 6
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.05
        value : root.emissivity
		background: Rectangle {
			x: emissivitySlider.leftPadding
			y: emissivitySlider.topPadding + emissivitySlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: emissivitySlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: emissivitySlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: emissivitySlider.leftPadding + emissivitySlider.visualPosition * (emissivitySlider.availableWidth - width)
			y: emissivitySlider.topPadding + emissivitySlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: emissivitySlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.emissivity = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 6
        Layout.column : 3
		color : "#34495e"
        text : "%1".arg(emissivity)
      }
      //Row 8
      Label {
        Layout.row : 7
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Mean Radiant Temperature"
      }      
      Slider {
        id: meanRadiantTempSlider
        Layout.fillWidth : true
        Layout.row : 7
        Layout.column : 1
        Layout.columnSpan : 2
        from : -15
        to : 45
        stepSize : 0.5
        value : root.meanRadiantTemperature_C
		background: Rectangle {
			x: meanRadiantTempSlider.leftPadding
			y: meanRadiantTempSlider.topPadding + meanRadiantTempSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: meanRadiantTempSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: meanRadiantTempSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: meanRadiantTempSlider.leftPadding + meanRadiantTempSlider.visualPosition * (meanRadiantTempSlider.availableWidth - width)
			y: meanRadiantTempSlider.topPadding + meanRadiantTempSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: meanRadiantTempSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.meanRadiantTemperature_C = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 7
        Layout.column : 3
		color : "#34495e"
        text : "%1 C".arg(root.meanRadiantTemperature_C)
      }
	  
      //Row 9 
      Label {
        //visible : o2Source === "Bottle One" //sets only visible if
        Layout.column : 0
        Layout.row : 8
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Relative Humidity"
      }      
      Slider {
        id: relHumiditySlider
        Layout.fillWidth : true
        Layout.row : 8
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.05
        value : root.relativeHumidity
		background: Rectangle {
			x: relHumiditySlider.leftPadding
			y: relHumiditySlider.topPadding + relHumiditySlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: relHumiditySlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: relHumiditySlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: relHumiditySlider.leftPadding + relHumiditySlider.visualPosition * (relHumiditySlider.availableWidth - width)
			y: relHumiditySlider.topPadding + relHumiditySlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: relHumiditySlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.relativeHumidity = value
          if ( root.active ){
            root.active = false;
          }
        }
      }
      Label {
        Layout.row : 8
        Layout.column : 3
		color : "#34495e"
        text : "%1".arg(relativeHumidity)
      }
      //Row 10
      Label {
        Layout.column : 0
        Layout.row : 9
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Respiration Ambient Temperature"
      }      
      Slider {
        id: respAmbientTempSlider
        Layout.fillWidth : true
        Layout.row : 9
        Layout.column : 1
        Layout.columnSpan : 2
        from : -15
        to : 45
        stepSize : 0.5
        value : root.respirationAmbientTemperature_C
		background: Rectangle {
			x: respAmbientTempSlider.leftPadding
			y: respAmbientTempSlider.topPadding + respAmbientTempSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: respAmbientTempSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: respAmbientTempSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: respAmbientTempSlider.leftPadding + respAmbientTempSlider.visualPosition * (respAmbientTempSlider.availableWidth - width)
			y: respAmbientTempSlider.topPadding + respAmbientTempSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: respAmbientTempSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.respirationAmbientTemperature_C = value
          if ( root.active ){
            root.active = false;
          }
        }
      }
      Label {
        Layout.row : 9
        Layout.column : 3
		color : "#34495e"
        text : "%1 C".arg(respirationAmbientTemperature_C)
      }
	  //Row 11
	  Label {
		Layout.leftMargin : 5
        Layout.row : 10
        Layout.column : 0
		Layout.columnSpan : 4
		color : "#34495e"
        text : "Gas Fractions: %1 O2, %2 CO2, %3 CO, %4 N2".arg(gasFractionO2).arg(gasFractionCO2).arg(gasFractionCO).arg(gasFractionN2)
      }
	  // Row 12
      Label {
        Layout.column : 0
        Layout.row : 11
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Sarin Conc."
      }      
      Slider {
        id: sarinConcSlider
        Layout.fillWidth : true
        Layout.row : 11
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 10
        stepSize : 0.5
        value : root.concentrationSarin
		background: Rectangle {
			x: sarinConcSlider.leftPadding
			y: sarinConcSlider.topPadding + sarinConcSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: sarinConcSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: sarinConcSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: sarinConcSlider.leftPadding + sarinConcSlider.visualPosition * (sarinConcSlider.availableWidth - width)
			y: sarinConcSlider.topPadding + sarinConcSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: sarinConcSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.concentrationSarin = value
          if ( root.active ){
            root.active = false;
          }
        }
      }
      Label {
        Layout.row : 11
        Layout.column : 3
		color : "#34495e"
        text : "%1 mg/m3".arg(concentrationSarin)
      }
      // Row 13
      Label {
        Layout.column : 0
        Layout.row : 12
		Layout.leftMargin : 5
		color : "#34495e"
        text : "FFP Conc."
      }      
      Slider {
        id: ffpConcSlider
        Layout.fillWidth : true
        Layout.row : 12
        Layout.column : 1
        Layout.columnSpan : 2
        from : 0
        to : 10
        stepSize : 0.5
        value : root.concentrationFireParticulate
		background: Rectangle {
			x: ffpConcSlider.leftPadding
			y: ffpConcSlider.topPadding + ffpConcSlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: ffpConcSlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: ffpConcSlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: ffpConcSlider.leftPadding + ffpConcSlider.visualPosition * (ffpConcSlider.availableWidth - width)
			y: ffpConcSlider.topPadding + ffpConcSlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: ffpConcSlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.concentrationFireParticulate = value
          if ( root.active ){
            root.active = false;
          }
        }
      }
      Label {
        Layout.row : 12
        Layout.column : 3
		color : "#34495e"
        text : "%1 mg/m3".arg(concentrationFireParticulate)
      }
	  
      // Row 14 : On/Off toggle
      Button {
		Layout.row : 13
        Layout.column : 2
		Layout.columnSpan : 2
		text : "Update"
		onClicked: {
		  root.active = !root.active
		}// emit
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
        root.surroundingType = ""
        surrTypeRadioGroup.radioGroup.checkState = Qt.Unchecked
        root.airDensity_kg_Per_m3 = 0.0
        root.airVelocity_m_Per_s = 0.0
        root.ambientTemperature_C = 0.0
        root.atmpshpericPressure_Pa = 0.0
        root.clothingResistance_clo = 0.0
        root.emissivity = 0.0
        root.meanRadiantTemperature_C = 0.0
        root.relativeHumidity = 0.0
        root.respirationAmbientTemperature_C = 0.0

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
        text : "%1".arg(actionType)
      }    
      //Row 2
      UIRadioButtonForm {
        id : surrTypeRadioGroup
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
        radioGroup.checkedButton : root.surroundingType === "" ? null : root.surroundingType === "Air" ? radioGroup.buttons[0] : radioGroup.buttons[1]
        label.text : "Surrounding Type"
        label.font.pixelSize : 15
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ["Air", "Water"]
        radioGroup.onClicked : {
          root.connection = buttonModel[button.buttonIndex]
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
        id : airDensWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 0
        Layout.columnSpan : 4
        Label {
          id : flowLabel
          leftPadding : 5
          text : "Air Density"
          font.pixelSize : 15
        }
        Slider {
          id: airDensSlider
          Layout.fillWidth : true
          from : 0
          to : 3
          stepSize : 0.1
          value : root.airDensity_kg_Per_m3
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: airDensSlider.leftPadding
				y: airDensSlider.topPadding + airDensSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: airDensSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: airDensSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: airDensSlider.leftPadding + airDensSlider.visualPosition * (airDensSlider.availableWidth - width)
				y: airDensSlider.topPadding + airDensSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: airDensSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.airDensity_kg_Per_m3 = value
          }
        }
        Label {
          text : "%1 kg/m3".arg(root.airDensity_kg_Per_m3)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : airVelWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 4
        Layout.columnSpan : 4
        Label {
          id : ieLabel
          leftPadding : 5
          text : "Air Velocity"
          font.pixelSize : 15
        }
        Slider {
          id: airVelSlider
          Layout.fillWidth : true
          from : 0
          to : 60
          stepSize : 1
          value : root.airVelocity_m_Per_s
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: airVelSlider.leftPadding
				y: airVelSlider.topPadding + airVelSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: airVelSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: airVelSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: airVelSlider.leftPadding + airVelSlider.visualPosition * (airVelSlider.availableWidth - width)
				y: airVelSlider.topPadding + airVelSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: airVelSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.airVelocity_m_Per_s = value
          }
        }
        Label {
          text : "%1 m/s".arg(root.airVelocity_m_Per_s)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : ambientTempWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 2
        Layout.column : 8
        Layout.columnSpan : 4
        Label {
          id : maxLabel
          leftPadding : 5
          text : "Ambient Temperature"
          font.pixelSize : 15
        }
        Slider {
          id: ambientTempSlider
          Layout.fillWidth : true
          from : -15
          to : 45
          stepSize : 0.5
          value : root.ambientTemperature_C
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: ambientTempSlider.leftPadding
				y: ambientTempSlider.topPadding + ambientTempSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: ambientTempSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: ambientTempSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: ambientTempSlider.leftPadding + ambientTempSlider.visualPosition * (ambientTempSlider.availableWidth - width)
				y: ambientTempSlider.topPadding + ambientTempSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: ambientTempSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.ambientTemperature_C = value
          }
        }
        Label {
          text : "%1 C".arg(root.ambientTemperature_C)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      //Row 4
      RowLayout {
        id : atmPressureWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 3
        Layout.column : 0
        Layout.columnSpan : 4
        Label {
          id : peepLabel
          leftPadding : 5
          text : "Atm Pressure"
          font.pixelSize : 15
        }
        Slider {
          id: atmPressSlider
          Layout.fillWidth : true
          from : 10000
          to : 100000
          stepSize : 10000
          value : root.atmpshpericPressure_Pa
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: atmPressSlider.leftPadding
				y: atmPressSlider.topPadding + atmPressSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: atmPressSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: atmPressSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: atmPressSlider.leftPadding + atmPressSlider.visualPosition * (atmPressSlider.availableWidth - width)
				y: atmPressSlider.topPadding + atmPressSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: atmPressSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.atmpshpericPressure_Pa = value
          }
        }
        Label {
          text : "%1 Pa".arg(root.atmpshpericPressure_Pa)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : cloWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 3
        Layout.column : 4
        Layout.columnSpan : 4
        Label {
          id : rrLabel
          leftPadding : 5
          text : "Clothing Resistance"
          font.pixelSize : 15
        }
        Slider {
          id: cloSlider
          Layout.fillWidth : true
          from : 0
          to : 2
          stepSize : 0.05
          value : root.clothingResistance_clo
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: cloSlider.leftPadding
				y: cloSlider.topPadding + cloSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: cloSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: cloSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: cloSlider.leftPadding + cloSlider.visualPosition * (cloSlider.availableWidth - width)
				y: cloSlider.topPadding + cloSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: cloSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.clothingResistance_clo = value
          }
        }
        Label {
          text : "%1".arg(root.clothingResistance_clo)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      RowLayout {
        id : emissivityWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 3
        Layout.column : 8
        Layout.columnSpan : 4
        Label {
          id : reliefLabel
          leftPadding : 5
          text : "Emissivity"
          font.pixelSize : 15
        }
        Slider {
          id: emissivitySlider
          Layout.fillWidth : true
          from : 0
          to : 1
          stepSize : 0.05
          value : root.emissivity
          Layout.alignment : Qt.AlignLeft
			  background: Rectangle {
				x: emissivitySlider.leftPadding
				y: emissivitySlider.topPadding + emissivitySlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: emissivitySlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: emissivitySlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: emissivitySlider.leftPadding + emissivitySlider.visualPosition * (emissivitySlider.availableWidth - width)
				y: emissivitySlider.topPadding + emissivitySlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: emissivitySlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.emissivity = value
          }
        }
        Label {
          text : "%1".arg(root.emissivity)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      //Row 5
      RowLayout {
        id : meanRadTempWrapper
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
          id: meanRadiantTempSlider
          Layout.fillWidth : true
          from : -15
          to : 45
          stepSize : 0.5
          value : root.meanRadiantTemperature_C
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: meanRadiantTempSlider.leftPadding
				y: meanRadiantTempSlider.topPadding + meanRadiantTempSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: meanRadiantTempSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: meanRadiantTempSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: meanRadiantTempSlider.leftPadding + meanRadiantTempSlider.visualPosition * (meanRadiantTempSlider.availableWidth - width)
				y: meanRadiantTempSlider.topPadding + meanRadiantTempSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: meanRadiantTempSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.meanRadiantTemperature_C = value
          }
        }
        Label {
          text : "%1 C".arg(root.meanRadiantTemperature_C)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      
      RowLayout {
        id : relHumidityWrapper
        Layout.maximumWidth : grid.width / 3 - grid.columnSpacing * 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 4
        Layout.column : 4
        Layout.columnSpan : 4
        Label {
          id : bottleLabel
          leftPadding : 5
          text : "Relative Humidity"
          font.pixelSize : 15
        }
        Slider {
          id: relHumiditySlider
          Layout.fillWidth : true
          from : 0
          to : 1
          stepSize : 0.05
          value : root.relativeHumidity
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: relHumiditySlider.leftPadding
				y: relHumiditySlider.topPadding + relHumiditySlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: relHumiditySlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: relHumiditySlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: relHumiditySlider.leftPadding + relHumiditySlider.visualPosition * (relHumiditySlider.availableWidth - width)
				y: relHumiditySlider.topPadding + relHumiditySlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: relHumiditySlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.relativeHumidity = value
            }
          }
        Label {
          text : "%1".arg(root.relativeHumidity)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
        }
      }
      //Row 6
      RowLayout {
        id : respAmbientTempWrapper
        Layout.row : 5
        Layout.column : 0
        Layout.columnSpan : 4
        Layout.fillWidth : true
        Layout.preferredHeight : 60
        Layout.maximumWidth : grid.width / 2 - grid.columnSpacing
        Label {
          id : leftSubLabel
          text : "Respiration Ambient Temperature"
          verticalAlignment : Text.AlignBottom
          Layout.alignment : Qt.AlignBottom
          leftPadding : 5
          font.pixelSize : 15
          bottomPadding : 7
        }
        Slider {
          id: respAmbientTempSlider
          Layout.fillWidth : true
          from : -15
          to : 45
          stepSize : 0.5
          value : root.respirationAmbientTemperature_C
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: respAmbientTempSlider.leftPadding
				y: respAmbientTempSlider.topPadding + respAmbientTempSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: respAmbientTempSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: respAmbientTempSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: respAmbientTempSlider.leftPadding + respAmbientTempSlider.visualPosition * (respAmbientTempSlider.availableWidth - width)
				y: respAmbientTempSlider.topPadding + respAmbientTempSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: respAmbientTempSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.respirationAmbientTemperature_C = value
            }
        }
        Label {
          text : "%1 C".arg(root.respirationAmbientTemperature_C)
          font.pixelSize : 15
          Layout.alignment : Qt.AlignLeft
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
  
