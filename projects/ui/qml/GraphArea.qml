import QtQuick 2.4
import QtQuick.Controls.Material 2.12
import QtCharts 2.3

import com.biogearsengine.ui.scenario 1.0

GraphAreaForm {
  signal start()
  signal stop()
  signal pause()

  signal metricUpdates(PatientMetrics metrics)
  signal stateUpdates(PatientState state)
  signal conditionUpdates(PatientConditions conditions)


  property double count_1 : 0.0
  property double count_2 : 0.0

  onStart : {
    console.log("GraphAreaForm " + "start")
  }

  onStop : {
    console.log("GraphAreaForm " + "stop")
  }

  onPause: {
    console.log("GraphAreaForm " + "pause")
  }

  onMetricUpdates: {
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
		bloodChemistryModel.createPlotView(bloodChemistryReq.get(i).request)
		}
    }
    var cardiovascularReq = physiologyRequestModel.get(1).requests
    for ( var i = 0; i < cardiovascularReq.count; ++i){
      if( cardiovascularReq.get(i).active){
		physiologyRequestModel.get(1).activeRequests.append({"request": cardiovascularReq.get(i).request})
		cardiovascularModel.createPlotView(cardiovascularReq.get(i).request)
		}
    }
    var drugReq = physiologyRequestModel.get(2).requests
    for ( var i = 0; i < drugReq.count; ++i){
      if( drugReq.get(i).active){
		physiologyRequestModel.get(2).activeRequests.append({"request": drugReq.get(i).request})
		drugModel.createPlotView(drugReq.get(i).request)
		}
    }
    var endocrineReq = physiologyRequestModel.get(3).requests
    for ( var i = 0; i < endocrineReq.count ; ++i){
      if(endocrineReq.get(i).active){
		physiologyRequestModel.get(3).activeRequests.append({"request": endocrineReq.get(i).request})
		endocrineModel.createPlotView(endocrineReq.get(i).request)
		}
    }
    var energyReq = physiologyRequestModel.get(4).requests
    for ( var i = 0; i < energyReq.count ; ++i){
      if(energyReq.get(i).active){
		physiologyRequestModel.get(4).activeRequests.append({"request": energyReq.get(i).request})
		energyModel.createPlotView(energyReq.get(i).request)
		}  
    }
    var gastrointestinalReq = physiologyRequestModel.get(5).requests
    for ( var i = 0; i < gastrointestinalReq.count ; ++i){
      if( gastrointestinalReq.get(i).active){
		physiologyRequestModel.get(5).activeRequests.append({"request": gastrointestinalReq.get(i).request})
		gastrointestinalModel.createPlotView(gastrointestinalReq.get(i).request)
		}     
    }
    var hepaticReq = physiologyRequestModel.get(6).requests
    for ( var i = 0; i < hepaticReq.count ; ++i){
      if(hepaticReq.get(i).active){
		physiologyRequestModel.get(6).activeRequests.append({"request": hepaticReq.get(i).request})
		hepaticModel.createPlotView(hepaticReq.get(i).request)
		}
    }
    var nervousReq = physiologyRequestModel.get(7).requests
    for ( var i = 0; i < nervousReq.count; ++i){
      if( nervousReq.get(i).active){
		physiologyRequestModel.get(7).activeRequests.append({"request": nervousReq.get(i).request})
		nervousModel.createPlotView(nervousReq.get(i).request)
		} 
    }
    var renalReq = physiologyRequestModel.get(8).requests
    for ( var i = 0; i < renalReq.count ; ++i){
      if(renalReq.get(i).active){
		physiologyRequestModel.get(8).activeRequests.append({"request": renalReq.get(i).request})
		renalModel.createPlotView(renalReq.get(i).request)
		} 
    }
    var respiratoryReq = physiologyRequestModel.get(9).requests
    for ( var i = 0; i < respiratoryReq.count ; ++i){
      if(respiratoryReq.get(i).active){
		physiologyRequestModel.get(9).activeRequests.append({"request": respiratoryReq.get(i).request})
		respiratoryModel.createPlotView(respiratoryReq.get(i).request)
		}
    }
    var tissueReq = physiologyRequestModel.get(10).requests
    for ( var i = 0; i < tissueReq.count ; ++i){
      if(tissueReq.get(i).active){
		physiologyRequestModel.get(10).activeRequests.append({"request": tissueReq.get(i).request})
		tissueModel.createPlotView(tissueReq.get(i).request)
		}
    }
  }

  function newPointHandler(series,pointIndex) {
      const MAX_INTERVAL = 3600
      var start = ( series.count < MAX_INTERVAL ) ? 0 : series.count - MAX_INTERVAL;

      if ( !series.min || !series.max)  {
        series.min = series.at(series.count-1).y
        series.max = series.at(series.count-1).y
        series.min_count = 0
        series.max_count = 0
      }

      //New Poiunts
      if ( series.at(series.count-1).y < series.min) {
         series.min = series.at(series.count-1).y
         series.min_count = 1
      } else if ( series.at(series.count-1).y ==  series.min) {
          series.min_count += 1
      }

      if ( series.at(series.count-1).y > series.max) {
         series.max = series.at(series.count-1).y
         series.max_count = 1
      } else if ( series.at(series.count-1).y ==  series.max) {
          series.max_count += 1
      }
      //Deleting Points
      if ( series.at(start).y == series.min && series.count > MAX_INTERVAL ) {
         series.min_count -= 1
         if ( series.min_count == 0 ) {
          series.min = series.at(start - 1).y
         }
      }
      if ( series.at(start).y == series.max && series.count > MAX_INTERVAL ) {
         series.max_count -= 1
         if (series.max_count == 0 ) {
           series.max = series.at(series.count - 2 ).y
         }
      }
      
      series.axisY.min = (series.min == -1.0 || series.min == 0.0 ) ? series.min : series.min * 0.9
      series.axisY.max = (series.max == 1.0 ) ? series.max :series.max * 1.1
  }


  function updateDomain(axisX) {
    axisX.tickCount = axisX.tickCount + 1;
    const interval =  60 * 15
    if ( axisX.tickCount > interval ){
      axisX.min = axisX.tickCount - interval
      axisX.max = axisX.tickCount
    } else {
      axisX.min = 0
      axisX.max = interval
    }
  }

  //This function is specific to searching physiology request lists for an element with a "request" field that matches the input
  //We can look to generalize this to other fields if/when needed
  function findRequestIndex(list, request){
	var index = -1;
	for (var i = 0; i < list.count; ++i){
		if (list.get(i).title == request){
			index = i;
			break;
		}
	}
	return index;
  }

  function createPlotView(index, request){
	physiologyRequestModel.get(index).activeRequests.append({"request":request})
	switch(index) {
		case 0:
			bloodChemistryModel.createPlotView(request);
			break;
		case 1:
			cardiovascularModel.createPlotView(request);
			break;
		case 2:
			drugModel.createPlotView(request);
			break;
		case 3:
			endocrineModel.createPlotView(request);
			break;
		case 4:
			energyModel.createPlotView(request);
			break;
		case 5:
			gastrointestinalModel.createPlotView(request);
			break;
		case 6:
			hepaticModel.createPlotView(request);
			break;
		case 7:
			nervousModel.createPlotView(request);
			break;
		case 8:
			renalModel.createPlotView(request);
			break;
		case 9:
			respiratoryModel.createPlotView(request);
			break;
		case 10:
			tissueModel.createPlotView(request);
			break;
	}
  }

  function removePlotView(index, request){
	switch(index) {
		case 0:
			var i = findRequestIndex(bloodChemistryModel, request)
			if (i != -1){
				bloodChemistryModel.remove(i,1)
				physiologyRequestModel.get(index).activeRequests.remove(i,1)
			}
			break;
		case 1:
			var i = findRequestIndex(cardiovascularModel, request)
			if (i != -1){
				cardiovascularModel.remove(i,1)
				physiologyRequestModel.get(index).activeRequests.remove(i,1)
			}
			break;
		case 2:
			var i = findRequestIndex(drugModel, request)
			if (i != -1){
				drugModel.remove(i,1)
				physiologyRequestModel.get(index).activeRequests.remove(i,1)
			}
			break;
		case 3:
			var i = findRequestIndex(endocrineModel, request)
			if (i != -1){
				endocrineModel.remove(i,1)
				physiologyRequestModel.get(index).activeRequests.remove(i,1)
			}
			break;
		case 4:
			var i = findRequestIndex(energyModel, request)
			if (i != -1){
				energyModel.remove(i,1)
				physiologyRequestModel.get(index).activeRequests.remove(i,1)
			}
			break;
		case 5:
			var i = findRequestIndex(gastrointestinalModel, request)
			if (i != -1){
				gastrointestinalModel.remove(i,1)
				physiologyRequestModel.get(index).activeRequests.remove(i,1)
			}
			break;
		case 6:
			var i = findRequestIndex(hepaticModel, request)
			if (i != -1){
				hepaticModel.remove(i,1)
				physiologyRequestModel.get(index).activeRequests.remove(i,1)
			}
			break;
		case 7:
			var i = findRequestIndex(nervousModel, request)
			if (i != -1){
				nervousModel.remove(i,1)
				physiologyRequestModel.get(index).activeRequests.remove(i,1)
			}
			break;
		case 8:
			var i = findRequestIndex(renalModel, request)
			if (i != -1){
				renalModel.remove(i,1)
				physiologyRequestModel.get(index).activeRequests.remove(i,1)
			}
			break;
		case 9:
			var i = findRequestIndex(respiratoryModel, request)
			if (i != -1){
				respiratoryModel.remove(i,1)
				physiologyRequestModel.get(index).activeRequests.remove(i,1)
			}
			break;
		case 10:
			var i = findRequestIndex(tissueModel, request)
			if (i != -1){
				tissueModel.remove(i,1)
				physiologyRequestModel.get(index).activeRequests.remove(i,1)
			}
			break;

	}
  }

}
