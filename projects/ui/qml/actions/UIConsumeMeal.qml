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

  property string actionType : "Consume Meal"

  //Begin Action Properties
  property string name : "Default"
  property double carbohydrate_mass : 0
  property double fat_mass : 0
  property double protein_mass : 0
  property double calcium_mass : 0
  property double sodium_mass  : 0
  property double water_volume : 0

  property string fullName  : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>]".arg(actionType).arg(name)
  property string shortName : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>]<br/>Carbohdrate %3g<br/>Fat %4g<br/>Protein %5g<br/>Calcium %6g<br/>Socium %7g<br/>Water %8ml<br/>".arg(actionType).arg(name).arg(carbohydrate_mass).arg(fat_mass).arg(protein_mass).arg(calcium_mass).arg(sodium_mass).arg(water_volume)

  details : Component  {
    GridLayout {
      id: grid
      columns : 4
      rows    : 8
      width : root.width -5
      anchors.centerIn : parent
      Label {
        font.pixelSize : 10
        font.bold : true
        color : "blue"
        text : "%1".arg(actionType)
        Layout.maximumHeight : root.parent.height / grid.rows
      }      
      Label {
        font.pixelSize : 10
        font.bold : false
        color : "steelblue"
        text : "[%1]".arg(root.location)
        Layout.alignment : Qt.AlignHCenter
        Layout.maximumHeight : root.parent.height / grid.rows
      }
      //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : "Carbohydrate (g)"
        Layout.maximumHeight : root.parent.height / grid.rows
      }      
      Slider {
        id: carbSlider
        Layout.row : 1
        Layout.column : 1
        Layout.fillWidth : true
        Layout.maximumHeight : root.parent.height / grid.rows
        Layout.columnSpan : 2
        from : 0
        to : 300          //300 g is reasonable amount for one day
        stepSize : 5
        value : root.carbohydrate_mass

        onMoved : {
          root.carbohydrate_mass = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 1
        Layout.column : 3
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "%1".arg(root.carbohydrate_mass)
      }
      //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : "Fat (g)"
        Layout.maximumHeight : root.parent.height / grid.rows
      }      
      Slider {
        id: fatSlider
        Layout.row : 2
        Layout.column : 1
        Layout.maximumHeight : root.parent.height / grid.rows
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 80          //80 g is reasonable amount for one day
        stepSize : 5
        value : root.fat_mass

        onMoved : {
          root.fat_mass = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 2
        Layout.column : 3
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "%1".arg(root.fat_mass)
      }
    //Column 4
      Label {
        Layout.row : 3
        Layout.column : 0
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "Protein (g)"
      }      
      Slider {
        id: proteinSlider
        Layout.row : 3
        Layout.column : 1
        Layout.maximumHeight : root.parent.height / grid.rows
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 100          //60ish g is reasonable amount / day for sedentary person, bump up to 100 account for active
        stepSize : 5
        value : root.protein_mass

        onMoved : {
          root.protein_mass = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 3
        Layout.column : 3
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "%1".arg(root.protein_mass)
      }
      //Column 5
      Label {
        Layout.row : 4
        Layout.column : 0
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "Calcium (mg)"
      }      
      Slider {
        id: calciumSlider
        Layout.row : 4
        Layout.column : 1
        Layout.fillWidth : true
        Layout.columnSpan : 2
        Layout.maximumHeight : root.parent.height / grid.rows
        from : 0
        to : 2000         //2000 mg is reasonable upper limit for one day
        stepSize : 100
        value : root.calcium_mass

        onMoved : {
          root.calcium_mass = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 4
        Layout.column : 3
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "%1".arg(root.calcium_mass)
      }
      //Column 6
      Label {
        Layout.row : 5
        Layout.column : 0
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "Sodium (mg)"
      }      
      Slider {
        id: sodiumSlider
        Layout.row : 5
        Layout.column : 1
        Layout.fillWidth : true
        Layout.columnSpan : 2
        Layout.maximumHeight : root.parent.height / grid.rows
        from : 0
        to : 3000         //3000 mg is more than recommended amount, but most people go above recommendations
        stepSize : 100
        value : root.sodium_mass

        onMoved : {
          root.sodium_mass = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 5
        Layout.column : 3
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "%1".arg(root.sodium_mass)
      }
      //Column 7
      Label {
        Layout.row : 6
        Layout.column : 0
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "Water (mL)"
      }      
      Slider {
        id: waterSlider
        Layout.row : 6
        Layout.column : 1
        Layout.fillWidth : true
        Layout.columnSpan : 2
        Layout.maximumHeight : root.parent.height / grid.rows
        from : 0
        to : 3000         //3000 mL is more than recommended amount per day
        stepSize : 100
        value : root.water_volume

        onMoved : {
          root.water_volume = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        Layout.row : 6
        Layout.column : 3
        Layout.maximumHeight : root.parent.height / grid.rows
        text : "%1".arg(root.water_volume)
      }
      // Column 8
      Rectangle {
        id: toggle      
        Layout.row : 7
        Layout.column : 2
        Layout.columnSpan : 2
        Layout.maximumHeight : root.parent.height / grid.rows
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

  onActivate:   { scenario.create_consume_meal_action(name, carbohydrate_mass, fat_mass, protein_mass, sodium_mass,calcium_mass, water_volume)  }
  onDeactivate: { console.log("Cannot deactivate meal") }
}