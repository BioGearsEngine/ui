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
  signal timeAdvance(double time)

  property double count_1 : 0.0
  property double count_2 : 0.0
  property int tickCount : -1

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
  function createPlotViewHelper (request, objectModel, view, refreshRate) {
    var chartComponent = Qt.createComponent("UIPlotSeries.qml");
    console.log("%1 %2 %3 %4".arg(request).arg(objectModel).arg(view).arg(refreshRate))
    if ( chartComponent.status != Component.Ready){
      if (chartComponent.status == Component.Error){
      console.log("Error : " + chartComponent.errorString() );
      return;
      }
      console.log("Error : Chart component not ready");
    } else {
      var chartObject = chartComponent.createObject(view,{"width" : view.cellWidth, "height" : view.cellHeight });
      request.rate = refreshRate
      chartObject.dataSource = request
      chartObject.initializeChart(tickCount);
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

					onTimeAdvance : {
    currentTime_s = time
    tickCount++
  }
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

    function createPlotView (index, request) {
      console.log("GraphArea.qml CreatePlot View %1 %2 %3".arg(index).arg(request))
     root.createPlotViewHelper(request, vitalsObjectModel, vitalsGridView, 1)
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
    function createPlotView  (index, request) {
     root.createPlotViewHelper(request, cardiopulmonaryObjectModel, cardiopulmonaryGridView, 1)
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
    function createPlotView  (index, request) {
     root.createPlotViewHelper(request, bloodChemistryObjectModel, bloodChemistryGridView, 1)
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
    function createPlotView  (index, request) {
     root.createPlotViewHelper(request, energyMetabolismObjectModel, energyMetabolismGridView, 1)
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
    function createPlotView  (index, request) {
     root.createPlotViewHelper(request, renalFluidBalanceObjectModel, renalFluidBalanceGridView, 1)
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
    function createPlotView  (index, request) {
     root.createPlotViewHelper(request, substanceObjectModel, substanceGridView, substanceDataUpdates)
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
    function createPlotView  (index, request) {
     root.createPlotViewHelper(request, customObjectModel, customGridView, 10)
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

  function createPlotView(category, menuIndex, modelElement){
    switch(category) {
      case PhysiologyModel.VITALS:
        vitalsModel.createPlotView(menuIndex,modelElement);
        break;
      case PhysiologyModel.CARDIOPULMONARY:
        cardiopulmonaryModel.createPlotView(menuIndex,modelElement);
        break;
      case PhysiologyModel.BLOOD_CHEMISTRY:
        bloodChemistryModel.createPlotView(menuIndex,modelElement);
        break;
      case PhysiologyModel.ENERGY_AND_METABOLISM:
        energyMetabolismModel.createPlotView(menuIndex,modelElement);
        break;
      case PhysiologyModel.RENAL_FLUID_BALANCE:
        renalFluidBalanceModel.createPlotView(menuIndex,modelElement);
        break;
      case PhysiologyModel.SUBSTANCES:
        substanceModel.createPlotView(menuIndex,modelElement);
        break;
      case PhysiologyModel.CUSTOM:
        customModel.createPlotView(menuIndex,modelElement);
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
      console.log(model)
      for ( var i = 0; i < model.count; ++i ){
        var plot = model.get(i)
        if(plot.title == request)
          model.remove(i,1)
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


  tenHzPlotTimer.onTriggered : {
    console.log("tenHzPlotTimeronTriggered")
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

      for ( var j = 0; j < currentCategory.rowCount(); ++j){
        var index = currentCategory.index(j,0)
        if( currentCategory.data(index, PhysiologyModel.EnabledRole)
             && currentCategory.data(index,PhysiologyModel.RateRole)){
                 currentModel.update(j,index, currentCategory)
        }
      }
    }

   }
  

  oneHzPlotTimer.onTriggered : {
     console.log("oneHzPlotTimer")
 var vitals = physiologyRequestModel.category(PhysiologyModel.VITALS)
     var cardio = physiologyRequestModel.category(PhysiologyModel.CARDIOPULMONARY)
     var blood = physiologyRequestModel.category(PhysiologyModel.BLOOD_CHEMISTRY)
     var renal = physiologyRequestModel.category(PhysiologyModel.RENAL)
     var drugs = physiologyRequestModel.category(PhysiologyModel.DRUGS)
     var substances = physiologyRequestModel.category(PhysiologyModel.SUBSTANCES)
     var panels = physiologyRequestModel.category(PhysiologyModel.PANELS)
     
  }
}
