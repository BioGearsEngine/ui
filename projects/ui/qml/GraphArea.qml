import QtQuick 2.4
import QtQuick.Controls.Material 2.12
import QtCharts 2.3
import QtQml.Models 2.2

import com.biogearsengine.ui.scenario 1.0

GraphAreaForm {
  signal start()
  signal restart()
  signal pause()

  signal metricUpdates(PatientMetrics metrics)
  signal stateUpdates(PatientState state)
  signal conditionUpdates(PatientConditions conditions)

  property double count_1 : 0.0
  property double count_2 : 0.0
  property int tickCount : -1

  property ObjectModel bloodChemistryModel : bloodChemistryObjectModel
  property ObjectModel cardiovascularModel : cardiovascularObjectModel
  property ObjectModel drugModel : drugObjectModel
  property ObjectModel endocrineModel : endocrineObjectModel
  property ObjectModel energyModel : energyObjectModel
  property ObjectModel gastrointestinalModel : gastrointestinalObjectModel
  property ObjectModel hepaticModel : hepaticObjectModel
  property ObjectModel nervousModel : nervousObjectModel
  property ObjectModel renalModel : renalObjectModel
  property ObjectModel respiratoryModel : respiratoryObjectModel
  property ObjectModel tissueModel : tissueObjectModel

  onStart : {
  }

  onRestart : {
    console.log("Resetting GraphArea Plots")
    bloodChemistryObjectModel.clearPlots()
    cardiovascularObjectModel.clearPlots()
    drugObjectModel.clearPlots()
    endocrineObjectModel.clearPlots()
    energyObjectModel.clearPlots()
    gastrointestinalObjectModel.clearPlots()
    hepaticObjectModel.clearPlots()
    nervousObjectModel.clearPlots()
    renalObjectModel.clearPlots()
    respiratoryObjectModel.clearPlots()
    tissueObjectModel.clearPlots()
  }

  onPause: {
  }

  onMetricUpdates: {
  ++tickCount;
  }

  onStateUpdates: {
  }

  onConditionUpdates: {
  }

  Component.onCompleted: {
    var bloodChemistryReq = physiologyRequestModel.get(0).requests
    for ( var i = 0; i < bloodChemistryReq.count ; ++i){
      if (bloodChemistryReq.get(i).active){
        physiologyRequestModel.get(0).activeRequests.append({"request": bloodChemistryReq.get(i).request})
        bloodChemistryObjectModel.createPlotView(bloodChemistryReq.get(i))
      }
    }
    var cardiovascularReq = physiologyRequestModel.get(1).requests
    for ( var i = 0; i < cardiovascularReq.count; ++i){
      if( cardiovascularReq.get(i).active){
        physiologyRequestModel.get(1).activeRequests.append({"request": cardiovascularReq.get(i).request})
        cardiovascularModel.createPlotView(cardiovascularReq.get(i))
      }
    }
    var drugReq = physiologyRequestModel.get(2).requests
    for ( var i = 0; i < drugReq.count; ++i){
      if( drugReq.get(i).active){
        physiologyRequestModel.get(2).activeRequests.append({"request": drugReq.get(i).request})
        drugModel.createPlotView(drugReq.get(i))
      }
    }
    var endocrineReq = physiologyRequestModel.get(3).requests
    for ( var i = 0; i < endocrineReq.count ; ++i){
      if(endocrineReq.get(i).active){
        physiologyRequestModel.get(3).activeRequests.append({"request": endocrineReq.get(i).request})
        endocrineModel.createPlotView(endocrineReq.get(i))
      }
    }
    var energyReq = physiologyRequestModel.get(4).requests
    for ( var i = 0; i < energyReq.count ; ++i){
      if(energyReq.get(i).active){
        physiologyRequestModel.get(4).activeRequests.append({"request": energyReq.get(i).request})
        energyModel.createPlotView(energyReq.get(i))
      }  
    }
    var gastrointestinalReq = physiologyRequestModel.get(5).requests
    for ( var i = 0; i < gastrointestinalReq.count ; ++i){
      if( gastrointestinalReq.get(i).active){
        physiologyRequestModel.get(5).activeRequests.append({"request": gastrointestinalReq.get(i).request})
        gastrointestinalModel.createPlotView(gastrointestinalReq.get(i))
      }
    }
    var hepaticReq = physiologyRequestModel.get(6).requests
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
    }
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
        var chartObject = chartComponent.createObject(bloodChemistryGridView,{"width" : bloodChemistryGridView.cellWidth, "height" :  bloodChemistryGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        metricUpdates.connect(chartObject.updateSeries)
        bloodChemistryObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < bloodChemistryObjectModel.count; ++i){
        bloodChemistryObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
      for (var i = 0; i < bloodChemistryObjectModel.count; ++i){
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

 //Cardiovascular//
  ObjectModel {
    id: cardiovascularObjectModel
    function createPlotView (request) {
      var chartComponent = Qt.createComponent("UIPlotSeries.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        var chartObject = chartComponent.createObject(cardiovascularGridView,{"width" : cardiovascularGridView.cellWidth, "height" : cardiovascularGridView.cellHeight });
        chartObject.initializeChart(request, tickCount);
        metricUpdates.connect(chartObject.updateSeries)
        cardiovascularObjectModel.append(chartObject)
      }
    }
    function resizePlots(newWidth, newHeight){
      for (var i = 0; i < cardiovascularObjectModel.count; ++i){
        cardiovascularObjectModel.get(i).resizePlot(newWidth, newHeight);
      }
    }
    function clearPlots() {
        for (var i = 0; i < count; ++i){
          cardiovascularObjectModel.get(i).clear();
        }
    }
  }

 cardiovascularGridView.onCellWidthChanged : {
  cardiovascularObjectModel.resizePlots(cardiovascularGridView.cellWidth, cardiovascularGridView.cellHeight)
 }
 cardiovascularGridView.onCellHeightChanged : {
  cardiovascularObjectModel.resizePlots(cardiovascularGridView.cellWidth, cardiovascularGridView.cellHeight)
 }

//Drugs//
ObjectModel {
  id: drugObjectModel
  function createPlotView (request) {
    var chartComponent = Qt.createComponent("UIPlotSeries.qml");
    if ( chartComponent.status != Component.Ready){
      if (chartComponent.status == Component.Error){
      console.log("Error : " + chartComponent.errorString() );
      return;
      }
      console.log("Error : Chart component not ready");
    } else {
      var chartObject = chartComponent.createObject(drugGridView,{"width" : drugGridView.cellWidth, "height" : drugGridView.cellHeight });
      chartObject.initializeChart(request, tickCount);
      metricUpdates.connect(chartObject.updateSeries)
      drugObjectModel.append(chartObject)
    }
  }
  function resizePlots(newWidth, newHeight){
    for (var i = 0; i < drugObjectModel.count; ++i){
      drugObjectModel.get(i).resizePlot(newWidth, newHeight);
    }
  }
  function clearPlots() {
      for (var i = 0; i < count; ++i){
        drugObjectModel.get(i).clear();
      }
  }
}

drugGridView.onCellWidthChanged : {
  drugObjectModel.resizePlots(drugGridView.cellWidth, drugGridView.cellHeight)
}
drugGridView.onCellHeightChanged : {
  drugObjectModel.resizePlots(drugGridView.cellWidth, drugGridView.cellHeight)
}

//Endocrine//
ObjectModel {
  id: endocrineObjectModel
  function createPlotView (request) {
    var chartComponent = Qt.createComponent("UIPlotSeries.qml");
    if ( chartComponent.status != Component.Ready){
      if (chartComponent.status == Component.Error){
      console.log("Error : " + chartComponent.errorString() );
      return;
      }
      console.log("Error : Chart component not ready");
    } else {
      var chartObject = chartComponent.createObject(endocrineGridView,{"width" : endocrineGridView.cellWidth, "height" : endocrineGridView.cellHeight });
      chartObject.initializeChart(request, tickCount);
      metricUpdates.connect(chartObject.updateSeries)
      endocrineObjectModel.append(chartObject)
    }
  }
  function resizePlots(newWidth, newHeight){
    for (var i = 0; i < endocrineObjectModel.count; ++i){
      endocrineObjectModel.get(i).resizePlot(newWidth, newHeight);
    }
  }
  function clearPlots() {
      for (var i = 0; i < count; ++i){
        endocrineObjectModel.get(i).clear();
      }
  }
}

endocrineGridView.onCellWidthChanged : {
  endocrineObjectModel.resizePlots(endocrineGridView.cellWidth, endocrineGridView.cellHeight)
}
endocrineGridView.onCellHeightChanged : {
  endocrineObjectModel.resizePlots(endocrineGridView.cellWidth, endocrineGridView.cellHeight)
}

//Energy//
ObjectModel {
  id: energyObjectModel
  function createPlotView (request) {
    var chartComponent = Qt.createComponent("UIPlotSeries.qml");
    if ( chartComponent.status != Component.Ready){
      if (chartComponent.status == Component.Error){
      console.log("Error : " + chartComponent.errorString() );
      return;
      }
      console.log("Error : Chart component not ready");
    } else {
      var chartObject = chartComponent.createObject(energyGridView,{"width" : energyGridView.cellWidth, "height" : energyGridView.cellHeight });
      chartObject.initializeChart(request, tickCount);
      metricUpdates.connect(chartObject.updateSeries)
      energyObjectModel.append(chartObject)
    }
  }
  function resizePlots(newWidth, newHeight){
    for (var i = 0; i < energyObjectModel.count; ++i){
      energyObjectModel.get(i).resizePlot(newWidth, newHeight);
    }
  }
  function clearPlots() {
      for (var i = 0; i < count; ++i){
        energyObjectModel.get(i).clear();
      }
  }
}

energyGridView.onCellWidthChanged : {
  energyObjectModel.resizePlots(energyGridView.cellWidth, energyGridView.cellHeight)
}
energyGridView.onCellHeightChanged : {
  energyObjectModel.resizePlots(energyGridView.cellWidth, energyGridView.cellHeight)
}

//Gastrointestinal//
ObjectModel {
  id: gastrointestinalObjectModel
  function createPlotView (request) {
    var chartComponent = Qt.createComponent("UIPlotSeries.qml");
    if ( chartComponent.status != Component.Ready){
      if (chartComponent.status == Component.Error){
      console.log("Error : " + chartComponent.errorString() );
      return;
      }
      console.log("Error : Chart component not ready");
    } else {
      var chartObject = chartComponent.createObject(gastrointestinalGridView,{"width" : gastrointestinalGridView.cellWidth, "height" : gastrointestinalGridView.cellHeight });
      chartObject.initializeChart(request, tickCount);
      metricUpdates.connect(chartObject.updateSeries)
      gastrointestinalObjectModel.append(chartObject)
    }
  }
  function resizePlots(newWidth, newHeight){
    for (var i = 0; i < gastrointestinalObjectModel.count; ++i){
      gastrointestinalObjectModel.get(i).resizePlot(newWidth, newHeight);
    }
  }
  function clearPlots() {
      for (var i = 0; i < count; ++i){
        gastrointestinalObjectModel.get(i).clear();
      }
  }
}

gastrointestinalGridView.onCellWidthChanged : {
  gastrointestinalObjectModel.resizePlots(gastrointestinalGridView.cellWidth, gastrointestinalGridView.cellHeight)
}
gastrointestinalGridView.onCellHeightChanged : {
  gastrointestinalObjectModel.resizePlots(gastrointestinalGridView.cellWidth, gastrointestinalGridView.cellHeight)
}

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
      metricUpdates.connect(chartObject.updateSeries)
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
      metricUpdates.connect(chartObject.updateSeries)
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
      metricUpdates.connect(chartObject.updateSeries)
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
      metricUpdates.connect(chartObject.updateSeries)
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
      metricUpdates.connect(chartObject.updateSeries)
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
    bloodChemistryObjectModel.createPlotView(modelElement);
    break;
  case 1:
    cardiovascularModel.createPlotView(modelElement);
    break;
  case 2:
    drugModel.createPlotView(modelElement);
    break;
  case 3:
    endocrineModel.createPlotView(modelElement);
    break;
  case 4:
    energyModel.createPlotView(modelElement);
    break;
  case 5:
    gastrointestinalModel.createPlotView(modelElement);
    break;
  case 6:
    hepaticModel.createPlotView(modelElement);
    break;
  case 7:
    nervousModel.createPlotView(modelElement);
    break;
  case 8:
    renalModel.createPlotView(modelElement);
    break;
  case 9:
    respiratoryModel.createPlotView(modelElement);
    break;
  case 10:
    tissueModel.createPlotView(modelElement);
    break;
  }
  }

  function removePlotView(index, request){
  //We can search through list of active requests (rather than lists of chart objects and their titles) because we always append/remove an active request and chart at the same time
  var i = findRequestIndex(physiologyRequestModel.get(index).activeRequests, request)
  physiologyRequestModel.get(index).activeRequests.remove(i,1)
  if (i != -1){ 
  switch(index) {
    case 0:
    bloodChemistryObjectModel.remove(i,1)
    break;
    case 1:
    cardiovascularModel.remove(i,1)
    break;
    case 2:
    drugModel.remove(i,1)
    physiologyRequestModel.get(index).activeRequests.remove(i,1)
    break;
    case 3:
    endocrineModel.remove(i,1)
    physiologyRequestModel.get(index).activeRequests.remove(i,1)
    break;
    case 4:
    energyModel.remove(i,1)
    physiologyRequestModel.get(index).activeRequests.remove(i,1)
    break;
    case 5:
    gastrointestinalModel.remove(i,1)
    physiologyRequestModel.get(index).activeRequests.remove(i,1)
    break;
    case 6:
    hepaticModel.remove(i,1)
    physiologyRequestModel.get(index).activeRequests.remove(i,1)
    break;
    case 7:
    nervousModel.remove(i,1)
    physiologyRequestModel.get(index).activeRequests.remove(i,1)
    break;
    case 8:
    renalModel.remove(i,1)
    physiologyRequestModel.get(index).activeRequests.remove(i,1)
    break;
    case 9:
    respiratoryModel.remove(i,1)
    physiologyRequestModel.get(index).activeRequests.remove(i,1)
    break;
    case 10:
    tissueModel.remove(i,1)
    physiologyRequestModel.get(index).activeRequests.remove(i,1)
    break;
    }
  } else {
    console.log("No active plot : " + request)
  }
  }

}
