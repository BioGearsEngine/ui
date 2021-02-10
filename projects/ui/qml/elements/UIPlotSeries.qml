import QtQuick 2.12
import QtCharts 2.3

import com.biogearsengine.ui.scenario 1.0
UIPlotSeriesForm {
  id : root


  property var requestNames: [];
  property var model: null;
  property var index: null;
  property alias rate : root.refresh_rate;
  property int refreshOffset : 0;

  property double minCache : NaN
  property double maxCache : NaN
  property double minCount : NaN
  property double maxCount : NaN

  // Initilaizes chart based on input pulling existing data from the model.
  // TODO: Put AutoScaling On/Off in Model
  function initializeChart(biogearsData, physiologyRequest, title) {
    model = biogearsData;
    index = physiologyRequest;
    var v_name = title;

    root.refreshOffset = Math.floor(Math.random() * 10);

    switch (model.data(index, PhysiologyModel.RateRole)) {
      case 1:
        speed_1hz.checked = true;
        break;
      case 5:
        speed_5hz.checked = true;
        break;
      case 10:
        speed_10hz.checked = true;
        break;
      case - 5:
        speed_5s.checked = true;
        break;
      case - 10:
        speed_10s.checked = true;
        break;
      default:
        // code block
    }

    if (model.rowCount(index)) {
      if (model.data(index, PhysiologyModel.NestedRole)) {
        // NOTE: We should not ever get here as GraphAreaForm.ui should have
        //      broken the nested ot individual calls, but
      } else {
        requestNames = []
        for (let i = 0; i < model.rowCount(index); ++ i) {
          let l_subIndex = biogearsData.index(i, 0, physiologyRequest);
          requestNames.push(biogearsData.data(l_subIndex, Qt.DisplayRole));
          let l_series = root.createSeries(ChartView.SeriesTypeLine, biogearsData.data(l_subIndex, Qt.DisplayRole), xAxis, yAxis);
        }
        root.legend.visible = true
      }
    } else { // Common single line plot
      let l_series = root.createSeries(ChartView.SeriesTypeLine, v_name, xAxis, yAxis);
      root.requestNames.push(v_name);
    }
    yAxis.visible = false
    root.title = v_name;
  }

  // Gets simulation time and physiology data request from patient metrics, appending new point to each series
  function update(time_s, visibility) {
    let time_m = time_s / 60;
    if (root.count > 1) {
      for (let i = 0; i < root.count; ++ i) {
        let subRequest = requestNames[i];
        let subIndex = model.index(i, 0, index);
        let prop = root.model.data(subIndex, PhysiologyModel.ValueRole);
        root.series(subRequest).append(time_m, prop);

        if ( isNaN(root.minCache)) {
          root.minCache = prop
          root.minCount = 1;
        } else if (prop < root.minCache) {
          root.minCache = prop;
          root.minCount = 0
        } else if (prop == root.minCache) {
          root.minCount ++
        }       

        if ( isNaN(root.maxCache) ) {
          root.maxCache = prop
          root.maxCount = 1;
        } else if (prop > root.maxCache) {
          root.maxCache = prop;
          root.maxCount = 0
        } else if (prop == root.maxCache) {
          root.maxCount ++
        }

        if (!yAxis.visible) {
          yAxis.visible = true;
          yAxis.titleText = root.model.data(subIndex, PhysiologyModel.UnitRole);
        }
      }
    } else {
      let prop = root.model.data(index, PhysiologyModel.ValueRole);
      root.series(root.requestNames[0]).append(time_m, prop);
      if (isNaN(root.minCache)) {
        root.minCache = prop
        root.minCount = 1;
      } else if (prop < root.minCache) {
        root.minCache = prop;
        root.minCount = 0
      } else if (prop == root.minCache) {
        root.minCount ++
      }

      if (isNaN(root.maxCache)) {
        root.maxCache = prop
        root.maxCount = 1;
      } else if (prop > root.maxCache) {
        root.maxCache = prop;
        root.maxCount = 0
      } else if (prop == root.maxCache) {
        root.maxCount ++
      }

      if (!yAxis.visible) {
        yAxis.visible = true;
        yAxis.titleText = root.model.data(index, PhysiologyModel.UnitRole);
      }
    } updateXInterval(time_s, visibility);

    if (Math.floor(time_s + refreshOffset) % 5 == 0) {
      updateYInterval(time_s, visibility);
    }

    if (Math.floor(time_s + refreshOffset) % 10 == 0) {
      pruneHistory(time_s, visibility);
    }

  }

  // Gets simulation time and substance data request from substance metrics, appending new point to each series
  function updateSubstanceSeries(time_s, subData, visibility) { // Substance request names stored as (e.g.) Sodium-BloodConcentration.  Split at '-' to get substance (key) and property (object)
    let requestComponents = root.requestNames[0].split('-');
    let substance = requestComponents[0];
    let propName = requestComponents[1];
    let prop = subData[substance][propName];

    root.series(root.requestNames[0]).append(time_s / 60.0, prop);

    if (isNaN(root.minCache)) {
      root.minCache = prop
      root.minCount = 1;
    } else if (prop < root.minCache) {
      root.minCache = prop;
      root.minCount = 0
    } else if (prop == root.minCache) {
      root.minCount ++
    }
    
    if (isNaN(root.maxCache)) {
      root.maxCache = prop
      root.maxCount = 1;
    } else if (prop > root.maxCache) {
      root.maxCache = prop;
      root.maxCount = 0
    } else if (prop == root.maxCache) {
      root.maxCount ++
    }


    updateDomainAndRange(time_s, updateDomainAndRange);
    if (!yAxis.visible) {
      yAxis.visible = true;
    }
  }


  // Gets simulation time and physiology data request from patient metrics, appending new point to each series
  function clear(visibility) {
    if (root.count > 1) {
      for (let i = 0; i < root.count; ++ i) {
        let series = root.series(root.requestNames[i])
        series.removePoints(0, series.count)
      }
    } else {
      let series = root.series(root.requestNames[0])
      series.removePoints(0, series.count)
    }
  }

  function updateXInterval(time_s, visibility) {
    if (visibility) {
      const interval_s = 60 * timeInterval_m
      if (time_s > interval_s) {
        xAxis.min = (time_s - interval_s) / 60;
        xAxis.max = time_s / 60;
      } else {
        xAxis.min = 0;
        xAxis.max = timeInterval_m;
      }
    }
  }

  function updateYInterval(time_s, visibility) {
    if (root.autoScaleEnabled && visibility) {
      if (Math.floor(root.minCache) != Math.floor(root.maxCache)) {
        yAxis.min = root.minCache -(root.maxCache - root.minCache) * .5;
        yAxis.max = root.maxCache + (root.maxCache - root.minCache) * .5;
      } else {
        yAxis.min = root.minCache - 1;
        yAxis.max = root.maxCache + 1;
      }      
    } else {
      yAxis.min = userSpecifiedMin;
      yAxis.max = userSpecifiedMax;
      calculateScale = true;
    }
  }

  function pruneHistory(time_s, visibility) {
    const time_m = time_s / 60;
    for (let i = 0; i < root.count; ++ i) {
      var trim_count = 0;

      // Currently, the maximum timescale is 10 minutes we need to remove any points outside of that scale
      // We assumed well ordered time data.
      for (let j = 0; j < root.series(i).count; ++ j) {
        if (root.series(i).at(j).x > (time_m - 10)) {
          trim_count = j;
          break;
        }

        if (root.autoScaleEnabled) {
          if (root.series(i).at(j).y == root.minCache) {
            root.minCount -= 1;
            if (root.minCount == 0) {
              root.minCount = 1
              root.minCache = root.series(i).at(j + 1).y
            }
          }
          if (root.series(i).at(j).y == root.maxCache) {
            root.maxCount -= 1;
            if (root.maxCount == 0) {
              root.maxCount = 1
              root.maxCache = root.series(i).at(j + 1).y
            }
          }
        }
      }
      root.series(i).removePoints(0, trim_count)
    }
  }

  function updateDomainAndRange(time_s, visibility) {
    updateYInterval(time_s, visibility)
    updateXInterval(time_s, visibility)
    pruneHistory(time_s, visibility)
  }

  // Updates plot size when the application window size changes
  function resizePlot(newWidth, newHeight) {
    root.width = newWidth
    root.height = newHeight
  }


}
