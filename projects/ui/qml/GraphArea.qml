import QtQuick 2.4
import QtQuick.Controls.Material 2.12
import QtCharts 2.3
import QtQml.Models 2.2

import com.biogearsengine.ui.scenario 1.0

GraphAreaForm {

  id: root
  Rectangle {
    anchors.fill : parent
    border.color: "black"; color: "transparent"
  }
  signal start()
  signal restart()
  signal pause(bool paused)
  signal speedToggled(int speed)

  signal tenHzPlotRefresh(PatientMetrics metrics)
  signal oneHzPlotRefresh(PatientMetrics metrics)

  signal metricUpdates(PatientMetrics metrics)
  signal substanceDataUpdates(real time, var subData)
  signal stateUpdates(PatientState state)
  signal conditionUpdates(PatientConditions conditions)
  signal newActiveSubstance(Substance sub)

  property double count_1 : 0.0
  property double count_2 : 0.0
  property int tickCount : -1

  property PatientMetrics plotMetrics
  property ObjectModel vitalsModel : vitalsObjectModel
  property ObjectModel cardiopulmonaryModel : cardiopulmonaryObjectModel
  property ObjectModel bloodChemistryModel : bloodChemistryObjectModel
  property ObjectModel energyMetabolismModel : energyMetabolismObjectModel
  property ObjectModel renalFluidBalanceModel : renalFluidBalanceObjectModel
  property ObjectModel substanceModel : substanceObjectModel
  property ListModel substanceMenuListModel : substanceMenuListModel
  property ObjectModel customModel : customObjectModel
  //property ObjectModel hepaticModel : hepaticObjectModel
  //property ObjectModel nervousModel : nervousObjectModel
  //property ObjectModel renalModel : renalObjectModel
  //property ObjectModel respiratoryModel : respiratoryObjectModel
  //property ObjectModel tissueModel : tissueObjectModel


  onStart : {
    oneHzPlotTimer.start()
    tenHzPlotTimer.start()
    console.log("start")
  }

  onRestart : {
    oneHzPlotTimer.stop()
    tenHzPlotTimer.stop()
    console.log("Resetting GraphArea Plots")
    vitalsObjectModel.clearPlots()
    cardiopulmonaryObjectModel.clearPlots()
    bloodChemistryObjectModel.clearPlots()
    energyMetabolismObjectModel.clearPlots()
    renalFluidBalanceObjectModel.clearPlots()
    substanceObjectModel.clearPlots()
    customObjectModel.clearPlots()
    //hepaticObjectModel.clearPlots()
    //nervousObjectModel.clearPlots()
    //renalObjectModel.clearPlots()
    //respiratoryObjectModel.clearPlots()
    //tissueObjectModel.clearPlots()
  }

  onPause: {
    if (paused){
      oneHzPlotTimer.stop();
      tenHzPlotTimer.stop();
    } else {
      oneHzPlotTimer.start();
      tenHzPlotTimer.start();
    }
  }

  onSpeedToggled :{
    console.log("Speed = " + speed)
    if (speed == 1){
      root.state = "realTime"
    } else {
      root.state = "max"
    }
  }

  onOneHzPlotRefresh : {
    ++tickCount;
  }

  onMetricUpdates: {
    plotMetrics = metrics
  }

  onStateUpdates: {
  }

  onConditionUpdates: {
  }


  onNewActiveSubstance : {
    //First extract the properties that are valid to plot for the new substance -- invalid properties will = -1 (see Substance.h)
    //We also ignore unplottable properties ("Name", "objectName", "objectNameChanged", the latter two of which are auto assigned by qml)
    let validProps = []
    for (let prop in sub){
      if (sub[prop] == -1.0 || prop == "Name" || prop == "objectNameChanged" || prop == "objectName"){
        continue;
      }
      validProps.push({"propName" : prop})
    }
    substanceMenuListModel.append({"subName" : sub.Name, "props" : validProps})    
  }


  Component.onCompleted: {
    var vitalsReq = physiologyRequestModel.get(0).requests
    for ( var i = 0; i < vitalsReq.count ; ++i){
      if (vitalsReq.get(i).active){
				physiologyRequestModel.get(0).activeRequests.append({"request": vitalsReq.get(i).request})
				vitalsModel.createPlotView(vitalsReq.get(i))
			}
    }
    var cardiopulmonaryReq = physiologyRequestModel.get(1).requests
    for ( var i = 0; i < cardiopulmonaryReq.count; ++i){
      if( cardiopulmonaryReq.get(i).active){
        physiologyRequestModel.get(1).activeRequests.append({"request": cardiopulmonaryReq.get(i).request})
        cardiopulmonaryModel.createPlotView(cardiopulmonaryReq.get(i))
      }
    }
    var bloodChemistryReq = physiologyRequestModel.get(2).requests
    for ( var i = 0; i < bloodChemistryReq.count; ++i){
      if( bloodChemistryReq.get(i).active){
        physiologyRequestModel.get(2).activeRequests.append({"request": bloodChemistryReq.get(i).request})
        bloodChemistryModel.createPlotView(bloodChemistryReq.get(i))
      }
    }
    var energyMetabolismReq = physiologyRequestModel.get(3).requests
    for ( var i = 0; i < energyMetabolismReq.count ; ++i){
      if(energyMetabolismReq.get(i).active){
        physiologyRequestModel.get(3).activeRequests.append({"request": energyMetabolismReq.get(i).request})
        energyMetabolismModel.createPlotView(energyMetabolismReq.get(i))
      }
    }
    var renalFluidBalanceReq = physiologyRequestModel.get(4).requests
    for ( var i = 0; i < renalFluidBalanceReq.count ; ++i){
      if(renalFluidBalanceReq.get(i).active){
        physiologyRequestModel.get(4).activeRequests.append({"request": renalFluidBalanceReq.get(i).request})
        renalFluidBalanceModel.createPlotView(renalFluidBalanceReq.get(i))
      }  
    }
    var customReq = physiologyRequestModel.get(5).requests
    for ( var i = 0; i < customReq.count ; ++i){
      if( customReq.get(i).active){
        physiologyRequestModel.get(5).activeRequests.append({"request": customReq.get(i).request})
        customModel.createPlotView(customReq.get(i))
      }
    }
    /*var hepaticReq = physiologyRequestModel.get(6).requests
    for ( var i = 0; i < hepaticReq.count ; ++i){
      if(hepaticReq.get(i).active){
        physiologyRequestModel.get(6).activeRequests.append({"request": hepaticReq.get(i).request})
        hepaticModel.createPlotView(hepaticReq.get(i))
      }
    }
    var nervousReq = physiologyRequestModel.get(7).requests
    for ( var i = 0; i < nervousReq.count; ++i){
      if( nervousReq.get(i).active){
        physiologyRequestModel.get(7).activeRequests.append({"request": nervousReq.get(i).request})
        nervousModel.createPlotView(nervousReq.get(i))
      } 
    }
    var renalReq = physiologyRequestModel.get(8).requests
    for ( var i = 0; i < renalReq.count ; ++i){
      if(renalReq.get(i).active){
        physiologyRequestModel.get(8).activeRequests.append({"request": renalReq.get(i).request})
        renalModel.createPlotView(renalReq.get(i))
      } 
    }
    var respiratoryReq = physiologyRequestModel.get(9).requests
    for ( var i = 0; i < respiratoryReq.count ; ++i){
      if(respiratoryReq.get(i).active){
        physiologyRequestModel.get(9).activeRequests.append({"request": respiratoryReq.get(i).request})
        respiratoryModel.createPlotView(respiratoryReq.get(i))
      }
    }
    var tissueReq = physiologyRequestModel.get(10).requests
    for ( var i = 0; i < tissueReq.count ; ++i){
      if(tissueReq.get(i).active){
        physiologyRequestModel.get(10).activeRequests.append({"request": tissueReq.get(i).request})
        tissueModel.createPlotView(tissueReq.get(i))
      }
    }*/
  }
  //Vitals//
  ObjectModel {
    id: vitalsObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("UIPlotSeries.qml");
      if ( chartComponent.status != Component.Ready){
      if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
      }
      console.log("Error : Chart component not ready");
      } else {
        var chartObject = chartComponent.createObject(vitalsGridView,{"width" : vitalsGridView.cellWidth, "height" :  vitalsGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        oneHzPlotRefresh.connect(chartObject.updatePatientSeries)
        vitalsObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < vitalsObjectModel.count; ++i){
        vitalsObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < vitalsObjectModel.count; ++i){
        vitalsObjectModel.get(i).clear();
      }
    }
  }

  vitalsGridView.onCellWidthChanged : {
    vitalsObjectModel.resizePlots(vitalsGridView.cellWidth, vitalsGridView.cellHeight)
  }
  vitalsGridView.onCellHeightChanged : {
    vitalsObjectModel.resizePlots(vitalsGridView.cellWidth, vitalsGridView.cellHeight)
  }

 //Cardiopulmonary//
  ObjectModel {
    id: cardiopulmonaryObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("UIPlotSeries.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        var chartObject = chartComponent.createObject(cardiopulmonaryGridView,{"width" : cardiopulmonaryGridView.cellWidth, "height" : cardiopulmonaryGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        oneHzPlotRefresh.connect(chartObject.updatePatientSeries)
        cardiopulmonaryObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < cardiopulmonaryObjectModel.count; ++i){
        cardiopulmonaryObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < count; ++i){
        cardiopulmonaryObjectModel.get(i).clear();
      }
    }
  }

  cardiopulmonaryGridView.onCellWidthChanged : {
    cardiopulmonaryObjectModel.resizePlots(cardiopulmonaryGridView.cellWidth, cardiopulmonaryGridView.cellHeight)
  }
  cardiopulmonaryGridView.onCellHeightChanged : {
    cardiopulmonaryObjectModel.resizePlots(cardiopulmonaryGridView.cellWidth, cardiopulmonaryGridView.cellHeight)
  }

  //Blood Chemistry//
  ObjectModel {
    id: bloodChemistryObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("UIPlotSeries.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        var chartObject = chartComponent.createObject(bloodChemistryGridView,{"width" : bloodChemistryGridView.cellWidth, "height" : bloodChemistryGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        oneHzPlotRefresh.connect(chartObject.updatePatientSeries)
        bloodChemistryObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < bloodChemistryObjectModel.count; ++i){
        bloodChemistryObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < count; ++i){
        bloodChemistryObjectModel.get(i).clear();
      }
    }
  }

  bloodChemistryGridView.onCellWidthChanged : {
    bloodChemistryObjectModel.resizePlots(bloodChemistryGridView.cellWidth, bloodChemistryGridView.cellHeight)
  }
  bloodChemistryGridView.onCellHeightChanged : {
    bloodChemistryObjectModel.resizePlots(bloodChemistryGridView.cellWidth, bloodChemistryGridView.cellHeight)
  }

  //Energy - Metabolism//
  ObjectModel {
    id: energyMetabolismObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("UIPlotSeries.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        var chartObject = chartComponent.createObject(energyMetabolismGridView,{"width" : energyMetabolismGridView.cellWidth, "height" : energyMetabolismGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        oneHzPlotRefresh.connect(chartObject.updatePatientSeries)
        energyMetabolismObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < energyMetabolismObjectModel.count; ++i){
        energyMetabolismObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < count; ++i){
        energyMetabolismObjectModel.get(i).clear();
      }
    }
  }

  energyMetabolismGridView.onCellWidthChanged : {
    energyMetabolismObjectModel.resizePlots(energyMetabolismGridView.cellWidth, energyMetabolismGridView.cellHeight)
  }
  energyMetabolismGridView.onCellHeightChanged : {
    energyMetabolismObjectModel.resizePlots(energyMetabolismGridView.cellWidth, energyMetabolismGridView.cellHeight)
  }

  //Renal - Fluid Balance//
  ObjectModel {
    id: renalFluidBalanceObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("UIPlotSeries.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        var chartObject = chartComponent.createObject(renalFluidBalanceGridView,{"width" : renalFluidBalanceGridView.cellWidth, "height" : renalFluidBalanceGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        oneHzPlotRefresh.connect(chartObject.updatePatientSeries)
        renalFluidBalanceObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < renalFluidBalanceObjectModel.count; ++i){
        renalFluidBalanceObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < count; ++i){
        renalFluidBalanceObjectModel.get(i).clear();
      }
    }
  }

  renalFluidBalanceGridView.onCellWidthChanged : {
    renalFluidBalanceObjectModel.resizePlots(renalFluidBalanceGridView.cellWidth, renalFluidBalanceGridView.cellHeight)
  }
  renalFluidBalanceGridView.onCellHeightChanged : {
    renalFluidBalanceObjectModel.resizePlots(renalFluidBalanceGridView.cellWidth, renalFluidBalanceGridView.cellHeight)
  }

  //Substances
  ListModel {
    //List model for menu of currently active substances and valid properties--blank at initialization (dynamically updated by onNewActiveSubstance)
    id : substanceMenuListModel
  }
  ObjectModel {
    id: substanceObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("UIPlotSeries.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        var chartObject = chartComponent.createObject(substanceGridView,{"width" : substanceGridView.cellWidth, "height" : substanceGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        substanceDataUpdates.connect(chartObject.updateSubstanceSeries)
        substanceObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < substanceObjectModel.count; ++i){
        substanceObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < count; ++i){
        console.log(i)
        substanceObjectModel.get(i).clear();
      }
    }
  }

  substanceGridView.onCellWidthChanged : {
    substanceObjectModel.resizePlots(substanceGridView.cellWidth, substanceGridView.cellHeight)
  }
  substanceGridView.onCellHeightChanged : {
    substanceObjectModel.resizePlots(substanceGridView.cellWidth, substanceGridView.cellHeight)
  }

  //Custom Views//
  ObjectModel {
    id: customObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("CustomPlots.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        switch (request.request) {
          case "respiratoryPVCycle" :
            var chartObject = chartComponent.createObject(customGridView,{"width" : customGridView.cellWidth, "height" : customGridView.cellHeight });
            chartObject.initializeRespiratoryPVSeries();
            tenHzPlotRefresh.connect(chartObject.updateRespiratoryPVSeries)
            customObjectModel.append(chartObject);
            break;
          default :
            console.log(request + " not found");
        } 
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < customObjectModel.count; ++i){
        customObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < count; ++i){
        customObjectModel.get(i).clear();
      }
    }
  }

  customGridView.onCellWidthChanged : {
    customObjectModel.resizePlots(customGridView.cellWidth, customGridView.cellHeight)
  }
  customGridView.onCellHeightChanged : {
    customObjectModel.resizePlots(customGridView.cellWidth, customGridView.cellHeight)
  }

  /*
  //Hepatic//
  ObjectModel {
    id: hepaticObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("UIPlotSeries.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        var chartObject = chartComponent.createObject(hepaticGridView,{"width" : hepaticGridView.cellWidth, "height" : hepaticGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        oneHzPlotRefresh.connect(chartObject.updatePatientSeries)
        hepaticObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < hepaticObjectModel.count; ++i){
        hepaticObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < count; ++i){
        hepaticObjectModel.get(i).clear();
      }
    }
  }

  hepaticGridView.onCellWidthChanged : {
    hepaticObjectModel.resizePlots(hepaticGridView.cellWidth, hepaticGridView.cellHeight)
  }
  hepaticGridView.onCellHeightChanged : {
    hepaticObjectModel.resizePlots(hepaticGridView.cellWidth, hepaticGridView.cellHeight)
  }

  //Nervous//
  ObjectModel {
    id: nervousObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("UIPlotSeries.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        var chartObject = chartComponent.createObject(nervousGridView,{"width" : nervousGridView.cellWidth, "height" : nervousGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        oneHzPlotRefresh.connect(chartObject.updatePatientSeries)
        nervousObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < nervousObjectModel.count; ++i){
        nervousObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < count; ++i){
        nervousObjectModel.get(i).clear();
      }
    }
  }

  nervousGridView.onCellWidthChanged : {
    nervousObjectModel.resizePlots(nervousGridView.cellWidth, nervousGridView.cellHeight)
  }
  nervousGridView.onCellHeightChanged : {
    nervousObjectModel.resizePlots(nervousGridView.cellWidth, nervousGridView.cellHeight)
  }

  //Renal//
  ObjectModel {
    id: renalObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("UIPlotSeries.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        var chartObject = chartComponent.createObject(renalGridView,{"width" : renalGridView.cellWidth, "height" : renalGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        oneHzPlotRefresh.connect(chartObject.updatePatientSeries)
        renalObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < renalObjectModel.count; ++i){
        renalObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < count; ++i){
        renalObjectModel.get(i).clear();
      }
    }
  }

  renalGridView.onCellWidthChanged : {
    renalObjectModel.resizePlots(renalGridView.cellWidth, renalGridView.cellHeight)
  }
  renalGridView.onCellHeightChanged : {
    renalObjectModel.resizePlots(renalGridView.cellWidth, renalGridView.cellHeight)
  }

  //Respiratory//
  ObjectModel {
    id: respiratoryObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("UIPlotSeries.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        var chartObject = chartComponent.createObject(respiratoryGridView,{"width" : respiratoryGridView.cellWidth, "height" : respiratoryGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        oneHzPlotRefresh.connect(chartObject.updatePatientSeries)
        respiratoryObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < respiratoryObjectModel.count; ++i){
        respiratoryObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < count; ++i){
        respiratoryObjectModel.get(i).clear();
      }
    }
  }

  respiratoryGridView.onCellWidthChanged : {
    respiratoryObjectModel.resizePlots(respiratoryGridView.cellWidth, respiratoryGridView.cellHeight)
  }
  respiratoryGridView.onCellHeightChanged : {
    respiratoryObjectModel.resizePlots(respiratoryGridView.cellWidth, respiratoryGridView.cellHeight)
  }

  //Tissue//
  ObjectModel {
    id: tissueObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("UIPlotSeries.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        var chartObject = chartComponent.createObject(tissueGridView,{"width" : tissueGridView.cellWidth, "height" : tissueGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        oneHzPlotRefresh.connect(chartObject.updatePatientSeries)
        tissueObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < tissueObjectModel.count; ++i){
        tissueObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < count; ++i){
        tissueObjectModel.get(i).clear();
      }
    }
  }

  tissueGridView.onCellWidthChanged : {
    tissueObjectModel.resizePlots(tissueGridView.cellWidth, tissueGridView.cellHeight)
  }
  tissueGridView.onCellHeightChanged : {
    tissueObjectModel.resizePlots(tissueGridView.cellWidth, tissueGridView.cellHeight)
  }
  */

  //This function is specific to searching physiology request lists for an element with a "request" field that matches the input
  //We can look to generalize this to other fields if/when needed
  function findRequestIndex(list, searchRequest){
    var index = -1;
    for (var i = 0; i < list.count; ++i){
      if (list.get(i).request == searchRequest){
        index = i;
        break;
      }
    }
    return index;
  }

  function createPlotView(index, modelElement){
    physiologyRequestModel.get(index).activeRequests.append({"request":modelElement.request})
    switch(index) {
      case 0:
        vitalsModel.createPlotView(modelElement);
        break;
      case 1:
        cardiopulmonaryModel.createPlotView(modelElement);
        break;
      case 2:
        bloodChemistryModel.createPlotView(modelElement);
        break;
      case 3:
        energyMetabolismModel.createPlotView(modelElement);
        break;
      case 4:
        renalFluidBalanceModel.createPlotView(modelElement);
        break;
      case 5:
        substanceModel.createPlotView(modelElement);
        break;
      case 6:
        customModel.createPlotView(modelElement);
        break;
      /*case 7:
        hepaticModel.createPlotView(modelElement);
        break;
      case 8:
        nervousModel.createPlotView(modelElement);
        break;
      case 9:
        renalModel.createPlotView(modelElement);
        break;
      case 10:
        respiratoryModel.createPlotView(modelElement);
        break;
      case 11:
        tissueModel.createPlotView(modelElement);
        break;*/
    }
  }

  function removePlotView(index, request){
    //We can search through list of active requests (rather than lists of chart objects and their titles) because we always append/remove an active request and chart at the same time
    var i = findRequestIndex(physiologyRequestModel.get(index).activeRequests, request)
    console.log(i)
    physiologyRequestModel.get(index).activeRequests.remove(i,1)
    if (i != -1){
      let chart;
      switch(index) {
        case 0:
          chart = vitalsModel.get(i)
          oneHzPlotRefresh.disconnect(chart.updatePatientSeries)
          vitalsModel.remove(i,1)
          break;
        case 1:
          chart = cardiopulmonaryModel.get(i)
          oneHzPlotRefresh.disconnect(chart.updatePatientSeries)
          cardiopulmonaryModel.remove(i,1)
          break;
        case 2:
          chart = bloodChemistryModel.get(i)
          oneHzPlotRefresh.disconnect(chart.updatePatientSeries)
          bloodChemistryModel.remove(i,1)
          break;
        case 3:
          chart = energyMetabolismModel.get(i)
          oneHzPlotRefresh.disconnect(chart.updatePatientSeries)
          energyMetabolismModel.remove(i,1)
          break;
        case 4:
          chart = renalFluidBalanceModel.get(i)
          oneHzPlotRefresh.disconnect(chart.updatePatientSeries)
          renalFluidBalanceModel.remove(i,1)
          break;
        case 5:
          chart = substanceModel.get(i)
          oneHzPlotRefresh.disconnect(chart.updateSubstanceSeries)
          substanceModel.remove(i,1)
        case 6:
          customModel.remove(i,1)
          break;
        /*case 7:
          hepaticModel.remove(i,1)
          break;
        case 8:
          nervousModel.remove(i,1)
          break;
        case 9:
          renalModel.remove(i,1)
          break;
        case 10:
          respiratoryModel.remove(i,1)
          break;
        case 11:
          tissueModel.remove(i,1)
          break;
        */
      }
    } else {
      console.log("No active plot : " + request)
    }
  }

  //Takes request (or subrequest) name (in camel case) and converts to normal format, e.g. systolicArterialPressure -> Systolic Arterial Pressure, for clear plot title and lengend labels
  function formatRequest(request){
    //Expression ([a-z])([A-Z]) searches for lower case letter followed by upper case (this way, something like "PH" isn't split into "P H").  
    //Parenthesis around each range capture the value in string, which we can call using $ syntax.  '$1 $2' means put a space between the first captured value (lower) and second captured value (upper)
    let formatted = request.replace(/([a-z])([A-Z])/g, '$1 $2')
    //Next, make sure that first character is upper case.  ^[a-z] specifies that we are only looking at leading character.
    formatted = formatted.replace(/^[a-z]/, u=>u.toUpperCase());
    return formatted
  }

}
