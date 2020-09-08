import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

GridLayout {
	id : root
  columns : 3
  rows : 2
  property string pathId : ""   //unique to each request, used to search for requests to remove when unchecked in menu
  property string requestRoot : ""    //Top level request catergory, e.g. compartment, physiology, substance, etc.
  property var requestBranches : []    //Intermediate tiers of data (e.g. compartment type, compartment name, substance name, physiology subsection
  property string requestLeaf : ""  //Request name
  Rectangle {
    Layout.row : 0
    Layout.column : 0
    Layout.columnSpan : 3
    Layout.preferredHeight : 20
    Layout.preferredWidth : parent.width
    color : "transparent"
    border.color : "blue"
    border.width : 1
    Text {
      anchors.left : parent.left
      text : {  if (requestBranches.length > 0){
                  return requestRoot + "(" + requestBranches[0] + ")"
                } else {
                  return requestRoot
                }
      }
    }
  }
  Rectangle {
    Layout.row : 1
    Layout.column : 0
    Layout.columnSpan : 3
    Layout.preferredHeight : 20
    Layout.preferredWidth : parent.width
    color : "transparent"
    border.color : "green"
    border.width : 1
    Text {
      anchors.left : parent.left
      text : requestLeaf
    }
  }


	property var units : ({ 'AmountPerTime' : [],
                          'AmountPerVolume' : [],
                          'Area' : [],
                          'ElectricPotential' : [],
                          'Energy': [],
                          'FlowResistance' : [],
                          'Frequency' : ['1/s', '1/min', 'Hz', '1/hr'],
                          'HeatCapacitancePerMass' : [],
                          'Mass' : ['lb', 'kg', 'g', 'mg','ug'],
                          'MassPerTime' : [],
                          'MassPerVolume' : [],
                          'Osmolality' : [],
                          'Osmolarity' : [],
                          'Power': ['W','kcal/s','kcal/min','kcal/hr','BTU/hr'],
                          'Pressure' : ['mmHg','atm','cmH2O'],
                          'PressureTimePerVolumeArea' : [],
                          'Temperature': [],
                          'Time' : ['yr', 'hr','min','s'],
                          'TimeMassPerVolume' : [],
                          'Volume' : ['L','mL','uL'],
                          'VolumePerTime' : [],
                          'VolumePerTimePressure' : []
                         })
}


/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/