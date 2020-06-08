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

  signal substanceDataUpdates(real time, var subData)
  signal stateUpdates(PatientState state)
  signal conditionUpdates(PatientConditions conditions)
  signal newActiveSubstance(Substance sub)

  signal newPhysiologyModel(PhysiologyModel model)

  property double count_1 : 0.0
  property double count_2 : 0.0

  property ObjectModel vitalsModel : vitalsObjectModel
  property ObjectModel cardiopulmonaryModel : cardiopulmonaryObjectModel
  property ObjectModel bloodChemistryModel : bloodChemistryObjectModel
  property ObjectModel energyMetabolismModel : energyMetabolismObjectModel
  property ObjectModel renalFluidBalanceModel : renalFluidBalanceObjectModel
  property ObjectModel substanceModel : substanceObjectModel
  property ObjectModel customModel : customObjectModel

  property double currentTime_s


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

  Rectangle {
    anchors.fill : parent
    border.color: "black"; color: "transparent"
  }

  onNewPhysiologyModel : {
    physiologyRequestModel = model;
  }

  onStart : {
    oneHzPlotTimer.start();
    fiveHzPlotTimer.start();
    tenHzPlotTimer.start();
    everyFiveSecondsPlotTimer.start();
    everyTenSecondsPlotTimer.start();
  }

  onRestart : {
    oneHzPlotTimer.stop();
    fiveHzPlotTimer.stop();
    tenHzPlotTimer.stop();
    everyFiveSecondsPlotTimer.stop();
    everyTenSecondsPlotTimer.stop();

    vitalsObjectModel.clearPlots()
    cardiopulmonaryObjectModel.clearPlots()
    bloodChemistryObjectModel.clearPlots()
    energyMetabolismObjectModel.clearPlots()
    renalFluidBalanceObjectModel.clearPlots()
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
    } else {
      oneHzPlotTimer.start();
      fiveHzPlotTimer.start();
      tenHzPlotTimer.start();
      everyFiveSecondsPlotTimer.start();
      everyTenSecondsPlotTimer.start();
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


  onPhysiologyRequestModelChanged: {
    //TODO Fix Initial Plots
    if( !root.initialized ){
      root.initialized = true;
      var vitalsReq = physiologyRequestModel.category(0)
      for ( var i = 0; i < vitalsReq.count ; ++i){
        if (vitalsReq.get(i).active){
		  		physiologyRequestModel.get(0).activeRequests.append({"request": vitalsReq.get(i).request})
		  		vitalsModel.createPlotView(vitalsReq.get(i))
		  	}
      }
      var cardiopulmonaryReq = physiologyRequestModel.category(1)
      for ( var i = 0; i < cardiopulmonaryReq.count; ++i){
        if( cardiopulmonaryReq.get(i).active){
          physiologyRequestModel.get(1).activeRequests.append({"request": cardiopulmonaryReq.get(i).request})
          cardiopulmonaryModel.createPlotView(cardiopulmonaryReq.get(i))
        }
      }
      var bloodChemistryReq = physiologyRequestModel.category(2)
      for ( var i = 0; i < bloodChemistryReq.count; ++i){
        if( bloodChemistryReq.get(i).active){
          physiologyRequestModel.get(2).activeRequests.append({"request": bloodChemistryReq.get(i).request})
          bloodChemistryModel.createPlotView(bloodChemistryReq.get(i))
        }
      }
      var energyMetabolismReq = physiologyRequestModel.category(3)
      for ( var i = 0; i < energyMetabolismReq.count ; ++i){
        if(energyMetabolismReq.get(i).active){
          physiologyRequestModel.get(3).activeRequests.append({"request": energyMetabolismReq.get(i).request})
          energyMetabolismModel.createPlotView(energyMetabolismReq.get(i))
        }
      }
      var renalFluidBalanceReq = physiologyRequestModel.category(4)
      for ( var i = 0; i < renalFluidBalanceReq.count ; ++i){
        if(renalFluidBalanceReq.get(i).active){
          physiologyRequestModel.get(4).activeRequests.append({"request": renalFluidBalanceReq.get(i).request})
          renalFluidBalanceModel.createPlotView(renalFluidBalanceReq.get(i))
        }  
      }
      var customReq = physiologyRequestModel.category(5)
      for ( var i = 0; i < customReq.count ; ++i){
        if( customReq.get(i).active){
          physiologyRequestModel.get(5).activeRequests.append({"request": customReq.get(i).request})
          customModel.createPlotView(customReq.get(i))
        }
      }
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

 //Cardiopulmonary//
  ObjectModel {
    id: cardiopulmonaryObjectModel
    function createPlotView (model, request, title) {
     var vitals = physiologyRequestModel.category(PhysiologyModel.CARDIOPULMONARY)
     root.createPlotViewHelper(model, request, title,cardiopulmonaryObjectModel, cardiopulmonaryGridView, 1)
    }
    function resizePlots(newWidth, newHeight){
      root.resizePlotsHelper(newWidth,newHeight,cardiopulmonaryObjectModel)
    }
    function clearPlots() {
      root.clearPlotsHelper(cardiopulmonaryObjectModel)
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

  //Renal - Fluid Balance//
  ObjectModel {
    id: renalFluidBalanceObjectModel
    function createPlotView (model, request, title) {
     var vitals = physiologyRequestModel.category(PhysiologyModel.RENAL_FLUID_BALANCE)
    root.createPlotViewHelper(model, request, title,renalFluidBalanceObjectModel, renalFluidBalanceGridView, 1)
    }
    function resizePlots(newWidth, newHeight){
      root.resizePlotsHelper(newWidth,newHeight,renalFluidBalanceObjectModel)
    }
    function clearPlots() {
      root.clearPlotsHelper(renalFluidBalanceObjectModel)
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
      case PhysiologyModel.CARDIOPULMONARY:
        cardiopulmonaryModel.createPlotView(model, request, title);
        break;
      case PhysiologyModel.BLOOD_CHEMISTRY:
        bloodChemistryModel.createPlotView(model, request, title);
        break;
      case PhysiologyModel.ENERGY_AND_METABOLISM:
        energyMetabolismModel.createPlotView(model, request, title);
        break;
      case PhysiologyModel.RENAL_FLUID_BALANCE:
        renalFluidBalanceModel.createPlotView(model, request, title);
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
        case PhysiologyModel.CARDIOPULMONARY:
          model = cardiopulmonaryModel
          break;
        case PhysiologyModel.BLOOD_CHEMISTRY:
          model = bloodChemistryModel
          break;
        case PhysiologyModel.ENERGY_AND_METABOLISM:
          model = energyMetabolismModel
          break;
        case PhysiologyModel.RENAL_FLUID_BALANCE:
          model = renalFluidBalanceModel
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
        if(plot.title == request)
        {
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
        case PhysiologyModel.CARDIOPULMONARY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CARDIOPULMONARY)
          currentModel = cardiopulmonaryObjectModel
        break;
        case PhysiologyModel.BLOOD_CHEMISTRY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.BLOOD_CHEMISTRY)
          currentModel = bloodChemistryObjectModel
        break;
        case PhysiologyModel.ENERGY_AND_METABOLISM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.ENERGY_AND_METABOLISM)
          currentModel = energyMetabolismObjectModel
        break;
        case PhysiologyModel.RENAL_FLUID_BALANCE:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RENAL_FLUID_BALANCE)
          currentModel = renalFluidBalanceObjectModel
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
        case PhysiologyModel.CARDIOPULMONARY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CARDIOPULMONARY)
          currentModel = cardiopulmonaryObjectModel
        break;
        case PhysiologyModel.BLOOD_CHEMISTRY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.BLOOD_CHEMISTRY)
          currentModel = bloodChemistryObjectModel
        break;
        case PhysiologyModel.ENERGY_AND_METABOLISM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.ENERGY_AND_METABOLISM)
          currentModel = energyMetabolismObjectModel
        break;
        case PhysiologyModel.RENAL_FLUID_BALANCE:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RENAL_FLUID_BALANCE)
          currentModel = renalFluidBalanceObjectModel
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
        case PhysiologyModel.CARDIOPULMONARY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CARDIOPULMONARY)
          currentModel = cardiopulmonaryObjectModel
        break;
        case PhysiologyModel.BLOOD_CHEMISTRY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.BLOOD_CHEMISTRY)
          currentModel = bloodChemistryObjectModel
        break;
        case PhysiologyModel.ENERGY_AND_METABOLISM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.ENERGY_AND_METABOLISM)
          currentModel = energyMetabolismObjectModel
        break;
        case PhysiologyModel.RENAL_FLUID_BALANCE:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RENAL_FLUID_BALANCE)
          currentModel = renalFluidBalanceObjectModel
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
        case PhysiologyModel.CARDIOPULMONARY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CARDIOPULMONARY)
          currentModel = cardiopulmonaryObjectModel
        break;
        case PhysiologyModel.BLOOD_CHEMISTRY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.BLOOD_CHEMISTRY)
          currentModel = bloodChemistryObjectModel
        break;
        case PhysiologyModel.ENERGY_AND_METABOLISM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.ENERGY_AND_METABOLISM)
          currentModel = energyMetabolismObjectModel
        break;
        case PhysiologyModel.RENAL_FLUID_BALANCE:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RENAL_FLUID_BALANCE)
          currentModel = renalFluidBalanceObjectModel
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
        case PhysiologyModel.CARDIOPULMONARY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.CARDIOPULMONARY)
          currentModel = cardiopulmonaryObjectModel
        break;
        case PhysiologyModel.BLOOD_CHEMISTRY:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.BLOOD_CHEMISTRY)
          currentModel = bloodChemistryObjectModel
        break;
        case PhysiologyModel.ENERGY_AND_METABOLISM:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.ENERGY_AND_METABOLISM)
          currentModel = energyMetabolismObjectModel
        break;
        case PhysiologyModel.RENAL_FLUID_BALANCE:
          currentCategory = physiologyRequestModel.category(PhysiologyModel.RENAL_FLUID_BALANCE)
          currentModel = renalFluidBalanceObjectModel
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
