import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtCharts 2.3
import QtQml.Models 2.2

import com.biogearsengine.ui.scenario 1.0
Page {
    id: root
    z : 0 // Explicitly setting this to lowest level so that messages displayed in Controls view will not get hidden behind plots

    property bool initialized : false
    property PhysiologyModel physiologyRequestModel
    property alias vitalsGridView : vitalsGridView
    property alias cardiopulmonaryGridView : cardiopulmonaryGridView
    property alias bloodChemistryGridView : bloodChemistryGridView
    property alias energyMetabolismGridView : energyMetabolismGridView
    property alias renalFluidBalanceGridView : renalFluidBalanceGridView
    property alias substanceGridView : substanceGridView
    property alias customGridView : customGridView

    property alias tenHzPlotTimer : tenHzPlotTimer
    property alias oneHzPlotTimer : oneHzPlotTimer

    state : "realTime"

    // The states defined for GraphArea relate to the timers that trigger plot updates. During "RealTime", the slower timer triggers plot updates every 1 s (1 Hz),
    // while faster timer triggers every 0.1 s (10 Hz).  At maximum run rate, these refresh rates are multipled by factor of 5 (5 Hz for slow timer, 50 Hz for
    // fast timer) to keep up with BioGears metrics update rate.  By default, all plots are assigned to slower timer (see GraphArea.qml).  Only plots that
    // absolutely require a faster sampling rate for resolution (like pressure-volume curve) should connect plot to faster timer.
    states : [
        State {
            name : "realTime"
            PropertyChanges {
                target : tenHzPlotTimer;
                interval : 100
            }
            PropertyChanges {
                target : oneHzPlotTimer;
                interval : 1000
            }
        },
        State {
            name : "max"
            PropertyChanges {
                target : tenHzPlotTimer;
                interval : 20
            }
            PropertyChanges {
                target : oneHzPlotTimer;
                interval : 200
            }
        }
    ]

    header : RowLayout {
        id : headerBar
        Layout.fillWidth : true
        Layout.fillHeight : true
        Button {
            id : previous
            text : "Prev"
            display : AbstractButton.IconOnly
            icon.source : "qrc:/icons/prev.png"
            icon.name : "terminate"
            icon.color : "transparent"
            background : Rectangle {
                color : "transparent"
            }
            onClicked : {
                if (plots.currentIndex == 0) {
                    plots.currentIndex = plots.count - 1;
                } else {
                    plots.currentIndex = plots.currentIndex - 1
                }
                if (filterMenu.visible) { // This overrides the "CloseOnReleaseOutside" policy so that menu stays open when switching to new view panel
                    filterMenu.open()
                }
            }
        }
        SwipeView {
            id : systemSwipeView
            clip : true
            Layout.fillWidth : true
            Layout.preferredWidth : 200
            Layout.preferredHeight : 40
            Repeater { // contentHeight: 40
                Layout.fillWidth : true
                Layout.preferredWidth : 200
                Layout.preferredHeight : 40
                // font.pointSize: 12
                model : physiologyRequestModel

                delegate : UITabButtonForm {
                    text : name
                }
            }
            currentIndex : plots.currentIndex
            onCurrentIndexChanged : {
                if (plots.currentIndex != currentIndex) {
                    plots.currentIndex = currentIndex;
                }
            }
        }

        Button {
            id : filterMenuButton
            text : "Filter Menu"
            display : AbstractButton.IconOnly
            icon.source : "qrc:/icons/menu.png"
            icon.name : "terminate"
            icon.color : "transparent"
            onClicked : {
                if (filterMenu.visible) {
                    filterMenu.close()
                } else {
                    filterMenu.open()
                }
            }
            background : Rectangle {
                color : "transparent"
            }
            Menu {
                id : filterMenu
                x : -200
                y : 50
                closePolicy : Popup.CloseOnEscape | Popup.CloseOnReleaseOutside
                Repeater {
                    id : filterMenuInstance
                    model : (physiologyRequestModel) ? physiologyRequestModel.category(plots.currentIndex) : null
                    // !
                    // ! Component for Selecting a Data Request.
                    // ! Creates a checkbox which activates a plot when clicked
                    // ! Covers signle and multiplots
                    Component {
                        id : singleItemComponent
                        MenuItem {
                            CheckBox {
                                checkable : true
                                checked : _model.data(_item, PhysiologyModel.EnabledRole)
                                text :    _model.data(_item, PhysiologyModel.RequestRole) 
                                onClicked : {
                                    if (checked) {
                                        _model.setData(_item, true, PhysiologyModel.EnabledRole)
                                        createPlotView(plots.currentIndex, _model, _item, _title)
                                    } else {
                                        _model.setData(_item, false, PhysiologyModel.EnabledRole)
                                        removePlotView(plots.currentIndex, _item.row, _title)
                                    }
                                }
                            }
                        }
                    }

                    // ! When a item is nested like substances
                    // ! We want to be able to select individual data request
                    // ! Under a nested menu to plot multiple single plots
                    Component {
                        id : categorySelectionComponent
                        Instantiator {
                            id : menuItemInstance
                            property var bgData : _model
                            property var entry : _item
                            model : _current
                            delegate : Menu {
                                id : substanceSubMenu
                                title : _model.data(_item, PhysiologyModel.RequestRole)
                                Repeater {
                                    id : subMenuInstance
                                    model : DelegateModel {
                                        model : _model
                                        rootIndex : _model.index(index, 0)
                                        delegate : Loader {
                                            property var _model: menuItemInstance.bgData//subMenuInstance.rootIndex.model
                                            property var _item:  menuItemInstance.bgData.index(index,0,entry)//subMenuInstance.model.index(index, 0, subMenuInstance.rootIndex)
                                            property var _title: "%1 - %2".arg(menuItemInstance.bgData.data(entry, Qt.DisplayRole))
                                                                          .arg(menuItemInstance.bgData.data(_item, Qt.DisplayRole))
                                            sourceComponent : singleItemComponent
                                        }
                                    }
                                }
                            }
                            onObjectAdded : {
                                filterMenu.addMenu(object)
                            }
                            onObjectRemoved : {
                                filterMenu.removeMenu(object)
                            }
                        }
                    }

                    delegate : Loader {
                        property var             _current : model
                        property PhysiologyModel _model : root.physiologyRequestModel.category(plots.currentIndex)
                        property var             _item  : _model.index(index, 0)
                        property var _title: "%1".arg(_model.data(_item, Qt.DisplayRole))
                        sourceComponent : {
                            if (!model.nested) {
                                return singleItemComponent
                            } else {
                                return categorySelectionComponent
                            }
                        }
                    }
                }
            }
        }
        Button {
            id : next
            text : "Next"
            display : AbstractButton.IconOnly
            icon.source : "qrc:/icons/next.png"
            icon.name : "terminate"
            icon.color : "transparent"
            onClicked : {
                if (plots.currentIndex == plots.count - 1) {
                    plots.currentIndex = 0;
                } else {
                    plots.currentIndex = plots.currentIndex + 1
                }
                if (filterMenu.visible) { // This overrides the "CloseOnReleaseOutside" policy so that menu stays open when switching to new view panel
                    filterMenu.open()
                }
            }
            background : Rectangle {
                color : "transparent"
            }
        }
    }

    SwipeView {
        id : plots
        anchors.fill : parent
        currentIndex : 0
        clip : true
        Item {
            id : vitalsSeries
            Layout.fillWidth : true
            Layout.fillHeight : true
            Rectangle {
                id : vitalsBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : vitalsGridView
                anchors.fill : parent
                clip : true
                cellWidth : parent.width / 2
                cellHeight : parent.height / 2
                model : vitalsModel
                ScrollBar.vertical : ScrollBar {
                    parent : vitalsGridView.parent
                    anchors.top : vitalsGridView.top
                    anchors.right : vitalsGridView.right
                    anchors.bottom : vitalsGridView.bottom
                }
            }
        }
        Item {
            id : cardiopulmonarySeries
            Layout.fillWidth : true
            Layout.fillHeight : true
            Rectangle {
                id : cardiovascularBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : cardiopulmonaryGridView
                anchors.fill : parent
                clip : true
                cellWidth : plots.width / 2
                cellHeight : plots.height / 2
                model : cardiopulmonaryModel
                ScrollBar.vertical : ScrollBar {
                    parent : cardiopulmonaryGridView.parent
                    anchors.top : cardiopulmonaryGridView.top
                    anchors.right : cardiopulmonaryGridView.right
                    anchors.bottom : cardiopulmonaryGridView.bottom
                }
            }
        }
        Item {
            id : bloodChemistrySeries
            Layout.fillWidth : true
            Layout.fillHeight : true
            Rectangle {
                id : bloodChemistryBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : bloodChemistryGridView
                anchors.fill : parent
                clip : true
                cellWidth : plots.width / 2
                cellHeight : plots.height / 2
                model : bloodChemistryModel
                ScrollBar.vertical : ScrollBar {
                    parent : bloodChemistryGridView.parent
                    anchors.top : bloodChemistryGridView.top
                    anchors.right : bloodChemistryGridView.right
                    anchors.bottom : bloodChemistryGridView.bottom
                }
            }
        }
        Item {
            id : energyMetabolismSeries
            Layout.fillWidth : true
            Layout.fillHeight : true

            Rectangle {
                id : energyMetabolismBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : energyMetabolismGridView
                anchors.fill : parent
                clip : true
                width : parent.width
                cellWidth : plots.width / 2
                cellHeight : plots.height / 2
                model : energyMetabolismModel
                ScrollBar.vertical : ScrollBar {
                    parent : energyMetabolismGridView.parent
                    anchors.top : energyMetabolismGridView.top
                    anchors.right : energyMetabolismGridView.right
                    anchors.bottom : energyMetabolismGridView.bottom
                }
            }
        }
        Item {
            id : renalFluidBalanceSeries
            Layout.fillWidth : true
            Layout.fillHeight : true

            Rectangle {
                id : renalFluidBalanceBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : renalFluidBalanceGridView
                anchors.fill : parent
                clip : true
                cellWidth : plots.width / 2
                cellHeight : plots.height / 2
                model : renalFluidBalanceModel
                ScrollBar.vertical : ScrollBar {
                    parent : renalFluidBalanceGridView.parent
                    anchors.top : renalFluidBalanceGridView.top
                    anchors.right : renalFluidBalanceGridView.right
                    anchors.bottom : renalFluidBalanceGridView.bottom
                }
            }
        }
        Item {
            id : substanceSeries
            Layout.fillWidth : true
            Layout.fillHeight : true
            Rectangle {
                id : substanceBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : substanceGridView
                anchors.fill : parent
                clip : true
                cellWidth : plots.width / 2
                cellHeight : plots.height / 2
                model : substanceModel
                ScrollBar.vertical : ScrollBar {
                    parent : substanceGridView.parent
                    anchors.top : substanceGridView.top
                    anchors.right : substanceGridView.right
                    anchors.bottom : substanceGridView.bottom
                }
            }
        }
        Item {
            id : customSeries
            Layout.fillWidth : true
            Layout.fillHeight : true
            Rectangle {
                id : customBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : customGridView
                anchors.fill : parent
                clip : true
                cellWidth : plots.width / 2
                cellHeight : plots.height / 2
                model : customModel
                ScrollBar.vertical : ScrollBar {
                    parent : customGridView.parent
                    anchors.top : customGridView.top
                    anchors.right : customGridView.right
                    anchors.bottom : customGridView.bottom
                }
            }
        }
    }

    PageIndicator {
        id : indicator

        count : plots.count
        currentIndex : plots.currentIndex

        anchors.bottom : plots.bottom
        anchors.horizontalCenter : plots.horizontalCenter
    }

    Timer {
        id : tenHzPlotTimer
        interval : 100
        running : false
        repeat : true
        triggeredOnStart : true
    }

    Timer {
        id : oneHzPlotTimer
        interval : 1000
        running : false
        repeat : true
        triggeredOnStart : true
    }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/

