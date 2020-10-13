import QtQuick 2.4
import QtQuick.Controls.Material 2.12
import QtCharts 2.3
import QtQml.Models 2.2

import com.biogearsengine.ui.scenario 1.0

GraphAreaForm {
  id: root
  signal start()
  signal restart()
  signal pause(bool paused)
  signal speedToggled(int speed)
  signal stateUpdates(PatientState state)
  signal conditionUpdates(PatientConditions conditions)
  signal newActiveSubstance(var subIndex)
  signal newPhysiologyModel(PhysiologyModel model)
  property double count_1 : 0.0
  property double count_2 : 0.0
  property ObjectModel vitalsModel : vitalsObjectModel
  property ObjectModel cardiovascularModel : cardiovascularObjectModel
  property ObjectModel bloodChemistryModel : bloodChemistryObjectModel
  property ObjectModel energyMetabolismModel : energyMetabolismObjectModel
  property ObjectModel respiratoryModel : respiratoryObjectModel
  property ObjectModel renalModel : renalObjectModel
  property ObjectModel substanceModel : substanceObjectModel
  property ObjectModel customModel : customObjectModel
  property Urinalysis urinalysis
  property double currentTime_s

  Rectangle {
    anchors.fill : parent
    border.color: "black"; color: "transparent"
  }

  // Request = "C++ PhysiologyReqest"
  // ObjectModel = QML ObjectModel
  // View = QML QT QUICK View
  // eventSignal = Signal that will fire updatePatientSeries
  function createPlotViewHelper (model, request, title, objectModel, view, refreshRate) {
    var chartComponent = Qt.createComponent("UIPlotSeries.qml");
    if ( chartComponent.status != Component.Ready){
      if (chartComponent.status == Component.Error){
      console.log("Error : " + chartComponent.errorString() );
      return;
      }
      console.log("Error : Chart component not ready");
    } else {
      var chartObject = chartComponent.createObject(view,{"width" : view.cellWidth, "height" : view.cellHeight });
      chartObject.initializeChart(model, request, title, currentTime_s);
      objectModel.append(chartObject)
    }
  }
  function updatePlotHelper(plot, series, value){

  }
  function resizePlotsHelper(newWidth, newHeight, objectModel){
    for (var i = 0; i < objectModel.count; ++i){
      objectModel.get(i).resizePlot(newWidth, newHeight);
    }
  }  
  function clearPlotsHelper(objectModel) {
    for (var i = 0; i < objectModel.count; ++i){
      objectModel.get(i).clear();
    }
  }

  onNewPhysiologyModel : {
    physiologyRequestModel = model;
	  energyMetabolismSeries.physiologyEnergyModel = (physiologyRequestModel.category(PhysiologyModel.ENERGY_AND_METABOLISM))
	  energyMetabolismSeries.physiologyVitalsModel = (physiologyRequestModel.category(PhysiologyModel.VITALS))
	  renalSeries.physiologyRenalModel = (physiologyRequestModel.category(PhysiologyModel.RENAL))
  }
  onUrinalysisChanged : {
	  renalSeries.urinalysisData = urinalysis;
  }
  onStart : {
    oneHzPlotTimer.start();
    fiveHzPlotTimer.start();
    tenHzPlotTimer.start();
    everyFiveSecondsPlotTimer.start();
    everyTenSecondsPlotTimer.start();
	  energyTimer.start();
	  renalTimer.start();
  }
  onRestart : {
    oneHzPlotTimer.stop();
    fiveHzPlotTimer.stop();
    tenHzPlotTimer.stop();
    everyFiveSecondsPlotTimer.stop();
    everyTenSecondsPlotTimer.stop();
	  energyTimer.stop();
	  renalTimer.stop();
    vitalsObjectModel.clearPlots()
    cardiovascularObjectModel.clearPlots()
    bloodChemistryObjectModel.clearPlots()
    energyMetabolismObjectModel.clearPlots()
    respiratoryObjectModel.clearPlots()
	  renalObjectModel.clearPlots()
    substanceObjectModel.clearPlots()
    customObjectModel.clearPlots()
  }
  onPause: {
    if (paused){
      oneHzPlotTimer.stop();
      fiveHzPlotTimer.stop();
      tenHzPlotTimer.stop();
      everyFiveSecondsPlotTimer.stop();
      everyTenSecondsPlotTimer.stop();
	    energyTimer.stop();
	    renalTimer.stop();
    } else {
      oneHzPlotTimer.start();
      fiveHzPlotTimer.start();
      tenHzPlotTimer.start();
      everyFiveSecondsPlotTimer.start();
      everyTenSecondsPlotTimer.start();
	    energyTimer.start();
	    renalTimer.start();
    }
  }
  onSpeedToggled :{
    if (speed == 1){
      root.state = "realTime"
    } else {
      root.state = "max"
    }
  }
  
  //Vitals//
  ObjectModel {
    id: vitalsObjectModel
    function createPlotView (model, request, title) {
     var vitals = physiologyRequestModel.category(PhysiologyModel.VITALS)
     root.createPlotViewHelper(model, request, title,vitalsObjectModel, vitalsGridView, 1)
    }
    function resizePlots(newWidth, newHeight){
      root.resizePlotsHelper(newWidth,newHeight,vitalsObjectModel)
    }
    function clearPlots() {
      root.clearPlotsHelper(vitalsObjectModel)
      }
    function updatePlot(key, data, model) {
      updatePlotHelper(key,data,model)
    }
  }
  vitalsGridView.onCellWidthChanged : {
    vitalsObjectModel.resizePlots(vitalsGridView.cellWidth, vitalsGridView.cellHeight)
  }
  vitalsGridView.onCellHeightChanged : {
    vitalsObjectModel.resizePlots(vitalsGridView.cellWidth, vitalsGridView.cellHeight)
  }
 //Cardiovascular//
  ObjectModel {
    id: cardiovascularObjectModel
    function createPlotView (model, request, title) {
     var vitals = physiologyRequestModel.category(PhysiologyModel.CARDIOVASCULAR)
     root.createPlotViewHelper(model, request, title,cardiovascularObjectModel, cardiovascularGridView, 1)
    }
    function resizePlots(newWidth, newHeight){
      root.resizePlotsHelper(newWidth,newHeight,cardiovascularObjectModel)
    }
    function clearPlots() {
      root.clearPlotsHelper(cardiovascularObjectModel)
    }
  }
  cardiovascularGridView.onCellWidthChanged : {
    cardiovascularObjectModel.resizePlots(cardiovascularGridView.cellWidth, cardiovascularGridView.cellHeight)
  }
  cardiovascularGridView.onCellHeightChanged : {
    cardiovascularObjectModel.resizePlots(cardiovascularGridView.cellWidth, cardiovascularGridView.cellHeight)
  }
  //Respiratory//
  ObjectModel {
    id: respiratoryObjectModel
    function createPlotView (model, request, title) {
     var vitals = physiologyRequestModel.category(PhysiologyModel.RESPIRATORY)
     root.createPlotViewHelper(model, request, title,respiratoryObjectModel, respiratoryGridView, 1)
    }
    function resizePlots(newWidth, newHeight){
      root.resizePlotsHelper(newWidth,newHeight,respiratoryObjectModel)
    }
    function clearPlots() {
      root.clearPlotsHelper(respiratoryObjectModel)
    }
  }
  respiratoryGridView.onCellWidthChanged : {
    respiratoryObjectModel.resizePlots(respiratoryGridView.cellWidth, respiratoryGridView.cellHeight)
  }
  respiratoryGridView.onCellHeightChanged : {
    respiratoryObjectModel.resizePlots(respiratoryGridView.cellWidth, respiratoryGridView.cellHeight)
  }
  //Blood Chemistry//
  ObjectModel {
    id: bloodChemistryObjectModel
    function createPlotView (model, request, title) {
      var blood = physiologyRequestModel.category(PhysiologyModel.BLOOD_CHEMISTRY)
      root.createPlotViewHelper(model, request, title,bloodChemistryObjectModel, bloodChemistryGridView, 1)
    }
    function resizePlots(newWidth, newHeight){
      root.resizePlotsHelper(newWidth,newHeight,bloodChemistryObjectModel)
    }
    function clearPlots() {
      root.clearPlotsHelper(bloodChemistryObjectModel)
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
    function createPlotView (model, request, title) {
     var energy = physiologyRequestModel.category(PhysiologyModel.ENERGY_AND_METABOLISM)
     root.createPlotViewHelper(model, request, title,energyMetabolismObjectModel, energyMetabolismGridView, 1)
    }
    function resizePlots(newWidth, newHeight){
      root.resizePlotsHelper(newWidth,newHeight,energyMetabolismObjectModel)
    }
    function clearPlots() {
      root.clearPlotsHelper(energyMetabolismObjectModel)
    }
  }
  energyMetabolismGridView.onCellWidthChanged : {
    energyMetabolismObjectModel.resizePlots(energyMetabolismGridView.cellWidth, energyMetabolismGridView.cellHeight)
  }
  energyMetabolismGridView.onCellHeightChanged : {
    energyMetabolismObjectModel.resizePlots(energyMetabolismGridView.cellWidth, energyMetabolismGridView.cellHeight)
  }
  //Renal - Overview//
  ObjectModel {
    id: renalObjectModel
    function createPlotView (model, request, title) {
     var vitals = physiologyRequestModel.category(PhysiologyModel.RENAL)
	 root.createPlotViewHelper(model, request, title,renalObjectModel, renalGridView, 1)
    }
    function resizePlots(newWidth, newHeight){
      root.resizePlotsHelper(newWidth,newHeight,renalObjectModel)
    }
    function clearPlots() {
      root.clearPlotsHelper(renalObjectModel)
    }
  }
  renalGridView.onCellWidthChanged : {
    renalObjectModel.resizePlots(renalGridView.cellWidth, renalGridView.cellHeight)
  }
  renalGridView.onCellHeightChanged : {
    renalObjectModel.resizePlots(renalGridView.cellWidth, renalGridView.cellHeight)
  }
  //Substances
  ObjectModel {
    id: substanceObjectModel
    function createPlotView (model, request, title) {
     var subs = physiologyRequestModel.category(PhysiologyModel.SUBSTANCES)
     root.createPlotViewHelper(model, request, title, substanceObjectModel, substanceGridView, 1)
    }
    function resizePlots(newWidth, newHeight){
      root.resizePlotsHelper(newWidth,newHeight,substanceObjectModel)
    }
    function clearPlots() {
      root.clearPlotsHelper(substanceObjectModel)
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
    function createPlotView (model, request, title) {
      var chartComponent = Qt.createComponent("CustomPlots.qml");
      if ( chartComponent.status != Component.Ready){
        if (chartComponent.status == Component.Error){
        console.log("Error : " + chartComponent.errorString() );
        return;
        }
        console.log("Error : Chart component not ready");
      } else {
        switch (title) {
          case "Respiratory PV Curve" :
            var chartObject = chartComponent.createObject(customGridView,{"width" : customGridView.cellWidth, "height" : customGridView.cellHeight });
            chartObject.initializeRespiratoryPVSeries(model,request,title);
            customObjectModel.append(chartObject);
            break;
          default :
            console.log(title + " not found");
        } 
      }  
    }
    function resizePlots(newWidth, newHeight){
      root.resizePlotsHelper(newWidth,newHeight,customObjectModel)
    }
    function clearPlots() {
      root.clearPlotsHelper(customObjectModel)
    }
  }
  customGridView.onCellWidthChanged : {
    customObjectModel.resizePlots(customGridView.cellWidth, customGridView.cellHeight)
  }
  customGridView.onCellHeightChanged : {
    customObjectModel.resizePlots(customGridView.cellWidth, customGridView.cellHeight)
  }
  function createPlotView(category, model, request, title){
    switch(category) {
      case PhysiologyModel.VITALS:
        vitalsModel.createPlotView(model, request, title);
        break;
      case PhysiologyModel.CARDIOVASCULAR:
        cardiovascularModel.createPlotView(model, request, title);
        break;
      case PhysiologyModel.RESPIRATORY:
        respiratoryModel.createPlotView(model, request, title);
        break;
      case PhysiologyModel.BLOOD_CHEMISTRY:
        bloodChemistryModel.createPlotView(model, request, title);
        break;
      case PhysiologyModel.ENERGY_AND_METABOLISM:
        energyMetabolismModel.createPlotView(model, request, title);
        break;
	    case PhysiologyModel.RENAL:
        renalModel.createPlotView(model, request, title);
        break;
      case PhysiologyModel.SUBSTANCES:
        substanceModel.createPlotView(model, request, title);
        break;
      case PhysiologyModel.CUSTOM:
        customModel.createPlotView(model, request, title);
        break;
    }
  }
  function removePlotView(category, menuIndex, request){
    let model = null
    switch(category) {
      case PhysiologyModel.VITALS:
        model = vitalsModel
        break;
      case PhysiologyModel.CARDIOVASULAR:
        model = cardiovascularModel
        break;
      case PhysiologyModel.RESPIRATORY:
        model = respiratoryModel
        break;
      case PhysiologyModel.BLOOD_CHEMISTRY:
        model = bloodChemistryModel
        break;
      case PhysiologyModel.ENERGY_AND_METABOLISM:
        model = energyMetabolismModel
        break;
		  case PhysiologyModel.RENAL:
		    model = renalModel
        break;
      case PhysiologyModel.SUBSTANCES:
        model = substanceModel
        break;
      case PhysiologyModel.CUSTOM:
        model = customModel
        break;
      default:
        console.log("Could not find Category  : %1".arg(category))
        return
    }
    for ( var i = 0; i < model.count; ++i ){
      var plot = model.get(i)
      console.log("Remove Custom Plot")
      console.log(category, menuIndex, request, plot.title)
      if (plot.title == request){
        model.remove(i,1)
      }
    }
  }

  tenHzPlotTimer.onTriggered : {
    let currentCategory = null
    let currentModel = null
    for (var i = 0 ; i < PhysiologyModel.TOTAL_CATEGORIES; ++i){
      switch (i){
        case PhysiologyModel.VITALS:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.VITALS)
          currentModel = vitalsObjectModel
        break;
        case PhysiologyModel.CARDIOVASCULAR:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CARDIOVASCULAR)
          currentModel = cardiovascularObjectModel
        break;
        case PhysiologyModel.RESPIRATORY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RESPIRATORY)
          currentModel = respiratoryObjectModel
        break;
        case PhysiologyModel.BLOOD_CHEMISTRY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.BLOOD_CHEMISTRY)
          currentModel = bloodChemistryObjectModel
        break;
        case PhysiologyModel.ENERGY_AND_METABOLISM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.ENERGY_AND_METABOLISM)
          currentModel = energyMetabolismObjectModel
        break;
		  case PhysiologyModel.RENAL:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RENAL)
          currentModel = renalObjectModel
        break;
        case PhysiologyModel.SUBSTANCES:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.SUBSTANCES)
          currentModel = substanceModel
        break;
        case PhysiologyModel.CUSTOM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CUSTOM)
          currentModel = customObjectModel
        break;
        default:
          continue;
      }
      for ( var j = 0; j < currentModel.count; ++j){
        var plot = currentModel.get(j)
        if (plot.model && plot.rate == 10){
          plot.update(physiologyRequestModel.simulation_time)
        }
      }
    }
  }
  
  fiveHzPlotTimer.onTriggered : {
    let currentCategory = null
    let currentModel = null
    for (var i = 0 ; i < PhysiologyModel.TOTAL_CATEGORIES; ++i){
      switch (i){
        case PhysiologyModel.VITALS:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.VITALS)
          currentModel = vitalsObjectModel
        break;
        case PhysiologyModel.CARDIOVASCULAR:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CARDIOVASCULAR)
          currentModel = cardiovascularObjectModel
        break;
        case PhysiologyModel.RESPIRATORY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RESPIRATORY)
          currentModel = respiratoryObjectModel
        break;
        case PhysiologyModel.BLOOD_CHEMISTRY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.BLOOD_CHEMISTRY)
          currentModel = bloodChemistryObjectModel
        break;
        case PhysiologyModel.ENERGY_AND_METABOLISM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.ENERGY_AND_METABOLISM)
          currentModel = energyMetabolismObjectModel
        break;
		    case PhysiologyModel.RENAL:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RENAL)
          currentModel = renalObjectModel
        break;
        case PhysiologyModel.SUBSTANCES:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.SUBSTANCES)
          currentModel = substanceModel
        break;
        case PhysiologyModel.CUSTOM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CUSTOM)
          currentModel = customObjectModel
        break;
        default:
          continue;
      }
      for ( var j = 0; j < currentModel.count; ++j){
        var plot = currentModel.get(j)
        if (plot.model && plot.rate == 5){
          plot.update(physiologyRequestModel.simulation_time)
        }
      }
    }
  }

  oneHzPlotTimer.onTriggered : {
    let currentCategory = null
    let currentModel = null
    for (var i = 0 ; i < PhysiologyModel.TOTAL_CATEGORIES; ++i){
      switch (i){
        case PhysiologyModel.VITALS:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.VITALS)
          currentModel = vitalsObjectModel
        break;
        case PhysiologyModel.CARDIOVASCULAR:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CARDIOVASCULAR)
          currentModel = cardiovascularObjectModel
        break;
        case PhysiologyModel.RESPIRATORY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RESPIRATORY)
          currentModel = respiratoryObjectModel
        break;
        case PhysiologyModel.BLOOD_CHEMISTRY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.BLOOD_CHEMISTRY)
          currentModel = bloodChemistryObjectModel
        break;
        case PhysiologyModel.ENERGY_AND_METABOLISM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.ENERGY_AND_METABOLISM)
          currentModel = energyMetabolismObjectModel
        break;
		    case PhysiologyModel.RENAL:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RENAL)
          currentModel = renalObjectModel
        break;
        case PhysiologyModel.SUBSTANCES:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.SUBSTANCES)
          currentModel = substanceModel
        break;
        case PhysiologyModel.CUSTOM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CUSTOM)
          currentModel = customObjectModel
        break;
        default:
          continue;
      }
      for ( var j = 0; j < currentModel.count; ++j){
        var plot = currentModel.get(j)
        if (plot.model && plot.rate == 1){
          plot.update(physiologyRequestModel.simulation_time)
        }
      }
    }
  }

    everyFiveSecondsPlotTimer.onTriggered : {
    let currentCategory = null
    let currentModel = null
    for (var i = 0 ; i < PhysiologyModel.TOTAL_CATEGORIES; ++i){
      switch (i){
        case PhysiologyModel.VITALS:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.VITALS)
          currentModel = vitalsObjectModel
        break;
        case PhysiologyModel.CARDIOVASCULAR:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CARDIOVASCULAR)
          currentModel = cardiovascularObjectModel
        break;
        case PhysiologyModel.RESPIRATORY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RESPIRATORY)
          currentModel = respiratoryObjectModel
        break;
        case PhysiologyModel.BLOOD_CHEMISTRY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.BLOOD_CHEMISTRY)
          currentModel = bloodChemistryObjectModel
        break;
        case PhysiologyModel.ENERGY_AND_METABOLISM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.ENERGY_AND_METABOLISM)
          currentModel = energyMetabolismObjectModel
        break;
		    case PhysiologyModel.RENAL:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RENAL)
          currentModel = renalObjectModel
        break;
        case PhysiologyModel.SUBSTANCES:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.SUBSTANCES)
          currentModel = substanceModel
        break;
        case PhysiologyModel.CUSTOM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CUSTOM)
          currentModel = customObjectModel
        break;
        default:
          continue;
      }
      for ( var j = 0; j < currentModel.count; ++j){
        var plot = currentModel.get(j)
        if (plot.model && plot.rate == -5){
          
          plot.update(physiologyRequestModel.simulation_time)
        }
      }
    }
  }

  everyTenSecondsPlotTimer.onTriggered : {
    let currentCategory = null
    let currentModel = null
    for (var i = 0 ; i < PhysiologyModel.TOTAL_CATEGORIES; ++i){
      switch (i){
        case PhysiologyModel.VITALS:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.VITALS)
          currentModel = vitalsObjectModel
        break;
        case PhysiologyModel.CARDIOVASCULAR:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CARDIOVASCULAR)
          currentModel = cardiovascularObjectModel
        break;
        case PhysiologyModel.RESPIRATORY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RESPIRATORY)
          currentModel = respiratoryObjectModel
        break;
        case PhysiologyModel.BLOOD_CHEMISTRY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.BLOOD_CHEMISTRY)
          currentModel = bloodChemistryObjectModel
        break;
        case PhysiologyModel.ENERGY_AND_METABOLISM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.ENERGY_AND_METABOLISM)
          currentModel = energyMetabolismObjectModel
        break;
		    case PhysiologyModel.RENAL:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RENAL)
          currentModel = renalObjectModel
        break;
        case PhysiologyModel.SUBSTANCES:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.SUBSTANCES)
          currentModel = substanceModel
        break;
        case PhysiologyModel.CUSTOM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CUSTOM)
          currentModel = customObjectModel
        break;
        default:
          continue;
      }
      for ( var j = 0; j < currentModel.count; ++j){
        var plot = currentModel.get(j)
        if (plot.model && plot.rate == -10){
          plot.update(physiologyRequestModel.simulation_time)
        }
      }
    }
  }
}
